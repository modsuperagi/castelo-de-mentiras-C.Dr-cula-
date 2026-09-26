// Pré-curadoria do SONAR sobre o resultado da busca própria.
// Faz só o que o código consegue fazer sem julgar:
//   camada 1 (filtro de entrada): descarta, com motivo, o que não tem origem rastreável ou parece isca de clique;
//   camada 3 (curadoria contextual): agrupa por tema e conta domínios independentes.
// Impacto, disputa e desmentido exigem julgamento: ficam para quem interpreta (o bot).

const ISCA = /(você não vai acreditar|chocante|inacreditável|urgente!|clique aqui|veja o que aconteceu|you won'?t believe|shocking|this one trick|!!+)/i;
// Sufixos de dois níveis comuns, para contar "exemplo.com.br" e "noticias.exemplo.com.br" como um só domínio.
const SEGUNDO_NIVEL = new Set(['com.br', 'gov.br', 'org.br', 'edu.br', 'net.br', 'co.uk', 'ac.uk', 'gov.uk', 'com.au', 'co.jp', 'com.pt']);

export function dominioRaiz(url) {
  try {
    const partes = new URL(url).hostname.replace(/^www\./, '').toLowerCase().split('.');
    const ultimos2 = partes.slice(-2).join('.');
    return SEGUNDO_NIVEL.has(ultimos2) ? partes.slice(-3).join('.') : ultimos2;
  } catch {
    return null;
  }
}

function tituloEmCaixaAlta(titulo) {
  const letras = titulo.replace(/[^\p{L}]/gu, '');
  return letras.length >= 12 && letras === letras.toUpperCase();
}

export function filtrar(resultados, { dominiosBloqueados = [] } = {}) {
  const bloqueados = new Set(dominiosBloqueados.map((d) => d.toLowerCase()));
  const aprovados = [];
  const rejeitados = [];
  for (const r of resultados) {
    const dominio = dominioRaiz(r.url);
    const host = dominio && new URL(r.url).hostname.replace(/^www\./, '').toLowerCase();
    let motivo = null;
    if (!dominio) motivo = 'sem origem rastreável (URL inválida)';
    else if (bloqueados.has(host) || bloqueados.has(dominio)) motivo = `domínio marcado como não confiável (${bloqueados.has(host) ? host : dominio})`;
    else if (ISCA.test(r.titulo) || tituloEmCaixaAlta(r.titulo)) motivo = 'título com padrão de isca de clique';
    if (motivo) rejeitados.push({ titulo: r.titulo, url: r.url, motivo });
    else aprovados.push({ ...r, dominio });
  }
  return { aprovados, rejeitados };
}

const VAZIAS = new Set('para pela pelo com sem que uma uns umas por dos das nos nas the and for with from this that are was sobre entre como mais novo nova'.split(' '));
function palavrasChave(titulo) {
  return new Set(String(titulo).toLowerCase().normalize('NFD').replace(/\p{M}/gu, '')
    .split(/[^\p{L}\p{N}]+/u).filter((p) => p.length > 3 && !VAZIAS.has(p)));
}

// Agrupamento guloso por palavras significativas em comum no título (Jaccard >= limiar).
export function agrupar(itens, { limiar = 0.34 } = {}) {
  const grupos = [];
  for (const item of itens) {
    const chave = palavrasChave(item.titulo);
    let melhor = null;
    let melhorNota = 0;
    for (const g of grupos) {
      const comum = [...chave].filter((p) => g.chave.has(p)).length;
      const uniao = new Set([...chave, ...g.chave]).size || 1;
      const nota = comum / uniao;
      if (nota > melhorNota) { melhor = g; melhorNota = nota; }
    }
    if (melhor && melhorNota >= limiar) {
      melhor.itens.push(item);
      for (const p of chave) melhor.chave.add(p);
    } else {
      grupos.push({ chave: new Set(chave), itens: [item] });
    }
  }
  return grupos.map((g) => {
    const dominios = [...new Set(g.itens.map((i) => i.dominio))];
    return {
      tema: g.itens[0].titulo,
      dominios_independentes: dominios.length,
      etiqueta_previa: dominios.length >= 2 ? 'multiplas_fontes_independentes' : 'fonte_unica',
      itens: g.itens,
    };
  }).sort((a, b) => b.dominios_independentes - a.dominios_independentes || b.itens.length - a.itens.length);
}

export function preCurar(busca, opcoes = {}) {
  const { aprovados, rejeitados } = filtrar(busca.resultados, opcoes);
  return {
    consulta: busca.consulta,
    gerado_em: busca.gerado_em,
    fontes_consultadas: busca.fontes_consultadas,
    grupos: agrupar(aprovados, opcoes),
    rejeitados,
  };
}

// Texto para colar no bot: material pré-curado, sem conclusões.
export function formatarParaBot(pc) {
  const linhas = [`MATERIAL SONAR PRÉ-CURADO · consulta: "${pc.consulta}" · ${pc.gerado_em}`];
  linhas.push(`Fontes consultadas: ${pc.fontes_consultadas.map((f) => `${f.fonte}=${f.ok ? f.n : `falhou (${f.erro})`}`).join('; ')}`);
  if (!pc.grupos.length) linhas.push('Nenhum material aprovado no filtro. Evidência nula: não conclua nada a partir desta busca.');
  pc.grupos.forEach((g, i) => {
    linhas.push('', `TEMA ${i + 1}: ${g.tema}`, `  domínios independentes: ${g.dominios_independentes} (${g.etiqueta_previa})`);
    for (const it of g.itens) {
      linhas.push(`  - ${it.titulo}`, `    ${it.url}`, `    ${it.fonte} | ${it.tipo}${it.data ? ` | ${String(it.data).slice(0, 10)}` : ' | sem data'}${it.trecho ? ` | ${it.trecho.slice(0, 200)}` : ''}`);
      if (it.leitura?.ok) linhas.push(`    lido: ${it.leitura.texto.slice(0, 500)}`);
    }
  });
  if (pc.rejeitados.length) {
    linhas.push('', 'REJEITADOS NO FILTRO (com motivo):');
    for (const r of pc.rejeitados) linhas.push(`  - ${r.titulo} | ${r.url} | ${r.motivo}`);
  }
  linhas.push('', 'Próximo passo do bot: aplicar as 3 validações (propósito, evidência, impacto), etiquetar ✅ ⚠️ ❌ e responder no formato SONAR.');
  return linhas.join('\n');
}
