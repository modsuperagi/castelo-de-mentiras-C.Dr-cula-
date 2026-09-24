-- Migração 20260816003033 · trina_first_test_integrity
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

create unique index if not exists uq_trina_results_session_agent on public.trina_results(session_id, agent_id); create unique index if not exists uq_p0_audit_session_check on public.p0_audit(session_id, check_id); create index if not exists idx_sessions_created_at_ms on public.sessions(created_at_ms desc);
