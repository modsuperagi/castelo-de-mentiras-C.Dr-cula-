# SONAR: website MVP, documentação da implementação

Primeira superfície pública do SONAR: **entra → pergunta → investiga → organiza → resultado com fontes**.
Código em `sonar/`. Este documento fica em `docs/` e **não vai ao ar**.

> Regra de evidência: documentado ≠ instalado ≠ executado ≠ validado.
> O status de cada parte está na seção [Checkpoint](#checkpoint-de-desenvolvimento), no fim.

## Separação do organismo

O SONAR é outro produto e não conhece a infraestrutura interna:

- `sonar/` não importa, cita nem chama o Castelo, o Supabase, o EVO ou qualquer nomenclatura interna.
  A varredura `grep -rniE 'castelo|evo\b|metalab|supabase|plasma|golden|mariana|ghost|n[uú]cleo|fio|p0|hellwolf|guardi' sonar/` precisa voltar vazia.
- `sonar/` entrou no `.vercelignore` da raiz: o projeto do espelho (`p0-pulsa`) não publica o SONAR.
- O SONAR tem projeto Vercel próprio, com Root Directory `sonar`.

## Estrutura

```
sonar/
├── public/                 ← único diretório servido como site (outputDirectory)
│   ├── index.html          interface (HTML + CSS)
│   ├── app.js              comportamento (estados, leitura do fluxo, resultado)
│   ├── favicon.svg
│   └── robots.txt
├── api/                    ← funções do servidor (Vercel Functions, Node)
│   ├── investigar.js       POST /api/investigar
│   └── saude.js            GET  /api/saude
├── lib/                    ← usado só pelas funções; nunca servido
│   ├── profundidade.js     profundidade adaptativa (sem custo de chamada)
│   ├── instrucoes.js       instruções da investigação (só no servidor)
│   ├── xai.js              cliente da Responses API da xAI
│   ├── sintese.js          leitura da resposta, cruzamento de fontes, estados
│   ├── armazenamento.js    adaptador de armazenamento desacoplado
│   └── limite.js           freio de uso por endereço
├── testes/                 testes do encanamento com xAI SIMULADA (não vão ao ar)
├── servidor-local.js       servidor de desenvolvimento (não vai ao ar)
├── vercel.json             outputDirectory, tempo máximo das funções, cabeçalhos de segurança
├── .vercelignore
└── package.json            sem dependências; Node ≥ 20
```

Por que `public/` separado: se o site fosse servido da raiz de `sonar/`, qualquer pessoa baixaria
`lib/instrucoes.js` (as instruções internas). Com `outputDirectory: "public"`, só `public/` é arquivo estático.

## Frontend

Uma página, sem build, sem framework.

**Rotas**: `/` (site), `/api/investigar`, `/api/saude`.

**Estados da tela** (classe no `<body>`):

| Estado | O que aparece |
|---|---|
| entrada | nome, frase "Pergunte. Investigue. Compreenda.", campo e botão **Sondar** |
| `investigando` | cabeçalho compacto, eco saindo do campo, linha de etapas com as etapas reais |
| `com-resultado` | pergunta como título, medida da evidência, avisos, Resultado, O que foi encontrado, Cruzamento, Pontos de atenção, Fontes |
| falha | mensagem dizendo que a investigação não foi concluída, e botão "Tentar de novo" |

**Etapas mostradas**: cada uma só acende quando o servidor emite o estado correspondente
(Pergunta recebida → Pesquisando na web [e no X] → Cruzando e conferindo as fontes → Organizando o resultado).
Nenhuma etapa é animada por tempo.

**Segurança da tela**: todo dado do servidor entra por `textContent`; links só `http(s)`, com
`rel="noopener noreferrer nofollow"`. CSP: `script-src 'self'`, `connect-src 'self'`, `frame-ancestors 'none'`.

## Backend

### `POST /api/investigar`

Entrada: `{ "pergunta": "texto de 3 a 800 caracteres" }`.

Recusas em JSON comum: `405` (não é POST), `403` (Origin de outro site), `400` (pergunta vazia ou longa),
`503` (servidor sem `XAI_API_KEY`: a investigação nem começa), `429` (limite de uso, com `Retry-After`).

Aceito: `200` com `Content-Type: application/x-ndjson`, uma linha JSON por evento:

```
{"id":"…","estado":"RECEBIDO","nivel":"comparativa"}
{"id":"…","estado":"INVESTIGANDO","ferramentas":["web_search","x_search"]}
{"id":"…","estado":"INVESTIGANDO","pulso":true}          ← a cada 10 s, mantém a conexão viva
{"id":"…","estado":"CRUZANDO"}
{"id":"…","estado":"ORGANIZANDO"}
{"id":"…","estado":"CONCLUIDO","resultado":{…}}          ← ou INCOMPLETO, ou:
{"id":"…","estado":"ERRO","codigo":"tempo","mensagem":"…não pôde ser concluída…"}
```

Resultado entregue ao navegador:

```json
{
  "id": "uuid", "concluido_em": "ISO", "pergunta": "…", "estado": "CONCLUIDO|INCOMPLETO",
  "nivel": "direta|atual|comparativa|profunda", "ferramentas": ["web_search"],
  "resumo": "…",
  "achados": [{ "texto": "…", "tipo": "fato|evidencia|afirmacao|interpretacao|hipotese|incerteza", "fontes": [1, 2] }],
  "cruzamento": { "convergencias": [{ "texto": "…", "fontes": [1] }],
                  "divergencias": [{ "tema": "…", "posicoes": [{ "texto": "…", "fontes": [3] }] }] },
  "pontos_de_atencao": ["…"],
  "evidencia": "suficiente|limitada|insuficiente",
  "fontes": [{ "n": 1, "url": "…", "titulo": "…", "dominio": "…", "origem": "web|x", "citada": true }],
  "consultas": [{ "ferramenta": "web_search|x_search", "consulta": "…" }],
  "avisos": ["…"]
}
```

### `GET /api/saude`

`{ "ok": true, "pesquisa_configurada": true|false }`. Não revela chave, modelo nem configuração.

### Fluxo de execução

```
navegador ── POST /api/investigar ──► api/investigar.js
  1. valida (método, origem, tamanho, limite de uso)            → RECEBIDO
  2. lib/profundidade.planejar(pergunta)                        (sem custo)
  3. lib/xai.investigarNoGrok  → POST {XAI_BASE_URL}/responses  → INVESTIGANDO
        a xAI roda o laço de busca no servidor dela (web_search / x_search)
  4. lib/sintese.sintetizar                                      → CRUZANDO, ORGANIZANDO
        confere cada URL citada contra as fontes que a pesquisa retornou
  5. lib/armazenamento.salvar(registro com proveniência)         (falha aqui não derruba o resultado)
  6. resultado                                                   → CONCLUIDO | INCOMPLETO
  qualquer falha                                                 → ERRO
```

### Variáveis de ambiente

| Variável | Obrigatória | Padrão | Para quê |
|---|---|---|---|
| `XAI_API_KEY` | **sim** | – | chave da API da xAI. Só no Vercel (Environment Variables), nunca em arquivo versionado |
| `XAI_MODEL` | não | `grok-4-1-fast` | modelo da Responses API |
| `XAI_BASE_URL` | não | `https://api.x.ai/v1` | trocar só em teste |
| `SONAR_TEMPO_LIMITE_MS` | não | `110000` | limite da chamada à xAI (a função tem `maxDuration: 120`) |
| `SONAR_LIMITE_POR_JANELA` | não | `10` | investigações por endereço por janela |
| `SONAR_JANELA_MINUTOS` | não | `10` | tamanho da janela |
| `SONAR_ARMAZENAMENTO` | não | `nenhum` | `nenhum`, `memoria` ou `webhook` |
| `SONAR_ARMAZENAMENTO_URL` | com `webhook` | – | destino do registro |
| `SONAR_ARMAZENAMENTO_TOKEN` | não | – | vai como `Authorization: Bearer` |
| `SONAR_BUSCA_TOKEN` | para `/api/buscar` | – | token do operador; sem ele a busca do operador fica desligada |
| `SONAR_BUSCA_LIMITE` | não | `60` | buscas do operador por 10 minutos |
| `SONAR_SEARXNG_URL` | não | – | endereço do SearXNG próprio (fonte `web`) |

### Logs

Cada investigação gera **uma** linha JSON com metadados: id, estado, nível, tempo, número de fontes
e consultas, tokens e uso de ferramentas (custo). **A pergunta, o texto e a chave não vão para o log.**

## xAI

- **Endpoint**: `POST https://api.x.ai/v1/responses`, `Authorization: Bearer $XAI_API_KEY`.
- **Ferramentas**: `web_search` sempre; `x_search` quando a pergunta fala do X, de repercussão ou de redes,
  ou quando a profundidade é `profunda`. São ferramentas **de servidor**: a xAI executa as buscas e devolve a resposta final.
- **Corpo enviado**:

```json
{
  "model": "grok-4-1-fast",
  "input": [
    { "role": "system", "content": "<instruções de lib/instrucoes.js>" },
    { "role": "user", "content": "<pergunta>" }
  ],
  "tools": [{ "type": "web_search" }, { "type": "x_search" }],
  "max_turns": 5,
  "store": false
}
```

- `max_turns` (economia) e `store` (privacidade) são opcionais: se a API recusar um deles com 400/422,
  o cliente refaz **uma** vez sem eles.
- **Resposta lida**: `output[].type == "message"` → `content[].output_text` (texto e `annotations`);
  `citations` (todas as fontes que a busca encontrou); chamadas de ferramenta em `output` (consultas);
  `usage` e `server_side_tool_usage` (custo).
- **Formato pedido ao modelo**: JSON com resumo, achados tipados, cruzamento, pontos de atenção e evidência.
  Se vier fora do formato, o texto é mostrado como veio e a investigação fica **INCOMPLETO**.

## Função dos Grok Bots no MVP

O documento mestre prevê quatro funções. No MVP elas vivem em **uma chamada** ao Grok mais código determinístico,
o mínimo que faz o trabalho real:

| Função | Onde está | Entrada → saída |
|---|---|---|
| Orquestração | `api/investigar.js` + `lib/profundidade.js` | pergunta → plano (nível, ferramentas, `max_turns`, orçamento de buscas) |
| Pesquisa | Grok com `web_search` / `x_search` (laço de busca no servidor da xAI) | pergunta + plano → consultas, fontes, texto |
| Cruzamento / verificação | instruções ao Grok (tipos epistêmicos, divergências) **e** `lib/sintese.js` | fontes + texto → URLs conferidas, fatos sem fonte rebaixados a incerteza, referências inventadas removidas |
| Síntese / organização | Grok (JSON) + `lib/sintese.js` | texto → resultado estruturado com fontes numeradas |

Regras que o código impõe, sem depender do modelo:

- URL citada que **não** consta nas fontes retornadas pela pesquisa é removida, e isso vira aviso.
- Achado do tipo fato, evidência ou afirmação sem fonte confirmada é rebaixado a **incerteza**.
- Sem nenhuma fonte retornada → **INCOMPLETO**, evidência `insuficiente`.
- Evidência "suficiente" com menos de duas fontes citadas → `limitada`.
- Falha da API, tempo esgotado ou resposta vazia → **ERRO**. Nunca aparece como concluída.

Quando o teste real mostrar onde a chamada única perde qualidade (por exemplo, perguntas profundas),
a verificação pode virar uma segunda chamada. Só então.

## Armazenamento

`lib/armazenamento.js` expõe `salvar(registro)`. O registro guarda a proveniência completa:
pergunta → plano → modelo e parâmetros → consultas → fontes retornadas → referências descartadas →
texto bruto → resultado → uso. Hoje o padrão é `nenhum`. Para ligar um destino, basta um webhook
(`SONAR_ARMAZENAMENTO=webhook`) ou um driver novo no mesmo arquivo. Nenhum banco foi escolhido.

## Deploy (Vercel)

1. Criar um projeto Vercel **novo** ligado a este repositório, com **Root Directory = `sonar`**,
   Framework Preset = Other. O `vercel.json` já define `outputDirectory: "public"` e o tempo das funções.
2. Em Settings → Environment Variables, criar `XAI_API_KEY` (Production e Preview). Opcional: `XAI_MODEL`.
3. Produção sai da `main`. Domínio: o `.vercel.app` do projeto, até decidirem um domínio próprio.
4. Conferir depois do deploy:
   - `GET /api/saude` → `pesquisa_configurada: true`;
   - `/lib/instrucoes.js`, `/api/../lib/xai.js`, `/testes/…` e `/servidor-local.js` → 404;
   - no código-fonte da página, nenhuma chave e nenhum nome interno.

Local: `cd sonar && XAI_API_KEY=... npm run dev` → <http://localhost:3000>. Ou crie `sonar/.env.local`
(o git ignora `.env.*`).

## Testes

`cd sonar && npm test` roda 21 testes: 12 do fluxo de investigação, com uma **xAI simulada** (`testes/xai-simulada.mjs`):
plano de profundidade, extração de citações e de JSON, conferência de fontes (inclusive fonte inventada),
estados INCOMPLETO e ERRO, retentativa sem parâmetro opcional, tempo limite, cota, limite de uso,
e o endpoint de ponta a ponta com os estados na ordem.

**Esses testes provam o encanamento, não a xAI.** O formato simulado segue a documentação
pública da xAI, lida por busca porque `docs.x.ai` e `api.x.ai` são bloqueados na rede do ambiente de desenvolvimento.

## Decisão de operação (Guardião, 26/09/2026)

A pesquisa **não** passa pelas ferramentas da xAI. O caminho decidido é:

```
visitante → site (Grok Bot na barra: conversa, organiza, vende)
          → Grok Bot (computador próprio) → Cursor → Dola AI / Golden
              (chat com a estrutura Sonar)
          + busca própria do SONAR (código nosso, fontes abertas)
```

- O **Grok Bot** é o operador e assistente. Ele não é o motor de busca.
- A **Golden, na Dola**, guarda a estrutura Sonar e interpreta.
- A **busca própria** (abaixo) traz o material bruto com origem, sem modelo de IA no meio.
- O caminho `api/investigar.js` com `web_search`/`x_search` fica como está, mas **deixa de ser o principal**.
  O site vai ser redesenhado para: assistente na barra, pedido em fila, entrega depois e blog.
- Riscos já apresentados ao Guardião: operar chats pela tela é lento (minutos por pedido), forma fila
  e pode violar os termos de uso das plataformas. A decisão foi tomada ciente disso.
- As **sete entregas do Sonar** não estão no Castelo (check-in `4b68fa1a`, 26/09). O redesenho do motor espera por elas.

## Busca própria do SONAR

Código em `lib/busca/`. Nenhum modelo de IA e nenhuma chave paga: só APIs abertas e oficiais.

| Fonte | API | Entra quando |
|---|---|---|
| `wikipedia-pt`, `wikipedia-en` | MediaWiki search | sempre |
| `noticias` | GDELT DOC 2.0 | consulta atual (hoje, semana, lançamento…) ou quando há poucas fontes |
| `arxiv`, `crossref` | arXiv API, Crossref REST | consulta acadêmica (artigo, estudo, científico, DOI…) |
| `github` | GitHub search (sem login: 10 buscas/min) | consulta de código (repositório, biblioteca, API…) |
| `hackernews` | Algolia HN | tecnologia + atual ou código |
| `web` | **SearXNG próprio** em `SONAR_SEARXNG_URL` | sempre que configurado |

O que o motor faz (`lib/busca/motor.js`):
1. escolhe as fontes pela natureza da consulta (ou usa as que o operador pedir);
2. consulta todas em paralelo, com tempo limite por fonte;
3. registra cada fonte como `ok` ou com o erro, sem esconder falhas;
4. tira URLs repetidas (guarda em `tambem_em` quem mais trouxe a mesma URL);
5. ordena por aderência ao título e ao trecho, com bônus de recência em consultas atuais;
6. com `ler`, baixa as melhores páginas e extrai o texto (`lib/busca/leitura.js`), bloqueando
   endereços internos, portas fora do padrão e redirecionamentos para a rede interna.

**Comando para o operador (Grok Bot no Cursor):**

```
cd sonar
node buscar.js "consulta" [--fontes noticias,arxiv] [--ler 3] [--limite 5] [--json]
```

Sem `--json`, a saída é uma lista legível para colar no chat da Golden. Sem resultados, o comando
diz que a evidência foi nula.

Com `--sonar`, a saída é o **material pré-curado** para o bot (`lib/busca/curadoria.js`): camada 1
(descarta com motivo o que não tem origem rastreável, parece isca de clique ou vem de domínio bloqueado em
`SONAR_DOMINIOS_BLOQUEADOS`) e camada 3 (agrupa por tema e conta domínios independentes). Impacto,
disputa e desmentido ficam para o bot julgar. As instruções do bot estão em `docs/SONAR-BOT-INSTRUCOES.md`.

**Endpoint para o operador:** `POST /api/buscar` com `Authorization: Bearer $SONAR_BUSCA_TOKEN`
e `{ "consulta": "...", "fontes"?: [...], "ler"?: 0-5, "limite"?: 1-10 }`. Sem `SONAR_BUSCA_TOKEN`,
responde 503 (desligado); token errado, 401. Limite padrão: 60 buscas por 10 minutos por endereço
(`SONAR_BUSCA_LIMITE`). Não é para o visitante.

**Status:** 9 testes com fontes simuladas passam. Nenhuma fonte real foi consultada: este ambiente
bloqueia todas (Wikipedia, GDELT, arXiv, Crossref, HN, GitHub responderam 403 pelo proxy). O primeiro
teste real precisa rodar no computador do Grok Bot ou na Vercel.

## Checkpoint de desenvolvimento

Data: 2026-09-26.

### 1. URL de teste

Ainda não há. Falta o projeto Vercel do SONAR e a `XAI_API_KEY` configurada nele (Fase 8: publicar
só quando a pesquisa real funcionar).

### 2. Código

Branch `claude/sonar-website-mvp-dawde4`, pasta `sonar/`.

### 3. Evidência

- `npm test`: 21/21 passam (12 com xAI simulada, 9 da busca própria com fontes simuladas).
- Tela conferida no Chromium (Playwright), em 1280 px e 390 px, com a xAI simulada respondendo em 4 s:
  entrada, etapas acendendo na ordem, resultado com fontes numeradas, avisos de fonte descartada e de
  fato rebaixado; sem rolagem lateral no celular.
- **Nenhuma chamada real à xAI foi feita**: o ambiente de desenvolvimento não tem a chave e bloqueia `api.x.ai`.

### 4. Fluxo executado

Navegador → `POST /api/investigar` → plano → cliente xAI → **xAI simulada** → síntese e conferência de fontes
→ NDJSON com estados → tela de resultado.

### 5. Integrações

| Parte | Documentado | Instalado / configurado | Executado | Validado |
|---|---|---|---|---|
| Interface (entrada, etapas, resultado, falha) | sim | sim | sim (local) | sim, com xAI simulada |
| Endpoint `/api/investigar` e estados | sim | sim | sim (local) | sim, com xAI simulada |
| Conferência de fontes e estados INCOMPLETO/ERRO | sim | sim | sim | sim, com xAI simulada |
| Adaptador de armazenamento | sim | sim (`nenhum`) | sim | sem destino real |
| xAI Responses API | sim | **não** (falta `XAI_API_KEY`) | **não** | **não** |
| `web_search` | sim | código pronto | **não** | **não** |
| `x_search` | sim | código pronto | **não** | **não** |
| `max_turns` / `store` na API REST | sim, com retentativa | código pronto | **não** | **não** |
| Deploy Vercel do SONAR | sim | **não** | **não** | **não** |

### 6. Pendências

1. **Chave da xAI**: criar `XAI_API_KEY` no projeto Vercel do SONAR (decisão e posse do Guardião).
2. **Projeto Vercel** com Root Directory `sonar` e conferência do deploy (lista acima).
3. **Teste real de ponta a ponta** (seção 32 do documento mestre): uma pergunta "novidades de uma tecnologia nesta
   semana" e outra que peça o X. Registrar resposta, fontes, consultas, tempo e custo (`uso_ferramentas` no log).
4. Conferir na resposta real se `citations`, `annotations` e as chamadas de ferramenta vêm no formato que
   `lib/sintese.js` lê. Ajustar o leitor se não vierem.
5. Confirmar o nome do modelo (`XAI_MODEL`) e a aceitação de `max_turns` na REST.
6. O limite de uso é por instância. Antes de divulgar, ligar uma regra de rate limit no Firewall do Vercel.
7. Escolher o destino do armazenamento.
8. Só então: textos do site que declarem capacidade (por exemplo "pesquisa na web e no X") podem entrar.
   Hoje o site não declara nada disso.
