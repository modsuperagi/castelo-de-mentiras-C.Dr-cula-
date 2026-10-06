-- Mesa Trina que não trava (ordem do Guardião, 30/09/2026). Testado antes no projeto auxiliar xrgapxeauoccaruvcfhs.
-- Profundidade proporcional: reflexo (registra e segue), pensamento (Trina lê se houver motor; se não, arquiva honesto),
-- missão (aberta pelo Lab, fica na Mesa até ser concluída). Toda missão concluída vira aprendizado consultável.

-- 0. Fio: "NEW IS NOT NULL" só é verdadeiro quando nenhuma coluna é nula; o Fio perdia dados_novo/dados_antigo.
CREATE OR REPLACE FUNCTION public.trigger_fio_checkpoint() RETURNS trigger LANGUAGE plpgsql SET search_path TO 'public' AS $f$
DECLARE v_record_id UUID;
BEGIN
  v_record_id := CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END;
  INSERT INTO public.fios_checkpoint_universal (fio_id, acao, tabela_origem, registro_id, timestamp_acao, resultado)
  VALUES ('ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid, TG_OP, TG_TABLE_NAME, coalesce(v_record_id, gen_random_uuid()), NOW(),
    jsonb_build_object('operacao', TG_OP, 'tabela', TG_TABLE_NAME, 'trigger_time', NOW()::text,
      'dados_novo', CASE WHEN TG_OP <> 'DELETE' THEN to_jsonb(NEW) END,
      'dados_antigo', CASE WHEN TG_OP <> 'INSERT' THEN to_jsonb(OLD) END));
  RETURN COALESCE(NEW, OLD);
END; $f$;

-- 1. Resultado honesto para o que não foi deliberado: ARQUIVADO não sobe para Golden.
ALTER TABLE public.trina_circulacao_principal DROP CONSTRAINT IF EXISTS trina_circulacao_principal_trina_resultado_check;
ALTER TABLE public.trina_circulacao_principal ADD CONSTRAINT trina_circulacao_principal_trina_resultado_check
  CHECK (trina_resultado::text = ANY (ARRAY['CONFIRMADO','PARCIAL','REJEITADO','PENDENTE','ARQUIVADO']));

-- 2. Missão aberta no Lab (meta_lab_entries, coleção MISSOES_TRINA) abre sessão na Mesa.
CREATE OR REPLACE FUNCTION public.checkpoint_dispara_trina() RETURNS trigger LANGUAGE plpgsql SET search_path TO 'public' AS $f$
DECLARE v_p0_pass boolean; v_allow boolean := false; v_tipo text := 'CHECKPOINT_AUTOMÁTICO'; v_missao boolean := false;
BEGIN
  IF NEW.tabela_origem = 'checkin_recepcion' THEN
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

