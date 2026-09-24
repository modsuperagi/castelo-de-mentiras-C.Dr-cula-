-- Migração 20260907200347 · plasma_p0_public_entrypoints
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create or replace function public.p0_principal_validar(
  p_sessao_id uuid,
  p_nome_agente varchar,
  p_camada_evo varchar,
  p_conteudo text,
  p_nivel_acesso varchar
) returns table (
  p0_id uuid,
  check_1_identidade boolean,
  check_2_autoridade boolean,
  check_3_propositum boolean,
  check_4_evidencia boolean,
  check_5_escopo boolean,
  check_6_rastreabilidade boolean,
  check_7_dedup boolean,
  p0_pass boolean,
  resultado text
) language sql security invoker set search_path = public, metalab_evo as $$
  select * from metalab_evo.executar_p0_validacao($1,$2,$3,$4,$5)
$$;

create or replace function public.p0_principal_abrir_porta(
  p_fio_id uuid,
  p_nome_agente text,
  p_identificador_unico text,
  p_sessao_id uuid,
  p_p0_id uuid,
  p_determinacao text
) returns jsonb language plpgsql security invoker set search_path = public, metalab_evo as $$
declare v_row jsonb;
begin
  insert into metalab_evo.porta_entrada_local(fio_id,nome_agente,identificador_unico,status_porta,sessao_id,p0_id,determinacao)
  values(p_fio_id,p_nome_agente,p_identificador_unico,'processing',p_sessao_id,p_p0_id,p_determinacao)
  returning jsonb_build_object('id',id,'permitido',permitido,'status_porta',status_porta,'p0_id',p0_id,'sessao_id',sessao_id) into v_row;
  return v_row;
end;
$$;

revoke all on function public.p0_principal_validar(uuid,varchar,varchar,text,varchar) from public,anon,authenticated;
revoke all on function public.p0_principal_abrir_porta(uuid,text,text,uuid,uuid,text) from public,anon,authenticated;
grant execute on function public.p0_principal_validar(uuid,varchar,varchar,text,varchar) to service_role;
grant execute on function public.p0_principal_abrir_porta(uuid,text,text,uuid,uuid,text) to service_role;
