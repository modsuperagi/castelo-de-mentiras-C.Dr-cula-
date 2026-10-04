-- Autodiagnóstico v2 (Plasma, 04/10/2026): 13ª verificação, anon_alcanca (nível alto).
-- Depois de tirar as portas externas do ar, o Castelo vigia sozinho que o anônimo siga sem alcançar
-- nenhuma tabela ou função do public. Uma nova função criada sem REVOKE (PUBLIC ganha EXECUTE por padrão)
-- aparece como achado novo no retrato seguinte.

CREATE OR REPLACE FUNCTION public.castelo_autodiagnosticar(p_origem text DEFAULT 'manual')
RETURNS jsonb
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_checks     jsonb := '[]'::jsonb;
  v_itens      jsonb;
  v_atual      jsonb;
  v_anterior   jsonb;
  v_novos      jsonb;
  v_resolvidos jsonb;
  v_alertas    integer;
  v_resultado  jsonb;
BEGIN
  IF NOT (public.eh_guardiao()
          OR coalesce(auth.role(), '') = 'service_role'
          OR session_user IN ('postgres', 'supabase_admin')) THEN
    RAISE EXCEPTION 'autodiagnóstico: só o Guardião ou o service_role' USING ERRCODE = '42501';
  END IF;

  -- 1. Tabela do public sem RLS (alto)
  SELECT coalesce(jsonb_agg(c.relname ORDER BY c.relname), '[]') INTO v_itens
  FROM pg_catalog.pg_class c JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public' AND c.relkind IN ('r', 'p') AND NOT c.relrowsecurity;
  v_checks := v_checks || jsonb_build_object('chave', 'tabela_sem_rls', 'nivel', 'alto', 'itens', v_itens);

  -- 2. Política aberta (true) para anon ou public (alto)
  SELECT coalesce(jsonb_agg(p.tablename || '.' || p.policyname ORDER BY 1), '[]') INTO v_itens
  FROM pg_catalog.pg_policies p
  WHERE p.schemaname = 'public' AND p.roles && '{anon,public}'::name[]
    AND (p.qual = 'true' OR p.with_check = 'true');
  v_checks := v_checks || jsonb_build_object('chave', 'politica_aberta_publico', 'nivel', 'alto', 'itens', v_itens);

  -- 3. SECURITY DEFINER no public que o anon executa (alto)
  SELECT coalesce(jsonb_agg(p.proname || '(' || pg_catalog.pg_get_function_identity_arguments(p.oid) || ')' ORDER BY 1), '[]') INTO v_itens
  FROM pg_catalog.pg_proc p JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = 'public' AND p.prosecdef AND pg_catalog.has_function_privilege('anon', p.oid, 'EXECUTE');
  v_checks := v_checks || jsonb_build_object('chave', 'definer_exposta_anon', 'nivel', 'alto', 'itens', v_itens);

  -- 4. Função do public sem search_path fixo (médio)
  SELECT coalesce(jsonb_agg(p.proname ORDER BY 1), '[]') INTO v_itens
  FROM pg_catalog.pg_proc p JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = 'public' AND p.prokind = 'f'
    AND NOT EXISTS (SELECT 1 FROM unnest(coalesce(p.proconfig, '{}')) c WHERE c LIKE 'search_path=%')
    AND NOT EXISTS (SELECT 1 FROM pg_catalog.pg_depend d WHERE d.objid = p.oid AND d.deptype = 'e');
  v_checks := v_checks || jsonb_build_object('chave', 'funcao_sem_search_path', 'nivel', 'medio', 'itens', v_itens);

  -- 5. View do public sem security_invoker que anon ou authenticated leem (médio)
  SELECT coalesce(jsonb_agg(c.relname ORDER BY 1), '[]') INTO v_itens
  FROM pg_catalog.pg_class c JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname = 'public' AND c.relkind = 'v'
    AND NOT coalesce('security_invoker=true' = ANY (c.reloptions) OR 'security_invoker=on' = ANY (c.reloptions), false)
    AND (pg_catalog.has_table_privilege('anon', c.oid, 'SELECT')
         OR pg_catalog.has_table_privilege('authenticated', c.oid, 'SELECT'));
  v_checks := v_checks || jsonb_build_object('chave', 'view_definer_exposta', 'nivel', 'medio', 'itens', v_itens);

  -- 6. Privilégio do anon sem política que o use (defesa em profundidade; info)
  SELECT coalesce(jsonb_agg(t.relname || ':' || t.privs ORDER BY t.relname), '[]') INTO v_itens
  FROM (
    SELECT c.relname, string_agg(x.priv, ',' ORDER BY x.ordem) AS privs
    FROM pg_catalog.pg_class c JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    CROSS JOIN (VALUES (1, 'SELECT'), (2, 'INSERT'), (3, 'UPDATE'), (4, 'DELETE')) AS x(ordem, priv)
    WHERE n.nspname = 'public' AND c.relkind IN ('r', 'p')
      AND pg_catalog.has_table_privilege('anon', c.oid, x.priv)
      AND NOT EXISTS (
        SELECT 1 FROM pg_catalog.pg_policies p
        WHERE p.schemaname = 'public' AND p.tablename = c.relname
          AND p.roles && '{anon,public}'::name[] AND p.cmd IN (x.priv, 'ALL'))
    GROUP BY c.relname
  ) t;
  v_checks := v_checks || jsonb_build_object('chave', 'grant_anon_sem_politica', 'nivel', 'info', 'itens', v_itens);

  -- 7. Política que reavalia eh_guardiao() ou auth.uid() linha a linha (desempenho; info)
  SELECT coalesce(jsonb_agg(p.tablename || '.' || p.policyname ORDER BY 1), '[]') INTO v_itens
  FROM pg_catalog.pg_policies p
  WHERE p.schemaname = 'public'
    AND regexp_replace(coalesce(p.qual, '') || ' ' || coalesce(p.with_check, ''),
                       'SELECT (public\.)?(eh_guardiao|auth\.uid)\(\)', '', 'g')
        ~ '(eh_guardiao|auth\.uid)\(\)';
  v_checks := v_checks || jsonb_build_object('chave', 'politica_sem_initplan', 'nivel', 'info', 'itens', v_itens);

  -- 8. Chave estrangeira sem índice que a cubra (desempenho; info)
  SELECT coalesce(jsonb_agg(cl.relname || '.' || con.conname ORDER BY 1), '[]') INTO v_itens
  FROM pg_catalog.pg_constraint con
  JOIN pg_catalog.pg_class cl ON cl.oid = con.conrelid
  JOIN pg_catalog.pg_namespace n ON n.oid = cl.relnamespace
  WHERE con.contype = 'f' AND n.nspname = 'public'
    AND NOT EXISTS (
      SELECT 1 FROM pg_catalog.pg_index i
      WHERE i.indrelid = con.conrelid
        AND (i.indkey::int2[])[0:array_length(con.conkey, 1) - 1] @> con.conkey
        AND (i.indkey::int2[])[0:array_length(con.conkey, 1) - 1] <@ con.conkey);
  v_checks := v_checks || jsonb_build_object('chave', 'fk_sem_indice', 'nivel', 'info', 'itens', v_itens);

  -- 9. Fila da Mesa Trina (circulação; info)
  BEGIN
    SELECT coalesce(jsonb_agg(to_jsonb(v) ->> 'coracao_id'), '[]') INTO v_itens FROM public.v_trina_pendente v;
  EXCEPTION WHEN OTHERS THEN
    v_itens := jsonb_build_array('erro: ' || SQLERRM);
  END;
  v_checks := v_checks || jsonb_build_object('chave', 'trina_pendente', 'nivel', 'info', 'itens', v_itens);

  -- 10. Pedido entre núcleos parado há mais de 7 dias (médio)
  BEGIN
    SELECT coalesce(jsonb_agg(left(p.id::text, 8) || ' ' || p.de_nucleo || ' → ' || p.para_nucleo ORDER BY p.criado_em), '[]') INTO v_itens
    FROM public.pedidos_entre_nucleos p
    WHERE p.status IN ('aberto', 'em_andamento', 'bloqueado')
      AND coalesce(p.atualizado_em, p.criado_em) < now() - interval '7 days';
  EXCEPTION WHEN OTHERS THEN
    v_itens := jsonb_build_array('erro: ' || SQLERRM);
  END;
  v_checks := v_checks || jsonb_build_object('chave', 'pedido_parado_7d', 'nivel', 'medio', 'itens', v_itens);

  -- 11. Pedidos abertos repetidos: mesmo destino e mesma necessidade (deduplicação P0; info)
  BEGIN
    SELECT coalesce(jsonb_agg(g.para_nucleo || ' · ' || g.necessidade || ' ×' || g.n ORDER BY 1), '[]') INTO v_itens
    FROM (
      SELECT p.para_nucleo, p.necessidade, count(*) AS n
      FROM public.pedidos_entre_nucleos p
      WHERE p.status IN ('aberto', 'em_andamento', 'bloqueado')
      GROUP BY 1, 2 HAVING count(*) > 1
    ) g;
  EXCEPTION WHEN OTHERS THEN
    v_itens := jsonb_build_array('erro: ' || SQLERRM);
  END;
  v_checks := v_checks || jsonb_build_object('chave', 'pedido_duplicado', 'nivel', 'info', 'itens', v_itens);

  -- 12. Rotina do pg_cron que falhou nas últimas 24 horas (alto)
  BEGIN
    EXECUTE $q$
      SELECT coalesce(jsonb_agg(DISTINCT j.jobname), '[]')
      FROM cron.job_run_details d JOIN cron.job j ON j.jobid = d.jobid
      WHERE d.start_time > now() - interval '24 hours' AND d.status = 'failed'
    $q$ INTO v_itens;
  EXCEPTION WHEN OTHERS THEN
    v_itens := '[]'::jsonb;  -- sem acesso ao cron (conta do Guardião): não conta como achado
  END;
  v_checks := v_checks || jsonb_build_object('chave', 'cron_falhou_24h', 'nivel', 'alto', 'itens', v_itens);

  -- 13. Qualquer coisa que o anônimo alcance no public (alto). Portas fechadas em 04/10: deve ficar vazio.
  SELECT coalesce(jsonb_agg(x ORDER BY x), '[]') INTO v_itens FROM (
    SELECT 'tabela:' || c.relname AS x
    FROM pg_catalog.pg_class c JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relkind IN ('r', 'p', 'v', 'm')
      AND (pg_catalog.has_table_privilege('anon', c.oid, 'SELECT') OR pg_catalog.has_table_privilege('anon', c.oid, 'INSERT')
           OR pg_catalog.has_table_privilege('anon', c.oid, 'UPDATE') OR pg_catalog.has_table_privilege('anon', c.oid, 'DELETE'))
    UNION ALL
    SELECT 'funcao:' || p.proname
    FROM pg_catalog.pg_proc p JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public' AND pg_catalog.has_function_privilege('anon', p.oid, 'EXECUTE')
  ) s;
  v_checks := v_checks || jsonb_build_object('chave', 'anon_alcanca', 'nivel', 'alto', 'itens', v_itens);

  -- Quantidade por achado
  SELECT jsonb_agg(c || jsonb_build_object('quantidade', jsonb_array_length(c -> 'itens'))) INTO v_checks
  FROM jsonb_array_elements(v_checks) c;

  -- Conjunto atual de achados ("chave:item") para comparar com o retrato anterior
  SELECT coalesce(jsonb_agg(DISTINCT (c ->> 'chave') || ':' || i), '[]') INTO v_atual
  FROM jsonb_array_elements(v_checks) c, jsonb_array_elements_text(c -> 'itens') i
  WHERE (c ->> 'chave') <> 'trina_pendente';

  SELECT coalesce(jsonb_agg(DISTINCT (c ->> 'chave') || ':' || i), '[]') INTO v_anterior
  FROM (SELECT a.resultado FROM public.castelo_autodiagnostico a ORDER BY a.criado_em DESC LIMIT 1) ult,
       jsonb_array_elements(ult.resultado -> 'achados') c, jsonb_array_elements_text(c -> 'itens') i
  WHERE (c ->> 'chave') <> 'trina_pendente';

  -- No primeiro retrato não há com o que comparar: nada é "novo", tudo é linha de base.
  SELECT coalesce(jsonb_agg(x ORDER BY x), '[]') INTO v_novos
  FROM jsonb_array_elements_text(v_atual) x
  WHERE NOT v_anterior ? x
    AND EXISTS (SELECT 1 FROM public.castelo_autodiagnostico);
  SELECT coalesce(jsonb_agg(x ORDER BY x), '[]') INTO v_resolvidos
  FROM jsonb_array_elements_text(v_anterior) x WHERE NOT v_atual ? x;

  SELECT coalesce(sum((c ->> 'quantidade')::int), 0) INTO v_alertas
  FROM jsonb_array_elements(v_checks) c WHERE c ->> 'nivel' IN ('alto', 'medio');

  v_resultado := jsonb_build_object(
    'versao', 2,
    'em', now(),
    'alertas_alto_medio', v_alertas,
    'achados', v_checks,
    'novos', v_novos,
    'resolvidos', v_resolvidos);

  INSERT INTO public.castelo_autodiagnostico (origem, alertas, novos, resolvidos, resultado)
  VALUES (left(coalesce(p_origem, 'manual'), 60), v_alertas, v_novos, v_resolvidos, v_resultado);

  RETURN v_resultado;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.castelo_autodiagnosticar(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.castelo_autodiagnosticar(text) TO authenticated, service_role;

COMMENT ON FUNCTION public.castelo_autodiagnosticar(text) IS
  'Autodiagnóstico recursivo v2: 13 verificações (segurança, desempenho, circulação; a 13ª, anon_alcanca, vigia as portas fechadas em 04/10), grava o retrato em castelo_autodiagnostico e devolve novos e resolvidos desde o retrato anterior. Rode no início de cada sessão de núcleo e depois de cada migração. pg_cron castelo-autodiagnostico às 06:29 UTC.';
