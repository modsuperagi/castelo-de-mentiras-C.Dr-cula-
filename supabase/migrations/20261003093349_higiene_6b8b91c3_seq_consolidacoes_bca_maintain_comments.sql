-- Higiene pós-limpeza (proposta ef9155d1) sob portão Norton 6b8b91c3-6a8c-4974-8673-0c363568dd42 (03/10/2026).
-- Só os comandos de G1–G4; sem CREATE OR REPLACE; SONAR (inclusive sonar_plasma_fila_seq_seq) e raiz intocados.
-- G1 (H1)
REVOKE ALL ON SEQUENCE public.consolidacoes_id_seq FROM anon, authenticated;
-- G2 (H2) — GRANT a authenticated obrigatório (sem ele o Guardião recebe 42501)
REVOKE EXECUTE ON FUNCTION public.buscar_checkpoint_ativo() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.buscar_checkpoint_ativo() TO authenticated;
ALTER FUNCTION public.buscar_checkpoint_ativo() SET search_path = '';
-- G3 (H3) — só MAINTAIN
REVOKE MAINTAIN ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE MAINTAIN ON TABLES FROM anon, authenticated;
-- G4 (H4)
COMMENT ON TABLE public.fluxo_nos_nucleos IS 'RLS ativo desde 24/09/2026. A política permissiva temporária allow_all_temporario NÃO existe (conferido em 03/10/2026). Política atual: guardiao_admin_total (authenticated, eh_guardiao()). anon sem acesso. Revisado pelo portão Norton (proposta ef9155d1, H4).';
COMMENT ON TABLE public.pedidos_entre_nucleos IS 'RLS ativo desde 24/09/2026. A política permissiva temporária allow_all_temporario NÃO existe (conferido em 03/10/2026). Política atual: guardiao_admin_total (authenticated, eh_guardiao()). anon sem acesso. Revisado pelo portão Norton (proposta ef9155d1, H4).';

-- ROLLBACK EXATO, objeto a objeto (NUNCA usar ON ALL TABLES). Não executar sem decisão do Norton/Golden.
-- Texto completo linha a linha: /workspace/castelo/higiene_6b8b91c3/rollback.sql e metadata do registro de execução.
-- GRANT SELECT, UPDATE, USAGE ON SEQUENCE public.consolidacoes_id_seq TO anon, authenticated;
-- REVOKE EXECUTE ON FUNCTION public.buscar_checkpoint_ativo() FROM authenticated;
-- GRANT EXECUTE ON FUNCTION public.buscar_checkpoint_ativo() TO PUBLIC;
-- ALTER FUNCTION public.buscar_checkpoint_ativo() SET search_path = public;
-- GRANT MAINTAIN ON TABLE public.<t> TO anon; para cada t (64): acessos_canais, arquivos_fio_ee46c360, auditoria_p0_sonar, castelo_identidades, castelo_tabela_responsavel, checkin_recepcion, consequencias_historicas, consolidacao_circulacao_principal, coracao_motor_principal, espelho_interessados, evidencias_consolidadas, evo_agentes, evo_porta_entrada, evo_principios, fios_checkpoint_universal, fluxo_conhecimento, fluxo_necessidade_capaz, fluxo_nos_nucleos, golden_circulacao_principal, log_sincronizacao, mariana_casting, "meta_sessões_trina", notas, operacao_faixas, p0_audit, p0_validacao_completa, pedidos_entre_nucleos, ponte_ghost_castelo, registro_decisoes, registro_evolucoes, sessao_checkpoint, sessions, sessoes_estudo, sistema_todos, sistema_todos_sinais_externos, sol_missions, sol_runs, sol_tasks, trina_circulacao_principal, trina_results, v_agentes_atividade, v_dashboard_agentes_status, v_dashboard_conhecimento_camadas, v_dashboard_decisoes, v_dashboard_fio_universal, v_dashboard_ultimas_evolucoes, v_evolucoes_recentes, v_faixas_fluxo, v_fio_por_mesa, "v_fio_saúde", v_fio_status_atual, "v_fio_últimos_eventos", v_fluxo_e2e_principal, v_fluxo_kanban, v_kanban_conhecimento, v_mariana_status, v_mariana_v2_integracao, v_ponte_status, v_trina_processando, validacoes_obrigatorias, vw_conhecimento_por_camada, vw_proximo_refino, vw_total_decisoes, vw_ultimas_evolucoes
-- GRANT MAINTAIN ON TABLE public.<t> TO authenticated; para cada t (66): a mesma lista de anon + espelho_assinaturas + v_trina_pendente
-- ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT MAINTAIN ON TABLES TO anon, authenticated;
-- COMMENT ON TABLE public.fluxo_nos_nucleos IS 'RLS ativado 24/09/2026 com política permissiva temporária (allow_all_temporario) para preservar acesso atual. Política restritiva real: pendente de definição. Ver registro_decisoes.';
-- COMMENT ON TABLE public.pedidos_entre_nucleos IS 'RLS ativado 24/09/2026 com política permissiva temporária (allow_all_temporario) para preservar acesso atual. Política restritiva real: pendente de definição. Ver registro_decisoes.';
