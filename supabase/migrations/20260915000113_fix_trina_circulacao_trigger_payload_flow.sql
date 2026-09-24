-- Migração 20260915000113 · fix_trina_circulacao_trigger_payload_flow
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create or replace function public.fn_trina_para_circulacao()
returns trigger
language plpgsql
as $function$
begin
  if new.status = 'validado' and old.status <> 'validado' then
    insert into public.trina_circulacao_principal (
      fio_id,
      flow_id,
      trina_papel,
      trina_resultado,
      escopo_provado,
      escopo_nao_provado,
      limites_explicitos,
      timestamp_trina
    )
    values (
      new.fio_id,
      nullif(new.payload->>'flow_id','')::uuid,
      'VERIFICADOR',
      'CONFIRMADO',
      'Passagem completa pelos 3 polos da Mesa Trina para a missão validada',
      'P0 independente e circulação E2E integral permanecem não comprovados quando ausentes de evidência específica',
      'O esquema atual de trina_circulacao_principal não possui checkpoint_id; a linhagem usa fio_id e flow_id do payload da sessão',
      now()
    );

    raise notice 'Trina % propagada para circulação (Golden)', new.id;
  end if;
  return new;
end;
$function$;
