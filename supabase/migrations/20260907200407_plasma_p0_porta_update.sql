-- Migração 20260907200407 · plasma_p0_porta_update
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create or replace function public.p0_principal_atualizar_porta(p_sessao_id uuid,p_status text,p_determinacao text) returns integer language sql security invoker set search_path = public, metalab_evo as $$
  update metalab_evo.porta_entrada_local
  set status_porta=case when $2 in ('pending','processing','p0_pass','p0_fail','blocked') then $2 else status_porta end,
      determinacao=$3
  where sessao_id=$1;
  select 1;
$$;
revoke all on function public.p0_principal_atualizar_porta(uuid,text,text) from public,anon,authenticated;
grant execute on function public.p0_principal_atualizar_porta(uuid,text,text) to service_role;
