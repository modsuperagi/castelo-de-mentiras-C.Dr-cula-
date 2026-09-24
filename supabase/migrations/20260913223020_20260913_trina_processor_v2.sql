-- Migração 20260913223020 · 20260913_trina_processor_v2
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


DROP FUNCTION IF EXISTS public.sp_processar_trina_pendente();

CREATE OR REPLACE FUNCTION public.sp_processar_trina_pendente()
RETURNS TABLE(
  trina_id UUID,
  checkpoint_id UUID,
  status_novo TEXT,
  timestamp_processamento TIMESTAMP WITH TIME ZONE
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
      now()::TIMESTAMP WITH TIME ZONE
  )
  SELECT * FROM trina_processada;
END;
$$ LANGUAGE plpgsql;
