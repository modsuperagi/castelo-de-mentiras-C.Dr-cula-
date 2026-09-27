# SONAR · três projetos para estudo e votação

**Pedido do Guardião (27/09/2026):** planejar do início ao fim os três projetos propostos para o SONAR, do Golden, da Sol e da Mariana, para estudo e votação dos 7 núcleos. Depois da votação o Guardião opera o marketing, e só então alguma coisa é construída.

**Quem planejou:** Plasma (Claude), com permissão total do Guardião para as decisões de planejamento.
**Estado:** só planejamento. Nada foi construído, publicado, cobrado ou acionado. As rotinas automáticas do Market e do comando dos bots seguem pausadas.

## Em um minuto

| | Projeto 1 · Golden | Projeto 2 · Sol | Projeto 3 · Mariana |
|---|---|---|---|
| Nome | SONAR Pesquisa Contínua | Castelo como serviço (MCP) | SONAR Pesquisa Contínua Programada |
| O cliente compra | investigações que ficam vivas: pergunta, confronto e continuação quando quiser | investigação com fontes e memória que continua, dentro do Claude, ChatGPT ou Cursor que ele já usa | um tema acompanhado sozinho, no ritmo escolhido; cada entrega amplia a anterior |
| Onde acontece | aplicativo web, tema escuro | na ferramenta de IA do cliente, com um painel de conta | aplicativo web, tema claro, desktop, com aviso por e-mail |
| A Mesa Trina aparece como | A favor · Contra · Lacuna | uma ferramenta que revisa um texto em três leituras | Arquiteto · Engenheiro · Verificador |
| Primeiro público | universitários, pesquisadores e profissionais | engenharia de dados, desenvolvimento, empresas técnicas | universitários e times de tecnologia |
| Maior força | o confronto aparece na tela; é fácil de mostrar | continuidade entre ferramentas, território quase vazio | valor recorrente: trabalha sozinho e cobra todo mês |
| Maior risco | crescer em telas e perder o brilho | público estreito; difícil de mostrar num anúncio | entrega "sem novidade" parecer vazia |
| Entrada mais barata | R$ 9,90 | R$ 0 (memória grátis) | R$ 24,90 |
| Primeira venda | ~4 semanas depois da ordem | ~4 semanas (prova técnica em ~5 dias) | ~4 semanas |

**O motor é o mesmo nos três** (`01-BASE-COMUM.md`). A votação escolhe a **porta de entrada** do SONAR, a forma como o cliente usa o motor. Quem não vencer não se perde: pode virar fase posterior do vencedor. A memória em MCP da Sol pode virar segundo canal, por exemplo, e a pesquisa programada da Mariana pode virar um recurso do projeto do Golden.

## Como ler

| Arquivo | O que tem | Leitura |
|---|---|---|
| `01-BASE-COMUM.md` | o que vale para qualquer vencedor: motor, teste de qualidade, dados e segurança, custos, papéis e o que fica de fora | 10 min |
| `02-PROJETO-1-GOLDEN.md` | Pesquisa Contínua: a investigação que fica viva | 10 min |
| `03-PROJETO-2-SOL.md` | Castelo como serviço: SONAR e memória dentro da IA do cliente | 10 min |
| `04-PROJETO-3-MARIANA.md` | Pesquisa Contínua Programada: o tema acompanhado sozinho | 10 min |
| `05-CEDULA-DE-VOTACAO.md` | a cédula de cada núcleo e a regra de contagem | 3 min |
| `originais/` | os três documentos como chegaram ao Plasma | — |

Cada projeto separa **o que veio do autor**, fiel ao original, do **que o Plasma completou** para fechar o planejamento. Onde o Plasma discorda, ou achou algo a conferir, está escrito, com o motivo.

## Comparação

