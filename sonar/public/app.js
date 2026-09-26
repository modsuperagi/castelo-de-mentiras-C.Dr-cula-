// SONAR: envia a pergunta, acompanha os estados reais da investigação e mostra o resultado.
// Todo texto vindo do servidor entra por textContent: nada de HTML montado com dados externos.
'use strict';

const MAX = 800;
const PAUSA_ENTRE_ETAPAS = 320;

const TIPOS = {
  fato: 'Fato',
  evidencia: 'Evidência',
  afirmacao: 'Afirmação',
  interpretacao: 'Interpretação',
  hipotese: 'Hipótese',
  incerteza: 'Incerteza',
};

const $ = (id) => document.getElementById(id);
const formulario = $('formulario');
const campo = $('pergunta');
const botao = $('sondar');
const contador = $('contador');
const erroEntrada = $('erro-entrada');
const sondagem = $('sondagem');
const falha = $('falha');
const saida = $('resultado');

let emCurso = null;

function el(tag, props = {}, ...filhos) {
  const no = document.createElement(tag);
  for (const [k, v] of Object.entries(props)) {
    if (v == null || v === false) continue;
    if (k === 'class') no.className = v;
    else if (k === 'text') no.textContent = v;
    else no.setAttribute(k, v);
  }
  for (const f of filhos.flat()) if (f != null && f !== false) no.append(f);
  return no;
}

function esperar(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

/* Campo */

function ajustarAltura() {
  campo.style.height = 'auto';
  campo.style.height = `${Math.min(campo.scrollHeight, 192)}px`;
}

function atualizarContador() {
  const n = campo.value.trim().length;
  contador.textContent = n > MAX * 0.8 ? `${n} de ${MAX} caracteres` : '';
  contador.classList.toggle('excedeu', n > MAX);
}

campo.addEventListener('input', () => {
  ajustarAltura();
  atualizarContador();
  erroEntrada.hidden = true;
});
campo.addEventListener('keydown', (e) => {
  if (e.key === 'Enter' && !e.shiftKey && !e.isComposing) {
    e.preventDefault();
    formulario.requestSubmit();
  }
});

/* Etapas */

const etapas = {};
function montarSondagem() {
  sondagem.replaceChildren();
  const lista = [
    ['RECEBIDO', 'Pergunta recebida'],
    ['INVESTIGANDO', 'Pesquisando fontes'],
    ['CRUZANDO', 'Cruzando e conferindo as fontes'],
    ['ORGANIZANDO', 'Organizando o resultado'],
  ];
  for (const [chave, texto] of lista) {
    const rotulo = el('span', { text: texto });
    const tempo = el('span', { class: 'tempo' });
    const item = el('li', { class: 'etapa' }, rotulo, tempo);
    etapas[chave] = { item, rotulo, tempo };
    sondagem.append(item);
  }
  sondagem.hidden = false;
}

let ativa = null;
let relogio = null;
async function ativar(chave) {
  if (ativa === chave) return;
  if (ativa) {
    etapas[ativa].item.classList.replace('ativa', 'feita');
    etapas[ativa].tempo.textContent = '';
    await esperar(PAUSA_ENTRE_ETAPAS);
  }
  ativa = chave;
  const etapa = etapas[chave];
  etapa.item.classList.add('ativa');
  clearInterval(relogio);
  if (chave === 'INVESTIGANDO') {
    const inicio = Date.now();
    relogio = setInterval(() => {
      etapa.tempo.textContent = `${Math.round((Date.now() - inicio) / 1000)} s`;
    }, 1000);
  }
}

function encerrarEtapas(sucesso) {
  clearInterval(relogio);
  if (ativa) {
    etapas[ativa].item.classList.remove('ativa');
    etapas[ativa].item.classList.add(sucesso ? 'feita' : 'falhou');
    etapas[ativa].tempo.textContent = '';
  }
  ativa = null;
}

/* Fluxo */

function reiniciar({ limpar = true } = {}) {
  emCurso?.abort();
  emCurso = null;
  encerrarEtapas(false);
  document.body.classList.remove('investigando', 'com-resultado');
  sondagem.hidden = true;
  falha.hidden = true;
  saida.hidden = true;
  saida.replaceChildren();
  botao.disabled = false;
  campo.readOnly = false;
  if (limpar) campo.value = '';
  campo.placeholder = 'O que você quer investigar?';
  ajustarAltura();
  atualizarContador();
  campo.focus();
  window.scrollTo({ top: 0 });
}

function mostrarFalha(mensagem) {
  encerrarEtapas(false);
  document.body.classList.remove('investigando');
  document.body.classList.add('com-resultado');
  falha.replaceChildren(
    el('p', { text: mensagem }),
    el('p', {}, el('button', { class: 'secundario', type: 'button', id: 'tentar' }, 'Tentar de novo')),
  );
  falha.hidden = false;
  botao.disabled = false;
  campo.readOnly = false;
  $('tentar').addEventListener('click', () => formulario.requestSubmit());
}

async function* linhas(resposta) {
  const leitor = resposta.body.getReader();
  const decodificador = new TextDecoder();
  let resto = '';
  for (;;) {
    const { value, done } = await leitor.read();
    if (done) break;
    resto += decodificador.decode(value, { stream: true });
    let quebra;
    while ((quebra = resto.indexOf('\n')) >= 0) {
      const linha = resto.slice(0, quebra).trim();
      resto = resto.slice(quebra + 1);
      if (linha) yield JSON.parse(linha);
    }
  }
  if (resto.trim()) yield JSON.parse(resto);
}

formulario.addEventListener('submit', async (e) => {
  e.preventDefault();
  const pergunta = campo.value.replace(/\s+/g, ' ').trim();
  if (pergunta.length < 3) {
    erroEntrada.textContent = 'Escreva o que você quer investigar.';
    erroEntrada.hidden = false;
    campo.focus();
    return;
  }
  if (pergunta.length > MAX) {
    erroEntrada.textContent = `A pergunta pode ter até ${MAX} caracteres. Corte ${pergunta.length - MAX}.`;
    erroEntrada.hidden = false;
    return;
  }

  emCurso?.abort();
  const controle = new AbortController();
  emCurso = controle;
  erroEntrada.hidden = true;
  falha.hidden = true;
  saida.hidden = true;
  saida.replaceChildren();
  botao.disabled = true;
  campo.readOnly = true;
  document.body.classList.remove('com-resultado');
  document.body.classList.add('investigando');
  // O cabeçalho encolhe com transição; recalcula a altura do campo depois dela.
  setTimeout(() => { ajustarAltura(); campo.scrollTop = 0; }, 650);
  montarSondagem();

  let final = false;
  try {
    const resposta = await fetch('/api/investigar', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ pergunta }),
      signal: controle.signal,
    });
    const tipo = resposta.headers.get('Content-Type') || '';
    if (!resposta.ok || !tipo.includes('ndjson')) {
      const corpo = tipo.includes('json') ? await resposta.json().catch(() => ({})) : {};
      mostrarFalha(corpo.erro || 'O servidor não aceitou a investigação agora. Tente de novo em instantes.');
      return;
    }

    for await (const evento of linhas(resposta)) {
      if (controle.signal.aborted) return;
      if (evento.pulso) continue;
      if (evento.estado === 'INVESTIGANDO' && Array.isArray(evento.ferramentas)) {
        etapas.INVESTIGANDO.rotulo.textContent = evento.ferramentas.includes('x_search')
          ? 'Pesquisando na web e no X'
          : 'Pesquisando na web';
      }
      if (etapas[evento.estado]) {
        await ativar(evento.estado);
      } else if (evento.estado === 'CONCLUIDO' || evento.estado === 'INCOMPLETO') {
        final = true;
        await esperar(PAUSA_ENTRE_ETAPAS);
        encerrarEtapas(true);
        mostrarResultado(evento.resultado);
      } else if (evento.estado === 'ERRO') {
        final = true;
        mostrarFalha(evento.mensagem || 'A investigação não pôde ser concluída.');
      }
    }
    if (!final) mostrarFalha('A conexão caiu antes do fim. A investigação não foi concluída.');
  } catch (erro) {
    if (controle.signal.aborted) return;
    mostrarFalha('A conexão com o servidor falhou. A investigação não foi concluída. Confira sua internet e tente de novo.');
  } finally {
    if (emCurso === controle) emCurso = null;
  }
});

