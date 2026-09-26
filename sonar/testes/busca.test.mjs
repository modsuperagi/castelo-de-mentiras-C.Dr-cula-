// Testes da busca própria com fontes SIMULADAS (fetch injetado). Não validam as APIs reais.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createServer } from 'node:http';

import { buscar, escolherFontes, pontuar } from '../lib/busca/motor.js';
import { enderecoInterno, urlPublica, extrairTexto, lerPagina } from '../lib/busca/leitura.js';
import { semHtml } from '../lib/busca/fontes.js';

function resposta(corpo, { status = 200, tipo = 'application/json', headers = {} } = {}) {
  const h = new Headers({ 'content-type': tipo, ...headers });
  const texto = typeof corpo === 'string' ? corpo : JSON.stringify(corpo);
  return { ok: status >= 200 && status < 300, status, headers: h, json: async () => JSON.parse(texto), text: async () => texto };
}

const RESPOSTAS = {
  'pt.wikipedia.org': { query: { search: [{ title: 'Sonar', snippet: 'O <span>sonar</span> é uma técnica', timestamp: '2026-01-01T00:00:00Z' }] } },
  'en.wikipedia.org': { query: { search: [{ title: 'Sonar', snippet: 'Sonar is a technique', timestamp: '2026-02-01T00:00:00Z' }] } },
  'api.gdeltproject.org': { articles: [
    { title: 'Novo sonar lançado nesta semana', url: 'https://noticias.example.com/sonar', seendate: '20260925T120000Z', domain: 'noticias.example.com', language: 'Portuguese' },
    { title: 'Sonar', url: 'https://www.pt.wikipedia.org/wiki/Sonar/', seendate: '20260901T000000Z', domain: 'wikipedia.org' },
  ] },
  'export.arxiv.org': '<feed><entry><id>http://arxiv.org/abs/2609.00001v1</id><published>2026-09-20T00:00:00Z</published><title>Deep sonar\n imaging</title><summary>We study sonar.</summary></entry></feed>',
  'api.crossref.org': { message: { items: [{ title: ['Sonar review'], URL: 'https://doi.org/10.1/abc', issued: { 'date-parts': [[2025, 3]] }, type: 'journal-article' }] } },
};

function obterSimulado(pedidos = []) {
  return async (url) => {
    pedidos.push(url);
    const host = new URL(url).hostname;
    if (host === 'api.github.com') return resposta({ message: 'rate limit' }, { status: 403 });
    const corpo = RESPOSTAS[host];
    if (corpo === undefined) throw new Error(`host inesperado ${host}`);
    return resposta(corpo, { tipo: typeof corpo === 'string' ? 'application/atom+xml' : 'application/json' });
  };
}

test('escolhe fontes pela natureza da consulta', () => {
  const todas = ['wikipedia-pt', 'wikipedia-en', 'noticias', 'arxiv', 'crossref', 'hackernews', 'github'];
  assert.deepEqual(escolherFontes('o que é sonar', todas), ['wikipedia-pt', 'wikipedia-en', 'noticias']);
  assert.ok(escolherFontes('artigos científicos sobre sonar', todas).includes('arxiv'));
  assert.ok(escolherFontes('biblioteca open source de sonar no github', todas).includes('github'));
  assert.ok(escolherFontes('novidades de IA nesta semana', todas).includes('hackernews'));
  assert.ok(escolherFontes('o que é sonar', [...todas, 'web']).includes('web'));
});

test('pontua título acima de trecho e favorece recência quando a consulta é atual', () => {
  const agora = Date.parse('2026-09-26T00:00:00Z');
  const a = pontuar({ titulo: 'Sonar novo', trecho: '' }, 'sonar novo', { agora });
  const b = pontuar({ titulo: 'Outro', trecho: 'sonar novo' }, 'sonar novo', { agora });
  assert.ok(a > b);
  const recente = pontuar({ titulo: 'x', trecho: '', data: '2026-09-25T00:00:00Z' }, 'sonar', { atual: true, agora });
  const antiga = pontuar({ titulo: 'x', trecho: '', data: '2025-01-01T00:00:00Z' }, 'sonar', { atual: true, agora });
  assert.ok(recente > antiga);
});

test('busca junta fontes, tira repetidos, registra falhas e não inventa resultado', async () => {
  const pedidos = [];
  const r = await buscar('artigos científicos sobre sonar lançado nesta semana', { obter: obterSimulado(pedidos), env: {}, fontes: ['wikipedia-pt', 'wikipedia-en', 'noticias', 'arxiv', 'crossref', 'github'] });
  const porFonte = Object.fromEntries(r.fontes_consultadas.map((f) => [f.fonte, f]));
  assert.equal(porFonte.github.ok, false);
  assert.equal(porFonte.github.erro, 'HTTP 403');
  assert.equal(porFonte.arxiv.n, 1);

  const wiki = r.resultados.find((x) => x.url === 'https://pt.wikipedia.org/wiki/Sonar');
  assert.ok(wiki, 'resultado da Wikipedia presente');
  assert.deepEqual(wiki.tambem_em, ['noticias'], 'mesma URL vinda do GDELT vira repetição, não item novo');
  assert.equal(r.resultados.filter((x) => x.url.includes('wikipedia.org/wiki/Sonar') && x.url.includes('pt.')).length, 1);

  const artigo = r.resultados.find((x) => x.fonte === 'arxiv');
  assert.equal(artigo.titulo, 'Deep sonar imaging');
  assert.equal(artigo.url, 'https://arxiv.org/abs/2609.00001v1');
  assert.equal(r.resultados.find((x) => x.fonte === 'crossref').data, '2025-03');
  assert.ok(r.resultados.every((x) => x.url && x.titulo));
});

