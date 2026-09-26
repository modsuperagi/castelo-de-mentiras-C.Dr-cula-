// Testes do encanamento do SONAR com a xAI SIMULADA. Não validam a API real.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createServer } from 'node:http';

import { planejar } from '../lib/profundidade.js';
import { sintetizar, extrairCitacoesEmbutidas, extrairJson } from '../lib/sintese.js';
import { investigarNoGrok, ErroInvestigacao } from '../lib/xai.js';
import { consumir } from '../lib/limite.js';
import { iniciarXaiSimulada, RESPOSTA_EXEMPLO } from './xai-simulada.mjs';

test('profundidade adapta o plano à pergunta', () => {
  assert.equal(planejar('Qual é a capital da Austrália?').nivel, 'direta');
  assert.deepEqual(planejar('Qual é a capital da Austrália?').ferramentas, ['web_search']);
  assert.equal(planejar('Quais são as últimas novidades do Rust?').nivel, 'atual');
  assert.equal(planejar('Compare PostgreSQL e MySQL para análise').nivel, 'comparativa');
  const x = planejar('Compare as informações oficiais com o que está sendo discutido no X.');
  assert.equal(x.nivel, 'comparativa');
  assert.deepEqual(x.ferramentas, ['web_search', 'x_search']);
  const p = planejar('Investigue a fundo a situação da fusão nuclear comercial');
  assert.equal(p.nivel, 'profunda');
  assert.ok(p.ferramentas.includes('x_search'));
  assert.ok(p.maxTurnos > planejar('oi, tudo bem?').maxTurnos);
  // "raio x" não pede busca no X
  assert.deepEqual(planejar('Como funciona um raio x?').ferramentas, ['web_search']);
});

test('citações embutidas saem do texto e viram URLs', () => {
  const { texto, urls } = extrairCitacoesEmbutidas('Saiu hoje [[1]](https://a.com/x). Veja [o blog](https://b.com).');
  assert.equal(texto, 'Saiu hoje. Veja o blog.');
  assert.deepEqual(urls, ['https://a.com/x', 'https://b.com']);
});

test('extrai JSON com cerca de código ou texto em volta', () => {
  assert.deepEqual(extrairJson('```json\n{"a":1}\n```'), { a: 1 });
  assert.deepEqual(extrairJson('Aqui está: {"a":2} fim'), { a: 2 });
  assert.equal(extrairJson('sem json'), null);
});

test('síntese confere fontes, descarta as inventadas e rebaixa fato sem fonte', () => {
  const plano = planejar('Quais são as novidades da tecnologia Exemplo nesta semana?');
  const { resultado, proveniencia } = sintetizar({ pergunta: 'p', plano, bruto: RESPOSTA_EXEMPLO });

  assert.equal(resultado.estado, 'CONCLUIDO');
  assert.equal(resultado.fontes.length, 4);
  assert.deepEqual(resultado.fontes.map((f) => f.citada), [true, true, true, false]);
  assert.equal(resultado.fontes[0].titulo, 'Exemplo 2.0 chegou');
  assert.equal(resultado.fontes[2].origem, 'x');
  assert.ok(!resultado.fontes.some((f) => f.url.includes('inventada')), 'fonte inventada não pode aparecer');
  assert.deepEqual(proveniencia.referencias_descartadas, ['https://inventada.example.net/nao-existe']);

  assert.equal(resultado.resumo, 'A versão 2.0 da tecnologia Exemplo saiu nesta semana, segundo o anúncio oficial.');
  assert.deepEqual(resultado.achados[0].fontes, [1, 2]);
  assert.equal(resultado.achados[1].tipo, 'afirmacao');
  assert.equal(resultado.achados[2].tipo, 'incerteza');
  assert.deepEqual(resultado.achados[2].fontes, []);
  assert.equal(resultado.cruzamento.divergencias[0].posicoes.length, 2);
  assert.equal(resultado.avisos.length, 2);

  assert.deepEqual(resultado.consultas, [
    { ferramenta: 'web_search', consulta: 'exemplo tecnologia novidades semana' },
    { ferramenta: 'x_search', consulta: 'exemplo tecnologia lançamento' },
  ]);
});

