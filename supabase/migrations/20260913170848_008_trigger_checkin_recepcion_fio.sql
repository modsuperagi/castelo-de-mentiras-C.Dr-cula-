-- Migração 20260913170848 · 008_trigger_checkin_recepcion_fio
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- TRIGGER: Checkin dispara checkpoint no fio
DROP TRIGGER IF EXISTS trg_checkin_recepcion_fio ON public.checkin_recepcion CASCADE;
CREATE TRIGGER trg_checkin_recepcion_fio
AFTER INSERT OR UPDATE OR DELETE ON public.checkin_recepcion
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();

-- TRIGGER: Porta entrada também dispara
DROP TRIGGER IF EXISTS trg_evo_porta_entrada_fio ON public.evo_porta_entrada CASCADE;
CREATE TRIGGER trg_evo_porta_entrada_fio
AFTER INSERT OR UPDATE OR DELETE ON public.evo_porta_entrada
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();
