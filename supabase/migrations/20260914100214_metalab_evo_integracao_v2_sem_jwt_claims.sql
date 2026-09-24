-- Migração 20260914100214 · metalab_evo_integracao_v2_sem_jwt_claims
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- =====================================================
-- METALAB EVO - INTEGRAÇÃO TOTAL SOL + CIRCULAÇÃO V2
-- =====================================================
-- Fio Raiz: ee46c360-b95b-426e-86c3-2e5d0ccbe916
-- Princípio: Clareza > Velocidade > Escala
-- 3 Validações Obrigatórias: Propósito | Evidência | Impacto
-- =====================================================

-- =====================================================
-- 1. TABELA: EVO_PRINCIPIOS (EVO 1 - Guardião)
-- =====================================================
CREATE TABLE IF NOT EXISTS evo_principios (
  id BIGSERIAL PRIMARY KEY,
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  principio VARCHAR(255) NOT NULL UNIQUE,
  descricao TEXT NOT NULL,
  validacao_1_proposito BOOLEAN DEFAULT FALSE,
  validacao_2_evidencia BOOLEAN DEFAULT FALSE,
  validacao_3_impacto BOOLEAN DEFAULT FALSE,
  ativo BOOLEAN DEFAULT TRUE,
  responsavel VARCHAR(150) NOT NULL,
  data_criacao TIMESTAMP DEFAULT NOW(),
  data_atualizacao TIMESTAMP,
  observacoes TEXT,
  hierarquia_prioridade INT DEFAULT 100,
  CONSTRAINT fio_raiz_fixo CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid),
  CONSTRAINT validacao_completa CHECK (
    (NOT ativo) OR 
    (validacao_1_proposito = TRUE AND validacao_2_evidencia = TRUE AND validacao_3_impacto = TRUE)
  )
);

CREATE INDEX idx_evo_principios_ativo ON evo_principios(ativo);
CREATE INDEX idx_evo_principios_fio ON evo_principios(fio_id);

ALTER TABLE evo_principios ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 2. TABELA: REGISTRO_DECISOES (EVO 4 - Golden, APPEND-ONLY)
-- =====================================================
CREATE TABLE IF NOT EXISTS registro_decisoes (
  id BIGSERIAL PRIMARY KEY,
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  decisao TEXT NOT NULL,
  motivo TEXT NOT NULL,
  mudanca_esperada TEXT,
  data_decisao TIMESTAMP DEFAULT NOW(),
  data_implementacao TIMESTAMP,
  responsavel VARCHAR(150) NOT NULL,
  nivel_acesso VARCHAR(20) DEFAULT 'estrutura' 
    CHECK (nivel_acesso IN ('nucleo', 'confianca', 'estrutura', 'publico')),
  link_externo TEXT,
  status VARCHAR(50) DEFAULT 'pendente' 
    CHECK (status IN ('pendente', 'em_progresso', 'concluido', 'cancelado')),
  relacionado_a_conhecimento UUID,
  relacionado_a_agente VARCHAR(150),
  versao_imutavel INT DEFAULT 1,
  hash_rastreamento VARCHAR(64),
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP,
  CONSTRAINT fio_raiz_fixo CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid),
  CONSTRAINT decisao_nao_vazia CHECK (LENGTH(TRIM(decisao)) > 0),
  CONSTRAINT motivo_nao_vazio CHECK (LENGTH(TRIM(motivo)) > 0)
);

CREATE INDEX idx_registro_decisoes_status ON registro_decisoes(status);
CREATE INDEX idx_registro_decisoes_data ON registro_decisoes(data_decisao);
CREATE INDEX idx_registro_decisoes_nivel ON registro_decisoes(nivel_acesso);
CREATE INDEX idx_registro_decisoes_fio ON registro_decisoes(fio_id);

ALTER TABLE registro_decisoes ENABLE ROW LEVEL SECURITY;

