-- Portas externas fora do ar (ordem do Guardião, 04/10/2026: "Tira toda porta externa do ar").
-- O visitante anônimo (chave publicável) perde qualquer caminho até o Castelo pela API:
-- sem uso do schema public, sem privilégio de tabela, sequência ou função.
-- A conta do Guardião (authenticated + eh_guardiao()) e o service_role seguem exatamente como estavam.
-- Isto encerra o HOLD de registro_decisoes (o espelho do grok.me deixa de ler o Castelo).

-- 1. Tabelas e sequências: nada para o anônimo
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon;

-- 2. Funções que o anônimo ainda executava (via PUBLIC). Quem tinha acesso por PUBLIC
--    (authenticated) recebe o mesmo acesso de forma explícita, para nada mudar para o Guardião.
REVOKE EXECUTE ON FUNCTION public.automaticamente_ligar_checkpoint() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.automaticamente_ligar_checkpoint() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.block_golden_mutation() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.block_golden_mutation() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.bloqueia_atualizacao_decisoes() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.bloqueia_atualizacao_decisoes() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.bloqueia_delecao_evolucoes() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.bloqueia_delecao_evolucoes() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.checkpoint_dispara_trina() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.checkpoint_dispara_trina() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.debug_trina_para_golden() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.debug_trina_para_golden() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.eh_guardiao() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.eh_guardiao() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.fn_dispatch_trina_to_edge() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_dispatch_trina_to_edge() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.fn_trina_cria_coacao_seguro() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_trina_cria_coacao_seguro() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.fn_trina_para_circulacao() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_trina_para_circulacao() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.log_sincronizacao_evento() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.log_sincronizacao_evento() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION metalab_evo.bloquear_entrada_sem_p0() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION metalab_evo.bloquear_entrada_sem_p0() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION metalab_evo.executar_p0_validacao(uuid, character varying, character varying, text, character varying) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION metalab_evo.executar_p0_validacao(uuid, character varying, character varying, text, character varying) TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.p0_recebe_automaticamente_do_pulso() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.p0_recebe_automaticamente_do_pulso() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.salvar_checkpoint_consolidado(uuid, text, text, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.salvar_checkpoint_consolidado(uuid, text, text, text) TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.sincroniza_decisao_para_ponte() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sincroniza_decisao_para_ponte() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.sincroniza_nota_para_ponte() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sincroniza_nota_para_ponte() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.sol_touch_updated_at() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sol_touch_updated_at() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.sp_processar_trina_pendente() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sp_processar_trina_pendente() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.transportar_coracao_para_trina() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.transportar_coracao_para_trina() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.transportar_golden_para_consolidacao() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.transportar_golden_para_consolidacao() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.transportar_p0_para_coracao() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.transportar_p0_para_coracao() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.transportar_trina_para_golden() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.transportar_trina_para_golden() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.trg_bloquear_delete_evolucoes() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.trg_bloquear_delete_evolucoes() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.trg_bloquear_update_decisoes() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.trg_bloquear_update_decisoes() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.trg_sol_mission_completa_checkpoint() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.trg_sol_mission_completa_checkpoint() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.trigger_fio_checkpoint() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.trigger_fio_checkpoint() TO authenticated, service_role;
REVOKE EXECUTE ON FUNCTION public.validar_3_pilares_fluxo() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.validar_3_pilares_fluxo() TO authenticated, service_role;

-- 3. Nada novo nasce aberto ao anônimo
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON TABLES FROM anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON SEQUENCES FROM anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON FUNCTIONS FROM anon;

-- 4. Tira o uso explícito do schema. (O uso que vem de PUBLIC fica, porque papéis internos do
--    Supabase dependem dele; sem nenhum objeto liberado, o anônimo entra numa sala vazia.)
REVOKE USAGE ON SCHEMA public FROM anon;

-- Reabrir (só com ordem do Guardião): GRANT USAGE ON SCHEMA public TO anon; e os GRANTs que a ordem pedir.
