-- Migração 20260913223044 · 20260913_trina_circulacao_trigger
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- ========================================================
-- TRIGGER: Trina validada → Circulação Trina → Golden
-- FIO: ee46c360-b95b-426e-86c3-2e5d0ccbe916
-- ========================================================

CREATE OR REPLACE FUNCTION public.fn_trina_para_circulacao()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'validado' AND OLD.status <> 'validado' THEN
    -- Insere em trina_circulacao_principal para propagação a Golden
    INSERT INTO public.trina_circulacao_principal (
      fio_id, checkpoint_id, flow_id, trina_papel, trina_resultado,
      escopo_provado, escopo_nao_provado, limites_explicitos, timestamp_trina
    )
    VALUES (
      'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID,
      NEW.checkpoint_id,
      NULL,
      'VERIFICADOR',
      'CONFIRMADO',
      'Passagem completa pelos 3 pólos da Mesa Trina',
      NULL,
      'Nenhum',
      now()
    );

    RAISE NOTICE '✅ Trina % propagada para circulação (Golden)', NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ========================================================
DROP TRIGGER IF EXISTS trg_meta_trina_para_circulacao ON public.meta_sessões_trina;

CREATE TRIGGER trg_meta_trina_para_circulacao
AFTER UPDATE ON public.meta_sessões_trina
FOR EACH ROW
EXECUTE FUNCTION public.fn_trina_para_circulacao();
