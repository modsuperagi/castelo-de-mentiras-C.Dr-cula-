-- Migração 20260905024727 · create_evo_porta_entrada
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create table if not exists public.evo_porta_entrada (
  id uuid primary key default gen_random_uuid(),
  flow_id uuid,
  identidade text,
  nucleo text,
  selo text,
  determinacao text,
  tipo_registro text not null default 'entrada',
  conteudo text not null,
  origem text,
  origem_instancia text,
  referencia_checkpoint uuid,
  metadata jsonb not null default '{}'::jsonb,
  criado_em timestamptz not null default now()
);

create index if not exists idx_evo_porta_entrada_flow_id on public.evo_porta_entrada(flow_id);
create index if not exists idx_evo_porta_entrada_identidade on public.evo_porta_entrada(identidade);
create index if not exists idx_evo_porta_entrada_criado_em on public.evo_porta_entrada(criado_em desc);

alter table public.evo_porta_entrada enable row level security;

create policy "evo_porta_entrada_read_authenticated"
on public.evo_porta_entrada
for select
to authenticated
using (true);

create policy "evo_porta_entrada_insert_authenticated"
on public.evo_porta_entrada
for insert
to authenticated
with check (true);

revoke update, delete on public.evo_porta_entrada from authenticated;
revoke update, delete on public.evo_porta_entrada from anon;