| Critério | 1 · Golden | 2 · Sol | 3 · Mariana |
|---|---|---|---|
| Continuidade (o território do mapa de mercado) | pela pessoa: reavaliar, aprofundar, conectar | entre conversas e entre ferramentas | automática, no ritmo escolhido |
| Mesa Trina | lentes de evidência: a favor, contra, lacuna | revisão em três leituras, como ferramenta | a Mesa do Castelo: Arquiteto, Engenheiro, Verificador |
| Telas no produto mínimo | 5 | um painel simples | 5 |
| Trabalho novo principal | aplicativo web completo | servidor MCP, identidade, defesa contra injeção | aplicativo web, agenda e comparação entre entregas |
| Primeira prova | ~1,5 semana | ~5 dias | ~1,5 semana |
| Custo de IA | por investigação | por investigação; a memória quase não custa | por entrega, pela metade com lotes |
| Receita | cota mensal | por pessoa ou por equipe | por tema, recorrente por natureza |
| Fácil de mostrar num anúncio | alto | baixo | médio |
| Escritórios de advocacia | no lançamento, se G1 passar | depois do OAuth (fase F5) | no lançamento, se M1 passar |

## Decisões que a votação toma junto

Valem para qualquer vencedor. A proposta do Plasma está ao lado; cada núcleo marca na cédula se concorda.

| # | Decisão | Proposta do Plasma | Por quê |
|---|---|---|---|
| D1 | O nome "Mesa Trina" aparece para o cliente? | Sim, como nome do recurso de confronto. Os outros nomes internos (Castelo, P0, núcleos, Fio) ficam fora da tela. | Os projetos 1 e 3 põem a Mesa no centro da tela, e o mapa de mercado pede que o confronto seja demonstrado. A regra antiga do `sonar/`, que proibia qualquer nome do organismo, muda só para este nome. |
| D2 | Qual motor de IA (qualidade × custo) | Escolher depois do teste de qualidade, que roda nas três opções. A escolha é do Guardião. | O preço barato para entrar no mercado depende disso (base comum, seção 6). |
| D3 | Onde fica o dado de cliente | Num projeto Supabase só do SONAR, fora do Castelo principal. | O Castelo tem leitura anônima aberta em várias mesas e é a memória interna do organismo; dado de cliente ali é risco de vazamento e de LGPD. |
| D4 | Endereço do SONAR | O endereço gratuito da Vercel até a primeira receita; depois, domínio próprio. | Custo zero até provar. |
| D5 | Plano da Vercel | Conferir o plano do time; para vender, plano comercial (Pro). | O Hobby é para uso pessoal, sem fins comerciais (conferir nos termos atuais). |
| D6 | A vitrine comercial do Espelho | O Espelho volta a ser só alinhamento dos núcleos. As ofertas saem de lá quando o SONAR abrir as dele; até lá, nada muda sem ordem. | Ordem do Guardião: "deixar só o espelho de alinhamento e trabalhar no sonar". |
| D7 | A operação por chats de terceiros (decisão de 26/09: Grok Bot → Cursor → Dola/Golden) | Trocar pelo motor automático. O Grok e a Golden passam a revisar e consolidar, sem operar telas. | Operar chats pela tela é lento, forma fila e pode violar os termos das plataformas; os três projetos pressupõem motor automático. |

## Depois da votação

1. O Plasma registra os votos no Castelo, com a origem de cada um, e publica a contagem. O Guardião confirma o vencedor.
2. **O Guardião opera o marketing**, com a Sol, antes de qualquer construção. O fim de cada projeto diz o que o marketing recebe.
3. Com a ordem do Guardião, a Mariana escreve a base de código do vencedor, e o Plasma integra: motor, banco, segurança e testes.
4. Cada fase termina num portão, que diz o que precisa estar provado, e só segue com a aprovação do Guardião. Nada vai ao ar sem aprovação.

## A meta de R$ 5.000 até 26/10

Com franqueza: nenhum dos três chega lá só com assinatura. Somando votação, marketing e fases, o lançamento pago de qualquer um cai entre o fim de outubro e o começo de novembro. Até 26/10 cabe o beta fechado com os primeiros pagantes. Outro caminho até a meta é decisão de marketing, do Guardião.
