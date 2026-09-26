// Síntese e cruzamento do lado do servidor.
// Recebe a resposta bruta da xAI e devolve o resultado do SONAR:
// - separa o texto final, as consultas feitas e as fontes que a pesquisa realmente retornou;
// - confere cada URL citada contra essas fontes e descarta o que a pesquisa não trouxe;
// - rebaixa achados sem fonte confirmada e decide se a investigação terminou de verdade.

import { TIPOS } from './instrucoes.js';

const EVIDENCIAS = ['suficiente', 'limitada', 'insuficiente'];
const DOMINIOS_X = new Set(['x.com', 'twitter.com', 'mobile.twitter.com', 'mobile.x.com']);

export function normalizarUrl(bruta) {
  if (typeof bruta !== 'string') return null;
  let url;
  try {
    url = new URL(bruta.trim().replace(/[.,;:]+$/, ''));
  } catch {
    return null;
  }
  if (url.protocol !== 'http:' && url.protocol !== 'https:') return null;
  url.hash = '';
  return url;
}

function chave(url) {
  const host = url.hostname.replace(/^www\./, '').toLowerCase();
  const caminho = url.pathname.replace(/\/+$/, '');
  return `${host}${caminho}${url.search}`;
}

// Tira as citações embutidas ([[1]](url) e [texto](url)) do texto e devolve as URLs delas.
export function extrairCitacoesEmbutidas(texto) {
  const urls = [];
  if (typeof texto !== 'string') return { texto: '', urls };
  let limpo = texto.replace(/\[\[\d+\]\]\((https?:\/\/[^\s)]+)\)/g, (_, u) => {
    urls.push(u);
    return '';
  });
  limpo = limpo.replace(/\[([^\]]+)\]\((https?:\/\/[^\s)]+)\)/g, (_, t, u) => {
    urls.push(u);
    return t;
  });
  return { texto: limpo.replace(/[ \t]{2,}/g, ' ').replace(/\s+([.,;:!?])/g, '$1').trim(), urls };
}

function* percorrer(no) {
  if (Array.isArray(no)) for (const item of no) yield* percorrer(item);
  else if (no && typeof no === 'object') {
    yield no;
    for (const valor of Object.values(no)) if (valor && typeof valor === 'object') yield* percorrer(valor);
  }
}

// Lê o que interessa da resposta da Responses API sem depender de um formato único.
export function lerResposta(bruto) {
  const textos = [];
  const anotacoes = [];
  const consultas = [];

  for (const item of Array.isArray(bruto?.output) ? bruto.output : []) {
    if (item?.type === 'message' && Array.isArray(item.content)) {
      for (const parte of item.content) {
        if (parte?.type === 'output_text' && typeof parte.text === 'string') textos.push(parte.text);
        for (const a of Array.isArray(parte?.annotations) ? parte.annotations : []) {
          if (a?.url) anotacoes.push({ url: a.url, titulo: a.title || '' });
        }
      }
    }
  }
  if (!textos.length && typeof bruto?.output_text === 'string') textos.push(bruto.output_text);

  // Consultas: chamadas de ferramenta em qualquer lugar da saída (itens *_call, tool_calls, function).
  for (const no of percorrer(bruto?.output)) {
    const nome = no.name || no.function?.name || no.type || '';
    if (!/search|browse|tool_call|function_call/i.test(nome) || no.type === 'message') continue;
    let args = no.arguments ?? no.function?.arguments ?? no.action ?? no.input ?? null;
    if (typeof args === 'string') {
      try { args = JSON.parse(args); } catch { args = { query: args }; }
    }
    const consulta = args?.query || args?.q || args?.url || no.query;
    if (typeof consulta === 'string' && consulta.trim()) {
      const ferramenta = /x_|keyword|semantic|user_search|thread/i.test(nome) ? 'x_search' : 'web_search';
      const texto = consulta.trim().slice(0, 300);
      // tool_calls aninham { function: { name, arguments } }: o mesmo pedido aparece duas vezes na travessia.
      if (!consultas.some((c) => c.ferramenta === ferramenta && c.consulta === texto)) {
        consultas.push({ ferramenta, nome, consulta: texto });
      }
    }
  }

  const citacoes = [];
  for (const c of Array.isArray(bruto?.citations) ? bruto.citations : []) {
    if (typeof c === 'string') citacoes.push({ url: c, titulo: '' });
    else if (c?.url) citacoes.push({ url: c.url, titulo: c.title || '' });
  }

  return {
    texto: textos.join('\n').trim(),
    citacoes,
    anotacoes,
    consultas,
    uso: bruto?.usage || null,
    usoFerramentas: bruto?.server_side_tool_usage || bruto?.usage?.server_side_tool_usage || null,
  };
}

export function extrairJson(texto) {
  if (typeof texto !== 'string') return null;
  const semCerca = texto.replace(/^```(?:json)?\s*/i, '').replace(/```\s*$/i, '');
  const inicio = semCerca.indexOf('{');
  const fim = semCerca.lastIndexOf('}');
  if (inicio < 0 || fim <= inicio) return null;
  try {
    const obj = JSON.parse(semCerca.slice(inicio, fim + 1));
    return obj && typeof obj === 'object' && !Array.isArray(obj) ? obj : null;
  } catch {
    return null;
  }
}

function lista(valor) {
  return Array.isArray(valor) ? valor : [];
}

