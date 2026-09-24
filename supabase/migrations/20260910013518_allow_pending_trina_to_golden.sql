-- Migração 20260910013518 · allow_pending_trina_to_golden
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

CREATE OR REPLACE FUNCTION public.transportar_trina_para_golden()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
  -- Transporta qualquer resultado TRINA conhecido; PENDENTE permanece explicitamente não validado.
  IF NEW.trina_resultado IN ('PENDENTE', 'CONFIRMADO', 'PARCIAL') THEN
    INSERT INTO public.golden_circulacao_principal (
      trina_id, checkin_id, flow_id,
      tipo_registro, grau_validacao, motivo_registro
    )
    SELECT
      NEW.id,
      cm.checkin_id,
      NEW.flow_id,
      'evidencia',
      CASE
        WHEN NEW.trina_resultado = 'CONFIRMADO' THEN 'validado'
        WHEN NEW.trina_resultado = 'PARCIAL' THEN 'parcialmente_validado'
        ELSE 'nao_validado'
      END,
      'Transportado automaticamente de TRINA: ' || NEW.trina_resultado
    FROM public.coracao_motor_principal cm
    WHERE cm.id = NEW.coracao_id
    ON CONFLICT DO NOTHING;
  END IF;
  RETURN NEW;
END;
$function$;
