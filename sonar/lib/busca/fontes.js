// Fontes da busca própria do SONAR. Cada fonte é uma API aberta e oficial, chamada
// direto do nosso código, sem modelo de IA no meio. Todas devolvem o mesmo formato:
// { titulo, url, trecho, data, fonte, tipo }.
//
// Cada função recebe (consulta, { limite, sinal, obter }), onde `obter` é o fetch
// (injetável nos testes) e `sinal` é o AbortSignal do tempo limite.

const AGENTE = 'SONAR-busca/0.1 (+ferramenta de pesquisa)';

export function semHtml(texto) {
  return String(texto || '')
    .replace(/<[^>]*>/g, ' ')
    .replace(/&quot;/g, '"').replace(/&#39;|&apos;/g, "'").replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&nbsp;/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

async function json(obter, url, sinal) {
  const r = await obter(url, { headers: { 'User-Agent': AGENTE, Accept: 'application/json' }, signal: sinal });
  if (!r.ok) throw new Error(`HTTP ${r.status}`);
  return r.json();
}

async function texto(obter, url, sinal) {
  const r = await obter(url, { headers: { 'User-Agent': AGENTE }, signal: sinal });
  if (!r.ok) throw new Error(`HTTP ${r.status}`);
  return r.text();
}

function wikipedia(idioma) {
  return async (consulta, { limite, sinal, obter }) => {
    const url = `https://${idioma}.wikipedia.org/w/api.php?action=query&list=search&format=json&srprop=snippet|timestamp&srlimit=${limite}&srsearch=${encodeURIComponent(consulta)}`;
    const dados = await json(obter, url, sinal);
    return (dados?.query?.search || []).map((p) => ({
      titulo: p.title,
      url: `https://${idioma}.wikipedia.org/wiki/${encodeURIComponent(p.title.replace(/ /g, '_'))}`,
      trecho: semHtml(p.snippet),
      data: p.timestamp || null,
      tipo: 'enciclopedia',
    }));
  };
}

async function gdelt(consulta, { limite, sinal, obter }) {
  const url = `https://api.gdeltproject.org/api/v2/doc/doc?mode=artlist&format=json&sort=datedesc&maxrecords=${limite}&query=${encodeURIComponent(consulta)}`;
  const dados = await json(obter, url, sinal);
  return (dados?.articles || []).map((a) => ({
    titulo: a.title,
    url: a.url,
    trecho: [a.domain, a.language, a.sourcecountry].filter(Boolean).join(', '),
    data: a.seendate ? a.seendate.replace(/^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z$/, '$1-$2-$3T$4:$5:$6Z') : null,
    tipo: 'noticia',
  }));
}

async function arxiv(consulta, { limite, sinal, obter }) {
  const url = `https://export.arxiv.org/api/query?sortBy=relevance&max_results=${limite}&search_query=all:${encodeURIComponent(consulta)}`;
  const xml = await texto(obter, url, sinal);
  const campo = (bloco, nome) => semHtml((bloco.match(new RegExp(`<${nome}[^>]*>([\\s\\S]*?)</${nome}>`)) || [])[1]);
  return [...xml.matchAll(/<entry>([\s\S]*?)<\/entry>/g)].map(([, e]) => ({
    titulo: campo(e, 'title'),
    url: campo(e, 'id').replace(/^http:/, 'https:'),
    trecho: campo(e, 'summary').slice(0, 400),
    data: campo(e, 'published') || null,
    tipo: 'artigo_cientifico',
  }));
}

async function crossref(consulta, { limite, sinal, obter }) {
  const url = `https://api.crossref.org/works?rows=${limite}&select=title,URL,issued,container-title,type&query=${encodeURIComponent(consulta)}`;
  const dados = await json(obter, url, sinal);
  return (dados?.message?.items || []).map((i) => {
    const partes = i.issued?.['date-parts']?.[0];
    return {
      titulo: semHtml(i.title?.[0]),
      url: i.URL,
      trecho: [i['container-title']?.[0], i.type].filter(Boolean).join(', '),
      data: partes ? partes.map((n) => String(n).padStart(2, '0')).join('-') : null,
      tipo: 'publicacao',
    };
  });
}

async function hackernews(consulta, { limite, sinal, obter }) {
  const url = `https://hn.algolia.com/api/v1/search?tags=story&hitsPerPage=${limite}&query=${encodeURIComponent(consulta)}`;
  const dados = await json(obter, url, sinal);
  return (dados?.hits || []).map((h) => ({
    titulo: h.title,
    url: h.url || `https://news.ycombinator.com/item?id=${h.objectID}`,
    trecho: `${h.points ?? 0} pontos, ${h.num_comments ?? 0} comentários no Hacker News`,
    data: h.created_at || null,
    tipo: 'discussao',
  }));
}

async function github(consulta, { limite, sinal, obter }) {
  const url = `https://api.github.com/search/repositories?per_page=${limite}&q=${encodeURIComponent(consulta)}`;
  const dados = await json(obter, url, sinal);
  return (dados?.items || []).map((r) => ({
    titulo: r.full_name,
    url: r.html_url,
    trecho: [r.description, `${r.stargazers_count} estrelas`].filter(Boolean).join(', '),
    data: r.pushed_at || r.updated_at || null,
    tipo: 'codigo',
  }));
}

// SearXNG: metabuscador de código aberto que roda num servidor nosso (SONAR_SEARXNG_URL).
function searxng(base) {
  return async (consulta, { limite, sinal, obter }) => {
    const url = `${base.replace(/\/+$/, '')}/search?format=json&q=${encodeURIComponent(consulta)}`;
    const dados = await json(obter, url, sinal);
    return (dados?.results || []).slice(0, limite).map((r) => ({
      titulo: r.title,
      url: r.url,
      trecho: semHtml(r.content),
      data: r.publishedDate || null,
      tipo: 'web',
    }));
  };
}

export function catalogo(env = process.env) {
  const fontes = {
    'wikipedia-pt': wikipedia('pt'),
    'wikipedia-en': wikipedia('en'),
    noticias: gdelt,
    arxiv,
    crossref,
    hackernews,
    github,
  };
  if (env.SONAR_SEARXNG_URL) fontes.web = searxng(env.SONAR_SEARXNG_URL);
  return fontes;
}
