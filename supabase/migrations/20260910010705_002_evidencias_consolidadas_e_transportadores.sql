-- Migração 20260910010705 · 002_evidencias_consolidadas_e_transportadores
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- ============================================================================
-- TABELA DE EVIDÊNCIAS CONSOLIDADAS
-- Repositório único de verdade para registros validados/consolidados
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.evidencias_consolidadas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  
  -- Rastreabilidade imutável
  flow_id UUID NOT NULL,
  checkin_id UUID NOT NULL REFERENCES public.checkin_recepcion(id),
  golden_id UUID REFERENCES public.golden_circulacao_principal(id),
  
  -- Checkpoint anterior (continuidade)
  checkpoint_anterior_id UUID REFERENCES public.sessao_checkpoint(id),
  
  -- Tipo de evidência
  tipo_evidencia VARCHAR(50) NOT NULL 
    CHECK (tipo_evidencia IN ('novo', 'continuacao', 'atualizacao', 'evidencia', 'confirmacao', 'contradicao', 'refinamento', 'conexao', 'missao')),
  
  -- Grau de consolidação (pipeline)
  grau_consolidacao VARCHAR(50) DEFAULT 'nao_validado'
    CHECK (grau_consolidacao IN ('nao_validado', 'parcialmente_validado', 'validado', 'consolidado')),
  
  -- Conteúdo
  conteudo_raw TEXT NOT NULL,
  conteudo_processado TEXT,
  
  -- Metadados
  identidade VARCHAR(255),
  nuclei_origem VARCHAR(100),
  tipo_conteudo VARCHAR(100),
  fonte VARCHAR(255),
  
  -- P0 aprovado
  p0_resultado JSONB DEFAULT '{}',
  p0_timestamp TIMESTAMP,
  
  -- TRINA validação
  trina_resultado VARCHAR(50),
  trina_escopo_provado TEXT,
  trina_timestamp TIMESTAMP,
  
  -- GOLDEN imutável
  golden_timestamp TIMESTAMP,
  
  -- Timestamps completos
  timestamp_entrada TIMESTAMP DEFAULT NOW(),
  timestamp_consolidacao TIMESTAMP,
  
  -- Status final
  status VARCHAR(50) DEFAULT 'em_processamento'
    CHECK (status IN ('em_processamento', 'parcial', 'validado', 'consolidado', 'arquivado')),
  
  CONSTRAINT chk_fio_evidencia CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid),
  CONSTRAINT chk_evidencia_flow_checkin CHECK (flow_id IS NOT NULL AND checkin_id IS NOT NULL)
);

CREATE INDEX idx_evidencia_flow ON public.evidencias_consolidadas(flow_id);
CREATE INDEX idx_evidencia_checkin ON public.evidencias_consolidadas(checkin_id);
CREATE INDEX idx_evidencia_golden ON public.evidencias_consolidadas(golden_id);
CREATE INDEX idx_evidencia_grau ON public.evidencias_consolidadas(grau_consolidacao);
CREATE INDEX idx_evidencia_status ON public.evidencias_consolidadas(status);
CREATE INDEX idx_evidencia_timestamp ON public.evidencias_consolidadas(timestamp_consolidacao);

-- ============================================================================
-- TRIGGER: Transportador P0 → CORAÇÃO (Quando P0 passa)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.transportar_p0_para_coracao()
RETURNS TRIGGER AS $$
BEGIN
  -- Só criar CORAÇÃO se P0 passou
  IF NEW.p0_pass = TRUE THEN
    INSERT INTO public.coracao_motor_principal (
      checkin_id, flow_id, destinos_identados, 
      motivo_roteamento, estado_circulacao
    ) SELECT
      NEW.checkin_id, 
      c.flow_id,
      ARRAY['trina', 'conhecimento', 'evidencia'],
      'Transportado automaticamente de P0',
      'p0_aprovado'
    FROM public.checkin_recepcion c
    WHERE c.id = NEW.checkin_id
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_p0_para_coracao ON public.p0_validacao_completa;
CREATE TRIGGER trg_p0_para_coracao
AFTER INSERT OR UPDATE ON public.p0_validacao_completa
FOR EACH ROW
EXECUTE FUNCTION public.transportar_p0_para_coracao();

