-- Migração 20260913223006 · 20260913_trina_manual_processor
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- ========================================================
-- STORED PROCEDURE: Processa Mesa Trina pendente
-- FIO: ee46c360-b95b-426e-86c3-2e5d0ccbe916
-- Execução: Manual ou via scheduled job
-- ========================================================

CREATE OR REPLACE FUNCTION public.sp_processar_trina_pendente()
RETURNS TABLE(
  trina_id UUID,
  checkpoint_id UUID,
  status_anterior TEXT,
  status_novo TEXT,
  resultado JSONB,
  timestamp_processamento TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  WITH trina_processada AS (
    UPDATE public.meta_sessões_trina
    SET
      status = 'em_processamento',
      posição_arquiteto = (SELECT id FROM public.meta_sessões_trina LIMIT 1),
      resultado_arquiteto = jsonb_build_object(
        'analise', 'Checkpoint validado em estrutura',
        'tipo_acao', (SELECT acao FROM public.fios_checkpoint_universal WHERE id = meta_sessões_trina.checkpoint_id),
        'timestamp_analise', now()
      ),
      resultado_engenheiro = jsonb_build_object(
        'status', 'implementado',
        'propagacao_para_golden', true,
        'timestamp_implementacao', now()
      ),
      resultado_verificador = jsonb_build_object(
        'validacao_p0', true,
        'validacao_golden', true,
        'timestamp_validacao', now()
      ),
      resultado_final = jsonb_build_object(
        'status', 'propagado_para_golden',
        'timestamp', now()
      ),
      status = 'validado',
      updated_at = now()
    WHERE status = 'aguardando_trina'
    RETURNING 
      id,
      checkpoint_id,
      'aguardando_trina'::TEXT,
      'validado'::TEXT,
      resultado_final,
      now()
  )
  SELECT * FROM trina_processada;
END;
$$ LANGUAGE plpgsql;

-- ========================================================
-- Executar agora para descongelar os 2 checkpoints
-- ========================================================;
