// Leitura de página: baixa uma URL pública e extrai título, descrição e texto corrido.
// Protegida contra SSRF: só http(s), só portas padrão, nunca endereços internos,
// e cada redirecionamento é conferido de novo.

import { lookup } from 'node:dns/promises';
import { isIP } from 'node:net';
import { semHtml } from './fontes.js';

const MAX_BYTES = 1_500_000;
const MAX_REDIRECIONAMENTOS = 3;

export function enderecoInterno(ip) {
  if (isIP(ip) === 4) {
    const [a, b] = ip.split('.').map(Number);
    return a === 0 || a === 10 || a === 127 || (a === 169 && b === 254) || (a === 172 && b >= 16 && b <= 31)
      || (a === 192 && b === 168) || (a === 100 && b >= 64 && b <= 127) || a >= 224;
  }
  const v6 = ip.toLowerCase();
  if (v6.startsWith('::ffff:')) return enderecoInterno(v6.slice(7));
  return v6 === '::' || v6 === '::1' || v6.startsWith('fc') || v6.startsWith('fd') || v6.startsWith('fe80');
}

export async function urlPublica(bruta, resolver = lookup) {
  let url;
  try {
    url = new URL(bruta);
  } catch {
    return null;
  }
  if (url.protocol !== 'http:' && url.protocol !== 'https:') return null;
  if (url.port && url.port !== '80' && url.port !== '443') return null;
  if (url.username || url.password) return null;
  const host = url.hostname.replace(/^\[|\]$/g, '');
  const enderecos = isIP(host) ? [{ address: host }] : await resolver(host, { all: true }).catch(() => []);
  if (!enderecos.length || enderecos.some((e) => enderecoInterno(e.address))) return null;
  return url;
}

export function extrairTexto(html) {
  const titulo = semHtml((html.match(/<title[^>]*>([\s\S]*?)<\/title>/i) || [])[1]);
  const descricao = semHtml((html.match(/<meta[^>]+name=["']description["'][^>]*content=["']([^"']*)["']/i)
    || html.match(/<meta[^>]+property=["']og:description["'][^>]*content=["']([^"']*)["']/i) || [])[1]);
  const corpo = html
    .replace(/<(script|style|noscript|svg|nav|header|footer|form|aside)[\s\S]*?<\/\1>/gi, ' ')
    .replace(/<!--[\s\S]*?-->/g, ' ');
  const principal = (corpo.match(/<(article|main)[^>]*>([\s\S]*?)<\/\1>/i) || [])[2] || corpo;
  return { titulo, descricao, texto: semHtml(principal) };
}

export async function lerPagina(bruta, { obter = fetch, resolver = lookup, limiteMs = 8000, maxCaracteres = 4000 } = {}) {
  let atual = bruta;
  const sinal = AbortSignal.timeout(limiteMs);
  for (let salto = 0; salto <= MAX_REDIRECIONAMENTOS; salto++) {
    const url = await urlPublica(atual, resolver);
    if (!url) return { url: bruta, ok: false, erro: 'endereço não permitido' };
    const r = await obter(url.href, { redirect: 'manual', signal: sinal, headers: { 'User-Agent': 'SONAR-leitura/0.1', Accept: 'text/html,text/plain' } });
    if (r.status >= 300 && r.status < 400 && r.headers.get('location')) {
      atual = new URL(r.headers.get('location'), url).href;
      continue;
    }
    if (!r.ok) return { url: url.href, ok: false, erro: `HTTP ${r.status}` };
    const tipo = r.headers.get('content-type') || '';
    if (!/text\/html|text\/plain|application\/xhtml/i.test(tipo)) return { url: url.href, ok: false, erro: `tipo ${tipo || 'desconhecido'}` };
    const bruto = (await r.text()).slice(0, MAX_BYTES);
    const lido = /text\/plain/i.test(tipo) ? { titulo: '', descricao: '', texto: bruto.replace(/\s+/g, ' ').trim() } : extrairTexto(bruto);
    return { url: url.href, ok: true, ...lido, texto: lido.texto.slice(0, maxCaracteres) };
  }
  return { url: bruta, ok: false, erro: 'redirecionamentos demais' };
}
