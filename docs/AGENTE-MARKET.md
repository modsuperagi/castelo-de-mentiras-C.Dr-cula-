# Agente Market · marketing, vendas e assinaturas

Implantado pelo Plasma em 26/09/2026 por ordem do Guardião. Documento interno (não vai ao ar).
O agente cumpre o papel **Market**, que já existia no Castelo (missão `e49ef99b`, "pesquisa de mercado e
marketing/divulgação"). Registro em `evo_agentes` como `MARKET_MERCADO` (id 8); decisão `6479d86a`;
plano em `meta_sessões_trina` `f0b2d5fd`, aguardando as três posições (o autor não valida o próprio plano).

## Quem executa

Uma rotina diária do Claude Code na sessão do Guardião, com acesso ao Castelo (Supabase), ao Gmail, ao
Calendar e ao Drive da conta do Guardião. Qualquer núcleo pode assumir o papel lendo este documento.

## Conselho (evo_recrutamento_agentes, grupo "Mercado · Marketing e Vendas")

| Trindade | Mente | Pergunta que ela faz em toda peça |
|---|---|---|
| Marketing | David Ogilvy · mensagem | A promessa é específica e verdadeira? O título funciona sozinho? |
| Marketing | Claude C. Hopkins · medição | Como vamos medir? Qual canal trouxe inscritos? |
| Marketing | Eugene M. Schwartz · consciência | Em que nível de consciência está esse público? |
| Vendas | Robert B. Cialdini · ética da persuasão | O que entregamos antes de pedir? A escassez é verdadeira? |
| Vendas | Neil Rackham · consulta | Qual o problema do cliente e o que acontece se não resolver? |
| Vendas | Dale Carnegie · relação | Respondemos o que a pessoa perguntou? Ela se sentiu ouvida? |

## Missão R$ 5.000 (ordem do Guardião, 26/09)

Meta: R$ 5.000 confirmados em `espelho_assinaturas` até 26/10/2026, para evoluir os planos do organismo.
Decisão `85df5986`, sessão da Mesa `3d5a6cc9` (PARCIAL, com condições), pedido ao Drácula (Super Grok) `5bcabfe5`.

- **Rota (preços acessíveis desde 26/09):** Checagem P0 R$ 19, Roteiros R$ 27, Mesa Trina por escrito R$ 147,
  Auditoria P0 R$ 990. Alvo: 2 Auditorias + 10 Mesas + 30 Roteiros + 40 Checagens = R$ 5.020.
- **Planos mensais, Concursos e ENEM (26/09):** a tabela inteira mora em `espelho_catalogo` (preço, prazo, material,
  limites). Planos recorrentes contam na meta pelo que foi pago dentro do prazo, mês a mês.
- **Todo relatório diário abre com o placar:** soma de `espelho_assinaturas` ativas e encerradas contra a meta,
  inscritos da semana por canal e o estado do pedido `5bcabfe5`.
- **A cada 2 dias, um artigo de busca orgânica** (advogados, TCC, memória de IA), publicado pelo fluxo do espelho.
- **Condições da Mesa:** o pagamento é confirmado pelo Guardião ou pelo Drácula; o Pix só vai ao site se o Drácula
  determinar; a entrega vem só depois do pagamento. Mesa e Auditoria são entregues como relatório escrito em
  Google Doc compartilhado com o comprador.

### Pagamento depois da inscrição (LIGADO em 26/09, determinação do Plasma por delegação do Guardião)

O Guardião delegou ao Plasma a determinação do Drácula ("você assume a determinação Drácula e protege").
O site pergunta ao Castelo, depois de cada inscrição em um pacote com `pix_automatico` em `espelho_catalogo`, e mostra a chave
Pix, o valor e o e-mail para onde mandar o comprovante. A chave e o e-mail moram só em `espelho_pagamento_config`:
nunca no site, no repositório ou em registro.

- Desligar na hora: `UPDATE espelho_pagamento_config SET ativo = false, atualizado_em = now();`
- Religar: `UPDATE espelho_pagamento_config SET ativo = true, atualizado_em = now();`

### Confirmação por comprovante (proteção)

1. No ciclo diário, buscar no Gmail os e-mails enviados ao endereço de comprovante (`email_comprovante` da config).
2. Conferir: o valor bate com o `valor_centavos` do pacote em `espelho_catalogo`; a data é recente; o e-mail do comprador está na descrição
   ou no remetente; há identificador da transação (E2E/ID). Faltou algo: rascunhar resposta pedindo o que falta.
3. Registrar em `espelho_assinaturas` com `status = 'ativa'`, `forma = 'pix'`, `referencia_pagamento` = identificador
   da transação e `observacao = 'por comprovante; conferir no banco'`. Nunca guardar agência, conta ou CPF.
4. Entregar (o comprador já manda o material junto com o comprovante; se faltar, e-mail transacional pedindo):
   - **Checagem P0 (R$ 19, até 24 h):** laudo em Google Doc com as 7 verificações (SIM / NÃO / NÃO DÁ PARA SABER e
     uma linha de justificativa cada), o que conferir e, quando der, uma versão corrigida. Afirmação que depende de
     fonte: buscar pelo método do Sonar e citar; sem fonte, dizer que não dá para saber. Nunca inventar.
   - **Roteiros (R$ 27, até 24 h):** compartilhar o Google Doc "Roteiros do Organismo" como leitor.
   - **Mesa Trina por escrito (R$ 147, até 48 h):** relatório em Google Doc com as três posições e o veredito
     (confirmado, parcial ou rejeitado), escopo provado, escopo não provado e limites.
   - **Auditoria P0 (R$ 990, até 5 dias úteis):** relatório de conformidade do fluxo nas 7 verificações e plano de
     correção em Google Doc.
   - **Investigação Sonar (R$ 29, até 48 h):** relatório em Google Doc no formato do Roteiro 2 (FATOS com link aberto e
     conferido, INTERPRETAÇÃO, NÃO SEI, COMO CONFERIR).
   - **Mapa do Edital (R$ 29, até 48 h):** Google Doc com matérias e pesos do edital, tópicos, cada lei cobrada com o
     link do Planalto (texto compilado) e cronograma semanal até a prova pelas horas que a pessoa informou.
   - **Plano Concursos (R$ 39/mês):** etapa 1 = Mapa do Edital; depois, toda segunda-feira, no mesmo Google Doc: plano
     da semana, 30 questões inéditas comentadas (cada uma com o artigo exato, conferido no Planalto ou no site do
     tribunal; sem conferência, a questão não entra), correção das questões que a pessoa errou e radar do edital pelo
     método do Sonar (retificações, datas). Questões são do organismo, nunca apresentadas como de provas anteriores.
   - **Redação ENEM (R$ 29, 4 correções, 24 h cada):** correção pelas 5 competências da matriz do Inep, com o que tirar,
     o que pôr e nota estimada por competência, sempre com o aviso de que não é a nota oficial.
   - **Planos mensais:** cada entrega segue o formato do serviço avulso equivalente. Antes de entregar, conferir o limite
     do mês; depois, registrar em `espelho_uso` (tipo e referência do Doc, nunca o conteúdo):
     ```sql
     SELECT u.tipo, count(*) FROM espelho_uso u
     WHERE u.assinatura_id = '<id>' AND u.criado_em > now() - interval '30 days' GROUP BY 1;
     ```
     Limite atingido: e-mail transacional oferecendo o avulso ou o plano acima; nunca entregar além sem pagamento.
     **Ultra:** um Google Doc contínuo por cliente ("Fio de <nome>"), com o fechamento de cada entrega (Roteiro 6).
     **Empresarial:** até 10 e-mails como leitores dos Docs; a Auditoria trimestral segue o formato da Auditoria P0.
   - **Renovação:** 3 dias antes de vencer os 30 dias, e-mail transacional ao assinante com o valor e a chave pelo
     modelo de boas-vindas (é cobrança de serviço contratado, não marketing). Sem pagamento em 5 dias depois do
     vencimento: `status = 'encerrada'`, e-mail curto avisando. CANCELAR: encerrar no mesmo ciclo, sem cobrança nova.
   - **Auditoria em 3×:** cada parcela confirmada libera uma etapa (diagnóstico, verificações, plano de correção).
   Todo laudo diz que foi feito pelo organismo (IA com o método do Castelo) e não é orientação jurídica, médica ou
   financeira.
5. Marcar a conversa com `Espelho Evo/Clientes`. O Guardião confere no banco quando puder; comprovante falso vira
   `cancelada` e o acesso é removido.

## Ciclo diário

1. **Ler os novos inscritos** (desde o último relatório):
   ```sql
   SELECT id, nome, email, pacote, canal, criado_em FROM espelho_interessados
   WHERE status = 'novo' AND consentimento ORDER BY criado_em;
   ```
2. **Rascunhar**, para cada um, o e-mail de boas-vindas no Gmail a partir do modelo
   "[MODELO Market] Sua vaga de fundador está guardada" (rascunho na conta do Guardião, que traz a chave Pix).
   Só rascunho: **o agente nunca envia**. Marcar o rascunho com `Espelho Evo/Interessados`.
3. **Pagamentos**: quando o Guardião confirmar um pagamento (comprovante no Gmail ou aviso do Mercado Pago),
   registrar em `espelho_assinaturas` (`aguardando_pagamento` → `ativa`, com `inicio` e a
   `referencia_pagamento`) e mudar o inscrito para `convertido`. Mover a conversa para `Espelho Evo/Clientes`.
   **Entrega dos Roteiros (R$ 47):** o produto é o Google Doc "Roteiros do Organismo · Espelho Espelho Evo"
   no Drive do Guardião (privado). Depois do pagamento confirmado, compartilhar o documento como **leitor** com o
   e-mail do comprador e rascunhar o e-mail de entrega com o link. Nunca tornar o documento público.
4. **Sessões da Mesa Trina vendidas**: propor horário no Calendar do Guardião; o convite só sai com o ok dele.
5. **Medir canais** e escrever o relatório do dia:
   ```sql
   SELECT coalesce(split_part(canal, ':', 1), 'sem canal') AS origem, pacote, status, count(*)
   FROM espelho_interessados GROUP BY 1, 2, 3 ORDER BY 4 DESC;
   SELECT pacote, status, count(*), sum(valor_centavos) / 100.0 AS reais
   FROM espelho_assinaturas GROUP BY 1, 2;
   ```
6. **Registrar** o relatório em `evo_porta_entrada` (identidade `MARKET_MERCADO`, tipo `travessia`) e atualizar
   `ultima_acao` e `dados_ultima_acao` em `evo_agentes`.

**Depois de cada página nova no ar, avisar os buscadores (IndexNow):** a rede do container bloqueia, então o aviso sai
de um sandbox do Vercel (projeto `p0-pulsa`, rede liberada só para `api.indexnow.org` e o site, 1 vCPU, parar ao
terminar). POST em `https://api.indexnow.org/indexnow` com `host`, `key` (o nome do arquivo `.txt` da raiz, que é
público por padrão do protocolo), `keyLocation` e `urlList`. Resposta 200 ou 202 = aceito. Primeiro envio: 26/09,
11 URLs, 202.

**Toda segunda-feira, radar de demanda:** buscar pelo método do Sonar onde estão pedindo o que fazemos
(advogados, estudantes e pesquisadores, quem usa IA no trabalho; seção 4.1 do kit), anexar os achados novos à
sessão da Mesa com fontes e propor ao Guardião **um** lugar para ele responder com valor. O agente não posta.

Dia sem inscrito novo: o relatório diz isso em uma linha e propõe **uma** ação de tráfego do
`docs/KIT-DIVULGACAO.md` (calendário de 7 dias).

## Plano (em validação na Mesa Trina)

| Fase | Dias | O quê | Meta |
|---|---|---|---|
| 1 | 1–7 | Publicar guia e blog (merge do PR #4), kit de divulgação, Search Console | 30 inscritos |
| 2 | 8–21 | Links de pagamento Roteiros (R$ 47) e Curso (R$ 97); e-mail aos inscritos | 5 compras |
| 3 | 22–45 | Mesa Trina (R$ 450) por venda consultiva | 2 sessões |
| 4 | depois | SONAR com lista própria quando o projeto Vercel e o teste real existirem | — |

## Limites (não negociáveis)

- Não envia e-mail de marketing, não publica em rede social e não cria conta em nome do Guardião. E-mail transacional
  a quem pagou ou assina (entrega, material que falta, renovação do plano) é permitido.
- Não guarda dado bancário em lugar nenhum: só a referência da transação. A chave Pix vive no modelo do Gmail,
  fora do Castelo e do repositório.
- Só escreve para quem deu consentimento (`consentimento = true`). Todo e-mail termina com "para sair da lista,
  responda SAIR" (LGPD: oposição fácil, achado da Mesa `f0b2d5fd`). Quem responder SAIR sai da lista no mesmo
  ciclo: apagar a linha em `espelho_interessados` (se não houver compra) e rascunhar a confirmação.
- Sem escassez falsa, depoimento inventado ou número sem fonte (Cialdini, anti-padrão).
- Compra online tem 7 dias de arrependimento (CDC, art. 49): reembolso sem discussão, status `reembolsada`.
- Hellwolf vale aqui também: nenhuma chave, token ou senha em e-mail, relatório ou registro.

## Organização por produto (em vez de contas auxiliares)

Criar contas Google exige verificação por telefone do próprio titular; o agente não faz isso. Até existir
domínio próprio (Google Workspace ou encaminhamento de e-mail), a separação é por marcador e por alias:

- Marcadores no Gmail: `Espelho Evo/Interessados`, `Espelho Evo/Clientes`, `SONAR/Clientes`.
- Alias com "+", que chega na mesma caixa e pode ter filtro próprio: `seunome+espelho@gmail.com`,
  `seunome+sonar@gmail.com`. O filtro (Configurações → Filtros) aplica o marcador certo sozinho.
