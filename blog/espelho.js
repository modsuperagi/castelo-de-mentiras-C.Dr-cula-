// Espelho editorial: sinais do público, "Quero investigar isso", ressonâncias e telemetria de comportamento.
// Tudo é opcional: se o Castelo não responder, a página continua igual. Nada aqui depende de Grok, Plasma ou SONAR.
// Regra do organismo: ressonância não é verdade. Todo sinal entra como RECEBIDO e só o organismo muda o estado.
(function () {
  const CASTELO = 'https://zolbckgqdxxovguspjdb.supabase.co/rest/v1';
  const CHAVE_PUBLICA = 'sb_publishable_BuWJQNrlYoNrIjrrFJNU5w_dJKXf7nu';
  const EMAIL_VALIDO = /^[^@\s]+@[^@\s]+\.[^@\s]{2,}$/;
  const EVENTO_DO_TIPO = {
    pergunta: 'question', opiniao: 'opinion', correcao: 'correction', evidencia: 'source_suggestion',
    investigar: 'investigation_interest', experiencia: 'contribution', ideia: 'contribution', proposta: 'contribution'
  };

  const pagina = (location.pathname.replace(/^\/+|\/+$/g, '').replace(/\.html$/, '').toLowerCase()
    .replace(/[^a-z0-9/_.-]+/g, '-') || 'inicio').slice(0, 120);

  function guardado(chave, criar) {
    try {
      let v = sessionStorage.getItem(chave);
      if (!v && criar) { v = criar(); sessionStorage.setItem(chave, v); }
      return v || '';
    } catch (_) { return criar ? criar() : ''; }
  }
  const sessao = guardado('espelho_sessao', () => Array.from(crypto.getRandomValues(new Uint8Array(10)), (b) => (b % 36).toString(36)).join(''));

  function canal() {
    try {
      const p = new URLSearchParams(location.search);
      const limpo = (s) => String(s || '').toLowerCase().replace(/[^a-z0-9_.:/-]+/g, '-').slice(0, 60);
      const fonte = limpo(p.get('utm_source'));
      const campanha = limpo(p.get('utm_campaign'));
      if (fonte) sessionStorage.setItem('espelho_utm', campanha ? `${fonte}/${campanha}` : fonte);
      const utm = sessionStorage.getItem('espelho_utm');
      return (utm ? `${utm}:${pagina}` : pagina).slice(0, 120);
    } catch (_) { return pagina; }
  }

  function enviar(caminho, corpo) {
    return fetch(`${CASTELO}/${caminho}`, {
      method: 'POST',
      headers: { apikey: CHAVE_PUBLICA, 'Content-Type': 'application/json', Prefer: 'return=minimal' },
      body: JSON.stringify(corpo),
      keepalive: true
    });
  }

  // Telemetria de comportamento: separada de evidência, sem dado pessoal. Falha em silêncio.
  function evento(nome) {
    try { enviar('espelho_eventos', { evento: nome, pagina, canal: canal(), sessao }).catch(() => {}); } catch (_) { /* segue */ }
  }
  window.espelhoEvento = evento;

  const artigo = document.querySelector('article');
  evento('page_view');
  if (artigo) {
    evento('article_open');
    let continuou = false;
    const aoRolar = () => {
      if (continuou) return;
      const r = artigo.getBoundingClientRect();
      if (r.height > 0 && (window.innerHeight - r.top) / r.height > 0.6) {
        continuou = true;
        evento('article_continue');
        window.removeEventListener('scroll', aoRolar);
      }
    };
    window.addEventListener('scroll', aoRolar, { passive: true });
  }
  document.addEventListener('espelho:conversao', () => evento('conversion'));

  function mostrar(el, texto, tipo) {
    if (!el) return;
    el.textContent = texto;
    el.classList.remove('ok', 'erro');
    if (tipo) el.classList.add(tipo);
  }

  // "Quero investigar isso": um toque, um sinal. Não vira verdade.
  document.querySelectorAll('button.investigar').forEach((botao) => {
    const retorno = botao.parentNode.querySelector('.retorno-investigar');
    botao.addEventListener('click', async () => {
      botao.disabled = true;
      try {
        const r = await enviar('espelho_sinais', { tipo: 'investigar', pagina: botao.dataset.pagina || pagina, canal: canal() });
        if (!r.ok) throw new Error(String(r.status));
        evento('investigation_interest');
        botao.textContent = '✓ Pedido de investigação registrado';
        mostrar(retorno, 'Obrigado. Quanto mais gente pede, mais cedo o tema entra na fila, mas só vira conteúdo depois de conferido.', 'ok');
      } catch (_) {
        botao.disabled = false;
        mostrar(retorno, 'Não conseguimos registrar agora. Tente de novo em instantes.', 'erro');
      }
    });
  });

  // Formulário de sinal (nos artigos) e de escrita (página Escrever).
  document.querySelectorAll('form.sinal-form').forEach((form) => {
    const retorno = form.querySelector('.retorno');
    const botao = form.querySelector('button[type=submit]');
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const d = new FormData(form);
      const sinal = {
        tipo: String(d.get('tipo') || 'pergunta'),
        pagina: form.dataset.pagina || pagina,
        texto: String(d.get('texto') || '').trim(),
        autor_nome: String(d.get('nome') || '').trim() || null,
        autor_email: String(d.get('email') || '').trim() || null,
        contato_ok: d.get('contato') === 'on',
        canal: canal()
      };
      if (sinal.texto.length < 3) return mostrar(retorno, 'Escreva pelo menos uma frase.', 'erro');
      if (sinal.texto.length > 4000) return mostrar(retorno, 'O texto passou de 4.000 caracteres. Resuma um pouco.', 'erro');
      if (sinal.autor_nome && sinal.autor_nome.length < 2) sinal.autor_nome = null;
      if (sinal.autor_email) {
        if (!EMAIL_VALIDO.test(sinal.autor_email)) return mostrar(retorno, 'Esse e-mail não parece válido.', 'erro');
        if (!sinal.contato_ok) return mostrar(retorno, 'Para receber resposta, marque a autorização de contato.', 'erro');
      } else {
        sinal.contato_ok = false;
      }
      botao.disabled = true;
      mostrar(retorno, 'Enviando…');
      try {
        const r = await enviar('espelho_sinais', sinal);
        if (!r.ok) throw new Error(String(r.status));
        evento(EVENTO_DO_TIPO[sinal.tipo] || 'contribution');
        form.reset();
        mostrar(retorno, sinal.autor_email
          ? 'Recebido. Seu texto fica como você escreveu. Quando houver resposta conferida, ela chega no seu e-mail.'
          : 'Recebido. Seu texto fica como você escreveu e entra na fila de leitura do organismo.', 'ok');
      } catch (_) {
        mostrar(retorno, 'Não conseguimos enviar agora. Seu texto continua aqui: tente de novo em instantes.', 'erro');
      } finally {
        botao.disabled = false;
      }
    });
  });

  // Compartilhar o artigo.
  document.querySelectorAll('button.compartilhar').forEach((botao) => {
    botao.addEventListener('click', async () => {
      const dados = { title: document.title, url: location.href.split('?')[0] };
      try {
        if (navigator.share) await navigator.share(dados);
        else if (navigator.clipboard) { await navigator.clipboard.writeText(dados.url); botao.textContent = 'Link copiado'; }
        evento('share');
      } catch (_) { /* a pessoa cancelou */ }
    });
  });

  // Busca no blog: filtra a lista de artigos na própria página.
  const busca = document.querySelector('input.busca');
  if (busca) {
    const itens = Array.from(document.querySelectorAll('.lista-artigos li'));
    const vazio = document.querySelector('.busca-vazia');
    let contou = false;
    busca.addEventListener('input', () => {
      const q = busca.value.trim().toLowerCase();
      let achou = 0;
      itens.forEach((li) => {
        const ok = !q || li.textContent.toLowerCase().includes(q);
        li.hidden = !ok;
        if (ok) achou++;
      });
      document.querySelectorAll('section.grupo').forEach((g) => { g.hidden = !g.querySelector('li:not([hidden])'); });
      if (vazio) vazio.hidden = achou > 0;
      if (q.length >= 3 && !contou) { contou = true; evento('search'); }
    });
  }

  // "O que está ressoando?": só agregados e contribuições que o organismo marcou como publicáveis.
  const painel = document.getElementById('ressonancias');
  if (painel) {
    const titulos = {};
    document.querySelectorAll('[data-titulo-de]').forEach((el) => { titulos[el.dataset.tituloDe] = el.textContent; });
    const nomeTipo = { pergunta: 'Pergunta', opiniao: 'Opinião', experiencia: 'Experiência', ideia: 'Ideia', evidencia: 'Evidência', correcao: 'Correção', proposta: 'Proposta', investigar: 'Quero investigar' };
    const nomeEstado = { RECEBIDO: 'recebido', OBSERVADO: 'observado', EM_INVESTIGACAO: 'em investigação', COM_EVIDENCIA: 'com evidência', CONSOLIDADO: 'consolidado', ARQUIVADO: 'arquivado' };
    const el = (tag, cls, texto) => { const n = document.createElement(tag); if (cls) n.className = cls; if (texto != null) n.textContent = texto; return n; };
    const link = (pag) => {
      const a = el('a', null, titulos[pag] || pag);
      a.href = pag === 'inicio' ? '/' : `/${pag}${pag.endsWith('blog') ? '/' : '.html'}`;
      return a;
    };
    const preencher = (id, itens, montar, vazio) => {
      const alvo = document.getElementById(id);
      if (!alvo) return;
      alvo.textContent = '';
      if (!itens || !itens.length) { alvo.appendChild(el('p', 'vazio', vazio)); return; }
      const ul = el('ul', 'ressoa');
      itens.forEach((i) => ul.appendChild(montar(i)));
      alvo.appendChild(ul);
    };
    fetch(`${CASTELO}/rpc/espelho_ressonancias`, {
      method: 'POST',
      headers: { apikey: CHAVE_PUBLICA, 'Content-Type': 'application/json' },
      body: '{}'
    }).then((r) => (r.ok ? r.json() : Promise.reject(r.status))).then((d) => {
      preencher('ressoa-alta', d.em_alta, (i) => {
        const li = el('li');
        li.appendChild(link(i.pagina));
        const partes = [`${i.leitores_7d} leitores`];
        if (i.leram_ate_o_fim) partes.push(`${i.leram_ate_o_fim} leram até o fim`);
        if (i.leitores_7d > i.leitores_7d_antes) partes.push('↑ subindo');
        li.appendChild(el('span', 'detalhe', partes.join(' · ')));
        return li;
      }, 'Ainda não há leitura suficiente nesta semana para mostrar tendência.');
      preencher('ressoa-temas', d.por_pagina, (i) => {
        const li = el('li');
        li.appendChild(link(i.pagina));
        const partes = [`${i.sinais} ${i.sinais === 1 ? 'sinal' : 'sinais'}`];
        if (i.querem_investigar) partes.push(`${i.querem_investigar} querem investigar`);
        if (i.perguntas) partes.push(`${i.perguntas} ${i.perguntas === 1 ? 'pergunta' : 'perguntas'}`);
        if (i.correcoes_e_evidencias) partes.push(`${i.correcoes_e_evidencias} correções ou fontes`);
        li.appendChild(el('span', 'detalhe', partes.join(' · ')));
        return li;
      }, 'Ainda não há sinais nos últimos 30 dias. Leia um artigo e mande a sua pergunta.');
      preencher('ressoa-investigacoes', d.investigacoes, (i) => {
        const li = el('li');
        li.appendChild(el('span', `estado estado-${String(i.estado).toLowerCase()}`, nomeEstado[i.estado] || i.estado));
        li.appendChild(el('p', null, i.resumo || 'Investigação aberta.'));
        li.appendChild(link(i.pagina));
        (i.fontes || []).forEach((f) => {
          if (f && typeof f.url === 'string' && /^https?:\/\//.test(f.url)) {
            const a = el('a', 'fonte', f.titulo || f.url);
            a.href = f.url; a.rel = 'noopener nofollow'; a.target = '_blank';
            li.appendChild(a);
          }
        });
        return li;
      }, 'Nenhuma investigação aberta no momento.');
      preencher('ressoa-comunidade', d.comunidade, (i) => {
        const li = el('li');
        li.appendChild(el('span', 'estado', `${nomeTipo[i.tipo] || i.tipo} · ${nomeEstado[i.estado] || i.estado}`));
        li.appendChild(el('p', null, i.texto || ''));
        const autor = el('span', 'detalhe', `${i.autor} · sobre `);
        autor.appendChild(link(i.pagina));
        li.appendChild(autor);
        return li;
      }, 'As contribuições aparecem aqui depois da leitura do organismo. A sua pode ser a primeira.');
    }).catch(() => {
      ['ressoa-alta', 'ressoa-temas', 'ressoa-investigacoes', 'ressoa-comunidade'].forEach((id) => {
        const alvo = document.getElementById(id);
        if (alvo) alvo.textContent = 'O painel está indisponível agora. Os artigos continuam abertos.';
      });
    });
  }
})();
