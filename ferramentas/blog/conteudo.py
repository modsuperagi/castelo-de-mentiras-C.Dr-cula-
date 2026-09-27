"""Conteúdo do guia gratuito e dos artigos do blog do Espelho Espelho Evo."""

GUIA = """<main class="pagina">
  <p class="meta">Guia gratuito · leitura de 6 minutos · para imprimir ou salvar</p>
  <h1>7 perguntas para saber se a IA inventou a resposta</h1>
  <p class="linha-fina">Uma checagem simples, que funciona com qualquer IA, antes de você copiar, enviar ou decidir alguma coisa com base no que ela disse.</p>

  <p>IA escreve com segurança mesmo quando está errada. Ela não mente por maldade: ela completa frases de um jeito provável, e às vezes o provável é falso. Um nome de lei que não existe, um estudo que ninguém publicou, um número que parece exato e não tem origem.</p>
  <p>Este guia é a versão de bolso do <strong>P0</strong>, o filtro de sete verificações que o nosso organismo usa antes de deixar qualquer informação circular. A regra é uma só: <strong>um "não" basta para parar</strong>. Se alguma das sete perguntas não tiver resposta boa, você não usa a informação ainda. Primeiro confere.</p>

  <div class="pergunta">
    <h3><span class="num">1.</span>Identidade: quem está falando?</h3>
    <p>Qual ferramenta respondeu, em que data, e ela tinha acesso à internet naquele momento? Uma IA sem busca não sabe o que aconteceu depois do treino dela. Se a pergunta é sobre algo recente e a ferramenta não pesquisou, a resposta é palpite.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">2.</span>Autoridade: essa fonte pode afirmar isso?</h3>
    <p>IA não é médica, advogada nem contadora. Em saúde, direito, dinheiro e segurança, a resposta da IA serve para você entender o assunto e formular perguntas melhores. A decisão pede a fonte que tem autoridade: a bula, a lei publicada, o profissional, o órgão oficial.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">3.</span>Propósito: ela respondeu o que eu perguntei?</h3>
    <p>Releia a sua pergunta e depois a resposta. É comum a IA responder uma pergunta parecida, mais fácil, ou enrolar com generalidades. Se a resposta mudou o assunto, ela não serve, por mais bem escrita que esteja.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">4.</span>Evidência: onde está a prova?</h3>
    <p>Peça as fontes e <strong>abra os links</strong>. Confira se a página existe e se ela diz o que a IA disse que ela diz. Número sem origem, citação sem autor e estudo sem nome de revista não contam como evidência.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">5.</span>Escopo: a conclusão cabe na evidência?</h3>
    <p>Uma pesquisa com 40 pessoas não prova nada sobre "todo mundo". Um caso não vira regra. Veja se a resposta generaliza além do que a fonte sustenta, e se ela separa o que é fato do que é opinião ou hipótese.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">6.</span>Rastreabilidade: eu consigo refazer o caminho?</h3>
    <p>Anote a pergunta, a data, a ferramenta e as fontes que você conferiu. Se amanhã alguém perguntar "de onde você tirou isso?", você precisa conseguir mostrar. Sem esse registro, a informação vira boato, mesmo quando é verdadeira.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">7.</span>Duplicidade: isso contradiz o que eu já sei?</h3>
    <p>Compare com o que você já tinha verificado antes. Se a nova resposta contradiz uma informação conferida, não escolha a mais conveniente: descubra qual das duas está certa. Se só repete o que você já sabia, ótimo, mas isso não é prova extra.</p>
  </div>

  <div class="quadro">
    <p><strong>Versão de 10 segundos</strong>, para colar num post-it:</p>
    <p>Quem falou? · Pode afirmar isso? · Respondeu o que perguntei? · Cadê a prova? · A conclusão cabe na prova? · Consigo refazer o caminho? · Bate com o que já sei?</p>
    <p><strong>Um "não" basta para parar e conferir.</strong></p>
  </div>

  <h2>Um pedido que ajuda qualquer IA</h2>
  <p>Cole isto depois da sua pergunta. Não garante acerto, mas deixa as lacunas visíveis:</p>
  <pre class="modelo">Responda separando em três partes:
1. O que é fato verificável, com a fonte de cada um (link ou referência completa).
2. O que é interpretação ou opinião sua.
3. O que você não sabe ou não conseguiu confirmar.
Se não tiver fonte para algo, diga "sem fonte" em vez de inventar.</pre>

  {{CHAMADA}}
</main>
"""

ARTIGO_INVENTOU = """<article>
  <p class="meta">Blog · 26 de setembro de 2026 · leitura de 7 minutos</p>
  <h1>Como saber se o ChatGPT (ou qualquer IA) inventou a resposta</h1>
  <p class="linha-fina">Por que a IA erra com tanta confiança, quais erros aparecem mais e uma checagem simples para não cair neles.</p>

  <p>Quem usa IA no trabalho já passou por isso: a resposta vem bem escrita, organizada, com tom de especialista, e está errada. Às vezes um detalhe, às vezes a base inteira. O nome técnico é <strong>alucinação</strong>, mas o nome não ajuda a evitar o problema. O que ajuda é entender de onde ele vem.</p>

  <h2>Por que a IA inventa</h2>
  <p>Um modelo de linguagem aprende padrões de texto e gera a continuação mais provável para o que você escreveu. Ele não consulta um arquivo de verdades antes de responder. Quando o padrão provável coincide com a realidade, a resposta sai certa. Quando não coincide, ele produz algo que <em>soa</em> certo.</p>
  <p>Por isso o erro vem com a mesma segurança do acerto. A fluência do texto não diz nada sobre a veracidade.</p>

  <h2>Os erros que mais aparecem</h2>
  <ul>
    <li><strong>Fontes que não existem:</strong> artigos, livros, leis e links com nomes plausíveis e nenhuma existência real.</li>
    <li><strong>Números precisos sem origem:</strong> "37,4% das empresas…" sem pesquisa identificável por trás.</li>
    <li><strong>Informação desatualizada:</strong> a ferramenta responde sobre algo recente sem ter pesquisado, com base no que sabia antes.</li>
    <li><strong>Troca de pergunta:</strong> ela responde uma pergunta parecida, mais fácil, e você não percebe.</li>
    <li><strong>Generalização:</strong> um caso vira regra, uma opinião vira consenso.</li>
  </ul>

  <h2>A checagem em sete perguntas</h2>
  <p>No nosso organismo, nenhuma informação circula sem passar pelo <strong>P0</strong>, um filtro de sete verificações. A versão para uso diário é esta:</p>
  <ol>
    <li><strong>Quem falou?</strong> Qual ferramenta, em que data, e se ela pesquisou na internet.</li>
    <li><strong>Pode afirmar isso?</strong> Em saúde, lei e dinheiro, a IA orienta; quem decide é a fonte com autoridade.</li>
    <li><strong>Respondeu o que eu perguntei?</strong> Releia os dois lados.</li>
    <li><strong>Cadê a prova?</strong> Abra cada link. Confira se diz o que a IA disse.</li>
    <li><strong>A conclusão cabe na prova?</strong> Veja se ela generaliza além do que a fonte sustenta.</li>
    <li><strong>Consigo refazer o caminho?</strong> Anote pergunta, data e fontes conferidas.</li>
    <li><strong>Bate com o que já sei?</strong> Se contradiz algo verificado, investigue antes de escolher.</li>
  </ol>
  <p>A regra que torna isso útil: <strong>um "não" basta para parar</strong>. Não é preciso que as sete falhem. Uma falha já significa "ainda não use".</p>
  <p>O <a href="/guia-p0.html">guia gratuito</a> explica cada pergunta com exemplos e traz um modelo de pedido que você cola depois de qualquer pergunta para a IA separar fato, opinião e o que ela não sabe.</p>

  <h2>O que muda quando você faz isso sempre</h2>
  <p>No começo parece lento. Depois de algumas semanas vira reflexo: você lê a resposta já procurando a fonte, já percebendo a generalização. E começa a guardar o que conferiu, com data e origem. É aí que a IA deixa de ser um oráculo arriscado e vira uma ferramenta de trabalho confiável: não porque ela parou de errar, mas porque você passou a ver os erros.</p>

  {{CHAMADA}}
</article>
"""

