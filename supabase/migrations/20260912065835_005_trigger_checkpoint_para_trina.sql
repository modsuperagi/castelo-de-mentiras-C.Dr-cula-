-- Migração 20260912065835 · 005_trigger_checkpoint_para_trina
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- FUNÇÃO: Quando checkpoint chega, cria sessão Trina
CREATE OR REPLACE FUNCTION public.checkpoint_dispara_trina()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.meta_sessões_trina (
    fio_id,
    checkpoint_id,
    tipo,
    status,
    origem_tabela,
    payload,
    created_at
  ) VALUES (
    'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
    NEW.id,
    'CHECKPOINT_AUTOMÁTICO',
    'aguardando_trina',
    NEW.tabela_origem,
    jsonb_build_object(
      'checkpoint_id', NEW.id,
      'acao', NEW.acao,
      'tabela_origem', NEW.tabela_origem,
      'registro_id', NEW.registro_id,
      'timestamp', NEW.timestamp_acao,
      'resultado', NEW.resultado
    ),
    NOW()
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER: Dispara automaticamente
DROP TRIGGER IF EXISTS trg_fio_cria_trina ON public.fios_checkpoint_universal CASCADE;
CREATE TRIGGER trg_fio_cria_trina
AFTER INSERT ON public.fios_checkpoint_universal
FOR EACH ROW EXECUTE FUNCTION public.checkpoint_dispara_trina();

COMMENT ON FUNCTION public.checkpoint_dispara_trina() IS 'AUTOMÁTICO: Cada checkpoint que chega no fio, uma nova sessão Trina nasce.';
