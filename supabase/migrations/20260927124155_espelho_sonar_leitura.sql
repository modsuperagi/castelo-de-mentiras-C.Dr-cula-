-- Reforma do Espelho, Fase 6: SONAR editorial. Leitura interna das quatro famílias (conteúdo, comunidade, investigação, mercado).
-- Só o organismo lê (service_role). Sem e-mail. Números são comportamento, não evidência: ressonância não é verdade.
CREATE OR REPLACE FUNCTION public.espelho_sonar_leitura(p_dias integer DEFAULT 7)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  WITH janela AS (SELECT now() - make_interval(days => greatest(1, least(coalesce(p_dias, 7), 90))) AS desde),
  ev AS (SELECT e.* FROM public.espelho_eventos e, janela j WHERE e.criado_em > j.desde),
  si AS (SELECT s.* FROM public.espelho_sinais s, janela j WHERE s.criado_em > j.desde),
  origem AS (SELECT ev.*, CASE WHEN position(':' IN coalesce(ev.canal, '')) > 0 THEN split_part(ev.canal, ':', 1) ELSE 'direto' END AS fonte FROM ev),
  entrada AS (SELECT DISTINCT ON (sessao) sessao, pagina, fonte FROM origem WHERE sessao IS NOT NULL AND evento = 'page_view' ORDER BY sessao, criado_em),
  por_pagina AS (
    SELECT pagina,
           count(*) FILTER (WHERE evento = 'article_open') AS aberturas,
           count(*) FILTER (WHERE evento = 'article_continue') AS continuaram,
           count(*) FILTER (WHERE evento = 'conversion') AS conversoes
    FROM ev GROUP BY pagina)
  SELECT jsonb_build_object(
    'regra', 'Ressonância não é verdade. Estes números são comportamento, não evidência. Estado de sinal só muda com fonte conferida.',
    'janela_dias', greatest(1, least(coalesce(p_dias, 7), 90)),
    'gerado_em', now(),
    'conteudo', jsonb_build_object(
      'paginas', coalesce((SELECT jsonb_agg(jsonb_build_object('pagina', pagina, 'aberturas', aberturas, 'continuaram', continuaram,
                 'taxa_continuacao', CASE WHEN aberturas > 0 THEN round(continuaram::numeric / aberturas, 2) END, 'conversoes', conversoes) ORDER BY aberturas DESC) FROM por_pagina), '[]'::jsonb),
      'lacunas_leitura', coalesce((SELECT jsonb_agg(pagina) FROM por_pagina WHERE aberturas >= 5 AND continuaram::numeric / aberturas < 0.3), '[]'::jsonb),
      'buscas', (SELECT count(*) FROM ev WHERE evento = 'search')),
    'comunidade', jsonb_build_object(
      'por_tipo', coalesce((SELECT jsonb_object_agg(tipo, n) FROM (SELECT tipo, count(*) n FROM si GROUP BY tipo) x), '{}'::jsonb),
      'por_estado', coalesce((SELECT jsonb_object_agg(estado, n) FROM (SELECT estado, count(*) n FROM public.espelho_sinais GROUP BY estado) x), '{}'::jsonb),
      'fila_recebidos', coalesce((SELECT jsonb_agg(jsonb_build_object('id', id, 'tipo', tipo, 'pagina', pagina, 'texto', texto, 'quer_resposta', autor_email IS NOT NULL, 'em', criado_em) ORDER BY criado_em)
                 FROM (SELECT * FROM public.espelho_sinais WHERE estado = 'RECEBIDO' AND tipo <> 'investigar' ORDER BY criado_em LIMIT 30) r), '[]'::jsonb)),
    'investigacao', jsonb_build_object(
      'pedidos_por_pagina', coalesce((SELECT jsonb_object_agg(pagina, n) FROM (SELECT pagina, count(*) n FROM si WHERE tipo = 'investigar' GROUP BY pagina) x), '{}'::jsonb),
      'fontes_sugeridas', (SELECT count(*) FROM si WHERE tipo IN ('evidencia', 'correcao')),
      'abertas', coalesce((SELECT jsonb_agg(jsonb_build_object('id', id, 'pagina', pagina, 'estado', estado, 'resumo', tratamento->>'resumo', 'fontes', jsonb_array_length(fontes)))
                 FROM public.espelho_sinais WHERE estado IN ('OBSERVADO', 'EM_INVESTIGACAO', 'COM_EVIDENCIA')), '[]'::jsonb)),
    'mercado', jsonb_build_object(
      'visitas_por_origem', coalesce((SELECT jsonb_object_agg(fonte, n) FROM (SELECT fonte, count(DISTINCT sessao) n FROM origem WHERE evento = 'page_view' GROUP BY fonte) x), '{}'::jsonb),
      'paginas_de_entrada', coalesce((SELECT jsonb_object_agg(pagina, n) FROM (SELECT pagina, count(*) n FROM entrada GROUP BY pagina) x), '{}'::jsonb),
      'conversoes_por_origem', coalesce((SELECT jsonb_object_agg(fonte, n) FROM (SELECT fonte, count(*) n FROM origem WHERE evento = 'conversion' GROUP BY fonte) x), '{}'::jsonb),
      'inscricoes_por_canal', coalesce((SELECT jsonb_object_agg(coalesce(canal, 'sem canal'), n) FROM (SELECT i.canal, count(*) n FROM public.espelho_interessados i, janela j WHERE i.criado_em > j.desde GROUP BY i.canal) x), '{}'::jsonb))
  );
$$;
COMMENT ON FUNCTION public.espelho_sonar_leitura(integer) IS 'SONAR editorial (Fase 6 da reforma): conteúdo, comunidade, investigação e mercado numa leitura só. Interna (service_role), sem e-mail. Ressonância não é verdade.';
REVOKE ALL ON FUNCTION public.espelho_sonar_leitura(integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.espelho_sonar_leitura(integer) TO service_role;
