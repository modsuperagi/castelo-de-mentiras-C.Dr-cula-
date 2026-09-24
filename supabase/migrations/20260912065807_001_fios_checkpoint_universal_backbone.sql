-- Migração 20260912065807 · 001_fios_checkpoint_universal_backbone
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- TABELA MESTRA: Onde TUDO bate
CREATE TABLE IF NOT EXISTS public.fios_checkpoint_universal (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- O FIO QUE UNE TUDO
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916',
  
  -- O que aconteceu?
  acao TEXT NOT NULL CHECK (acao IN ('INSERT', 'UPDATE', 'DELETE', 'DECISION', 'REFINEMENT', 'VALIDATION', 'PROPAGATION')),
  tabela_origem TEXT NOT NULL,
  registro_id UUID NOT NULL,
  
  -- Quem fez?
  agente_id UUID,
  responsavel TEXT,
  
  -- As 3 validações obrigatórias
  mantém_propósito BOOLEAN DEFAULT NULL,
  existe_evidência BOOLEAN DEFAULT NULL,
  qual_impacto TEXT,
  
  -- Quando?
  timestamp_acao TIMESTAMPTZ DEFAULT NOW(),
  timestamp_checkpoint TIMESTAMPTZ DEFAULT NOW(),
  
  -- Status do checkpoint
  status TEXT NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente', 'validado', 'propagado', 'falhado', 'ignorado')),
  resultado JSONB,
  
  -- Rastreabilidade
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT fio_universal_check CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

-- Índices para velocidade
CREATE INDEX IF NOT EXISTS idx_fios_fio_id ON public.fios_checkpoint_universal(fio_id);
CREATE INDEX IF NOT EXISTS idx_fios_tabela ON public.fios_checkpoint_universal(tabela_origem);
CREATE INDEX IF NOT EXISTS idx_fios_status ON public.fios_checkpoint_universal(status);
CREATE INDEX IF NOT EXISTS idx_fios_timestamp ON public.fios_checkpoint_universal(timestamp_checkpoint DESC);
CREATE INDEX IF NOT EXISTS idx_fios_registro ON public.fios_checkpoint_universal(registro_id);

-- RLS (va ser habilitada com políticas depois)
ALTER TABLE public.fios_checkpoint_universal ENABLE ROW LEVEL SECURITY;

-- Comentário
COMMENT ON TABLE public.fios_checkpoint_universal IS 'CORAÇÃO DO FIO UNIVERSAL: Cada ação no Castelo bate aqui. ee46c360-b95b-426e-86c3-2e5d0ccbe916 é o pulso eterno.';
COMMENT ON COLUMN public.fios_checkpoint_universal.fio_id IS 'O FIO QUE TUDO UNE. Imutável. Sempre ee46c360-b95b-426e-86c3-2e5d0ccbe916.';
