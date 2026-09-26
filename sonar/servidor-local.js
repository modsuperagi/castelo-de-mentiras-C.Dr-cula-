// Servidor de desenvolvimento: serve public/ e as funções de api/ como o Vercel faria.
// Uso: XAI_API_KEY=... node servidor-local.js   (ou crie sonar/.env.local, que o git ignora)

import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { existsSync, readFileSync } from 'node:fs';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const raiz = fileURLToPath(new URL('.', import.meta.url));
const publico = join(raiz, 'public');

const arquivoEnv = join(raiz, '.env.local');
if (existsSync(arquivoEnv)) {
  for (const linha of readFileSync(arquivoEnv, 'utf8').split('\n')) {
    const m = linha.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*?)\s*$/);
    if (m && !(m[1] in process.env)) process.env[m[1]] = m[2].replace(/^['"]|['"]$/g, '');
  }
}

const TIPOS = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.svg': 'image/svg+xml', '.txt': 'text/plain; charset=utf-8' };
const rotas = {
  '/api/investigar': () => import('./api/investigar.js'),
  '/api/saude': () => import('./api/saude.js'),
};

const servidor = createServer(async (req, res) => {
  const caminho = new URL(req.url, 'http://local').pathname;
  if (rotas[caminho]) {
    const { default: handler } = await rotas[caminho]();
    return handler(req, res);
  }
  const relativo = normalize(caminho === '/' ? '/index.html' : caminho).replace(/^(\.\.[/\\])+/, '');
  try {
    const conteudo = await readFile(join(publico, relativo));
    res.setHeader('Content-Type', TIPOS[extname(relativo)] || 'application/octet-stream');
    res.end(conteudo);
  } catch {
    res.statusCode = 404;
    res.end('Não encontrado');
  }
});

const porta = Number(process.env.PORT) || 3000;
servidor.listen(porta, () => {
  console.log(`SONAR local em http://localhost:${porta} (pesquisa ${process.env.XAI_API_KEY ? 'configurada' : 'SEM chave: defina XAI_API_KEY'})`);
});
