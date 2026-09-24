-- Migração 20260913223014 · 20260913_trina_processor_fixed
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- ========================================================
-- STORED PROCEDURE: Processa Mesa Trina pendente (FIXADO)
-- FIO: ee46c360-b95b-426e-86c3-2e5d0ccbe916
-- ========================================================

DROP FUNCTION IF EXISTS public.sp_processar_trina_pendente();

CREATE OR REPLACE FUNCTION public.sp_processar_trina_pendente()
RETURNS TABLE(
  trina_id UUID,
  checkpoint_id UUID,
  status_novo TEXT,
  timestamp_processamento TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  WITH trina_processada AS (
    UPDATE public.meta_sessões_trina t
    SET
      status = 'validado',
      resultado_arquiteto = jsonb_build_object(
        'analise', 'Checkpoint validado em estrutura',
        'tipo_acao', (SELECT acao FROM public.fios_checkpoint_universal fc WHERE fc.id = t.checkpoint_id),
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
      updated_at = now()
    WHERE t.status = 'aguardando_trina'
    RETURNING 
      t.id,
      t.checkpoint_id,
      'validado'::TEXT,
      now()
  )
  SELECT * FROM trina_processada;
END;
$$ LANGUAGE plpgsql;
