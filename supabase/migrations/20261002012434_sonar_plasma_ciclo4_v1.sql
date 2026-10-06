-- sonar_plasma_ciclo4_v1 — Ciclo 4: P1+H1, P2, P3, P5 (portão Norton 82830d2e + decisão 7e8ade27 sobre o hold d463f94d; proposta b99d0517)
-- (1.1) ORDEM ESPERADA DECLARADA: 8b4242f8=1, 1af72e0a=2, f2a47362=3, 73de3d6b=4, cc82c28a=5, 9e554538=6
-- Topologia: gênese -> filhos (profundidade), desempate criado_em, id. Hashes históricos NÃO são reescritos.
alter table public.sonar_plasma_fila add column seq bigint;

-- (1.2) _bu desligado SÓ durante o backfill
alter table public.sonar_plasma_fila disable trigger sonar_plasma_fila_bu;

with recursive t as (
  select f.id, f.hash, f.criado_em, 0 as prof
    from public.sonar_plasma_fila f
   where not exists (select 1 from public.sonar_plasma_fila p where p.hash = f.hash_pai)
  union all
  select c.id, c.hash, c.criado_em, t.prof + 1
    from public.sonar_plasma_fila c join t on c.hash_pai = t.hash
), o as (
  select id, row_number() over (order by prof, criado_em, id) as rn from t
)
update public.sonar_plasma_fila f set seq = o.rn from o where o.id = f.id;

-- (1.2) religado na MESMA migration
alter table public.sonar_plasma_fila enable trigger sonar_plasma_fila_bu;

do $$
declare
  v_exp text := '8b4242f8-bfc5-47f7-8a3a-61ef3ffb3129:1,1af72e0a-56a1-440d-a2dc-12b9581c1cb0:2,f2a47362-b48d-4564-a5a9-353fdaa6898b:3,73de3d6b-799b-48af-8536-ecf2d1391040:4,cc82c28a-1ca4-4646-b8c1-9d15ba548e5e:5,9e554538-107c-45f1-a6dd-32e25a2d0147:6';
  v_got text; v_n int; v_nulls int; v_tg text;
begin
  select string_agg(id::text || ':' || seq, ',' order by seq), count(*), count(*) filter (where seq is null)
    into v_got, v_n, v_nulls from public.sonar_plasma_fila;
  if v_n <> 6 or v_nulls <> 0 or v_got is distinct from v_exp then
    raise exception 'HOLD 1.1: backfill de seq divergente: %', v_got;
  end if;
  select tgenabled::text into v_tg from pg_trigger where tgname = 'sonar_plasma_fila_bu' and tgrelid = 'public.sonar_plasma_fila'::regclass;
  if v_tg is distinct from 'O' then raise exception 'HOLD 1.2: _bu tgenabled=%', v_tg; end if;
end $$;

alter table public.sonar_plasma_fila alter column seq set not null;
alter table public.sonar_plasma_fila add constraint sonar_plasma_fila_seq_key unique (seq);
alter table public.sonar_plasma_fila alter column seq add generated always as identity (start with 7);
alter table public.sonar_plasma_fila alter column seq restart with 7;

do $$ begin
  if pg_get_serial_sequence('public.sonar_plasma_fila','seq') is distinct from 'public.sonar_plasma_fila_seq_seq' then
    raise exception 'HOLD 1.4: sequência da identity inesperada: %', pg_get_serial_sequence('public.sonar_plasma_fila','seq');
  end if;
end $$;

-- (1.4)/(1.7) _bi: lock -> nextval dentro do lock -> pai por seq desc -> clock_timestamp() -> hash
create or replace function public.sonar_plasma_fila_bi()
 returns trigger
 language plpgsql
 set search_path to ''
as $function$
declare
  v_pai text;
