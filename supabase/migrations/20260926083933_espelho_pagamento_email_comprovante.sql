-- Missão R$ 5.000: o comprador precisa saber para onde mandar o comprovante do Pix.
-- O agente Market lê esse endereço no Gmail do Guardião, confere o comprovante e entrega.
ALTER TABLE public.espelho_pagamento_config
  ADD COLUMN email_comprovante text
  CHECK (email_comprovante IS NULL OR (char_length(email_comprovante) <= 254 AND email_comprovante ~* '^[^@\s]+@[^@\s]+\.[^@\s]{2,}$'));

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

  -- Só produtos que o organismo entrega sem o Guardião: Roteiros (Drive) e Mesa Trina (relatório escrito).
  v_valor := CASE v_pacote WHEN 'roteiros' THEN 4700 WHEN 'trina' THEN 45000 ELSE NULL END;
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
