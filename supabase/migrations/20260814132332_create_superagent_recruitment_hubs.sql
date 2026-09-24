-- Migração 20260814132332 · create_superagent_recruitment_hubs
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create table if not exists public.evo_recrutamento_agentes (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  nome text not null,
  grupo text not null,
  funcao_original text not null,
  papel_evo text not null,
  periodo text,
  status text not null default 'fundamentacao',
  prioridade integer not null default 1,
  resumo text not null,
  dominios jsonb not null default '[]'::jsonb,
  protocolo_recrutamento jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table if not exists public.evo_recrutamento_conhecimento (
  id uuid primary key default gen_random_uuid(),
  agente_id uuid not null references public.evo_recrutamento_agentes(id) on delete cascade,
  tipo text not null,
  titulo text not null,
  conteudo text not null,
  ordem integer not null default 1,
  nivel text not null default 'fundamental',
  status text not null default 'fundamentacao',
  fonte_principal text,
  fontes jsonb not null default '[]'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);

create table if not exists public.evo_recrutamento_fontes (
  id uuid primary key default gen_random_uuid(),
  agente_id uuid references public.evo_recrutamento_agentes(id) on delete cascade,
  titulo text not null,
  url text not null,
  tipo text not null,
  autoridade text,
  observacao text,
  acessado_em timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb
);

create index if not exists idx_evo_recrutamento_conhecimento_agente on public.evo_recrutamento_conhecimento(agente_id, ordem);
create index if not exists idx_evo_recrutamento_conhecimento_tipo on public.evo_recrutamento_conhecimento(tipo);
create index if not exists idx_evo_recrutamento_fontes_agente on public.evo_recrutamento_fontes(agente_id);

alter table public.evo_recrutamento_agentes enable row level security;
alter table public.evo_recrutamento_conhecimento enable row level security;
alter table public.evo_recrutamento_fontes enable row level security;

create policy "recrutamento agentes leitura autenticada" on public.evo_recrutamento_agentes for select to authenticated using (true);
create policy "recrutamento conhecimento leitura autenticada" on public.evo_recrutamento_conhecimento for select to authenticated using (true);
create policy "recrutamento fontes leitura autenticada" on public.evo_recrutamento_fontes for select to authenticated using (true);

comment on table public.evo_recrutamento_agentes is 'Hub de recrutamento dos futuros superagentes do organismo EVO. Estrutura funcional, não personificação histórica.';
comment on table public.evo_recrutamento_conhecimento is 'Biblioteca modular de conhecimento por agente; preparada para ingestão, revisão e futura busca semântica.';
comment on table public.evo_recrutamento_fontes is 'Registro de fontes e rastreabilidade da biblioteca de recrutamento.';