$('inicio').addEventListener('click', () => reiniciar());

/* Resultado */

function refs(numeros, total) {
  const validos = (numeros || []).filter((n) => Number.isInteger(n) && n >= 1 && n <= total);
  if (!validos.length) return null;
  const sup = el('sup', { class: 'ref' });
  validos.forEach((n, i) => {
    if (i) sup.append(',');
    sup.append(el('a', { href: `#fonte-${n}`, 'aria-label': `fonte ${n}` }, String(n)));
  });
  return sup;
}

function linkSeguro(url, texto) {
  try {
    const u = new URL(url);
    if (u.protocol !== 'https:' && u.protocol !== 'http:') throw new Error();
    return el('a', { href: u.href, target: '_blank', rel: 'noopener noreferrer nofollow' }, texto);
  } catch {
    return el('span', { text: texto });
  }
}

function bloco(titulo, ...conteudo) {
  return el('section', { class: 'bloco' }, el('h2', { text: titulo }), ...conteudo);
}

function mostrarResultado(r) {
  document.body.classList.remove('investigando');
  document.body.classList.add('com-resultado');
  botao.disabled = false;
  campo.readOnly = false;
  // A pergunta passa a ser o título do resultado; o campo fica livre para a próxima.
  campo.value = '';
  campo.placeholder = 'Investigar outra coisa';
  ajustarAltura();
  atualizarContador();

  const total = r.fontes.length;
  const citadas = r.fontes.filter((f) => f.citada);
  const outras = r.fontes.filter((f) => !f.citada);
  const partes = [];

  partes.push(el('h2', { class: 'pergunta', text: r.pergunta }));

  const rotuloEvidencia = { suficiente: 'suficiente', limitada: 'limitada', insuficiente: 'insuficiente' }[r.evidencia] || 'limitada';
  partes.push(el('p', { class: 'medida' },
    'Evidência ', el('strong', { class: `evidencia-${rotuloEvidencia}`, text: rotuloEvidencia }),
    `, ${citadas.length} ${citadas.length === 1 ? 'fonte citada' : 'fontes citadas'}`,
    r.consultas.length ? `, ${r.consultas.length} ${r.consultas.length === 1 ? 'consulta feita' : 'consultas feitas'}` : '',
    '.',
  ));

  if (r.estado === 'INCOMPLETO' || r.avisos.length) {
    partes.push(el('div', { class: 'incompleto', role: 'note' },
      el('h2', { text: r.estado === 'INCOMPLETO' ? 'Investigação incompleta' : 'Leia com atenção' }),
      el('ul', {}, r.avisos.map((a) => el('li', { text: a }))),
    ));
  }

  partes.push(bloco('Resultado', el('p', { class: 'resumo', text: r.resumo })));

  if (r.achados.length) {
    partes.push(bloco('O que foi encontrado', el('ul', { class: 'achados' }, r.achados.map((a) => el('li', {},
      el('span', { class: `tipo tipo-${a.tipo}`, text: TIPOS[a.tipo] || 'Interpretação' }),
      a.texto,
      refs(a.fontes, total),
    )))));
  }

  const { convergencias, divergencias } = r.cruzamento;
  if (convergencias.length || divergencias.length) {
    const conteudo = [];
    if (convergencias.length) {
      conteudo.push(el('h3', { text: 'Onde as fontes concordam' }),
        el('ul', { class: 'convergencias' }, convergencias.map((c) => el('li', {}, c.texto, refs(c.fontes, total)))));
    }
    if (divergencias.length) {
      conteudo.push(el('h3', { text: 'Onde as fontes divergem' }), ...divergencias.map((d) => el('div', { class: 'divergencia' },
        d.tema ? el('p', { class: 'tema', text: d.tema }) : null,
        el('ul', { class: 'posicoes' }, d.posicoes.map((p) => el('li', {}, p.texto, refs(p.fontes, total)))),
      )));
    }
    partes.push(bloco('Cruzamento', ...conteudo));
  }

  if (r.pontos_de_atencao.length) {
    partes.push(bloco('Pontos de atenção', el('ul', { class: 'atencao' }, r.pontos_de_atencao.map((p) => el('li', { text: p })))));
  }

  const nomeFonte = (f) => {
    if (f.titulo) return f.titulo;
    if (f.origem === 'x') {
      const perfil = new URL(f.url).pathname.split('/').filter(Boolean)[0];
      if (perfil) return `@${perfil}`;
    }
    return f.dominio;
  };
  const itemFonte = (f) => el('li', { id: `fonte-${f.n}` },
    el('span', { class: 'n', text: String(f.n) }),
    el('span', {},
      linkSeguro(f.url, nomeFonte(f)),
      el('span', { class: 'dominio', text: f.origem === 'x' ? 'post no X' : f.dominio }),
    ),
  );
  const conteudoFontes = [];
  if (citadas.length) conteudoFontes.push(el('ol', { class: 'fontes' }, citadas.map(itemFonte)));
  else conteudoFontes.push(el('p', { text: 'Nenhuma fonte retornada pela pesquisa sustenta este resultado.' }));
  if (outras.length) {
    conteudoFontes.push(el('details', {},
      el('summary', { text: `Consultadas, mas não citadas (${outras.length})` }),
      el('ol', { class: 'fontes' }, outras.map(itemFonte)),
    ));
  }
  if (r.consultas.length) {
    conteudoFontes.push(el('details', {},
      el('summary', { text: `Consultas feitas (${r.consultas.length})` }),
      el('ul', { class: 'consultas' }, r.consultas.map((c) => el('li', { text: `${c.ferramenta === 'x_search' ? 'No X' : 'Na web'}: ${c.consulta}` }))),
    ));
  }
  partes.push(bloco('Fontes', ...conteudoFontes));

  const nova = el('button', { class: 'secundario', type: 'button' }, 'Nova investigação');
  nova.addEventListener('click', () => reiniciar());
  partes.push(el('div', { class: 'acoes' },
    nova,
    el('p', { class: 'rodape', text: 'Cada achado aponta para as fontes que o sustentam. Confira as fontes antes de decidir.' }),
  ));

  saida.replaceChildren(...partes);
  saida.hidden = false;
  sondagem.hidden = true;
  saida.querySelector('.pergunta').setAttribute('tabindex', '-1');
  saida.querySelector('.pergunta').focus({ preventScroll: true });
}

ajustarAltura();
