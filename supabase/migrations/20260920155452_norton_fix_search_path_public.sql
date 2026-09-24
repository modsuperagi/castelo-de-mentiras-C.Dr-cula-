-- Migração 20260920155452 · norton_fix_search_path_public
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- Norton: fix search_path mutável (advisor 0011). Reversível com ALTER ... RESET search_path.
ALTER FUNCTION public.automaticamente_ligar_checkpoint() SET search_path = public;
ALTER FUNCTION public.block_golden_mutation() SET search_path = public;
ALTER FUNCTION public.bloqueia_atualizacao_decisoes() SET search_path = public;
ALTER FUNCTION public.bloqueia_delecao_evolucoes() SET search_path = public;
ALTER FUNCTION public.buscar_checkpoint_ativo() SET search_path = public;
ALTER FUNCTION public.checkpoint_dispara_trina() SET search_path = public;
ALTER FUNCTION public.debug_trina_para_golden() SET search_path = public;
ALTER FUNCTION public.fluxo_e2e_sonar_principal(uuid, character varying, character varying, text, character varying, character varying) SET search_path = public;
ALTER FUNCTION public.fn_dispatch_trina_to_edge() SET search_path = public;
ALTER FUNCTION public.fn_trina_cria_coacao_seguro() SET search_path = public;
ALTER FUNCTION public.fn_trina_para_circulacao() SET search_path = public;
ALTER FUNCTION public.ligar_checkin_ao_checkpoint(uuid, uuid) SET search_path = public;
ALTER FUNCTION public.log_sincronizacao_evento() SET search_path = public;
ALTER FUNCTION public.salvar_checkpoint_consolidado(uuid, text, text, text) SET search_path = public;
ALTER FUNCTION public.sincroniza_decisao_para_ponte() SET search_path = public;
ALTER FUNCTION public.sincroniza_nota_para_ponte() SET search_path = public;
ALTER FUNCTION public.sol_touch_updated_at() SET search_path = public;
ALTER FUNCTION public.sp_processar_trina_pendente() SET search_path = public;
ALTER FUNCTION public.transportar_coracao_para_trina() SET search_path = public;
ALTER FUNCTION public.transportar_golden_para_consolidacao() SET search_path = public;
ALTER FUNCTION public.transportar_p0_para_coracao() SET search_path = public;
ALTER FUNCTION public.transportar_trina_para_golden() SET search_path = public;
ALTER FUNCTION public.trg_bloquear_delete_evolucoes() SET search_path = public;
ALTER FUNCTION public.trg_bloquear_update_decisoes() SET search_path = public;
ALTER FUNCTION public.trg_sol_mission_completa_checkpoint() SET search_path = public;
ALTER FUNCTION public.trigger_fio_checkpoint() SET search_path = public;
ALTER FUNCTION public.validar_3_pilares_fluxo() SET search_path = public;
