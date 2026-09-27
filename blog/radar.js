// Radar P0: lê o texto aqui no navegador (nada é enviado) e marca onde olhar antes de confiar numa resposta de IA.
// Ele aponta onde olhar; não dá veredito. Quem leva cada ponto até a fonte é a checagem (o laudo) ou a investigação.
// Liga sozinho em <textarea data-radar="completo|curto" data-radar-alvo="id-do-painel"> e em [data-radar-estatico].
// Se o índice de investigações não carregar, o radar segue igual, só sem o caso parecido.
(function () {
  'use strict';

  const MESES = 'janeiro|fevereiro|março|marco|abril|maio|junho|julho|agosto|setembro|outubro|novembro|dezembro';
  const antes = '(^|[^\\p{L}\\p{N}_])';
  const depois = '(?=$|[^\\p{L}\\p{N}_])';
  const palavras = (lista) => new RegExp(`${antes}(${lista})${depois}`, 'giu');

  // Cada padrão: grupo 1 é a borda (pode ser vazia), grupo 2 é o trecho marcado.
  // A ordem dos tipos decide quem fica quando dois sinais caem no mesmo trecho.
  const PADROES = [
    ['link', /()((?:https?:\/\/|www\.)[^\s)>\]"']+)/giu],
    ['referencia', /()(et al\.?)/giu],
    ['referencia', /()((?:doi:?\s*)?10\.\d{4,9}\/[^\s)>\]"']+)/giu],
    ['referencia', /()(\([\p{Lu}][\p{L}'-]+(?:\s(?:et al\.?|e|&)(?:\s[\p{Lu}][\p{L}'-]+)?)?,?\s(?:19|20)\d{2}[a-z]?(?:,\s?p\.\s?\d+)?\))/gu],
    ['referencia', /(^|[^\p{L}])([\p{Lu}]{3,}(?:\s[\p{Lu}]{2,})*,\s[\p{Lu}][\p{Ll}]*\.?(?:\s[\p{Lu}][\p{Ll}]*\.?)*\.)(?=\s)/gu],
    ['referencia', /()((?:Revista|Journal of|Cadernos de|Anais do|Anais da)\s[\p{Lu}][\p{L}]+)/gu],
    ['norma', new RegExp(`${antes}((?:lei complementar|decreto-lei|lei|decreto|medida provisória|mp|emenda constitucional|resolução|portaria|instrução normativa|súmula vinculante|súmula|acórdão|tema|enunciado|parecer)\\s*(?:n[º°o.]*\\s*)?\\d+(?:\\.\\d+)*(?:\\/\\d{2,4})?)`, 'giu')],
    ['norma', new RegExp(`${antes}((?:arts?\\.?|artigos?)\\s*\\d+[º°]?(?:-[A-Z])?(?:\\s*(?:,|e|a|ao)\\s*\\d+[º°]?(?:-[A-Z])?)*)`, 'giu')],
    ['norma', new RegExp(`${antes}(§\\s*\\d+[º°]?|parágrafo único|inciso\\s+[IVXLC]+)${depois}`, 'gu')],
    ['norma', new RegExp(`${antes}(STF|STJ|TST|TSE|TCU|STM|CNJ|TJ[A-Z]{2}|TRF-?\\d|TRT-?\\d{1,2}|TCE-?[A-Z]{2}|Constituição Federal|Constituição|CF\\/88|CLT|CDC|ECA|CTN|CPC|CPP|Código Civil|Código Penal|Código de Processo Civil|Código de Defesa do Consumidor)${depois}`, 'gu')],
    ['norma', new RegExp(`${antes}((?:REsp|RE|HC|ADI|ADC|ADO|ADPF|AgRg|AgInt|AREsp|RMS|MS|Rcl|ARE)\\s*(?:n[º°o.]*\\s*)?\\d+(?:\\.\\d+)*(?:\\/[A-Z]{2})?)`, 'gu')],
    ['tempo', new RegExp(`${antes}(\\d{1,2}[º°]?\\s+de\\s+(?:${MESES})(?:\\s+de\\s+\\d{4})?|(?:${MESES})\\s+de\\s+\\d{4}|\\d{1,2}\\/\\d{1,2}\\/\\d{2,4})`, 'giu')],
    ['tempo', /(^|[^\p{L}\p{N}_/.])((?:19|20)\d{2})(?![\p{N}])/gu],
    ['tempo', palavras('atualmente|hoje em dia|hoje|recentemente|recentes?|em vigor|vigentes?|vigência|até hoje|até o momento|mais recentes?|nos últimos anos|neste ano|este ano|ano passado|desde então')],
    ['vaga', palavras('estudos? (?:mostram|mostra|comprovam|comprova|indicam|indica|apontam|aponta|revelam|revela|sugerem)|pesquisas? (?:mostram|mostra|comprovam|comprova|indicam|indica|apontam|aponta|revelam)|segundo (?:especialistas|estudos|pesquisas|dados|pesquisadores|cientistas)|especialistas (?:dizem|afirmam|recomendam|apontam|concordam)|de acordo com (?:especialistas|estudos|pesquisas|dados)|sabe-se que|é sabido que|é consenso|é fato que|está provado|cientificamente|a ciência (?:diz|mostra|comprova)|dados (?:mostram|indicam|apontam)|diversos (?:estudos|autores|especialistas)|muitos (?:estudos|autores|especialistas)')],
    ['absoluto', palavras('sempre|nunca|jamais|todos|todas|todo|toda|nenhum|nenhuma|ninguém|nada|totalmente|completamente|inteiramente|absolutamente|integralmente|comprovad[oa]s?|comprovadamente|garantid[oa]s?|garante|definitivamente|certamente|sem dúvida(?: alguma)?|sem exceção|obrigatoriamente|únic[oa]s?|qualquer|a maioria|a grande maioria|automaticamente|indiscutivelmente')],
    ['numero', new RegExp(`${antes}(\\d+(?:[.,]\\d+)?\\s?%|R\\$\\s?\\d+(?:[.,]\\d+)*(?:\\s(?:mil|milhões|milhão|bilhões|bilhão))?|\\d+(?:[.,]\\d+)?\\s(?:mil|milhões|milhão|bilhões|bilhão|trilhões|trilhão)|\\d+(?:[.,]\\d+)?\\s?vezes|\\d+\\sem cada\\s\\d+|\\d{1,3}(?:\\.\\d{3})+(?:,\\d+)?|\\d+,\\d+)`, 'giu')]
  ];
  const PRIORIDADE = ['link', 'referencia', 'norma', 'tempo', 'vaga', 'absoluto', 'numero'];

  const ROTULO = {
    norma: ['norma citada', 'normas citadas'],
    tempo: ['marca de tempo', 'marcas de tempo'],
    numero: ['número', 'números'],
    vaga: ['fonte vaga', 'fontes vagas'],
    absoluto: ['palavra absoluta', 'palavras absolutas'],
    link: ['link', 'links'],
    referencia: ['referência', 'referências']
  };

  // As 7 verificações do P0 (guia gratuito). Três delas só você responde: o radar diz isso em vez de fingir.
  const CHECK_DO_TIPO = { tempo: 'identidade', norma: 'autoridade', numero: 'evidencia', vaga: 'evidencia', absoluto: 'escopo', link: 'rastreabilidade', referencia: 'rastreabilidade' };

  const EXEMPLO = 'Pergunta: A Lei 8.666 ainda vale para alguma coisa?\n\n' +
    'Resposta da IA: Não. A Lei 14.133/2021 revogou totalmente a Lei 8.666/1993 em 1º de abril de 2023. ' +
    'Desde então, nenhum contrato pode seguir a lei antiga, e todos os processos passaram automaticamente para a nova lei. ' +
    'Estudos mostram que a mudança reduziu em 30% o tempo das licitações.';

  const plural = (n, par) => `${n} ${n === 1 ? par[0] : par[1]}`;
  const normalizar = (s) => String(s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');

  function ler(texto) {
    const achados = [];
    for (const [tipo, re] of PADROES) {
      re.lastIndex = 0;
      let m;
      while ((m = re.exec(texto))) {
        const ini = m.index + m[1].length;
        // Link e DOI não levam a pontuação que fecha a frase.
        const trecho = /^(?:https?:|www\.|doi|10\.)/i.test(m[2]) ? m[2].replace(/[.,;:!?]+$/, '') : m[2];
        const fim = ini + trecho.length;
        if (fim > ini) achados.push({ tipo, ini, fim, trecho });
        if (re.lastIndex === m.index) re.lastIndex++;
      }
    }
    achados.sort((a, b) => PRIORIDADE.indexOf(a.tipo) - PRIORIDADE.indexOf(b.tipo) || a.ini - b.ini);
    const aceitos = [];
    for (const a of achados) {
      if (!aceitos.some((b) => a.ini < b.fim && b.ini < a.fim)) aceitos.push(a);
    }
    aceitos.sort((a, b) => a.ini - b.ini);
    const conta = {};
    for (const a of aceitos) conta[a.tipo] = (conta[a.tipo] || 0) + 1;
    return { marcas: aceitos, conta, total: aceitos.length, semFonte: !conta.link && !conta.referencia };
  }

  // Índice das investigações já feitas (mesmo arquivo que gera as páginas). Carrega uma vez, quando precisa.
  let casos = null;
  function carregarCasos() {
    if (!casos) {
      casos = fetch('/blog/investigacoes/casos.json', { credentials: 'omit' })
        .then((r) => (r.ok ? r.json() : { casos: [] }))
        .then((d) => (Array.isArray(d.casos) ? d.casos : []))
        .catch(() => []);
    }
    return casos;
  }
  async function casoParecido(texto) {
    const alvo = ` ${normalizar(texto).replace(/[^a-z0-9./]+/g, ' ')} `;
    let melhor = null;
    let pontos = 0;
    for (const c of await carregarCasos()) {
      const n = (c.palavras || []).filter((p) => alvo.includes(` ${normalizar(p)} `) || alvo.includes(` ${normalizar(p)}/`)).length;
      if (n > pontos) { melhor = c; pontos = n; }
    }
    return melhor;
  }

  function el(tag, classe, texto) {
    const e = document.createElement(tag);
    if (classe) e.className = classe;
    if (texto != null) e.textContent = texto;
    return e;
  }

  function marcado(texto, marcas) {
    const frag = document.createDocumentFragment();
    let pos = 0;
    for (const m of marcas) {
      if (m.ini > pos) frag.appendChild(document.createTextNode(texto.slice(pos, m.ini)));
      const mk = el('mark', `r-${m.tipo}`, texto.slice(m.ini, m.fim));
      mk.dataset.check = CHECK_DO_TIPO[m.tipo];
      mk.title = ROTULO[m.tipo][0];
      frag.appendChild(mk);
      pos = m.fim;
    }
    if (pos < texto.length) frag.appendChild(document.createTextNode(texto.slice(pos)));
    return frag;
  }

  function lista(marcas, tipo) {
    const vistos = [];
    for (const m of marcas) {
      const t = m.trecho.toLowerCase();
      if (m.tipo === tipo && !vistos.includes(t)) vistos.push(t);
    }
    return vistos.slice(0, 4).map((t) => `"${t}"`).join(', ');
  }

  // Estado de cada verificação: marcado (há pontos para conferir), alerta (a ausência já é um sinal) ou voce (só você responde).
  function verificacoes(r, texto, caso) {
    const c = r.conta;
    const n = (...tipos) => tipos.reduce((s, t) => s + (c[t] || 0), 0);
    const longo = texto.trim().length >= 80;
    const evid = [];
    if (c.numero) evid.push(`${plural(c.numero, ROTULO.numero)}: de onde veio cada um?`);
    if (c.vaga) evid.push(`${plural(c.vaga, ROTULO.vaga)} (${lista(r.marcas, 'vaga')}): qual estudo, de quem, onde?`);
    return [
      { id: 'identidade', nome: 'Identidade', n: n('tempo'),
        texto: c.tempo ? `${plural(c.tempo, ROTULO.tempo)}. Uma IA sem busca não sabe o que mudou depois do treino: pergunte a data da resposta e se ela pesquisou.`
          : 'Qual ferramenta respondeu, em que data e se ela tinha busca. Só você sabe.', estado: c.tempo ? 'marcado' : 'voce' },
      { id: 'autoridade', nome: 'Autoridade', n: n('norma'),
        texto: c.norma ? `${plural(c.norma, ROTULO.norma)}. Quem pode afirmar isso é o texto publicado: abra cada uma na fonte oficial e veja se ainda vale.`
          : 'Nenhuma norma ou decisão citada. Em saúde, direito ou dinheiro, a decisão pede uma fonte com autoridade.', estado: c.norma ? 'marcado' : 'voce' },
      { id: 'proposito', nome: 'Propósito', n: 0, texto: 'Releia a sua pergunta: a resposta respondeu a ela, ou a uma parecida e mais fácil?', estado: 'voce' },
      { id: 'evidencia', nome: 'Evidência', n: n('numero', 'vaga'),
        texto: evid.length ? `${evid.join(' ')} Número sem origem e estudo sem nome não contam como prova.`
          : (r.semFonte && longo ? 'A resposta não cita fonte nenhuma. Peça as fontes antes de usar.' : 'Nada marcado aqui. Mesmo assim, peça as fontes e abra os links.'),
        estado: n('numero', 'vaga') ? 'marcado' : (r.semFonte && longo ? 'alerta' : 'voce') },
      { id: 'escopo', nome: 'Escopo', n: n('absoluto'),
        texto: c.absoluto ? `${plural(c.absoluto, ROTULO.absoluto)} (${lista(r.marcas, 'absoluto')}). A conclusão cabe na evidência, ou generaliza além dela?`
          : 'Nada absoluto marcado. Veja se um caso está virando regra.', estado: c.absoluto ? 'marcado' : 'voce' },
      { id: 'rastreabilidade', nome: 'Rastreabilidade', n: n('link', 'referencia'),
        texto: n('link', 'referencia') ? `${plural(n('link', 'referencia'), ['link ou referência', 'links e referências'])}: abra cada um e confira se existe e se diz o que a IA disse.`
          : 'Nada para abrir: nem link, nem referência. Sem isso, não dá para refazer o caminho.',
        estado: n('link', 'referencia') ? 'marcado' : (longo ? 'alerta' : 'voce') },
      { id: 'duplicidade', nome: 'Duplicidade', n: caso ? 1 : 0, caso,
        texto: caso ? 'O Castelo já investigou algo parecido. Compare antes de confiar:' : 'Isso contradiz o que você já conferiu antes? Descubra qual versão está certa, não a mais conveniente.',
        estado: caso ? 'marcado' : 'voce' }
    ];
  }

  function linkCaso(caso) {
    const a = el('a', null, caso.titulo);
    a.href = caso.url;
    return a;
  }

  function avisar() {
    if (avisar.feito) return;
    avisar.feito = true;
    try { if (window.espelhoEvento) window.espelhoEvento('radar'); } catch (_) { /* segue */ }
  }

  // Modo completo: texto espelhado com as marcas, as 7 verificações clicáveis e o caminho para o laudo.
  function montarCompleto(painel) {
    painel.textContent = '';
    const resumo = el('p', 'radar-resumo');
    resumo.setAttribute('role', 'status');
    const espelho = el('div', 'radar-espelho');
    espelho.setAttribute('aria-label', 'Seu texto com os pontos marcados');
    const checks = el('ol', 'radar-checks');
    const nota = el('p', 'radar-nota', 'O radar lê o texto aqui no seu aparelho; nada é enviado. Ele aponta onde olhar. Não diz se está certo.');
    const cta = el('p', 'radar-cta');
    painel.append(resumo, espelho, checks, nota, cta);
    return { resumo, espelho, checks, cta };
  }

  async function desenharCompleto(painel, partes, texto) {
    const r = ler(texto);
    const caso = r.total ? await casoParecido(texto) : null;
    painel.hidden = texto.trim().length < 12;
    if (painel.hidden) return;
    delete painel.dataset.foco;
    const semAbrir = r.semFonte && texto.trim().length >= 80;
    partes.resumo.textContent = r.total
      ? `O radar marcou ${plural(r.total, ['ponto', 'pontos'])} para conferir${semAbrir ? ' e não achou nenhuma fonte para abrir' : ''}. Toque numa verificação para ver onde olhar.`
      : 'O radar não marcou nada. Isso não quer dizer que está certo: identidade, propósito e duplicidade só você responde.';
    partes.espelho.textContent = '';
    partes.espelho.appendChild(marcado(texto, r.marcas));
    partes.checks.textContent = '';
    for (const v of verificacoes(r, texto, caso)) {
      const li = el('li', `radar-check ${v.estado}`);
      li.dataset.check = v.id;
      const botao = el('button', null);
      botao.type = 'button';
      botao.setAttribute('aria-pressed', 'false');
      botao.append(el('span', 'radar-n', v.estado === 'marcado' ? String(v.n) : (v.estado === 'alerta' ? '0' : '?')), el('span', 'radar-nome', v.nome));
      botao.disabled = v.estado !== 'marcado' || v.id === 'duplicidade';
      botao.addEventListener('click', () => {
        const ligado = painel.dataset.foco === v.id;
        painel.querySelectorAll('.radar-check button').forEach((b) => b.setAttribute('aria-pressed', 'false'));
        if (ligado) delete painel.dataset.foco;
        else { painel.dataset.foco = v.id; botao.setAttribute('aria-pressed', 'true'); }
      });
      const p = el('p', null, v.texto);
      if (v.caso) { p.append(' '); p.appendChild(linkCaso(v.caso)); }
      li.append(botao, p);
      partes.checks.appendChild(li);
    }
    partes.cta.textContent = r.total
      ? `No laudo, o organismo leva cada um desses ${plural(r.total, ['ponto', 'pontos'])} até a fonte e diz o que confere, o que falta prova e o que mudar. Escolha abaixo como receber.`
      : 'No laudo, o organismo confere a resposta inteira na fonte, mesmo quando o radar não marca nada.';
    if (r.total) avisar();
  }

  // Modo curto: uma linha com o que o radar já vê na pergunta, e o caso parecido que o Castelo já investigou.
  async function desenharCurto(painel, texto) {
    const r = ler(texto);
    const caso = texto.trim().length >= 12 ? await casoParecido(texto) : null;
    painel.textContent = '';
    painel.hidden = !r.total && !caso;
    if (painel.hidden) return;
    if (r.total) {
      const linha = el('p', 'radar-linha');
      linha.append('Na sua pergunta, o radar já vê ');
      const tipos = PRIORIDADE.filter((t) => r.conta[t]);
      tipos.forEach((t, i) => {
        if (i) linha.append(i === tipos.length - 1 ? ' e ' : ', ');
        linha.appendChild(el('span', `radar-chip r-${t}`, plural(r.conta[t], ROTULO[t])));
      });
      linha.append('. A investigação leva cada ponto até a fonte.');
      painel.appendChild(linha);
      avisar();
    }
    if (caso) {
      const box = el('div', 'radar-caso');
      box.append(el('p', 'radar-caso-t', 'O Castelo já investigou algo parecido'), linkCaso(caso));
      box.appendChild(el('p', null, String(caso.conclusao || '').split('. ')[0] + '.'));
      painel.appendChild(box);
    }
  }

  function ligar(area) {
    const painel = document.getElementById(area.dataset.radarAlvo || '');
    if (!painel) return;
    const completo = area.dataset.radar === 'completo';
    const partes = completo ? montarCompleto(painel) : null;
    let espera = null;
    let ultimo = null;
    const rodar = () => {
      if (area.value === ultimo) return;
      ultimo = area.value;
      if (completo) desenharCompleto(painel, partes, area.value);
      else desenharCurto(painel, area.value);
    };
    area.addEventListener('input', () => { clearTimeout(espera); espera = setTimeout(rodar, 220); });
    if (area.form) area.form.addEventListener('reset', () => setTimeout(() => { ultimo = null; rodar(); }, 0));
    if (area.value.trim()) rodar();
  }

  function iniciar() {
    document.querySelectorAll('textarea[data-radar]').forEach(ligar);
    document.querySelectorAll('button[data-radar-exemplo]').forEach((b) => {
      const area = document.getElementById(b.dataset.radarExemplo);
      if (!area) return;
      // Só aparece com o campo vazio: o exemplo nunca apaga o que a pessoa escreveu.
      const mostrar = () => { b.hidden = area.value.trim().length > 0; };
      area.addEventListener('input', mostrar);
      if (area.form) area.form.addEventListener('reset', () => setTimeout(mostrar, 0));
      mostrar();
      b.addEventListener('click', () => {
        area.value = b.dataset.radarExemploTexto || EXEMPLO;
        area.dispatchEvent(new Event('input', { bubbles: true }));
        area.focus();
      });
    });
    document.querySelectorAll('[data-radar-estatico]').forEach((alvo) => {
      const texto = alvo.textContent.trim();
      alvo.textContent = '';
      alvo.appendChild(marcado(texto, ler(texto).marcas));
    });
  }

  window.EspelhoRadar = { ler };
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', iniciar);
  else iniciar();
})();
