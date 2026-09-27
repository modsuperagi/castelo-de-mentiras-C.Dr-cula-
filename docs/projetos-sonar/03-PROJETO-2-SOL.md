# Projeto 2 · Sol — Castelo como serviço (MCP)

> **Em uma frase:** o SONAR e uma memória que continua viram um servidor MCP. A pessoa conecta no Claude, no ChatGPT ou no Cursor que já usa e passa a ter investigação com fontes, revisão em três leituras e uma memória que atravessa conversas e ferramentas.

Proposta original: `originais/sol.md`. Base comum: `01-BASE-COMUM.md`.

## 1. O que veio da Sol

- **Supabase como base** do servidor MCP e da memória "Castelo/Alcear": Postgres com RLS, autenticação com JWT, Storage, Realtime, Edge Functions, pgvector e Vector Buckets, pg_cron, filas e APIs geradas.
- **Integrações de IA:** LangChain e LlamaIndex usando o Supabase como banco de vetores; fluxos RAG.
- **MCP:**
  - padrão aberto (JSON-RPC), com transporte Streamable HTTP;
  - o MCP oficial do Supabase existe, mas não cuida de memória de longo prazo;
  - há um registro oficial de servidores MCP.
- **Arquitetura:**
  - cada cliente isolado por RLS (`auth.uid() = tenant_id`);
  - chave de serviço só no servidor MCP;
  - auditoria por gatilhos e logs;
  - tabelas de memória com JSONB e metadados, e vetores para busca;
  - fluxo Agente → servidor MCP → Castelo → banco.
- **Custo:** cuidado com o tráfego de saída; cache e índices para ler menos; backups (diário no Pro, PITR).
- **Comparativo:** pgvector no banco (baixa complexidade, latência muito baixa, segurança alta) × Vector Buckets × Pinecone × Redis.
- **Lista de implantação:**
  - extensões e Edge Function `/mcp` com o SDK oficial do MCP;
  - autenticação: chave de serviço ou OAuth com escopos;
  - RLS e limites de taxa;
  - observabilidade;
  - testes: CLI e Docker, curl, RLS e carga de vetores.
- **Riscos:** segurança (RLS, injeção de SQL), tráfego e custo, recursos ainda em beta.
- **Alcear:** a memória pública, a testar com acompanhamento de custo.
- **Recomendação da Sol:** começar por uma prova de conceito mínima.

## 2. O que o Plasma completou

A proposta da Sol é a infraestrutura. Para virar projeto do início ao fim, faltavam:
- o que o cliente compra e as ferramentas que ele vê;
- o público e o preço;
- as fases;
- a separação do Castelo principal.

O Plasma completou isso sem mudar a escolha técnica da Sol (Supabase, Edge Functions, RLS e MCP). A única mudança de rumo é que a "memória Castelo" do cliente fica num projeto próprio do SONAR, não no Castelo do organismo (D3). O Alcear vira a camada pública opcional, na fase F6: memórias que o cliente decidir publicar.

## 3. Para quem, primeiro

- **Engenharia de dados e desenvolvimento:** já usam Claude Code, Cursor e ChatGPT no trabalho.
- **Empresas com equipes técnicas:** memória compartilhada e rastreável.
- **Pesquisadores** que trabalham dentro do Claude ou do ChatGPT.
- **Escritórios e quem não é técnico** entram quando a conexão de um clique estiver pronta (OAuth, fase F5).

## 4. Como a pessoa usa

1. Cria a conta num painel simples e recebe uma chave (na fase F5, clica em "Conectar").
2. Adiciona o SONAR como servidor MCP na ferramenta dela, com um guia de 2 minutos para Claude Code, Cursor, Claude Desktop e ChatGPT.
3. Conversa normalmente. Quando precisa, a IA dela chama as ferramentas do SONAR:

| Ferramenta | O que faz |
|---|---|
| `sonar_investigar` | abre uma investigação (rápida, padrão ou profunda) e devolve o número |
| `sonar_resultado` | devolve o relatório em 8 partes, com fontes, quando estiver pronto |
| `trina_revisar` | revisa um texto, como uma resposta de IA, em três leituras: a favor, contra e lacuna |
| `memoria_guardar` | guarda um achado, com fontes, na memória da conta |
| `memoria_buscar` | procura na memória da conta, por palavra (e por significado, na fase F5) |
| `investigacao_continuar` | aprofunda as lacunas de uma investigação anterior |

