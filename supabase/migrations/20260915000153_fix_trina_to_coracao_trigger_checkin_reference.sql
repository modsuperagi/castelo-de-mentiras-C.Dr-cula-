-- Migração 20260915000153 · fix_trina_to_coracao_trigger_checkin_reference
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create or replace function public.fn_trina_cria_coacao_seguro()
returns trigger
language plpgsql
as $function$
declare
  v_checkpoint_id uuid;
  v_coacao_existente uuid;
  v_checkin_id uuid;
begin
  if new.status <> 'validado' or old.status = 'validado' then
    return new;
  end if;

  v_checkpoint_id := new.checkpoint_id;
  if v_checkpoint_id is null then
    raise warning 'fn_trina_cria_coacao_seguro: checkpoint_id nulo para Trina %', new.id;
    return new;
  end if;

  select fc.registro_id into v_checkin_id
  from public.fios_checkpoint_universal fc
  where fc.id = v_checkpoint_id
    and fc.tabela_origem = 'checkin_recepcion'
  limit 1;

  if v_checkin_id is null then
    select fc.registro_id into v_checkin_id
    from public.fios_checkpoint_universal fc
    where fc.id = v_checkpoint_id
    limit 1;
  end if;

  select id into v_coacao_existente
  from public.coracao_motor_principal
  where checkin_id = v_checkin_id
    and estado_circulacao in ('esperando_p0','p0_aprovado','roteando','trina_processando')
  limit 1;

  if v_coacao_existente is not null then
    raise notice 'Coração % já existe para Trina % — idempotência mantida', v_coacao_existente, new.id;
    return new;
  end if;

  insert into public.coracao_motor_principal (
    fio_id, checkin_id, checkpoint_id, flow_id, destinos, prioridade,
    estado_circulacao, motivo_roteamento, linhagem_completa, timestamp_circulacao
  ) values (
    new.fio_id,
    v_checkin_id,
    v_checkpoint_id,
    coalesce(nullif(new.payload->>'flow_id','')::uuid, new.id),
    array['trina_circulacao_principal'::text],
    'normal'::varchar,
    'trina_processando'::varchar,
    'Auto-gerado por Trina validada',
    jsonb_build_object('origem_trina',new.id,'checkpoint',v_checkpoint_id,'timestamp_criacao',now(),'rastreamento_completo',true),
    now()
  );

  insert into public.fios_checkpoint_universal (
    fio_id, acao, tabela_origem, registro_id, agente_id, responsavel,
    mantém_propósito, existe_evidência, qual_impacto, status, resultado
  ) values (
    new.fio_id, 'PROPAGATION', 'meta_sessões_trina', new.id, null,
    'Trina → Coração', true, true,
    'Unificação de fluxo Checkpoint ↔ Trina ↔ Coração', 'validado',
    jsonb_build_object('trina_id',new.id,'coracao_criado',true,'checkpoint_id',v_checkpoint_id,'timestamp',now())
  );

  return new;
end;
$function$;