begin
  -- 1) serializa a cadeia
  perform pg_catalog.pg_advisory_xact_lock(hashtext('sonar_plasma_fila_cadeia'));
  -- 2) seq DENTRO do lock (ignora valor do cliente, inclusive OVERRIDING SYSTEM VALUE)
  new.seq := pg_catalog.nextval('public.sonar_plasma_fila_seq_seq'::regclass);
  new.estado := 'pendente';
  new.motor := 'grok_bot_fila';
  new.ancora_id := '657d6e4c-0ce0-4e8b-b5d2-8eafc579ada5'::uuid;
  new.cadeia := 'v7.0-RAIZ → v8-CRUZAMENTO';
  new.fio_id := 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid;
  if auth.uid() is not null then
    new.solicitante := auth.uid();
  end if;
  new.chave_dedupe := 'SONAR-PLASMA|' || new.operacao || '|' ||
    encode(sha256(convert_to(new.operacao || '|' || coalesce(new.memoria_ref,'') || '|' || new.texto, 'UTF8')), 'hex');
  -- 3) pai = linha de maior seq
  select f.hash into v_pai from public.sonar_plasma_fila f order by f.seq desc limit 1;
  if v_pai is null then
    v_pai := encode(sha256(convert_to('657d6e4c-0ce0-4e8b-b5d2-8eafc579ada5|v7.0-RAIZ|ROGUE-WAVE-v1 → v8-CRUZAMENTO', 'UTF8')), 'hex');
  end if;
  new.hash_pai := v_pai;
  -- 4) criado_em pós-lock
  new.criado_em := pg_catalog.clock_timestamp();
  new.atualizado_em := new.criado_em;
  -- 5) hash com esse criado_em
  new.hash := encode(sha256(convert_to(v_pai || '|' || new.chave_dedupe || '|' || new.criado_em::text, 'UTF8')), 'hex');
  return new;
end;
$function$;

-- (1.6) _bu: única mudança = seq como 17º campo imutável
create or replace function public.sonar_plasma_fila_bu()
 returns trigger
 language plpgsql
 set search_path to ''
as $function$
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
     or new.nota_motor is distinct from old.nota_motor
     or new.seq is distinct from old.seq then
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
$function$;

-- (1.3) trava final: corte literal 6
create unique index sonar_plasma_fila_hash_pai_pos6_uniq on public.sonar_plasma_fila (hash_pai) where seq > 6;

comment on column public.sonar_plasma_fila.seq is 'Ciclo 4 (82830d2e): ordem canônica da cadeia. Backfill topológico 1..6 (8b4242f8,1af72e0a,f2a47362,73de3d6b,cc82c28a,9e554538); identity RESTART 7. Pontas mortas históricas 73de3d6b e cc82c28a; be5ba68c (f2a47362) é pai de 3 itens (bifurcação documentada, hashes não reescritos). Pai canônico do 1º item novo: 9e554538. Buracos na numeração são aceitos (7e8ade27 H5).';

-- (H1) somente USAGE para authenticated (nextval/currval); sem SELECT/UPDATE; anon e PUBLIC sem nada
grant usage on sequence public.sonar_plasma_fila_seq_seq to authenticated;

-- =========================== P2 TRANSIÇÕES ===========================
-- (2.6) SEM BACKFILL: transições históricas não são fabricadas; a tabela nasce vazia.
create table public.sonar_plasma_transicoes (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references public.sonar_plasma_fila(id) on delete restrict,
  estado_de text not null,
  estado_para text not null,
  papel text not null,
  sessao_papel text,
  auth_uid uuid,
  quando timestamptz not null,
  motivo text
);
comment on table public.sonar_plasma_transicoes is 'Ciclo 4 (82830d2e P2): append-only, preenchida só pelo trigger AFTER UPDATE OF estado da fila. Sem backfill: começa vazia (transições anteriores ao Ciclo 4 não são inventadas).';
alter table public.sonar_plasma_transicoes enable row level security;
alter table public.sonar_plasma_transicoes force row level security;
revoke all on table public.sonar_plasma_transicoes from public, anon, authenticated, service_role;
grant select on table public.sonar_plasma_transicoes to authenticated;
grant select, insert on table public.sonar_plasma_transicoes to service_role;
create policy sonar_plasma_transicoes_select_guardiao on public.sonar_plasma_transicoes
  for select to authenticated using ((select public.eh_guardiao()));