-- 3. Abrir missão (porta do Lab).
CREATE OR REPLACE FUNCTION public.trina_abrir_missao(p_titulo text, p_objetivo text, p_criterio_conclusao text, p_aberta_por text)
RETURNS uuid LANGUAGE plpgsql SET search_path TO '' AS $f$
DECLARE v_lab uuid; v_sessao uuid;
BEGIN
  IF coalesce(length(trim(p_titulo)),0) < 5 OR coalesce(length(trim(p_objetivo)),0) < 20
     OR coalesce(length(trim(p_criterio_conclusao)),0) < 10 OR coalesce(length(trim(p_aberta_por)),0) < 2 THEN
    RAISE EXCEPTION 'Missão precisa de título, objetivo (20+), critério de conclusão (10+) e quem abriu';
  END IF;
  INSERT INTO public.meta_lab_entries (colecao, titulo, conteudo, tipo_conteudo, estado, fonte, metadata)
  VALUES ('MISSOES_TRINA', p_titulo, p_objetivo, 'missao', 'em análise', p_aberta_por,
    jsonb_build_object('criterio_conclusao', p_criterio_conclusao, 'aberta_por', p_aberta_por,
      'fio_id', 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'))
  RETURNING id INTO v_lab;
  SELECT s.id INTO v_sessao FROM public."meta_sessões_trina" s
  WHERE s.origem_tabela = 'meta_lab_entries' AND s.payload->>'registro_id' = v_lab::text
  ORDER BY s.created_at DESC LIMIT 1;
  RETURN v_sessao;
END; $f$;

-- 4. Concluir missão: três posições, veredito de quem não abriu, e o aprendizado entra na memória.
CREATE OR REPLACE FUNCTION public.trina_concluir_missao(p_sessao_id uuid, p_arquiteto text, p_engenheiro text,
  p_verificador text, p_veredito text, p_aprendizado text, p_verificador_nome text)
RETURNS uuid LANGUAGE plpgsql SET search_path TO '' AS $f$
DECLARE v_s public."meta_sessões_trina"%ROWTYPE; v_lab uuid; v_aberta_por text; v_titulo text; v_apr uuid;
BEGIN
  SELECT * INTO v_s FROM public."meta_sessões_trina" WHERE id = p_sessao_id FOR UPDATE;
  IF NOT FOUND OR coalesce(v_s.payload->>'missao','false') <> 'true' THEN RAISE EXCEPTION 'Sessão % não é missão', p_sessao_id; END IF;
  IF v_s.status NOT IN ('aguardando_trina','em_processamento') THEN RAISE EXCEPTION 'Missão já concluída (%)', v_s.status; END IF;
  IF p_veredito NOT IN ('CONFIRMADO','PARCIAL','REJEITADO') THEN RAISE EXCEPTION 'Veredito inválido: %', p_veredito; END IF;
  IF least(length(coalesce(trim(p_arquiteto),'')), length(coalesce(trim(p_engenheiro),'')), length(coalesce(trim(p_verificador),''))) < 20 THEN
    RAISE EXCEPTION 'As três posições precisam de leitura própria (20+ caracteres cada)';
  END IF;
  IF length(coalesce(trim(p_aprendizado),'')) < 30 THEN RAISE EXCEPTION 'Diga o que o organismo aprendeu (30+ caracteres)'; END IF;
  v_lab := (v_s.payload->>'registro_id')::uuid;
  SELECT metadata->>'aberta_por', titulo INTO v_aberta_por, v_titulo FROM public.meta_lab_entries WHERE id = v_lab;
  IF coalesce(length(trim(p_verificador_nome)),0) < 2 OR lower(trim(p_verificador_nome)) = lower(trim(coalesce(v_aberta_por,''))) THEN
    RAISE EXCEPTION 'Quem abriu a missão (%) não dá o veredito dela', v_aberta_por;
  END IF;
  UPDATE public."meta_sessões_trina" SET status = 'propagado', updated_at = now(),
    resultado_arquiteto = jsonb_build_object('leitura', p_arquiteto),
    resultado_engenheiro = jsonb_build_object('leitura', p_engenheiro),
    resultado_verificador = jsonb_build_object('leitura', p_verificador, 'veredito', p_veredito, 'verificador', p_verificador_nome),
    resultado_final = jsonb_build_object('veredito', p_veredito, 'aprendizado', p_aprendizado, 'concluida_em', now(), 'missao_lab_id', v_lab)
  WHERE id = p_sessao_id;
  UPDATE public.meta_lab_entries SET estado = 'decisão', verificado_por = p_verificador_nome WHERE id = v_lab;
  INSERT INTO public.meta_lab_entries (colecao, titulo, conteudo, tipo_conteudo, estado, fonte, grau_confianca, verificado_por, metadata)
  VALUES ('APRENDIZADOS', 'Aprendizado: ' || coalesce(v_titulo,'missão'), p_aprendizado, 'aprendizado', 'consolidado',
    'Mesa Trina', CASE p_veredito WHEN 'CONFIRMADO' THEN 'alto' WHEN 'PARCIAL' THEN 'medio' ELSE 'baixo' END, p_verificador_nome,
    jsonb_build_object('missao_lab_id', v_lab, 'sessao_id', p_sessao_id, 'veredito', p_veredito, 'aberta_por', v_aberta_por))
  RETURNING id INTO v_apr;
  RETURN v_apr;
END; $f$;

-- 5. Respiração: nada que não é missão fica preso na Mesa.
CREATE OR REPLACE FUNCTION public.trina_respirar(p_horas_reflexo int DEFAULT 24, p_dias_pensamento int DEFAULT 7)
RETURNS jsonb LANGUAGE plpgsql SET search_path TO '' AS $f$
DECLARE v_p0 int := 0; v_sess int := 0; v_trina int := 0;
BEGIN
  WITH alvo AS (
    SELECT p.id, p.checkin_id FROM public.p0_validacao_completa p
    JOIN public.checkin_recepcion c ON c.id = p.checkin_id
    WHERE p.resultado_detalhado->>'status' = 'AGUARDANDO_COMPREENSAO'
      AND p.timestamp_validacao < now() - make_interval(hours => p_horas_reflexo)
      AND coalesce(c.tipo_registro,'') <> 'missao'
  ), up AS (
    UPDATE public.p0_validacao_completa p SET resultado_detalhado = p.resultado_detalhado || jsonb_build_object(
      'status', 'REGISTRADO_POR_REFLEXO', 'em', now(),
      'nota', 'Não precisou de deliberação: registrado e mantido na memória. Para deliberar, abra como missão.')
    FROM alvo WHERE p.id = alvo.id RETURNING alvo.checkin_id
  )
  SELECT count(*) INTO v_p0 FROM up;
  UPDATE public.checkin_recepcion c SET status = 'arquivado'
  WHERE c.status = 'checkin_recebido' AND EXISTS (SELECT 1 FROM public.p0_validacao_completa p
    WHERE p.checkin_id = c.id AND p.resultado_detalhado->>'status' = 'REGISTRADO_POR_REFLEXO');

  UPDATE public."meta_sessões_trina" s SET status = 'propagado', updated_at = now(),
    resultado_final = coalesce(s.resultado_final,'{}'::jsonb) || jsonb_build_object('veredito','ARQUIVADO',
      'nota','Sem deliberação em ' || p_dias_pensamento || ' dias; não era missão. Reabrir como missão se precisar.', 'em', now())
  WHERE s.status IN ('aguardando_trina','em_processamento')
    AND coalesce(s.payload->>'missao','false') <> 'true'
    AND s.created_at < now() - make_interval(days => p_dias_pensamento);
  GET DIAGNOSTICS v_sess = ROW_COUNT;

  INSERT INTO public.trina_circulacao_principal (coracao_id, flow_id, trina_papel, trina_resultado, escopo_provado, escopo_nao_provado, limites_explicitos)
  SELECT t.coracao_id, t.flow_id, 'VERIFICADOR', 'ARQUIVADO',
    'Nada foi conferido: circulação arquivada pela respiração da Mesa após ' || p_dias_pensamento || ' dias sem veredito.',
    'Todo o conteúdo segue sem prova; reabrir como missão para deliberar.',
    'Respiração automática da Mesa Trina (trina_respirar). Não é veredito.'
  FROM public.trina_circulacao_principal t
  WHERE t.trina_resultado = 'PENDENTE' AND t.timestamp_trina < now() - make_interval(days => p_dias_pensamento)
    AND NOT EXISTS (SELECT 1 FROM public.trina_circulacao_principal v WHERE v.coracao_id = t.coracao_id AND v.trina_resultado <> 'PENDENTE');
  GET DIAGNOSTICS v_trina = ROW_COUNT;

  RETURN jsonb_build_object('p0_reflexo', v_p0, 'sessoes_propagadas', v_sess, 'circulacao_arquivada', v_trina, 'em', now());
END; $f$;

-- 6. Antes de operar, o núcleo consulta o que já aprendemos e decidimos.
CREATE OR REPLACE FUNCTION public.castelo_aprendizados(p_tema text DEFAULT NULL, p_limite int DEFAULT 8)
RETURNS TABLE(origem text, id uuid, titulo text, conteudo text, grau text, em timestamptz)
LANGUAGE sql STABLE SET search_path TO '' AS $f$
  WITH q AS (SELECT CASE WHEN coalesce(trim(p_tema),'') = '' THEN NULL ELSE plainto_tsquery('portuguese', p_tema) END AS tsq)
  SELECT * FROM (
    SELECT 'aprendizado'::text, e.id, e.titulo, e.conteudo, e.grau_confianca, e.criado_em
    FROM public.meta_lab_entries e, q
    WHERE e.colecao = 'APRENDIZADOS' AND e.estado = 'consolidado'
      AND (q.tsq IS NULL OR to_tsvector('portuguese', e.titulo || ' ' || coalesce(e.conteudo,'')) @@ q.tsq)
    UNION ALL
    SELECT 'decisao', d.id, d.decisao, coalesce(d.mudanca, d.motivo), d.nivel_acesso, d.data_decisao::timestamptz
    FROM public.registro_decisoes d, q
    WHERE d.status = 'ativa'
      AND (q.tsq IS NULL OR to_tsvector('portuguese', d.decisao || ' ' || coalesce(d.motivo,'') || ' ' || coalesce(d.mudanca,'')) @@ q.tsq)
  ) x ORDER BY 6 DESC LIMIT greatest(1, least(p_limite, 50));
$f$;

REVOKE ALL ON FUNCTION public.trina_abrir_missao(text,text,text,text), public.trina_concluir_missao(uuid,text,text,text,text,text,text),
  public.trina_respirar(int,int), public.castelo_aprendizados(text,int) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.trina_abrir_missao(text,text,text,text), public.trina_concluir_missao(uuid,text,text,text,text,text,text),
  public.trina_respirar(int,int), public.castelo_aprendizados(text,int) TO authenticated, service_role;

-- 7. A Mesa respira sozinha uma vez por dia (custo zero: pg_cron do próprio Castelo).
SELECT cron.unschedule(jobid) FROM cron.job WHERE jobname = 'trina-respirar';
SELECT cron.schedule('trina-respirar', '17 6 * * *', 'select public.trina_respirar()');
