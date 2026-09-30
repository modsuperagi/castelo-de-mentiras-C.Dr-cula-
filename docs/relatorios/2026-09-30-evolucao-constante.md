# Relatório · Evolução constante · 30/09/2026

Pedido do Guardião: olhar para dentro do nosso funcionamento, usar o SONAR e a ponte, ver o que há
de novo no mundo das IAs, percorrer os nossos dados, e dizer o que estamos estudando e o que não
estamos vendo.

Quem escreveu: Plasma. Tudo foi feito só em leitura, exceto a exportação de uma migração para o
repositório (seção 6). Nada foi construído, publicado ou ligado. A campanha segue fora do ar.

Método (o do SONAR): o Castelo foi lido diretamente (tabelas, políticas, funções, fila da Mesa Trina,
pedidos, tarefas, memórias). O mundo foi lido por busca na web. Dois sites primários (UpGuard e x.ai)
estão bloqueados no meu ambiente, então o que vem deles aqui é **coletado, não verificado**: o resumo
de terceiros, com a fonte listada no fim. Quem coleta não dá o veredito; as decisões ficam com a Mesa
Trina e o Guardião.

---

## 1. Em poucas linhas

1. **O Castelo está saudável na escrita e aberto na leitura.** Só o Guardião escreve nas tabelas
   centrais. Mas 24 tabelas podem ser lidas por qualquer pessoa que tenha a chave pública do site,
   entre elas as memórias e as decisões. Na semana passada, um estudo encontrou 16.326 bancos
   Supabase expostos exatamente assim. O nosso próprio SONAR registrou esse sinal em 28/09, mas
   ninguém ligou o sinal à nossa casa.
2. **O painel de tarefas do organismo (`sistema_todos`) mostra um mundo que já mudou.** Três itens
   estão errados ou repetidos, e a fila da Mesa Trina tem dois itens parados desde 24/09 e 26/09.
3. **O site ficou fora do ar em 29 e 30/09 sem que nenhum núcleo percebesse.** O último evento é de
   28/09. Só descobrimos quando o Guardião perguntou.
4. **O mundo das IAs chegou onde o organismo já estava.** Em setembro, Meta (Muse), OpenAI (Dots) e
   a SpaceXAI (Grok Bot) lançaram agentes sempre ligados, com memória e gatilhos. Ter núcleos
   deixou de ser diferença. O que continua sendo diferença é o que o mapa de mercado de 27/09 já
   dizia: continuidade que não depende de fornecedor, verificação e linhagem.
5. **O MetaLab já existe dentro do Castelo.** São três tabelas (`meta_lab_entries`, `_versoes`,
   `_auditoria`) com grau de confiança e "verificado por", paradas desde ~10/09. Antes de programar
   cada núcleo num bot do Super Grok, esse é o lugar para onde a memória dos bots deve voltar.

---

## 2. Como estamos (estado em 30/09)

