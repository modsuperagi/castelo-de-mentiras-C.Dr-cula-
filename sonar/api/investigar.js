// POST /api/investigar  { "pergunta": "..." }
// Responde em NDJSON (uma linha JSON por estado), para o site acompanhar a investigação:
// RECEBIDO → INVESTIGANDO → CRUZANDO → ORGANIZANDO → CONCLUIDO | INCOMPLETO, ou ERRO.
// Cada estado só é enviado quando a etapa correspondente começa de fato no servidor.

import { randomUUID } from 'node:crypto';
import { planejar } from '../lib/profundidade.js';
import { investigarNoGrok, configuracao, ErroInvestigacao } from '../lib/xai.js';
import { sintetizar } from '../lib/sintese.js';
import { salvar } from '../lib/armazenamento.js';
import { consumir, enderecoDe } from '../lib/limite.js';

const MIN = 3;
const MAX = 800;

const MENSAGENS = {
  configuracao: 'A pesquisa ainda não está configurada neste servidor. A investigação não foi feita.',
  tempo: 'A pesquisa passou do tempo limite. A investigação não pôde ser concluída. Tente de novo ou faça uma pergunta mais específica.',
  rede: 'O serviço de pesquisa não respondeu. A investigação não pôde ser concluída. Tente de novo em instantes.',
  cota: 'O serviço de pesquisa está no limite de uso agora. A investigação não pôde ser concluída. Tente de novo em alguns minutos.',
  api: 'O serviço de pesquisa recusou o pedido. A investigação não pôde ser concluída.',
  vazio: 'A pesquisa terminou sem conteúdo utilizável. A investigação não pôde ser concluída.',
};

function json(res, status, corpo) {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.end(JSON.stringify(corpo));
}

async function lerCorpo(req) {
  if (req.body && typeof req.body === 'object') return req.body;
  if (typeof req.body === 'string') return JSON.parse(req.body);
  let texto = '';
  for await (const pedaco of req) {
    texto += pedaco;
    if (texto.length > 10_000) throw new Error('corpo grande demais');
  }
  return texto ? JSON.parse(texto) : {};
}

function mesmaOrigem(req) {
  const origem = req.headers.origin;
  if (!origem) return true; // navegadores sempre mandam Origin em POST de outro site
  try {
    return new URL(origem).host === req.headers.host;
  } catch {
    return false;
  }
}

function log(dados) {
  // Só metadados: a pergunta, o texto e as chaves nunca vão para o log.
  console.log(JSON.stringify({ servico: 'sonar', ...dados }));
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return json(res, 405, { erro: 'Use POST.' });
  }
  if (!mesmaOrigem(req)) return json(res, 403, { erro: 'Origem não permitida.' });

  let corpo;
  try {
    corpo = await lerCorpo(req);
  } catch {
    return json(res, 400, { erro: 'Envie um JSON com o campo "pergunta".' });
  }
  const pergunta = typeof corpo?.pergunta === 'string' ? corpo.pergunta.replace(/\s+/g, ' ').trim() : '';
  if (pergunta.length < MIN) return json(res, 400, { erro: 'Escreva o que você quer investigar.' });
  if (pergunta.length > MAX) return json(res, 400, { erro: `A pergunta pode ter até ${MAX} caracteres.` });

  const config = configuracao();
  if (!config.chave) return json(res, 503, { erro: MENSAGENS.configuracao });

  const limite = consumir(enderecoDe(req));
  if (!limite.permitido) {
    res.setHeader('Retry-After', String(limite.esperarSegundos));
    return json(res, 429, { erro: `Muitas investigações seguidas. Tente de novo em ${Math.ceil(limite.esperarSegundos / 60)} min.` });
  }

  const id = randomUUID();
  const inicio = Date.now();
  res.statusCode = 200;
  res.setHeader('Content-Type', 'application/x-ndjson; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.setHeader('X-Accel-Buffering', 'no');
  const emitir = (evento) => res.write(`${JSON.stringify({ id, ...evento })}\n`);

  const plano = planejar(pergunta);
  emitir({ estado: 'RECEBIDO', nivel: plano.nivel });

  // Mantém a conexão viva durante a espera da pesquisa.
  const pulso = setInterval(() => emitir({ estado: 'INVESTIGANDO', pulso: true }), 10_000);
  try {
    emitir({ estado: 'INVESTIGANDO', ferramentas: plano.ferramentas });
    const { bruto, modelo, parametros } = await investigarNoGrok({ pergunta, plano, config });
    clearInterval(pulso);

    emitir({ estado: 'CRUZANDO' });
    const sintese = sintetizar({ pergunta, plano, bruto });
    if (!sintese) throw new ErroInvestigacao('vazio', MENSAGENS.vazio);

    emitir({ estado: 'ORGANIZANDO' });
    const { resultado, proveniencia } = sintese;
    const concluidoEm = new Date().toISOString();
    const armazenamento = await salvar({
      id,
      criado_em: new Date(inicio).toISOString(),
      concluido_em: concluidoEm,
      pergunta,
      plano,
      modelo,
      parametros,
      resultado,
      proveniencia,
    });

    log({ id, estado: resultado.estado, nivel: plano.nivel, ms: Date.now() - inicio, fontes: resultado.fontes.length, consultas: resultado.consultas.length, uso: proveniencia.uso, uso_ferramentas: proveniencia.uso_ferramentas, armazenamento });
    emitir({ estado: resultado.estado, resultado: { id, concluido_em: concluidoEm, ...resultado } });
  } catch (erro) {
    clearInterval(pulso);
    const codigo = erro instanceof ErroInvestigacao ? erro.codigo : 'interno';
    log({ id, estado: 'ERRO', codigo, ms: Date.now() - inicio, detalhe: erro.detalhe || erro.message });
    emitir({ estado: 'ERRO', codigo, mensagem: MENSAGENS[codigo] || 'A investigação não pôde ser concluída por uma falha interna.' });
  } finally {
    res.end();
  }
}
