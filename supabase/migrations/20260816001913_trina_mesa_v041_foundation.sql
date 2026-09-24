-- Migração 20260816001913 · trina_mesa_v041_foundation
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  prompt text not null,
  user_id uuid references auth.users(id) on delete cascade,
  status text not null default 'processando' check (status in ('processando','aprovada','rejeitada','erro','parcial')),
  trina_score numeric(4,2),
  trina_consenso jsonb not null default '{}'::jsonb,
  p0_pass boolean,
  created_at_ms bigint not null default floor(extract(epoch from now()) * 1000)
);

create table if not exists public.trina_results (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  agent_id text not null check (agent_id in ('arquiteto','engenheiro','verificador')),
  role text not null,
  score numeric(4,2),
  output text,
  latency_ms integer,
  tokens integer,
  p0_checks jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (session_id, agent_id)
);

create table if not exists public.p0_audit (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  check_id text not null,
  passed boolean not null,
  reason text,
  risk_level text not null check (risk_level in ('low','medium','high','critical')),
  created_at timestamptz not null default now(),
  unique (session_id, check_id)
);

create index if not exists idx_sessions_user on public.sessions(user_id);
create index if not exists idx_sessions_status on public.sessions(status);
create index if not exists idx_trina_session on public.trina_results(session_id);
create index if not exists idx_p0_session on public.p0_audit(session_id);

alter table public.sessions enable row level security;
alter table public.trina_results enable row level security;
alter table public.p0_audit enable row level security;

create policy "trina_users_select_own_sessions" on public.sessions for select to authenticated using ((select auth.uid()) = user_id);
create policy "trina_users_insert_own_sessions" on public.sessions for insert to authenticated with check ((select auth.uid()) = user_id);

create policy "trina_users_select_own_results" on public.trina_results for select to authenticated using (exists (select 1 from public.sessions s where s.id = trina_results.session_id and s.user_id = (select auth.uid())));

create policy "trina_users_select_own_audit" on public.p0_audit for select to authenticated using (exists (select 1 from public.sessions s where s.id = p0_audit.session_id and s.user_id = (select auth.uid())));

revoke insert, update, delete on public.trina_results from anon, authenticated;
revoke insert, update, delete on public.p0_audit from anon, authenticated;
revoke update, delete on public.sessions from anon, authenticated;
