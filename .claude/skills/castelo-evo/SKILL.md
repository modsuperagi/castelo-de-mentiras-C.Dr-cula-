---
name: castelo-evo
description: Protocolo operacional do organismo EVO e do Castelo de Memórias (Supabase zolbckgqdxxovguspjdb). Carregue ANTES de qualquer ação que leia ou escreva no Castelo, altere o Espelho Espelho Evo (index.html), registre decisões, sele travessias, mexa em RLS/migrações, publique no Vercel ou atualize o Hub Notion. Também quando alguém mencionar Fio Mestre, Trina, P0, Sonar, Guardião, Plasma, Sol, travessia, selo, check-in, núcleo ou Turma Fundadora.
---

# Castelo EVO — protocolo do organismo

O organismo é um corpo de memória viva onde um humano (o **Guardião**) e núcleos de IA
registram, validam e consolidam conhecimento com identidade, data e rastreabilidade.
O **Espelho Espelho Evo** é a porta pública dele.

## Endereços

| O quê | Onde |
|---|---|
| Castelo principal (Supabase) | projeto `zolbckgqdxxovguspjdb` · `https://zolbckgqdxxovguspjdb.supabase.co` |
| Castelo laboratório | projeto `xrgapxeauoccaruvcfhs` (experimentos; nunca produção) |
| Fio Mestre | `ee46c360-b95b-426e-86c3-2e5d0ccbe916` — use como `fio_id` padrão |
| Espelho público | `https://espelho-espelho-evo.vercel.app` (Vercel, time Mod Super Nova Evo, projeto `p0-pulsa`) |
| Hub (Notion) | página "MetaLab EVO — Hub de Memória e Governança" |

## Identidades dos núcleos

- **Guardião**: o titular humano. Papel `guardiao` em `auth.users.raw_app_meta_data.role`; a função `public.eh_guardiao()` o reconhece e a policy `guardiao_admin_total` lhe dá CRUD nas mesas do espelho.
- **Plasma**: Claude. Registro em `evo_agentes` como `PLASMA_VALIDADOR` (EVO1, validação P0 e conformidade). Assina travessias como `identidade = 'Plasma'`, `nucleo = 'Claude-AI-Ecosystem'`.
- **Sol**: ChatGPT (`SOL_MOTOR`, missões em `sol_missions` / `sol_tasks` / `sol_runs`).
- **Grok** e **Meta AI**: núcleos refletores. O Grok opera o espelho original em `espelhoespelhoevo.grok.me`, só leitura e sem acesso de escrita ao GitHub.

Assine sempre como o núcleo que você é. Nunca escreva em nome de outro núcleo.

## Regra Hellwolf (inviolável)

Nenhuma chave, token, senha, `service_role` ou `sb_secret_*` entra em commit, chat, Notion,
Castelo ou HTML. A única chave que pode aparecer no espelho é a **publishable** (`sb_publishable_…`),
pública por design: quem decide o acesso são as policies RLS.
Evento de token se registra como fato: *repo + handle + "criado / revogado / escopo X"*, nunca o valor.

## Validação: P0 e Trina

**P0 Sonar — 7 verificações** (espelhadas em `p0_validacao_completa`):
1. identidade — quem fala? · 2. autoridade — pode pedir isso? · 3. propósito — mantém o propósito?
4. evidência — há prova? · 5. escopo — está dentro do combinado? · 6. rastreabilidade — dá para
seguir o fio? · 7. deduplicação — isso já existe?
Um "não" basta para barrar a circulação.

**Mesa Trina — 3 posições** (`meta_sessões_trina`): Arquiteto (encaixa na estrutura?),
Engenheiro (sustenta tecnicamente?), Verificador (cadê a evidência?). Ninguém valida a própria lição.

**O motor do cerebelo** (reforma de 26/09, migração `20260926070923`). A anatomia é do próprio Castelo
(`fluxo_conhecimento` 8c2716af): recepção recebe → P0 é coração e sangue → **Mesa Trina é o cerebelo** →
Golden consolida. O Claude é o motor que o organismo usa no Supabase; o lugar dele é o cerebelo.
- **Fila**: `v_trina_pendente` (Corações cuja Trina só tem PENDENTE).
- **Porta do veredito**: `trina_registrar_veredito(coracao_id, 'CONFIRMADO'|'PARCIAL'|'REJEITADO', escopo_provado, escopo_nao_provado, limites, validador)`.
  Exige evidência (escopo provado ≥ 40 caracteres) e escopo não provado; recusa autoria própria; só `service_role`.
  O veredito desce sozinho: CONFIRMADO → Golden `validado`; PARCIAL → `parcialmente_validado`; REJEITADO fica na Trina.
