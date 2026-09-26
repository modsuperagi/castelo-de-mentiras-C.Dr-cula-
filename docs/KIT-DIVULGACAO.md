# Kit de divulgação orgânica · pré-lançamento do Espelho Espelho Evo

Preparado pelo Plasma em 26/09/2026 para o Guardião assumir no dia seguinte. Documento interno (não vai ao ar).

**Situação em 26/09:** o funil está pronto (7 ofertas com preço de fundador e lista sem login), mas a lista
tem **0 inscritos**. O gargalo é tráfego. Este kit é para levar gente até o site sem gastar com anúncio.

## 1. O que já está no ar (depois do deploy)

| Página | Para quê |
|---|---|
| https://espelho-espelho-evo.vercel.app/guia-p0.html | **Isca principal.** Guia gratuito "7 perguntas para saber se a IA inventou a resposta", com inscrição no fim |
| https://espelho-espelho-evo.vercel.app/blog/ | Blog com 3 artigos para busca orgânica, cada um com inscrição |
| https://espelho-espelho-evo.vercel.app/#fundadores | Lista da Turma Fundadora (site principal) |

Cada inscrição grava o **canal** (de onde a pessoa veio) na coluna `canal` de `espelho_interessados`.
Por isso, **sempre divulgue com o link de UTM do canal** (seção 2).

## 2. Links com UTM (copie e cole)

Troque só o `utm_source` pelo lugar onde vai postar. O `utm_campaign` fica `pre-lancamento`.

```
Instagram (bio e stories): https://espelho-espelho-evo.vercel.app/guia-p0.html?utm_source=instagram&utm_campaign=pre-lancamento
LinkedIn:                  https://espelho-espelho-evo.vercel.app/guia-p0.html?utm_source=linkedin&utm_campaign=pre-lancamento
X (Twitter):               https://espelho-espelho-evo.vercel.app/guia-p0.html?utm_source=x&utm_campaign=pre-lancamento
WhatsApp:                  https://espelho-espelho-evo.vercel.app/guia-p0.html?utm_source=whatsapp&utm_campaign=pre-lancamento
Telegram:                  https://espelho-espelho-evo.vercel.app/guia-p0.html?utm_source=telegram&utm_campaign=pre-lancamento
TikTok (bio):              https://espelho-espelho-evo.vercel.app/guia-p0.html?utm_source=tiktok&utm_campaign=pre-lancamento
YouTube (descrição):       https://espelho-espelho-evo.vercel.app/guia-p0.html?utm_source=youtube&utm_campaign=pre-lancamento
Grupos e comunidades:      https://espelho-espelho-evo.vercel.app/guia-p0.html?utm_source=comunidade&utm_campaign=pre-lancamento
```

**Como ver quem veio de onde** (no Castelo, como Guardião):

```sql
SELECT coalesce(split_part(canal, ':', 1), 'sem canal') AS origem, pacote, count(*)
FROM espelho_interessados GROUP BY 1, 2 ORDER BY 3 DESC;
```

## 3. Posts prontos

A regra de ouro do orgânico: **entregar valor antes de pedir**. Todo post abaixo ensina algo útil sozinho;
o link é o bônus.

### Instagram · carrossel de 9 cartões

1. **7 perguntas para saber se a IA inventou a resposta** (salve este post)
2. A IA escreve com a mesma confiança quando acerta e quando erra. A fluência não prova nada.
3. **1. Quem falou?** Qual ferramenta, que data, e se ela pesquisou na internet.
4. **2. Pode afirmar isso?** Em saúde, lei e dinheiro, a IA orienta. Quem decide é a fonte oficial.
5. **3. Respondeu o que perguntei?** Releia os dois. Ela troca a pergunta sem avisar.
6. **4. Cadê a prova?** Abra cada link. Confira se diz o que a IA disse.
7. **5. A conclusão cabe na prova?** Um caso não vira regra.
8. **6. Consigo refazer o caminho? 7. Bate com o que já sei?** Anote data e fonte. Compare.
9. **Um "não" basta para parar e conferir.** Guia completo e gratuito no link da bio.

