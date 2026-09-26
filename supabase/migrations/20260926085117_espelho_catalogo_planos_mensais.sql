-- Planos mensais, parcelamento no Pix e catálogo como fonte única de preço, prazo e limites
-- (ordem do Guardião, 26/09: "oferece parcelamento, uso mensal, diferentes planos, empresarial, estudantil").
CREATE TABLE public.espelho_catalogo (
  pacote text PRIMARY KEY CHECK (pacote ~ '^[a-z0-9_]{2,40}$'),
  nome text NOT NULL CHECK (char_length(nome) BETWEEN 2 AND 120),
  valor_centavos integer CHECK (valor_centavos IS NULL OR valor_centavos > 0),
  recorrente boolean NOT NULL DEFAULT false,
  pix_automatico boolean NOT NULL DEFAULT false,
  material text NOT NULL DEFAULT '' CHECK (char_length(material) <= 400),
  prazo text NOT NULL DEFAULT '' CHECK (char_length(prazo) <= 300),
  limites jsonb NOT NULL DEFAULT '{}'::jsonb,
  ordem integer NOT NULL DEFAULT 100,
  atualizado_em timestamptz NOT NULL DEFAULT now(),
  CHECK (NOT pix_automatico OR valor_centavos IS NOT NULL)
);
COMMENT ON TABLE public.espelho_catalogo IS 'Fonte única de preço, prazo, material pedido e limites de cada oferta do Espelho. O Pix automático só vale para o que o organismo entrega sozinho.';

ALTER TABLE public.espelho_catalogo ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.espelho_catalogo FROM anon, authenticated;

INSERT INTO public.espelho_catalogo (pacote,nome,valor_centavos,recorrente,pix_automatico,material,prazo,limites,ordem) VALUES
 ('plano_estudante','Plano Estudante',990,true,true,
  'No mesmo e-mail, diga o seu nome e a sua instituição de ensino.',
  'O plano começa em até 24 horas e vale 30 dias. Todo mês chega o lembrete do Pix; para cancelar, responda CANCELAR.',
  '{"checagens":10,"roteiros":true}',10),
 ('plano_pro','Plano Profissional',3900,true,true,
  'No mesmo e-mail, diga o seu nome e a sua área de trabalho.',
  'O plano começa em até 24 horas e vale 30 dias. Todo mês chega o lembrete do Pix; para cancelar, responda CANCELAR.',
  '{"checagens":30,"investigacoes":2,"mesas":1,"roteiros":true}',20),
 ('plano_ultra','Plano Ultra · Seu Fio no Castelo',9700,true,true,
  'No mesmo e-mail, diga o seu nome e o projeto que o organismo vai acompanhar.',
  'O plano começa em até 24 horas e vale 30 dias. Todo mês chega o lembrete do Pix; para cancelar, responda CANCELAR.',
  '{"checagens":100,"investigacoes":5,"mesas":2,"memoria_continua":true,"roteiros":true}',30),
 ('plano_empresa','Plano Empresarial',29700,true,true,
  'No mesmo e-mail, diga o nome da empresa ou do escritório e quantas pessoas vão usar (até 10).',
  'O plano começa em até 24 horas e vale 30 dias. Todo mês chega o lembrete do Pix; para cancelar, responda CANCELAR.',
  '{"pessoas":10,"checagens":150,"investigacoes":10,"mesas":4,"auditoria_por_trimestre":1,"roteiros":true}',40),
 ('checagem','Checagem P0 de uma resposta',1900,false,true,
  'No mesmo e-mail, mande a pergunta que você fez à IA e a resposta que quer checar.',
  'O laudo chega em até 24 horas.','{}',50),
 ('investigacao','Investigação Sonar',2900,false,true,
  'No mesmo e-mail, mande a pergunta que quer investigar e para que vai usar a resposta.',
  'O relatório com fontes chega em até 48 horas.','{}',60),
 ('roteiros','Roteiros do Organismo',2700,false,true,'',
  'Os Roteiros chegam em até 24 horas.','{}',70),
 ('trina','Mesa Trina por escrito',14700,false,true,
  'No mesmo e-mail, conte a decisão ou o projeto que a Mesa vai examinar.',
  'O relatório chega em até 48 horas depois do material.','{}',80),
 ('sonar','Auditoria P0 Sonar',99000,false,true,
  'No mesmo e-mail, descreva o fluxo de trabalho com IA da sua equipe: ferramentas, tarefas e quem revisa.',
  'A auditoria chega em até 5 dias úteis depois do material.','{}',90),
 ('sonar_3x','Auditoria P0 Sonar em 3 parcelas',33000,false,true,
  'Esta é a 1ª de 3 parcelas mensais de R$ 330; cada parcela libera uma etapa: diagnóstico, verificações e plano de correção. No mesmo e-mail, descreva o fluxo de trabalho com IA da sua equipe.',
  'A 1ª etapa chega em até 5 dias úteis depois do material.','{"parcelas":3}',95),
 ('travessia','Selo de Travessia',2900,true,false,'','','{}',110),
 ('curso','Curso Introdução ao Organismo EVO (pré-venda)',9700,false,false,'','','{}',120),
 ('arquitetura','Arquitetura EVO · Implantação',NULL,false,false,'','','{}',130),
 ('nucleo','Selo de Núcleo',NULL,false,false,'','','{}',140),
 ('indefinido','Quero conhecer primeiro',NULL,false,false,'','','{}',1);

