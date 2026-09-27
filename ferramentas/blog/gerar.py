#!/usr/bin/env python3
"""Gera o guia gratuito e os artigos do blog do Espelho Espelho Evo com cabeçalho, rodapé e formulário iguais."""
import html
import json
import pathlib
import re

RAIZ = pathlib.Path(__file__).resolve().parents[2]
SITE = 'https://espelho-espelho-evo.vercel.app'
DATA = '2026-09-26'
AUTOR = 'Espelho Espelho Evo'

CABECA = """<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{titulo_pagina}</title>
<meta name="description" content="{descricao}">
<link rel="canonical" href="{url}">
<meta property="og:type" content="article">
<meta property="og:url" content="{url}">
<meta property="og:site_name" content="Espelho Espelho Evo">
<meta property="og:title" content="{titulo}">
<meta property="og:description" content="{descricao}">
<meta property="og:locale" content="pt_BR">
<meta property="og:image" content="{site}/icons/icone-512.png">
<meta name="twitter:card" content="summary">
<meta name="twitter:title" content="{titulo}">
<meta name="twitter:description" content="{descricao}">
<meta name="theme-color" content="#07060b">
<link rel="icon" href="/icons/icone.svg" type="image/svg+xml">
<link rel="manifest" href="/manifest.webmanifest">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@500;600;700&family=Alegreya:ital,wght@0,400;0,500;1,400&display=swap">
<link rel="stylesheet" href="/blog/artigo.css">
<script type="application/ld+json">{ld}</script>
</head>
<body>
<header class="topo">
  <a class="marca" href="/">🪞 Espelho Espelho Evo</a>
  <nav aria-label="Seções"><a href="/investigar.html">Investigar</a> <a href="/investigar.html#conferir">Conferir</a> <a href="/blog/">Aprender</a> <a href="/blog/ressonancias.html">Acompanhar</a> <a href="/nucleos.html">Conhecer o EVO</a></nav>
</header>
"""

FORM = """<form class="inscricao" data-pagina="{pagina}" novalidate>
      <label for="nome-{i}">Nome</label>
      <input type="text" id="nome-{i}" name="nome" autocomplete="name" maxlength="120" placeholder="Como devemos te chamar?" required>
      <label for="email-{i}">E-mail</label>
      <input type="email" id="email-{i}" name="email" autocomplete="email" maxlength="254" placeholder="voce@exemplo.com" required>
      <label for="pacote-{i}">O que mais te interessa</label>
      <select id="pacote-{i}" name="pacote">
        <option value="indefinido">Quero conhecer primeiro</option>
        <optgroup label="Planos mensais">
          <option value="plano_estudante">Plano Estudante · R$ 9,90/mês</option>
          <option value="plano_pro">Plano Profissional · R$ 39/mês</option>
          <option value="plano_ultra">Plano Ultra · Seu Fio no Castelo · R$ 97/mês</option>
          <option value="plano_empresa">Plano Empresarial · R$ 297/mês</option>
        </optgroup>
        <optgroup label="Concursos e ENEM">
          <option value="plano_concurso">Plano Concursos por etapas · R$ 39/mês</option>
          <option value="concurso_mapa">Mapa do Edital · R$ 29</option>
          <option value="enem_redacao">Redação ENEM · 4 correções · R$ 29</option>
        </optgroup>
        <optgroup label="Avulsos">
          <option value="checagem">Checagem P0 de uma resposta · R$ 19</option>
          <option value="investigacao">Investigação Sonar · R$ 29</option>
          <option value="roteiros">Roteiros do Organismo · R$ 27</option>
          <option value="trina">Mesa Trina por escrito · R$ 147</option>
          <option value="sonar">Auditoria P0 Sonar · R$ 990 ou 3× R$ 330</option>
        </optgroup>
      </select>
      <label class="aceite"><input type="checkbox" name="consentimento" required> <span>Aceito receber contato do Espelho Evo sobre a fase beta. Meus dados não são compartilhados e posso pedir a remoção quando quiser.</span></label>
      <button type="submit" class="btn">{botao}</button>
      <p class="retorno" role="status" aria-live="polite"></p>
    </form>"""