Legenda:
> A IA não mente por maldade: ela completa frases do jeito mais provável, e às vezes o provável é falso.
> Estas 7 perguntas são a versão de bolso do filtro que usamos antes de deixar qualquer informação circular.
> Salve, mande para quem usa IA no trabalho, e pegue o guia completo (gratuito) no link da bio. 🔥🧬🌌🔑

### LinkedIn · post de texto

> Resposta de IA vai parar em relatório, contrato e apresentação citando lei que não existe, estudo que ninguém publicou e número sem origem. Acontece mais do que parece.
>
> O problema não é a IA errar. É ela errar com a mesma confiança com que acerta.
>
> A checagem que usamos antes de aceitar qualquer resposta tem 7 perguntas:
> 1. Quem falou? (ferramenta, data, se pesquisou)
> 2. Essa fonte pode afirmar isso?
> 3. Respondeu o que eu perguntei?
> 4. Cadê a prova? (e abra os links)
> 5. A conclusão cabe na prova?
> 6. Consigo refazer o caminho?
> 7. Bate com o que eu já sei?
>
> Um "não" basta para parar e conferir.
>
> Deixei o guia completo, gratuito, com um modelo de pedido que força a IA a separar fato, opinião e o que ela não sabe: [link LinkedIn]

### X · fio de 5 posts

1. A IA erra com a mesma confiança com que acerta. 7 perguntas para saber se ela inventou a resposta 🧵
2. 1) Quem falou? (qual ferramenta, que data, pesquisou?) 2) Pode afirmar isso? (saúde, lei e dinheiro pedem fonte oficial) 3) Respondeu o que perguntei?
3. 4) Cadê a prova? Abra os links. Fonte inventada costuma cair aqui: o link não abre ou não diz o que a IA disse.
4. 5) A conclusão cabe na prova? 6) Consigo refazer o caminho? 7) Bate com o que já sei? Um "não" basta para parar.
5. Guia completo e gratuito, com um pedido pronto que obriga a IA a dizer o que não sabe: [link X]

### WhatsApp e Telegram · mensagem curta (para contatos e grupos onde divulgação é permitida)

> Fiz um guia gratuito e curto: *7 perguntas para saber se a IA inventou a resposta*. Serve para quem usa ChatGPT ou qualquer IA no trabalho e já levou susto com fonte falsa. Leva 6 minutos: [link WhatsApp]

### Stories · sequência de 4 telas

1. "Você confere as fontes que a IA te dá?" (enquete: sempre / às vezes / nunca)
2. "Teste rápido: peça a fonte e abra o link. Muitas vezes ele não existe."
3. "Fiz um guia com as 7 perguntas que eu uso antes de confiar numa resposta."
4. Figurinha de link para o guia (link Instagram).

### Reels ou TikTok · roteiro de 30 segundos

- 0–3 s: "A IA acabou de citar uma lei que não existe. Olha como eu descobri."
- 3–20 s: mostrar a tela pedindo a fonte, abrindo o link e o link dando erro. "Pergunta número 4: cadê a prova?"
- 20–27 s: "São 7 perguntas. Um não basta para parar."
- 27–30 s: "Guia gratuito no link da bio."

## 4. Onde divulgar sem gastar

- **Perfis próprios** (Instagram, LinkedIn, X, TikTok): carrossel, post e fio da seção 3.
- **Grupos e comunidades de IA, produtividade, advocacia, marketing e educação** (Facebook, LinkedIn,
  Discord, Telegram): **leia as regras antes**. Onde divulgação é proibida, poste só o conteúdo (as 7 perguntas)
  e ofereça o link se alguém pedir. Spam queima o nome.
