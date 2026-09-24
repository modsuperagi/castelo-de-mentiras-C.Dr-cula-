-- Migração 20260920160210 · fn_trina_resolve_coracao_por_checkpoint_sol
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- B) Resolver Coração por checkpoint/flow; nunca Ghost latest para origem Sol
CREATE OR REPLACE FUNCTION public.fn_trina_para_circulacao()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_coracao_id uuid;
  v_flow_id uuid;
  v_origem text;
begin
  if new.status = 'validado' and old.status <> 'validado' then
    v_flow_id := coalesce(
      nullif(new.payload->>'flow_id','')::uuid,
      nullif(new.payload->>'checkpoint_id','')::uuid,
      new.checkpoint_id,
      new.id
    );

    v_origem := coalesce(new.origem_tabela, new.payload->>'tabela_origem');

    -- 1) Coração da mesma linhagem (checkpoint)
    select id into v_coracao_id
    from public.coracao_motor_principal
    where checkpoint_id = new.checkpoint_id
    order by timestamp_circulacao desc
    limit 1;

    -- 2) Mesmo flow_id
    if v_coracao_id is null and v_flow_id is not null then
      select id into v_coracao_id
      from public.coracao_motor_principal
      where flow_id = v_flow_id
      order by timestamp_circulacao desc
      limit 1;
    end if;

    -- 3) Fallback Ghost/fio SOMENTE se NÃO for caminho Sol
    if v_coracao_id is null then
      if v_origem in ('sol_tasks', 'sol_missions') then
        raise exception
          'Trina Sol % sem Coração ligado ao checkpoint % (origem %). Não usar Coração Ghost do fio.',
          new.id, new.checkpoint_id, v_origem;
      end if;

      select id into v_coracao_id
      from public.coracao_motor_principal
      where fio_id = new.fio_id
      order by timestamp_circulacao desc
      limit 1;
    end if;

    if v_coracao_id is null then
      raise exception 'Trina não pode circular: nenhum Coração encontrado para o Fio %', new.fio_id;
    end if;

    insert into public.trina_circulacao_principal (
      fio_id, coracao_id, flow_id, trina_papel, trina_resultado,
      escopo_provado, escopo_nao_provado, limites_explicitos, timestamp_trina
    )
    values (
      new.fio_id, v_coracao_id, v_flow_id, 'VERIFICADOR', 'CONFIRMADO',
      'Passagem pelos 3 polos da Mesa Trina para a missão validada',
      'P0 E2E integral e Coração específico da missão podem permanecer lacunas se não evidenciados',
      'Hellwolf: resolve Coração por checkpoint/flow; Sol nunca herda Ghost latest',
      now()
    );

    raise notice 'Trina % → circulação coracao=% flow=%', new.id, v_coracao_id, v_flow_id;
  end if;
  return new;
end;
$function$;
