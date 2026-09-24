-- Migração 20260918224741 · diafragma_checkpoint_dispara_trina_p0_20260918
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- Diafragma P0 no Fio→Mesa: só cria meta_sessões_trina quando checkin_recepcion com p0_pass=true
-- (ou tabelas de missão explícitas). Demais origens: early return, sem INSERT.
CREATE OR REPLACE FUNCTION public.checkpoint_dispara_trina()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
  v_p0_pass boolean;
  v_allow boolean := false;
BEGIN
  -- A) checkin_recepcion: só se existir check-in com p0_pass=true para registro_id
  IF NEW.tabela_origem = 'checkin_recepcion' THEN
    SELECT c.p0_pass INTO v_p0_pass
    FROM public.checkin_recepcion c
    WHERE c.id = NEW.registro_id
    LIMIT 1;
    IF COALESCE(v_p0_pass, false) = true THEN
      v_allow := true;
    END IF;

  -- A/C missões explícitas Guardião (whitelist mínima; sem inventar métricas)
  ELSIF NEW.tabela_origem IN (
    'sol_missions',
    'sol_tasks'
  ) THEN
    v_allow := true;

  -- B) telemetria / circulação / lab / porta / etc. → NÃO inserir na Mesa
  ELSE
    v_allow := false;
  END IF;

  IF NOT v_allow THEN
    RETURN NEW;
  END IF;

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
      'resultado', NEW.resultado,
      'diafragma', 'p0_checkin_or_mission_whitelist_20260918'
    ),
    NOW()
  );

  RETURN NEW;
END;
$function$;