-- TRIGGER: BLOQUEIA UPDATE/DELETE (APPEND-ONLY)
CREATE OR REPLACE FUNCTION bloqueia_atualizacao_decisoes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' OR TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'Decisões são imutáveis. Não é permitido UPDATE ou DELETE. Crie nova decisão se necessário.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_decisoes_imutaveis ON registro_decisoes;
CREATE TRIGGER trg_decisoes_imutaveis
  BEFORE UPDATE OR DELETE ON registro_decisoes
  FOR EACH ROW
  EXECUTE FUNCTION bloqueia_atualizacao_decisoes();

-- =====================================================
-- 3. TABELA: FLUXO_CONHECIMENTO (EVO 3 - Conhecimento, Kanban)
-- =====================================================
CREATE TABLE IF NOT EXISTS fluxo_conhecimento (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  titulo VARCHAR(255) NOT NULL,
  origem VARCHAR(150) NOT NULL,
  data_entrada TIMESTAMP DEFAULT NOW(),
  camada VARCHAR(50) NOT NULL DEFAULT 'bruto'
    CHECK (camada IN ('bruto', 'refinado', 'transmissivel', 'ensino')),
  conteudo TEXT NOT NULL,
  conexoes UUID[],
  aprendizado_extraido TEXT,
  tags TEXT[],
  responsavel VARCHAR(150) NOT NULL,
  data_refino TIMESTAMP,
  data_transmissao TIMESTAMP,
  data_arquivamento TIMESTAMP,
  qualidade_score INT DEFAULT 0 CHECK (qualidade_score >= 0 AND qualidade_score <= 100),
  revisor VARCHAR(150),
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW(),
  CONSTRAINT fio_raiz_fixo CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid),
  CONSTRAINT titulo_nao_vazio CHECK (LENGTH(TRIM(titulo)) > 0),
  CONSTRAINT conteudo_nao_vazio CHECK (LENGTH(TRIM(conteudo)) > 0)
);

CREATE INDEX idx_fluxo_conhecimento_camada ON fluxo_conhecimento(camada);
CREATE INDEX idx_fluxo_conhecimento_data ON fluxo_conhecimento(data_entrada);
CREATE INDEX idx_fluxo_conhecimento_fio ON fluxo_conhecimento(fio_id);
CREATE INDEX idx_fluxo_conhecimento_origem ON fluxo_conhecimento(origem);

ALTER TABLE fluxo_conhecimento ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 4. TABELA: NOTAS (EVO 4 + EVO 6 - Consolidação de Evidências)
-- =====================================================
CREATE TABLE IF NOT EXISTS notas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  titulo VARCHAR(255) NOT NULL,
  corpo TEXT NOT NULL,
  categoria_evo VARCHAR(50) NOT NULL
    CHECK (categoria_evo IN ('EVO1', 'EVO2', 'EVO3', 'EVO4', 'EVO5', 'EVO6')),
  tags TEXT[],
  data_criacao TIMESTAMP DEFAULT NOW(),
  data_atualizacao TIMESTAMP,
  status VARCHAR(50) DEFAULT 'ativa'
    CHECK (status IN ('ativa', 'arquivada', 'cancelada')),
  relacionado_a_conhecimento UUID REFERENCES fluxo_conhecimento(id) ON DELETE SET NULL,
  relacionado_a_decisao BIGINT REFERENCES registro_decisoes(id) ON DELETE SET NULL,
  criador VARCHAR(150) NOT NULL,
  revisor VARCHAR(150),
  criado_em TIMESTAMP DEFAULT NOW(),
  CONSTRAINT fio_raiz_fixo CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid),
  CONSTRAINT titulo_nao_vazio CHECK (LENGTH(TRIM(titulo)) > 0),
  CONSTRAINT corpo_nao_vazio CHECK (LENGTH(TRIM(corpo)) > 0)
);

CREATE INDEX idx_notas_categoria ON notas(categoria_evo);
CREATE INDEX idx_notas_status ON notas(status);
CREATE INDEX idx_notas_fio ON notas(fio_id);

