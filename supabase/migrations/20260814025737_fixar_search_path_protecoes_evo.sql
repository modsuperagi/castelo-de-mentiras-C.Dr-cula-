-- Migração 20260814025737 · fixar_search_path_protecoes_evo
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

alter function public.bloquear_arquivo_primordial_minima_galaxia() set search_path = public, pg_temp;
alter function public.bloquear_alteracao_snapshot_evo() set search_path = public, pg_temp;