ARTIGO_MEMORIA = """<article>
  <p class="meta">Blog · 26 de setembro de 2026 · leitura de 6 minutos</p>
  <h1>Por que a IA esquece o que você já explicou, e como criar uma memória que não se perde</h1>
  <p class="linha-fina">Conversa com IA não é arquivo. Um registro simples, feito por você, resolve o problema do "começar do zero" toda vez.</p>

  <p>Você explica o projeto, o contexto, as decisões que já tomou. A conversa rende. Dias depois, numa conversa nova, é preciso explicar tudo de novo. Ou pior: a IA "lembra" de algo que você nunca disse.</p>
  <p>Algumas ferramentas já oferecem memória entre conversas, e isso ajuda. Mas essa memória é da ferramenta: você não controla bem o que entra, o que sai, nem como ela é usada. E se você trocar de ferramenta, ela fica para trás.</p>

  <h2>A memória que vale é a sua</h2>
  <p>O nosso organismo guarda tudo num lugar que chamamos de <strong>Castelo de Memórias</strong>: um registro em banco de dados onde cada informação entra com identidade, data, fonte e decisão. Você não precisa de banco de dados para começar. Um documento ou uma planilha resolvem, desde que sigam quatro regras.</p>

  <h3>1. Cada entrada tem data e origem</h3>
  <p>"O cliente prefere entrega às sextas" vale pouco. "Em 12/09, o cliente pediu por e-mail entrega às sextas" vale muito. Sem data e origem, você não sabe se a informação ainda vale nem de onde ela veio.</p>

  <h3>2. Fato, hipótese e decisão ficam separados</h3>
  <p>Escreva o tipo de cada entrada: <em>fato</em> (verificado), <em>hipótese</em> (suspeita a confirmar) ou <em>decisão</em> (o que foi escolhido e por quê). Quando uma hipótese vira fato, isso acontece numa entrada nova, com a prova.</p>

  <h3>3. Atualizar é acrescentar, não apagar</h3>
  <p>Mudou alguma coisa? Escreva uma entrada nova dizendo o que mudou e por quê, e aponte para a antiga. Apagar o passado apaga também o motivo das decisões, e é justamente o motivo que você vai precisar lembrar daqui a seis meses.</p>

  <h3>4. Toda conversa nova começa lendo o registro</h3>
  <p>Cole na IA as entradas que importam para a tarefa do dia. Em vez de explicar tudo de memória, você entrega um contexto conferido, com datas. A IA trabalha melhor e você para de repetir.</p>

  <div class="quadro">
    <p><strong>Modelo de entrada</strong>, para copiar:</p>
    <pre class="modelo">Data: 26/09/2026
Quem: (você, cliente, ferramenta X…)
Tipo: fato | hipótese | decisão
Conteúdo: (uma ou duas frases)
Fonte: (e-mail de fulano, link, reunião de 25/09…)
Substitui: (entrada anterior, se houver)</pre>
  </div>

  <h2>O ganho real</h2>
  <p>Um registro assim transforma a IA de "assistente que esquece" em "assistente que trabalha em cima do que você já sabe". E ele é seu: vale para qualquer ferramenta de hoje e para as que vierem depois.</p>
  <p>Para decidir o que entra no registro, use as <a href="/guia-p0.html">7 perguntas do guia gratuito</a>: só guarde como fato o que passou por elas.</p>

  {{CHAMADA}}
</article>
"""

ARTIGO_TRINA = """<article>
  <p class="meta">Blog · 26 de setembro de 2026 · leitura de 6 minutos</p>
  <h1>Três olhares antes de decidir com IA: o método da Mesa Trina</h1>
  <p class="linha-fina">Pedir para a IA "revisar" rende elogio. Pedir três leituras diferentes, com papéis definidos, rende crítica útil.</p>

  <p>Quando você pede para uma IA avaliar um plano, ela tende a concordar e sugerir melhorias pequenas. É o jeito mais provável de responder. O problema é que decisões importantes precisam do contrário: alguém procurando o que pode dar errado.</p>
  <p>No nosso organismo, decisões e conhecimentos novos passam pela <strong>Mesa Trina</strong>: três posições que olham a mesma coisa por ângulos diferentes. A regra central é que <strong>ninguém valida a própria lição</strong>: quem propôs não é quem aprova.</p>

  <h2>As três posições</h2>
  <div class="pergunta">
    <h3>Arquiteto: isso encaixa?</h3>
    <p>Olha a estrutura. A proposta combina com o que já existe? Conflita com alguma decisão anterior? Resolve o problema certo, ou um problema vizinho?</p>
  </div>
  <div class="pergunta">
    <h3>Engenheiro: isso se sustenta?</h3>
    <p>Olha a execução. Dá para fazer com o tempo, o dinheiro e as pessoas que existem? O que quebra primeiro? Qual é o menor teste que prova que funciona?</p>
  </div>
  <div class="pergunta">
    <h3>Verificador: cadê a evidência?</h3>
    <p>Olha a prova. O que foi demonstrado e o que é suposição? Quais afirmações dependem de dados que ninguém conferiu? O que ficaria de fora se só valesse o que tem prova?</p>
  </div>

  <h2>Como usar com qualquer IA</h2>
  <p>Faça três pedidos separados, de preferência em conversas novas, para uma leitura não contaminar a outra:</p>
  <pre class="modelo">Você é o ARQUITETO. Não elogie. Diga se esta proposta encaixa no contexto abaixo,
com o que ela conflita e se resolve o problema certo.
[proposta] [contexto]</pre>
  <pre class="modelo">Você é o ENGENHEIRO. Não elogie. Diga o que quebra primeiro na execução,
o que falta de recurso e qual é o menor teste que provaria que funciona.
[proposta]</pre>
  <pre class="modelo">Você é o VERIFICADOR. Não elogie. Liste cada afirmação da proposta e marque:
provada (com qual evidência), suposição, ou sem base.
[proposta]</pre>
  <p>Depois, leia as três respostas juntas e decida. Cada resultado tem três saídas possíveis: <strong>confirmado</strong> (as três posições sustentam), <strong>parcial</strong> (vale com limites que você escreve) ou <strong>rejeitado</strong> (volta para a prancheta, com o motivo registrado).</p>

  <h2>Quando vale a pena</h2>
  <p>Não para tudo. Para decisões que custam caro se derem errado: contratar, investir, lançar, mudar um processo, publicar algo com seu nome. Nessas, meia hora de três olhares economiza semanas de conserto.</p>
  <p>Se quiser a sua decisão examinada pela Mesa Trina do organismo, com relatório de escopo provado e limites explícitos, as primeiras sessões da fase beta estão com preço de fundador.</p>

  {{CHAMADA}}
</article>
"""

