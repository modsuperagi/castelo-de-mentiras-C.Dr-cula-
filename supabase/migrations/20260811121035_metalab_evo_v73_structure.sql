-- Migração 20260811121035 · metalab_evo_v73_structure
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

begin;

-- v7.3: non-destructive structural migration for META LAB EVO
alter table public.meta_lab_entries
  add column if not exists chave_dedupe text,
  add column if not exists tipo_conteudo text,
  add column if not exists estado text,
  add column if not exists fonte text,
  add column if not exists data_fonte timestamptz,
  add column if not exists tipo_fonte text,
  add column if not exists grau_confianca text,
  add column if not exists verificado_por text;

alter table public.consolidacoes
  add column if not exists chave_dedupe text;

-- Audit trail: append-only history of changes to EVO records.
create table if not exists public.meta_lab_auditoria (
  id uuid primary key default gen_random_uuid(),
  tabela_origem text not null,
  registro_id text not null,
  acao text not null,
  quem_alterou text not null,
  quando_alterou timestamptz not null default timezone('utc', now()),
  versao_anterior jsonb,
  versao_nova jsonb,
  motivo text not null,
  autorizacao text not null,
  origem text not null,
  criado_em timestamptz not null default timezone('utc', now())
);

-- Version snapshots preserve previous state instead of destructive overwrite.
create table if not exists public.meta_lab_versoes (
  id uuid primary key default gen_random_uuid(),
  tabela_origem text not null,
  registro_id text not null,
  versao integer not null,
  estado_snapshot jsonb not null,
  criado_em timestamptz not null default timezone('utc', now()),
  criado_por text not null,
  motivo text not null,
  autorizacao text not null,
  origem text not null,
  unique (tabela_origem, registro_id, versao)
);

-- Deduplication indexes; NULLs remain allowed for legacy rows until classified.
create unique index if not exists meta_lab_entries_chave_dedupe_uidx
  on public.meta_lab_entries (chave_dedupe)
  where chave_dedupe is not null;

create unique index if not exists consolidacoes_chave_dedupe_uidx
  on public.consolidacoes (chave_dedupe)
  where chave_dedupe is not null;

create index if not exists meta_lab_entries_estado_idx
  on public.meta_lab_entries (estado);

create index if not exists meta_lab_entries_colecao_idx
  on public.meta_lab_entries (colecao);

create index if not exists meta_lab_auditoria_registro_idx
  on public.meta_lab_auditoria (tabela_origem, registro_id, quando_alterou desc);

create index if not exists meta_lab_versoes_registro_idx
  on public.meta_lab_versoes (tabela_origem, registro_id, versao desc);

-- v7.3 canonical lifecycle values.
alter table public.meta_lab_entries
  drop constraint if exists meta_lab_entries_estado_check;
alter table public.meta_lab_entries
  add constraint meta_lab_entries_estado_check
  check (estado is null or estado in ('entrada','em análise','evidência','interpretação','decisão','consolidado','arquivado','obsoleto'));

commit;