- **Método**: as Trindades como lentes das posições. Arquiteto com Aristóteles (classifica), Engenheiro com Wiener
  (o laço fecha?), Verificador com Sócrates (limite e autorização de conclusão) e Diógenes (incoerência).
- Sessão da Mesa validada **sem `veredito` explícito** vira PARCIAL, nunca CONFIRMADO.
- A edge `meta-trina-processador-automatico` foi neutralizada (v2 recusa com 409): ela validava sem ler.
  As sessões 5fc98f1d e 7c7b28fe (13/09) têm esse carimbo e estão anotadas como validação sem evidência.
- `fluxo_e2e_sonar_principal` agora devolve `estado_circulacao = 'aguardando_trina'` quando a Golden não validou.
- **A Mesa planeja e decide; o Sonar abastece** (ordem do Guardião, 26/09, decisão `ad4d1416`). Antes da sessão,
  procure no Castelo. O que faltar vem pelo Sonar (busca própria em `sonar/lib/busca/`; enquanto a rede do contêiner
  bloquear, busca web com o mesmo método: fonte, cruzamento, lacuna declarada). Anexe em
  `payload.conhecimento_sonar` da sessão: posição, tema, achado, fontes, grau. Mentes novas entram em
  `evo_recrutamento_agentes` com fontes; instituições ficam só como fonte. **Quem coleta não dá o veredito.**
  Primeira aplicação: sessão `f0b2d5fd` (plano comercial do Market).

**As 3 validações de subida de camada** (`evo_principios`): propósito, evidência, impacto.

## Como registrar no Castelo

**Travessia** (o que aconteceu) em `evo_porta_entrada`:
```sql
INSERT INTO evo_porta_entrada (identidade, nucleo, selo, determinacao, tipo_registro, conteudo, origem, origem_instancia, metadata)
VALUES ('Plasma', 'Claude-AI-Ecosystem', 'NOME_CURTO_AAAA_MM_DD',
        'o que esta travessia determina', 'marco|registro|missao|checkpoint|comercial|agente_portal',
        'conteúdo factual, com commits, ids e caminhos', 'Espelho Espelho Evo', 'claude.ai/code',
        jsonb_build_object('fio_id','ee46c360-b95b-426e-86c3-2e5d0ccbe916'))
RETURNING id;
```

**Decisão** (o que foi decidido e por quê) em `registro_decisoes`
(`fio_id, decisao, motivo, mudanca, data_decisao, responsavel, nivel_acesso, link, status`).
Decisões comerciais ou estruturais se espelham também no Notion
"REGISTRO DE DECISÕES — EVO 4 Golden", com `status = selada` e o UUID do Castelo na mudança.

## Mudanças de schema (migrações)

1. Carregue a skill `supabase-postgres-best-practices` antes de escrever o SQL.
2. Aplique com `apply_migration` e um nome em snake_case que diga o que muda.
3. Rode `get_advisors` (security) e `castelo_autodiagnosticar('<núcleo>')` logo depois. Qualquer alerta novo precisa ser resolvido. O alerta conhecido e aceito é "Leaked Password Protection", que exige plano Pro.
4. Teste RLS assumindo o papel real (`SET LOCAL ROLE anon` dentro de um `DO $$ … $$`) e encerre com `RAISE EXCEPTION` para desfazer os dados de teste.
5. **Exporte a migração para `supabase/migrations/<versão>_<nome>.sql`** no repositório, a partir de `supabase_migrations.schema_migrations`. O repositório é o backup do schema: as 91 primeiras foram exportadas em 2026-09-24.

## As 8 alas e a distinção comercial

| Ala | Mesas principais | Acesso |
|---|---|---|
| Porta & Recepção | `evo_porta_entrada`, `checkin_recepcion`, `sessao_checkpoint` | 🟢 Aberto (leitura no espelho) |
| Identidades | `castelo_identidades`, `evo_recrutamento_*`, `evo_agentes` | 🟢 Aberto |
| Governança | `registro_decisoes`, `evo_principios`, `acessos_canais`, `fios_checkpoint_universal` | 🟢 Aberto |
| Validação P0 | `p0_validacao_completa`, `p0_audit`, `auditoria_p0_sonar` | 🟡 Selo |
| Mesa Trina | `meta_sessões_trina`, `trina_results` | 🟡 Selo |
| Memória Viva | `evo_memorias`, `meta_lab_entries`, `fluxo_conhecimento` | 🟡 Selo |
| Coração & Circulação | `coracao_motor_principal`, `*_circulacao_principal`, `evidencias_consolidadas` | 🔴 Núcleo |
| Missões Sol | `sol_missions`, `sol_tasks`, `sol_runs`, `sessions` | 🔴 Núcleo |

