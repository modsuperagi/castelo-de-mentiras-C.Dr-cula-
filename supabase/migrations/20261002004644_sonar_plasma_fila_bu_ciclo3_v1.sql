-- Ciclo 3 (proposta d595977e, portão Norton 824c22cb P1+P2). Só substitui a função do trigger sonar_plasma_fila_bu.
-- P1: imutáveis = união (texto, operacao, memoria_ref, criado_em, ancora_id, chave_dedupe, hash, hash_pai)
--     + (solicitante, fio_id, motor) + cadeia + origem; e, pela regra 'só estado continua mutável', também id, pedido_ref, nota_motor.
--     atualizado_em segue forçado pelo trigger.
-- P2: transições permitidas: pendente->em_processamento, em_processamento->concluido,
--     pendente->cancelado, em_processamento->erro. concluido/erro/cancelado terminais. Qualquer outra -> exceção.
-- Sem tabela de transições (Ciclo 4). Sem SQL dinâmico. INVOKER, search_path vazio.

create or replace function public.sonar_plasma_fila_bu()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.id is distinct from old.id
     or new.texto is distinct from old.texto
     or new.operacao is distinct from old.operacao
     or new.memoria_ref is distinct from old.memoria_ref
     or new.criado_em is distinct from old.criado_em
     or new.ancora_id is distinct from old.ancora_id
     or new.chave_dedupe is distinct from old.chave_dedupe
     or new.hash is distinct from old.hash
     or new.hash_pai is distinct from old.hash_pai
     or new.solicitante is distinct from old.solicitante
     or new.fio_id is distinct from old.fio_id
     or new.motor is distinct from old.motor
     or new.cadeia is distinct from old.cadeia
     or new.origem is distinct from old.origem
     or new.pedido_ref is distinct from old.pedido_ref
     or new.nota_motor is distinct from old.nota_motor then
    raise exception 'sonar_plasma_fila: campos de linhagem são imutáveis' using errcode = 'P0001';
  end if;

  if not (
       (old.estado = 'pendente'         and new.estado = 'em_processamento')
    or (old.estado = 'em_processamento' and new.estado = 'concluido')
    or (old.estado = 'pendente'         and new.estado = 'cancelado')
    or (old.estado = 'em_processamento' and new.estado = 'erro')
  ) then
    raise exception 'sonar_plasma_fila: transicao de estado invalida (% -> %)', old.estado, new.estado using errcode = 'P0001';
  end if;

  new.atualizado_em := now();
  return new;
end;
$$;

revoke all on function public.sonar_plasma_fila_bu() from public, anon, authenticated;

comment on function public.sonar_plasma_fila_bu() is 'Ciclo 3 (portão Norton 824c22cb): só estado é mutável (atualizado_em forçado); transições pendente->em_processamento->concluido, pendente->cancelado, em_processamento->erro; terminais sem volta. Limite conhecido: postgres pode desligar o trigger.';