ARTIGO_JURIS = """<article>
  <p class="meta">Blog · 26 de setembro de 2026 · leitura de 5 minutos · para advogados</p>
  <h1>Jurisprudência inventada pela IA: como conferir antes de protocolar</h1>
  <p class="linha-fina">A IA escreve precedente com número, relator e ementa que parecem reais. Cinco conferências tiram a dúvida em minutos, e a responsabilidade continua sendo de quem assina.</p>

  <p>O caso mais conhecido é americano: em 2023, um advogado de Nova York apresentou uma petição com seis precedentes que o ChatGPT inventou, e foi multado em US$ 5.000 (<a href="https://www.jusbrasil.com.br/noticias/advogado-pode-ser-punido-por-usar-chatgpt-em-acao-o-motivo-invencao-de-precedentes/1866539948" rel="noopener">Jusbrasil</a>, <a href="https://conjur.com.br/2025-abr-25/chatgpt-primeiro-voce-alucina-inventa-jurisprudencia-ou-nao-era-julgado-era-cilada/" rel="noopener">Conjur</a>). O problema não ficou lá: qualquer IA de conversa pode produzir um número de processo com formato correto, um relator que existe e uma tese que nenhum tribunal escreveu.</p>
  <p>A IA não consulta o tribunal quando responde. Ela escreve o que é provável. Um precedente provável não é um precedente real.</p>

  <h2>As cinco conferências</h2>
  <div class="pergunta">
    <h3><span class="num">1.</span>O processo existe?</h3>
    <p>Pesquise o número na consulta processual ou na pesquisa de jurisprudência do próprio tribunal. Não abriu, não existe. Não use busca geral da internet como prova: ela mostra páginas que citam o número, não o processo.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">2.</span>Os dados batem?</h3>
    <p>Confira relator, órgão julgador e data do julgamento no site do tribunal. A IA costuma acertar o tribunal e errar o resto, ou juntar um número real com o relator de outro caso.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">3.</span>O acórdão diz o que a IA disse que ele diz?</h3>
    <p>Abra o inteiro teor, não só a ementa. O erro mais perigoso é o precedente real com tese inventada: o processo existe, mas não decidiu aquilo. Copie o trecho exato que sustenta o seu argumento.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">4.</span>O entendimento ainda vale?</h3>
    <p>Veja se a tese não foi superada por julgamento posterior, súmula ou tema repetitivo. A IA não sabe o que mudou depois do treino dela.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">5.</span>Dá para mostrar de onde veio?</h3>
    <p>Anote o link da consulta e a data em que você conferiu. Se alguém questionar, você mostra o caminho em vez de defender a memória da IA.</p>
  </div>

  <h2>Um pedido que ajuda em vez de atrapalhar</h2>
  <p>Use a IA para saber <em>o que procurar</em>, não como fonte. Este pedido força a separação:</p>
  <pre class="modelo">Estou pesquisando [tema]. Não cite precedentes de memória.
1. Liste os termos e filtros que eu devo usar na pesquisa de jurisprudência de [tribunal].
2. Se mencionar algum julgado, marque cada um com [VERIFICAR] e diga que você não
   confirmou que ele existe.
3. Diga que tipo de decisão sustentaria a tese e que tipo a derrubaria.</pre>
  <p>A pesquisa em si acontece na base do tribunal. O que a IA entrega é o mapa, e mapa não vai na petição.</p>

  <h2>Para o escritório inteiro</h2>
  <p>As cinco conferências são a aplicação jurídica das <a href="/guia-p0.html">7 perguntas do guia gratuito</a>. Para padronizar isso na equipe, os <strong>Roteiros do Organismo</strong> trazem os pedidos prontos de checagem, registro de decisão e revisão em três olhares, e a <strong>Mesa Trina</strong> examina um fluxo de trabalho com IA do seu escritório em sessão.</p>
  <p class="meta">Este artigo trata de método de conferência. Não é orientação jurídica sobre um caso concreto.</p>

  {{CHAMADA}}
</article>
"""

ARTIGO_TCC = """<article>
  <p class="meta">Blog · 26 de setembro de 2026 · leitura de 5 minutos · para estudantes e pesquisadores</p>
  <h1>O ChatGPT me deu uma referência: como saber se ela existe antes de pôr no TCC</h1>
  <p class="linha-fina">A IA monta referências com autor, revista e ano que parecem perfeitas. Quatro buscas de dois minutos separam a real da inventada.</p>

  <p>Você pede fontes para o seu trabalho e a IA devolve uma lista bonita, no formato certo, com autores que parecem conhecidos. Parte dela pode não existir. A IA não consulta uma biblioteca quando responde: ela escreve o que é provável, e uma referência provável não é uma referência real (<a href="https://www.doutoranathalia.com.br/blog/chatgpt-referencias-falsas-como-verificar/" rel="noopener">Dra. Nathalia Cavichiolli</a>).</p>
  <p>O risco é seu: quem assina o trabalho responde pela lista de referências.</p>

  <h2>As quatro buscas</h2>
  <div class="pergunta">
    <h3><span class="num">1.</span>O DOI abre?</h3>
    <p>Se a referência tem DOI, cole em <strong>doi.org</strong> ou pesquise no <strong>Crossref</strong>. DOI que não abre, ou que abre outro artigo, é sinal forte de invenção.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">2.</span>O título exato aparece?</h3>
    <p>Pesquise o título entre aspas no <strong>Google Acadêmico</strong>. Nada encontrado com o título exato? Desconfie. A IA costuma juntar o nome de um autor real com um título que ele nunca escreveu.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">3.</span>A revista e o volume batem?</h3>
    <p>Abra o site da revista e procure a edição citada. Revista real com volume, número ou páginas que não existem é a invenção mais difícil de perceber.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">4.</span>O texto diz o que você vai citar?</h3>
    <p>Mesmo com a referência real, leia pelo menos o resumo. Às vezes o artigo existe, mas não defende o que a IA disse que ele defende.</p>
  </div>

  <h2>Um pedido que usa a IA sem arriscar o trabalho</h2>
  <p>Use a IA para saber <em>o que procurar</em>. A busca e a leitura são suas:</p>
  <pre class="modelo">Estou pesquisando [tema] para um trabalho acadêmico. Não me dê referências prontas.
1. Liste os termos de busca e as bases onde eu devo procurar.
2. Se citar algum autor ou estudo, marque cada um com [VERIFICAR]
   e diga que você não confirmou que ele existe.
3. Explique o debate principal do tema em poucas linhas,
   para eu saber o que estou procurando.</pre>
  <p>Se a IA foi usada no trabalho, veja também como a sua instituição pede que isso seja declarado (<a href="https://meutccnapratica.com.br/guia-abnt/referencia-de-ia" rel="noopener">TCC na Prática</a>).</p>

  <h2>Para não depender da memória</h2>
  <p>As quatro buscas são a pergunta 4 das <a href="/guia-p0.html">7 perguntas do guia gratuito</a>, "cadê a prova?", aplicada à pesquisa. Os <strong>Roteiros do Organismo</strong> trazem o resto do método pronto para copiar: abrir e fechar cada sessão de estudo com a IA para ela retomar de onde parou, checar respostas em outra conversa e registrar o que você decidiu.</p>

  {{CHAMADA}}
</article>
"""

