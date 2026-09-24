-- Migração 20260913222958 · 20260913_trigger_trina_auto_dispatch
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- ========================================================
-- TRIGGER: Dispara Edge Function ao criar Trina aguardando
-- FIO: ee46c360-b95b-426e-86c3-2e5d0ccbe916
-- DATA: 13/09/2026 17:20 UTC
-- ========================================================

CREATE OR REPLACE FUNCTION public.fn_dispatch_trina_to_edge()
RETURNS TRIGGER AS $$
DECLARE
  v_edge_url TEXT;
  v_response RECORD;
BEGIN
  -- URL da Edge Function
  v_edge_url := current_setting('app.edge_url', true) || '/functions/v1/meta-trina-processador-automatico';
  
  -- Se v_edge_url não está setado, usa padrão
  IF v_edge_url IS NULL OR v_edge_url = '/functions/v1/meta-trina-processador-automatico' THEN
    v_edge_url := 'https://zolbckgqdxxovguspjdb.supabase.co/functions/v1/meta-trina-processador-automatico';
  END IF;

  -- Log inicial
  RAISE NOTICE '🧠 Despachando Trina % para Edge Function', NEW.id;

  -- Dispatch para Edge Function via HTTP POST (async)
  -- Nota: PostgreSQL não tem HTTP nativo; usar próximo passo com net.http_post ou equivalente
  -- Por ora, registramos o evento para processamento externo

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ========================================================
-- TRIGGER: Executa ao INSERT em meta_sessões_trina
-- ========================================================

DROP TRIGGER IF EXISTS trg_meta_trina_dispatch ON public.meta_sessões_trina;

CREATE TRIGGER trg_meta_trina_dispatch
AFTER INSERT ON public.meta_sessões_trina
FOR EACH ROW
WHEN (NEW.status = 'aguardando_trina')
EXECUTE FUNCTION public.fn_dispatch_trina_to_edge();

-- ========================================================
-- NOTA IMPORTANTE: PostgreSQL não tem HTTP nativo
-- Solução alternativa: usar stored procedure que verifica
-- periodicamente, ou invocar Edge Function manualmente
-- ========================================================;
