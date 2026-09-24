-- Migração 20260921223547 · criar_tabela_arquivos_fio
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- Criar tabela arquivos_fio_ee46c360 se não existir
CREATE TABLE IF NOT EXISTS arquivos_fio_ee46c360 (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio VARCHAR(50) NOT NULL,
  nome_arquivo VARCHAR(500) NOT NULL,
  tipo VARCHAR(100),
  hash_sha256 VARCHAR(64),
  tamanho_bytes BIGINT,
  descricao TEXT,
  status_epistemico VARCHAR(100) DEFAULT 'INTEGRADO',
  data_ingestao TIMESTAMP DEFAULT NOW(),
  data_auditoria TIMESTAMP,
  motor_operador VARCHAR(100),
  decisao_motor VARCHAR(100),
  categoria_motor VARCHAR(100),
  ordem_ingestao INTEGER,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_fio_ee46c360 ON arquivos_fio_ee46c360(fio);
CREATE INDEX IF NOT EXISTS idx_tipo_arquivo ON arquivos_fio_ee46c360(tipo);
CREATE INDEX IF NOT EXISTS idx_status_epistemico ON arquivos_fio_ee46c360(status_epistemico);
CREATE INDEX IF NOT EXISTS idx_hash_sha256 ON arquivos_fio_ee46c360(hash_sha256);