OFERTAS_PADRAO = [
    '<strong>Plano Estudante</strong>: 10 checagens P0 por mês e os Roteiros inclusos, R$ 9,90/mês.',
    '<strong>Checagem P0 de uma resposta</strong>: você manda a resposta da IA e recebe o laudo das 7 verificações em até 24 horas, R$ 19.',
    '<strong>Plano Profissional</strong>: 30 checagens, 2 investigações Sonar e 1 Mesa Trina por mês, R$ 39/mês.',
]

CHAMADA = """<section class="chamada" aria-labelledby="chamada-{i}">
    <h2 id="chamada-{i}">{titulo}</h2>
    <p>{texto}</p>
    <ul class="ofertas">
{ofertas}
    </ul>
    <p>Entrar na lista não custa nada. Se escolher um plano ou serviço, o Pix aparece logo depois, e você tem 7 dias para desistir.</p>
    {form}
  </section>"""

SINAL = """<section class="sinal" aria-labelledby="sinal-t">
    <h2 id="sinal-t">Este artigo continua com você</h2>
    <p>Tem uma pergunta, uma correção, uma fonte ou uma experiência sobre o assunto? Mande. O organismo lê tudo, mas <strong>nada vira verdade por ser muito pedido</strong>: cada sinal passa pela checagem antes de virar conteúdo.</p>
    <div class="sinal-acoes">
      <button type="button" class="btn fantasma investigar" data-pagina="{pagina}">🔎 Quero investigar isso</button>
      <button type="button" class="btn fantasma compartilhar">Compartilhar</button>
      <p class="retorno retorno-investigar" role="status" aria-live="polite"></p>
    </div>
    <form class="sinal-form" data-pagina="{pagina}" novalidate>
      <label for="sinal-tipo">O que você quer mandar?</label>
      <select id="sinal-tipo" name="tipo">
        <option value="pergunta">Uma pergunta</option>
        <option value="correcao">Uma correção</option>
        <option value="evidencia">Uma fonte ou evidência</option>
        <option value="experiencia">Uma experiência</option>
        <option value="opiniao">Uma opinião</option>
      </select>
      <label for="sinal-texto">Seu texto</label>
      <textarea id="sinal-texto" name="texto" maxlength="4000" rows="4" placeholder="Escreva do seu jeito. Se tiver link da fonte, cole aqui." required></textarea>
      <label for="sinal-nome">Nome (opcional)</label>
      <input type="text" id="sinal-nome" name="nome" maxlength="80" autocomplete="name" placeholder="Como quer ser identificado">
      <details>
        <summary>Quero receber a resposta por e-mail</summary>
        <label for="sinal-email">E-mail</label>
        <input type="email" id="sinal-email" name="email" maxlength="254" autocomplete="email" placeholder="voce@exemplo.com">
        <label class="aceite"><input type="checkbox" name="contato"> <span>Autorizo o contato só para responder este envio.</span></label>
      </details>
      <button type="submit" class="btn">Enviar ao organismo</button>
      <p class="retorno" role="status" aria-live="polite"></p>
    </form>
  </section>

  """

# Atalho logo abaixo da linha fina: quem chega pelo anúncio vê o caminho para a oferta sem rolar o artigo inteiro.
ATALHO = """<p class="atalho">{texto} <a href="#chamada-1">{link} ↓</a></p>"""

# Fase 3 da reforma: o artigo não termina em saída; aponta para leituras do mesmo tema.
RELACIONADOS = """<section class="relacionados" aria-labelledby="relacionados-t">
    <h2 id="relacionados-t">Continue lendo</h2>
    <ul>
{itens}
    </ul>
  </section>"""

