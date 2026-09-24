-- Migração 20260820075451 · create_session_checkpoint_continuity
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

CREATE TABLE IF NOT EXISTS public.sessao_checkpoint (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  flow_id uuid NOT NULL,
  identidade jsonb NOT NULL DEFAULT '{}'::jsonb,
  ponto_retomada text NOT NULL,
  pergunta_aberta text,
  fio_raciocinio text,
  estado jsonb NOT NULL DEFAULT '{}'::jsonb,
  versao bigint NOT NULL DEFAULT 1,
  ativo boolean NOT NULL DEFAULT true,
  criado_em timestamptz NOT NULL DEFAULT now(),
  atualizado_em timestamptz NOT NULL DEFAULT now(),
  UNIQUE(flow_id)
);

CREATE INDEX IF NOT EXISTS idx_sessao_checkpoint_flow_id ON public.sessao_checkpoint(flow_id);
CREATE INDEX IF NOT EXISTS idx_sessao_checkpoint_ativo ON public.sessao_checkpoint(ativo);

CREATE OR REPLACE FUNCTION public.salvar_checkpoint(
  p_flow_id uuid,
  p_identidade jsonb,
  p_ponto_retomada text,
  p_pergunta_aberta text DEFAULT NULL,
  p_fio_raciocinio text DEFAULT NULL,
  p_estado jsonb DEFAULT '{}'::jsonb
) RETURNS public.sessao_checkpoint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE r public.sessao_checkpoint;
BEGIN
  INSERT INTO public.sessao_checkpoint(flow_id, identidade, ponto_retomada, pergunta_aberta, fio_raciocinio, estado, versao, ativo)
  VALUES (p_flow_id, COALESCE(p_identidade,'{}'::jsonb), p_ponto_retomada, p_pergunta_aberta, p_fio_raciocinio, COALESCE(p_estado,'{}'::jsonb), 1, true)
  ON CONFLICT (flow_id) DO UPDATE SET
    identidade = EXCLUDED.identidade,
    ponto_retomada = EXCLUDED.ponto_retomada,
    pergunta_aberta = EXCLUDED.pergunta_aberta,
    fio_raciocinio = EXCLUDED.fio_raciocinio,
    estado = EXCLUDED.estado,
    versao = public.sessao_checkpoint.versao + 1,
    ativo = true,
    atualizado_em = now()
  RETURNING * INTO r;
  RETURN r;
END;
$$;

CREATE OR REPLACE FUNCTION public.buscar_checkpoint(p_flow_id uuid)
RETURNS public.sessao_checkpoint
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT * FROM public.sessao_checkpoint WHERE flow_id = p_flow_id AND ativo = true LIMIT 1;
$$;

REVOKE ALL ON FUNCTION public.salvar_checkpoint(uuid,jsonb,text,text,text,jsonb) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.buscar_checkpoint(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.salvar_checkpoint(uuid,jsonb,text,text,text,jsonb) TO service_role;
GRANT EXECUTE ON FUNCTION public.buscar_checkpoint(uuid) TO service_role;

ALTER TABLE public.sessao_checkpoint ENABLE ROW LEVEL SECURITY;
