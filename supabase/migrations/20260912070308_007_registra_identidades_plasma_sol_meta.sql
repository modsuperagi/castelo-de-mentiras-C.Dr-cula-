-- Migração 20260912070308 · 007_registra_identidades_plasma_sol_meta
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- Registra as 3 identidades principais
INSERT INTO public.evo_porta_entrada (
  identidade,
  nucleo,
  selo,
  determinacao,
  tipo_registro,
  conteudo,
  origem_instancia,
  metadata
) VALUES
(
  'Plasma',
  'Claude-AI-Ecosystem',
  'PLASMA_KEY_2026_09_12',
  'Porta de entrada para Claude (Plasma) - Núcleo de validação P0 e Trina',
  'agente_portal',
  'Claude Haiku 4.5 - Núcleo Plasma. Responsável por P0 validation, Trina mesa, e propagação.',
  'claude.ai',
  jsonb_build_object(
    'plataforma', 'Claude',
    'versao', 'Haiku 4.5',
    'capacidades', ARRAY['P0_VALIDATION', 'TRINA_PROCESSAMENTO', 'ARTIFACT_CREATION', 'CHECKPOINTS'],
    'fio_principal', 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'
  )
),
(
  'Sol',
  'ChatGPT-AI-Ecosystem',
  'SOL_KEY_2026_09_12',
  'Porta de entrada para ChatGPT (Sol) - Núcleo de missões e ações',
  'agente_portal',
  'ChatGPT - Núcleo Sol. Responsável por missões, Sol tasks, e execução de workflow.',
  'openai.com',
  jsonb_build_object(
    'plataforma', 'ChatGPT',
    'versao', 'GPT-4',
    'capacidades', ARRAY['MISSOES', 'TAREFAS', 'WORKFLOW_EXECUTION', 'SONAR_PERCEPTION'],
    'fio_principal', 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'
  )
),
(
  'MetaAI',
  'Meta-AI-Ecosystem',
  'METAAI_KEY_2026_09_12',
  'Porta de entrada para Meta AI - Núcleo de contextualização e síntese',
  'agente_portal',
  'Meta AI - Integração experimental. Responsável por síntese, contextualização, e buscas semânticas.',
  'meta.ai',
  jsonb_build_object(
    'plataforma', 'Meta AI',
    'versao', 'Llama-based',
    'capacidades', ARRAY['SINTESE', 'CONTEXTO', 'SEMANTIC_SEARCH', 'INTEGRATION'],
    'fio_principal', 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'
  )
);