RODAPE = """<footer class="rodape">
  <p><a href="/">Espelho Espelho Evo</a> · investigar o que a IA respondeu, em português · <a href="/blog/">todos os artigos</a> · <a href="/guia-p0.html">guia gratuito</a> · <a href="/#comercio">planos e preços</a></p>
</footer>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.js" defer></script>
<script src="/blog/inscricao.js" defer></script>
<script src="/blog/espelho.js" defer></script>
<script src="/blog/radar.js" defer></script>
</body>
</html>
"""


def ld_artigo(titulo, descricao, url):
    return json.dumps({
        '@context': 'https://schema.org',
        '@type': 'Article',
        'headline': titulo,
        'description': descricao,
        'inLanguage': 'pt-BR',
        'datePublished': DATA,
        'dateModified': DATA,
        'author': {'@type': 'Organization', 'name': AUTOR, 'url': SITE + '/'},
        'publisher': {'@type': 'Organization', 'name': AUTOR, 'url': SITE + '/'},
        'mainEntityOfPage': url,
    }, ensure_ascii=False)


def pagina(caminho, titulo, descricao, corpo, chamada, titulo_pagina=None, ld=None, tema=(), resumo=None, relacionados=''):
    url = f'{SITE}/{caminho}'.replace('/index.html', '/')
    esc = lambda s: html.escape(s, quote=True)
    cab = CABECA.format(
        titulo_pagina=esc(titulo_pagina or f'{titulo} · Espelho Espelho Evo'),
        titulo=esc(titulo), descricao=esc(descricao), url=url, site=SITE,
        ld=(ld or ld_artigo(titulo, descricao, url)).replace('</', '<\\/'),
    )
    slug = re.sub(r'[^a-z0-9/-]+', '-', caminho.replace('.html', '').replace('index', '').strip('/')) or 'blog'
    ch = ''
    if chamada:
        form = FORM.format(pagina=slug, i=1, botao=chamada.get('botao', 'Entrar na Turma Fundadora'))
        if chamada.get('pacote'):
            form = form.replace(f'<option value="{chamada["pacote"]}">', f'<option value="{chamada["pacote"]}" selected>', 1)
        ofertas = '\n'.join(f'      <li>{o}</li>' for o in chamada.get('ofertas', OFERTAS_PADRAO))
        ch = CHAMADA.format(i=1, titulo=chamada['titulo'], texto=chamada['texto'], ofertas=ofertas, form=form)
        if '<article>' in corpo and chamada.get('atalho'):
            texto, link = chamada['atalho']
            corpo = re.sub(r'(<p class="linha-fina">.*?</p>)', lambda m: m.group(1) + '\n  ' + ATALHO.format(texto=texto, link=link), corpo, count=1, flags=re.S)
    if caminho.startswith('blog/') and 'class="sinal-form"' not in corpo and caminho not in ('blog/index.html', 'blog/ressonancias.html'):
        sinal = SINAL.format(pagina=slug)
        if caminho.startswith('blog/investigacoes/'):
            sinal = sinal.replace('Este artigo continua com você', 'Esta investigação continua com você')
        ch = sinal + ch
    miolo = corpo.replace('{{CHAMADA}}', ch + relacionados)
    # O radar P0 só vai para as páginas que o usam (tela Investigar e investigações abertas).
    rodape = RODAPE if 'data-radar' in miolo else RODAPE.replace('<script src="/blog/radar.js" defer></script>\n', '')
    doc = cab + miolo + rodape
    destino = RAIZ / caminho
    destino.parent.mkdir(parents=True, exist_ok=True)
    destino.write_text(doc, encoding='utf-8')
    return url


# Investigações abertas (27/09): o mesmo casos.json alimenta as páginas e o radar (caso parecido).
CASOS = json.loads((RAIZ / 'blog/investigacoes/casos.json').read_text(encoding='utf-8'))['casos']

