-- Migração 20260816004552 · sol_operational_runtime_v1
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create table if not exists public.sol_missions (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references auth.users(id),
  title text not null,
  instruction text not null,
  status text not null default 'queued' check (status in ('queued','running','paused','completed','failed','cancelled')),
  priority int not null default 100,
  max_rounds int not null default 10,
  current_round int not null default 0,
  stop_reason text,
  context jsonb not null default '{}'::jsonb
);

create table if not exists public.sol_tasks (
  id uuid primary key default gen_random_uuid(),
  mission_id uuid not null references public.sol_missions(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  task_type text not null default 'analysis',
  title text not null,
  instruction text not null,
  assigned_agent text not null check (assigned_agent in ('karpathy-model','willison-tool','chase-agent')),
  status text not null default 'queued' check (status in ('queued','running','completed','failed','blocked')),
  priority int not null default 100,
  attempt_count int not null default 0,
  depends_on uuid references public.sol_tasks(id),
  input_context jsonb not null default '{}'::jsonb,
  output text,
  evidence jsonb not null default '{}'::jsonb,
  error text
);

create table if not exists public.sol_runs (
  id uuid primary key default gen_random_uuid(),
  mission_id uuid not null references public.sol_missions(id) on delete cascade,
  task_id uuid references public.sol_tasks(id) on delete cascade,
  agent_slug text not null,
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  status text not null check (status in ('running','completed','failed')),
  model text,
  latency_ms int,
  input_tokens int,
  output_tokens int,
  result jsonb not null default '{}'::jsonb,
  error text
);

create index if not exists idx_sol_missions_status_priority on public.sol_missions(status, priority, created_at);
create index if not exists idx_sol_tasks_queue on public.sol_tasks(status, priority, created_at);
create index if not exists idx_sol_tasks_mission on public.sol_tasks(mission_id);
create index if not exists idx_sol_runs_mission on public.sol_runs(mission_id, started_at desc);

alter table public.sol_missions enable row level security;
alter table public.sol_tasks enable row level security;
alter table public.sol_runs enable row level security;

create policy "sol_missions_owner_select" on public.sol_missions for select using (auth.uid() = created_by);
create policy "sol_missions_owner_insert" on public.sol_missions for insert with check (auth.uid() = created_by);
create policy "sol_missions_owner_update" on public.sol_missions for update using (auth.uid() = created_by) with check (auth.uid() = created_by);

create policy "sol_tasks_owner_select" on public.sol_tasks for select using (exists (select 1 from public.sol_missions m where m.id = mission_id and m.created_by = auth.uid()));
create policy "sol_runs_owner_select" on public.sol_runs for select using (exists (select 1 from public.sol_missions m where m.id = mission_id and m.created_by = auth.uid()));

create or replace function public.sol_touch_updated_at() returns trigger language plpgsql as $$ begin new.updated_at = now(); return new; end $$;
drop trigger if exists sol_missions_touch on public.sol_missions;
create trigger sol_missions_touch before update on public.sol_missions for each row execute function public.sol_touch_updated_at();
drop trigger if exists sol_tasks_touch on public.sol_tasks;
create trigger sol_tasks_touch before update on public.sol_tasks for each row execute function public.sol_touch_updated_at();
