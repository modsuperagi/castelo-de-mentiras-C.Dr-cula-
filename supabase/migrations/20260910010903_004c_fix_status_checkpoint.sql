-- Migração 20260910010903 · 004c_fix_status_checkpoint
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- Corrigir função de ligação: não atualizar status invalid
DROP FUNCTION IF EXISTS public.ligar_checkin_ao_checkpoint(uuid, uuid);

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
  
  -- Buscar checkpoint ATIVO mais recente
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
    
    -- Ligar checkpoint ao novo CHECK-IN (sem atualizar status, apenas guardar referência)
    UPDATE public.checkin_recepcion
    SET checkpoint_anterior = v_checkpoint_id
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