ARTIGO_CONCURSO = """<article>
  <p class="meta">Blog · 26 de setembro de 2026 · leitura de 6 minutos · para concurseiros</p>
  <h1>Estudar para concurso com IA sem decorar lei inventada</h1>
  <p class="linha-fina">A IA faz questões de lei seca em segundos. O perigo é o artigo que não existe, a redação revogada e a súmula com o número trocado. Cinco conferências resolvem.</p>

  <p>Muita gente já usa IA para estudar para concurso: cola trechos da lei e pede questões, pede resumo do edital, pede para explicar um instituto. Um aprovado em cinco concursos de cartório contou que fazia assim, e deu o alerta: confira o que o robô manda, porque às vezes ele inventa autor e citação (<a href="https://folha.qconcursos.com/n/aprovado-em-concursos-usou-chatgpt-para-estudar" rel="noopener">Folha Dirigida</a>).</p>
  <p>O alerta tem número. Pesquisadores de Stanford mediram erros de 69% a 88% quando modelos de linguagem de uso geral respondem perguntas jurídicas específicas (<a href="https://law.stanford.edu/2024/01/11/hallucinating-law-legal-mistakes-with-large-language-models-are-pervasive/" rel="noopener">Stanford Law School</a>). Para quem estuda, um erro decorado vale menos que nada: ele custa a questão e ainda tira o ponto de quem marcou certo por instinto.</p>

  <h2>As cinco conferências</h2>
  <div class="pergunta">
    <h3><span class="num">1.</span>O artigo existe e diz isso?</h3>
    <p>Abra a lei no <strong>Planalto</strong> (planalto.gov.br), no texto compilado, e leia o artigo inteiro, com parágrafos e incisos. A IA costuma acertar o assunto e errar o número, ou juntar dois dispositivos num só.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">2.</span>Essa redação ainda vale?</h3>
    <p>No texto compilado, trecho riscado é redação antiga, e a nota ao lado diz qual lei mudou. A IA mistura versões com frequência, porque aprendeu com textos de anos diferentes.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">3.</span>A súmula é daquele tribunal, com aquele número?</h3>
    <p>Procure a súmula no site do próprio tribunal (STF, STJ, TST) e veja se ela não foi cancelada ou superada. Número de súmula é o tipo de detalhe que a IA completa de memória, e erra.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">4.</span>O edital cobra isso?</h3>
    <p>Volte ao conteúdo programático. Resumo bonito de assunto que não está no edital é tempo roubado do que está.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">5.</span>A banca pensa assim?</h3>
    <p>Na dúvida entre duas leituras, a referência é o gabarito oficial das provas anteriores da banca, não a opinião da IA.</p>
  </div>

  <h2>Um pedido que usa a IA sem arriscar o estudo</h2>
  <p>O segredo é a IA trabalhar sobre o texto que <em>você</em> trouxe da fonte oficial, e não sobre a memória dela:</p>
  <pre class="modelo">Abaixo está o texto oficial de [lei, artigos X a Y], copiado do Planalto.
Use SÓ este texto. Não complete nada de memória.
1. Faça 10 questões de certo ou errado no estilo da banca [nome].
2. Em cada uma, diga o artigo exato em que a resposta está.
3. Se precisar de algo que não está no texto, escreva [FORA DO TEXTO]
   em vez de inventar.

[cole o texto da lei]</pre>
  <p>Depois, confira as três primeiras questões você mesmo, no texto. Se uma delas citar artigo errado, descarte a lista inteira e peça de novo.</p>

  <h2>Por etapas, com a conferência já feita</h2>
  <p>As cinco conferências são a pergunta 4 das <a href="/guia-p0.html">7 perguntas do guia gratuito</a>, "cadê a prova?", aplicada à lei. Se quiser o estudo já montado assim, o organismo do Espelho faz por etapas: primeiro o mapa do seu edital, com cada lei ligada ao Planalto, e o cronograma até a prova; depois, toda semana, o plano da semana e questões comentadas com a base legal conferida na fonte oficial.</p>

  {{CHAMADA}}
</article>
"""

ARTIGO_ENEM = """<article>
  <p class="meta">Blog · 26 de setembro de 2026 · leitura de 6 minutos · para quem faz o ENEM</p>
  <h1>Redação do ENEM 2026 com IA: como pedir correção por competência (e não cair em nota inventada)</h1>
  <p class="linha-fina">A prova é em 8 de novembro. Seis semanas dão para seis redações corrigidas, se cada correção disser o que mudar em cada competência, e não só "ficou boa".</p>

  <p>A redação do ENEM 2026 é no primeiro dia de prova, 8 de novembro, junto com Linguagens e Ciências Humanas (<a href="https://www.fsa.br/datas-enem-2026/" rel="noopener">FSA</a>). O Inep já publicou a cartilha do participante com as regras e exemplos de textos bem avaliados em 2025 (<a href="https://www.gov.br/inep/pt-br/centrais-de-conteudo/acervo-linha-editorial/publicacoes-institucionais/avaliacoes-e-exames-da-educacao-basica/a-redacao-do-enem-2026-cartilha-do-a-participante" rel="noopener">Inep</a>). Ela é a fonte: tudo o que a IA disser sobre a correção precisa bater com ela.</p>

  <h2>As 5 competências, em uma linha cada</h2>
  <div class="pergunta">
    <h3><span class="num">1.</span>Norma escrita formal</h3>
    <p>Ortografia, acentuação, concordância, regência, pontuação.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">2.</span>Tema e tipo de texto</h3>
    <p>Entender a proposta, desenvolver o tema no texto dissertativo-argumentativo e usar repertório de outras áreas.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">3.</span>Argumentação</h3>
    <p>Selecionar, organizar e interpretar informações e fatos em defesa de um ponto de vista.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">4.</span>Coesão</h3>
    <p>Os conectivos e as retomadas que amarram um parágrafo no outro.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">5.</span>Proposta de intervenção</h3>
    <p>Uma ação para enfrentar o problema, respeitando os direitos humanos. A cartilha de 2026 destaca a diferença entre <em>propor</em> uma ação e só <em>constatar</em> o problema (<a href="https://agenciagov.ebc.com.br/noticias/202609/enem-2026-cartilha-da-redacao-esta-disponivel-1" rel="noopener">Agência Gov</a>).</p>
  </div>

  <h2>Onde a IA atrapalha</h2>
  <p>Pedir "corrige minha redação e dá a nota" costuma render elogio e um número redondo. A nota da IA não é a nota do ENEM: a oficial vem de corretores treinados pelo Inep. O que a IA faz bem é apontar, trecho por trecho, onde o texto se afasta de cada competência. E cuidado com o repertório: citação de autor ou dado que a IA sugerir precisa ser conferida, porque ela inventa autor e frase com a mesma segurança.</p>

  <h2>Um pedido que corrige de verdade</h2>
  <pre class="modelo">Você é um corretor treinado na matriz de referência da redação do ENEM.
Tema: [cole o tema]
Redação: [cole o texto]

Para CADA uma das 5 competências:
1. Cite o trecho exato que mais tirou pontos.
2. Explique o problema em uma linha.
3. Reescreva só esse trecho, melhor.
Na competência 5, diga se há agente, ação, meio, finalidade e detalhamento,
e se a proposta é uma ação ou só a constatação do problema.
Se sugerir repertório (autor, dado, lei), marque [CONFERIR].
Não dê elogio genérico. Não dê nota total.</pre>
  <p>Reescreva só os trechos apontados e mande de novo em outra conversa. A conversa que corrigiu tende a aprovar a própria sugestão.</p>

  <h2>Seis semanas, seis redações</h2>
  <p>Uma redação por semana, sempre com tema novo, cronometrada em 1 hora. Na semana seguinte, comece relendo a correção anterior. Na última semana, releia as seis correções e anote os três erros que mais se repetiram: é neles que você presta atenção no dia.</p>

  {{CHAMADA}}
</article>
"""

