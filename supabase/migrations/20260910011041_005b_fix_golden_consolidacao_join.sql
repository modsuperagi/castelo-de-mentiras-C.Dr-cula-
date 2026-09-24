-- Migração 20260910011041 · 005b_fix_golden_consolidacao_join
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- Corrigir trigger GOLDEN → CONSOLIDAÇÃO
DROP TRIGGER IF EXISTS trg_golden_para_consolidacao ON public.golden_circulacao_principal;
DROP FUNCTION IF EXISTS public.transportar_golden_para_consolidacao();

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
  
  -- Criar EVIDÊNCIA (repositório de verdade)
  INSERT INTO public.evidencias_consolidadas (
    flow_id, checkin_id, golden_id,
    tipo_evidencia, grau_consolidacao,
    conteudo_raw,
    golden_timestamp,
    timestamp_consolidacao,
    status
  ) SELECT
    NEW.flow_id,
    NEW.checkin_id,
    NEW.id,
    c.tipo_registro::VARCHAR(50),
    NEW.grau_validacao::VARCHAR(50),
    c.conteudo_raw,
    NOW(),
    NOW(),
    'consolidado'
  FROM public.checkin_recepcion c
  WHERE c.id = NEW.checkin_id
  ON CONFLICT DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_golden_para_consolidacao
AFTER INSERT OR UPDATE ON public.golden_circulacao_principal
FOR EACH ROW
EXECUTE FUNCTION public.transportar_golden_para_consolidacao();

-- Verificar estado agora
SELECT 'STATUS APÓS CORREÇÃO' AS acao;

SELECT 
  (SELECT COUNT(*) FROM public.trina_circulacao_principal) as trinas,
  (SELECT COUNT(*) FROM public.golden_circulacao_principal) as goldens,
  (SELECT COUNT(*) FROM public.consolidacao_circulacao_principal) as consolidacoes,
  (SELECT COUNT(*) FROM public.evidencias_consolidadas) as evidencias;
