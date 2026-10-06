-- Ciclo 1 (pedido 210f9385 / proposta db5b8f1d / parecer Norton c61834c5)
-- Fila de entrada e saída do SONAR da memória Plasma. Motor = fila de Grok Bots (sem polling).
-- Não toca v_mariana_v2_raiz nem suas tabelas-base.

create table public.sonar_plasma_fila (
  id uuid primary key default gen_random_uuid(),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  operacao text not null check (operacao in ('leitura','escrita')),
  memoria_ref text check (memoria_ref is null or char_length(memoria_ref) between 1 and 200),
  texto text not null check (char_length(texto) between 1 and 8000),
  estado text not null default 'pendente' check (estado in ('pendente','em_processamento','concluido','erro','cancelado')),
  motor text not null default 'grok_bot_fila',
  solicitante uuid,
  origem text not null default 'edge:sonar-plasma' check (char_length(origem) <= 100),
  chave_dedupe text not null unique,
  hash_pai text not null,
  hash text not null unique,
  ancora_id uuid not null default '657d6e4c-0ce0-4e8b-b5d2-8eafc579ada5'::uuid,
  cadeia text not null default 'v7.0-RAIZ → v8-CRUZAMENTO',
  pedido_ref uuid not null default '210f9385-fe5f-4474-85c9-602067c9e1f0'::uuid,
  fio_id uuid not null default 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid check (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid),
  nota_motor text
);

