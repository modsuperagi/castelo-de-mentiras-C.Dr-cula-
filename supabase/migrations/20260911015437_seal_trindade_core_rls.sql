-- Migração 20260911015437 · seal_trindade_core_rls
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

alter table public.checkin_recepcion enable row level security;
alter table public.p0_validacao_completa enable row level security;
alter table public.coracao_motor_principal enable row level security;
alter table public.trina_circulacao_principal enable row level security;
alter table public.golden_circulacao_principal enable row level security;
alter table public.consolidacao_circulacao_principal enable row level security;
alter table public.auditoria_p0_sonar enable row level security;
alter table public.evidencias_consolidadas enable row level security;