create policy sonar_plasma_transicoes_service_role_select on public.sonar_plasma_transicoes
  for select to service_role using (true);
create policy sonar_plasma_transicoes_service_role_insert on public.sonar_plasma_transicoes
  for insert to service_role with check (true);

-- (2.3)/(2.4) registrador: INVOKER, search_path vazio, nada vem do cliente
create function public.sonar_plasma_fila_registra_transicao()
 returns trigger
 language plpgsql
 set search_path to ''
as $function$
begin
  insert into public.sonar_plasma_transicoes (item_id, estado_de, estado_para, papel, sessao_papel, auth_uid, quando, motivo)
  values (new.id, old.estado, new.estado, current_user, session_user, auth.uid(), pg_catalog.clock_timestamp(),
          'trigger sonar_plasma_fila_au_transicao');
  return null;
end;
$function$;

create trigger sonar_plasma_fila_au_transicao
  after update of estado on public.sonar_plasma_fila
  for each row when (old.estado is distinct from new.estado)
  execute function public.sonar_plasma_fila_registra_transicao();

-- =========================== P3 GUARDAS (e 2.2) ===========================
create function public.sonar_plasma_bloqueia_mutacao()
 returns trigger
 language plpgsql
 set search_path to ''
as $function$
begin
  raise exception 'sonar_plasma: % proibido em % (append-only / sem apagar histórico)', tg_op, tg_table_name using errcode = 'P0001';
end;
$function$;

create trigger sonar_plasma_transicoes_bu before update on public.sonar_plasma_transicoes for each row execute function public.sonar_plasma_bloqueia_mutacao();
create trigger sonar_plasma_transicoes_bd before delete on public.sonar_plasma_transicoes for each row execute function public.sonar_plasma_bloqueia_mutacao();
create trigger sonar_plasma_transicoes_bt before truncate on public.sonar_plasma_transicoes for each statement execute function public.sonar_plasma_bloqueia_mutacao();
create trigger sonar_plasma_fila_bd before delete on public.sonar_plasma_fila for each row execute function public.sonar_plasma_bloqueia_mutacao();
create trigger sonar_plasma_fila_bt before truncate on public.sonar_plasma_fila for each statement execute function public.sonar_plasma_bloqueia_mutacao();
create trigger sonar_plasma_saida_bd before delete on public.sonar_plasma_saida for each row execute function public.sonar_plasma_bloqueia_mutacao();
create trigger sonar_plasma_saida_bt before truncate on public.sonar_plasma_saida for each statement execute function public.sonar_plasma_bloqueia_mutacao();

-- (3.2)/(G3) funções novas: EXECUTE só postgres e service_role
revoke all on function public.sonar_plasma_fila_registra_transicao() from public, anon, authenticated;
revoke all on function public.sonar_plasma_bloqueia_mutacao() from public, anon, authenticated;
grant execute on function public.sonar_plasma_fila_registra_transicao() to postgres, service_role;
grant execute on function public.sonar_plasma_bloqueia_mutacao() to postgres, service_role;

