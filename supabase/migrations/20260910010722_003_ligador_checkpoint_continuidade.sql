-- Migração 20260910010722 · 003_ligador_checkpoint_continuidade
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- ============================================================================
-- FUNÇÃO: Ligar novo CHECK-IN ao checkpoint anterior (continuidade automática)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.ligar_checkin_ao_checkpoint(
  p_flow_id UUID,
  p_fio_id UUID
)
RETURNS TABLE (
  checkpoint_encontrado BOOLEAN,
  checkpoint_id UUID,
  ponto_retomada TEXT,
  pergunta_aberta TEXT,
  fio_raciocinio TEXT,
  versao BIGINT,
  mensagem TEXT
) AS $$
DECLARE
  v_checkpoint_id UUID;
  v_ponto_retomada TEXT;
  v_pergunta_aberta TEXT;
  v_fio_raciocinio TEXT;
  v_versao BIGINT;
  v_ativo BOOLEAN;
BEGIN
  
  -- Buscar checkpoint ATIVO mais recente para este fio_id
  SELECT
    sc.id,
    sc.ponto_retomada,
    sc.pergunta_aberta,
    sc.fio_raciocinio,
    sc.versao,
    sc.ativo
  INTO
    v_checkpoint_id,
    v_ponto_retomada,
    v_pergunta_aberta,
    v_fio_raciocinio,
    v_versao,
    v_ativo
  FROM public.sessao_checkpoint sc
  WHERE sc.ativo = TRUE
  ORDER BY sc.atualizado_em DESC
  LIMIT 1;
  
  -- Se checkpoint encontrado e ativo
  IF v_checkpoint_id IS NOT NULL AND v_ativo = TRUE THEN
    
    -- Ligar checkpoint ao novo CHECK-IN
    UPDATE public.checkin_recepcion
    SET checkpoint_anterior = v_checkpoint_id,
        status = 'ligado_ao_checkpoint'
    WHERE flow_id = p_flow_id;
    
    RETURN QUERY SELECT
      TRUE,
      v_checkpoint_id,
      v_ponto_retomada,
      v_pergunta_aberta,
      v_fio_raciocinio,
      v_versao,
      'Continuidade preservada: Checkpoint anterior ligado ao novo fluxo'::TEXT;
  ELSE
    -- Nenhum checkpoint anterior ativo
    RETURN QUERY SELECT
      FALSE,
      NULL::UUID,
      NULL::TEXT,
      NULL::TEXT,
      NULL::TEXT,
      NULL::BIGINT,
      'Novo fluxo iniciado (sem checkpoint anterior ativo)'::TEXT;
  END IF;

END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGER: Automaticamente ligar CHECK-IN ao checkpoint ao ser criado
-- ============================================================================

CREATE OR REPLACE FUNCTION public.automaticamente_ligar_checkpoint()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM public.ligar_checkin_ao_checkpoint(NEW.flow_id, NEW.fio_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auto_ligacao_checkpoint ON public.checkin_recepcion;
CREATE TRIGGER trg_auto_ligacao_checkpoint
AFTER INSERT ON public.checkin_recepcion
FOR EACH ROW
EXECUTE FUNCTION public.automaticamente_ligar_checkpoint();

-- ============================================================================
-- FUNÇÃO: Salvar novo checkpoint (ao fim de ciclo/consolidação)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.salvar_checkpoint_consolidado(
  p_flow_id UUID,
  p_ponto_retomada TEXT,
  p_pergunta_aberta TEXT,
  p_fio_raciocinio TEXT
)
RETURNS TABLE (
  checkpoint_id UUID,
  versao BIGINT,
  ativo BOOLEAN,
  mensagem TEXT
) AS $$
DECLARE
  v_checkpoint_id UUID;
  v_versao BIGINT;
BEGIN
  
  -- Desativar checkpoint anterior
  UPDATE public.sessao_checkpoint
  SET ativo = FALSE
  WHERE ativo = TRUE;
  
  -- Criar novo checkpoint (versão incrementada)
  INSERT INTO public.sessao_checkpoint (
    flow_id,
    identidade,
    ponto_retomada,
    pergunta_aberta,
    fio_raciocinio,
    estado,
    versao,
    ativo,
    criado_em,
    atualizado_em
  ) VALUES (
    p_flow_id,
    jsonb_build_object('fio_id', 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'),
    p_ponto_retomada,
    p_pergunta_aberta,
    p_fio_raciocinio,
    jsonb_build_object(
      'timestamp', NOW(),
      'ciclo_consolidado', TRUE
    ),
    COALESCE((SELECT MAX(versao) FROM public.sessao_checkpoint), 0) + 1,
    TRUE,
    NOW(),
    NOW()
  ) RETURNING sessao_checkpoint.id, sessao_checkpoint.versao
  INTO v_checkpoint_id, v_versao;
  
  RETURN QUERY SELECT
    v_checkpoint_id,
    v_versao,
    TRUE,
    'Checkpoint consolidado e novo ciclo pronto'::TEXT;

END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNÇÃO: Buscar checkpoint (compatível com chamador externo = PEDIDO)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.buscar_checkpoint_ativo()
RETURNS TABLE (
  checkpoint_id UUID,
  flow_id UUID,
  ponto_retomada TEXT,
  pergunta_aberta TEXT,
  fio_raciocinio TEXT,
  versao BIGINT,
  identificacao JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    sc.id,
    sc.flow_id,
    sc.ponto_retomada,
    sc.pergunta_aberta,
    sc.fio_raciocinio,
    sc.versao,
    sc.identidade
  FROM public.sessao_checkpoint sc
  WHERE sc.ativo = TRUE
  ORDER BY sc.atualizado_em DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;
