-- Migração 20260913224131 · 20260913_solucao_c_trina_gera_coacao
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- ========================================================
-- SOLUÇÃO C: Meta Trina Validada Gera Coração Automaticamente
-- FIO: ee46c360-b95b-426e-86c3-2e5d0ccbe916
-- R1 COMPLIANCE: Idempotência + Origem Rastreada + Log Imutável
-- ========================================================

CREATE OR REPLACE FUNCTION public.fn_trina_cria_coacao_seguro()
RETURNS TRIGGER AS $$
DECLARE
  v_checkpoint_id UUID;
  v_coacao_existente UUID;
  v_checkin_id UUID;
  v_flow_id UUID;
BEGIN
  -- Segurança 1: Apenas quando status transita para 'validado'
  IF NEW.status <> 'validado' OR OLD.status = 'validado' THEN
    RETURN NEW;
  END IF;

  -- Segurança 2: Buscar Checkpoint associado
  v_checkpoint_id := NEW.checkpoint_id;
  IF v_checkpoint_id IS NULL THEN
    RAISE WARNING 'fn_trina_cria_coacao_seguro: checkpoint_id nulo para Trina %', NEW.id;
    RETURN NEW;
  END IF;

  -- Segurança 3: Buscar Checkin vinculado ao Checkpoint (via trace)
  SELECT checkin_id INTO v_checkin_id
  FROM public.checkin_recepcion
  WHERE id = (
    SELECT registro_id FROM public.fios_checkpoint_universal 
    WHERE id = v_checkpoint_id AND tabela_origem = 'checkin_recepcion'
  )
  LIMIT 1;

  -- Se não encontrou via checkin_recepcion, busca direto
  IF v_checkin_id IS NULL THEN
    SELECT fc.registro_id INTO v_checkin_id
    FROM public.fios_checkpoint_universal fc
    WHERE fc.id = v_checkpoint_id
    LIMIT 1;
  END IF;

  -- Segurança 4: IDEMPOTÊNCIA — verifica se Coração já existe
  SELECT id INTO v_coacao_existente
  FROM public.coracao_motor_principal
  WHERE 
    (checkin_id = v_checkin_id OR checkin_id = NEW.checkpoint_id)
    AND estado_circulacao IN ('esperando_p0', 'p0_aprovado', 'roteando', 'trina_processando')
  LIMIT 1;

  IF v_coacao_existente IS NOT NULL THEN
    RAISE NOTICE '✅ Coração % já existe para Trina % — idempotência mantida', 
      v_coacao_existente, NEW.id;
    RETURN NEW;
  END IF;

  -- Segurança 5: ORIGEM — Criar Coração com rastreamento completo
  INSERT INTO public.coracao_motor_principal (
    fio_id,
    checkin_id,
    checkpoint_id,  -- NOVO CAMPO: vincula ao Checkpoint
    flow_id,
    destinos,
    prioridade,
    estado_circulacao,
    motivo_roteamento,
    linhagem_completa,
    timestamp_circulacao
  )
  VALUES (
    'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID,
    v_checkin_id,
    v_checkpoint_id,  -- RASTREAMENTO: Checkpoint que originou
    NEW.id,  -- Flow_id aponta para Trina validada
    ARRAY['trina_circulacao_principal'::TEXT],
    'normal'::VARCHAR,
    'trina_processando'::VARCHAR,
    'Auto-gerado por Trina validada (Solução C)',
    jsonb_build_object(
      'origem_trina', NEW.id,
      'checkpoint', v_checkpoint_id,
      'timestamp_criacao', now(),
      'rastreamento_completo', true
    ),
    now()
  );

  RAISE NOTICE '🧬 Coração auto-gerado para Trina % vinculado ao Checkpoint %', 
    NEW.id, v_checkpoint_id;

  -- Segurança 6: LOG IMUTÁVEL em eventos_fio
  INSERT INTO public.fios_checkpoint_universal (
    fio_id,
    acao,
    tabela_origem,
    registro_id,
    agente_id,
    responsavel,
    mantém_propósito,
    existe_evidência,
    qual_impacto,
    status,
    resultado
  )
  VALUES (
    'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID,
    'PROPAGATION'::TEXT,
    'meta_sessões_trina',
    NEW.id,
    NULL,
    'Solução C: Trina → Coração',
    true,
    true,
    'Unificação de fluxo Checkpoint ↔ Trina ↔ Coração',
    'validado',
    jsonb_build_object(
      'trina_id', NEW.id,
      'coacao_criado', true,
      'checkpoint_id', v_checkpoint_id,
      'timestamp', now()
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ========================================================
-- TRIGGER: Dispara ao UPDATE de Trina para status='validado'
-- ========================================================

DROP TRIGGER IF EXISTS trg_trina_cria_coacao ON public.meta_sessões_trina;

CREATE TRIGGER trg_trina_cria_coacao
AFTER UPDATE ON public.meta_sessões_trina
FOR EACH ROW
EXECUTE FUNCTION public.fn_trina_cria_coacao_seguro();

-- ========================================================
-- NOTA: Coluna checkpoint_id deve existir em coracao_motor_principal
-- Se não existir, a migration anterior deve tê-la criado
-- ========================================================;