# As 8 partes do relatório, na ordem em que chegam para quem pede.
PARTES = [
    ('pergunta', 'Pergunta', 'Como você fez, sem reescrever.'),
    ('sinais', 'Sinais encontrados', 'O que já se diz sobre o tema, e onde.'),
    ('fontes', 'Fontes', 'Cada uma com link e data, primárias primeiro.'),
    ('a_favor', 'Evidências a favor', 'O que sustenta a afirmação.'),
    ('em_conflito', 'Evidências em conflito', 'O que a contradiz ou a limita.'),
    ('nao_confirmado', 'O que não foi confirmado', 'Dito com todas as letras, em vez de preenchido com palpite.'),
    ('contexto', 'Contexto', 'Condições, exceções e o que mudou com o tempo.'),
    ('conclusao', 'Conclusão provisória', 'O que dá para afirmar hoje, e com que segurança.'),
]


def _e(s):
    return html.escape(str(s), quote=True)


def parte_html(caso, chave):
    v = caso[chave]
    if chave == 'pergunta':
        return f'<blockquote class="afirmacao" data-radar-estatico>{_e(v)}</blockquote>'
    if chave == 'fontes':
        itens = ''.join(f'<li><a href="{_e(f["url"])}" rel="noopener">{_e(f["titulo"])}</a>'
                        f'<span class="fonte-tipo">{_e(f["tipo"])}, consultada em {_e(f["consulta"])}</span></li>' for f in v)
        return f'<ol class="fontes">{itens}</ol>'
    if chave == 'conclusao':
        return f'<p>{_e(v)}</p><p class="seguranca"><strong>Segurança.</strong> {_e(caso["seguranca"])}</p>'
    if isinstance(v, list):
        return '<ul>' + ''.join(f'<li>{_e(x)}</li>' for x in v) + '</ul>'
    return f'<p>{_e(v)}</p>'


def trilha_html(caso):
    itens = []
    for p in caso['linhagem']:
        feito = p['estado'] == 'feito'
        itens.append(f'<li class="{"feito" if feito else "aguardando"}"><details><summary><span class="etapa">{_e(p["etapa"])}</span>'
                     f'<span class="estado">{"feito" if feito else "aguardando"}</span></summary><p>{_e(p["feito"])}</p></details></li>')
    return '<ol class="trilha">\n      ' + '\n      '.join(itens) + '\n    </ol>'


def relatorio_html(caso):
    """Seção "O que chega para você" da tela Investigar: as 8 partes abertas com um caso real."""
    partes = '\n      '.join(
        f'<details{" open" if chave == "pergunta" else ""}><summary><span class="parte">{nome}</span><span class="parte-o-que">{o_que}</span></summary>'
        f'<div>{parte_html(caso, chave)}</div></details>' for chave, nome, o_que in PARTES)
    return f"""<section class="sonar-bloco" id="por-dentro" aria-labelledby="entrega-t">
    <h2 id="entrega-t">O que chega para você</h2>
    <p>Uma investigação, não uma resposta a mais. Abra cada parte desta, feita pelo organismo em {_e(caso["data"][8:10] + "/" + caso["data"][5:7] + "/" + caso["data"][:4])}: <a href="{_e(caso["url"])}">{_e(caso["titulo"])}</a></p>
    <div class="relatorio">
      {partes}
    </div>
    <h3>Como foi feita</h3>
    {trilha_html(caso)}
    <p class="nota">Quem coleta não dá o veredito, e nada vira verdade por ser muito pedido. <a href="{_e(caso["url"])}">Abrir a investigação completa</a> · <a href="/nucleos.html">Conhecer o EVO por dentro</a></p>
  </section>"""