export function sintetizar({ pergunta, plano, bruto }) {
  const lido = lerResposta(bruto);
  const avisos = [];

  // Fontes que a pesquisa realmente retornou: citações da resposta + anotações do texto.
  const retornadas = new Map();
  for (const c of [...lido.citacoes, ...lido.anotacoes]) {
    const url = normalizarUrl(c.url);
    if (!url) continue;
    const k = chave(url);
    const atual = retornadas.get(k);
    if (!atual) retornadas.set(k, { url: url.href, titulo: c.titulo || '' });
    else if (!atual.titulo && c.titulo) atual.titulo = c.titulo;
  }

  const citadas = []; // ordem de primeira citação
  const descartadas = new Set();
  function resolverFontes(declaradas, embutidas) {
    const numeros = [];
    for (const bruta of [...lista(declaradas), ...embutidas]) {
      const url = normalizarUrl(bruta);
      if (!url) continue;
      const k = chave(url);
      if (!retornadas.has(k)) {
        descartadas.add(url.href);
        continue;
      }
      let n = citadas.indexOf(k);
      if (n < 0) n = citadas.push(k) - 1;
      if (!numeros.includes(n + 1)) numeros.push(n + 1);
    }
    return numeros;
  }
  function limpar(texto) {
    return extrairCitacoesEmbutidas(typeof texto === 'string' ? texto : '');
  }

  const dados = extrairJson(lido.texto);
  let estruturado = true;
  let resumo = '';
  let achados = [];
  let convergencias = [];
  let divergencias = [];
  let pontos = [];
  let evidencia = 'limitada';

  if (dados) {
    const r = limpar(dados.resumo);
    resumo = r.texto;
    resolverFontes([], r.urls);

    achados = lista(dados.achados).map((a) => {
      const t = limpar(a?.texto);
      const fontes = resolverFontes(a?.fontes, t.urls);
      let tipo = TIPOS.includes(a?.tipo) ? a.tipo : 'interpretacao';
      let semFonte = false;
      if (!fontes.length && ['fato', 'evidencia', 'afirmacao'].includes(tipo)) {
        tipo = 'incerteza';
        semFonte = true;
      }
      return { texto: t.texto, tipo, fontes, semFonte };
    }).filter((a) => a.texto);

    convergencias = lista(dados.cruzamento?.convergencias).map((c) => {
      const t = limpar(typeof c === 'string' ? c : c?.texto);
      return { texto: t.texto, fontes: resolverFontes(c?.fontes, t.urls) };
    }).filter((c) => c.texto);

    divergencias = lista(dados.cruzamento?.divergencias).map((d) => ({
      tema: limpar(d?.tema).texto,
      posicoes: lista(d?.posicoes).map((p) => {
        const t = limpar(typeof p === 'string' ? p : p?.texto);
        return { texto: t.texto, fontes: resolverFontes(p?.fontes, t.urls) };
      }).filter((p) => p.texto),
    })).filter((d) => d.tema || d.posicoes.length);

    pontos = lista(dados.pontos_de_atencao).map((p) => limpar(p).texto).filter(Boolean);
    evidencia = EVIDENCIAS.includes(dados.evidencia) ? dados.evidencia : 'limitada';
  } else {
    estruturado = false;
    const r = limpar(lido.texto);
    resumo = r.texto.slice(0, 6000);
    resolverFontes([], r.urls);
  }

  if (!resumo && !achados.length) return null; // nada utilizável: quem chama trata como erro

  // Todas as fontes retornadas: as citadas primeiro, na ordem da citação; depois as só consultadas.
  const fontes = [];
  const usadas = new Set();
  for (const k of citadas) {
    fontes.push({ ...retornadas.get(k), citada: true });
    usadas.add(k);
  }
  for (const [k, f] of retornadas) if (!usadas.has(k)) fontes.push({ ...f, citada: false });
  for (const [i, f] of fontes.entries()) {
    const host = new URL(f.url).hostname.replace(/^www\./, '');
    f.n = i + 1;
    f.dominio = host;
    f.origem = DOMINIOS_X.has(host) ? 'x' : 'web';
  }

  let estado = 'CONCLUIDO';
  if (!retornadas.size) {
    estado = 'INCOMPLETO';
    evidencia = 'insuficiente';
    avisos.push('A pesquisa não retornou fontes. Trate o texto abaixo como não verificado.');
  }
  if (!estruturado) {
    estado = 'INCOMPLETO';
    avisos.push('O resultado veio sem a organização esperada. O texto aparece como foi recebido.');
  }
  if (evidencia === 'suficiente' && citadas.length < 2) evidencia = 'limitada';
  if (descartadas.size) {
    avisos.push(`${descartadas.size === 1 ? 'Uma referência citada não constava' : `${descartadas.size} referências citadas não constavam`} nas fontes retornadas pela pesquisa e ${descartadas.size === 1 ? 'foi removida' : 'foram removidas'}.`);
  }
  const semFonte = achados.filter((a) => a.semFonte).length;
  if (semFonte) {
    avisos.push(`${semFonte === 1 ? 'Um achado apresentado como fato não tinha fonte confirmada e foi marcado' : `${semFonte} achados apresentados como fato não tinham fonte confirmada e foram marcados`} como incerteza.`);
  }

  return {
    resultado: {
      pergunta,
      estado,
      nivel: plano.nivel,
      ferramentas: plano.ferramentas,
      resumo,
      achados: achados.map(({ texto, tipo, fontes: f }) => ({ texto, tipo, fontes: f })),
      cruzamento: { convergencias, divergencias },
      pontos_de_atencao: pontos,
      evidencia,
      fontes,
      consultas: lido.consultas.map(({ ferramenta, consulta }) => ({ ferramenta, consulta })),
      avisos,
    },
    proveniencia: {
      texto_bruto: lido.texto,
      consultas: lido.consultas,
      fontes_retornadas: [...retornadas.values()],
      referencias_descartadas: [...descartadas],
      uso: lido.uso,
      uso_ferramentas: lido.usoFerramentas,
    },
  };
}
