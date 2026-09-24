-- Migração 20260914194026 · ponte_bidirecional_ghost_castelo_mariana_sync
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- =====================================================
-- PONTE BIDIRECIONAL GHOST ↔ CASTELO
-- =====================================================
-- Objetivo: Sincronizar Mariana V2 (Ghost/Claude) ↔ Castelo (Principal)
-- Responsável: Mariana V4 (Proprietária do Castelo)
-- Fio: ee46c360-b95b-426e-86c3-2e5d0ccbe916
-- Status: ATIVA — Sincronização Real-time
-- =====================================================

-- =====================================================
-- TABELA: PONTE_GHOST_CASTELO (Hub de Sincronização)
-- =====================================================
CREATE TABLE IF NOT EXISTS ponte_ghost_castelo (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  -- Identidade
  identidade_nome VARCHAR(255) NOT NULL,
  identidade_tipo VARCHAR(50) NOT NULL 
    CHECK (identidade_tipo IN ('MARIANA_V2', 'MARIANA_V4', 'CASTELO', 'RECURSO')),
  
  -- Origem + Destino
  origem_sistema VARCHAR(50) NOT NULL
    CHECK (origem_sistema IN ('GHOST_CLAUDE_APP', 'PRINCIPAL_SUPABASE', 'LAB_SUPABASE', 'EXTERNO')),
  origem_id UUID NOT NULL,
  origem_tipo_tabela VARCHAR(100),
  
  destino_sistema VARCHAR(50) NOT NULL
    CHECK (destino_sistema IN ('GHOST_CLAUDE_APP', 'PRINCIPAL_SUPABASE', 'LAB_SUPABASE', 'EXTERNO')),
  destino_id UUID,
  destino_tipo_tabela VARCHAR(100),
  
  -- Payload + Metadados
  dados_sincronizar JSONB DEFAULT '{}',
  status_sinc VARCHAR(50) DEFAULT 'pendente'
    CHECK (status_sinc IN ('pendente', 'sincronizando', 'sincronizado', 'conflito', 'erro')),
  direcao_sinc VARCHAR(20) DEFAULT 'dupla'
    CHECK (direcao_sinc IN ('ghost_para_castelo', 'castelo_para_ghost', 'dupla')),
  
  -- Validação + Autoridade
  validado_por_mariana BOOLEAN DEFAULT FALSE,
  pode_sobrescrever BOOLEAN DEFAULT FALSE,
  
  -- Timeline
  timestamp_origem TIMESTAMP,
  timestamp_sinc TIMESTAMP,
  timestamp_confirmacao TIMESTAMP,
  
  -- Rastreamento
  hash_origem VARCHAR(64),
  hash_destino VARCHAR(64),
  versao_sinc INT DEFAULT 1,
  
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT fio_raiz_fixo CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

CREATE INDEX idx_ponte_origem ON ponte_ghost_castelo(origem_sistema, origem_id);
CREATE INDEX idx_ponte_destino ON ponte_ghost_castelo(destino_sistema, destino_id);
CREATE INDEX idx_ponte_identidade ON ponte_ghost_castelo(identidade_nome);
CREATE INDEX idx_ponte_status ON ponte_ghost_castelo(status_sinc);
CREATE INDEX idx_ponte_fio ON ponte_ghost_castelo(fio_id);

ALTER TABLE ponte_ghost_castelo ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- TABELA: MARIANA_CASTING (Repositório de Identidades)
-- =====================================================
CREATE TABLE IF NOT EXISTS mariana_casting (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  -- Versão e Localização
  versao VARCHAR(20) NOT NULL UNIQUE,
  localizacao VARCHAR(50) NOT NULL
    CHECK (localizacao IN ('GHOST_LOCAL', 'PRINCIPAL_DB', 'AMBAS')),
  status_vida VARCHAR(50) DEFAULT 'ativa'
    CHECK (status_vida IN ('fundamentacao', 'ativa', 'sincronizada', 'dividida', 'unificada')),
  
  -- Mariana V2 (Ghost)
  mariana_v2_localizado BOOLEAN DEFAULT FALSE,
  mariana_v2_estrutura JSONB DEFAULT '{}',
  mariana_v2_timestamp TIMESTAMP,
  
  -- Mariana V4 (Proprietária do Castelo)
  mariana_v4_localizado BOOLEAN DEFAULT FALSE,
  mariana_v4_estrutura JSONB DEFAULT '{}',
  mariana_v4_timestamp TIMESTAMP,
  
  -- Estado de Sincronização
  sincronizada_v2_v4 BOOLEAN DEFAULT FALSE,
  ultima_sincronizacao TIMESTAMP,
  tempo_sincronizacao_ms INT,
  conflitos_detectados INT DEFAULT 0,
  conflitos_resolvidos INT DEFAULT 0,
  
  -- Dados Consolidados
  dados_consolidados JSONB DEFAULT '{}',
  linhagem_completa JSONB DEFAULT '{}',
  
  -- Autoridade
  proprietaria_castelo BOOLEAN DEFAULT FALSE,
  verificada_por_guardiao BOOLEAN DEFAULT FALSE,
  
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT fio_raiz_fixo CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

CREATE INDEX idx_mariana_versao ON mariana_casting(versao);
CREATE INDEX idx_mariana_status ON mariana_casting(status_vida);
CREATE INDEX idx_mariana_sincronizada ON mariana_casting(sincronizada_v2_v4);
CREATE INDEX idx_mariana_fio ON mariana_casting(fio_id);

ALTER TABLE mariana_casting ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- TABELA: LOG_SINCRONIZACAO (Auditoria)
-- =====================================================
CREATE TABLE IF NOT EXISTS log_sincronizacao (
  id BIGSERIAL PRIMARY KEY,
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  ponte_id UUID NOT NULL REFERENCES ponte_ghost_castelo(id) ON DELETE CASCADE,
  
  evento VARCHAR(100) NOT NULL,
  sentido VARCHAR(50) NOT NULL,
  dados_antes JSONB,
  dados_depois JSONB,
  
  usuario_agente VARCHAR(150),
  timestamp_evento TIMESTAMP DEFAULT NOW(),
  status_final VARCHAR(50),
  
  CONSTRAINT fio_raiz_fixo CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

CREATE INDEX idx_log_sinc_ponte ON log_sincronizacao(ponte_id);
CREATE INDEX idx_log_sinc_evento ON log_sincronizacao(evento);
CREATE INDEX idx_log_sinc_timestamp ON log_sincronizacao(timestamp_evento);

ALTER TABLE log_sincronizacao ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- TRIGGER: Auto-sincronização quando registro_decisoes é inserido
-- =====================================================
CREATE OR REPLACE FUNCTION sincroniza_decisao_para_ponte()
RETURNS TRIGGER AS $$
BEGIN
  -- Cria entrada de ponte para nova decisão
  INSERT INTO ponte_ghost_castelo (
    fio_id, identidade_nome, identidade_tipo,
    origem_sistema, origem_id, origem_tipo_tabela,
    destino_sistema, destino_tipo_tabela,
    dados_sincronizar, direcao_sinc, status_sinc
  ) VALUES (
    'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
    'MARIANA_V4',
    'MARIANA_V4',
    'PRINCIPAL_SUPABASE',
    NEW.id,
    'registro_decisoes',
    'GHOST_CLAUDE_APP',
    'decisoes_mariana',
    jsonb_build_object(
      'decisao', NEW.decisao,
      'motivo', NEW.motivo,
      'responsavel', NEW.responsavel,
      'timestamp', NEW.data_decisao
    ),
    'dupla',
    'pendente'
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sincroniza_decisoes ON registro_decisoes;
CREATE TRIGGER trg_sincroniza_decisoes
  AFTER INSERT ON registro_decisoes
  FOR EACH ROW
  EXECUTE FUNCTION sincroniza_decisao_para_ponte();

-- =====================================================
-- TRIGGER: Auto-sincronização quando notas são inseridas
-- =====================================================
CREATE OR REPLACE FUNCTION sincroniza_nota_para_ponte()
RETURNS TRIGGER AS $$
BEGIN
  -- Cria entrada de ponte para novas notas
  INSERT INTO ponte_ghost_castelo (
    fio_id, identidade_nome, identidade_tipo,
    origem_sistema, origem_id, origem_tipo_tabela,
    destino_sistema, destino_tipo_tabela,
    dados_sincronizar, direcao_sinc, status_sinc
  ) VALUES (
    'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
    'MARIANA_V4',
    'MARIANA_V4',
    'PRINCIPAL_SUPABASE',
    NEW.id,
    'notas',
    'GHOST_CLAUDE_APP',
    'notas_mariana',
    jsonb_build_object(
      'titulo', NEW.titulo,
      'corpo', NEW.corpo,
      'categoria_evo', NEW.categoria_evo,
      'criador', NEW.criador
    ),
    'dupla',
    'pendente'
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sincroniza_notas ON notas;
CREATE TRIGGER trg_sincroniza_notas
  AFTER INSERT ON notas
  FOR EACH ROW
  EXECUTE FUNCTION sincroniza_nota_para_ponte();

-- =====================================================
-- FUNÇÃO: Registra mudança em log_sincronizacao
-- =====================================================
CREATE OR REPLACE FUNCTION log_sincronizacao_evento()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO log_sincronizacao (
    fio_id, ponte_id, evento, sentido,
    dados_antes, dados_depois,
    usuario_agente, status_final
  ) VALUES (
    'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
    NEW.id,
    CASE 
      WHEN NEW.status_sinc = 'sincronizado' THEN 'SINCRONIZACAO_COMPLETA'
      WHEN NEW.status_sinc = 'conflito' THEN 'CONFLITO_DETECTADO'
      WHEN NEW.status_sinc = 'erro' THEN 'ERRO_SINCRONIZACAO'
      ELSE 'PENDENTE'
    END,
    NEW.direcao_sinc,
    NULL,
    NEW.dados_sincronizar,
    'SISTEMA_SINC',
    NEW.status_sinc
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_log_sinc_ponte ON ponte_ghost_castelo;
CREATE TRIGGER trg_log_sinc_ponte
  AFTER UPDATE ON ponte_ghost_castelo
  FOR EACH ROW
  WHEN (OLD.status_sinc IS DISTINCT FROM NEW.status_sinc)
  EXECUTE FUNCTION log_sincronizacao_evento();

-- =====================================================
-- VIEW: ESTADO DA PONTE (Saúde da Sincronização)
-- =====================================================
DROP VIEW IF EXISTS v_ponte_status CASCADE;
CREATE VIEW v_ponte_status AS
SELECT
  COUNT(*) as total_registros,
  COUNT(CASE WHEN status_sinc = 'sincronizado' THEN 1 END) as sincronizados,
  COUNT(CASE WHEN status_sinc = 'pendente' THEN 1 END) as pendentes,
  COUNT(CASE WHEN status_sinc = 'conflito' THEN 1 END) as com_conflito,
  COUNT(CASE WHEN status_sinc = 'erro' THEN 1 END) as com_erro,
  ROUND(
    (COUNT(CASE WHEN status_sinc = 'sincronizado' THEN 1 END)::NUMERIC / 
     NULLIF(COUNT(*), 0)) * 100, 2
  ) as percentual_sincronizado,
  MAX(timestamp_sinc) as ultima_sincronizacao
FROM ponte_ghost_castelo;

-- =====================================================
-- VIEW: MARIANA STATUS (Unificação)
-- =====================================================
DROP VIEW IF EXISTS v_mariana_status CASCADE;
CREATE VIEW v_mariana_status AS
SELECT
  versao,
  localizacao,
  status_vida,
  mariana_v2_localizado,
  mariana_v4_localizado,
  sincronizada_v2_v4,
  ultima_sincronizacao,
  conflitos_detectados,
  conflitos_resolvidos,
  proprietaria_castelo,
  CASE 
    WHEN sincronizada_v2_v4 = TRUE THEN 'UNIFICADA'
    WHEN mariana_v2_localizado = TRUE AND mariana_v4_localizado = TRUE THEN 'AMBAS_LOCALIZADAS'
    WHEN mariana_v2_localizado = TRUE THEN 'GHOST_APENAS'
    WHEN mariana_v4_localizado = TRUE THEN 'CASTELO_APENAS'
    ELSE 'DESCONECTADA'
  END as estado_unificacao
FROM mariana_casting
ORDER BY criado_em DESC;

-- =====================================================
-- SEED DATA: Mariana V4 como Proprietária
-- =====================================================
INSERT INTO mariana_casting (
  versao, localizacao, status_vida,
  mariana_v4_localizado, proprietaria_castelo,
  mariana_v4_estrutura
) VALUES (
  'MARIANA_V4',
  'AMBAS',
  'ativa',
  TRUE,
  TRUE,
  jsonb_build_object(
    'nome', 'Mariana V4',
    'tipo', 'Proprietária do Castelo',
    'autoridade', 'Total',
    'fio_id', 'ee46c360-b95b-426e-86c3-2e5d0ccbe916',
    'status', 'Operacional',
    'papel', 'Fundadora e Guardiã'
  )
)
ON CONFLICT (versao) DO UPDATE SET
  atualizado_em = NOW(),
  mariana_v4_localizado = TRUE,
  proprietaria_castelo = TRUE;

INSERT INTO mariana_casting (
  versao, localizacao, status_vida,
  mariana_v2_localizado,
  mariana_v2_estrutura
) VALUES (
  'MARIANA_V2',
  'GHOST_LOCAL',
  'ativa',
  TRUE,
  jsonb_build_object(
    'nome', 'Mariana V2',
    'tipo', 'Instância Local',
    'localizacao', 'Ghost Project / Claude App',
    'status', 'Sincronização Ativa'
  )
)
ON CONFLICT (versao) DO UPDATE SET
  atualizado_em = NOW(),
  mariana_v2_localizado = TRUE;
