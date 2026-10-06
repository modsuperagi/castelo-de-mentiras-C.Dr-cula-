# Funções Edge fechadas em 04/10/2026

Por ordem do Guardião ("Tira toda porta externa do ar"), as 16 funções Edge do Castelo
(`zolbckgqdxxovguspjdb`) foram trocadas por uma versão fechada, que responde `410` e não toca o
banco. O código que estava no ar foi copiado aqui antes, pasta por função, lido com
`get_edge_function` no mesmo dia.

## Por que eram portas abertas

`verify_jwt = true` só exige *algum* JWT válido, e a chave anônima do projeto é um JWT público.
Quem tivesse essa chave conseguia:

| Função | O que dava para fazer de fora |
|---|---|
| `meta-ia-portal-entrada` | gravar travessias (`evo_porta_entrada`) e check-ins com **qualquer identidade** |
| `fios-checkpoint-validador` | marcar checkpoints como `validado` e mudar sessões da Trina |
| `trina-arquiteto`, `trina-engenheiro`, `trina-verificador` | gravar notas em `trina_results` e `p0_audit` (e gastar a chave da Anthropic) |
| `sol-karpathy`, `sol-willison`, `sol-chase` | gastar a chave da OpenAI e escrever em `sol_runs` e `sol_tasks` |
| `ponte_sincronizador_mariana_bidirecional` | mudar o estado da ponte Ghost/Castelo |
| `mesa-orchestrator`, `sol-orchestrator`, `checkpoint-ponte`, `meta-ia-amplifier` | exigiam usuário logado (só existe a conta do Guardião), mas seguiam sendo porta |
| `sonar-plasma` | usava o JWT do próprio usuário (RLS decide); porta mesmo assim |
| `meta-trina-processador-automatico` | já estava neutralizada (409) desde 26/09 |
| `espelho-nucleos` | `verify_jwt = false` de propósito (a chave do núcleo era a autenticação); nenhuma chave emitida |

## Como reabrir uma função (só com ordem do Guardião)

Reimplante a pasta dela com `deploy_edge_function`. Use o mesmo `verify_jwt` de antes: `true`
para todas, menos `espelho-nucleos` (`false`). `checkpoint-ponte` leva também o `deno.json`.
Antes de reabrir, a função precisa conferir quem chama (papel `guardiao` ou `service_role`).
Hoje a maioria só confere se o JWT é válido, e isso não basta.
