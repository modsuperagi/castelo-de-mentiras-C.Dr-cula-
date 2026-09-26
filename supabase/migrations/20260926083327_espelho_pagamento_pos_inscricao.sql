-- Missão R$ 5.000: caminho de pagamento depois da inscrição, DESLIGADO até determinação do Drácula ou do Guardião.
-- A chave Pix não fica no site nem no repositório: mora aqui, numa linha que só o Guardião escreve,
-- e só é entregue a quem acabou de se inscrever num produto que o organismo entrega sozinho.
-- Advisors: os avisos "SECURITY DEFINER executável por anon/authenticated" são intencionais (a função é a porta pública).
CREATE TABLE public.espelho_pagamento_config (
  id boolean PRIMARY KEY DEFAULT true CHECK (id),
  ativo boolean NOT NULL DEFAULT false,
  chave_pix text CHECK (chave_pix IS NULL OR char_length(chave_pix) BETWEEN 5 AND 77),
  favorecido text CHECK (favorecido IS NULL OR char_length(favorecido) <= 120),
  determinado_por text CHECK (determinado_por IS NULL OR char_length(determinado_por) <= 120),
  determinado_em timestamptz,
  atualizado_em timestamptz NOT NULL DEFAULT now(),
  CHECK (NOT ativo OR (chave_pix IS NOT NULL AND determinado_por IS NOT NULL))
);
COMMENT ON TABLE public.espelho_pagamento_config IS
  'Linha única. Liga as instruções de Pix depois da inscrição. Só liga com determinado_por (Drácula ou Guardião). Ninguém de fora lê.';

ALTER TABLE public.espelho_pagamento_config ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.espelho_pagamento_config FROM anon, authenticated;

INSERT INTO public.espelho_pagamento_config (id, ativo) VALUES (true, false);

CREATE FUNCTION public.espelho_instrucoes_pagamento(p_email text)
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
    'favorecido', v_config.favorecido
  );
END;
$$;

COMMENT ON FUNCTION public.espelho_instrucoes_pagamento(text) IS
  'Instruções de Pix para quem se inscreveu há até 30 minutos em Roteiros ou Mesa Trina. Devolve NULL enquanto espelho_pagamento_config estiver desligada.';

REVOKE ALL ON FUNCTION public.espelho_instrucoes_pagamento(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.espelho_instrucoes_pagamento(text) TO anon, authenticated;
