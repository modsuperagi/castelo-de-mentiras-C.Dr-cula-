// Profundidade adaptativa: decide, sem gastar chamada nenhuma, quanto processamento
// a pergunta merece. Perguntas simples recebem operação leve; investigações amplas
// recebem mais rodadas de busca e o X quando faz sentido.

// \b do JavaScript não entende acentos ("últimas" falharia). Estas bordas entendem.
function termos(...alternativas) {
  return new RegExp(`(?<![\\p{L}\\p{N}])(?:${alternativas.join('|')})(?![\\p{L}\\p{N}])`, 'iu');
}

const PROFUNDA = termos(
  'a fundo', 'em profundidade', 'relatório', 'detalhad[ao]s?',
  'investiga(?:ção|r|e) (?:completa|profunda|detalhada)', 'análise (?:completa|profunda|detalhada)',
  'todas as (?:fontes|evidências)',
);
const COMPARATIVA = termos(
  'compar\\p{L}*', 'versus', 'vs\\.?', 'diferenç\\p{L}*', 'diverg\\p{L}*', 'concord\\p{L}*',
  'contradi\\p{L}*', 'confront\\p{L}*', 'prós e contras',
);
const ATUAL = termos(
  'hoje', 'agora', 'ontem', 'semana', 'recente\\p{L}*', 'últim[oa]s?', 'novidade\\p{L}*',
  'notícia\\p{L}*', 'atual\\p{L}*', 'lançamento\\p{L}*', 'anunci\\p{L}*', 'mudanças?', '20[2-3]\\d',
);
const SOCIAL = termos(
  'no x', 'do x', 'na rede x', 'x\\.com', 'twitter', 'tweets?', 'posts?', 'redes sociais',
  'repercu\\p{L}*', 'discutid\\p{L}*', 'comentad\\p{L}*', 'viral\\p{L}*', 'opinião pública',
  'o que (?:as pessoas|o público) (?:diz|dizem|acha|acham)',
);

export const PLANOS = {
  direta: { maxTurnos: 2, buscas: 'uma ou duas buscas objetivas', formato: 'resposta curta: um resumo de até três frases e poucos achados' },
  atual: { maxTurnos: 3, buscas: 'poucas buscas focadas nas fontes mais recentes e oficiais', formato: 'resumo direto e achados datados' },
  comparativa: { maxTurnos: 5, buscas: 'buscas separadas para cada lado da comparação, com fontes independentes', formato: 'achados organizados por lado e cruzamento explícito' },
  profunda: { maxTurnos: 8, buscas: 'busca ampliada: decomponha a pergunta, investigue cada parte e procure fontes que contradigam as primeiras', formato: 'investigação estruturada completa' },
};

export function planejar(pergunta) {
  const texto = String(pergunta || '');
  let nivel = 'direta';
  if (PROFUNDA.test(texto) || texto.length > 280) nivel = 'profunda';
  else if (COMPARATIVA.test(texto)) nivel = 'comparativa';
  else if (ATUAL.test(texto)) nivel = 'atual';

  const social = SOCIAL.test(texto);
  const usarX = social || nivel === 'profunda';
  const ferramentas = usarX ? ['web_search', 'x_search'] : ['web_search'];

  return { nivel, ferramentas, social, ...PLANOS[nivel] };
}
