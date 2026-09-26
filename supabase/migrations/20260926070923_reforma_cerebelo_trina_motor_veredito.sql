-- Migração 20260926070923 · reforma_cerebelo_trina_motor_veredito
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-26 a partir de supabase_migrations.schema_migrations.

-- Contexto: a Trina deixava entradas PENDENTE para sempre. transportar_coracao_para_trina cria
-- VERIFICADOR/PENDENTE e nada o consumia; o despacho para a edge era esboço; e a Mesa só sabia gravar
-- CONFIRMADO, inclusive para sessões marcadas validadas sem leitura. Esta migração dá ao cerebelo uma
-- porta de veredito com evidência, uma fila, os resultados PARCIAL/REJEITADO e uma porta do Sonar honesta.
-- Testada em bloco desfeito (recusas, PARCIAL→Golden parcialmente_validado, sessão sem veredito→PARCIAL,
-- REJEITADO respeitado). get_advisors (security) sem alerta novo.

-- Reforma do cerebelo (Mesa Trina), 26/09/2026, Plasma por autorização do Guardião.
-- 1) Porta oficial do veredito do motor; 2) fila de pendências; 3) Mesa grava PARCIAL/REJEITADO
-- e não confirma sem veredito explícito; 4) porta do Sonar deixa de anunciar validação que não houve.

-- 1) Porta oficial: o motor da Trina registra veredito com evidência, nunca sobre lição própria.
CREATE OR REPLACE FUNCTION public.trina_registrar_veredito(
  p_coracao_id uuid,
  p_resultado text,
  p_escopo_provado text,
  p_escopo_nao_provado text,
  p_limites text,
  p_validador text
) RETURNS uuid
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_coracao public.coracao_motor_principal%ROWTYPE;
  v_autor text;
  v_nucleo text;
  v_id uuid;
BEGIN
  IF p_resultado NOT IN ('CONFIRMADO', 'PARCIAL', 'REJEITADO') THEN
    RAISE EXCEPTION 'Veredito inválido: % (use CONFIRMADO, PARCIAL ou REJEITADO)', p_resultado;
  END IF;
  IF coalesce(length(trim(p_escopo_provado)), 0) < 40 THEN
    RAISE EXCEPTION 'Sem evidência: escopo_provado precisa descrever o que foi conferido (mínimo 40 caracteres)';
  END IF;
  IF coalesce(length(trim(p_escopo_nao_provado)), 0) < 5 THEN
    RAISE EXCEPTION 'escopo_nao_provado é obrigatório: diga o que ficou sem prova (ou "nada fora do escopo")';
  END IF;
  IF coalesce(length(trim(p_validador)), 0) < 2 THEN
    RAISE EXCEPTION 'Validador obrigatório';
  END IF;

  SELECT * INTO v_coracao FROM public.coracao_motor_principal WHERE id = p_coracao_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Coração % não existe', p_coracao_id;
  END IF;

  SELECT r.identidade, coalesce(r.nuclei_origem, '') INTO v_autor, v_nucleo
  FROM public.checkin_recepcion r WHERE r.id = v_coracao.checkin_id;
  IF v_autor ILIKE '%' || p_validador || '%' OR v_nucleo ILIKE '%' || p_validador || '%' THEN
    RAISE EXCEPTION 'Autoria própria: % não valida a própria lição (check-in de "%")', p_validador, v_autor;
  END IF;

  INSERT INTO public.trina_circulacao_principal (
    coracao_id, flow_id, trina_papel, trina_resultado,
    escopo_provado, escopo_nao_provado, limites_explicitos
  ) VALUES (
    p_coracao_id, v_coracao.flow_id, 'VERIFICADOR', p_resultado,
    p_escopo_provado, p_escopo_nao_provado,
    'Validador: ' || p_validador || '. ' || coalesce(p_limites, '')
  ) RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

