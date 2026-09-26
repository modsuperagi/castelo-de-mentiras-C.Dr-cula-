-- Migração 20260926071611 · reforma_cerebelo_ficha_p0_e_linhagem_checkin
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-26 a partir de supabase_migrations.schema_migrations.

-- Reforma do cerebelo, parte 2 (26/09/2026, Plasma por autorização do Guardião).
-- a) P0 v4: "P0 traz de volta e preenche a ficha". O veredito do motor preenche a ficha do pulso
--    (resultado_detalhado AGUARDANDO_COMPREENSAO), sem mexer nos checks nem em p0_pass.
-- b) Linhagem: sessão da Mesa vinda de check-in resolve o Coração pelo próprio check-in (registro_id)
--    e nunca herda o Coração mais recente do Fio (mesma regra que já valia para a Sol).
-- Testada em bloco desfeito: ficha preenchida com p0_pass intacto; check-in com Coração → Coração certo;
-- check-in sem Coração → recusa em vez de herdar. get_advisors (security) sem alerta novo.

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

  -- P0 traz de volta: preenche a ficha do pulso que aguardava compreensão.
  UPDATE public.p0_validacao_completa
  SET resultado_detalhado = coalesce(resultado_detalhado, '{}'::jsonb) || jsonb_build_object(
    'status', 'COMPREENDIDO_PELO_CEREBELO',
    'veredito_trina', p_resultado,
    'trina_id', v_id,
    'validador', p_validador,
    'em', now()
  )
  WHERE checkin_id = v_coracao.checkin_id
    AND resultado_detalhado->>'status' = 'AGUARDANDO_COMPREENSAO';

  RETURN v_id;
END;
$$;

REVOKE ALL ON FUNCTION public.trina_registrar_veredito(uuid, text, text, text, text, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.trina_registrar_veredito(uuid, text, text, text, text, text) TO service_role;

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

    -- 0b) Sessão vinda de check-in: o Coração é o do próprio check-in
    if v_coracao_id is null and v_origem = 'checkin_recepcion' and nullif(new.payload->>'registro_id','') is not null then
      select id into v_coracao_id
      from public.coracao_motor_principal
      where checkin_id = (new.payload->>'registro_id')::uuid
      order by timestamp_circulacao desc
      limit 1;
    end if;

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

    -- 3) Fallback Ghost/fio SOMENTE se não for caminho Sol nem check-in
    if v_coracao_id is null then
      if v_origem in ('sol_tasks', 'sol_missions', 'checkin_recepcion') then
        raise exception
          'Trina % (origem %) sem Coração da própria linhagem (checkpoint %). Não herda Coração alheio: o check-in precisa circular pelo P0 antes, ou o veredito vai pela porta trina_registrar_veredito.',
          new.id, v_origem, new.checkpoint_id;
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
      'Hellwolf: resolve Coração por payload/check-in/checkpoint/flow; Sol e check-in nunca herdam Coração alheio. Sessão Mesa ' || new.id,
      now()
    );

    raise notice 'Trina % → circulação % coracao=% flow=%', new.id, v_resultado, v_coracao_id, v_flow_id;
  end if;
  return new;
end;
$function$;