test('SearXNG próprio entra quando configurado', async () => {
  const obter = async (url) => {
    assert.match(url, /^https:\/\/busca\.exemplo\.org\/search\?format=json&q=/);
    return resposta({ results: [{ title: 'Resultado web', url: 'https://site.example.com/a', content: '<b>trecho</b>' }] });
  };
  const r = await buscar('sonar', { obter, env: { SONAR_SEARXNG_URL: 'https://busca.exemplo.org/' }, fontes: ['web'] });
  assert.equal(r.resultados[0].trecho, 'trecho');
  assert.equal(r.resultados[0].tipo, 'web');
});

test('leitura bloqueia endereços internos e esquemas estranhos', async () => {
  for (const ip of ['127.0.0.1', '10.1.2.3', '192.168.0.1', '172.20.0.1', '169.254.169.254', '::1', 'fd00::1', '::ffff:127.0.0.1', '100.64.0.1']) {
    assert.equal(enderecoInterno(ip), true, ip);
  }
  assert.equal(enderecoInterno('93.184.216.34'), false);
  const resolverPublico = async () => [{ address: '93.184.216.34' }];
  const resolverInterno = async () => [{ address: '10.0.0.5' }];
  assert.equal(await urlPublica('file:///etc/passwd', resolverPublico), null);
  assert.equal(await urlPublica('http://exemplo.com:8080/', resolverPublico), null);
  assert.equal(await urlPublica('http://user:pw@exemplo.com/', resolverPublico), null);
  assert.equal(await urlPublica('http://interno.exemplo.com/', resolverInterno), null);
  assert.equal(await urlPublica('http://169.254.169.254/latest/meta-data', resolverPublico), null);
  assert.ok(await urlPublica('https://exemplo.com/pagina', resolverPublico));
});

test('leitura extrai texto e confere cada redirecionamento', async () => {
  const html = '<html><head><title>Página &amp; teste</title><meta name="description" content="Resumo"></head><body><nav>menu</nav><script>x()</script><article><p>Texto <b>principal</b>.</p></article><footer>rodapé</footer></body></html>';
  assert.deepEqual(extrairTexto(html), { titulo: 'Página & teste', descricao: 'Resumo', texto: 'Texto principal .' });

  const resolver = async (host) => [{ address: host === 'interno.exemplo.com' ? '10.0.0.9' : '93.184.216.34' }];
  const obter = async (url) => (url.startsWith('https://exemplo.com/')
    ? resposta('', { status: 302, headers: { location: 'http://interno.exemplo.com/segredo' } })
    : resposta('segredo', { tipo: 'text/plain' }));
  const r = await lerPagina('https://exemplo.com/a', { obter, resolver });
  assert.equal(r.ok, false);
  assert.equal(r.erro, 'endereço não permitido');

  const ok = await lerPagina('https://exemplo.com/b', { obter: async () => resposta(html, { tipo: 'text/html; charset=utf-8' }), resolver });
  assert.equal(ok.ok, true);
  assert.equal(ok.texto, 'Texto principal .');
});

test('semHtml limpa marcação e entidades', () => {
  assert.equal(semHtml('<p>a &amp; b&nbsp; <i>c</i></p>'), 'a & b c');
});

test('endpoint do operador exige token e fica desligado sem configuração', async () => {
  const { default: handler } = await import('../api/buscar.js');
  const servidor = createServer(handler);
  await new Promise((r) => servidor.listen(0, r));
  const url = `http://127.0.0.1:${servidor.address().port}/api/buscar`;
  const chamar = (headers = {}) => fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json', ...headers }, body: JSON.stringify({ consulta: 'sonar' }) });
  try {
    delete process.env.SONAR_BUSCA_TOKEN;
    assert.equal((await chamar()).status, 503);
    process.env.SONAR_BUSCA_TOKEN = 'token-de-teste-123';
    assert.equal((await chamar()).status, 401);
    assert.equal((await chamar({ Authorization: 'Bearer errado' })).status, 401);
    const vazio = await fetch(url, { method: 'POST', headers: { Authorization: 'Bearer token-de-teste-123', 'Content-Type': 'application/json' }, body: '{"consulta":" "}' });
    assert.equal(vazio.status, 400);
  } finally {
    delete process.env.SONAR_BUSCA_TOKEN;
    servidor.close();
  }
});