ARTIGO_SEDUC = """<article>
  <p class="meta">Blog · 26 de setembro de 2026 · leitura de 6 minutos · para quem vai fazer o concurso da Seduc CE</p>
  <h1>Concurso Seduc CE 2026 para professor: o estudo até a prova em 8 semanas</h1>
  <p class="linha-fina">São 2.000 vagas imediatas, inscrições até 15 de outubro e prova objetiva prevista para 22 de novembro. Um plano pelo peso de cada prova, e como usar IA sem decorar lei inventada.</p>

  <p>O Edital nº 014/2026 (SEDUC/SEPLAG), organizado pela FUNECE/CEV-UECE, abriu 2.000 vagas imediatas e 1.000 de cadastro de reserva para professor, em 13 disciplinas e no Atendimento Educacional Especializado. As inscrições vão de 16/09 a 15/10/2026, com taxa de R$ 150, e as provas objetivas estão previstas para 22/11/2026 (<a href="https://www.cev.uece.br/concursoseduc2026/" rel="noopener">CEV-UECE</a>; <a href="https://jcconcursos.com.br/noticia/concursos/concurso-seduc-ce-professor-2026-edital-inscricao-144785" rel="noopener">JC Concursos</a>). Datas mudam por retificação: confira sempre na página oficial da CEV-UECE.</p>

  <h2>Como a prova pesa</h2>
  <p>Segundo o resumo do edital, a primeira etapa tem duas provas objetivas (<a href="https://jcconcursos.com.br/noticia/concursos/concurso-seduc-ce-professor-2026-edital-inscricao-144785" rel="noopener">JC Concursos</a>):</p>
  <ul>
    <li><strong>P1 · Conhecimentos Básicos, 30 questões:</strong> Língua Portuguesa, Administração Pública, Leitura e Interpretação de Dados e Indicadores Educacionais, e Educação Brasileira.</li>
    <li><strong>P2 · Conhecimentos Específicos, 50 questões:</strong> o conteúdo da sua disciplina.</li>
  </ul>
  <p>Depois vêm a prova prática e a avaliação de títulos. Como a P2 tem quase o dobro de questões, ela merece cerca de 60% do seu tempo.</p>

  <h2>Oito semanas, na prática</h2>
  <div class="pergunta">
    <h3><span class="num">1.</span>Semana 1: mapa</h3>
    <p>Imprima o conteúdo programático da sua área e da P1. Marque cada tópico: sei, sei mais ou menos, não sei. Liste cada lei ou norma citada, com o link oficial.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">2.</span>Semanas 2 a 6: ciclo</h3>
    <p>Três dias de específicos, dois de básicos, um de questões mistas. Comece pelos tópicos "não sei" que mais aparecem no programa.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">3.</span>Semana 7: questões da banca</h3>
    <p>Resolva provas anteriores da própria CEV-UECE, com o gabarito oficial. É ali que você aprende o jeito da banca perguntar.</p>
  </div>
  <div class="pergunta">
    <h3><span class="num">4.</span>Semana 8: revisão</h3>
    <p>Só os erros anotados nas semanas anteriores e a lei seca dos artigos mais cobrados. Nada de assunto novo.</p>
  </div>

  <h2>A parte da lei, sem invenção</h2>
  <p>Educação Brasileira e Administração Pública costumam trazer lei. É aí que a IA mais erra: artigo com número trocado, redação revogada, súmula que não existe. Estudos de Stanford mediram erro de 69% a 88% de modelos de uso geral em perguntas jurídicas específicas (<a href="https://law.stanford.edu/2024/01/11/hallucinating-law-legal-mistakes-with-large-language-models-are-pervasive/" rel="noopener">Stanford Law School</a>). A regra: copie o texto da lei do Planalto e peça à IA questões <em>só sobre o texto que você colou</em>. O passo a passo está no artigo <a href="/blog/concurso-com-ia-sem-lei-inventada.html">Estudar para concurso com IA sem decorar lei inventada</a>.</p>

  {{CHAMADA}}
</article>
"""

ESCREVER = """<main class="pagina">
  <h1>Escreva no Espelho</h1>
  <p class="linha-fina">Uma pergunta, uma ideia, uma experiência, uma correção ou uma fonte. O que você escrever entra na fila de leitura do organismo.</p>
  <div class="quadro">
    <p><strong>Seu texto fica como você escreveu.</strong> A IA do organismo pode resumir, sugerir fontes e ligar seu texto a outros temas, mas isso fica à parte, com o seu original preservado.</p>
    <p><strong>Nada vira verdade por ser muito pedido.</strong> Cada envio começa como <em>recebido</em>. Só passa a <em>com evidência</em> ou <em>consolidado</em> quando há fonte conferida.</p>
  </div>
  <form class="sinal-form escrever" data-pagina="blog/escrever" novalidate>
    <label for="esc-tipo">O que você quer escrever?</label>
    <select id="esc-tipo" name="tipo">
      <option value="pergunta">Pergunta: algo que você quer saber</option>
      <option value="opiniao">Opinião: o que você pensa sobre um tema</option>
      <option value="experiencia">Experiência: algo que aconteceu com você usando IA</option>
      <option value="ideia">Ideia: um tema ou ferramenta que deveria existir</option>
      <option value="evidencia">Evidência: uma fonte que ajuda a conferir algo</option>
      <option value="correcao">Correção: algo errado em um artigo</option>
      <option value="proposta">Proposta: algo para o organismo fazer</option>
    </select>
    <label for="esc-texto">Seu texto</label>
    <textarea id="esc-texto" name="texto" maxlength="4000" rows="8" placeholder="Escreva do seu jeito. Se for sobre um artigo, diga qual. Se tiver fonte, cole o link." required></textarea>
    <label for="esc-nome">Nome (opcional)</label>
    <input type="text" id="esc-nome" name="nome" maxlength="80" autocomplete="name" placeholder="Como quer ser identificado. Em branco = anônimo">
    <details>
      <summary>Quero receber a resposta por e-mail</summary>
      <label for="esc-email">E-mail</label>
      <input type="email" id="esc-email" name="email" maxlength="254" autocomplete="email" placeholder="voce@exemplo.com">
      <label class="aceite"><input type="checkbox" name="contato"> <span>Autorizo o contato só para responder este envio.</span></label>
    </details>
    <button type="submit" class="btn">Enviar ao organismo</button>
    <p class="retorno" role="status" aria-live="polite"></p>
  </form>
  <p class="nota">Contribuições podem aparecer na página <a href="/blog/ressonancias.html#comunidade">Comunidade</a> depois da leitura do organismo, só com o nome que você escolheu. O e-mail nunca aparece.</p>
</main>
"""