-- O catálogo passa a ser a regra dos pacotes válidos.
ALTER TABLE public.espelho_interessados DROP CONSTRAINT interessados_pacote_valido;
ALTER TABLE public.espelho_interessados
  ADD CONSTRAINT interessados_pacote_catalogo FOREIGN KEY (pacote) REFERENCES public.espelho_catalogo(pacote);
ALTER TABLE public.espelho_assinaturas DROP CONSTRAINT espelho_assinaturas_pacote_check;
ALTER TABLE public.espelho_assinaturas
  ADD CONSTRAINT espelho_assinaturas_pacote_catalogo FOREIGN KEY (pacote) REFERENCES public.espelho_catalogo(pacote);
CREATE INDEX espelho_interessados_pacote_idx ON public.espelho_interessados (pacote);
CREATE INDEX espelho_assinaturas_pacote_idx ON public.espelho_assinaturas (pacote);

-- Uso mensal de cada plano (checagens, investigações, Mesas, auditorias), para o agente respeitar os limites.
CREATE TABLE public.espelho_uso (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  assinatura_id uuid NOT NULL REFERENCES public.espelho_assinaturas(id) ON DELETE CASCADE,
  tipo text NOT NULL CHECK (tipo = ANY (ARRAY['checagem','investigacao','mesa','auditoria','roteiros','memoria'])),
  referencia text CHECK (referencia IS NULL OR char_length(referencia) <= 300),
  criado_em timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE public.espelho_uso IS 'Cada entrega feita dentro de um plano mensal. Sem conteúdo do cliente: só tipo, data e referência do documento entregue.';
CREATE INDEX espelho_uso_assinatura_idx ON public.espelho_uso (assinatura_id, criado_em);
ALTER TABLE public.espelho_uso ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.espelho_uso FROM anon, authenticated;

-- A função de pagamento passa a ler o catálogo: preço, prazo e material mudam no Castelo, sem deploy.
CREATE OR REPLACE FUNCTION public.espelho_instrucoes_pagamento(p_email text)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_config public.espelho_pagamento_config%ROWTYPE;
  v_item public.espelho_catalogo%ROWTYPE;
  v_pacote text;
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

  SELECT * INTO v_item FROM public.espelho_catalogo c WHERE c.pacote = v_pacote AND c.pix_automatico;
  IF NOT FOUND THEN RETURN NULL; END IF;

  RETURN jsonb_build_object(
    'pacote', v_item.pacote,
    'nome', v_item.nome,
    'valor_centavos', v_item.valor_centavos,
    'recorrente', v_item.recorrente,
    'material', v_item.material,
    'prazo', v_item.prazo,
    'chave_pix', v_config.chave_pix,
    'favorecido', v_config.favorecido,
    'email_comprovante', v_config.email_comprovante
  );
END;
$$;

REVOKE ALL ON FUNCTION public.espelho_instrucoes_pagamento(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.espelho_instrucoes_pagamento(text) TO anon, authenticated;
