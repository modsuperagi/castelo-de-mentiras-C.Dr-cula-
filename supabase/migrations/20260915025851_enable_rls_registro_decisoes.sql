-- Migração 20260915025851 · enable_rls_registro_decisoes
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

ALTER TABLE "public"."registro_decisoes" ENABLE ROW LEVEL SECURITY;