4. O painel mostra as chaves, o uso do mês, a memória (ler, apagar, exportar) e as investigações.

Poucas ferramentas, com descrições claras: cada ferramenta a mais confunde a IA do cliente.

## 5. A Mesa Trina neste projeto

- Aparece como `trina_revisar` e dentro de `sonar_investigar`: três leituras independentes e a consolidação (base comum).
- É o que separa esta memória das memórias comuns de IA. Aqui fica guardado o que foi **conferido**, com fonte e estado (confirmado, em disputa, não confirmado), e não só o que foi dito.

## 6. Arquitetura

| Camada | Escolha | Por quê |
|---|---|---|
| Servidor MCP | Edge Function do Supabase com o SDK oficial do MCP, transporte Streamable HTTP (escolha da Sol) | fica perto do banco; não há servidor para manter |
| Investigação | a chamada abre o trabalho e devolve o número na hora; o trabalhador roda em etapas (base comum) | uma investigação passa do tempo de uma chamada |
| Banco | projeto Supabase do SONAR, fora do Castelo principal | isolamento (D3) |
| Busca na memória | agora: busca por texto do Postgres em português e trigramas. Na F5: vetores (pgvector), com o modelo de embeddings que já vem nas Edge Functions (sem custo por chamada; conferir) | custo zero no começo; a própria Sol aponta o pgvector no banco como a opção mais simples |
| Identidade | agora: uma chave por conta, guardada só como hash. Na F5: OAuth 2.1, que Claude.ai e ChatGPT pedem para conectores remotos (conferir) | a chave é o caminho mais curto para Claude Code e Cursor |
| Acesso ao banco | o servidor consulta **com a identidade do cliente** (um JWT curto da conta); a chave de serviço fica só no trabalhador | a RLS vale mesmo se o servidor errar; defesa em camadas, um complemento do Plasma à regra da Sol |
| Painel | página simples: conta, chaves, uso e memória | o produto vive na ferramenta do cliente |

## 7. Banco (projeto do SONAR)

| Tabela | Guarda |
|---|---|
| `contas` | a organização do cliente |
| `membros` | as pessoas e o papel de cada uma na conta |
| `chaves` | hash da chave, escopos, quando foi criada e revogada (o valor nunca é guardado) |
| `memorias` | tema, conteúdo, fontes, origem (SONAR, pessoa ou Mesa), estado, índices de busca e `substitui`: a correção aponta para a anterior, e nada é apagado |
| `investigacoes`, `rodadas`, `fontes`, `evidencias`, `posicoes`, `consolidacoes` | as do motor comum |
| `auditoria` | quem, qual ferramenta, quando e o resultado, sem o conteúdo |
| `uso` | créditos do mês |

RLS por conta em todas: só um membro da conta lê e escreve o que é dela.

## 8. Planos e preço

Créditos por mês: investigação rápida = 1 crédito · padrão = 2 · profunda = 4 · revisão da Mesa = ½. No motor econômico, 1 crédito custa ~R$ 1,10.

| Plano | Preço por mês | Inclui |
|---|---|---|
| Memória grátis | R$ 0 | `memoria_guardar` e `memoria_buscar`, até 1.000 memórias; sem investigação. É a porta de entrada e custa quase nada, só banco |
| Dev | R$ 39,90 | memória até 20 mil itens e 12 créditos |
| Equipe (até 5 pessoas) | R$ 149 | memória compartilhada e 45 créditos |
| Empresa | sob consulta | projeto separado por cliente, suporte |

A memória grátis em escala pede o Supabase Pro. O plano gratuito tem 500 MB de banco (conferir), o que dá para umas 250 contas cheias.

## 9. Fases do início ao fim