REVOKE ALL ON FUNCTION public.trina_registrar_veredito(uuid, text, text, text, text, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.trina_registrar_veredito(uuid, text, text, text, text, text) TO service_role;

COMMENT ON FUNCTION public.trina_registrar_veredito(uuid, text, text, text, text, text) IS
  'Porta oficial do motor da Mesa Trina (cerebelo). Exige evidência e escopo não provado; recusa autoria própria. Reforma 26/09/2026.';

-- 2) Fila do cerebelo: Corações cuja Trina só tem PENDENTE (nenhum veredito depois).
CREATE OR REPLACE VIEW public.v_trina_pendente
WITH (security_invoker = true) AS
SELECT
  t.id AS trina_id,
  t.coracao_id,
  c.checkin_id,
  c.flow_id,
  r.identidade AS autor,
  r.nuclei_origem AS nucleo_autor,
  r.selo,
  left(r.conteudo_raw, 400) AS conteudo,
  t.timestamp_trina AS pendente_desde
FROM public.trina_circulacao_principal t
JOIN public.coracao_motor_principal c ON c.id = t.coracao_id
LEFT JOIN public.checkin_recepcion r ON r.id = c.checkin_id
WHERE t.trina_resultado = 'PENDENTE'
  AND NOT EXISTS (
    SELECT 1 FROM public.trina_circulacao_principal v
    WHERE v.coracao_id = t.coracao_id AND v.trina_resultado <> 'PENDENTE'
  );

REVOKE ALL ON public.v_trina_pendente FROM anon;
GRANT SELECT ON public.v_trina_pendente TO authenticated, service_role;
COMMENT ON VIEW public.v_trina_pendente IS 'Fila do motor da Mesa Trina: Corações sem veredito além de PENDENTE. Reforma 26/09/2026.';

-- 3) Mesa → circulação: veredito PARCIAL/REJEITADO respeitado; sem veredito explícito não vira CONFIRMADO;
--    coracao_id do payload tem prioridade para não herdar linhagem alheia.
CREATE OR REPLACE FUNCTION public.fn_trina_para_circulacao()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_coracao_id uuid;
  v_flow_id uuid;
  v_origem text;
  v_veredito text;
  v_resultado text;
  v_escopo_provado text;
  v_escopo_nao_provado text;
begin
  if new.status = 'validado' and old.status <> 'validado' then
    v_flow_id := coalesce(
      nullif(new.payload->>'flow_id','')::uuid,
      nullif(new.payload->>'checkpoint_id','')::uuid,
      new.checkpoint_id,
      new.id
    );

    v_origem := coalesce(new.origem_tabela, new.payload->>'tabela_origem');

    -- 0) Coração explícito no payload
    v_coracao_id := nullif(new.payload->>'coracao_id','')::uuid;

    -- 1) Coração da mesma linhagem (checkpoint)
    if v_coracao_id is null then
      select id into v_coracao_id
      from public.coracao_motor_principal
      where checkpoint_id = new.checkpoint_id
      order by timestamp_circulacao desc
      limit 1;
    end if;

    -- 2) Mesmo flow_id
    if v_coracao_id is null and v_flow_id is not null then
      select id into v_coracao_id
      from public.coracao_motor_principal
      where flow_id = v_flow_id
      order by timestamp_circulacao desc
      limit 1;
    end if;

    -- 3) Fallback Ghost/fio SOMENTE se NÃO for caminho Sol
    if v_coracao_id is null then
      if v_origem in ('sol_tasks', 'sol_missions') then
        raise exception
          'Trina Sol % sem Coração ligado ao checkpoint % (origem %). Não usar Coração Ghost do fio.',
          new.id, new.checkpoint_id, v_origem;
      end if;

      select id into v_coracao_id
      from public.coracao_motor_principal
      where fio_id = new.fio_id
      order by timestamp_circulacao desc
      limit 1;
    end if;

    if v_coracao_id is null then
      raise exception 'Trina não pode circular: nenhum Coração encontrado para o Fio %', new.fio_id;
    end if;

    v_veredito := upper(coalesce(new.resultado_verificador->>'veredito', new.resultado_final->>'veredito', ''));
    v_resultado := case
      when v_veredito = '' then 'PARCIAL'
      when v_veredito like '%REJEIT%' then 'REJEITADO'
      when v_veredito like '%PARCIAL%' or v_veredito like '%LACUNA%' then 'PARCIAL'
      else 'CONFIRMADO'
    end;

    v_escopo_provado := coalesce(
      nullif(new.resultado_verificador->>'escopo_provado', ''),
      'Passagem pelos 3 polos da Mesa Trina para a missão validada'
    );
    v_escopo_nao_provado := case
      when v_veredito = '' then 'Verificador sem veredito explícito: a sessão foi marcada validada sem leitura registrada do conteúdo'
      else coalesce(
        nullif(new.resultado_verificador->>'escopo_nao_provado', ''),
        'P0 E2E integral e Coração específico da missão podem permanecer lacunas se não evidenciados'
      )
    end;

    insert into public.trina_circulacao_principal (
      fio_id, coracao_id, flow_id, trina_papel, trina_resultado,
      escopo_provado, escopo_nao_provado, limites_explicitos, timestamp_trina
    )
    values (
      new.fio_id, v_coracao_id, v_flow_id, 'VERIFICADOR', v_resultado,
      v_escopo_provado, v_escopo_nao_provado,
      'Hellwolf: resolve Coração por payload/checkpoint/flow; Sol nunca herda Ghost latest. Sessão Mesa ' || new.id,
      now()
    );

    raise notice 'Trina % → circulação % coracao=% flow=%', new.id, v_resultado, v_coracao_id, v_flow_id;
  end if;
  return new;