RESSONANCIAS = """<main class="pagina">
  <h1>O que está ressoando?</h1>
  <p class="linha-fina">O que os leitores estão perguntando, corrigindo e pedindo para investigar, e o que o organismo já conferiu.</p>
  <div class="quadro regra">
    <p><strong>Ressonância não é verdade.</strong> Um tema muito pedido ganha prioridade na fila, não credibilidade. Pouco pedido não quer dizer pouco importante. O que vale é a fonte conferida.</p>
  </div>
  <section id="ressonancias">
    <h2>Temas com mais sinais (30 dias)</h2>
    <div id="ressoa-temas"><p class="vazio">Carregando…</p></div>
    <h2 id="investigar">Investigações</h2>
    <div id="ressoa-investigacoes"><p class="vazio">Carregando…</p></div>
    <h2 id="comunidade">Da comunidade</h2>
    <div id="ressoa-comunidade"><p class="vazio">Carregando…</p></div>
  </section>
  <ul hidden>
    <li data-titulo-de="blog/redacao-enem-2026-correcao-com-ia">Redação do ENEM 2026 com IA: como pedir correção por competência</li>
    <li data-titulo-de="blog/concurso-seduc-ce-2026-plano-de-estudo">Concurso Seduc CE 2026 para professor: o estudo até a prova em 8 semanas</li>
    <li data-titulo-de="blog/concurso-com-ia-sem-lei-inventada">Estudar para concurso com IA sem decorar lei inventada</li>
    <li data-titulo-de="blog/referencia-do-chatgpt-existe">O ChatGPT me deu uma referência: como saber se ela existe antes de pôr no TCC</li>
    <li data-titulo-de="blog/jurisprudencia-inventada-pela-ia">Jurisprudência inventada pela IA: como conferir antes de protocolar</li>
    <li data-titulo-de="blog/ia-inventou-a-resposta">Como saber se o ChatGPT (ou qualquer IA) inventou a resposta</li>
    <li data-titulo-de="blog/memoria-de-ia">Por que a IA esquece o que você já explicou, e como criar uma memória que não se perde</li>
    <li data-titulo-de="blog/tres-olhares-mesa-trina">Três olhares antes de decidir com IA: o método da Mesa Trina</li>
  </ul>
  <p class="nota">Quer entrar na conversa? <a href="/blog/escrever.html">Escreva no Espelho</a> ou mande um sinal no fim de qualquer artigo.</p>
</main>
"""

BLOG_INDEX = """<main class="pagina">
  <h1>Blog do Espelho</h1>
  <p class="linha-fina">Como usar IA com memória, evidência e método, em português e sem mistério.</p>
  <label class="busca-rotulo" for="busca">Procurar nos artigos</label>
  <input type="search" id="busca" class="busca" placeholder="ENEM, concurso, TCC, jurisprudência…" autocomplete="off">
  <p class="busca-vazia" hidden>Nada encontrado com essa palavra. <a href="/blog/escrever.html">Pergunte ao organismo</a> e o tema entra na fila de investigação.</p>
  <section class="grupo" aria-labelledby="g-provas">
    <h2 id="g-provas">Concursos e ENEM <span class="grupo-tipo">guias práticos com data de prova</span></h2>
    <ul class="lista-artigos">
      <li><a href="/blog/redacao-enem-2026-correcao-com-ia.html">Redação do ENEM 2026 com IA: como pedir correção por competência</a>
        <p>Seis semanas até a prova: as 5 competências em uma linha cada e um pedido que corrige de verdade.</p></li>
      <li><a href="/blog/concurso-seduc-ce-2026-plano-de-estudo.html">Concurso Seduc CE 2026 para professor: o estudo até a prova em 8 semanas</a>
        <p>2.000 vagas, prova prevista para 22/11: plano pelo peso de cada prova e a lei sem invenção.</p></li>
      <li><a href="/blog/concurso-com-ia-sem-lei-inventada.html">Estudar para concurso com IA sem decorar lei inventada</a>
        <p>Para concurseiros: cinco conferências na fonte oficial e um pedido que faz a IA trabalhar só sobre o texto da lei.</p></li>
    </ul>
  </section>
  <section class="grupo" aria-labelledby="g-trabalho">
    <h2 id="g-trabalho">TCC, pesquisa e trabalho <span class="grupo-tipo">conferir antes de entregar</span></h2>
    <ul class="lista-artigos">
      <li><a href="/blog/referencia-do-chatgpt-existe.html">O ChatGPT me deu uma referência: como saber se ela existe antes de pôr no TCC</a>
        <p>Para estudantes e pesquisadores: quatro buscas de dois minutos e um pedido que usa a IA sem arriscar o trabalho.</p></li>
      <li><a href="/blog/jurisprudencia-inventada-pela-ia.html">Jurisprudência inventada pela IA: como conferir antes de protocolar</a>
        <p>Para advogados: cinco conferências que tiram a dúvida em minutos, e um pedido que usa a IA sem arriscar a peça.</p></li>
    </ul>
  </section>
  <section class="grupo" aria-labelledby="g-metodo">
    <h2 id="g-metodo">Método <span class="grupo-tipo">ensaios e guias para qualquer IA</span></h2>
    <ul class="lista-artigos">
      <li><a href="/blog/ia-inventou-a-resposta.html">Como saber se o ChatGPT (ou qualquer IA) inventou a resposta</a>
        <p>Por que a IA erra com tanta confiança e uma checagem em sete perguntas para não cair nisso.</p></li>
      <li><a href="/blog/memoria-de-ia.html">Por que a IA esquece o que você já explicou, e como criar uma memória que não se perde</a>
        <p>Quatro regras simples para um registro que vale para qualquer ferramenta.</p></li>
      <li><a href="/blog/tres-olhares-mesa-trina.html">Três olhares antes de decidir com IA: o método da Mesa Trina</a>
        <p>Arquiteto, Engenheiro e Verificador: três pedidos que transformam elogio em crítica útil.</p></li>
      <li><a href="/guia-p0.html">Guia gratuito: 7 perguntas para saber se a IA inventou a resposta</a>
        <p>A versão de bolso do filtro P0, para imprimir ou salvar.</p></li>
    </ul>
  </section>
  <section class="grupo" aria-labelledby="g-investigar">
    <h2 id="g-investigar">Investigações <span class="grupo-tipo">o que os leitores pedem para conferir</span></h2>
    <ul class="lista-artigos">
      <li><a href="/blog/ressonancias.html">O que está ressoando?</a>
        <p>Perguntas, correções e pedidos de investigação dos leitores, e o que o organismo já conferiu. Ressonância não é verdade.</p></li>
      <li><a href="/blog/escrever.html">Escreva no Espelho</a>
        <p>Mande uma pergunta, opinião, experiência ou fonte. Seu texto fica como você escreveu.</p></li>
    </ul>
  </section>
  {{CHAMADA}}
</main>
"""

