-- Reforma do Espelho com SONAR (documento operacional do Guardião, 27/09/2026), Fases 3 a 9.
-- Sinal do público ≠ verdade: todo sinal entra como RECEBIDO; só o organismo muda o estado, e só com evidência.

CREATE TABLE public.espelho_sinais (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  criado_em timestamptz NOT NULL DEFAULT now(),
  atualizado_em timestamptz NOT NULL DEFAULT now(),
  tipo text NOT NULL CHECK (tipo = ANY (ARRAY['pergunta','opiniao','experiencia','ideia','evidencia','correcao','proposta','investigar'])),
  pagina text NOT NULL CHECK (pagina ~ '^[a-z0-9/_.-]{1,120}$'),
  texto text CHECK (texto IS NULL OR char_length(texto) BETWEEN 3 AND 4000),
  autor_nome text CHECK (autor_nome IS NULL OR char_length(autor_nome) BETWEEN 2 AND 80),
  autor_email text CHECK (autor_email IS NULL OR (char_length(autor_email) <= 254 AND autor_email ~ '^[^@\s]+@[^@\s]+\.[^@\s]{2,}$')),
  contato_ok boolean NOT NULL DEFAULT false,
  canal text CHECK (canal IS NULL OR char_length(canal) <= 120),
  -- Ghost: o texto original nunca é reescrito; o tratamento do organismo fica separado.
  estado text NOT NULL DEFAULT 'RECEBIDO' CHECK (estado = ANY (ARRAY['RECEBIDO','OBSERVADO','EM_INVESTIGACAO','COM_EVIDENCIA','CONSOLIDADO','ARQUIVADO'])),
  tratamento jsonb NOT NULL DEFAULT '{}'::jsonb,
  fontes jsonb NOT NULL DEFAULT '[]'::jsonb,
  publicavel boolean NOT NULL DEFAULT false,
  CHECK (tipo = 'investigar' OR texto IS NOT NULL),
  CHECK (autor_email IS NULL OR contato_ok)
);
COMMENT ON TABLE public.espelho_sinais IS 'Sinais do público nos artigos e na página Escrever. Ressonância não é verdade: estado muda só com evidência, pelo organismo. Texto original preservado; tratamento e fontes à parte.';
CREATE INDEX espelho_sinais_pagina_idx ON public.espelho_sinais (pagina, criado_em DESC);
CREATE INDEX espelho_sinais_estado_idx ON public.espelho_sinais (estado, criado_em);
CREATE INDEX espelho_sinais_publicavel_idx ON public.espelho_sinais (criado_em DESC) WHERE publicavel;

ALTER TABLE public.espelho_sinais ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.espelho_sinais FROM anon, authenticated;
GRANT INSERT (tipo, pagina, texto, autor_nome, autor_email, contato_ok, canal) ON public.espelho_sinais TO anon, authenticated;
CREATE POLICY espelho_sinais_publico_insere ON public.espelho_sinais
  FOR INSERT TO anon, authenticated
  WITH CHECK (estado = 'RECEBIDO' AND publicavel = false AND tratamento = '{}'::jsonb AND fontes = '[]'::jsonb);

-- Telemetria de comportamento (não é evidência de conhecimento). Sem dado pessoal: sessão é um número aleatório do navegador.
CREATE TABLE public.espelho_eventos (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  criado_em timestamptz NOT NULL DEFAULT now(),
  evento text NOT NULL CHECK (evento = ANY (ARRAY['page_view','article_open','article_continue','search','question','opinion','contribution','source_suggestion','correction','investigation_interest','share','conversion'])),
  pagina text NOT NULL CHECK (pagina ~ '^[a-z0-9/_.-]{1,120}$'),
  canal text CHECK (canal IS NULL OR char_length(canal) <= 120),
  sessao text CHECK (sessao IS NULL OR sessao ~ '^[a-z0-9]{8,40}$')
);
COMMENT ON TABLE public.espelho_eventos IS 'Telemetria de comportamento do Espelho. Separada de evidência: popularidade não valida nada.';
CREATE INDEX espelho_eventos_tempo_idx ON public.espelho_eventos (criado_em DESC);
CREATE INDEX espelho_eventos_pagina_idx ON public.espelho_eventos (pagina, evento);
ALTER TABLE public.espelho_eventos ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.espelho_eventos FROM anon, authenticated;
GRANT INSERT (evento, pagina, canal, sessao) ON public.espelho_eventos TO anon, authenticated;
CREATE POLICY espelho_eventos_publico_insere ON public.espelho_eventos FOR INSERT TO anon, authenticated WITH CHECK (true);

-- "O que está ressoando?": só agregados e contribuições que o organismo marcou como publicáveis. Nunca e-mail.
CREATE OR REPLACE FUNCTION public.espelho_ressonancias()
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT jsonb_build_object(
    'gerado_em', now(),
    'por_pagina', coalesce((
      SELECT jsonb_agg(x ORDER BY x.sinais DESC) FROM (
        SELECT s.pagina,
               count(*) AS sinais,
               count(*) FILTER (WHERE s.tipo = 'investigar') AS querem_investigar,
               count(*) FILTER (WHERE s.tipo = 'pergunta') AS perguntas,
               count(*) FILTER (WHERE s.tipo IN ('correcao','evidencia')) AS correcoes_e_evidencias
        FROM public.espelho_sinais s
        WHERE s.criado_em > now() - interval '30 days' AND s.estado <> 'ARQUIVADO'
        GROUP BY s.pagina ORDER BY count(*) DESC LIMIT 12
      ) x), '[]'::jsonb),
    'investigacoes', coalesce((
      SELECT jsonb_agg(jsonb_build_object('pagina', s.pagina, 'estado', s.estado, 'resumo', s.tratamento->>'resumo', 'fontes', s.fontes) ORDER BY s.atualizado_em DESC)
      FROM (SELECT * FROM public.espelho_sinais WHERE estado IN ('EM_INVESTIGACAO','COM_EVIDENCIA','CONSOLIDADO') AND publicavel ORDER BY atualizado_em DESC LIMIT 12) s), '[]'::jsonb),
    'comunidade', coalesce((
      SELECT jsonb_agg(jsonb_build_object('tipo', s.tipo, 'pagina', s.pagina, 'texto', s.texto, 'autor', coalesce(s.autor_nome, 'Anônimo'), 'estado', s.estado, 'em', s.criado_em) ORDER BY s.criado_em DESC)
      FROM (SELECT * FROM public.espelho_sinais WHERE publicavel ORDER BY criado_em DESC LIMIT 20) s), '[]'::jsonb)
  );
$$;
REVOKE ALL ON FUNCTION public.espelho_ressonancias() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.espelho_ressonancias() TO anon, authenticated;