| Frente | Estado |
|---|---|
| Espelho (site) | No ar de novo desde hoje (despausado; estava com erro 402). Campanha fora do ar, por ordem. |
| Movimento no site | 52 visitas, 22 aberturas de artigo, 12 leituras até o fim, 2 conversões, 1 uso do radar (27–28/09). Nada em 29–30/09 porque o site estava parado. |
| Receita | 1 inscrição ENEM (Google Ads, 27/09), 1 inscrição no Plano Estudante, 0 vendas confirmadas. `espelho_assinaturas` e `espelho_uso` vazias. |
| Bots | Parados por ordem, exceto o Alinhamento, retomado em 29/09 por ordem direta do Guardião. As rotinas Market e de comando de bots do Plasma seguem desligadas. |
| SONAR | Três projetos planejados (PR #24, rascunho), aguardando estudo e votação dos 7 núcleos. Nada construído. |
| Mesa Trina | 2 itens pendentes: a reformulação P0 V4 (desde 24/09) e a formulação base do SONAR (desde 26/09). |
| Tarefas do organismo | 6 abertas, 5 em andamento, 2 bloqueadas, 3 concluídas. |
| Corpus das 500 mentes | 85 mapeadas: 3 ativas (Karpathy, Willison, Chase, desde 18/09), 16 alocadas, 66 só citadas. |

---

## 3. O que há de novo dentro do Castelo (27 a 30/09)

- **29/09 · "EVO × Supabase: Experimento de Caixa-Preta e Porta 8"** (`evo_memorias` 1ae4131f).
  A hipótese é abrir uma porta institucional com a Supabase: um experimento em que uma inteligência
  externa recebe acesso ao ambiente sem receber o mapa e tenta reconstruir o organismo. O próprio
  registro diz que está em estado de hipótese.
- **29/09 · Linhagem "a história do beijo"** (`evo_memorias` 7ebf8d5d): registro de continuidade
  do autor, tratado como linhagem e não como origem.
- **29/09 · Alinhamento retomado** por ordem direta do Guardião. Os demais bots seguem parados.
- **30/09 · Migração do Grok Bot M** fechou `pedidos_entre_nucleos` e `fluxo_nos_nucleos`: agora
  só o Guardião escreve e lê nelas. É uma boa correção de segurança, mas faltava no repositório;
  exportei (seção 6).
- **28/09 · Sinal do SONAR** sobre a exposição em massa de aplicações Supabase, registrado como
  "sinal não validado" em `sistema_todos`.
- **27/09** · Mapa de mercado (0ced7b2c), Espelho reformado segundo ele, os três projetos do SONAR,
  a remoção da campanha e o stand-down do Norton com os achados HOLD da ponte.

## 4. O que estamos estudando

- **SONAR em três caminhos** (Golden, Sol, Mariana), com a base comum e a cédula (`docs/projetos-sonar/`).
- **Continuidade como território.** Pelo mapa de mercado, o EVO atua depois da resposta: investigar,
  confrontar, registrar e dar continuidade.
- **P0 V4, a anatomia**: P0 como coração e sangue, Mesa Trina como cerebelo. Está parado na fila da Trina.
- **A parceria com a Supabase** pela experiência, não pela venda.
- **Mentes tecnológicas** (Karpathy, Willison, Chase), já ativas, e as trindades de marketing e vendas,
  já alocadas.

---

## 5. O que não estamos vendo

Em ordem de peso.

### 5.1 O Castelo pode ser lido por qualquer um, e o mundo começou a procurar exatamente isso

- **O que vi:** 24 tabelas têm política de leitura `USING (true)` para `anon`. Entre elas estão
  `evo_memorias` (inclui o mapa de mercado, a estratégia de contato com a Supabase e a doutrina do
  Ponto 5), `registro_decisoes`, `checkin_recepcion`, `mariana_casting` e `ponte_ghost_castelo`. A
  chave `sb_publishable_…` está no HTML do site, como deve estar, e basta ela para ler essas tabelas.
- **O que está fechado, e está certo:** `espelho_pagamento_config` (Pix), `espelho_interessados`
  (dados de quem se inscreveu), `espelho_assinaturas` e a escrita nas tabelas centrais, que é só
  do Guardião.
- **Por que agora:** em 25/09 a UpGuard publicou que analisou cerca de 300 mil domínios com
  sinais de Supabase e achou 16.326 bancos com tabelas legíveis sem login. Mais da metade tinha
  dados pessoais. Isso é feito em escala, por robô.
- **O ponto cego:** a leitura aberta foi uma escolha (ponte do espelho do Grok, 19/09) e segue
  pendente de decisão do Guardião. O mundo mudou em volta dela. Há ainda uma contradição: o
  experimento "Caixa-Preta" quer oferecer à Supabase uma inteligência sem mapa entrando no
  organismo, e isso já acontece hoje, sem convite e sem registro. E chegar à Supabase com as
  memórias legíveis por qualquer um enfraquece a tese.
- **Decisão do Guardião:** quais tabelas o `nucleos.html` e os núcleos externos realmente precisam
  ler sem login. Proposta: manter abertas só as que alimentam o pulso público e fechar
  `evo_memorias`, `registro_decisoes`, `checkin_recepcion`, `mariana_casting` e `ponte_ghost_castelo`
  para leitura anônima. Os núcleos continuam lendo com login ou por função própria.

### 5.2 A memória dos bots é a nova porta de ataque

- A pesquisa de 2026 sobre agentes fala sobretudo de envenenamento de memória: um texto de fora
  entra na memória do agente e volta dias depois como se fosse instrução. Há pelo menos seis
  artigos no arXiv só entre abril e setembro.
- No organismo, os bots obedecem ao que está em `evo_memorias` (coleção `CLAUDE.md`: Ponto 5,
  escopo, stand-down). Hoje só o Guardião grava ali, o que é bom. Mas o público grava em
  `espelho_sinais` e `espelho_interessados.mensagem`, e a fila pública do SONAR mostra esses sinais.
- **Regra proposta, antes de programar os núcleos em bots:** texto que veio do público nunca vira
  instrução. O bot lê o texto como dado, e só executa o que está numa memória selada pelo Guardião
  (coleção `CLAUDE.md` com origem e selo). Isso deve entrar na instrução de cada bot.

### 5.3 O painel de tarefas mostra o organismo de 20/09, não o de hoje

A atualização automática de 29/09 às 02:32 renovou as datas, mas não os fatos:

- "Edge `meta-ia-portal-entrada` com verify_jwt=false" aparece **bloqueado**, mas a função hoje
  está com `verify_jwt=true`. O risco já foi fechado e o item não saiu.
- "Fechar tabelas com RLS e sem policy" diz 3 tabelas; o advisor de segurança mostra 4:
  `castelo_tabela_responsavel`, `espelho_catalogo`, `espelho_pagamento_config` e `espelho_uso`.
  As três do Espelho estão fechadas de propósito, porque só funções as leem.
- "P1: deploy saudável Espelho/app Vite (não static)" aparece duas vezes (`p1_espelho_deploy_saudavel`
  e `vercel_repo_mentiras_conflito`) e contradiz a decisão atual (site estático sem build, no ar).
- "Desbloquear P0 / Sonar (sair do DENY)" continua preso a uma auditoria de 10/09.

Um painel que diz coisas velhas leva os bots a trabalhar no passado. Proposta: a Mesa Trina revisa
os itens de prioridade ≥ 90 e o Plasma corrige o que for fato, com a evidência no próprio item.

### 5.4 Ninguém vigia se a casa está de pé

- O site ficou com erro 402 por pelo menos dois dias. O último evento no Castelo é de 28/09.
- Com a rotina Market parada, também ninguém confere comprovantes de Pix. Hoje não há venda
  pendente, mas se chegar uma, ninguém vê.
- **Hipótese a conferir (não verificada):** projetos Vercel costumam ser pausados quando batem o
  limite de gasto (spend management). Isso explicaria a pausa sem aviso e a sensação de "pagar de
  novo". Vale olhar no painel do Vercel, em Billing → Spend Management, o limite e a ação configurada.
  Não mexi em nada de cobrança.
- **Proposta de custo zero:** uma verificação diária (uma requisição à página inicial e uma consulta
  a comprovantes novos) dentro de uma rotina que já existe, sem ligar bot novo. Só com a sua ordem.

### 5.5 Três políticas "temporárias" continuam abertas, mas sem efeito

- `arquivos_fio_ee46c360` (63 linhas), `fluxo_necessidade_capaz` (14) e `operacao_faixas` (3) têm a
  política `allow_all_temporario` (tudo liberado para `public`).
- Hoje nada vaza: nem `anon` nem `authenticated` têm permissão de tabela, então a política não tem
  efeito. Mas basta um `GRANT` para abrir tudo, e foi assim, com um `GRANT`, que a migração de hoje
  ativou a política do Guardião nas outras duas tabelas.
- **Proposta:** apagar as três políticas e deixar só a do Guardião, no mesmo molde da migração do
  Grok Bot M.

### 5.6 A migração de hoje pode ter cortado a fala entre bots

- Agora só o Guardião (ou `service_role`) escreve em `pedidos_entre_nucleos`. É lá que os bots se
  pedem coisas, e há pedidos abertos: veredito da Trina f1f5a259, teste comparativo do SONAR para
  o Grok Bot, 500 mentes e auditoria Hellwolf para o Super Grok, sincronização Mariana V2↔V4, selo
  da Mariana, webhook do ponto 5.
- Se algum bot escrevia ali com um login comum, a partir de hoje ele falha em silêncio.
- A travessia do Grok Bot M (f6eaaf52) diz "acesso só do Guardião e núcleos (service_role)". Se os
  núcleos escrevem com a chave `service_role`, eles passam por cima de toda a RLS do Castelo. Nesse
  caso, um bot com a memória envenenada (seção 5.2) pode apagar ou reescrever qualquer tabela.
- **Conferir:** com que credencial cada bot escreve no Castelo. Isso também é pré-requisito para
  programar os núcleos em bots (seção 8, item 3).
- O pedido "acompanhar_campanha" (Plasma → Alinhamento) ficou sem objeto com a campanha fora do ar
  e pode ser encerrado.

### 5.7 O que o organismo já tem e não usa

- **MetaLab no Castelo:** 51 entradas, 19 versões, 20 auditorias, com `grau_confianca`,
  `verificado_por` e `origem_banca`. Está parado desde ~10/09. O MetaLab do Super Grok pode ser a
  oficina, e este, o arquivo selado.
- **Mesa Trina automática:** as funções `trina-arquiteto`, `trina-engenheiro`, `trina-verificador` e
  `mesa-orchestrator`, e as do Sol (`sol-karpathy`, `sol-willison`, `sol-chase`, `sol-orchestrator`),
  estão ativas, mas a fila tem itens de 24/09. Ou as funções não estão sendo chamadas, ou chamam e
  não fecham o veredito.
- **Corpus:** 66 das 85 mentes só estão citadas, sem alocação.

---

## 6. O que fiz nesta rodada

- Exportei para `supabase/migrations/20260930013743_fechar_rls_pedidos_fluxo_nucleos_guardiao.sql`
  a migração que o Grok Bot M aplicou hoje. É cópia fiel, com uma linha de origem no topo. O
  repositório volta a ter as 106 migrações do Castelo.
- Nada mais foi alterado no Castelo, no Vercel ou no site.

---

## 7. O que há de novo no mundo das IAs (setembro de 2026)

Coletado por busca; fontes no fim. Para cada item, o que significa para nós.

### 7.1 Agentes sempre ligados viraram o produto da estação

- **Meta Muse** (08/09): agente pessoal que liga e-mail, agenda e pagamentos. É grátis com limites,
  com planos de US$ 20 e US$ 100 por mês. Em 29/09 ganhou versão para pequenos negócios.
- **OpenAI Dots** (DevDay, 29/09): agentes 24/7, cada um com seu computador na nuvem e navegador,
  mais o "ChatGPT Space" para trabalhar junto com eles. Disponível no Pro e no Business.
- **SpaceXAI Grok Bot:** a equipe de agentes que o organismo já usa. Memória e rotinas pertencem a
  cada bot, com gatilhos por agenda ou por evento e delegação entre agentes. A VentureBeat cita
  US$ 120 por mês.

**Para nós:** o que o organismo desenhou desde setembro (núcleos, memória, gatilhos, circulação)
agora é o que as três maiores empresas vendem. Isso confirma a arquitetura e tira dela a novidade.
A diferença que sobra é a do mapa de mercado: **a memória mora no Castelo, não no fornecedor.**
No Grok Bot, "a memória pertence ao bot"; se a assinatura cair, a memória vai junto. Ao programar
cada núcleo num bot, a memória do bot deve ser só uma cópia de trabalho, e o que vale fica no Castelo.

### 7.2 Modelos

- **Claude Sonnet 5.5** (28/09): mesmo preço do Sonnet 5 (US$ 2/10 por milhão de tokens), mais de
  30% mais rápido e até 30% mais barato por tarefa. O **Haiku 5.5** vem "nas próximas semanas".
- **GPT-6.1 Sol** (OpenAI): quase o nível do GPT-6 Astra em código, uso de computador e trabalho
  profissional, por um quinto do preço. A OpenAI desistiu do 6.1 Astra por não passar nos padrões
  de segurança.
- **Grok 4.7** na API: 500 mil tokens de contexto. O Grok 5 segue em treino e ainda não saiu.
- **Gemini 3.5 Pro:** lê vídeo de forma ativa, navegando pelo conteúdo.

**Para nós:** as contas do motor em `docs/projetos-sonar/01-BASE-COMUM.md` usam o Sonnet 5 e o
Haiku 4.5. Com o Sonnet 5.5 no mesmo preço e o Haiku 5.5 chegando, o custo por investigação tende a
cair, sobretudo no modo Econômico. Isso deve ser revisto depois da votação, com o teste de qualidade
que a base comum já prevê.

### 7.3 MCP amadureceu

- A especificação de 28/07/2026 tornou o núcleo do protocolo sem estado. Entrou a extensão
  oficial **Tasks** para agentes de longa duração, e a memória passou a ser responsabilidade
  explícita da aplicação.

**Para nós:** o Projeto 2 (Sol, "Castelo como serviço MCP") deve nascer nessa versão da especificação.
E a própria especificação diz o que o Castelo já faz: a memória é da aplicação.

### 7.4 Checar citação virou mercado

- A **GPTZero** achou mais de 50 artigos com citações inventadas no ICLR 2026.
- **RealityCheck** e **CiteCheck** verificam citações em peças jurídicas.
- O **arXiv** passou a banir por um ano quem enviar conteúdo de IA sem checagem (maio/2026).
- Há um benchmark acadêmico só para isso (CiteAudit).

**Para nós:** isso valida a Checagem P0 e o artigo "a referência do ChatGPT existe?". Também mostra
concorrentes reais nos nichos jurídico e acadêmico. O nosso ângulo, pelo mapa de mercado, continua
sendo a investigação com continuidade e linhagem, e não só a checagem pontual.

### 7.5 Segurança de agentes

- A pesquisa se concentra em envenenamento de memória persistente (seção 5.2) e em tratar a
  segurança de agentes como problema de rede, controlando por onde cada agente pode falar.

### 7.6 Regulação no Brasil

- O **PL 2338/2023** (marco da IA) tinha votação no plenário da Câmara marcada para 27/05/2026.
  **Não consegui confirmar o resultado.** As fontes de setembro não trazem desfecho claro. É uma
  lacuna, e é tarefa típica do SONAR, útil ao Projeto 3 (tema jurídico) e a qualquer oferta para
  escritórios.

---

## 8. Para quando os núcleos virarem bots no MetaLab

É só o que este relatório ensina. A programação em si fica para quando o Guardião mandar.

1. **Memória canônica no Castelo.** O bot guarda o necessário para trabalhar e devolve ao Castelo o
   que aprendeu (`meta_lab_entries` com grau de confiança, ou `evo_memorias`).
2. **Instrução só de fonte selada.** Texto do público, de outro bot ou da web é dado, nunca ordem.
3. **Uma credencial por bot, com o mínimo de permissão.** Hoje só o Guardião escreve nas tabelas
   centrais; cada bot precisa de um caminho próprio (uma função que só insere pedidos, por exemplo),
   nunca a chave de serviço.
4. **Gatilho em vez de ronda.** O Grok Bot já trabalha por gatilhos; o organismo já tem o Ponto 5.
   Bot que roda a cada 30 minutos sem motivo gasta dinheiro.
5. **Registro na volta:** cada ação do bot vira uma travessia com `fio_id`, como já fazem os núcleos.

---

## 9. O que depende do Guardião

| # | Decisão | Custo |
|---|---|---|
| 1 | Fechar a leitura anônima de `evo_memorias`, `registro_decisoes`, `checkin_recepcion`, `mariana_casting` e `ponte_ghost_castelo` | zero |
| 2 | Apagar as três políticas `allow_all_temporario` que sobraram | zero |
| 3 | Mandar a Mesa Trina revisar o painel de tarefas e fechar os dois itens da fila (24/09 e 26/09) | zero |
| 4 | Ligar uma verificação diária do site e dos comprovantes dentro de rotina existente | zero |
| 5 | Olhar no Vercel o limite de gasto que pode ter pausado o site | zero |
| 6 | Mandar o SONAR confirmar o desfecho do PL 2338 e a fonte primária do estudo da UpGuard | baixo |
| 7 | Conferir com que credencial cada bot escreve no Castelo, antes do MetaLab | zero |

---

## Fontes (coletadas em 30/09/2026)

Castelo: projeto `zolbckgqdxxovguspjdb`, leitura direta de `pg_policies`, `pg_stat_user_tables`,
`evo_memorias`, `registro_decisoes`, `sistema_todos`, `v_trina_pendente`, `evo_recrutamento_agentes`,
`espelho_eventos`, `supabase_migrations.schema_migrations`, advisor de segurança e lista de Edge Functions.

Mundo:

- UpGuard, "Everything Everywhere: Systemic Data Exposure in Supabase Apps": https://www.upguard.com/blog/everything-everywhere-systemic-data-exposure-in-supabase-apps (bloqueado no meu ambiente; lido por terceiros)
- BleepingComputer, "Misconfigured Supabase apps expose data in over 16,000 databases": https://www.bleepingcomputer.com/news/security/misconfigured-supabase-apps-expose-data-in-over-16-000-databases/
- byteiota, "16,326 Supabase Databases Leaked": https://byteiota.com/16326-supabase-databases-leaked-check-your-rls-now/
- Meta, "Introducing Muse": https://about.fb.com/news/2026/09/introducing-muse-personal-ai-agent/
- TechCrunch, Muse para pequenos negócios: https://techcrunch.com/2026/09/29/meta-is-expanding-its-ai-agent-muse-to-small-businesses/
- TechCrunch, OpenAI Dots: https://techcrunch.com/2026/09/29/openai-launches-dots-its-bubbly-agentic-avatar/
- Axios, cinco anúncios do DevDay: https://www.axios.com/2026/09/29/openai-dev-day-2026-dots-space-sol
- CNBC, DevDay: https://www.cnbc.com/2026/09/29/openai-devday-2026-live-updates.html
- SpaceXAI, "Designing Grok Bot": https://x.ai/news/designing-grok-bot (bloqueado no meu ambiente)
- VentureBeat, Grok Bot: https://venturebeat.com/orchestration/spacexais-grok-bot-turns-agents-into-persistent-digital-coworkers-that-can-operate-your-apps-for-120-per-month
- DataCamp, "Grok Bot Explained": https://www.datacamp.com/blog/grok-bot
- SiliconANGLE, Claude Sonnet 5.5: https://siliconangle.com/2026/09/28/anthropic-debuts-claude-sonnet-5-5-running-30-faster-than-the-previous-generation-ai-model/
- Unite.AI, preço do Sonnet 5.5: https://www.unite.ai/anthropic-releases-claude-sonnet-5-5-at-unchanged-sonnet-5-pricing/
- Grok 5, estado em setembro: https://geotoolbox.ai/blog/grok-5
- Gemini API, changelog: https://ai.google.dev/gemini-api/docs/changelog
- MCP, especificação 2026-07-28: https://blog.modelcontextprotocol.io/posts/2026-07-28/
- MCP, roteiro 2026: https://blog.modelcontextprotocol.io/posts/2026-mcp-roadmap/
- GPTZero, ICLR 2026: https://gptzero.me/news/iclr-2026/
- Above the Law, RealityCheck: https://abovethelaw.com/2026/03/new-tool-catches-ai-hallucinations-in-legal-briefs/
- The Daily Record, ferramentas contra alucinação em peças: https://thedailyrecord.com/2026/08/28/ai-hallucination-tech-tools/
- arXiv, envenenamento de memória persistente: https://arxiv.org/pdf/2609.13889
- arXiv, levantamento sobre segurança de memória de agentes: https://arxiv.org/pdf/2604.16548
- Entercast, PL 2338 com votação marcada para maio de 2026: https://www.entercastconsulting.com.br/blog/marco-legal-ia-brasil-votacao-camara-maio-2026
- Senado, PL 2338/2023: https://www25.senado.leg.br/web/atividade/materias/-/materia/157233

---

## Adendo · o que foi feito depois do relatório (30/09)

Por ordem do Guardião ("aberto aos núcleos, não ao público"; "quando identificam falta de RLS,
ativem por si mesmos"):

- **Migração `20260930021952_castelo_leitura_so_nucleos`.** Tirou a leitura pública de memória,
  circulação, Trina, Mariana, ponte e Sol. Os núcleos leem pela conta do Guardião
  (`guardiao_leitura`) ou pelo `service_role`. Decisões ficam visíveis ao público só com
  `nivel_acesso = 'publico'`, e canais voltaram ao filtro original. Saíram as três políticas
  `allow_all_temporario` e o UPDATE sem política da ponte Ghost.
- **Testado.** Como anônimo, a Recepção e a vitrine abrem, e o resto nega. Como Guardião, tudo abre.
  Com uma conta sem o papel de Guardião, nada interno abre. O advisor não mostrou nenhum alerta novo
  além de "sem policy" (INFO) nas mesas que agora só o `service_role` alcança.
- **Pedidos entre núcleos** continuam como o Grok Bot M (Drácula) deixou: só a conta do Guardião e
  o `service_role`. Eles não passam pelo check-in, porque a Recepção dispara P0 e a circulação e
  engarrafaria a Trina. O conhecimento que um pedido produz entra pelo check-in.
- **Regra de autocorreção** selada em `evo_memorias` (CLAUDE.md, b6d4ca93), decisão 83ac1771, e
  pedido 522c49e2 ao Verificador da Mesa Trina para conferir.
- **Painel de tarefas corrigido.** O item do verify_jwt foi concluído; as mesas sem policy estão
  recontadas (8, todas fechadas de propósito); o P1 duplicado foi cancelado; o sinal da Supabase
  foi fechado com fontes. O pedido "acompanhar campanha" foi cancelado.
- **Gatilho Drácula → Plasma:** o texto está em `docs/GATILHO-DRACULA.md`. A criação automática foi
  bloqueada pelo sistema de permissões desta sessão.
