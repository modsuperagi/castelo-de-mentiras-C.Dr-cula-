// POST /api/buscar  { "consulta": "...", "fontes"?: [...], "ler"?: 0-5, "limite"?: 1-10 }
// Busca própria do SONAR para o operador (Grok Bot, Cursor, chat de interpretação). Não é para o visitante:
// exige Authorization: Bearer SONAR_BUSCA_TOKEN. Sem token configurado, fica desligada.

import { timingSafeEqual } from 'node:crypto';
import { buscar } from '../lib/busca/motor.js';
import { consumir, enderecoDe } from '../lib/limite.js';

function json(res, status, corpo) {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.end(JSON.stringify(corpo));
}

function autorizado(req, token) {
  const recebido = String(req.headers.authorization || '').replace(/^Bearer\s+/i, '');
  const a = Buffer.from(recebido);
  const b = Buffer.from(token);
  return a.length === b.length && timingSafeEqual(a, b);
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

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return json(res, 405, { erro: 'Use POST.' });
  }
  const token = process.env.SONAR_BUSCA_TOKEN;
  if (!token) return json(res, 503, { erro: 'A busca do operador não está configurada neste servidor.' });
  if (!autorizado(req, token)) return json(res, 401, { erro: 'Token do operador ausente ou inválido.' });

  const limite = consumir(`busca:${enderecoDe(req)}`, { SONAR_LIMITE_POR_JANELA: process.env.SONAR_BUSCA_LIMITE || '60', SONAR_JANELA_MINUTOS: '10' });
  if (!limite.permitido) {
    res.setHeader('Retry-After', String(limite.esperarSegundos));
    return json(res, 429, { erro: 'Limite de buscas atingido. Tente de novo em instantes.' });
  }

  let corpo;
  try {
    corpo = await lerCorpo(req);
  } catch {
    return json(res, 400, { erro: 'Envie um JSON com o campo "consulta".' });
  }
  const consulta = typeof corpo?.consulta === 'string' ? corpo.consulta.slice(0, 300) : '';
  if (consulta.trim().length < 2) return json(res, 400, { erro: 'Informe a consulta.' });

  try {
    const resultado = await buscar(consulta, {
      fontes: Array.isArray(corpo.fontes) ? corpo.fontes.filter((f) => typeof f === 'string') : undefined,
      ler: Math.max(0, Math.min(5, Number(corpo.ler) || 0)),
      limitePorFonte: Math.max(1, Math.min(10, Number(corpo.limite) || 5)),
    });
    console.log(JSON.stringify({ servico: 'sonar-busca', fontes: resultado.fontes_consultadas.map((f) => `${f.fonte}:${f.ok ? f.n : 'erro'}`), resultados: resultado.resultados.length, ms: resultado.ms }));
    return json(res, 200, resultado);
  } catch (erro) {
    return json(res, 500, { erro: 'A busca falhou.', detalhe: erro.message });
  }
}
