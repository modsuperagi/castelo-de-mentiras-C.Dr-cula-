-- Migração 20260911052623 · 001b_activate_rls_safe
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- ========================================
-- ATIVAÇÃO DE RLS - PROTEÇÃO DO ORGANISMO
-- ========================================

-- 1. ATIVAR RLS NAS 8 TABELAS CRÍTICAS
DO $$
BEGIN
  EXECUTE 'ALTER TABLE IF EXISTS public.checkin_recepcion ENABLE ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE IF EXISTS public.p0_validacao_completa ENABLE ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE IF EXISTS public.coracao_motor_principal ENABLE ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE IF EXISTS public.trina_circulacao_principal ENABLE ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE IF EXISTS public.golden_circulacao_principal ENABLE ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE IF EXISTS public.consolidacao_circulacao_principal ENABLE ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE IF EXISTS public.auditoria_p0_sonar ENABLE ROW LEVEL SECURITY';
  EXECUTE 'ALTER TABLE IF EXISTS public.evidencias_consolidadas ENABLE ROW LEVEL SECURITY';
  RAISE NOTICE 'RLS activated on all 8 critical tables';
END $$;

-- 2. Trigger para GOLDEN IMMUTABILITY
DROP TRIGGER IF EXISTS golden_immutable_update ON public.golden_circulacao_principal;
DROP TRIGGER IF EXISTS golden_immutable_delete ON public.golden_circulacao_principal;
DROP FUNCTION IF EXISTS block_golden_mutation();

CREATE OR REPLACE FUNCTION block_golden_mutation()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'GOLDEN RECORDS ARE IMMUTABLE: Cannot modify. Once registered, the decision cannot be changed.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER golden_immutable_update BEFORE UPDATE ON public.golden_circulacao_principal
FOR EACH ROW EXECUTE FUNCTION block_golden_mutation();

CREATE TRIGGER golden_immutable_delete BEFORE DELETE ON public.golden_circulacao_principal
FOR EACH ROW EXECUTE FUNCTION block_golden_mutation();
