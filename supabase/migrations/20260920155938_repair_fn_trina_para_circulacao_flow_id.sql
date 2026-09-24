-- Migração 20260920155938 · repair_fn_trina_para_circulacao_flow_id
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

CREATE OR REPLACE FUNCTION public.fn_trina_para_circulacao()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_coracao_id uuid;
  v_flow_id uuid;
begin
  if new.status = 'validado' and old.status <> 'validado' then
    select id into v_coracao_id
    from public.coracao_motor_principal
    where fio_id = new.fio_id
    order by timestamp_circulacao desc
    limit 1;

    -- Linhagem: payload.flow_id → checkpoint_id → id da sessão Trina (nunca null opaco)
    v_flow_id := coalesce(
      nullif(new.payload->>'flow_id','')::uuid,
      nullif(new.payload->>'checkpoint_id','')::uuid,
      new.checkpoint_id,
      new.id
    );

    if v_coracao_id is null then
      raise exception 'Trina não pode circular: nenhum registro do Coração encontrado para o Fio %', new.fio_id;
    end if;

    insert into public.trina_circulacao_principal (
      fio_id, coracao_id, flow_id, trina_papel, trina_resultado,
      escopo_provado, escopo_nao_provado, limites_explicitos, timestamp_trina
    )
    values (
      new.fio_id, v_coracao_id, v_flow_id, 'VERIFICADOR', 'CONFIRMADO',
      'Passagem completa pelos 3 polos da Mesa Trina para a missão validada',
      'P0 independente e circulação E2E integral permanecem não comprovados quando ausentes de evidência específica',
      'Linhagem: coalesce(payload.flow_id, payload.checkpoint_id, checkpoint_id, trina.id); Hellwolf repair 2026-09-20',
      now()
    );

    raise notice 'Trina % propagada para circulação (Golden) flow_id=%', new.id, v_flow_id;
  end if;
  return new;
end;
$function$;
