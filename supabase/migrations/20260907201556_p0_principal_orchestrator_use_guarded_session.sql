-- Migração 20260907201556 · p0_principal_orchestrator_use_guarded_session
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create or replace function public.p0_principal_guardrail_status()
returns jsonb
language sql
stable
security definer
set search_path = public, metalab_evo
as $$
select jsonb_build_object(
  'fio_id','ee46c360-b95b-426e-86c3-2e5d0ccbe916',
  'session_creation_guard','p0_principal_criar_sessao_se_aprovada',
  'door_guard','p0_principal_abrir_porta',
  'p0_checks',7,
  'deny_before_session',true,
  'status','MATERIALIZADO'
);
$$;
revoke all on function public.p0_principal_guardrail_status() from public, anon, authenticated;
grant execute on function public.p0_principal_guardrail_status() to service_role;
