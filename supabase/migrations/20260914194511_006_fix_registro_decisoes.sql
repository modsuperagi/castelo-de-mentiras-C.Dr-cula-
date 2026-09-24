-- Migração 20260914194511 · 006_fix_registro_decisoes
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

DROP TABLE IF EXISTS registro_decisoes CASCADE;

CREATE TABLE registro_decisoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID,
  decisao TEXT NOT NULL,
  motivo TEXT,
  mudanca TEXT,
  data_decisao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  responsavel TEXT NOT NULL,
  nivel_acesso TEXT NOT NULL DEFAULT 'estrutura',
  link TEXT,
  status TEXT DEFAULT 'ativa',
  relacionado_a_conhecimento UUID,
  relacionado_a_agente UUID,
  data_revisao TIMESTAMP,
  data_descontinuacao TIMESTAMP,
  CONSTRAINT check_fio_id_decisoes CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID),
  CONSTRAINT check_nivel_acesso CHECK (nivel_acesso IN ('nucleo', 'confianca', 'estrutura', 'publico')),
  CONSTRAINT check_status_decisoes CHECK (status IN ('ativa', 'revisada', 'descontinuada'))
);
