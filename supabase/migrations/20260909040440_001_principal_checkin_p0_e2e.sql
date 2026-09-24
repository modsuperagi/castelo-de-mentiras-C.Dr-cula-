-- Migração 20260909040440 · 001_principal_checkin_p0_e2e
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- ============================================================================
-- MIGRAÇÃO PRINCIPAL: CHECK-IN + P0 + E2E COMPLETO
-- Integração com Recepção existente + Sol + Sessions
-- ============================================================================

-- Tabela 1: CHECK-IN FORMALIZADO (Recepção aprimorada)
CREATE TABLE IF NOT EXISTS public.checkin_recepcion (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  -- Ligação com Porta Entrada
  porta_entrada_id UUID REFERENCES public.evo_porta_entrada(id),
  flow_id UUID UNIQUE,
  
  -- Identidade + Determinação (SONAR)
  identidade VARCHAR(255) NOT NULL,
  nuclei_origem VARCHAR(100),
  selo VARCHAR(255),
  determinacao TEXT,
  origem_sonar VARCHAR(100),
  
  -- Entrega RAW
  conteudo_raw TEXT NOT NULL,
  timestamp_raw TIMESTAMP,
  
  -- Contexto e Continuidade
  checkpoint_anterior UUID REFERENCES public.sessao_checkpoint(id),
  tipo_registro VARCHAR(50) CHECK (tipo_registro IN ('novo', 'continuacao', 'atualizacao', 'evidencia', 'confirmacao', 'contradicao', 'refinamento', 'conexao', 'missao', 'checkpoint', 'desconhecido')),
  
  -- P0 Ligação
  sessao_id UUID REFERENCES public.sessions(id),
  p0_pass BOOLEAN DEFAULT FALSE,
  
  -- Dedup
  dedupe_hash VARCHAR(255),
  
  -- Auditoria
  timestamp_checkin TIMESTAMP DEFAULT NOW(),
  status VARCHAR(50) DEFAULT 'checkin_recebido' 
    CHECK (status IN ('checkin_recebido', 'p0_processando', 'p0_pass', 'p0_fail', 'roteando', 'circulando', 'consolidado', 'arquivado'))
);

CREATE INDEX idx_checkin_flow ON public.checkin_recepcion(flow_id);
CREATE INDEX idx_checkin_porta ON public.checkin_recepcion(porta_entrada_id);
CREATE INDEX idx_checkin_p0 ON public.checkin_recepcion(p0_pass);
CREATE INDEX idx_checkin_sessao ON public.checkin_recepcion(sessao_id);
CREATE INDEX idx_checkin_dedup ON public.checkin_recepcion(dedupe_hash);

-- Tabela 2: P0 VALIDAÇÃO (7 Checks + Hard Block)
CREATE TABLE IF NOT EXISTS public.p0_validacao_completa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  sessao_id UUID NOT NULL REFERENCES public.sessions(id),
  checkin_id UUID REFERENCES public.checkin_recepcion(id),
  
  -- 7 Checks
  check_1_identidade BOOLEAN DEFAULT FALSE,
  check_2_autoridade BOOLEAN DEFAULT FALSE,
  check_3_propositum BOOLEAN DEFAULT FALSE,
  check_4_evidencia BOOLEAN DEFAULT FALSE,
  check_5_escopo BOOLEAN DEFAULT FALSE,
  check_6_rastreabilidade BOOLEAN DEFAULT FALSE,
  check_7_dedup BOOLEAN DEFAULT FALSE,
  
  p0_pass BOOLEAN GENERATED ALWAYS AS (
    check_1_identidade AND check_2_autoridade AND check_3_propositum 
    AND check_4_evidencia AND check_5_escopo AND check_6_rastreabilidade AND check_7_dedup
  ) STORED,
  
  resultado_detalhado JSONB DEFAULT '{}',
  timestamp_validacao TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT chk_fio_p0_principal CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

CREATE INDEX idx_p0_sessao ON public.p0_validacao_completa(sessao_id);
CREATE INDEX idx_p0_pass ON public.p0_validacao_completa(p0_pass);
CREATE INDEX idx_p0_checkin ON public.p0_validacao_completa(checkin_id);

