-- Ciclo 2 (proposta c4b13a31, portão Norton 3109fc83 P2). Só RPCs + grants. Sem DDL em tabelas, sem alterar triggers _bi/_bu, sem tocar v_mariana_v2_raiz.
-- Estados: usa os valores já existentes no CHECK (pendente -> em_processamento -> concluido); CHECK não alterado (fora do portão).

create function public.claim_sonar_item(p_id uuid)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_row public.sonar_plasma_fila%rowtype;
begin
  if p_id is null then
    raise exception 'claim_sonar_item: id obrigatorio' using errcode = '22023';
  end if;
  select f.* into v_row
    from public.sonar_plasma_fila f
   where f.id = p_id and f.estado = 'pendente'
   for update skip locked;
  if not found then
    raise exception 'claim_sonar_item: item inexistente, ja reivindicado ou bloqueado' using errcode = 'P0002';
  end if;
  update public.sonar_plasma_fila f
     set estado = 'em_processamento'
   where f.id = v_row.id and f.estado = 'pendente';
  return jsonb_build_object(
    'id', v_row.id, 'estado', 'em_processamento', 'operacao', v_row.operacao,
    'memoria_ref', v_row.memoria_ref, 'texto', v_row.texto,
    'chave_dedupe', v_row.chave_dedupe, 'hash', v_row.hash);
end;
$$;

create function public.responder_sonar_item(p_id uuid, p_resposta text, p_evidencia jsonb)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_id uuid;
  v_saida public.sonar_plasma_saida%rowtype;
begin
  if p_id is null then
    raise exception 'responder_sonar_item: id obrigatorio' using errcode = '22023';
  end if;
  if p_resposta is null or char_length(p_resposta) < 1 or char_length(p_resposta) > 8000 then
    raise exception 'responder_sonar_item: resposta deve ter 1..8000 caracteres' using errcode = '22023';
  end if;
  if p_evidencia is null or jsonb_typeof(p_evidencia) <> 'object' then
    raise exception 'responder_sonar_item: evidencia deve ser objeto json' using errcode = '22023';
  end if;
  if octet_length(p_evidencia::text) > 16000 then
    raise exception 'responder_sonar_item: evidencia excede 16000 bytes' using errcode = '22023';
  end if;
  select f.id into v_id
    from public.sonar_plasma_fila f
   where f.id = p_id and f.estado = 'em_processamento'
   for update skip locked;
  if not found then
    raise exception 'responder_sonar_item: item nao esta em_processamento, ja respondido ou bloqueado' using errcode = 'P0002';
  end if;
  -- chave_dedupe da saída é única por fila_id (trigger sonar_plasma_saida_bi): resposta única.
  insert into public.sonar_plasma_saida (fila_id, executor, resultado)
  values (v_id, 'grok_bot_consumidor',
          jsonb_build_object('resposta', p_resposta, 'evidencia', p_evidencia))
  returning * into v_saida;
  update public.sonar_plasma_fila f
     set estado = 'concluido'
   where f.id = v_id and f.estado = 'em_processamento';
  return jsonb_build_object(
    'fila_id', v_id, 'estado', 'concluido', 'saida_id', v_saida.id,
    'chave_dedupe', v_saida.chave_dedupe, 'hash_pai', v_saida.hash_pai, 'hash', v_saida.hash);
end;
$$;

revoke all on function public.claim_sonar_item(uuid) from public, anon, authenticated;
revoke all on function public.responder_sonar_item(uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.claim_sonar_item(uuid) to service_role;
grant execute on function public.responder_sonar_item(uuid, text, jsonb) to service_role;

comment on function public.claim_sonar_item(uuid) is 'Ciclo 2 P2 (portão Norton 3109fc83): reivindica item pendente -> em_processamento com FOR UPDATE SKIP LOCKED. INVOKER, search_path vazio, EXECUTE só service_role.';
comment on function public.responder_sonar_item(uuid, text, jsonb) is 'Ciclo 2 P2 (portão Norton 3109fc83): em_processamento -> concluido uma única vez; grava saída com chave_dedupe única por fila_id e hash_pai = hash da fila. INVOKER, search_path vazio, EXECUTE só service_role.';