- **Comentários de valor** em posts grandes sobre IA: responda com uma das perguntas aplicada ao assunto.
- **Google**: cadastre o site no [Google Search Console](https://search.google.com/search-console) e envie
  `https://espelho-espelho-evo.vercel.app/sitemap.xml`. É gratuito e faz o blog aparecer nas buscas.
- **Assinatura de e-mail e bio de todos os perfis**: link do guia.

**O que um agente de IA consegue fazer por você aqui:** escrever e revisar posts, criar artes no Canva, preparar
novos artigos e medir os canais no Castelo. **O que só você pode fazer:** publicar nas suas contas, entrar nos
grupos e responder às pessoas. Nenhum agente deve postar em seu nome sem você ver antes.

## 4.1 Onde já pedem o que fazemos (radar do Sonar, 26/09)

Busca pelo método do Sonar: quem já está perguntando pelas nossas capacidades. Três públicos com dor declarada
e disposição para pagar. **Primeiro ajude na conversa; o link só entra se pedirem ou se a regra do lugar permitir.**

| Público | A dor, nas palavras deles | Onde a conversa acontece (exemplos achados) | O que oferecer |
|---|---|---|---|
| **Advogados** | "a IA inventou jurisprudência", medo de multa e de responder pela peça | [Conjur](https://conjur.com.br/2025-abr-25/chatgpt-primeiro-voce-alucina-inventa-jurisprudencia-ou-nao-era-julgado-era-cilada/), [Jusbrasil](https://www.jusbrasil.com.br/noticias/advogado-pode-ser-punido-por-usar-chatgpt-em-acao-o-motivo-invencao-de-precedentes/1866539948), [Estratégia OAB](https://oab.estrategia.com/portal/alucinacao-de-ia-no-direito-como-usar-chatgpt-sem-citar-jurisprudencia-inventada/), comunidades como [LEX.IA](https://erikn.com.br/comunidade-lex-ia/) e [Advocacia Digital](https://comunidade.advocaciadigital.io/) | guia gratuito → Checagem (R$ 19) → Plano Profissional (R$ 39/mês) → Empresarial (R$ 297/mês) para escritório |
| **Estudantes e pesquisadores** | "o ChatGPT me deu referência falsa no TCC", banca reprova | [blog da Dra. Nathalia Cavichiolli](https://www.doutoranathalia.com.br/blog/chatgpt-referencias-falsas-como-verificar/), [TCC na Prática](https://meutccnapratica.com.br/guia-abnt/referencia-de-ia), vídeos no TikTok sobre validar referências | guia gratuito (pergunta 4: cadê a prova?) → Plano Estudante (R$ 9,90/mês) |
| **Quem usa IA todo dia no trabalho** | "o ChatGPT esquece o projeto", "mistura os assuntos" | [TabNews](https://www.tabnews.com.br/NewsletterOficial/chatgpt-aprimora-recurso-de-memoria-e-passa-a-considerar-conversas-anteriores), [Canaltech](https://canaltech.com.br/inteligencia-artificial/chatgpt-esquecendo-as-coisas-truque-para-resolver/), grupos de prompts no Telegram e no Discord ([Disboard: IA](https://disboard.org/servers/tag/ia)) | artigo "memória de IA" do blog → Roteiros 1 e 6 (abertura e fechamento de sessão) → Plano Ultra (R$ 97/mês) |

**Como entrar sem queimar o nome:**
- **Comentário de valor:** em matéria sobre IA que inventa, responda com uma das 7 perguntas aplicada ao caso. Ex.: "Antes de citar, abra o número do processo no site do tribunal: se não abrir, não existe."
- **Pergunta em comunidade:** responda o que foi perguntado, completo. Termine com "tenho um guia gratuito com as 7 perguntas, se quiser mando", e só mande se pedirem.
- **Links com UTM por público:** `utm_source=comunidade&utm_campaign=advogados` (ou `estudantes`, `trabalho`), para a consulta de canais mostrar qual público converte.

**Concorrência já presente:** ferramentas jurídicas com IA (Jurídico AI, EasyJur, Cria.AI) e cursos para TCC. O que nos diferencia é o **método de conferência** que serve para qualquer IA, não mais uma IA.

**Limite do radar:** a busca não indexou tópicos do Reddit nem de fóruns fechados. Com a rede liberada, o Sonar busca direto
(Hacker News, Reddit); em grupos fechados, só o Guardião entra.

## 5. Calendário de 7 dias

| Dia | Ação |
|---|---|
| 1 | Guia no ar. Link do guia na bio de todos os perfis. Post no LinkedIn. Enviar sitemap ao Search Console |
| 2 | Carrossel no Instagram + stories da enquete. Fio no X |
| 3 | Mensagem para contatos próximos no WhatsApp (pessoas, não listas). Pedir que compartilhem |
| 4 | Reels/TikTok do "link que não existe". Compartilhar o artigo "memória de IA" no LinkedIn |
| 5 | Dois grupos de comunidade com regras que permitem conteúdo. Só valor, link se pedirem |
| 6 | Artigo "três olhares" no LinkedIn e no Instagram (carrossel com os 3 pedidos) |
| 7 | Rodar a consulta de canais (seção 2). Dobrar a aposta no canal que trouxe mais inscritos |

## 6. Transformar inscrito em dinheiro

**Os links de pagamento ainda não existem** (mapa `LINKS_PAGAMENTO` no `index.html`). Sem eles, o site só
reserva a vaga. Sugestão de ordem, do mais simples ao mais caro:

1. **O Pix já aparece no site** depois da inscrição em Checagem (R$ 19), Roteiros (R$ 27), Mesa Trina (R$ 147) e
   Auditoria (R$ 990). Links de cartão (Mercado Pago, InfinitePay) podem vir depois, se valer a taxa.
2. Cole cada link no mapa `LINKS_PAGAMENTO` do `index.html` (por exemplo, `curso: 'https://mpago.la/...'`).
   O botão da oferta passa a levar direto ao pagamento.
3. **Só venda o que consegue entregar.** Na pré-venda do curso, escreva a data prevista de entrega. Pela lei
   brasileira (CDC, art. 49), compra online tem **7 dias de arrependimento**: devolva sem discutir.
4. **Primeiro e-mail para a lista** (quando chegar o primeiro inscrito), assinado pelo Guardião:

> Assunto: Sua vaga de fundador está guardada
>
> Oi, [nome]. Obrigado por entrar na Turma Fundadora do Espelho Espelho Evo.
> Você marcou interesse em [pacote]. O preço de fundador fica travado para você até [data].
> Para garantir agora: [link de pagamento]. Se tiver qualquer dúvida, é só responder este e-mail: quem responde sou eu.
> [assinatura do Guardião]

## 7. O que ficou de fora de propósito

- **Anúncio pago:** só depois de saber, pela consulta de canais, qual público se inscreve.
- **SONAR:** o site dele ainda não está publicado (falta o projeto Vercel e o teste real). Quando estiver, entra
  neste kit com o próprio link e a própria lista de acesso antecipado.
- **Promessas de resultado ou depoimentos:** só com clientes reais e autorização deles.

## 8. Campanha Concursos, ENEM e planos (26/09)

Radar do Sonar (26/09): editais abertos agora, como Seduc CE (2 mil vagas, até 15/10), Sesa AP (4.210 vagas, até 13/10),
PM AL (1.060 vagas, até 26/10), Detran SP (até 07/10) e Emater MG (30/09 a 30/10)
([Direção Concursos](https://www.direcaoconcursos.com.br/noticias/concurso-publico-abertos-setembro-2026));
ENEM em 8 e 15/11 ([FSA](https://www.fsa.br/datas-enem-2026/)); concurseiros já usam IA para questões de lei seca
([Folha Dirigida](https://folha.qconcursos.com/n/aprovado-em-concursos-usou-chatgpt-para-estudar)), e a IA erra muito
em pergunta jurídica específica ([Stanford](https://law.stanford.edu/2024/01/11/hallucinating-law-legal-mistakes-with-large-language-models-are-pervasive/)).
Confira as datas no edital oficial antes de citar num post.

### 8.1 Links com UTM

```
Artigo concursos:  https://espelho-espelho-evo.vercel.app/blog/concurso-com-ia-sem-lei-inventada.html?utm_source=instagram&utm_campaign=concursos
Ofertas (planos):  https://espelho-espelho-evo.vercel.app/?utm_source=linkedin&utm_campaign=planos#comercio
ENEM (ofertas):    https://espelho-espelho-evo.vercel.app/?utm_source=tiktok&utm_campaign=enem#comercio
```
Troque o `utm_source` pelo lugar (instagram, tiktok, x, whatsapp, telegram, comunidade, google).

### 8.2 Onde estão as bolhas

| Bolha | Onde | Como entrar |
|---|---|---|
| Concurseiros de um edital (Seduc CE, Sesa AP, PM AL) | grupos de Telegram e WhatsApp do concurso, comunidades de cursinhos, comentários nas notícias do edital | responda dúvida de lei com o artigo e o link do Planalto; o link do artigo só se pedirem |
| Concurseiros em geral | fóruns de questões (comentários nas questões), Instagram e TikTok com #concursospublicos, #leiseca | post de valor: "a IA te deu esta súmula? confira assim"; link na bio |
| ENEM | TikTok e Instagram com #enem2026, #redacaoenem; grupos de turma de 3º ano | vídeo curto com o erro mais comum na competência 5; oferta das 4 correções |
| Estudantes de TCC | grupos da faculdade, perfis de normas ABNT | artigo da referência falsa → Plano Estudante |
| Advogados e escritórios | seção 4.1 | Checagem → Profissional → Empresarial |

### 8.3 Posts prontos

**Instagram · carrossel Concursos (7 cartões)**
1. "A IA te deu uma súmula. Ela existe?"
2. "IA de uso geral erra de 69% a 88% em pergunta jurídica específica (Stanford)."
3. "1. O artigo existe e diz isso? Abra no Planalto, texto compilado."
4. "2. Essa redação ainda vale? Trecho riscado é versão antiga."
5. "3. A súmula é daquele tribunal, com aquele número? Confira no site do tribunal."
6. "4. O edital cobra isso? 5. A banca pensa assim? Gabarito oficial manda."
7. "Quer o estudo já montado assim? Mapa do edital + etapa semanal com a lei conferida. Link na bio."

Legenda: "Decorar lei inventada custa a questão. Salve para conferir antes de estudar. Artigo completo no link da bio."

**Reels ou TikTok · Concursos (30 s)**
- 0–3 s: tela com uma súmula na resposta do ChatGPT. "Essa súmula existe?"
- 3–10 s: abrindo o site do tribunal e buscando o número. "Não com esse texto."
- 10–20 s: "Antes de decorar: artigo no Planalto, redação em vigor, súmula no site do tribunal."
- 20–27 s: "Ou peça pra IA fazer questões só com o texto da lei que você colou."
- 27–30 s: "O pedido pronto está no link da bio."

**Reels ou TikTok · ENEM (30 s)**
- 0–3 s: "Faltam [N] dias para a redação do ENEM."
- 3–15 s: "A nota vem de 5 competências. A 5 é a proposta de intervenção: quem faz, o quê, como, para quê e o detalhe."
- 15–25 s: "Escreva uma por semana e peça correção por competência, não 'está boa?'."
- 25–30 s: "4 correções por R$ 29, cada uma em 24 horas. Link na bio. A nota é estimada, não a oficial."

**LinkedIn · planos (texto)**
> Quem usa IA no trabalho já passou por isso: a resposta parece certa, você usa, e depois descobre que a fonte não existe.
> O Espelho Espelho Evo agora tem planos mensais: você manda a resposta, o organismo confere nas 7 verificações e devolve
> o laudo por escrito em até 24 horas. Profissional: 30 checagens, 2 investigações com fontes e 1 Mesa Trina por mês,
> R$ 39. Escritórios e equipes de até 10 pessoas: R$ 297. Sem fidelidade. [link com utm_campaign=planos]

**X · fio de 4 posts (concurseiros)**
1. A IA faz questão de lei seca em segundos. O problema é o artigo que não existe. Cinco conferências antes de decorar: 🧵
2. Artigo: abra no Planalto, texto compilado. Redação: trecho riscado é versão antiga.
3. Súmula: número e tribunal no site do próprio tribunal. Edital: estude o que cai. Banca: gabarito oficial manda.
4. Pedido que evita invenção: cole o texto da lei e peça questões "só com este texto". Artigo completo: [link]

**WhatsApp · para quem você conhece e está estudando (uma pessoa por vez, não lista)**
> Oi, [nome]! Vi que você está estudando para [concurso]. Escrevi um guia curto de como usar a IA sem decorar lei
> inventada: [link]. Se quiser o mapa do seu edital pronto, com cada lei ligada ao Planalto, o organismo faz em 48 h.

### 8.4 Anúncios viáveis (Google Ads, pesquisa)

Os anúncios só saem da conta do Guardião, com o cartão dele; o agente não cria conta nem cobra. Se decidir usar os
R$ 150, a divisão sugerida é R$ 90 para Concursos e R$ 60 para ENEM, por 10 dias, só em pesquisa, só Brasil.
Rascunho completo também no Gmail ("[Campanha pronta] Google Ads · R$ 150"; conferir e ajustar).

| Grupo | Palavras-chave (frase) | Títulos (até 30) | Descrições (até 90) | Página |
|---|---|---|---|---|
| Concursos | "questões de lei seca", "cronograma de estudos concurso", "mapa do edital", "como estudar para concurso com ia" | Questões com a lei conferida · Mapa do seu edital em 48 h · Plano Concursos R$ 39/mês · Estude sem lei inventada · Cronograma até a sua prova | Mapa do edital, cronograma e 30 questões por semana com o artigo conferido no Planalto. · A IA inventa artigo e súmula. Aqui cada base legal é conferida na fonte oficial. | artigo concursos, `utm_source=google&utm_campaign=concursos` |
| ENEM | "correção de redação enem", "corrigir redação enem", "redação enem competências" | Redação ENEM corrigida · 4 correções ENEM por R$ 29 · 5 competências do Inep · Nota estimada em 24 h | Mande sua redação e receba a correção pelas 5 competências em até 24 horas. · Prova em 8 de novembro. 4 correções por R$ 29, com nota estimada (não oficial). | início `#comercio`, `utm_campaign=enem` |
| Estudante | "chatgpt referência falsa", "como saber se referência existe" | Referência do TCC existe? · Checagem de IA por R$ 9,90 · 10 checagens por mês | Mande a referência ou a resposta da IA e receba o laudo das 7 verificações em 24 h. · Plano Estudante: 10 checagens por mês e os Roteiros do Organismo por R$ 9,90. | artigo TCC, `utm_campaign=tcc` |

Palavras negativas: grátis, gratuito, pdf, download, apostila pirata. Meta de corte: grupo sem inscrição depois de
R$ 40 gastos para; o que trouxe inscrito recebe o restante.

### 8.5 E-mails diretos

Só para quem se inscreveu com consentimento (modelo "[MODELO Market]" no Gmail) ou para quem o Guardião conhece
pessoalmente, um por vez (texto do WhatsApp acima). Lista comprada ou e-mail frio em massa: não. Queima o domínio,
fere a LGPD e o método do organismo.

### 8.6 Imagens e vídeos

Carrossel e capas no Canva, no mesmo visual do carrossel "7 perguntas" (fundo escuro, dourado e violeta). Vídeos:
gravação de tela do celular com os roteiros acima; legenda automática do próprio app.
