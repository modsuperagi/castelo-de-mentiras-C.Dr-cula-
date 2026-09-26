#!/usr/bin/env node
// Busca própria do SONAR pela linha de comando: é o jeito do operador (Grok Bot no Cursor)
// usar a ferramenta no próprio computador, sem servidor.
//
//   node buscar.js "consulta" [--fontes noticias,arxiv] [--ler 3] [--limite 5] [--sonar] [--json]
//
// Sem --json, imprime uma lista legível para colar no chat de interpretação do operador.
// Com --sonar, entrega o material pré-curado (filtro de entrada + agrupamento por tema) para o bot SONAR.

import { buscar } from './lib/busca/motor.js';
import { catalogo } from './lib/busca/fontes.js';
import { preCurar, formatarParaBot } from './lib/busca/curadoria.js';

const args = process.argv.slice(2);
const opcao = (nome) => {
  const i = args.indexOf(`--${nome}`);
  return i >= 0 ? args.splice(i, 2)[1] : undefined;
};
const querJson = args.includes('--json') && args.splice(args.indexOf('--json'), 1);
const modoSonar = args.includes('--sonar') && args.splice(args.indexOf('--sonar'), 1);
const fontes = opcao('fontes')?.split(',').map((f) => f.trim()).filter(Boolean);
const ler = Number(opcao('ler') || 0);
const limitePorFonte = Number(opcao('limite') || 5);
const consulta = args.join(' ');

if (!consulta) {
  console.error(`Uso: node buscar.js "consulta" [--fontes ${Object.keys(catalogo()).join(',')}] [--ler N] [--limite N] [--sonar] [--json]`);
  process.exit(1);
}

const r = await buscar(consulta, { fontes, ler, limitePorFonte });
if (modoSonar) {
  const pc = preCurar(r, { dominiosBloqueados: (process.env.SONAR_DOMINIOS_BLOQUEADOS || '').split(',').filter(Boolean) });
  console.log(querJson ? JSON.stringify(pc, null, 2) : formatarParaBot(pc));
} else if (querJson) {
  console.log(JSON.stringify(r, null, 2));
} else {
  console.log(`SONAR · busca própria: "${r.consulta}" (${r.ms} ms)`);
  for (const f of r.fontes_consultadas) console.log(`  fonte ${f.fonte}: ${f.ok ? `${f.n} resultados` : `falhou (${f.erro})`}`);
  console.log('');
  r.resultados.forEach((x, i) => {
    console.log(`[${i + 1}] ${x.titulo}`);
    console.log(`    ${x.url}`);
    console.log(`    ${x.fonte}${x.tambem_em.length ? ` + ${x.tambem_em.join(', ')}` : ''} | ${x.tipo}${x.data ? ` | ${x.data.slice(0, 10)}` : ''}`);
    if (x.trecho) console.log(`    ${x.trecho.slice(0, 240)}`);
    if (x.leitura?.ok) console.log(`    lido: ${x.leitura.texto.slice(0, 600)}`);
    else if (x.leitura) console.log(`    leitura falhou: ${x.leitura.erro}`);
  });
  if (!r.resultados.length) console.log('Nenhum resultado. A evidência encontrada foi nula; não conclua nada a partir desta busca.');
}
