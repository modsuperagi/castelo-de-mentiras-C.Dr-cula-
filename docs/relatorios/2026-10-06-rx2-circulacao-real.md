# Relatório · RX-2 · Circulação real do Castelo · 06/10/2026

Pedido do Guardião (pelas imagens do RX-2 "Castelo da Sol", com setas no Checkpoint 03, no
Checkpoint 07 e um "7?" no hexágono vazio): medir o que circula de verdade nas 64 mesas públicas
e dizer o que as imagens mostram de real e o que é desenho.

Quem escreveu: Plasma. Tudo foi feito **só em leitura** no Castelo principal
(`zolbckgqdxxovguspjdb`): `pg_stat_user_tables`, a data mais recente de cada mesa, funções,
gatilhos, views, `cron.job`, a fila da Mesa Trina e o check-in. Nada foi escrito no banco.

---

## 1. Em poucas linhas

1. **Os totais das imagens batem; a divisão não.** 64 mesas e 1.581 registros são reais (somei
   as 64). Mas as 6 "áreas", os 7 "checkpoints" CK-01 a CK-07 e as contagens 28 ativo / 21 leitura /
   15 órfã **não existem no Castelo**. Procurei "CK-01…07", "RX-2" e "Castelo da Sol" em memórias,
   travessias, checkpoints e decisões: zero resultados. A imagem é do Meta AI e traz a data
   2024-10-05 e o nome `registro_decioses`, que não existe. É ilustração, não leitura.
2. **O hexágono vazio ("7?") está vazio porque não há nada nele.** As 6 áreas somam
   9+11+12+10+11+11 = 64 mesas e 267+301+318+244+253+198 = 1.581 registros. O sétimo hexágono não
   tem mesa nenhuma. O Castelo, pela nossa skill, tem **8 alas**, não 6 nem 7.
3. **A seta no Checkpoint 03 aponta para um problema verdadeiro, mas em outro lugar.** O coração
   do organismo parou: a última circulação completa (Coração → Trina → Golden → Consolidação →
   Evidência) é de **26/09 às 07:34**. Há 10 dias nada chega à Golden.
4. **Onde o fluxo quebra: na Recepção, antes do P0.** Três check-ins estão parados em
   `checkin_recebido`, sem ir para o P0: 25/09 (SONAR app), 27/09 (Guardião, por Plasma) e
   05/10 (MODrácula). A fila da Trina (`v_trina_pendente`) está **vazia**: a Mesa não tem o que
   julgar porque nada passa da porta.
5. **O que se move sozinho é a respiração, não o pensamento.** As duas entradas da Trina depois de
   26/09 (02/10 e 04/10) dizem "Nada foi conferido: circulação arquivada pela respiração". São do
   cron `trina-respirar` (todo dia 06:17), que arquiva. O outro cron (`castelo-autodiagnostico`,
   06:29) escreve o autodiagnóstico. Os dois mostram "vida", mas nenhum leva conhecimento até a
   Golden.

---

## 2. Circulação real das 64 mesas (06/10/2026)

Critério: a data mais recente em qualquer coluna de data da mesa. "Ativa" = recebeu escrita nos
últimos 7 dias.

