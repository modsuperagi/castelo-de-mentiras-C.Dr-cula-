-- Migração 20260914194525 · 009_create_registro_evolucoes
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

CREATE TABLE IF NOT EXISTS registro_evolucoes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID,
  versao TEXT NOT NULL UNIQUE,
  mudanca TEXT NOT NULL,
  data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  responsavel TEXT NOT NULL,
  impacto TEXT,
  validado_por_guardiao BOOLEAN DEFAULT false,
  CONSTRAINT check_fio_id_evolucoes CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID)
);

CREATE OR REPLACE FUNCTION trg_bloquear_delete_evolucoes()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'Histórico de Evolução não pode ser deletado. Apenas marque como descontinuado via nota.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_no_delete_evolucoes
BEFORE DELETE ON registro_evolucoes
FOR EACH ROW
EXECUTE FUNCTION trg_bloquear_delete_evolucoes();
