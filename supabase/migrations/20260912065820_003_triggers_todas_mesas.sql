-- Migração 20260912065820 · 003_triggers_todas_mesas
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- TRIGGER: EVO 1 - Princípios
DROP TRIGGER IF EXISTS trg_evo_principios_fio ON public.evo_principios CASCADE;
CREATE TRIGGER trg_evo_principios_fio
AFTER INSERT OR UPDATE OR DELETE ON public.evo_principios
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();

-- TRIGGER: EVO 4 - Registro de Decisões (GOLDEN)
DROP TRIGGER IF EXISTS trg_registro_decisoes_fio ON public.registro_decisoes CASCADE;
CREATE TRIGGER trg_registro_decisoes_fio
AFTER INSERT OR UPDATE OR DELETE ON public.registro_decisoes
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();

-- TRIGGER: EVO 3 - Fluxo de Conhecimento
DROP TRIGGER IF EXISTS trg_fluxo_conhecimento_fio ON public.fluxo_conhecimento CASCADE;
CREATE TRIGGER trg_fluxo_conhecimento_fio
AFTER INSERT OR UPDATE OR DELETE ON public.fluxo_conhecimento
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();

-- TRIGGER: EVO 4 + 6 - Notas
DROP TRIGGER IF EXISTS trg_notas_fio ON public.notas CASCADE;
CREATE TRIGGER trg_notas_fio
AFTER INSERT OR UPDATE OR DELETE ON public.notas
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();

-- TRIGGER: EVO 2 - Agentes
DROP TRIGGER IF EXISTS trg_agentes_fio ON public.agentes CASCADE;
CREATE TRIGGER trg_agentes_fio
AFTER INSERT OR UPDATE OR DELETE ON public.agentes
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();

-- TRIGGER: EVO 5 + 6 - Registro de Evoluções
DROP TRIGGER IF EXISTS trg_registro_evolucoes_fio ON public.registro_evolucoes CASCADE;
CREATE TRIGGER trg_registro_evolucoes_fio
AFTER INSERT OR UPDATE OR DELETE ON public.registro_evolucoes
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();

-- TRIGGER: Acessos e Canais
DROP TRIGGER IF EXISTS trg_acessos_canais_fio ON public.acessos_canais CASCADE;
CREATE TRIGGER trg_acessos_canais_fio
AFTER INSERT OR UPDATE OR DELETE ON public.acessos_canais
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();

-- TRIGGERS ADICIONAIS: Tabelas críticas existentes
DROP TRIGGER IF EXISTS trg_meta_lab_entries_fio ON public.meta_lab_entries CASCADE;
CREATE TRIGGER trg_meta_lab_entries_fio
AFTER INSERT OR UPDATE OR DELETE ON public.meta_lab_entries
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();

DROP TRIGGER IF EXISTS trg_consolidacoes_fio ON public.consolidacoes CASCADE;
CREATE TRIGGER trg_consolidacoes_fio
AFTER INSERT OR UPDATE OR DELETE ON public.consolidacoes
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();

DROP TRIGGER IF EXISTS trg_golden_circulacao_fio ON public.golden_circulacao_principal CASCADE;
CREATE TRIGGER trg_golden_circulacao_fio
AFTER INSERT OR UPDATE OR DELETE ON public.golden_circulacao_principal
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();

DROP TRIGGER IF EXISTS trg_consolidacao_circulacao_fio ON public.consolidacao_circulacao_principal CASCADE;
CREATE TRIGGER trg_consolidacao_circulacao_fio
AFTER INSERT OR UPDATE OR DELETE ON public.consolidacao_circulacao_principal
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();

DROP TRIGGER IF EXISTS trg_trina_circulacao_fio ON public.trina_circulacao_principal CASCADE;
CREATE TRIGGER trg_trina_circulacao_fio
AFTER INSERT OR UPDATE OR DELETE ON public.trina_circulacao_principal
FOR EACH ROW EXECUTE FUNCTION public.trigger_fio_checkpoint();
