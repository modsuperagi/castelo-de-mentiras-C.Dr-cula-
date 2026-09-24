-- Migração 20260924124050 · espelho_leitura_publica_principios
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- Distinção comercial: princípios do organismo são manifesto público (leitura anônima no espelho)
DROP POLICY IF EXISTS espelho_select_publico ON public.evo_principios;
CREATE POLICY espelho_select_publico ON public.evo_principios
  FOR SELECT TO anon, authenticated
  USING (ativo IS TRUE);
