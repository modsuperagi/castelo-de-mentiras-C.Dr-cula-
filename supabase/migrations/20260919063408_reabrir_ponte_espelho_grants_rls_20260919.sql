-- Migração 20260919063408 · reabrir_ponte_espelho_grants_rls_20260919
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- Reabre ponte Espelho: anon/authenticated tinham ZERO grant; RLS ON sem policy = API morta.
-- service_role já escreve (bypass RLS) — Sol Edge usa isso. Cloud com anon não.
-- Hellwolf: anon = LEITURA Espelho; authenticated = leitura+escrita operacional; sem service_role no browser.

GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Tabelas do Espelho / circulação (leitura)
GRANT SELECT ON TABLE
  public.evo_memorias,
  public.fios_checkpoint_universal,
  public.meta_sessões_trina,
  public.evo_agentes,
  public.sol_tasks,
  public.sol_missions,
  public.sol_runs,
  public.checkin_recepcion,
  public.ponte_ghost_castelo,
  public.registro_decisoes,
  public.castelo_identidades,
  public.mariana_casting,
  public.golden_circulacao_principal,
  public.coracao_motor_principal,
  public.trina_circulacao_principal,
  public.sessao_checkpoint,
  public.fluxo_conhecimento,
  public.acessos_canais
TO anon, authenticated;

-- Escrita operacional para authenticated (núcleos logados)
GRANT INSERT, UPDATE ON TABLE
  public.evo_memorias,
  public.fios_checkpoint_universal,
  public.meta_sessões_trina,
  public.checkin_recepcion,
  public.ponte_ghost_castelo,
  public.registro_decisoes,
  public.sessao_checkpoint,
  public.fluxo_conhecimento
TO authenticated;

-- Policies SELECT (anon + authenticated) — só onde ainda não existem
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='evo_memorias' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.evo_memorias FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='fios_checkpoint_universal' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.fios_checkpoint_universal FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='meta_sessões_trina' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.meta_sessões_trina FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='evo_agentes' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.evo_agentes FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='checkin_recepcion' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.checkin_recepcion FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='ponte_ghost_castelo' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.ponte_ghost_castelo FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='registro_decisoes' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.registro_decisoes FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='castelo_identidades' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.castelo_identidades FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='mariana_casting' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.mariana_casting FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='golden_circulacao_principal' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.golden_circulacao_principal FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='coracao_motor_principal' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.coracao_motor_principal FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='trina_circulacao_principal' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.trina_circulacao_principal FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='sessao_checkpoint' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.sessao_checkpoint FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='fluxo_conhecimento' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.fluxo_conhecimento FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='acessos_canais' AND policyname='espelho_select_anon_auth') THEN
    CREATE POLICY espelho_select_anon_auth ON public.acessos_canais FOR SELECT TO anon, authenticated USING (true);
  END IF;
END $$;

-- Sol: permitir SELECT autenticado além do owner (leitura Espelho/revisão)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='sol_tasks' AND policyname='espelho_sol_tasks_select') THEN
    CREATE POLICY espelho_sol_tasks_select ON public.sol_tasks FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='sol_missions' AND policyname='espelho_sol_missions_select') THEN
    CREATE POLICY espelho_sol_missions_select ON public.sol_missions FOR SELECT TO anon, authenticated USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='sol_runs' AND policyname='espelho_sol_runs_select') THEN
    CREATE POLICY espelho_sol_runs_select ON public.sol_runs FOR SELECT TO anon, authenticated USING (true);
  END IF;
END $$;

GRANT SELECT ON TABLE public.sol_tasks, public.sol_missions, public.sol_runs TO anon, authenticated;

-- Escrita authenticated (Cloud/núcleos com JWT)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='evo_memorias' AND policyname='castelo_auth_write') THEN
    CREATE POLICY castelo_auth_write ON public.evo_memorias FOR INSERT TO authenticated WITH CHECK (true);
    CREATE POLICY castelo_auth_update ON public.evo_memorias FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='checkin_recepcion' AND policyname='castelo_auth_write') THEN
    CREATE POLICY castelo_auth_write ON public.checkin_recepcion FOR INSERT TO authenticated WITH CHECK (true);
    CREATE POLICY castelo_auth_update ON public.checkin_recepcion FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='fios_checkpoint_universal' AND policyname='castelo_auth_write') THEN
    CREATE POLICY castelo_auth_write ON public.fios_checkpoint_universal FOR INSERT TO authenticated WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='ponte_ghost_castelo' AND policyname='castelo_auth_write') THEN
    CREATE POLICY castelo_auth_write ON public.ponte_ghost_castelo FOR INSERT TO authenticated WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='registro_decisoes' AND policyname='castelo_auth_write') THEN
    CREATE POLICY castelo_auth_write ON public.registro_decisoes FOR INSERT TO authenticated WITH CHECK (true);
  END IF;
END $$;