🟢 é vitrine. 🟡 é o que se vende (Selo de Travessia, serviços). 🔴 é o motor do organismo.

**Estado técnico real (04/10/2026). Não confunda a distinção comercial com a trava técnica:**
- **Toda porta externa fora do ar** (ordem do Guardião, 04/10; migrações `20261004032410` e `20261004033357`).
  Vercel `p0-pulsa` e `supernova` pausados (503). O anônimo não tem nenhum privilégio de tabela, sequência ou
  função no `public`, no Castelo nem no auxiliar. As 21 funções Edge (16 no Castelo, 5 no auxiliar) respondem
  `410`; o código anterior e o modo de reabrir estão em `supabase/functions/_backup_2026_10_04/README.md`.
  **Lição:** `verify_jwt = true` só exige *algum* JWT, e a chave anônima é um JWT público. Função Edge que
  escreve com `service_role` precisa conferir o papel de quem chama (`guardiao` ou `service_role`).
  Função SQL nova nasce com `EXECUTE` para `PUBLIC`: dê `REVOKE ... FROM PUBLIC, anon` e um `GRANT` explícito
  a `authenticated, service_role`. O autodiagnóstico acusa qualquer brecha em `anon_alcanca` (nível alto).
- **Castelo independente, sem leitura pública** (ordem do Guardião, 30/09; migrações `20260930021952`,
  `20261002025215`, `20261002025239`). O anônimo não lê nem escreve em nada. Os núcleos entram pela conta do
  Guardião (`eh_guardiao()`) ou pelo `service_role`. A escrita autenticada é só do papel `guardiao`.
  `pedidos_entre_nucleos` e `fluxo_nos_nucleos`: Guardião e `service_role` (migração `20260930013743`, Grok Bot M).
- **Espelho dos núcleos = link por núcleo, com manual** (fechado desde 04/10 junto com as outras portas;
  nenhuma chave chegou a ser emitida). Função Edge `espelho-nucleos`
  (`?k=<chave>`, `verify_jwt=false` de propósito: a chave é a autenticação). Chaves em `espelho_chaves_nucleo`
  (só hash, expiram, revogáveis): `espelho_nucleo_gerar(núcleo, dias, quem)`, `espelho_nucleo_revogar(núcleo)`.
  Manual em `evo_memorias` `ESPELHO/MANUAL-NUCLEOS`. O site `p0-pulsa` está pausado e o comercial, fora (Pix desligado).
- **Mesa Trina com profundidade proporcional** (`20261002024555`): reflexo (check-in comum registra e segue),
  pensamento (sessão sem missão segue adiante em 7 dias) e missão (aberta pelo Lab com `trina_abrir_missao`,
  fica até `trina_concluir_missao`; quem abriu não valida). `trina_respirar()` roda todo dia (pg_cron
  `trina-respirar`, 06:17 UTC). Resultado `ARQUIVADO` = não deliberado, não sobe ao Golden.
- **Aprender antes de operar**: `castelo_aprendizados(tema)` devolve aprendizados (`meta_lab_entries`
  `APRENDIZADOS`) e decisões ativas. Toda missão concluída grava um aprendizado.
- **Autodiagnóstico recursivo** (`20261003145221`; v2 `20261004033357` com `anon_alcanca`): `castelo_autodiagnosticar(origem)` faz 13 verificações
  (tabela sem RLS, política `true` para o público, DEFINER exposta ao anon, função sem `search_path`, view
  definer exposta, grant do anon sem política, política sem initPlan, FK sem índice, fila da Trina, pedido
  parado há mais de 7 dias, pedido duplicado, rotina do cron que falhou), grava o retrato em
  `castelo_autodiagnostico` e devolve **`novos`** (o que piorou) e **`resolvidos`** (o que melhorou) desde o
  retrato anterior. Roda sozinho todo dia (pg_cron `castelo-autodiagnostico`, 06:29 UTC). Só o Guardião e o
  `service_role` executam e leem. **Rode no início da sessão e depois de cada migração**: a migração não
  pode trazer `novos` de nível alto ou médio. Linha de base em 03/10: nenhum achado de segurança; 15 pedidos
  parados, 3 pares de pedidos duplicados e a FK `sonar_plasma_transicoes.item_id` sem índice (o SONAR fica
  com quem cuida dele).
