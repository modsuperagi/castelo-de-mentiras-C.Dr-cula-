-- Migração 20260910010919 · 004d_fix_transportador_campo_v2
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- Soltar trigger e função
DROP TRIGGER IF EXISTS trg_p0_para_coracao ON public.p0_validacao_completa;
DROP FUNCTION IF EXISTS public.transportar_p0_para_coracao();

-- Recriar com campo correto
CREATE OR REPLACE FUNCTION public.transportar_p0_para_coracao()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.p0_pass = TRUE THEN
    INSERT INTO public.coracao_motor_principal (
      checkin_id, flow_id, destinos, 
      motivo_roteamento, estado_circulacao
    ) SELECT
      NEW.checkin_id, 
      c.flow_id,
      ARRAY['trina', 'conhecimento', 'evidencia'],
      'Transportado automaticamente de P0',
      'p0_aprovado'
    FROM public.checkin_recepcion c
    WHERE c.id = NEW.checkin_id
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_p0_para_coracao
AFTER INSERT OR UPDATE ON public.p0_validacao_completa
FOR EACH ROW
EXECUTE FUNCTION public.transportar_p0_para_coracao();