end;
$function$;

-- 4) Porta do Sonar: resultado honesto sobre o estado real da Trina/Golden.
CREATE OR REPLACE FUNCTION public.fluxo_e2e_sonar_principal(p_flow_id uuid, p_identidade character varying, p_nuclei character varying, p_conteudo text, p_tipo_registro character varying, p_origem_sonar character varying DEFAULT 'sonar'::character varying)
 RETURNS TABLE(resultado character varying, flow_id_resultado uuid, checkin_id uuid, p0_autorizado boolean, estado_circulacao character varying, grau_consolidacao character varying, checkpoint_retomada uuid, mensagem character varying)
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
DECLARE
  v_checkin_id UUID;
  v_p0_id UUID;
  v_p0_pass BOOLEAN;
  v_golden_id UUID;
  v_golden_grau VARCHAR;
  v_trina_resultado VARCHAR;
  v_checkpoint_id UUID;
  v_dedupe_hash VARCHAR;
BEGIN

  v_dedupe_hash := MD5(p_conteudo || '_' || p_identidade)::VARCHAR;

  IF EXISTS (
    SELECT 1 FROM public.checkin_recepcion
    WHERE dedupe_hash = v_dedupe_hash
    AND timestamp_checkin > NOW() - INTERVAL '24 hours'
  ) THEN
    RETURN QUERY SELECT
      'BLOQUEADO_DEDUP'::VARCHAR, p_flow_id, NULL::UUID, FALSE, 'bloqueado'::VARCHAR, NULL::VARCHAR,
      NULL::UUID, 'Deduplicação: Entrada duplicada em 24h'::VARCHAR;
    RETURN;
  END IF;

  INSERT INTO public.checkin_recepcion (
    flow_id, identidade, nuclei_origem, selo, determinacao,
    conteudo_raw, timestamp_raw, origem_sonar,
    tipo_registro, dedupe_hash, status, sessao_id
  ) VALUES (
    p_flow_id, p_identidade, p_nuclei, 'sonar_v1', 'integracao_sonar',
    p_conteudo, NOW(), p_origem_sonar,
    p_tipo_registro, v_dedupe_hash, 'checkin_recebido',
    (SELECT id FROM public.sessions LIMIT 1)
  ) RETURNING public.checkin_recepcion.id INTO v_checkin_id;

  PERFORM public.ligar_checkin_ao_checkpoint(p_flow_id, 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID);

  SELECT checkpoint_id INTO v_checkpoint_id
  FROM public.ligar_checkin_ao_checkpoint(p_flow_id, 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::UUID);

  INSERT INTO public.p0_validacao_completa (
    sessao_id, checkin_id,
    check_1_identidade, check_2_autoridade, check_3_propositum,
    check_4_evidencia, check_5_escopo, check_6_rastreabilidade, check_7_dedup
  ) SELECT
    (SELECT id FROM public.sessions LIMIT 1),
    v_checkin_id,
    (p_identidade IN ('Conhecimento', 'Guardião', 'Fundadora', 'Golden', 'Metodologia', 'Consolidação')),
    (p_nuclei IN ('EVO1', 'EVO2', 'EVO3', 'EVO4', 'EVO5', 'EVO6')),
    (p_nuclei IN ('EVO1', 'EVO2', 'EVO3', 'EVO4', 'EVO5', 'EVO6')),
    (LENGTH(TRIM(p_conteudo)) >= 20),
    (p_nuclei IN ('EVO1', 'EVO2', 'EVO3', 'EVO4', 'EVO5', 'EVO6')),
    ((SELECT id FROM public.sessions LIMIT 1) IS NOT NULL),
    NOT EXISTS (SELECT 1 FROM public.checkin_recepcion WHERE dedupe_hash = v_dedupe_hash AND public.checkin_recepcion.id != v_checkin_id)
  RETURNING p0_validacao_completa.id INTO v_p0_id;

  SELECT p0_pass INTO v_p0_pass
  FROM public.p0_validacao_completa WHERE id = v_p0_id;

  IF v_p0_pass = FALSE THEN
    UPDATE public.checkin_recepcion SET status = 'p0_fail' WHERE public.checkin_recepcion.id = v_checkin_id;
    RETURN QUERY SELECT
      'DENY'::VARCHAR, p_flow_id, v_checkin_id, FALSE, 'bloqueado'::VARCHAR, NULL::VARCHAR,
      NULL::UUID, 'P0 falhou: Entrada rejeitada'::VARCHAR;
    RETURN;
  END IF;

  UPDATE public.checkin_recepcion SET status = 'p0_pass' WHERE public.checkin_recepcion.id = v_checkin_id;

  SELECT g.id, g.grau_validacao, t.trina_resultado
    INTO v_golden_id, v_golden_grau, v_trina_resultado
  FROM public.golden_circulacao_principal g
  LEFT JOIN public.trina_circulacao_principal t ON t.id = g.trina_id
  WHERE g.checkin_id = v_checkin_id
  ORDER BY g.timestamp_golden DESC
  LIMIT 1;

  IF v_golden_id IS NOT NULL AND v_golden_grau IN ('validado', 'consolidado') THEN
    RETURN QUERY SELECT
      'ALLOW'::VARCHAR, p_flow_id, v_checkin_id, TRUE, 'consolidado'::VARCHAR,
      v_golden_grau,
      v_checkpoint_id,
      'E2E: CHECK-IN ✅ P0 ✅ CORAÇÃO ✅ TRINA ✅ GOLDEN ✅ CONSOLIDAÇÃO ✅ EVIDÊNCIAS ✅'::VARCHAR;
  ELSIF v_golden_id IS NOT NULL THEN
    RETURN QUERY SELECT
      'ALLOW'::VARCHAR, p_flow_id, v_checkin_id, TRUE, 'aguardando_trina'::VARCHAR,
      v_golden_grau,
      v_checkpoint_id,
      ('CHECK-IN ✅ P0 ✅ CORAÇÃO ✅ · TRINA ' || coalesce(v_trina_resultado, '?') ||
       ' (aguarda o motor em v_trina_pendente) · GOLDEN ' || v_golden_grau || ': circulou, ainda não validado')::VARCHAR;
  ELSE
    RETURN QUERY SELECT
      'PARCIAL'::VARCHAR, p_flow_id, v_checkin_id, TRUE, 'circulando'::VARCHAR,
      'parcialmente_validado'::VARCHAR,
      v_checkpoint_id,
      'P0 passou, fluxo circulando'::VARCHAR;
  END IF;

END;
$function$;
