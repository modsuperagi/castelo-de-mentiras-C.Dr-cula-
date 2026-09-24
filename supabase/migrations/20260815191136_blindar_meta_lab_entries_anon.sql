-- Migração 20260815191136 · blindar_meta_lab_entries_anon
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- Remove anonymous Data API access to the shared MetaLab memory.
-- RLS remains enabled; authenticated access is preserved by the existing policy.
DROP POLICY IF EXISTS "Permitir acesso total" ON public.meta_lab_entries;
DROP POLICY IF EXISTS "Permitir acesso total via anon" ON public.meta_lab_entries;
REVOKE ALL ON TABLE public.meta_lab_entries FROM anon;
