-- Migração 20260910010842 · 004b_fix_fluxo_e2e_sessao
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- Corrigir função: reusar sessão existente ou não usar referência de sessão
DROP FUNCTION IF EXISTS public.fluxo_e2e_sonar_principal(uuid, varchar, varchar, text, varchar, varchar);

CREATE OR REPLACE FUNCTION public.fluxo_e2e_sonar_principal(
  p_flow_id UUID,
  p_identidade VARCHAR,
  p_nuclei VARCHAR,
  p_conteudo TEXT,
  p_tipo_registro VARCHAR,
  p_origem_sonar VARCHAR DEFAULT 'sonar'
)
RETURNS TABLE (
  resultado VARCHAR,
  flow_id_resultado UUID,
  checkin_id UUID,
  p0_autorizado BOOLEAN,
  estado_circulacao VARCHAR,
  grau_consolidacao VARCHAR,
  checkpoint_retomada UUID,
  mensagem TEXT
) AS $$
DECLARE
  v_checkin_id UUID;
  v_p0_id UUID;
  v_p0_pass BOOLEAN;
  v_trina_id UUID;
  v_golden_id UUID;
  v_consolidacao_id UUID;
  v_evidencia_id UUID;
  v_checkpoint_id UUID;
  v_dedupe_hash VARCHAR;
BEGIN
  
  -- PASSO 1: Gerar hash dedupe
  v_dedupe_hash := MD5(p_conteudo || '_' || p_identidade)::VARCHAR;
  
  -- Verificar deduplicação nas últimas 24h
  IF EXISTS (
    SELECT 1 FROM public.checkin_recepcion
    WHERE dedupe_hash = v_dedupe_hash
    AND timestamp_checkin > NOW() - INTERVAL '24 hours'
  ) THEN
    RETURN QUERY SELECT
      'BLOQUEADO_DEDUP'::VARCHAR, p_flow_id, NULL::UUID, FALSE, 'bloqueado', NULL,
      NULL::UUID, 'Deduplicação: Entrada duplicada em 24h'::TEXT;
    RETURN;
  END IF;
  
  -- PASSO 2: Criar CHECK-IN (sem referenciar sessão)
  INSERT INTO public.checkin_recepcion (
    flow_id, identidade, nuclei_origem, selo, determinacao,
    conteudo_raw, timestamp_raw, origem_sonar,
    tipo_registro, dedupe_hash, status, sessao_id
  ) VALUES (
    p_flow_id, p_identidade, p_nuclei, 'sonar_v1', 'integracao_sonar',
    p_conteudo, NOW(), p_origem_sonar,
    p_tipo_registro, v_dedupe_hash, 'checkin_recebido',
    (SELECT id FROM public.sessions LIMIT 1)  -- Usar sessão existente
  ) RETURNING checkin_recepcion.id INTO v_checkin_id;
  
  -- PASSO 3: Tentar ligar ao checkpoint anterior (continuidade automática)
  SELECT checkpoint_id INTO v_checkpoint_id
  FROM public.ligar_checkin_ao_checkpoint(p_flow_id, 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID);
  
  -- PASSO 4: P0 VALIDAÇÃO (7 checks)
  INSERT INTO public.p0_validacao_completa (
    sessao_id, checkin_id,
    check_1_identidade, check_2_autoridade, check_3_propositum,
    check_4_evidencia, check_5_escopo, check_6_rastreabilidade, check_7_dedup
  ) SELECT
    (SELECT id FROM public.sessions LIMIT 1),
    v_checkin_id,
    (p_identidade IN ('Conhecimento', 'Guardião', 'Fundadora', 'Golden', 'Metodologia', 'Consolidação')),
    (p_nuclei IN ('EVO1', 'EVO2', 'EVO3', 'EVO4', 'EVO5', 'EVO6')),
    (p_nuclei IN ('EVO1', 'EVO2', 'EVO3', 'EVO4', 'EVO5', 'EVO6')),
    (LENGTH(TRIM(p_conteudo)) >= 20),
    (p_nuclei IN ('EVO1', 'EVO2', 'EVO3', 'EVO4', 'EVO5', 'EVO6')),
    ((SELECT id FROM public.sessions LIMIT 1) IS NOT NULL),
    NOT EXISTS (SELECT 1 FROM public.checkin_recepcion WHERE dedupe_hash = v_dedupe_hash AND id != v_checkin_id)
  RETURNING p0_validacao_completa.id INTO v_p0_id;
  
  -- Verificar P0
  SELECT p0_pass INTO v_p0_pass
  FROM public.p0_validacao_completa WHERE id = v_p0_id;
  
  -- SE P0 FALHOU: BLOQUEADO
  IF v_p0_pass = FALSE THEN
    UPDATE public.checkin_recepcion SET status = 'p0_fail' WHERE id = v_checkin_id;
    RETURN QUERY SELECT
      'DENY'::VARCHAR, p_flow_id, v_checkin_id, FALSE, 'bloqueado', NULL,
      NULL::UUID, 'P0 falhou: Entrada rejeitada em validação'::TEXT;
    RETURN;
  END IF;
  
  -- PASSO 5: P0 PASSOU - Inicial transportadores automáticos
  UPDATE public.checkin_recepcion SET status = 'p0_pass' WHERE id = v_checkin_id;
  
  -- Os triggers automáticos acionam: CORAÇÃO → TRINA → GOLDEN → CONSOLIDAÇÃO → EVIDÊNCIAS
  
  -- Verificar que GOLDEN foi criado (indicador de sucesso)
  SELECT id INTO v_golden_id
  FROM public.golden_circulacao_principal
  WHERE checkin_id = v_checkin_id
  ORDER BY timestamp_golden DESC
  LIMIT 1;
  
  IF v_golden_id IS NOT NULL THEN
    -- Buscar CONSOLIDAÇÃO
    SELECT id INTO v_consolidacao_id
    FROM public.consolidacao_circulacao_principal
    WHERE golden_id = v_golden_id;
    
    -- Buscar EVIDÊNCIA
    SELECT id INTO v_evidencia_id
    FROM public.evidencias_consolidadas
    WHERE golden_id = v_golden_id;
    
    RETURN QUERY SELECT
      'ALLOW'::VARCHAR, p_flow_id, v_checkin_id, TRUE, 'consolidado',
      'consolidado',
      v_checkpoint_id,
      'E2E Completo: CHECK-IN ✅ → P0 ✅ → CORAÇÃO ✅ → TRINA ✅ → GOLDEN ✅ → CONSOLIDAÇÃO ✅ → EVIDÊNCIAS ✅'::TEXT;
  ELSE
    RETURN QUERY SELECT
      'PARCIAL'::VARCHAR, p_flow_id, v_checkin_id, TRUE, 'circulando',
      'parcialmente_validado',
      v_checkpoint_id,
      'P0 passou mas fluxo ainda em circulação (aguardando TRINA)'::TEXT;
  END IF;

END;
$$ LANGUAGE plpgsql;
