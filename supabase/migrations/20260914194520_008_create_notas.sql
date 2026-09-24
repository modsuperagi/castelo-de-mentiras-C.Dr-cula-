-- Migração 20260914194520 · 008_create_notas
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

CREATE TABLE IF NOT EXISTS notas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID,
  titulo TEXT NOT NULL,
  corpo TEXT,
  categoria_evo TEXT NOT NULL,
  tags TEXT[],
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status TEXT DEFAULT 'ativa',
  relacionado_a_conhecimento UUID,
  responsavel TEXT,
  CONSTRAINT check_fio_id_notas CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID),
  CONSTRAINT check_categoria_evo CHECK (categoria_evo IN ('EVO1', 'EVO2', 'EVO3', 'EVO4', 'EVO5', 'EVO6'))
);