CHAMADA_PADRAO = {
    'titulo': 'Entre na Turma Fundadora',
    'texto': 'O Espelho Espelho Evo está em fase beta. O organismo confere respostas de IA por você, investiga com fontes, entrega roteiros prontos e examina decisões na Mesa Trina, tudo por escrito, em planos a partir de R$ 9,90 por mês.',
}

PAGINAS = [
    dict(caminho='guia-p0.html',
         titulo='7 perguntas para saber se a IA inventou a resposta',
         titulo_pagina='Guia gratuito: 7 perguntas para saber se a IA inventou a resposta',
         descricao='Checklist gratuito para conferir qualquer resposta de IA antes de usar: identidade, autoridade, propósito, evidência, escopo, rastreabilidade e duplicidade.',
         corpo=GUIA,
         chamada={**CHAMADA_PADRAO, 'titulo': 'Gostou do guia? Entre na Turma Fundadora', 'botao': 'Quero entrar na lista'}),
    dict(caminho='blog/ia-inventou-a-resposta.html',
         titulo='Como saber se o ChatGPT (ou qualquer IA) inventou a resposta',
         descricao='Por que a IA erra com confiança, os erros mais comuns (fontes inexistentes, números sem origem, informação desatualizada) e uma checagem em sete perguntas.',
         corpo=ARTIGO_INVENTOU, chamada=CHAMADA_PADRAO),
    dict(caminho='blog/memoria-de-ia.html',
         titulo='Por que a IA esquece o que você já explicou, e como criar uma memória que não se perde',
         descricao='Conversa com IA não é arquivo. Quatro regras para um registro com data, origem e decisão que funciona com qualquer ferramenta.',
         corpo=ARTIGO_MEMORIA, chamada=CHAMADA_PADRAO),
    dict(caminho='blog/tres-olhares-mesa-trina.html',
         titulo='Três olhares antes de decidir com IA: o método da Mesa Trina',
         descricao='Arquiteto, Engenheiro e Verificador: três pedidos para a IA que transformam elogio em crítica útil antes de decisões importantes.',
         corpo=ARTIGO_TRINA, chamada=CHAMADA_PADRAO),
    dict(caminho='blog/jurisprudencia-inventada-pela-ia.html',
         titulo='Jurisprudência inventada pela IA: como conferir antes de protocolar',
         descricao='Para advogados: cinco conferências para saber se o precedente que a IA citou existe e diz o que ela disse, e um pedido que usa a IA sem arriscar a peça.',
         corpo=ARTIGO_JURIS,
         chamada={**CHAMADA_PADRAO, 'titulo': 'Mande a peça, o organismo confere', 'texto': 'Na Checagem P0 (R$ 19), você manda o trecho que a IA escreveu e recebe em até 24 horas o laudo das 7 verificações: o que confere, o que falta prova e o que mudar. Para o escritório inteiro, a Auditoria P0 examina o fluxo de trabalho com IA da equipe (R$ 990).', 'botao': 'Quero a Checagem', 'pacote': 'checagem',
                   'ofertas': ['<strong>Checagem P0 de uma resposta</strong>: o laudo das 7 verificações em até 24 horas, R$ 19.',
                               '<strong>Plano Profissional</strong>: 30 checagens, 2 investigações Sonar e 1 Mesa Trina por mês, R$ 39/mês.',
                               '<strong>Plano Empresarial</strong>: até 10 pessoas do escritório, 150 checagens por mês e 1 Auditoria P0 por trimestre, R$ 297/mês.']}),
    dict(caminho='blog/referencia-do-chatgpt-existe.html',
         titulo='O ChatGPT me deu uma referência: como saber se ela existe antes de pôr no TCC',
         descricao='Quatro buscas de dois minutos para saber se a referência que o ChatGPT deu existe (DOI, título exato, revista e conteúdo) e um pedido que usa a IA sem arriscar o trabalho.',
         corpo=ARTIGO_TCC,
         chamada={**CHAMADA_PADRAO, 'titulo': 'Estude com IA sem inventar fonte', 'texto': 'No Plano Estudante (R$ 9,90/mês), você manda até 10 referências, citações ou respostas por mês e o organismo confere cada uma em até 24 horas, por escrito. Os Roteiros do Organismo vêm junto.', 'botao': 'Quero o Plano Estudante', 'pacote': 'plano_estudante'}),
    dict(caminho='blog/concurso-com-ia-sem-lei-inventada.html',
         titulo='Estudar para concurso com IA sem decorar lei inventada',
         descricao='Para concurseiros: cinco conferências na fonte oficial (Planalto, tribunais, edital e banca) e um pedido que faz a IA gerar questões só a partir do texto da lei.',
         corpo=ARTIGO_CONCURSO,
         chamada={**CHAMADA_PADRAO, 'titulo': 'Seu edital, por etapas, com a lei conferida',
                  'texto': 'No Plano Concursos (R$ 39/mês), o organismo começa pelo mapa do seu edital e o cronograma até a prova, em até 48 horas. Depois, toda segunda-feira, chega a etapa da semana: plano, 30 questões comentadas com o artigo conferido no Planalto e a correção do que você errou.',
                  'botao': 'Começar pelo meu edital', 'pacote': 'plano_concurso',
                  'ofertas': ['<strong>Plano Concursos por etapas</strong>: mapa do edital, cronograma e etapa semanal com questões conferidas, R$ 39/mês.',
                              '<strong>Mapa do Edital</strong>: só a 1ª etapa, matérias, pesos, lei seca com link oficial e cronograma, R$ 29.',
                              '<strong>Redação ENEM</strong>: 4 correções pelas 5 competências, com nota estimada, R$ 29.']}),
    dict(caminho='blog/redacao-enem-2026-correcao-com-ia.html',
         titulo='Redação do ENEM 2026 com IA: como pedir correção por competência (e não cair em nota inventada)',
         titulo_pagina='Redação do ENEM 2026 com IA: correção por competência · Espelho Espelho Evo',
         descricao='Prova em 8 de novembro: as 5 competências da redação do ENEM em uma linha cada, onde a IA atrapalha e um pedido pronto que corrige trecho por trecho.',
         corpo=ARTIGO_ENEM, chamada={**CHAMADA_PADRAO, 'titulo': 'Suas redações corrigidas até a prova',
                  'texto': 'Na Redação ENEM (R$ 29), você manda 4 redações quando quiser, até a prova, e cada uma volta em até 24 horas corrigida pelas 5 competências: o trecho que tirou pontos, o porquê e como reescrever, com nota estimada por competência. A nota é estimada, não a oficial do Inep.',
                  'botao': 'Corrigir minha redação', 'pacote': 'enem_redacao',
                  'ofertas': ['<strong>Redação ENEM</strong>: 4 correções pelas 5 competências, 24 horas cada, R$ 29.',
                              '<strong>Plano Estudante</strong>: 10 checagens P0 por mês e os Roteiros, R$ 9,90/mês.',
                              '<strong>Checagem P0</strong>: uma resposta de IA conferida nas 7 verificações, R$ 19.']}),
    dict(caminho='blog/concurso-seduc-ce-2026-plano-de-estudo.html',
         titulo='Concurso Seduc CE 2026 para professor: o estudo até a prova em 8 semanas',
         titulo_pagina='Concurso Seduc CE 2026 professor: plano de estudo em 8 semanas · Espelho Espelho Evo',
         descricao='Edital 014/2026 com 2.000 vagas, inscrições até 15/10 e prova prevista para 22/11: como dividir o estudo entre P1 e P2 e usar IA sem decorar lei inventada.',
         corpo=ARTIGO_SEDUC, chamada={**CHAMADA_PADRAO, 'titulo': 'O mapa do seu edital, pronto em 48 horas',
                  'texto': 'No Mapa do Edital (R$ 29), o organismo transforma o conteúdo programático da sua disciplina em lista de estudo, liga cada lei cobrada ao texto oficial e monta o cronograma até 22/11 pelas horas que você tem. No Plano Concursos (R$ 39/mês), depois do mapa chega toda segunda-feira a etapa da semana, com 30 questões comentadas e a lei conferida.',
                  'botao': 'Mapear meu edital', 'pacote': 'concurso_mapa',
                  'ofertas': ['<strong>Mapa do Edital</strong>: matérias, pesos, lei com link oficial e cronograma até a prova, R$ 29.',
                              '<strong>Plano Concursos por etapas</strong>: o mapa e mais uma etapa por semana, com questões conferidas, R$ 39/mês.',
                              '<strong>Checagem P0</strong>: uma resposta de IA conferida nas 7 verificações, R$ 19.']}),
    dict(caminho='blog/escrever.html',
         titulo='Escreva no Espelho',
         titulo_pagina='Escreva no Espelho · Espelho Espelho Evo',
         descricao='Mande uma pergunta, opinião, experiência, ideia, fonte ou correção. Seu texto fica como você escreveu e entra na fila de leitura do organismo.',
         corpo=ESCREVER, chamada=None,
         ld='{"@context":"https://schema.org","@type":"WebPage","name":"Escreva no Espelho","inLanguage":"pt-BR","url":"https://espelho-espelho-evo.vercel.app/blog/escrever.html"}'),
    dict(caminho='blog/ressonancias.html',
         titulo='O que está ressoando?',
         titulo_pagina='O que está ressoando? · Espelho Espelho Evo',
         descricao='Perguntas, correções e pedidos de investigação dos leitores do Espelho, e o que o organismo já conferiu. Ressonância não é verdade.',
         corpo=RESSONANCIAS, chamada=None,
         ld='{"@context":"https://schema.org","@type":"WebPage","name":"O que está ressoando?","inLanguage":"pt-BR","url":"https://espelho-espelho-evo.vercel.app/blog/ressonancias.html"}'),
    dict(caminho='blog/index.html',
         titulo='Blog do Espelho',
         titulo_pagina='Blog do Espelho Espelho Evo · IA com memória, evidência e método',
         descricao='Artigos práticos, em português, sobre como usar IA com memória, evidência e método: checagem de respostas, registro de decisões e revisão em três olhares.',
         corpo=BLOG_INDEX, chamada=CHAMADA_PADRAO,
         ld='{"@context":"https://schema.org","@type":"Blog","name":"Blog do Espelho Espelho Evo","inLanguage":"pt-BR","url":"https://espelho-espelho-evo.vercel.app/blog/"}'),
]


