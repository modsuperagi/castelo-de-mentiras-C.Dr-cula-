-- Migração 20260814005334 · create_evo_memorias_v2_mariana
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create table if not exists public.evo_memorias (id uuid primary key default gen_random_uuid(), chave_dedupe text not null unique, identidade text not null, nucleo text not null, colecao text not null, tipo_conteudo text not null, titulo text not null, conteudo text not null, estado text not null default 'selado', fonte text, data_fonte timestamptz, grau_confianca text, verificado_por text, metadata jsonb not null default '{}'::jsonb, criado_em timestamptz not null default now()); alter table public.evo_memorias enable row level security;
