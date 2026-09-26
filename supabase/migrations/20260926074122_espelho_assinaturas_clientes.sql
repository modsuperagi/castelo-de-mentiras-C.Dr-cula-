-- Assinaturas e compras dos clientes do Espelho Espelho Evo.
-- Fonte da verdade de quem pagou o quê. Só o Guardião (e o service_role do agente Market) lê e escreve.
-- Nunca guardar dado bancário: só a referência da transação (id do Mercado Pago ou E2E do Pix).
CREATE TABLE public.espelho_assinaturas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id uuid NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid
    CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid),
  interessado_id uuid NOT NULL REFERENCES public.espelho_interessados(id) ON DELETE RESTRICT,
  pacote text NOT NULL
    CHECK (pacote = ANY (ARRAY['travessia','nucleo','curso','roteiros','trina','sonar','arquitetura'])),
  valor_centavos integer NOT NULL CHECK (valor_centavos > 0),
  forma text NOT NULL
    CHECK (forma = ANY (ARRAY['pix','link_pagamento','cartao','boleto','cortesia'])),
  status text NOT NULL DEFAULT 'aguardando_pagamento'
    CHECK (status = ANY (ARRAY['aguardando_pagamento','ativa','encerrada','cancelada','reembolsada'])),
  referencia_pagamento text CHECK (referencia_pagamento IS NULL OR char_length(referencia_pagamento) <= 200),
  inicio date,
  fim date,
  observacao text CHECK (observacao IS NULL OR char_length(observacao) <= 1000),
  criado_em timestamptz NOT NULL DEFAULT now(),
  atualizado_em timestamptz NOT NULL DEFAULT now(),
  CHECK (fim IS NULL OR inicio IS NULL OR fim >= inicio),
  CHECK (status <> 'ativa' OR inicio IS NOT NULL)
);

COMMENT ON TABLE public.espelho_assinaturas IS
  'Compras e assinaturas dos clientes do Espelho. Sem dado bancário: só a referência da transação. Leitura e escrita só do Guardião.';

CREATE INDEX espelho_assinaturas_interessado_idx ON public.espelho_assinaturas (interessado_id);
CREATE INDEX espelho_assinaturas_pendentes_idx ON public.espelho_assinaturas (criado_em)
  WHERE status = 'aguardando_pagamento';

ALTER TABLE public.espelho_assinaturas ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.espelho_assinaturas FROM anon;

CREATE POLICY guardiao_admin_total ON public.espelho_assinaturas
  FOR ALL TO authenticated
  USING ((SELECT public.eh_guardiao()))
  WITH CHECK ((SELECT public.eh_guardiao()));
