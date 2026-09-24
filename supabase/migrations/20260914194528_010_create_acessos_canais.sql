-- Migração 20260914194528 · 010_create_acessos_canais
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

CREATE TABLE IF NOT EXISTS acessos_canais (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID,
  canal TEXT NOT NULL UNIQUE,
  descricao TEXT,
  nivel_acesso TEXT NOT NULL DEFAULT 'nucleo',
  link TEXT,
  responsavel TEXT NOT NULL,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ativo BOOLEAN DEFAULT true,
  CONSTRAINT check_fio_id_canais CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID),
  CONSTRAINT check_nivel_canais CHECK (nivel_acesso IN ('nucleo', 'confianca', 'estrutura', 'publico'))
);
