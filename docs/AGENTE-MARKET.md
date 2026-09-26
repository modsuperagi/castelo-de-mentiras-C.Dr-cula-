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

- **Rota:** advogados (Auditoria P0 R$ 2.900 e Mesa Trina R$ 450) e Roteiros (R$ 47). Alvo: 1 Auditoria +
  3 Mesas + 20 Roteiros = R$ 5.190.
- **Todo relatório diário abre com o placar:** soma de `espelho_assinaturas` ativas e encerradas contra a meta,
  inscritos da semana por canal e o estado do pedido `5bcabfe5`.
- **A cada 2 dias, um artigo de busca orgânica** (advogados, TCC, memória de IA), publicado pelo fluxo do espelho.
- **Condições da Mesa:** o pagamento é confirmado pelo Guardião ou pelo Drácula; o Pix só vai ao site se o Drácula
  determinar; a entrega vem só depois do pagamento. Mesa e Auditoria são entregues como relatório escrito em
  Google Doc compartilhado com o comprador.

### Ligar o pagamento depois da inscrição (só por determinação do Drácula ou do Guardião)

O site já pergunta ao Castelo, depois de cada inscrição, se há instruções de Pix (`espelho_instrucoes_pagamento`).
Enquanto `espelho_pagamento_config` estiver desligada, nada aparece. Para ligar, quem determinou roda no Castelo:

```sql
UPDATE espelho_pagamento_config
SET ativo = true, chave_pix = '<chave>', favorecido = '<nome que aparece no Pix>',
    determinado_por = '<Drácula ou Guardião>', determinado_em = now(), atualizado_em = now();
```

Para desligar: `UPDATE espelho_pagamento_config SET ativo = false, atualizado_em = now();`.
Só Roteiros (R$ 47) e Mesa Trina (R$ 450) recebem instruções; o resto continua pelo contato do Guardião.

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

- Não envia e-mail, não cobra, não publica em rede social e não cria conta em nome do Guardião.
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
