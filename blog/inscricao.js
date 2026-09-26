// Inscrição na Lista da Turma Fundadora a partir do guia e dos artigos.
// Grava em espelho_interessados com a chave publicável (pública por design): o visitante só consegue INSERIR,
// com consentimento, e ninguém de fora lê a lista. O canal registra de onde a pessoa veio.
(function () {
  const CASTELO_URL = 'https://zolbckgqdxxovguspjdb.supabase.co';
  const CHAVE_PUBLICA = 'sb_publishable_BuWJQNrlYoNrIjrrFJNU5w_dJKXf7nu';
  const EMAIL_VALIDO = /^[^@\s]+@[^@\s]+\.[^@\s]{2,}$/;

  function limpar(s) {
    return String(s || '').toLowerCase().replace(/[^a-z0-9_.:/-]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 60);
  }

  // Canal: UTM da visita (guardada na sessão) ou a página onde a pessoa se inscreveu.
  function canal(pagina) {
    let utm = '';
    try {
      const p = new URLSearchParams(location.search);
      const fonte = limpar(p.get('utm_source'));
      const campanha = limpar(p.get('utm_campaign'));
      if (fonte) sessionStorage.setItem('espelho_utm', campanha ? `${fonte}/${campanha}` : fonte);
      utm = sessionStorage.getItem('espelho_utm') || '';
    } catch (_) { /* navegação privada: segue sem UTM */ }
    return utm ? `${utm}:${pagina}` : pagina;
  }

  // Instruções de Pix depois da inscrição: o Castelo só devolve algo quando espelho_pagamento_config está ligado,
  // e só para o que o organismo entrega sozinho (espelho_catalogo.pix_automatico). A chave nunca fica no site.
  async function instrucoesPagamento(cliente, email) {
    try {
      const { data, error } = await cliente.rpc('espelho_instrucoes_pagamento', { p_email: email });
      return error ? null : data;
    } catch (_) { return null; }
  }

  // O que cada pedido precisa receber e o prazo vêm do catálogo do Castelo (espelho_catalogo), junto com o valor.
  function mostrarPagamento(ancora, p, email) {
    const antigo = ancora.parentNode.querySelector('.pagamento');
    if (antigo) antigo.remove();
    const valor = (p.valor_centavos / 100).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
    const caixa = document.createElement('div');
    caixa.className = 'pagamento';
    const linhas = [
      ['strong', p.recorrente ? `Para começar agora: ${valor} por Pix (1º mês)` : `Para garantir agora: ${valor} por Pix`],
      ['p', `Chave Pix: ${p.chave_pix}${p.favorecido ? ` (${p.favorecido})` : ''}`],
      ['p', `Na descrição do Pix, escreva o seu e-mail (${email}).`],
      ['p', p.email_comprovante ? `Depois de pagar, mande o comprovante para ${p.email_comprovante}.` : 'Guarde o comprovante do Pix.'],
      ['p', `${p.material || ''} ${p.prazo || 'A entrega chega em até 24 horas.'} Tudo chega em ${email}.`.trim()],
      ['p', 'Você tem 7 dias para desistir e receber o dinheiro de volta, sem precisar explicar (CDC, art. 49).']
    ];
    for (const [tag, texto] of linhas) {
      const el = document.createElement(tag);
      el.textContent = texto;
      caixa.appendChild(el);
    }
    const copiar = document.createElement('button');
    copiar.type = 'button';
    copiar.className = 'btn';
    copiar.textContent = 'Copiar chave Pix';
    copiar.addEventListener('click', () => {
      if (!navigator.clipboard) return;
      navigator.clipboard.writeText(p.chave_pix).then(() => { copiar.textContent = 'Chave copiada'; }).catch(() => {});
    });
    caixa.appendChild(copiar);
    ancora.insertAdjacentElement('afterend', caixa);
  }

  document.querySelectorAll('form.inscricao').forEach((form) => {
    const retorno = form.querySelector('.retorno');
    const botao = form.querySelector('button[type=submit]');
    const pagina = limpar(form.dataset.pagina || location.pathname.replace(/\.html$/, ''));

    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const dados = new FormData(form);
      const inscricao = {
        nome: String(dados.get('nome') || '').trim(),
        email: String(dados.get('email') || '').trim(),
        pacote: String(dados.get('pacote') || 'indefinido'),
        mensagem: form.dataset.mensagem || null,
        consentimento: dados.get('consentimento') === 'on',
        canal: canal(pagina).slice(0, 120)
      };
      const erro = (t) => { retorno.textContent = t; retorno.className = 'retorno erro'; };
      if (inscricao.nome.length < 2) return erro('Escreva seu nome.');
      if (!EMAIL_VALIDO.test(inscricao.email)) return erro('Esse e-mail não parece válido.');
      if (!inscricao.consentimento) return erro('Marque o aceite de contato para entrar na lista.');

      if (!window.supabase) return erro('Não foi possível conectar agora. Tente de novo em instantes.');
      botao.disabled = true;
      retorno.textContent = 'Registrando…';
      retorno.className = 'retorno';
      const cliente = window.supabase.createClient(CASTELO_URL, CHAVE_PUBLICA);
      const { error } = await cliente.from('espelho_interessados').insert(inscricao);
      botao.disabled = false;
      if (error && error.code === '23505') {
        retorno.textContent = 'Você já está na lista. Sua vaga de fundador está guardada.';
        retorno.className = 'retorno ok';
        return;
      }
      if (error) return erro('Não conseguimos registrar agora. Tente de novo em instantes.');
      retorno.textContent = `Pronto, ${inscricao.nome.split(' ')[0]}. Você está na Turma Fundadora: o contato chega em ${inscricao.email} quando a sua vaga abrir.`;
      retorno.className = 'retorno ok';
      const pagamento = await instrucoesPagamento(cliente, inscricao.email);
      if (pagamento) mostrarPagamento(retorno, pagamento, inscricao.email);
      form.reset();
    });
  });
})();