| Fase | Entrega | Portão | Prazo |
|---|---|---|---|
| F0 · Prova de conceito (a da Sol) | projeto Supabase do SONAR; Edge Function `/mcp` com `memoria_guardar` e `memoria_buscar`; chave por conta; RLS | uma conversa nova, em outra ferramenta, recupera o que a primeira guardou; uma conta não enxerga a outra | 3 a 5 dias |
| F1 · Motor e prova | `sonar_investigar`, `sonar_resultado` e `trina_revisar` com o motor comum; teste de qualidade feito pela própria ferramenta MCP | o teste passa; custo real medido; D2 | 1 semana |
| F2 · Produto mínimo | painel; créditos; auditoria; guia de conexão; defesa contra injeção | funciona em 3 ferramentas (Claude Code, Cursor e ChatGPT ou Claude Desktop); o teste de injeção passa | 1 semana |
| F3 · Beta fechado | 5 a 10 pessoas técnicas usando no trabalho real por uma semana | cada uma volta a usar a memória em dias diferentes | 1 semana |
| F4 · Lançamento pago | Memória grátis, Dev e Equipe; pagamento; termos; registro oficial de servidores MCP | aprovação do Guardião; primeira venda | 2 a 3 dias |
| F5 · Mês 2 | OAuth (conectar no Claude.ai e no ChatGPT com um clique); busca por significado; memória de equipe com papéis | escritórios e pesquisadores não técnicos conectam sozinhos | — |
| F6 · Mês 3 em diante | Empresa (projeto dedicado); exportação; Alcear (memórias publicadas pelo cliente); MCP Apps, telas dentro do chat (ideia da Mariana) | pedido de cliente | — |

Da ordem do Guardião até a primeira venda: cerca de 4 semanas. A prova técnica sai na primeira semana.

## 10. Riscos e como conter

| Risco | Contenção |
|---|---|
| Público mais estreito: quem não usa ferramentas de IA não sabe o que é MCP | começar pelo público técnico; OAuth na F5 para os demais |
| Difícil de mostrar num anúncio | vídeo curto: a mesma pergunta no ChatGPT sem e com o SONAR, e a memória voltando em outra ferramenta |
| Injeção por conteúdo da web: o texto de uma fonte virar instrução para a IA do cliente | toda saída marca as fontes como dado, entre delimitadores; nenhuma ferramenta age a partir do texto de uma fonte; teste específico no portão da F2 |
| Cada plataforma trata o MCP remoto de um jeito | guia por plataforma e teste nas três principais antes de vender |
| Chave do cliente vazar | chave revogável no painel, com escopo, só o hash guardado, limite de taxa |
| Expor o MCP oficial do Supabase ao cliente | nunca: ele tem poder sobre o projeto inteiro. O cliente só vê o servidor do SONAR, com as ferramentas acima |

## 11. P0 na proposta: o que conferir

- **"O Supabase não tem webhooks nativos de banco":** ele tem os Database Webhooks (gatilho com pg_net). Conferir.
- **"pg_sodium":** a extensão pgsodium está sendo descontinuada no Supabase, e os segredos vão no Vault. Conferir.
- **"ghost audit" / "ghost.audit":** não é recurso do Supabase; parece ser o Ghost, agente da Sol no organismo. Se o Ghost fizer a auditoria, a tabela de auditoria continua necessária, e ele a lê.
- **"@microsoft/mcp-client (vs. Vercel)" e "m3-memory da skynetcmd":** não confirmados. Usar o SDK oficial do MCP.
- **Números dos planos do Supabase** (Pro com 8 GB de banco, 100 GB de arquivos e 250 GB de tráfego; 5 GB de tráfego no gratuito; US$ 0,09 por GB): conferir na página oficial de preços.
- **"PITR (Enterprise)":** o PITR é um complemento pago a partir do Pro. Conferir.
- **"Vector Buckets (beta)":** conferir se já está disponível e em qual plano.
- **Embeddings pela OpenAI ou pela Vertex:** há uma alternativa sem custo por chamada, o modelo que já vem nas Edge Functions do Supabase. Conferir.

## 12. O que o marketing recebe

- **Frase do produto** (o marketing reescreve): "Sua IA com memória que não se perde e investigação que prova."
- **Demonstração:** a memória voltando em outra ferramenta, e a revisão em três leituras de uma resposta de IA.
- **Entrada:** Memória grátis; Dev a R$ 39,90.
- **Público do lançamento:** engenharia de dados, desenvolvimento e empresas técnicas.