ALTER TABLE notas ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 5. TABELA: EVO_AGENTES (EVO 2 - Fundadora, Delegação)
-- =====================================================
CREATE TABLE IF NOT EXISTS evo_agentes (
  id BIGSERIAL PRIMARY KEY,
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  nome VARCHAR(150) NOT NULL UNIQUE,
  camada_evo VARCHAR(10) NOT NULL
    CHECK (camada_evo IN ('EVO1', 'EVO2', 'EVO3', 'EVO4', 'EVO5', 'EVO6')),
  funcao TEXT NOT NULL,
  descricao TEXT,
  status_ativo BOOLEAN DEFAULT TRUE,
  comandos_permitidos TEXT[],
  nivel_acesso VARCHAR(50) DEFAULT 'estrutura',
  ultima_acao TIMESTAMP,
  dados_ultima_acao JSONB DEFAULT '{}',
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP,
  verificado_por_guardiao BOOLEAN DEFAULT FALSE,
  CONSTRAINT fio_raiz_fixo CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid),
  CONSTRAINT nome_nao_vazio CHECK (LENGTH(TRIM(nome)) > 0),
  CONSTRAINT funcao_nao_vazia CHECK (LENGTH(TRIM(funcao)) > 0)
);

CREATE INDEX idx_evo_agentes_nome ON evo_agentes(nome);
CREATE INDEX idx_evo_agentes_camada ON evo_agentes(camada_evo);
CREATE INDEX idx_evo_agentes_status ON evo_agentes(status_ativo);
CREATE INDEX idx_evo_agentes_fio ON evo_agentes(fio_id);

ALTER TABLE evo_agentes ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 6. TABELA: REGISTRO_EVOLUCOES (EVO 5 - Metodologia, Versionamento)
-- =====================================================
CREATE TABLE IF NOT EXISTS registro_evolucoes (
  id BIGSERIAL PRIMARY KEY,
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  versao VARCHAR(50) NOT NULL,
  mudanca TEXT NOT NULL,
  data_versao TIMESTAMP DEFAULT NOW(),
  responsavel VARCHAR(150) NOT NULL,
  impacto_estimado TEXT,
  impacto_real TEXT,
  validado_por_guardiao BOOLEAN DEFAULT FALSE,
  relacionado_a_decisao BIGINT REFERENCES registro_decisoes(id) ON DELETE SET NULL,
  relacionado_a_agente VARCHAR(150),
  tags TEXT[],
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP,
  CONSTRAINT fio_raiz_fixo CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid),
  CONSTRAINT versao_nao_vazia CHECK (LENGTH(TRIM(versao)) > 0),
  CONSTRAINT mudanca_nao_vazia CHECK (LENGTH(TRIM(mudanca)) > 0),
  CONSTRAINT versao_unica_responsavel UNIQUE (versao, responsavel)
);

CREATE INDEX idx_registro_evolucoes_versao ON registro_evolucoes(versao);
CREATE INDEX idx_registro_evolucoes_data ON registro_evolucoes(data_versao);
CREATE INDEX idx_registro_evolucoes_validado ON registro_evolucoes(validado_por_guardiao);
CREATE INDEX idx_registro_evolucoes_fio ON registro_evolucoes(fio_id);

ALTER TABLE registro_evolucoes ENABLE ROW LEVEL SECURITY;

-- TRIGGER: BLOQUEIA DELETE (append-only)
CREATE OR REPLACE FUNCTION bloqueia_delecao_evolucoes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'Histórico de evoluções é imutável. Não é permitido DELETE.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_evolucoes_imutaveis ON registro_evolucoes;
CREATE TRIGGER trg_evolucoes_imutaveis
  BEFORE DELETE ON registro_evolucoes
  FOR EACH ROW
  EXECUTE FUNCTION bloqueia_delecao_evolucoes();