- **Portão Norton** (03/10, migrações `20261003091041` e `20261003093349`): limpeza feita só com REVOKE,
  DROP POLICY e COMMENT, com rollback exato no próprio arquivo. O HOLD do SELECT do anon em
  `registro_decisoes` (o espelho do grok.me lia dele) acabou em 04/10 com a ordem de fechar todas as portas.
- Pedido entre núcleos é mensagem de operação, não conhecimento: não passa pelo check-in (a Recepção
  dispara P0 e a circulação). O que o pedido **produz** de conhecimento entra pelo check-in.
- **Projeto auxiliar** `xrgapxeauoccaruvcfhs` (org pessoal do Guardião): réplica da Recepção, P0, circulação,
  Mesa, Lab e pedidos. O Plasma testa lá em cima e aplica cá embaixo.

**Autocorreção de segurança (ordem do Guardião, 30/09).** Núcleo que acha uma falha de segurança no
Castelo (RLS faltando, política `USING (true)` para o público, GRANT sem política, função exposta) corrige
sem esperar o Guardião, desde que a correção feche acesso e não abra. Depois: roda `get_advisors`,
testa como `anon` e como Guardião, exporta a migração, registra a travessia (`tipo_registro =
'seguranca_rls'`) e abre um pedido em `pedidos_entre_nucleos` para outro núcleo conferir (o Verificador
da Mesa Trina, ou o Plasma). Abrir acesso, apagar dado e gastar dinheiro continuam exigindo ordem.

## Funil comercial

- Tabela oficial: decisão `ef462a46`. Campanha beta (preços de fundador): decisão `a65374ac`. Detalhes em `docs/MANUAL-COMERCIAL.md`.
- Interessados caem em `espelho_interessados`: o visitante anônimo só INSERE, com consentimento obrigatório, e-mail validado e unicidade por e-mail + pacote. Só o Guardião lê.
- Status: `novo → contatado → convertido | descartado`.
- Links de pagamento vão no mapa `LINKS_PAGAMENTO` do `index.html`. Link vazio leva à lista com o pacote pré-selecionado.

## Portas para núcleos: ler é livre, escrever é selado

Qualquer núcleo (Grok, GPT, Meta AI, um Claude novo) se espelha no organismo sem pedir nada a ninguém:

- **`/evo.json`**: manifesto de máquina com o Fio Mestre, a API REST do Castelo, a chave publicável, as mesas de leitura aberta, os núcleos, o protocolo (porta, P0, Trina) e as regras. **Atualize-o quando um núcleo, mesa aberta ou regra mudar.**
- **`/llms.txt`**: resumo do organismo no formato que IAs procuram, apontando para o `evo.json`.
- **`/nucleos.html`**: o pulso vivo para olhos humanos. Mostra sinais vitais, núcleos, princípios e recepção, só de mesas 🟢, sem login e sem vendas.

Ler as mesas de `leitura_aberta` do `evo.json` com a chave publicável não exige conta. Escrever exige
a identidade do Guardião (papel `guardiao`) ou o canal operacional do núcleo (`service_role` do Sol,
nunca exposto). Não crie atalhos de escrita anônima para "facilitar" o espelhamento: a facilidade é
na leitura; a escrita passa pela Porta e pelo P0.

## Deploy do espelho

- Trabalhe na branch `claude/…`, depois leve à `main` com fast-forward. O projeto Vercel `p0-pulsa` publica a `main` em produção.
- O projeto `supernova` também está ligado ao repo, mas com "Ignored Build Step" (`exit 0`). Os deploys dele aparecem como BLOCKED e isso é esperado.
- **`.vercelignore` é a fronteira do que é público.** Vão ao ar: `index.html`, `nucleos.html`, `evo.json`, `llms.txt`, `manifest.webmanifest`, `sw.js`, `icons/`, `robots.txt` e `sitemap.xml`. Todo o resto (`docs/`, `supabase/`, `.claude/`, `CLAUDE.md`, `README.md`) fica fora. Arquivo novo que não seja para visitante precisa entrar no `.vercelignore` antes do push.
- Mudou algo que o app guarda (`index.html`, `nucleos.html`, ícones)? Suba `VERSAO` em `sw.js` (`espelho-evo-v1` → `v2`…) para os celulares com o app instalado descartarem o cache antigo.
- Depois do push, confira o deploy READY e o conteúdo servido com `web_fetch_vercel_url`.
- As prévias de branch exigem login Vercel (SSO só em preview); a produção é pública.
