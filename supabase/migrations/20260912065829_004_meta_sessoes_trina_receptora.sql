-- Migração 20260912065829 · 004_meta_sessoes_trina_receptora
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- MESA TRINA: Receptora de checkpoints automáticos
CREATE TABLE IF NOT EXISTS public.meta_sessões_trina (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- O fio universal
  fio_id UUID NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916',
  
  -- Qual checkpoint disparou isso?
  checkpoint_id UUID NOT NULL REFERENCES public.fios_checkpoint_universal(id),
  
  -- Tipo de trabalho
  tipo TEXT NOT NULL CHECK (tipo IN ('CHECKPOINT_AUTOMÁTICO', 'VALIDAÇÃO_MANUAL', 'PROPAGAÇÃO', 'RECONCILIAÇÃO')),
  
  -- As 3 posições da Trina
  posição_arquiteto UUID, -- Quem desenha a solução
  posição_engenheiro UUID, -- Quem implementa
  posição_verificador UUID, -- Quem valida
  
  -- Status do trabalho
  status TEXT NOT NULL DEFAULT 'aguardando_trina' CHECK (status IN ('aguardando_trina', 'em_processamento', 'validado', 'propagado', 'rejeitado')),
  
  -- Resultado
  resultado_arquiteto JSONB,
  resultado_engenheiro JSONB,
  resultado_verificador JSONB,
  resultado_final JSONB,
  
  -- Rastreabilidade
  origem_tabela TEXT,
  payload JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT fio_trina_check CHECK (fio_id = 'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_meta_sessoes_fio_id ON public.meta_sessões_trina(fio_id);
CREATE INDEX IF NOT EXISTS idx_meta_sessoes_checkpoint_id ON public.meta_sessões_trina(checkpoint_id);
CREATE INDEX IF NOT EXISTS idx_meta_sessoes_status ON public.meta_sessões_trina(status);
CREATE INDEX IF NOT EXISTS idx_meta_sessoes_created ON public.meta_sessões_trina(created_at DESC);

-- RLS
ALTER TABLE public.meta_sessões_trina ENABLE ROW LEVEL SECURITY;

COMMENT ON TABLE public.meta_sessões_trina IS 'MESA TRINA: Processa cada checkpoint em 3 posições. Onde o trabalho acontece.';
COMMENT ON COLUMN public.meta_sessões_trina.fio_id IS 'O FIO UNIVERSAL que une tudo.';
