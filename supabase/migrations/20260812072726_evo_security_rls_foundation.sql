-- Migração 20260812072726 · evo_security_rls_foundation
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

begin;

-- Close the critical exposure on append-only audit/version tables.
alter table public.meta_lab_auditoria enable row level security;
alter table public.meta_lab_versoes enable row level security;

-- Authenticated users may read audit/version history.
create policy "authenticated_read_meta_lab_auditoria"
  on public.meta_lab_auditoria
  for select to authenticated
  using (true);

create policy "authenticated_read_meta_lab_versoes"
  on public.meta_lab_versoes
  for select to authenticated
  using (true);

-- No client-side UPDATE/DELETE policies are created: append-only remains enforced.
-- System/service-role writes remain available through the server-side path.

-- Consolidations remain readable by authenticated users; write policies will be
-- added only after equipe_evolucao exists and its authorization model is defined.

-- Fix mutable search_path on the existing timestamp trigger function.
alter function public.handle_updated_at() set search_path = public;

commit;
