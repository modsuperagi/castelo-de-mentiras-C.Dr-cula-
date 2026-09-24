-- Migração 20260912065858 · 006_views_dashboard_fio_corrigido
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- VIEW 1: Status atual do fio
CREATE OR REPLACE VIEW public.v_fio_status_atual AS
SELECT
  'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::text as fio_id,
  COUNT(*) FILTER (WHERE status = 'pendente') as checkpoints_pendentes,
  COUNT(*) FILTER (WHERE status = 'validado') as checkpoints_validados,
  COUNT(*) FILTER (WHERE status = 'propagado') as checkpoints_propagados,
  COUNT(*) FILTER (WHERE status = 'falhado') as checkpoints_falhados,
  COUNT(*) as total_checkpoints,
  MAX(timestamp_checkpoint) as último_checkpoint
FROM public.fios_checkpoint_universal;

-- VIEW 2: Distribuição por mesa de origem
CREATE OR REPLACE VIEW public.v_fio_por_mesa AS
SELECT
  tabela_origem,
  acao,
  status,
  COUNT(*) as quantidade,
  MAX(timestamp_checkpoint) as último_evento
FROM public.fios_checkpoint_universal
GROUP BY tabela_origem, acao, status
ORDER BY MAX(timestamp_checkpoint) DESC;

-- VIEW 3: Sessões Trina em processamento
CREATE OR REPLACE VIEW public.v_trina_processando AS
SELECT
  id,
  checkpoint_id,
  tipo,
  status,
  origem_tabela,
  created_at,
  AGE(NOW(), created_at) as tempo_processamento
FROM public.meta_sessões_trina
WHERE status NOT IN ('validado', 'propagado', 'rejeitado')
ORDER BY created_at DESC;

-- VIEW 4: Histórico dos últimos 10 checkpoints
CREATE OR REPLACE VIEW public.v_fio_últimos_eventos AS
SELECT
  id,
  acao,
  tabela_origem,
  registro_id,
  status,
  timestamp_checkpoint,
  mantém_propósito,
  existe_evidência,
  qual_impacto,
  responsavel
FROM public.fios_checkpoint_universal
ORDER BY timestamp_checkpoint DESC
LIMIT 10;

-- VIEW 5: Saúde do fio (métricas)
CREATE OR REPLACE VIEW public.v_fio_saúde AS
SELECT
  'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::text as fio_id,
  ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'validado') / NULLIF(COUNT(*), 0), 2) as taxa_validação_pct,
  COUNT(*) FILTER (WHERE status = 'falhado') as erros_total,
  COUNT(DISTINCT tabela_origem) as mesas_ativas,
  ROUND(AVG(EXTRACT(EPOCH FROM (timestamp_checkpoint - timestamp_acao))), 2) as latência_média_segundos
FROM public.fios_checkpoint_universal;
