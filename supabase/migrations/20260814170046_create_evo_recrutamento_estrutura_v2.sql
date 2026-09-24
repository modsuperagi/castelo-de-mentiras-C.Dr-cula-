-- Migração 20260814170046 · create_evo_recrutamento_estrutura_v2
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create table if not exists public.recrutamento_estrutura (
  id uuid primary key default gen_random_uuid(),
  chave text not null,
  versao text not null,
  total_recrutas integer not null,
  trindade_count integer not null,
  sol_count integer not null,
  status text not null,
  validado_por text,
  executado_por text,
  estrutura_json jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (chave, versao)
);

create table if not exists public.recrutas_funcoes_casa (
  id uuid primary key default gen_random_uuid(),
  nome text not null unique,
  trindade text,
  papel text,
  funcao_casa text,
  agente_prefixo text,
  fluxo text,
  nivel text not null,
  comando text,
  status text not null default 'ativo',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.recrutamento_estrutura enable row level security;
alter table public.recrutas_funcoes_casa enable row level security;

create policy "recrutamento_estrutura_authenticated_select" on public.recrutamento_estrutura for select to authenticated using (true);
create policy "recrutamento_estrutura_authenticated_insert" on public.recrutamento_estrutura for insert to authenticated with check (true);
create policy "recrutamento_estrutura_authenticated_update" on public.recrutamento_estrutura for update to authenticated using (true) with check (true);

create policy "recrutas_funcoes_casa_authenticated_select" on public.recrutas_funcoes_casa for select to authenticated using (true);
create policy "recrutas_funcoes_casa_authenticated_insert" on public.recrutas_funcoes_casa for insert to authenticated with check (true);
create policy "recrutas_funcoes_casa_authenticated_update" on public.recrutas_funcoes_casa for update to authenticated using (true) with check (true);

grant select, insert, update on public.recrutamento_estrutura to authenticated;
grant select, insert, update on public.recrutas_funcoes_casa to authenticated;
