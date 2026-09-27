-- Reforma do Espelho, Fase 7: "temas em crescimento" no painel público "O que está ressoando?".
-- Só agregados: leitores distintos por página em 7 dias contra os 7 dias anteriores, e quantos leram até o fim.
-- Página com menos de 3 leitores não aparece (ruído e privacidade). Mais lido não quer dizer mais certo.
CREATE OR REPLACE FUNCTION public.espelho_ressonancias()
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT jsonb_build_object(
    'gerado_em', now(),
    'em_alta', coalesce((
      SELECT jsonb_agg(x ORDER BY x.leitores_7d DESC, x.pagina) FROM (
        SELECT e.pagina,
               count(DISTINCT e.sessao) FILTER (WHERE e.evento = 'article_open' AND e.criado_em > now() - interval '7 days') AS leitores_7d,
               count(DISTINCT e.sessao) FILTER (WHERE e.evento = 'article_open' AND e.criado_em <= now() - interval '7 days') AS leitores_7d_antes,
               count(DISTINCT e.sessao) FILTER (WHERE e.evento = 'article_continue' AND e.criado_em > now() - interval '7 days') AS leram_ate_o_fim
        FROM public.espelho_eventos e
        WHERE e.criado_em > now() - interval '14 days' AND e.sessao IS NOT NULL
        GROUP BY e.pagina
        HAVING count(DISTINCT e.sessao) FILTER (WHERE e.evento = 'article_open' AND e.criado_em > now() - interval '7 days') >= 3
        ORDER BY 2 DESC LIMIT 6
      ) x), '[]'::jsonb),
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
COMMENT ON FUNCTION public.espelho_ressonancias() IS 'Painel público "O que está ressoando?": só agregados (em alta, sinais por página) e o que o organismo marcou como publicável. Nunca devolve e-mail. Ressonância não é verdade.';
REVOKE ALL ON FUNCTION public.espelho_ressonancias() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.espelho_ressonancias() TO anon, authenticated;
