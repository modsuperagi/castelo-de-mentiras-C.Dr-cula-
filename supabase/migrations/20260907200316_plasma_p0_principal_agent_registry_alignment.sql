-- Migração 20260907200316 · plasma_p0_principal_agent_registry_alignment
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

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
  v1 := lower(trim(coalesce(p_nome_agente,''))) in ('mesa-orchestrator','trina-arquiteto','trina-engenheiro','trina-verificador','trina-golden','sol-orchestrator');
  v2 := v1 and p_camada_evo in ('EVO1','EVO2','EVO3','EVO4','EVO5','EVO6');
  v3 := p_camada_evo in ('EVO1','EVO2','EVO3','EVO4','EVO5','EVO6');
  v4 := length(trim(coalesce(p_conteudo,''))) >= 20;
  v5 := p_nivel_acesso in ('núcleo','confiança','estrutura','público');
  v6 := p_sessao_id is not null and length(trim(coalesce(p_nome_agente,''))) > 0;
  v_dup := exists (
    select 1 from public.meta_lab_entries e
    where e.criado_em >= now() - interval '24 hours'
      and position(lower(left(trim(coalesce(p_conteudo,'')),50)) in lower(coalesce(e.conteudo,''))) > 0
  );
  v7 := not v_dup;

  insert into metalab_evo.p0_validacao(
    sessao_id,check_1_identidade,check_2_autoridade,check_3_propositum,check_4_evidencia,check_5_escopo,check_6_rastreabilidade,check_7_dedup,resultado_detalhado
  ) values (
    p_sessao_id,v1,v2,v3,v4,v5,v6,v7,jsonb_build_object(
      'agente',p_nome_agente,'camada_evo',p_camada_evo,'nivel_acesso',p_nivel_acesso,
      'checks',jsonb_build_object('P0-01',v1,'P0-02',v2,'P0-03',v3,'P0-04',v4,'P0-05',v5,'P0-06',v6,'P0-07',v7),
      'dedup_encontrado',v_dup,
      'origem','PLASMA-COMPACTACAO-APLICACAO'
    )
  ) returning id into v_id;

  return query select v_id,v1,v2,v3,v4,v5,v6,v7,(v1 and v2 and v3 and v4 and v5 and v6 and v7),
    case when (v1 and v2 and v3 and v4 and v5 and v6 and v7) then 'ALLOW: Passa para CORAÇÃO' else 'DENY: Bloqueado, apenas auditoria' end;
end;
$$;
