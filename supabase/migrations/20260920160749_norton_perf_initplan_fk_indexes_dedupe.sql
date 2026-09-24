-- Migração 20260920160749 · norton_perf_initplan_fk_indexes_dedupe
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- Norton: fechar WARNs performance seguros (initplan, FK indexes, índices duplicados).
-- Sem alterar superfície de acesso anon. Portal JWT intocado.

-- 1) auth_rls_initplan: (select auth.uid())
DROP POLICY IF EXISTS sol_missions_owner_select ON public.sol_missions;
CREATE POLICY sol_missions_owner_select ON public.sol_missions
  FOR SELECT TO public
  USING ((SELECT auth.uid()) = created_by);

DROP POLICY IF EXISTS sol_missions_owner_insert ON public.sol_missions;
CREATE POLICY sol_missions_owner_insert ON public.sol_missions
  FOR INSERT TO public
  WITH CHECK ((SELECT auth.uid()) = created_by);

DROP POLICY IF EXISTS sol_missions_owner_update ON public.sol_missions;
CREATE POLICY sol_missions_owner_update ON public.sol_missions
  FOR UPDATE TO public
  USING ((SELECT auth.uid()) = created_by)
  WITH CHECK ((SELECT auth.uid()) = created_by);

DROP POLICY IF EXISTS sol_tasks_owner_select ON public.sol_tasks;
CREATE POLICY sol_tasks_owner_select ON public.sol_tasks
  FOR SELECT TO public
  USING (EXISTS (
    SELECT 1 FROM sol_missions m
    WHERE m.id = sol_tasks.mission_id AND m.created_by = (SELECT auth.uid())
  ));

DROP POLICY IF EXISTS sol_runs_owner_select ON public.sol_runs;
CREATE POLICY sol_runs_owner_select ON public.sol_runs
  FOR SELECT TO public
  USING (EXISTS (
    SELECT 1 FROM sol_missions m
    WHERE m.id = sol_runs.mission_id AND m.created_by = (SELECT auth.uid())
  ));

DROP POLICY IF EXISTS "núcleo_apenas" ON public.castelo_identidades;
CREATE POLICY "núcleo_apenas" ON public.castelo_identidades
  FOR ALL TO public
  USING ((SELECT auth.uid()) IS NOT NULL)
  WITH CHECK ((SELECT auth.uid()) IS NOT NULL);

DROP POLICY IF EXISTS validacoes_privado ON public.validacoes_obrigatorias;
CREATE POLICY validacoes_privado ON public.validacoes_obrigatorias
  FOR ALL TO public
  USING ((SELECT auth.uid()) IS NOT NULL)
  WITH CHECK ((SELECT auth.uid()) IS NOT NULL);

-- 2) índices cobrindo FKs sem índice
CREATE INDEX IF NOT EXISTS idx_auditoria_p0_sonar_checkin_id ON public.auditoria_p0_sonar (checkin_id);
CREATE INDEX IF NOT EXISTS idx_checkin_recepcion_checkpoint_anterior ON public.checkin_recepcion (checkpoint_anterior);
CREATE INDEX IF NOT EXISTS idx_consolidacao_circ_conhecimento_entrada_id ON public.consolidacao_circulacao_principal (conhecimento_entrada_id);
CREATE INDEX IF NOT EXISTS idx_evidencias_consolidadas_checkpoint_anterior_id ON public.evidencias_consolidadas (checkpoint_anterior_id);
CREATE INDEX IF NOT EXISTS idx_notas_relacionado_a_conhecimento ON public.notas (relacionado_a_conhecimento);
CREATE INDEX IF NOT EXISTS idx_sol_missions_created_by ON public.sol_missions (created_by);
CREATE INDEX IF NOT EXISTS idx_sol_missions_relacionado_a_conhecimento ON public.sol_missions (relacionado_a_conhecimento);
CREATE INDEX IF NOT EXISTS idx_sol_runs_task_id ON public.sol_runs (task_id);
CREATE INDEX IF NOT EXISTS idx_sol_tasks_depends_on ON public.sol_tasks (depends_on);

-- 3) dropar índice duplicado que NÃO é constraint (manter *_key)
DROP INDEX IF EXISTS public.idx_meta_lab_colecao;
DROP INDEX IF EXISTS public.uq_p0_audit_session_check;
DROP INDEX IF EXISTS public.uq_trina_results_session_agent;