-- (3.3) ROLLBACK DOCUMENTADO: exportar sonar_plasma_transicoes ANTES de qualquer DROP; depois DROP dos triggers
--   *_bd/*_bt/transicoes_bu/fila_au_transicao, DROP das funções sonar_plasma_bloqueia_mutacao e
--   sonar_plasma_fila_registra_transicao, DROP INDEX sonar_plasma_fila_hash_pai_pos6_uniq, restaurar _bi/_bu do ciclo 3,
--   REVOKE USAGE da sequência de authenticated. A coluna seq NÃO é removida. (3.4) Limite: postgres pode desligar triggers.

-- =========================== P5 ===========================
revoke execute on function public.fluxo_e2e_sonar_principal(uuid,character varying,character varying,text,character varying,character varying) from public, anon, authenticated;
revoke execute on function public.ligar_checkin_ao_checkpoint(uuid,uuid) from public, anon, authenticated;
alter function public.fluxo_e2e_sonar_principal(uuid,character varying,character varying,text,character varying,character varying) set search_path = '';
alter function public.ligar_checkin_ao_checkpoint(uuid,uuid) set search_path = '';

-- =========================== GUARDAS FINAIS (falha = aborta tudo) ===========================
do $$
declare v_r text; v_n int; v_c text; v_p text; v_bad int; v_acl text; v_x text;
begin
  select md5(pg_get_viewdef('public.v_mariana_v2_raiz'::regclass, true)) into v_r;
  select count(*) into v_n from public.v_mariana_v2_raiz;
  if v_r <> '6530cca31c0f287e95803bae3fcb66cc' or v_n <> 1 then raise exception 'HOLD G4: raiz % / %', v_r, v_n; end if;
  select md5(pg_get_functiondef('public.claim_sonar_item(uuid)'::regprocedure)) into v_c;
  select md5(pg_get_functiondef('public.responder_sonar_item(uuid,text,jsonb)'::regprocedure)) into v_p;
  if v_c <> '4b8bfde47103db796f0bed78abea1e08' then raise exception 'HOLD G6: claim %', v_c; end if;
  if v_p <> '7d493b5a5502e8b6ca65053e91a03d06' then raise exception 'HOLD G6: responder %', v_p; end if;
  select md5(prosrc) into v_x from pg_proc where oid = 'public.fluxo_e2e_sonar_principal(uuid,character varying,character varying,text,character varying,character varying)'::regprocedure;
  if v_x <> '79ebee4991264882268d2b8484620e74' then raise exception 'HOLD 5.3: fluxo prosrc %', v_x; end if;
  select md5(prosrc) into v_x from pg_proc where oid = 'public.ligar_checkin_ao_checkpoint(uuid,uuid)'::regprocedure;
  if v_x <> '0485d83fd579651a0c4a1ff146dcd0ce' then raise exception 'HOLD 5.3: ligar prosrc %', v_x; end if;
  select count(*) filter (where tgenabled <> 'O') + abs(count(*) - 12) into v_bad from pg_trigger
   where not tgisinternal and tgrelid in ('public.sonar_plasma_fila'::regclass,'public.sonar_plasma_saida'::regclass,'public.sonar_plasma_transicoes'::regclass);
  if v_bad <> 0 then raise exception 'HOLD 1.2/2.2/3.1: triggers fora do esperado'; end if;
  select string_agg(case when a.grantee = 0 then 'PUBLIC' else a.grantee::regrole::text end || ':' || a.privilege_type, ',' order by a.privilege_type)
    into v_acl from pg_class c cross join lateral aclexplode(c.relacl) a
   where c.oid = 'public.sonar_plasma_fila_seq_seq'::regclass
     and (a.grantee = 0 or a.grantee in ('anon'::regrole::oid, 'authenticated'::regrole::oid));
  if v_acl is distinct from 'authenticated:USAGE' then raise exception 'HOLD H1: acl da sequência %', v_acl; end if;
  if exists (select 1 from pg_proc where pronamespace = 'public'::regnamespace and prosecdef and (proname like 'sonar_plasma%' or proname in ('claim_sonar_item','responder_sonar_item','fluxo_e2e_sonar_principal','ligar_checkin_ao_checkpoint'))) then
    raise exception 'HOLD G2: security definer';
  end if;
  if (select string_agg(extname, ',' order by extname) from pg_extension) <> 'pg_cron,pg_stat_statements,pgcrypto,plpgsql,supabase_vault,uuid-ossp,wrappers' then
    raise exception 'HOLD G1: extensões mudaram';
  end if;
  if (select count(*) from public.sonar_plasma_transicoes) <> 0 then raise exception 'HOLD 2.6'; end if;
end $$;
