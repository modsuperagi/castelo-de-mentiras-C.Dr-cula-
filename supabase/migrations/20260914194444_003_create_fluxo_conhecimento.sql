-- Migração 20260914194444 · 003_create_fluxo_conhecimento
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

CREATE TABLE IF NOT EXISTS fluxo_conhecimento (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID,
  titulo TEXT NOT NULL,
  origem TEXT,
  data_entrada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  camada TEXT NOT NULL,
  conteudo TEXT,
  conexoes UUID[],
  aprendizado TEXT,
  tags TEXT[],
  responsavel TEXT NOT NULL,
  data_refino TIMESTAMP,
  data_transmissao TIMESTAMP,
  CONSTRAINT check_fio_id_fluxo CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID),
  CONSTRAINT check_camada CHECK (camada IN ('bruto', 'refinado', 'transmissivel'))
);
