-- Migração 20260912065812 · 002_trigger_fio_checkpoint_funcao
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- FUNÇÃO MESTRE: Dispara o checkpoint automático
CREATE OR REPLACE FUNCTION public.trigger_fio_checkpoint()
RETURNS TRIGGER AS $$
DECLARE
  v_record_id UUID;
BEGIN
  -- Pega o ID do registro (NEW ou OLD)
  v_record_id := COALESCE(NEW.id, OLD.id, gen_random_uuid());
  
  -- Insere no coração do fio
  INSERT INTO public.fios_checkpoint_universal (
    fio_id,
    acao,
    tabela_origem,
    registro_id,
    timestamp_acao,
    resultado
  ) VALUES (
    'ee46c360-b95b-426e-86c3-2e5d0ccbe916'::uuid,
    TG_OP,
    TG_TABLE_NAME,
    v_record_id,
    NOW(),
    jsonb_build_object(
      'operacao', TG_OP,
      'tabela', TG_TABLE_NAME,
      'trigger_time', NOW()::text,
      'dados_novo', (CASE WHEN NEW IS NOT NULL THEN row_to_json(NEW) ELSE NULL END),
      'dados_antigo', (CASE WHEN OLD IS NOT NULL THEN row_to_json(OLD) ELSE NULL END)
    )
  );
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.trigger_fio_checkpoint() IS 'FUNÇÃO DE PULSO: Cada INSERT/UPDATE/DELETE em qualquer mesa dispara aqui e registra no fio universal.';
