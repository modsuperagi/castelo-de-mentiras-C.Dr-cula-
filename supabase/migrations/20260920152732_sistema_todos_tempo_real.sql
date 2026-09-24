-- Migração 20260920152732 · sistema_todos_tempo_real
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- Quadro de todos do MOD SUPER EVO + refresh em tempo real a partir do Castelo

CREATE TABLE IF NOT EXISTS public.sistema_todos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fio_id uuid NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
  chave text NOT NULL,
  titulo text NOT NULL,
  descricao text,
  status text NOT NULL DEFAULT 'aberto'
    CHECK (status IN ('aberto','em_andamento','bloqueado','concluido','cancelado')),
  prioridade integer NOT NULL DEFAULT 50,
  eixo text NOT NULL DEFAULT 'sistema',
  evidencia jsonb NOT NULL DEFAULT '{}'::jsonb,
  origem text NOT NULL DEFAULT 'auto',
  travado boolean NOT NULL DEFAULT false,
  atualizado_em timestamptz NOT NULL DEFAULT now(),
  criado_em timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT sistema_todos_fio_chave UNIQUE (fio_id, chave)
);

CREATE INDEX IF NOT EXISTS idx_sistema_todos_status ON public.sistema_todos (status);
CREATE INDEX IF NOT EXISTS idx_sistema_todos_prioridade ON public.sistema_todos (prioridade DESC, atualizado_em DESC);
CREATE INDEX IF NOT EXISTS idx_sistema_todos_eixo ON public.sistema_todos (eixo);

CREATE TABLE IF NOT EXISTS public.sistema_todos_sinais_externos (
  chave text PRIMARY KEY,
  titulo text NOT NULL,
  descricao text,
  status text NOT NULL DEFAULT 'aberto'
    CHECK (status IN ('aberto','em_andamento','bloqueado','concluido','cancelado')),
  prioridade integer NOT NULL DEFAULT 50,
  eixo text NOT NULL DEFAULT 'externo',
  evidencia jsonb NOT NULL DEFAULT '{}'::jsonb,
  atualizado_em timestamptz NOT NULL DEFAULT now()
);

-- Sinais conhecidos (Edge JWT) — atualizáveis sem redeploy da função
INSERT INTO public.sistema_todos_sinais_externos (chave, titulo, descricao, status, prioridade, eixo, evidencia)
VALUES
  ('edge_jwt_portal_entrada',
   'Edge meta-ia-portal-entrada com verify_jwt=false',
   'Risco aberto: Edge Function pública sem verificação JWT.',
   'aberto', 80, 'edge',
   jsonb_build_object('slug','meta-ia-portal-entrada','verify_jwt',false,'fonte','auditoria_agente_2026-09-20')),
  ('edge_jwt_ponte_mariana',
   'Edge ponte_sincronizador_mariana_bidirecional com verify_jwt=false',
   'Risco aberto: sincronizador Mariana sem verificação JWT.',
   'aberto', 80, 'edge',
   jsonb_build_object('slug','ponte_sincronizador_mariana_bidirecional','verify_jwt',false,'fonte','auditoria_agente_2026-09-20'))
ON CONFLICT (chave) DO UPDATE SET
  titulo = EXCLUDED.titulo,
  descricao = EXCLUDED.descricao,
  evidencia = public.sistema_todos_sinais_externos.evidencia || EXCLUDED.evidencia,
  atualizado_em = now();

