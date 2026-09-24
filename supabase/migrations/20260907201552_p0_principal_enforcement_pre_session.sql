-- Migração 20260907201552 · p0_principal_enforcement_pre_session
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create or replace function public.p0_principal_criar_sessao_se_aprovada(p_sessao_id uuid,p_prompt text,p_user_id uuid,p_agent_name text,p_camada_evo text,p_nivel_acesso text)
returns public.sessions
language plpgsql
security definer
set search_path = public, metalab_evo
as $$
declare v_p0 record; v_session public.sessions;
begin
  if p_sessao_id is null or p_prompt is null or length(trim(p_prompt)) = 0 then
    raise exception 'P0-03 FAIL: propósito vazio';
  end if;
  select * into v_p0 from public.p0_principal_validar(p_sessao_id,p_agent_name,p_camada_evo,p_prompt,p_nivel_acesso) limit 1;
  if v_p0.p0_id is null or coalesce(v_p0.p0_pass,false) = false then
    raise exception 'P0 DENY: sessão não pode ser criada';
  end if;
  perform public.p0_principal_abrir_porta('ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,p_agent_name,p_sessao_id::text,p_sessao_id,v_p0.p0_id,'ALLOW → CORAÇÃO → TRINA');
  insert into public.sessions(id,prompt,user_id,status,created_at_ms,p0_pass)
  values(p_sessao_id,trim(p_prompt),p_user_id,'processando',extract(epoch from clock_timestamp())::bigint*1000,true)
  returning * into v_session;
  return v_session;
end;
$$;

revoke all on function public.p0_principal_criar_sessao_se_aprovada(uuid,text,uuid,text,text,text) from public, anon, authenticated;
grant execute on function public.p0_principal_criar_sessao_se_aprovada(uuid,text,uuid,text,text,text) to service_role;

create or replace function public.p0_principal_atualizar_porta(p_sessao_id uuid,p_status text,p_determinacao text)
returns integer
language sql
set search_path = public, metalab_evo
as $$
  update metalab_evo.porta_entrada_local
  set status_porta=case when $2 in ('pending','processing','p0_pass','p0_fail','blocked') then $2 else status_porta end,
      determinacao=$3
  where sessao_id=$1;
  select 1;
$$;

create or replace function public.p0_principal_abrir_porta(p_fio_id uuid,p_nome_agente text,p_identificador_unico text,p_sessao_id uuid,p_p0_id uuid,p_determinacao text)
returns jsonb
language plpgsql
set search_path = public, metalab_evo
as $$
declare v_row jsonb;
begin
  if p_fio_id <> 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid then raise exception 'FIO_ID inválido'; end if;
  if p_p0_id is null then raise exception 'P0 obrigatório'; end if;
  if not exists(select 1 from metalab_evo.p0_validacao where id=p_p0_id and sessao_id=p_sessao_id and p0_pass=true) then raise exception 'P0 não aprovado para esta sessão'; end if;
  insert into metalab_evo.porta_entrada_local(fio_id,nome_agente,identificador_unico,status_porta,sessao_id,p0_id,determinacao)
  values(p_fio_id,p_nome_agente,p_identificador_unico,'processing',p_sessao_id,p_p0_id,p_determinacao)
  returning jsonb_build_object('id',id,'permitido',permitido,'status_porta',status_porta,'p0_id',p0_id,'sessao_id',sessao_id) into v_row;
  return v_row;
end;
$$;

revoke all on function public.p0_principal_abrir_porta(uuid,text,text,uuid,uuid,text) from public, anon, authenticated;
grant execute on function public.p0_principal_abrir_porta(uuid,text,text,uuid,uuid,text) to service_role;