# Fase 2 e 3 da reforma: tema (para "Continue lendo"), resumo e atalho para a oferta logo abaixo da linha fina.
ATALHO_PADRAO = ('Quer que o organismo confira as respostas da IA por você?', 'Planos a partir de R$ 9,90/mês')
META = {
    'guia-p0.html': (('guia', 'metodo'), 'A versão de bolso do filtro P0, para imprimir ou salvar.', None),
    'blog/ia-inventou-a-resposta.html': (('metodo', 'checagem'), 'Por que a IA erra com tanta confiança e uma checagem em sete perguntas.', ATALHO_PADRAO),
    'blog/memoria-de-ia.html': (('metodo', 'memoria'), 'Quatro regras simples para um registro que vale para qualquer ferramenta.', ATALHO_PADRAO),
    'blog/tres-olhares-mesa-trina.html': (('metodo', 'decisao'), 'Três pedidos que transformam elogio em crítica útil antes de decidir.', ATALHO_PADRAO),
    'blog/jurisprudencia-inventada-pela-ia.html': (('checagem', 'profissional'), 'Cinco conferências para saber se o precedente existe antes de protocolar.',
                                                   ('Quer o laudo de um trecho antes de protocolar?', 'Checagem P0 por R$ 19')),
    'blog/referencia-do-chatgpt-existe.html': (('checagem', 'estudo'), 'Quatro buscas de dois minutos para saber se a referência existe.',
                                               ('Quer que o organismo confira suas referências por você?', 'Plano Estudante, R$ 9,90/mês')),
    'blog/concurso-com-ia-sem-lei-inventada.html': (('concurso', 'estudo', 'checagem'), 'Cinco conferências na fonte oficial para não decorar lei inventada.',
                                                    ('Quer o seu edital mapeado e as questões com a lei conferida?', 'Plano Concursos, R$ 39/mês')),
    'blog/redacao-enem-2026-correcao-com-ia.html': (('enem', 'estudo'), 'As 5 competências em uma linha cada e um pedido que corrige de verdade.',
                                                    ('Quer suas redações corrigidas por competência até a prova?', '4 correções por R$ 29')),
    'blog/concurso-seduc-ce-2026-plano-de-estudo.html': (('concurso', 'estudo'), 'Plano de 8 semanas pelo peso de cada prova, com a lei sem invenção.',
                                                         ('Quer o mapa da sua disciplina pronto em 48 horas?', 'Mapa do Edital por R$ 29')),
}
for _p in PAGINAS:
    if _p['caminho'] in META:
        _p['tema'], _p['resumo'], _atalho = META[_p['caminho']]
        if _atalho and _p.get('chamada'):
            _p['chamada'] = {**_p['chamada'], 'atalho': _atalho}