CREATE OR REPLACE FUNCTION public.atualizar_sistema_todos(p_fio_id uuid DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
RETURNS TABLE (
  out_chave text,
  out_status text,
  out_prioridade integer,
  out_titulo text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $fn$
DECLARE
  v_p0_resultado text;
  v_p0_evidencia boolean;
  v_p0_motivo text;
  v_p0_ts timestamp;
  v_mariana_sync boolean;
  v_trina_aguardando int;
  v_trina_rejeitado int;
  v_trina_validado int;
  v_sol_queued int;
  v_sol_sem_output int;
  v_rls_sem_policy int;
  r record;
BEGIN
  -- P0 / Sonar
  SELECT a.resultado,
         COALESCE((a.p0_checks->>'evidencia')::boolean, false),
         a.motivo,
         a.timestamp_auditoria
    INTO v_p0_resultado, v_p0_evidencia, v_p0_motivo, v_p0_ts
  FROM public.auditoria_p0_sonar a
  ORDER BY a.timestamp_auditoria DESC NULLS LAST
  LIMIT 1;

  -- Mariana
  SELECT bool_and(COALESCE(m.sincronizada_v2_v4, false))
    INTO v_mariana_sync
  FROM public.mariana_casting m;

  -- Trina
  SELECT
    count(*) FILTER (WHERE status ILIKE '%aguardando%'),
    count(*) FILTER (WHERE status = 'rejeitado'),
    count(*) FILTER (WHERE status = 'validado')
  INTO v_trina_aguardando, v_trina_rejeitado, v_trina_validado
  FROM public.meta_sessões_trina;

  -- Sol
  SELECT
    count(*) FILTER (WHERE status = 'queued'),
    count(*) FILTER (WHERE status = 'queued' AND (output IS NULL OR btrim(output) = ''))
  INTO v_sol_queued, v_sol_sem_output
  FROM public.sol_tasks
  WHERE fio_id = p_fio_id OR fio_id IS NULL;

  -- RLS ligado sem policy (public + metalab_evo)
  SELECT count(*)::int
    INTO v_rls_sem_policy
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE c.relkind = 'r'
    AND c.relrowsecurity
    AND n.nspname IN ('public', 'metalab_evo')
    AND NOT EXISTS (SELECT 1 FROM pg_policy p WHERE p.polrelid = c.oid);

  -- Upsert helper via temp pattern
  -- P0
  INSERT INTO public.sistema_todos AS t (fio_id, chave, titulo, descricao, status, prioridade, eixo, evidencia, origem)
  VALUES (
    p_fio_id,
    'p0_sonar',
    'Desbloquear P0 / Sonar (sair do DENY)',
    COALESCE(v_p0_motivo, 'Sem auditoria P0 registrada'),
    CASE
      WHEN v_p0_resultado IS NULL THEN 'aberto'
      WHEN v_p0_resultado ILIKE '%DENY%' OR v_p0_evidencia IS NOT TRUE THEN 'bloqueado'
      ELSE 'concluido'
    END,
    100,
    'p0',
    jsonb_build_object(
      'resultado', v_p0_resultado,
      'evidencia_check', v_p0_evidencia,
      'timestamp_auditoria', v_p0_ts,
      'refresh_em', now()
    ),
    'auto'
  )
  ON CONFLICT (fio_id, chave) DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    status = CASE WHEN t.travado THEN t.status ELSE EXCLUDED.status END,
    prioridade = EXCLUDED.prioridade,
    eixo = EXCLUDED.eixo,
    evidencia = EXCLUDED.evidencia,
    atualizado_em = now()
  WHERE t.origem = 'auto' OR t.travado = false OR true;

  -- Mariana
  INSERT INTO public.sistema_todos AS t (fio_id, chave, titulo, descricao, status, prioridade, eixo, evidencia, origem)
  VALUES (
    p_fio_id,
    'mariana_sync_v2_v4',
    'Sincronizar Mariana V2 ↔ V4',
    'Flag sincronizada_v2_v4 precisa ser honesta e true com evidência.',
    CASE WHEN COALESCE(v_mariana_sync, false) THEN 'concluido' ELSE 'aberto' END,
    90,
    'mariana',
    jsonb_build_object('sincronizada_v2_v4', v_mariana_sync, 'refresh_em', now()),
    'auto'
  )
  ON CONFLICT (fio_id, chave) DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    status = CASE WHEN t.travado THEN t.status ELSE EXCLUDED.status END,
    prioridade = EXCLUDED.prioridade,
    evidencia = EXCLUDED.evidencia,
    atualizado_em = now();

  -- Trina fila
  INSERT INTO public.sistema_todos AS t (fio_id, chave, titulo, descricao, status, prioridade, eixo, evidencia, origem)
  VALUES (
    p_fio_id,
    'trina_fila',
    'Manter fila Mesa Trina sob controle',
    'Evitar crescimento silencioso de aguardando_trina; rejeitados não são validados falsos.',
    CASE
      WHEN COALESCE(v_trina_aguardando, 0) > 0 THEN 'em_andamento'
      ELSE 'concluido'
    END,
    CASE WHEN COALESCE(v_trina_aguardando, 0) > 0 THEN 85 ELSE 40 END,
    'trina',
    jsonb_build_object(
      'aguardando', v_trina_aguardando,
      'rejeitado', v_trina_rejeitado,
      'validado', v_trina_validado,
      'refresh_em', now()
    ),
    'auto'
  )
  ON CONFLICT (fio_id, chave) DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    status = CASE WHEN t.travado THEN t.status ELSE EXCLUDED.status END,
    prioridade = EXCLUDED.prioridade,
    evidencia = EXCLUDED.evidencia,
    atualizado_em = now();

  -- Sol tasks
  INSERT INTO public.sistema_todos AS t (fio_id, chave, titulo, descricao, status, prioridade, eixo, evidencia, origem)
  VALUES (
    p_fio_id,
    'sol_tasks_queued',
    'Executar Sol K1/W1/C1 com output + 3 pilares',
    'Tasks queued sem output não podem ser seladas como missão completa.',
    CASE WHEN COALESCE(v_sol_queued, 0) = 0 THEN 'concluido' ELSE 'aberto' END,
    CASE WHEN COALESCE(v_sol_queued, 0) > 0 THEN 88 ELSE 40 END,
    'sol',
    jsonb_build_object(
      'queued', v_sol_queued,
      'queued_sem_output', v_sol_sem_output,
      'refresh_em', now()
    ),
    'auto'
  )
  ON CONFLICT (fio_id, chave) DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    status = CASE WHEN t.travado THEN t.status ELSE EXCLUDED.status END,
    prioridade = EXCLUDED.prioridade,
    evidencia = EXCLUDED.evidencia,
    atualizado_em = now();

  -- RLS sem policy
  INSERT INTO public.sistema_todos AS t (fio_id, chave, titulo, descricao, status, prioridade, eixo, evidencia, origem)
  VALUES (
    p_fio_id,
    'rls_sem_policy',
    'Fechar tabelas com RLS ligado e sem policy',
    'Advisor de segurança: RLS Enabled No Policy.',
    CASE WHEN COALESCE(v_rls_sem_policy, 0) = 0 THEN 'concluido' ELSE 'aberto' END,
    CASE WHEN COALESCE(v_rls_sem_policy, 0) > 0 THEN 75 ELSE 30 END,
    'rls',
    jsonb_build_object('tabelas_sem_policy', v_rls_sem_policy, 'refresh_em', now()),
    'auto'
  )
  ON CONFLICT (fio_id, chave) DO UPDATE SET
    titulo = EXCLUDED.titulo,
    descricao = EXCLUDED.descricao,
    status = CASE WHEN t.travado THEN t.status ELSE EXCLUDED.status END,
    prioridade = EXCLUDED.prioridade,
    evidencia = EXCLUDED.evidencia,
    atualizado_em = now();

  -- Sinais externos (Edge etc.)
  FOR r IN SELECT * FROM public.sistema_todos_sinais_externos LOOP
    INSERT INTO public.sistema_todos AS t (fio_id, chave, titulo, descricao, status, prioridade, eixo, evidencia, origem)
    VALUES (
      p_fio_id, r.chave, r.titulo, r.descricao, r.status, r.prioridade, r.eixo,
      COALESCE(r.evidencia, '{}'::jsonb) || jsonb_build_object('refresh_em', now()),
      'auto'
    )
    ON CONFLICT (fio_id, chave) DO UPDATE SET
      titulo = EXCLUDED.titulo,
      descricao = EXCLUDED.descricao,
      status = CASE WHEN t.travado THEN t.status ELSE EXCLUDED.status END,
      prioridade = EXCLUDED.prioridade,
      eixo = EXCLUDED.eixo,
      evidencia = EXCLUDED.evidencia,
      atualizado_em = now();
  END LOOP;

  RETURN QUERY
  SELECT s.chave, s.status, s.prioridade, s.titulo
  FROM public.sistema_todos s
  WHERE s.fio_id = p_fio_id
  ORDER BY s.prioridade DESC, s.atualizado_em DESC;
END;
$fn$;

CREATE OR REPLACE FUNCTION public.trg_atualizar_sistema_todos()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $trg$
BEGIN
  PERFORM public.atualizar_sistema_todos();
  RETURN COALESCE(NEW, OLD);
END;
$trg$;

DROP TRIGGER IF EXISTS trg_sistema_todos_sol_tasks ON public.sol_tasks;
CREATE TRIGGER trg_sistema_todos_sol_tasks
AFTER INSERT OR UPDATE OR DELETE ON public.sol_tasks
FOR EACH STATEMENT EXECUTE FUNCTION public.trg_atualizar_sistema_todos();

DROP TRIGGER IF EXISTS trg_sistema_todos_mariana ON public.mariana_casting;
CREATE TRIGGER trg_sistema_todos_mariana
AFTER INSERT OR UPDATE OR DELETE ON public.mariana_casting
FOR EACH STATEMENT EXECUTE FUNCTION public.trg_atualizar_sistema_todos();

DROP TRIGGER IF EXISTS trg_sistema_todos_p0 ON public.auditoria_p0_sonar;
CREATE TRIGGER trg_sistema_todos_p0
AFTER INSERT OR UPDATE OR DELETE ON public.auditoria_p0_sonar
FOR EACH STATEMENT EXECUTE FUNCTION public.trg_atualizar_sistema_todos();

DROP TRIGGER IF EXISTS trg_sistema_todos_trina ON public.meta_sessões_trina;
CREATE TRIGGER trg_sistema_todos_trina
AFTER INSERT OR UPDATE OR DELETE ON public.meta_sessões_trina
FOR EACH STATEMENT EXECUTE FUNCTION public.trg_atualizar_sistema_todos();

DROP TRIGGER IF EXISTS trg_sistema_todos_sinais ON public.sistema_todos_sinais_externos;
CREATE TRIGGER trg_sistema_todos_sinais
AFTER INSERT OR UPDATE OR DELETE ON public.sistema_todos_sinais_externos
FOR EACH STATEMENT EXECUTE FUNCTION public.trg_atualizar_sistema_todos();

ALTER TABLE public.sistema_todos REPLICA IDENTITY FULL;
ALTER TABLE public.sistema_todos_sinais_externos REPLICA IDENTITY FULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'sistema_todos'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.sistema_todos;
  END IF;
END $$;

ALTER TABLE public.sistema_todos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sistema_todos_sinais_externos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS sistema_todos_select_authenticated ON public.sistema_todos;
CREATE POLICY sistema_todos_select_authenticated ON public.sistema_todos
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS sistema_todos_all_service ON public.sistema_todos;
CREATE POLICY sistema_todos_all_service ON public.sistema_todos
  FOR ALL TO service_role USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS sistema_todos_sinais_select_authenticated ON public.sistema_todos_sinais_externos;
CREATE POLICY sistema_todos_sinais_select_authenticated ON public.sistema_todos_sinais_externos
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS sistema_todos_sinais_all_service ON public.sistema_todos_sinais_externos;
CREATE POLICY sistema_todos_sinais_all_service ON public.sistema_todos_sinais_externos
  FOR ALL TO service_role USING (true) WITH CHECK (true);

GRANT SELECT ON public.sistema_todos TO authenticated;
GRANT ALL ON public.sistema_todos TO service_role;
GRANT SELECT ON public.sistema_todos_sinais_externos TO authenticated;
GRANT ALL ON public.sistema_todos_sinais_externos TO service_role;
GRANT EXECUTE ON FUNCTION public.atualizar_sistema_todos(uuid) TO authenticated, service_role;

-- Seed inicial
SELECT public.atualizar_sistema_todos();