test('sem fontes retornadas a investigação fica INCOMPLETA', () => {
  const bruto = { output: [{ type: 'message', content: [{ type: 'output_text', text: '{"resumo":"Talvez.","achados":[],"evidencia":"suficiente"}' }] }] };
  const { resultado } = sintetizar({ pergunta: 'p', plano: planejar('x y z'), bruto });
  assert.equal(resultado.estado, 'INCOMPLETO');
  assert.equal(resultado.evidencia, 'insuficiente');
});

test('texto fora do formato fica INCOMPLETO, e resposta vazia não vira resultado', () => {
  const bruto = { output: [{ type: 'message', content: [{ type: 'output_text', text: 'Texto livre [[1]](https://a.com).' }] }], citations: ['https://a.com'] };
  const { resultado } = sintetizar({ pergunta: 'p', plano: planejar('x y z'), bruto });
  assert.equal(resultado.estado, 'INCOMPLETO');
  assert.equal(resultado.resumo, 'Texto livre.');
  assert.equal(resultado.fontes[0].citada, true);
  assert.equal(sintetizar({ pergunta: 'p', plano: planejar('x'), bruto: { output: [] } }), null);
});

test('cliente xAI manda ferramentas, modelo e chave só no cabeçalho', async () => {
  const { servidor, pedidos, base } = await iniciarXaiSimulada();
  try {
    const plano = planejar('Compare o que está sendo discutido no X sobre o tema');
    const { bruto, parametros } = await investigarNoGrok({ pergunta: 'pergunta', plano, config: { chave: 'chave-de-teste', modelo: 'm', base, limiteMs: 5000 } });
    assert.equal(bruto.id, 'resp_simulada');
    assert.equal(pedidos[0].caminho, '/v1/responses');
    assert.equal(pedidos[0].autorizacao, 'Bearer chave-de-teste');
    assert.deepEqual(pedidos[0].corpo.tools, [{ type: 'web_search' }, { type: 'x_search' }]);
    assert.equal(pedidos[0].corpo.max_turns, plano.maxTurnos);
    assert.ok(!JSON.stringify(pedidos[0].corpo).includes('chave-de-teste'));
    assert.ok(parametros.includes('max_turns'));
  } finally {
    servidor.close();
  }
});

test('cliente xAI refaz uma vez sem o parâmetro opcional recusado', async () => {
  const { servidor, pedidos, base } = await iniciarXaiSimulada((corpo) => (
    'max_turns' in corpo
      ? { status: 400, json: { error: 'Argument not supported: max_turns' } }
      : { status: 200, json: RESPOSTA_EXEMPLO }
  ));
  try {
    const { parametros } = await investigarNoGrok({ pergunta: 'p', plano: planejar('p'), config: { chave: 'k', modelo: 'm', base, limiteMs: 5000 } });
    assert.equal(pedidos.length, 2);
    assert.ok(!parametros.includes('max_turns'));
  } finally {
    servidor.close();
  }
});

test('cliente xAI transforma falhas em erro explícito', async () => {
  await assert.rejects(
    investigarNoGrok({ pergunta: 'p', plano: planejar('p'), config: { chave: '', modelo: 'm', base: 'http://127.0.0.1:1', limiteMs: 1000 } }),
    (e) => e instanceof ErroInvestigacao && e.codigo === 'configuracao',
  );
  const { servidor, base } = await iniciarXaiSimulada(() => ({ status: 429, json: { error: 'rate' } }));
  try {
    await assert.rejects(
      investigarNoGrok({ pergunta: 'p', plano: planejar('p'), config: { chave: 'k', modelo: 'm', base, limiteMs: 5000 } }),
      (e) => e.codigo === 'cota',
    );
  } finally {
    servidor.close();
  }
  const lento = await iniciarXaiSimulada(() => ({ status: 200, json: {}, atraso: 500 }));
  try {
    await assert.rejects(
      investigarNoGrok({ pergunta: 'p', plano: planejar('p'), config: { chave: 'k', modelo: 'm', base: lento.base, limiteMs: 100 } }),
      (e) => e.codigo === 'tempo',
    );
  } finally {
    lento.servidor.close();
  }
});