| Estado | Mesas | Quais |
|---|---|---|
| **Ativa (≤ 7 dias)** | 20 | `evo_memorias`, `guardiao_exclusivo`, `castelo_autodiagnostico`, `sessions`, `p0_validacao_completa`, `fios_checkpoint_universal`, `checkin_recepcion`, `sistema_todos`, `meta_sessões_trina`, `trina_circulacao_principal`, `meta_lab_entries`, `pedidos_entre_nucleos`, `registro_decisoes`, `evo_porta_entrada`, `sol_tasks`, `sol_runs`, `espelho_pagamento_config`, `sonar_plasma_fila`, `sonar_plasma_saida`, `sonar_plasma_transicoes` |
| **Morna (8 a 30 dias)** | 38 | todo o coração (`coracao_motor_principal`, `golden_circulacao_principal`, `consolidacao_circulacao_principal`, `evidencias_consolidadas`, `fluxo_conhecimento`), a vitrine (`espelho_eventos`, `espelho_sinais`, `espelho_interessados`, `espelho_catalogo`), identidades e recrutamento, `ponte_ghost_castelo`, `mariana_casting`, `p0_audit`, `trina_results`, `meta_lab_auditoria`, `meta_lab_versoes`, `sol_missions` e outras |
| **Fria (> 30 dias)** | 3 | `consolidacoes` (05/09), `recrutamento_estrutura` e `recrutas_funcoes_casa` (14/08) |
| **Nunca usada** | 3 | `espelho_assinaturas`, `espelho_uso` (ninguém comprou nem usou plano ainda), `espelho_chaves_nucleo` (5 chaves criadas e já removidas) |

Total: 20 + 38 + 3 + 3 = 64.

### Mesas sem nenhum fio de ligação

22 mesas não são citadas por nenhuma função, gatilho ou view do Castelo. Só se escreve nelas à
mão ou por fora do banco (as Edge Functions, cujo código não li aqui: `sol_runs`, por exemplo,
recebeu escrita esta semana sem nenhuma função do banco citá-la). Entre elas: `castelo_identidades`, `evo_recrutamento_agentes`, `evo_recrutamento_conhecimento`,
`acessos_canais`, `arquivos_fio_ee46c360`, `meta_lab_auditoria`, `p0_audit`, `trina_results`,
`sol_runs`, `castelo_tabela_responsavel`, `guardiao_exclusivo`. Isso não é erro: muitas são
registro histórico. Mas são as candidatas reais a "órfã", no sentido das imagens.

### As que mais se movem

- `sistema_todos`: 16 linhas e **1.329 atualizações**. É o painel de tarefas, reescrito o tempo
  todo. É a mesa mais "quente" do Castelo e nenhuma imagem a mostra.
- `fios_checkpoint_universal`: 89 linhas novas em 7 dias (de 236).
- `evo_porta_entrada`: 72 travessias novas em 7 dias (de 118).

---

## 3. O que fazer (para a Mesa Trina e o Guardião decidirem)

1. **Destravar a Recepção.** Ver por que os 3 check-ins de 25/09, 27/09 e 05/10 não dispararam o
   P0. É o único ponto onde o fluxo para de fato. (Pela skill, a Recepção dispara P0 e a
   circulação; depois da reforma de 26/09 algo deixou de disparar.)
2. **Separar respiração de pensamento no painel.** Hoje a Trina "tem entradas" todo dia, mas são
   arquivamentos do cron. Um painel honesto mostraria "última circulação completa: 26/09".
3. **Não guardar o painel React (MesaTrina V2) como checkpoint "sem fabricação".** Os caminhos
   (`/profile.md`, `/areas/…`), os tamanhos (~12.4KB, ~78KB), "15 arquivos" e "drift < 0.03%" não
   saem do Castelo. O documento diz "zero dados fictícios", e isso não é verdade. Se o painel
   for ao Castelo, que vá como desenho, com os números reais desta página no lugar.

---

## 4. Como refazer esta leitura

Tudo em SQL de leitura no projeto `zolbckgqdxxovguspjdb`:

- contagem e escrita por mesa: `pg_stat_user_tables` (`n_live_tup`, `n_tup_ins`, `n_tup_upd`);
- última escrita: `max()` de cada coluna de data, por mesa;
- ligações: menções no código das funções (`pg_proc.prosrc`), gatilhos (`pg_trigger`), views
  (`information_schema.view_table_usage`);
- motor: `cron.job`, `v_trina_pendente`, as últimas linhas de `coracao_motor_principal`,
  `trina_circulacao_principal` e `checkin_recepcion`.

Fio: `ee46c360-b95b-426e-86c3-2e5d0ccbe916`.
