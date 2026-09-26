// Motor da busca própria do SONAR: escolhe as fontes pela natureza da consulta,
// consulta todas em paralelo com tempo limite, junta, tira repetidos, ordena
// e, se pedido, lê as páginas mais relevantes. Nenhum modelo de IA participa:
// o resultado é material bruto com origem, para o operador interpretar.

import { catalogo } from './fontes.js';
import { lerPagina } from './leitura.js';

function termos(...alternativas) {
  return new RegExp(`(?<![\\p{L}\\p{N}])(?:${alternativas.join('|')})(?![\\p{L}\\p{N}])`, 'iu');
}
const ACADEMICA = termos('artigo\\p{L}*', 'paper\\p{L}*', 'estudo\\p{L}*', 'pesquisa científica', 'científic\\p{L}*', 'revis\\p{L}* sistemática', 'doi', 'arxiv', 'teorema', 'prova', 'hipótese');
const CODIGO = termos('código', 'repositório\\p{L}*', 'github', 'biblioteca', 'framework', 'api', 'sdk', 'open source', 'código aberto', 'linguagem de programação');
const ATUAL = termos('hoje', 'agora', 'ontem', 'semana', 'recente\\p{L}*', 'últim[oa]s?', 'novidade\\p{L}*', 'notícia\\p{L}*', 'lançamento\\p{L}*', 'anunci\\p{L}*', '20[2-3]\\d');
const TECNOLOGIA = termos('ia', 'inteligência artificial', 'modelo\\p{L}*', 'software', 'startup\\p{L}*', 'tecnologia', 'agente\\p{L}*', 'llm\\p{L}*', 'chip\\p{L}*');

export function escolherFontes(consulta, disponiveis) {
  const q = String(consulta || '');
  const escolha = new Set(['wikipedia-pt', 'wikipedia-en']);
  if (disponiveis.includes('web')) escolha.add('web');
  if (ATUAL.test(q)) escolha.add('noticias');
  if (ACADEMICA.test(q)) { escolha.add('arxiv'); escolha.add('crossref'); }
  if (CODIGO.test(q)) escolha.add('github');
  if (TECNOLOGIA.test(q) && (ATUAL.test(q) || CODIGO.test(q))) escolha.add('hackernews');
  if (escolha.size <= 2 && !disponiveis.includes('web')) escolha.add('noticias');
  return [...escolha].filter((f) => disponiveis.includes(f));
}

function chaveUrl(bruta) {
  try {
    const u = new URL(bruta);
    return `${u.hostname.replace(/^www\./, '').toLowerCase()}${u.pathname.replace(/\/+$/, '')}${u.search}`;
  } catch {
    return null;
  }
}

function palavras(texto) {
  return String(texto || '').toLowerCase().normalize('NFD').replace(/\p{M}/gu, '').split(/[^\p{L}\p{N}]+/u).filter((p) => p.length > 2);
}

export function pontuar(resultado, consulta, { atual = false, agora = Date.now() } = {}) {
  const alvo = new Set(palavras(consulta));
  if (!alvo.size) return 0;
  const titulo = palavras(resultado.titulo);
  const trecho = palavras(resultado.trecho);
  let pontos = 0;
  for (const p of alvo) {
    if (titulo.includes(p)) pontos += 3;
    if (trecho.includes(p)) pontos += 1;
  }
  pontos /= alvo.size;
  if (atual && resultado.data) {
    const dias = (agora - Date.parse(resultado.data)) / 86_400_000;
    if (dias >= 0 && dias < 30) pontos += 1.5 * (1 - dias / 30);
  }
  return Math.round(pontos * 100) / 100;
}

export async function buscar(consulta, {
  fontes,
  limitePorFonte = 5,
  tempoMs = 8000,
  ler = 0,
  env = process.env,
  obter = fetch,
  resolver,
} = {}) {
  const q = String(consulta || '').replace(/\s+/g, ' ').trim();
  if (q.length < 2) throw new Error('consulta vazia');
  const todas = catalogo(env);
  const nomes = Object.keys(todas);
  const escolhidas = (fontes?.length ? fontes : escolherFontes(q, nomes)).filter((f) => nomes.includes(f));

  const inicio = Date.now();
  const relatorio = await Promise.all(escolhidas.map(async (fonte) => {
    const t0 = Date.now();
    try {
      const itens = await todas[fonte](q, { limite: limitePorFonte, sinal: AbortSignal.timeout(tempoMs), obter });
      return { fonte, ok: true, n: itens.length, ms: Date.now() - t0, itens };
    } catch (erro) {
      return { fonte, ok: false, n: 0, ms: Date.now() - t0, erro: erro.name === 'TimeoutError' ? 'tempo esgotado' : erro.message, itens: [] };
    }
  }));

  const atual = ATUAL.test(q);
  const vistos = new Map();
  for (const { fonte, itens } of relatorio) {
    for (const item of itens) {
      const k = item.url && chaveUrl(item.url);
      if (!k || !item.titulo) continue;
      if (vistos.has(k)) { vistos.get(k).tambem_em.push(fonte); continue; }
      vistos.set(k, { ...item, fonte, tambem_em: [], pontos: pontuar(item, q, { atual }) });
    }
  }
  const resultados = [...vistos.values()].sort((a, b) => b.pontos - a.pontos || String(b.data).localeCompare(String(a.data)));

  if (ler > 0) {
    const alvos = resultados.slice(0, Math.min(ler, 5));
    const lidas = await Promise.all(alvos.map((r) => lerPagina(r.url, { obter, ...(resolver ? { resolver } : {}) }).catch((e) => ({ ok: false, erro: e.message }))));
    alvos.forEach((r, i) => { r.leitura = lidas[i]; });
  }

  return {
    consulta: q,
    gerado_em: new Date().toISOString(),
    ms: Date.now() - inicio,
    fontes_consultadas: relatorio.map(({ itens, ...resto }) => resto),
    resultados,
  };
}
