-- Espelho dos núcleos (ordem do Guardião, 30/09/2026): o Espelho não é leitura pública.
-- É um link que o Guardião entrega a um núcleo, com manual. A chave vale por núcleo, expira, pode ser revogada
-- e só o hash fica guardado. Nada comercial ou pessoal sai por aqui. Testado antes no projeto auxiliar.
CREATE TABLE IF NOT EXISTS public.espelho_chaves_nucleo (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nucleo text NOT NULL,
  chave_hash text NOT NULL UNIQUE,
  criada_por text NOT NULL,
  criada_em timestamptz NOT NULL DEFAULT now(),
  expira_em timestamptz NOT NULL,
  revogada boolean NOT NULL DEFAULT false,
  usos integer NOT NULL DEFAULT 0,
  ultimo_uso timestamptz
);
ALTER TABLE public.espelho_chaves_nucleo ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.espelho_chaves_nucleo FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON public.espelho_chaves_nucleo TO service_role;
CREATE INDEX IF NOT EXISTS espelho_chaves_nucleo_nucleo_idx ON public.espelho_chaves_nucleo (nucleo);

CREATE OR REPLACE FUNCTION public.espelho_nucleo_gerar(p_nucleo text, p_dias integer DEFAULT 7, p_criada_por text DEFAULT 'Plasma')
RETURNS text LANGUAGE plpgsql SET search_path TO '' AS $f$
DECLARE v_chave text;
BEGIN
  IF coalesce(length(trim(p_nucleo)),0) < 2 THEN RAISE EXCEPTION 'Diga para qual núcleo é o link'; END IF;
  v_chave := encode(extensions.gen_random_bytes(24), 'hex');
  INSERT INTO public.espelho_chaves_nucleo (nucleo, chave_hash, criada_por, expira_em)
  VALUES (trim(p_nucleo), encode(extensions.digest(v_chave, 'sha256'), 'hex'), p_criada_por,
          now() + make_interval(days => greatest(1, least(coalesce(p_dias, 7), 30))));
  RETURN v_chave;
END; $f$;

CREATE OR REPLACE FUNCTION public.espelho_nucleo_revogar(p_nucleo text)
RETURNS integer LANGUAGE sql SET search_path TO '' AS $f$
  WITH r AS (UPDATE public.espelho_chaves_nucleo SET revogada = true
             WHERE lower(nucleo) = lower(trim(p_nucleo)) AND NOT revogada RETURNING 1)
  SELECT count(*)::int FROM r;
$f$;

CREATE OR REPLACE FUNCTION public.espelho_nucleo_ler(p_chave text)
RETURNS jsonb LANGUAGE plpgsql SET search_path TO '' AS $f$
DECLARE v_k public.espelho_chaves_nucleo%ROWTYPE;
BEGIN
  SELECT * INTO v_k FROM public.espelho_chaves_nucleo
  WHERE chave_hash = encode(extensions.digest(coalesce(p_chave,''), 'sha256'), 'hex')
    AND NOT revogada AND expira_em > now();
  IF NOT FOUND THEN RAISE EXCEPTION 'link invalido ou expirado' USING errcode = 'P0002'; END IF;
  UPDATE public.espelho_chaves_nucleo SET usos = usos + 1, ultimo_uso = now() WHERE id = v_k.id;
  RETURN jsonb_build_object(
    'nucleo', v_k.nucleo, 'gerado_em', now(), 'link_expira_em', v_k.expira_em,
    'manual', (SELECT m.conteudo FROM public.evo_memorias m WHERE m.chave_dedupe = 'ESPELHO/MANUAL-NUCLEOS'),
    'pedidos_abertos', coalesce((SELECT jsonb_agg(jsonb_build_object('id', p.id, 'de', p.de_nucleo, 'para', p.para_nucleo,
        'pedido', left(p.pedido, 600), 'retorno_esperado', p.retorno_esperado, 'status', p.status, 'desde', p.criado_em)
        ORDER BY p.criado_em DESC)
      FROM public.pedidos_entre_nucleos p WHERE p.status IN ('aberto','em_andamento')), '[]'::jsonb),
    'missoes_abertas', coalesce((SELECT jsonb_agg(jsonb_build_object('id', e.id, 'titulo', e.titulo, 'objetivo', e.conteudo,
        'criterio', e.metadata->>'criterio_conclusao', 'aberta_por', e.metadata->>'aberta_por', 'desde', e.criado_em,
        'sessao', (SELECT s.id FROM public."meta_sessões_trina" s WHERE s.payload->>'registro_id' = e.id::text LIMIT 1))
        ORDER BY e.criado_em DESC)
      FROM public.meta_lab_entries e WHERE e.colecao = 'MISSOES_TRINA' AND e.estado = 'em análise'), '[]'::jsonb),
    'aprendizados', coalesce((SELECT jsonb_agg(jsonb_build_object('origem', a.origem, 'titulo', a.titulo,
        'conteudo', left(a.conteudo, 500), 'grau', a.grau, 'em', a.em))
      FROM public.castelo_aprendizados(NULL, 10) a), '[]'::jsonb),
    'travessias_recentes', coalesce((SELECT jsonb_agg(x ORDER BY x->>'em' DESC) FROM (
        SELECT jsonb_build_object('em', t.criado_em, 'identidade', t.identidade, 'nucleo', t.nucleo, 'selo', t.selo,
          'determinacao', left(t.determinacao, 400)) x
        FROM public.evo_porta_entrada t ORDER BY t.criado_em DESC LIMIT 12) y), '[]'::jsonb),
    'mesa', jsonb_build_object(
      'missoes_em_andamento', (SELECT count(*) FROM public."meta_sessões_trina" s WHERE coalesce(s.payload->>'missao','false') = 'true' AND s.status IN ('aguardando_trina','em_processamento')),
      'pensamentos_na_fila', (SELECT count(*) FROM public."meta_sessões_trina" s WHERE coalesce(s.payload->>'missao','false') <> 'true' AND s.status IN ('aguardando_trina','em_processamento')))
  );
END; $f$;

REVOKE ALL ON FUNCTION public.espelho_nucleo_gerar(text,integer,text), public.espelho_nucleo_revogar(text),
  public.espelho_nucleo_ler(text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.espelho_nucleo_gerar(text,integer,text), public.espelho_nucleo_revogar(text),
  public.espelho_nucleo_ler(text) TO service_role;