test('limite de uso por endereço', () => {
  const env = { SONAR_LIMITE_POR_JANELA: '2', SONAR_JANELA_MINUTOS: '1' };
  assert.equal(consumir('1.1.1.1', env, 0).permitido, true);
  assert.equal(consumir('1.1.1.1', env, 1).permitido, true);
  assert.equal(consumir('1.1.1.1', env, 2).permitido, false);
  assert.equal(consumir('1.1.1.1', env, 61_000).permitido, true);
});

async function chamarEndpoint(env, corpo, headers = {}) {
  Object.assign(process.env, env);
  const { default: handler } = await import('../api/investigar.js');
  const servidor = createServer(handler);
  await new Promise((r) => servidor.listen(0, r));
  try {
    const resposta = await fetch(`http://127.0.0.1:${servidor.address().port}/api/investigar`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', ...headers },
      body: JSON.stringify(corpo),
    });
    const texto = await resposta.text();
    const tipo = resposta.headers.get('content-type');
    const eventos = tipo.includes('ndjson') ? texto.trim().split('\n').map((l) => JSON.parse(l)) : [JSON.parse(texto)];
    return { status: resposta.status, eventos };
  } finally {
    servidor.close();
  }
}

test('endpoint emite os estados em ordem e entrega o resultado', async () => {
  const { servidor, base } = await iniciarXaiSimulada();
  try {
    const { status, eventos } = await chamarEndpoint({ XAI_API_KEY: 'k', XAI_BASE_URL: base, SONAR_LIMITE_POR_JANELA: '100' }, { pergunta: 'Quais são as novidades da tecnologia Exemplo nesta semana?' });
    assert.equal(status, 200);
    assert.deepEqual(eventos.map((e) => e.estado), ['RECEBIDO', 'INVESTIGANDO', 'CRUZANDO', 'ORGANIZANDO', 'CONCLUIDO']);
    const final = eventos.at(-1).resultado;
    assert.equal(final.fontes.length, 4);
    assert.ok(!JSON.stringify(eventos).includes('texto_bruto'), 'proveniência interna não vai ao navegador');
  } finally {
    servidor.close();
  }
});

test('endpoint recusa entrada inválida, outra origem e informa erro da API', async () => {
  assert.equal((await chamarEndpoint({}, { pergunta: '' })).status, 400);
  assert.equal((await chamarEndpoint({}, { pergunta: 'a'.repeat(801) })).status, 400);
  assert.equal((await chamarEndpoint({}, { pergunta: 'ok ok' }, { Origin: 'https://outro-site.example' })).status, 403);
  const semChave = await chamarEndpoint({ XAI_API_KEY: '' }, { pergunta: 'uma pergunta qualquer' });
  assert.equal(semChave.status, 503);
  assert.match(semChave.eventos[0].erro, /não foi feita/);

  const { servidor, base } = await iniciarXaiSimulada(() => ({ status: 500, json: { error: 'x' } }));
  try {
    const { eventos } = await chamarEndpoint({ XAI_API_KEY: 'k', XAI_BASE_URL: base }, { pergunta: 'uma pergunta qualquer' });
    const ultimo = eventos.at(-1);
    assert.equal(ultimo.estado, 'ERRO');
    assert.match(ultimo.mensagem, /não pôde ser concluída/);
    assert.ok(!eventos.some((e) => e.estado === 'CONCLUIDO'));
  } finally {
    servidor.close();
  }
});
