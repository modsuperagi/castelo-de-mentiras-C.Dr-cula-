-- Preços acessíveis (ordem do Guardião, 26/09: "cobre preços acessíveis") e novo produto de entrada:
-- Checagem P0 de uma resposta (R$ 19). Todos entregues pelo organismo, por escrito.
ALTER TABLE public.espelho_interessados DROP CONSTRAINT interessados_pacote_valido;
ALTER TABLE public.espelho_interessados ADD CONSTRAINT interessados_pacote_valido
  CHECK (pacote = ANY (ARRAY['indefinido','checagem','travessia','nucleo','curso','roteiros','trina','sonar','arquitetura']));

ALTER TABLE public.espelho_assinaturas DROP CONSTRAINT espelho_assinaturas_pacote_check;
ALTER TABLE public.espelho_assinaturas ADD CONSTRAINT espelho_assinaturas_pacote_check
  CHECK (pacote = ANY (ARRAY['checagem','travessia','nucleo','curso','roteiros','trina','sonar','arquitetura']));

CREATE OR REPLACE FUNCTION public.espelho_instrucoes_pagamento(p_email text)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_config public.espelho_pagamento_config%ROWTYPE;
  v_pacote text;
  v_valor integer;
BEGIN
  SELECT * INTO v_config FROM public.espelho_pagamento_config WHERE id AND ativo AND chave_pix IS NOT NULL;
  IF NOT FOUND THEN RETURN NULL; END IF;

  SELECT i.pacote INTO v_pacote
  FROM public.espelho_interessados i
  WHERE lower(i.email) = lower(trim(p_email))
    AND i.consentimento
    AND i.criado_em > now() - interval '30 minutes'
  ORDER BY i.criado_em DESC
  LIMIT 1;
  IF NOT FOUND THEN RETURN NULL; END IF;

  -- Só o que o organismo entrega por escrito, sem o Guardião.
  v_valor := CASE v_pacote
    WHEN 'checagem' THEN 1900
    WHEN 'roteiros' THEN 2700
    WHEN 'trina'    THEN 14700
    WHEN 'sonar'    THEN 99000
    ELSE NULL END;
  IF v_valor IS NULL THEN RETURN NULL; END IF;

  RETURN jsonb_build_object(
    'pacote', v_pacote,
    'valor_centavos', v_valor,
    'chave_pix', v_config.chave_pix,
    'favorecido', v_config.favorecido,
    'email_comprovante', v_config.email_comprovante
  );
END;
$$;

REVOKE ALL ON FUNCTION public.espelho_instrucoes_pagamento(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.espelho_instrucoes_pagamento(text) TO anon, authenticated;