-- Tabela 3: CORAÇÃO/MOTOR (Roteador inteligente)
CREATE TABLE IF NOT EXISTS public.coracao_motor_principal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  checkin_id UUID NOT NULL REFERENCES public.checkin_recepcion(id),
  flow_id UUID,
  
  destinos TEXT[] DEFAULT '{}',
  prioridade VARCHAR(50) DEFAULT 'normal' 
    CHECK (prioridade IN ('critica', 'alta', 'normal', 'baixa')),
  
  estado_circulacao VARCHAR(50) DEFAULT 'esperando_p0'
    CHECK (estado_circulacao IN ('esperando_p0', 'p0_aprovado', 'roteando', 'trina_processando', 'golden_validando', 'consolidando', 'completo', 'erro_bloqueado')),
  
  motivo_roteamento TEXT,
  linhagem_completa JSONB DEFAULT '{}',
  timestamp_circulacao TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT chk_fio_coracao CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

CREATE INDEX idx_coracao_checkin ON public.coracao_motor_principal(checkin_id);
CREATE INDEX idx_coracao_flow ON public.coracao_motor_principal(flow_id);
CREATE INDEX idx_coracao_estado ON public.coracao_motor_principal(estado_circulacao);

-- Tabela 4: TRINA CIRCULAÇÃO
CREATE TABLE IF NOT EXISTS public.trina_circulacao_principal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  coracao_id UUID NOT NULL REFERENCES public.coracao_motor_principal(id),
  flow_id UUID,
  
  trina_papel VARCHAR(50) CHECK (trina_papel IN ('ARQUITETO', 'ENGENHEIRO', 'VERIFICADOR', 'GOLDEN', 'SOL')),
  trina_resultado VARCHAR(50) CHECK (trina_resultado IN ('CONFIRMADO', 'PARCIAL', 'REJEITADO', 'PENDENTE')),
  
  escopo_provado TEXT,
  escopo_nao_provado TEXT,
  limites_explicitos TEXT,
  
  timestamp_trina TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT chk_fio_trina CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

CREATE INDEX idx_trina_coracao ON public.trina_circulacao_principal(coracao_id);
CREATE INDEX idx_trina_flow ON public.trina_circulacao_principal(flow_id);

-- Tabela 5: GOLDEN CIRCULAÇÃO (Imutável)
CREATE TABLE IF NOT EXISTS public.golden_circulacao_principal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  trina_id UUID REFERENCES public.trina_circulacao_principal(id),
  checkin_id UUID NOT NULL REFERENCES public.checkin_recepcion(id),
  flow_id UUID,
  
  tipo_registro VARCHAR(50) CHECK (tipo_registro IN ('observacao', 'hipotese', 'evidencia', 'validacao', 'consolidacao')),
  grau_validacao VARCHAR(50) CHECK (grau_validacao IN ('nao_validado', 'parcialmente_validado', 'validado', 'consolidado')),
  
  motivo_registro TEXT,
  timestamp_golden TIMESTAMP DEFAULT NOW(),
  
  CONSTRAINT chk_fio_golden CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

CREATE INDEX idx_golden_trina ON public.golden_circulacao_principal(trina_id);
CREATE INDEX idx_golden_checkin ON public.golden_circulacao_principal(checkin_id);
CREATE INDEX idx_golden_grau ON public.golden_circulacao_principal(grau_validacao);

-- Tabela 6: CONSOLIDAÇÃO (Integração final)
CREATE TABLE IF NOT EXISTS public.consolidacao_circulacao_principal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  golden_id UUID NOT NULL REFERENCES public.golden_circulacao_principal(id),
  flow_id UUID,
  
  conhecimento_entrada_id UUID REFERENCES public.meta_lab_entries(id),
  linhagem_completa JSONB DEFAULT '{}',
  
  timestamp_consolidacao TIMESTAMP DEFAULT NOW(),
  estado_final VARCHAR(50) DEFAULT 'consolidado',
  
  CONSTRAINT chk_fio_consolidacao CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

CREATE INDEX idx_consolidacao_golden ON public.consolidacao_circulacao_principal(golden_id);
CREATE INDEX idx_consolidacao_flow ON public.consolidacao_circulacao_principal(flow_id);

-- Tabela 7: AUDITORIA P0+SONAR (Log de bloqueios e autorizações)
CREATE TABLE IF NOT EXISTS public.auditoria_p0_sonar (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sessao_id UUID REFERENCES public.sessions(id),
  checkin_id UUID REFERENCES public.checkin_recepcion(id),
  flow_id UUID,
  
  evento VARCHAR(100),
  identidade VARCHAR(255),
  resultado VARCHAR(50),
  motivo TEXT,
  
  p0_checks JSONB DEFAULT '{}',
  timestamp_auditoria TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_auditoria_sessao ON public.auditoria_p0_sonar(sessao_id);
CREATE INDEX idx_auditoria_resultado ON public.auditoria_p0_sonar(resultado);
