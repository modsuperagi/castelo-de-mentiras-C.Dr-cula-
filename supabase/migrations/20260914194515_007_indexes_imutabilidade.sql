-- Migração 20260914194515 · 007_indexes_imutabilidade
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

CREATE INDEX idx_decisoes_status ON registro_decisoes(status);
CREATE INDEX idx_decisoes_nivel_acesso ON registro_decisoes(nivel_acesso);
CREATE INDEX idx_decisoes_data ON registro_decisoes(data_decisao DESC);

CREATE OR REPLACE FUNCTION trg_bloquear_update_decisoes()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'Registro de Decisões é imutável. Use data_revisao ou data_descontinuacao para tracking.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_immutable_decisoes
BEFORE UPDATE ON registro_decisoes
FOR EACH ROW
EXECUTE FUNCTION trg_bloquear_update_decisoes();
