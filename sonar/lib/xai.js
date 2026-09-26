// Cliente da API da xAI (Responses API com ferramentas de servidor web_search e x_search).
// Roda apenas no servidor. A chave vem de XAI_API_KEY e nunca sai daqui.

import { montarInstrucoes } from './instrucoes.js';

export const MODELO_PADRAO = 'grok-4-1-fast';
const BASE_PADRAO = 'https://api.x.ai/v1';
// Parâmetros que economizam, mas que podem ser recusados por alguma versão da API.
// Se a API recusar um deles, a chamada é refeita uma única vez sem eles.
const OPCIONAIS = ['max_turns', 'store'];

export class ErroInvestigacao extends Error {
  constructor(codigo, mensagem, detalhe) {
    super(mensagem);
    this.codigo = codigo;
    this.detalhe = detalhe;
  }
}

export function configuracao(env = process.env) {
  return {
    chave: env.XAI_API_KEY || '',
    modelo: env.XAI_MODEL || MODELO_PADRAO,
    base: (env.XAI_BASE_URL || BASE_PADRAO).replace(/\/+$/, ''),
    limiteMs: Number(env.SONAR_TEMPO_LIMITE_MS) || 110_000,
  };
}

export function montarCorpo({ pergunta, plano, modelo }) {
  return {
    model: modelo,
    input: [
      { role: 'system', content: montarInstrucoes(plano) },
      { role: 'user', content: pergunta },
    ],
    tools: plano.ferramentas.map((type) => ({ type })),
    max_turns: plano.maxTurnos,
    store: false,
  };
}

async function enviar(url, chave, corpo, limiteMs) {
  const controle = new AbortController();
  const relogio = setTimeout(() => controle.abort(), limiteMs);
  try {
    return await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${chave}` },
      body: JSON.stringify(corpo),
      signal: controle.signal,
    });
  } catch (erro) {
    if (erro.name === 'AbortError') throw new ErroInvestigacao('tempo', 'A pesquisa passou do tempo limite.');
    throw new ErroInvestigacao('rede', 'O serviço de pesquisa não respondeu.', erro.message);
  } finally {
    clearTimeout(relogio);
  }
}

export async function investigarNoGrok({ pergunta, plano, config = configuracao() }) {
  if (!config.chave) throw new ErroInvestigacao('configuracao', 'A pesquisa ainda não está configurada neste servidor.');

  const url = `${config.base}/responses`;
  let corpo = montarCorpo({ pergunta, plano, modelo: config.modelo });
  let resposta = await enviar(url, config.chave, corpo, config.limiteMs);

  if (resposta.status === 400 || resposta.status === 422) {
    const texto = await resposta.text();
    const recusados = OPCIONAIS.filter((p) => texto.includes(p));
    if (!recusados.length) throw new ErroInvestigacao('api', 'O serviço de pesquisa recusou o pedido.', `HTTP ${resposta.status}: ${texto.slice(0, 300)}`);
    corpo = { ...corpo };
    for (const p of recusados) delete corpo[p];
    resposta = await enviar(url, config.chave, corpo, config.limiteMs);
  }

  if (!resposta.ok) {
    const texto = await resposta.text().catch(() => '');
    const codigo = resposta.status === 429 ? 'cota' : 'api';
    throw new ErroInvestigacao(codigo, 'O serviço de pesquisa recusou o pedido.', `HTTP ${resposta.status}: ${texto.slice(0, 300)}`);
  }

  try {
    return { bruto: await resposta.json(), modelo: config.modelo, parametros: Object.keys(corpo) };
  } catch {
    throw new ErroInvestigacao('api', 'O serviço de pesquisa devolveu uma resposta ilegível.');
  }
}