create table public.sonar_plasma_saida (
  id uuid primary key default gen_random_uuid(),
  criado_em timestamptz not null default now(),
  fila_id uuid not null references public.sonar_plasma_fila(id) on delete restrict,
  executor text not null check (char_length(executor) between 1 and 100),
  resultado jsonb not null default '{}'::jsonb,
  estado text not null default 'registrado' check (estado in ('registrado','erro')),
  chave_dedupe text not null unique,
  hash_pai text not null,
  hash text not null unique,
  fio_id uuid not null default 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid check (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

create index sonar_plasma_fila_estado_idx on public.sonar_plasma_fila (estado, criado_em);
create index sonar_plasma_saida_fila_idx on public.sonar_plasma_saida (fila_id);

-- Gênese da cadeia: âncora 657d6e4c (v7.0-RAIZ -> ROGUE-WAVE-v1 -> v8-CRUZAMENTO)
-- genesis = sha256('657d6e4c-0ce0-4e8b-b5d2-8eafc579ada5|v7.0-RAIZ|ROGUE-WAVE-v1 → v8-CRUZAMENTO')

create or replace function public.sonar_plasma_fila_bi()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_pai text;
begin
  -- serializa a cadeia
  perform pg_catalog.pg_advisory_xact_lock(hashtext('sonar_plasma_fila_cadeia'));
  new.criado_em := now();
  new.atualizado_em := new.criado_em;
  new.estado := 'pendente';
  new.motor := 'grok_bot_fila';
  new.ancora_id := '657d6e4c-0ce0-4e8b-b5d2-8eafc579ada5'::uuid;
  new.cadeia := 'v7.0-RAIZ → v8-CRUZAMENTO';
  new.fio_id := 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid;
  if auth.uid() is not null then
    new.solicitante := auth.uid();
  end if;
  -- chave_dedupe determinística (autoritativa no banco)
  new.chave_dedupe := 'SONAR-PLASMA|' || new.operacao || '|' ||
    encode(sha256(convert_to(new.operacao || '|' || coalesce(new.memoria_ref,'') || '|' || new.texto, 'UTF8')), 'hex');
  select f.hash into v_pai from public.sonar_plasma_fila f order by f.criado_em desc, f.id desc limit 1;
  if v_pai is null then
    v_pai := encode(sha256(convert_to('657d6e4c-0ce0-4e8b-b5d2-8eafc579ada5|v7.0-RAIZ|ROGUE-WAVE-v1 → v8-CRUZAMENTO', 'UTF8')), 'hex');
  end if;
  new.hash_pai := v_pai;
  new.hash := encode(sha256(convert_to(v_pai || '|' || new.chave_dedupe || '|' || new.criado_em::text, 'UTF8')), 'hex');
  return new;
end;
$$;

create or replace function public.sonar_plasma_fila_bu()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.chave_dedupe is distinct from old.chave_dedupe or new.hash is distinct from old.hash
     or new.hash_pai is distinct from old.hash_pai or new.texto is distinct from old.texto
     or new.operacao is distinct from old.operacao or new.memoria_ref is distinct from old.memoria_ref
     or new.criado_em is distinct from old.criado_em or new.ancora_id is distinct from old.ancora_id then
    raise exception 'sonar_plasma_fila: campos de linhagem são imutáveis';
  end if;
  new.atualizado_em := now();
  return new;
end;
$$;

create or replace function public.sonar_plasma_saida_bi()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_pai text;
begin
  new.criado_em := now();
  new.fio_id := 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid;
  select f.hash into v_pai from public.sonar_plasma_fila f where f.id = new.fila_id;
  if v_pai is null then
    raise exception 'sonar_plasma_saida: fila_id inexistente';
  end if;
  new.chave_dedupe := 'SONAR-PLASMA-SAIDA|' || new.fila_id::text;
  new.hash_pai := v_pai;
  new.hash := encode(sha256(convert_to(v_pai || '|' || new.chave_dedupe || '|' || new.resultado::text || '|' || new.criado_em::text, 'UTF8')), 'hex');
  return new;
end;
$$;

create or replace function public.sonar_plasma_saida_bu()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  raise exception 'sonar_plasma_saida: registros de saída são imutáveis';
end;
$$;

create trigger sonar_plasma_fila_bi before insert on public.sonar_plasma_fila for each row execute function public.sonar_plasma_fila_bi();
create trigger sonar_plasma_fila_bu before update on public.sonar_plasma_fila for each row execute function public.sonar_plasma_fila_bu();
create trigger sonar_plasma_saida_bi before insert on public.sonar_plasma_saida for each row execute function public.sonar_plasma_saida_bi();
create trigger sonar_plasma_saida_bu before update on public.sonar_plasma_saida for each row execute function public.sonar_plasma_saida_bu();

revoke all on function public.sonar_plasma_fila_bi() from public, anon, authenticated;
revoke all on function public.sonar_plasma_fila_bu() from public, anon, authenticated;
revoke all on function public.sonar_plasma_saida_bi() from public, anon, authenticated;
revoke all on function public.sonar_plasma_saida_bu() from public, anon, authenticated;

-- RLS + grants
alter table public.sonar_plasma_fila enable row level security;
alter table public.sonar_plasma_saida enable row level security;
alter table public.sonar_plasma_fila force row level security;
alter table public.sonar_plasma_saida force row level security;

revoke all on table public.sonar_plasma_fila from public, anon, authenticated;
revoke all on table public.sonar_plasma_saida from public, anon, authenticated;
grant select, insert on table public.sonar_plasma_fila to authenticated;
grant select on table public.sonar_plasma_saida to authenticated;
grant all on table public.sonar_plasma_fila to service_role;
grant all on table public.sonar_plasma_saida to service_role;

create policy sonar_plasma_fila_select_guardiao on public.sonar_plasma_fila
  for select to authenticated using ((select public.eh_guardiao()));
create policy sonar_plasma_fila_insert_guardiao on public.sonar_plasma_fila
  for insert to authenticated with check ((select public.eh_guardiao()) and solicitante = (select auth.uid()));
create policy sonar_plasma_saida_select_guardiao on public.sonar_plasma_saida
  for select to authenticated using ((select public.eh_guardiao()));
create policy sonar_plasma_fila_service_role_all on public.sonar_plasma_fila
  for all to service_role using (true) with check (true);
create policy sonar_plasma_saida_service_role_all on public.sonar_plasma_saida
  for all to service_role using (true) with check (true);

comment on table public.sonar_plasma_fila is 'SONAR Plasma ciclo 1: fila de pedidos de leitura/escrita de memória Plasma; motor = Grok Bots via fila (sem polling). chave_dedupe + hash encadeado desde âncora 657d6e4c. Não validado (Norton revisa deploy; Golden valida).';
comment on table public.sonar_plasma_saida is 'SONAR Plasma ciclo 1: resultados escritos pelos Grok Bots (service_role/postgres). hash_pai = hash do item da fila.';
