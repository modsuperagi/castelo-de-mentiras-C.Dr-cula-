-- Migração 20260924113951 · selo_guardiao_admin
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- Papel guardiao: poder total do titular nas mesas do espelho, verificado pelo JWT (app_metadata.role)
CREATE OR REPLACE FUNCTION public.eh_guardiao()
RETURNS boolean
LANGUAGE sql STABLE
SET search_path = ''
AS $$
  SELECT coalesce((auth.jwt() -> 'app_metadata' ->> 'role') = 'guardiao', false);
$$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['evo_porta_entrada','checkin_recepcion','acessos_canais','castelo_identidades','evo_memorias','registro_decisoes']
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS guardiao_admin_total ON public.%I', t);
    EXECUTE format(
      'CREATE POLICY guardiao_admin_total ON public.%I FOR ALL TO authenticated USING (public.eh_guardiao()) WITH CHECK (public.eh_guardiao())',
      t
    );
  END LOOP;
END $$;