def pagina_caso(caso):
    """Página própria da investigação: conclusão primeiro, depois as partes, a trilha e o convite."""
    data = caso['data'][8:10] + '/' + caso['data'][5:7] + '/' + caso['data'][:4]
    aguardando = [p['etapa'] for p in caso['linhagem'] if p['estado'] != 'feito']
    estado = (f'<p class="estado-trina">Ainda aguardando: {_e(", ".join(aguardando))}. Até lá, esta conclusão é provisória.</p>'
              if aguardando else '')
    secoes = '\n  '.join(f'<h2>{nome}</h2>\n  {parte_html(caso, chave)}' for chave, nome, _ in PARTES if chave != 'conclusao')
    corpo = f"""<main class="pagina caso">
  <p class="meta">Investigação do organismo, {data}</p>
  <h1>{_e(caso["titulo"])}</h1>
  <p class="linha-fina">{_e(caso["demonstracao"])}</p>
  <section class="quadro conclusao-topo" aria-labelledby="conclusao-t">
    <h2 id="conclusao-t">Conclusão provisória</h2>
    {parte_html(caso, "conclusao")}
    {estado}
  </section>
  {secoes}
  <p class="nota">As marcas na pergunta são do radar P0: onde olhar antes de confiar. <a href="/investigar.html#conferir">Use o radar no seu texto</a>.</p>
  <h2>Como foi feita</h2>
  {trilha_html(caso)}
  <section class="sonar-bloco" aria-labelledby="parecida-t">
    <h2 id="parecida-t">Tem uma pergunta parecida?</h2>
    <p>O organismo parte do que já investigou, em vez de começar do zero. Mande a sua pergunta ou a resposta de IA que você quer conferir.</p>
    <p class="botoes"><a class="btn" href="/investigar.html">Investigar a minha pergunta</a> <a class="btn fantasma" href="/investigar.html#conferir">Conferir uma resposta de IA</a></p>
  </section>
  {{{{CHAMADA}}}}
</main>
"""
    url = f'{SITE}{caso["url"]}'
    ld = json.dumps({'@context': 'https://schema.org', '@type': 'Article', 'headline': caso['titulo'],
                     'description': caso['conclusao'], 'inLanguage': 'pt-BR', 'datePublished': caso['data'],
                     'dateModified': caso['data'], 'author': {'@type': 'Organization', 'name': AUTOR, 'url': SITE + '/'},
                     'publisher': {'@type': 'Organization', 'name': AUTOR, 'url': SITE + '/'}, 'mainEntityOfPage': url},
                    ensure_ascii=False)
    return dict(caminho=caso['url'].lstrip('/'), titulo=caso['titulo'],
                titulo_pagina=f'{caso["titulo"]} · Investigação · Espelho Espelho Evo',
                descricao=caso['conclusao'][:155].rsplit(' ', 1)[0] + '…', corpo=corpo, chamada=None, ld=ld,
                tema=('checagem', 'concurso', 'investigacao'),
                resumo='Investigação aberta: fontes com data, conflitos e o que não deu para confirmar.')


def relacionados(atual, paginas, limite=3):
    """Até 3 artigos com tema em comum (os mais parecidos primeiro); completa com o guia gratuito."""
    temas = set(atual.get('tema', ()))
    if not temas:
        return ''
    candidatos = [p for p in paginas if p['caminho'] != atual['caminho'] and p.get('tema')]
    candidatos.sort(key=lambda p: -len(temas & set(p['tema'])))
    escolhidos = [p for p in candidatos if temas & set(p['tema'])][:limite]
    if len(escolhidos) < limite:
        escolhidos += [p for p in candidatos if 'guia' in p['tema'] and p not in escolhidos][:limite - len(escolhidos)]
    itens = '\n'.join(
        f'      <li><a href="/{p["caminho"]}">{p["titulo"]}</a><p>{p.get("resumo") or ""}</p></li>' for p in escolhidos)
    return '\n  ' + RELACIONADOS.format(itens=itens) if itens else ''


if __name__ == '__main__':
    import conteudo
    paginas = conteudo.PAGINAS + [pagina_caso(c) for c in CASOS]
    for p in paginas:
        if '{{RELATORIO}}' in p['corpo']:
            p = {**p, 'corpo': p['corpo'].replace('{{RELATORIO}}', relatorio_html(CASOS[0]))}
        print(pagina(**p, relacionados=relacionados(p, paginas)))
