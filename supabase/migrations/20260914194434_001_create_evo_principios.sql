-- Migração 20260914194434 · 001_create_evo_principios
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

CREATE TABLE IF NOT EXISTS evo_principios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID,
  principio TEXT NOT NULL,
  descricao TEXT,
  validacao_1 TEXT NOT NULL,
  validacao_2 TEXT NOT NULL,
  validacao_3 TEXT NOT NULL,
  ativo BOOLEAN DEFAULT true,
  responsavel TEXT NOT NULL,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT check_fio_id_principios CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID),
  UNIQUE(principio)
);