-- ============================================================================
-- TRIGGER: Transportador CORAÇÃO → TRINA (Quando coração ativo)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.transportar_coracao_para_trina()
RETURNS TRIGGER AS $$
BEGIN
  -- Só criar TRINA se coração foi aprovado por P0
  IF NEW.estado_circulacao = 'p0_aprovado' THEN
    INSERT INTO public.trina_circulacao_principal (
      coracao_id, flow_id, trina_papel, trina_resultado,
      escopo_provado, escopo_nao_provado
    ) VALUES (
      NEW.id, NEW.flow_id, 'VERIFICADOR', 'PENDENTE',
      'Conteúdo presente e identidade validada por P0',
      'Hipóteses não testadas; aguardando processamento semântico'
    )
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_coracao_para_trina ON public.coracao_motor_principal;
CREATE TRIGGER trg_coracao_para_trina
AFTER INSERT OR UPDATE ON public.coracao_motor_principal
FOR EACH ROW
EXECUTE FUNCTION public.transportar_coracao_para_trina();

-- ============================================================================
-- TRIGGER: Transportador TRINA → GOLDEN (Quando TRINA confirma)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.transportar_trina_para_golden()
RETURNS TRIGGER AS $$
BEGIN
  -- Só criar GOLDEN se TRINA confirmou ou parcial
  IF NEW.trina_resultado IN ('CONFIRMADO', 'PARCIAL') THEN
    INSERT INTO public.golden_circulacao_principal (
      trina_id, checkin_id, flow_id,
      tipo_registro, grau_validacao, motivo_registro
    ) SELECT
      NEW.id,
      cm.checkin_id,
      NEW.flow_id,
      'evidencia',
      CASE WHEN NEW.trina_resultado = 'CONFIRMADO' THEN 'validado' ELSE 'parcialmente_validado' END,
      'Transportado automaticamente de TRINA: ' || NEW.trina_resultado
    FROM public.coracao_motor_principal cm
    WHERE cm.id = NEW.coracao_id
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_trina_para_golden ON public.trina_circulacao_principal;
CREATE TRIGGER trg_trina_para_golden
AFTER INSERT OR UPDATE ON public.trina_circulacao_principal
FOR EACH ROW
EXECUTE FUNCTION public.transportar_trina_para_golden();

-- ============================================================================
-- TRIGGER: Transportador GOLDEN → CONSOLIDAÇÃO + EVIDÊNCIAS
-- ============================================================================

CREATE OR REPLACE FUNCTION public.transportar_golden_para_consolidacao()
RETURNS TRIGGER AS $$
DECLARE
  v_consolidacao_id UUID;
BEGIN
  -- Criar CONSOLIDAÇÃO
  INSERT INTO public.consolidacao_circulacao_principal (
    golden_id, flow_id,
    linhagem_completa,
    estado_final
  ) VALUES (
    NEW.id,
    NEW.flow_id,
    jsonb_build_object(
      'golden_id', NEW.id,
      'flow_id', NEW.flow_id,
      'grau_validacao', NEW.grau_validacao,
      'timestamp_golden', NOW()
    ),
    'consolidado'
  ) RETURNING id INTO v_consolidacao_id;
  
  -- SIMULTANEAMENTE: Criar registro em EVIDÊNCIAS (repositório de verdade)
  INSERT INTO public.evidencias_consolidadas (
    flow_id, checkin_id, golden_id,
    tipo_evidencia, grau_consolidacao,
    conteudo_raw,
    p0_resultado,
    trina_resultado,
    golden_timestamp,
    timestamp_consolidacao,
    status
  ) SELECT
    NEW.flow_id,
    NEW.checkin_id,
    NEW.id,
    c.tipo_registro,
    NEW.grau_validacao::VARCHAR(50),
    c.conteudo_raw,
    p0.resultado_detalhado,
    tc.trina_resultado,
    NOW(),
    NOW(),
    'consolidado'
  FROM public.checkin_recepcion c
  LEFT JOIN public.p0_validacao_completa p0 ON c.p0_id = p0.id
  LEFT JOIN public.trina_circulacao_principal tc ON NEW.flow_id = tc.flow_id
  WHERE c.id = NEW.checkin_id
  ON CONFLICT DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_golden_para_consolidacao ON public.golden_circulacao_principal;
CREATE TRIGGER trg_golden_para_consolidacao
AFTER INSERT OR UPDATE ON public.golden_circulacao_principal
FOR EACH ROW
EXECUTE FUNCTION public.transportar_golden_para_consolidacao();
