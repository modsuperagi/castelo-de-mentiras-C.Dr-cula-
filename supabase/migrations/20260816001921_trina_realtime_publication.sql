-- Migração 20260816001921 · trina_realtime_publication
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

do $$ begin
  alter publication supabase_realtime add table public.sessions;
exception when duplicate_object then null;
end $$;
do $$ begin
  alter publication supabase_realtime add table public.trina_results;
exception when duplicate_object then null;
end $$;
do $$ begin
  alter publication supabase_realtime add table public.p0_audit;
exception when duplicate_object then null;
end $$;
