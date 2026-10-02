-- Só a entrada de um check-in chama a Mesa; mudar o status dele (arquivar, consolidar) não abre sessão nova.
CREATE OR REPLACE FUNCTION public.checkpoint_dispara_trina() RETURNS trigger LANGUAGE plpgsql SET search_path TO 'public' AS $f$
DECLARE v_p0_pass boolean; v_allow boolean := false; v_tipo text := 'CHECKPOINT_AUTOMÁTICO'; v_missao boolean := false;
BEGIN
  IF NEW.tabela_origem = 'checkin_recepcion' AND NEW.acao = 'INSERT' THEN
    SELECT c.p0_pass INTO v_p0_pass FROM public.checkin_recepcion c WHERE c.id = NEW.registro_id LIMIT 1;
    v_allow := COALESCE(v_p0_pass, false);
  ELSIF NEW.tabela_origem IN ('sol_missions', 'sol_tasks') THEN
    v_allow := true;
  ELSIF NEW.tabela_origem = 'meta_lab_entries' AND NEW.acao = 'INSERT'
        AND EXISTS (SELECT 1 FROM public.meta_lab_entries e WHERE e.id = NEW.registro_id AND e.colecao = 'MISSOES_TRINA') THEN
    v_allow := true; v_tipo := 'VALIDAÇÃO_MANUAL'; v_missao := true;
  END IF;
  IF NOT v_allow THEN RETURN NEW; END IF;
  INSERT INTO public."meta_sessões_trina" (fio_id, checkpoint_id, tipo, status, origem_tabela, payload, created_at)
  VALUES ('ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid, NEW.id, v_tipo, 'aguardando_trina', NEW.tabela_origem,
    jsonb_build_object('checkpoint_id', NEW.id, 'acao', NEW.acao, 'tabela_origem', NEW.tabela_origem,
      'registro_id', NEW.registro_id, 'timestamp', NEW.timestamp_acao, 'resultado', NEW.resultado,
      'missao', v_missao, 'diafragma', 'p0_checkin_mission_lab_20260930'), NOW());
  RETURN NEW;
END; $f$;

UPDATE public."meta_sessões_trina" SET status = 'propagado', updated_at = now(),
  resultado_final = jsonb_build_object('veredito','ARQUIVADO','nota','Aberta por engano quando a respiração arquivou o check-in (corrigido em trina_checkin_so_na_entrada).','em',now())
WHERE status = 'aguardando_trina' AND origem_tabela = 'checkin_recepcion' AND payload->>'acao' = 'UPDATE' AND created_at > now() - interval '1 hour';
