-- Migração 20260913224137 · 20260913_add_checkpoint_id_coacao
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- ========================================================
-- Adicionar coluna checkpoint_id a coracao_motor_principal
-- Para rastreabilidade completa
-- ========================================================

ALTER TABLE public.coracao_motor_principal
ADD COLUMN checkpoint_id UUID REFERENCES public.fios_checkpoint_universal(id) ON DELETE SET NULL;

-- Índice para performance
CREATE INDEX idx_coacao_checkpoint ON public.coracao_motor_principal(checkpoint_id);

-- Comentário para documentação
COMMENT ON COLUMN public.coracao_motor_principal.checkpoint_id IS 
'FK para Checkpoint que originou este Coração. Rastreabilidade Solução C.';
