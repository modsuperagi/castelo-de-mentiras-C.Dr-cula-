-- Migração 20260920154134 · norton_rls_lockdown_explicit_deny
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- Norton: policies honestas de lockdown (P0 DENY). Não concede acesso a anon/authenticated.
-- service_role continua bypass RLS. Reversível via DROP POLICY.

DO $$ DECLARE
  t text;
  tables text[] := ARRAY[
    'public.auditoria_p0_sonar',
    'public.consolidacao_circulacao_principal',
    'public.consolidacoes',
    'public.evidencias_consolidadas',
    'public.evo_recrutamento_agentes',
    'public.evo_recrutamento_conhecimento',
    'public.evo_recrutamento_diretrizes',
    'public.evo_recrutamento_fontes',
    'public.log_sincronizacao',
    'public.meta_lab_auditoria',
    'public.meta_lab_entries',
    'public.meta_lab_versoes',
    'public.p0_validacao_completa',
    'public.recrutamento_estrutura',
    'public.recrutas_funcoes_casa',
    'metalab_evo.p0_validacao',
    'metalab_evo.porta_entrada_local'
  ];
  full_name text;
  sch text;
  rel text;
BEGIN
  FOREACH full_name IN ARRAY tables LOOP
    sch := split_part(full_name, '.', 1);
    rel := split_part(full_name, '.', 2);
    EXECUTE format('DROP POLICY IF EXISTS norton_deny_anon ON %I.%I', sch, rel);
    EXECUTE format('DROP POLICY IF EXISTS norton_deny_authenticated ON %I.%I', sch, rel);
    EXECUTE format(
      'CREATE POLICY norton_deny_anon ON %I.%I AS RESTRICTIVE FOR ALL TO anon USING (false) WITH CHECK (false)',
      sch, rel
    );
    EXECUTE format(
      'CREATE POLICY norton_deny_authenticated ON %I.%I AS RESTRICTIVE FOR ALL TO authenticated USING (false) WITH CHECK (false)',
      sch, rel
    );
  END LOOP;
END $$;

SELECT schemaname, tablename, policyname, roles, cmd, permissive
FROM pg_policies
WHERE policyname IN ('norton_deny_anon', 'norton_deny_authenticated')
ORDER BY schemaname, tablename, policyname;
