-- Migração 20260914194449 · 004_create_evo_agentes
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

CREATE TABLE IF NOT EXISTS evo_agentes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID,
  nome TEXT NOT NULL UNIQUE,
  camada_evo TEXT NOT NULL,
  funcao TEXT,
  status_ativo BOOLEAN DEFAULT true,
  comandos_permitidos TEXT[],
  ultima_acao TIMESTAMP,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT check_fio_id_agentes CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID)
);