-- =====================================================
-- 7. TABELA: ACESSOS_CANAIS (Núcleo - Restrito)
-- =====================================================
CREATE TABLE IF NOT EXISTS acessos_canais (
  id BIGSERIAL PRIMARY KEY,
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  canal VARCHAR(150) NOT NULL UNIQUE,
  descricao TEXT,
  nivel_acesso VARCHAR(50) NOT NULL
    CHECK (nivel_acesso IN ('publico', 'estrutura', 'confianca', 'nucleo')),
  link TEXT,
  responsavel VARCHAR(150) NOT NULL,
  data_criacao TIMESTAMP DEFAULT NOW(),
  data_atualizacao TIMESTAMP,
  ativo BOOLEAN DEFAULT TRUE,
  auditado_por_guardiao BOOLEAN DEFAULT FALSE,
  criado_em TIMESTAMP DEFAULT NOW(),
  CONSTRAINT fio_raiz_fixo CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

CREATE INDEX idx_acessos_canais_nivel ON acessos_canais(nivel_acesso);
CREATE INDEX idx_acessos_canais_ativo ON acessos_canais(ativo);
CREATE INDEX idx_acessos_canais_fio ON acessos_canais(fio_id);

ALTER TABLE acessos_canais ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- INTEGRAÇÃO SOL: Adicionar FK a sol_missions/tasks/runs
-- =====================================================

ALTER TABLE sol_missions ADD COLUMN IF NOT EXISTS
  fio_id UUID DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid;

ALTER TABLE sol_missions ADD COLUMN IF NOT EXISTS
  relacionado_a_conhecimento UUID REFERENCES fluxo_conhecimento(id) ON DELETE SET NULL;

ALTER TABLE sol_missions ADD COLUMN IF NOT EXISTS
  relacionado_a_decisao BIGINT REFERENCES registro_decisoes(id) ON DELETE SET NULL;

ALTER TABLE sol_missions ADD COLUMN IF NOT EXISTS
  validacao_proposito BOOLEAN DEFAULT FALSE;

ALTER TABLE sol_missions ADD COLUMN IF NOT EXISTS
  validacao_evidencia BOOLEAN DEFAULT FALSE;

ALTER TABLE sol_missions ADD COLUMN IF NOT EXISTS
  validacao_impacto BOOLEAN DEFAULT FALSE;

ALTER TABLE sol_missions ADD CONSTRAINT sol_missions_fio_raiz 
  CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid);

-- Adicionar coluna de rastreamento a sol_tasks
ALTER TABLE sol_tasks ADD COLUMN IF NOT EXISTS
  fio_id UUID DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid;

ALTER TABLE sol_tasks ADD COLUMN IF NOT EXISTS
  validacao_proposito BOOLEAN DEFAULT FALSE;

ALTER TABLE sol_tasks ADD COLUMN IF NOT EXISTS
  validacao_evidencia BOOLEAN DEFAULT FALSE;

ALTER TABLE sol_tasks ADD COLUMN IF NOT EXISTS
  validacao_impacto BOOLEAN DEFAULT FALSE;

ALTER TABLE sol_tasks ADD CONSTRAINT sol_tasks_fio_raiz 
  CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid);

-- Adicionar coluna de rastreamento a sol_runs
ALTER TABLE sol_runs ADD COLUMN IF NOT EXISTS
  fio_id UUID DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid;

ALTER TABLE sol_runs ADD CONSTRAINT sol_runs_fio_raiz 
  CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid);

-- =====================================================
-- TRIGGER: CIRCULAÇÃO AUTOMÁTICA SOL → CHECKPOINT
-- =====================================================

