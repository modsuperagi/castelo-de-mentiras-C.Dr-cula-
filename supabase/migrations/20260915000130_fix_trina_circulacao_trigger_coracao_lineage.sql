-- Migração 20260915000130 · fix_trina_circulacao_trigger_coracao_lineage
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create or replace function public.fn_trina_para_circulacao()
returns trigger
language plpgsql
as $function$
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

    v_flow_id := nullif(new.payload->>'flow_id','')::uuid;

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
      'Linhagem usa fio_id + coracao_id + flow_id; checkpoint_id não pertence ao esquema desta mesa',
      now()
    );

    raise notice 'Trina % propagada para circulação (Golden)', new.id;
  end if;
  return new;
end;
$function$;
