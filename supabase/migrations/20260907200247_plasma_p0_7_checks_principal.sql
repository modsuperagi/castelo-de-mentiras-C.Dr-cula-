-- Migração 20260907200247 · plasma_p0_7_checks_principal
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create schema if not exists metalab_evo;

create table if not exists metalab_evo.p0_validacao (
  id uuid primary key default gen_random_uuid(),
  fio_id uuid not null default 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  sessao_id uuid not null,
  check_1_identidade boolean not null,
  check_2_autoridade boolean not null,
  check_3_propositum boolean not null,
  check_4_evidencia boolean not null,
  check_5_escopo boolean not null,
  check_6_rastreabilidade boolean not null,
  check_7_dedup boolean not null,
  p0_pass boolean generated always as (check_1_identidade and check_2_autoridade and check_3_propositum and check_4_evidencia and check_5_escopo and check_6_rastreabilidade and check_7_dedup) stored,
  data_validacao timestamptz not null default now(),
  resultado_detalhado jsonb not null default '{}'::jsonb,
  constraint chk_fio_p0_principal check (fio_id='ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

create index if not exists idx_p0_validacao_principal_sessao on metalab_evo.p0_validacao(sessao_id);
create index if not exists idx_p0_validacao_principal_pass on metalab_evo.p0_validacao(p0_pass);
create index if not exists idx_p0_validacao_principal_data on metalab_evo.p0_validacao(data_validacao desc);

create table if not exists metalab_evo.porta_entrada_local (
  id uuid primary key default gen_random_uuid(),
  fio_id uuid not null default 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  nome_agente text not null,
  identificador_unico text not null unique,
  checkin_at timestamptz not null default now(),
  status_porta text not null default 'pending' check (status_porta in ('pending','processing','p0_pass','p0_fail','blocked')),
  sessao_id uuid,
  p0_id uuid,
  determinacao text,
  permitido boolean not null default false,
  motivo_bloqueio text,
  constraint chk_fio_porta_principal check (fio_id='ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid),
  constraint fk_porta_p0_principal foreign key (p0_id) references metalab_evo.p0_validacao(id)
);

create index if not exists idx_porta_principal_sessao on metalab_evo.porta_entrada_local(sessao_id);
create index if not exists idx_porta_principal_p0 on metalab_evo.porta_entrada_local(p0_id);

create or replace function metalab_evo.executar_p0_validacao(
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
) language plpgsql security invoker set search_path = metalab_evo, public as $$
declare
  v_id uuid;
  v1 boolean; v2 boolean; v3 boolean; v4 boolean; v5 boolean; v6 boolean; v7 boolean;
  v_dup boolean;
begin
  v1 := exists (select 1 from metalab_evo.agentes a where a.nome = p_nome_agente and coalesce(a.ativo,true));
  v2 := exists (select 1 from metalab_evo.agentes a where a.nome = p_nome_agente and coalesce(a.ativo,true) and (a.camada is null or a.camada = p_camada_evo));
  v3 := p_camada_evo in ('EVO1','EVO2','EVO3','EVO4','EVO5','EVO6');
  v4 := length(trim(coalesce(p_conteudo,''))) >= 20;
  v5 := p_nivel_acesso in ('núcleo','confiança','estrutura','público');
  v6 := p_sessao_id is not null and length(trim(coalesce(p_nome_agente,''))) > 0;
  v_dup := exists (
    select 1 from metalab_evo.registro_decisoes d
    where d.data >= now() - interval '24 hours'
      and position(lower(left(trim(coalesce(p_conteudo,'')),50)) in lower(coalesce(d.decisao,''))) > 0
  );
  v7 := not v_dup;

  insert into metalab_evo.p0_validacao(
    sessao_id,check_1_identidade,check_2_autoridade,check_3_propositum,check_4_evidencia,check_5_escopo,check_6_rastreabilidade,check_7_dedup,resultado_detalhado
  ) values (
    p_sessao_id,v1,v2,v3,v4,v5,v6,v7,jsonb_build_object(
      'agente',p_nome_agente,'camada_evo',p_camada_evo,'nivel_acesso',p_nivel_acesso,
      'checks',jsonb_build_object('P0-01',v1,'P0-02',v2,'P0-03',v3,'P0-04',v4,'P0-05',v5,'P0-06',v6,'P0-07',v7),
      'dedup_encontrado',v_dup
    )
  ) returning id into v_id;

  return query select v_id,v1,v2,v3,v4,v5,v6,v7,(v1 and v2 and v3 and v4 and v5 and v6 and v7),
    case when (v1 and v2 and v3 and v4 and v5 and v6 and v7) then 'ALLOW: Passa para CORAÇÃO' else 'DENY: Bloqueado, apenas auditoria' end;
end;
$$;

create or replace function metalab_evo.bloquear_entrada_sem_p0()
returns trigger language plpgsql security invoker set search_path = metalab_evo, public as $$
declare v_pass boolean;
begin
  select p0_pass into v_pass from metalab_evo.p0_validacao where id = new.p0_id and sessao_id = new.sessao_id;
  if coalesce(v_pass,false) is not true then
    new.permitido := false;
    new.status_porta := 'blocked';
    new.motivo_bloqueio := 'P0 FAIL: entrada não autorizada';
    raise exception using message = 'ACESSO NEGADO: P0 não aprovado. Nenhuma sessão deve ser criada.';
  end if;
  new.permitido := true;
  new.status_porta := 'p0_pass';
  return new;
end;
$$;

drop trigger if exists trg_bloquear_porta_sem_p0 on metalab_evo.porta_entrada_local;
create trigger trg_bloquear_porta_sem_p0 before insert on metalab_evo.porta_entrada_local for each row execute function metalab_evo.bloquear_entrada_sem_p0();

create or replace view metalab_evo.v_fluxo_e2e_path as
select p.id as porta_id,p.fio_id,p.nome_agente,p.identificador_unico,p.status_porta,p.sessao_id,p.p0_id,p.permitido,p.motivo_bloqueio,p.checkin_at,
       v.p0_pass,v.check_1_identidade,v.check_2_autoridade,v.check_3_propositum,v.check_4_evidencia,v.check_5_escopo,v.check_6_rastreabilidade,v.check_7_dedup,
       case when v.p0_pass then 'ALLOW: Passa para CORAÇÃO' else 'DENY: Bloqueado, apenas auditoria' end as resultado_fluxo
from metalab_evo.porta_entrada_local p left join metalab_evo.p0_validacao v on v.id=p.p0_id;

revoke all on metalab_evo.p0_validacao from anon, authenticated;
revoke all on metalab_evo.porta_entrada_local from anon, authenticated;
revoke all on metalab_evo.v_fluxo_e2e_path from anon, authenticated;
grant all on metalab_evo.p0_validacao to service_role;
grant all on metalab_evo.porta_entrada_local to service_role;
grant all on metalab_evo.v_fluxo_e2e_path to service_role;

alter table metalab_evo.p0_validacao enable row level security;
alter table metalab_evo.porta_entrada_local enable row level security;