CREATE OR REPLACE FUNCTION trg_sol_mission_completa_checkpoint()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    -- Registra mudança em fios_checkpoint_universal
    INSERT INTO fios_checkpoint_universal (
      fio_id, acao, tabela_origem, registro_id, responsavel,
      mantém_propósito, existe_evidência, qual_impacto, status
    ) VALUES (
      'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
      'INSERT',
      'sol_missions',
      NEW.id,
      'SOL_MOTOR',
      NEW.validacao_proposito,
      NEW.validacao_evidencia,
      CASE WHEN NEW.validacao_impacto THEN 'SOL Mission Concluída' ELSE NULL END,
      'validado'
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sol_missions_checkpoint ON sol_missions;
CREATE TRIGGER trg_sol_missions_checkpoint
  AFTER UPDATE ON sol_missions
  FOR EACH ROW
  EXECUTE FUNCTION trg_sol_mission_completa_checkpoint();

-- =====================================================
-- TRIGGER: VALIDAÇÕES OBRIGATÓRIAS (3 PILARES)
-- =====================================================

CREATE OR REPLACE FUNCTION validar_3_pilares_fluxo()
RETURNS TRIGGER AS $$
BEGIN
  -- Validação 1: Propósito (alinhado com princípios ativos)
  IF NOT EXISTS (
    SELECT 1 FROM evo_principios WHERE ativo = TRUE LIMIT 1
  ) THEN
    RAISE EXCEPTION 'Nenhum princípio ativo. Defina princípios antes de adicionar conhecimento.';
  END IF;

  -- Validação 2: Evidência (origem deve ser registrada)
  IF TRIM(NEW.origem) = '' THEN
    RAISE EXCEPTION 'Campo origem é obrigatório para rastreabilidade.';
  END IF;

  -- Validação 3: Impacto (camada deve estar definida)
  IF NEW.camada NOT IN ('bruto', 'refinado', 'transmissivel', 'ensino') THEN
    RAISE EXCEPTION 'Camada deve estar entre: bruto, refinado, transmissivel, ensino.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_3_pilares_entrada ON fluxo_conhecimento;
CREATE TRIGGER trg_validar_3_pilares_entrada
  BEFORE INSERT ON fluxo_conhecimento
  FOR EACH ROW
  EXECUTE FUNCTION validar_3_pilares_fluxo();

-- =====================================================
-- 5 VIEWS DE DASHBOARD
-- =====================================================

DROP VIEW IF EXISTS v_metalab_panorama CASCADE;
CREATE VIEW v_metalab_panorama AS
SELECT
  (SELECT COUNT(*) FROM evo_principios WHERE ativo = TRUE) as principios_ativos,
  (SELECT COUNT(*) FROM registro_decisoes WHERE status = 'pendente') as decisoes_pendentes,
  (SELECT COUNT(*) FROM registro_decisoes WHERE status = 'concluido') as decisoes_concluidas,
  (SELECT COUNT(*) FROM fluxo_conhecimento WHERE camada = 'bruto') as conhecimentos_brutos,
  (SELECT COUNT(*) FROM fluxo_conhecimento WHERE camada = 'refinado') as conhecimentos_refinados,
  (SELECT COUNT(*) FROM fluxo_conhecimento WHERE camada = 'transmissivel') as conhecimentos_transmissiveis,
  (SELECT COUNT(*) FROM fluxo_conhecimento WHERE camada = 'ensino') as conhecimentos_ensino,
  (SELECT COUNT(*) FROM evo_agentes WHERE status_ativo = TRUE) as agentes_ativos,
  (SELECT COUNT(*) FROM registro_evolucoes WHERE validado_por_guardiao = TRUE) as evolucoes_validadas,
  (SELECT COUNT(*) FROM notas WHERE status = 'ativa') as notas_ativas,
  (SELECT COUNT(*) FROM sol_missions WHERE status IN ('queued', 'running')) as sol_missoes_ativas;

DROP VIEW IF EXISTS v_fluxo_kanban CASCADE;
CREATE VIEW v_fluxo_kanban AS
SELECT
  camada,
  COUNT(*) as quantidade,
  AVG(qualidade_score) as qualidade_media,
  MAX(atualizado_em) as ultima_atualizacao
FROM fluxo_conhecimento
GROUP BY camada
ORDER BY CASE
  WHEN camada = 'bruto' THEN 1
  WHEN camada = 'refinado' THEN 2
  WHEN camada = 'transmissivel' THEN 3
  WHEN camada = 'ensino' THEN 4
END;

DROP VIEW IF EXISTS v_decisoes_por_pilar CASCADE;
CREATE VIEW v_decisoes_por_pilar AS
SELECT
  COUNT(*) as total_decisoes,
  status,
  nivel_acesso,
  DATE_TRUNC('day', data_decisao) as data,
  responsavel
FROM registro_decisoes
GROUP BY status, nivel_acesso, DATE_TRUNC('day', data_decisao), responsavel
ORDER BY data DESC;

DROP VIEW IF EXISTS v_evolucoes_recentes CASCADE;
CREATE VIEW v_evolucoes_recentes AS
SELECT
  versao,
  mudanca,
  responsavel,
  data_versao,
  validado_por_guardiao,
  impacto_estimado,
  CASE WHEN validado_por_guardiao THEN 'Validado' ELSE 'Pendente' END as status_validacao
FROM registro_evolucoes
ORDER BY data_versao DESC
LIMIT 10;

DROP VIEW IF EXISTS v_agentes_atividade CASCADE;
CREATE VIEW v_agentes_atividade AS
SELECT
  nome,
  camada_evo,
  status_ativo,
  ultima_acao,
  funcao,
  nivel_acesso,
  CASE WHEN ultima_acao > NOW() - INTERVAL '1 hour' THEN 'Ativo agora'
       WHEN ultima_acao > NOW() - INTERVAL '1 day' THEN 'Ativo hoje'
       ELSE 'Inativo' END as status_tempo
FROM evo_agentes
WHERE status_ativo = TRUE
ORDER BY ultima_acao DESC;

-- =====================================================
-- SEED DATA INICIAL
-- =====================================================

INSERT INTO evo_principios (
  principio, descricao, validacao_1_proposito, validacao_2_evidencia, 
  validacao_3_impacto, ativo, responsavel, hierarquia_prioridade
) VALUES
  (
    'Clareza > Velocidade > Escala',
    'O sistema prioriza clareza sobre velocidade, e velocidade sobre escala. Toda decisão segue essa hierarquia.',
    TRUE, TRUE, TRUE, TRUE,
    'Guardiao_EVO1',
    1
  ),
  (
    'Fio Universal ee46c360-b95b-426e-86c3-2e5d0ccbe916',
    'O Fio Raiz une todas as operações. Nenhuma ação escapa deste binding.',
    TRUE, TRUE, TRUE, TRUE,
    'Guardiao_EVO1',
    2
  ),
  (
    'Se um vive todos vivem',
    'Arquitetura de solidariedade entre componentes. O fracasso de um ativa proteção sistêmica.',
    TRUE, TRUE, TRUE, TRUE,
    'Guardiao_EVO1',
    3
  )
ON CONFLICT (principio) DO NOTHING;

INSERT INTO evo_agentes (
  nome, camada_evo, funcao, descricao, status_ativo,
  comandos_permitidos, nivel_acesso, verificado_por_guardiao
) VALUES
  (
    'FOWLER_ARQUITETO',
    'EVO3',
    'Arquitetura e Encaixe',
    'Valida estrutura, FKs, relacionamentos',
    TRUE,
    ARRAY['DESENHAR', 'VALIDAR_ESTRUTURA'],
    'estrutura',
    TRUE
  ),
  (
    'KNUTH_ENGENHEIRO',
    'EVO3',
    'Ligação Física e Integridade',
    'Implementa triggers, índices, performance',
    TRUE,
    ARRAY['IMPLEMENTAR', 'OTIMIZAR'],
    'estrutura',
    TRUE
  ),
  (
    'LECUN_VERIFICADOR',
    'EVO3',
    'Fluxo Vivo e Automação',
    'Monitora circulação, Edge Functions',
    TRUE,
    ARRAY['MONITORAR', 'OTIMIZAR_FLUXO'],
    'estrutura',
    TRUE
  ),
  (
    'SOL_MOTOR',
    'EVO3',
    'Motor Autônomo de Circulação',
    'Executa missões, gerencia tarefas, retorna resultados',
    TRUE,
    ARRAY['EXECUTAR_MISSOES', 'GERENCIAR_TAREFAS'],
    'estrutura',
    TRUE
  ),
  (
    'PLASMA_VALIDADOR',
    'EVO1',
    'Validação P0 e Conformidade',
    'Claude: valida P0, migrações, conformidade',
    TRUE,
    ARRAY['VALIDAR_P0', 'VALIDAR_MIGRACOES'],
    'nucleo',
    TRUE
  )
ON CONFLICT (nome) DO NOTHING;
