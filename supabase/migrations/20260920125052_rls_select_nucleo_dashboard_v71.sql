-- Migração 20260920125052 · rls_select_nucleo_dashboard_v71
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

ALTER TABLE IF EXISTS public.evo_principios ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.registro_decisoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.fluxo_conhecimento ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.notas ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.evo_agentes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.registro_evolucoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.acessos_canais ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS p_select_principios ON public.evo_principios;
CREATE POLICY p_select_principios ON public.evo_principios FOR SELECT TO anon, authenticated USING (ativo IS TRUE);

DROP POLICY IF EXISTS p_select_decisoes ON public.registro_decisoes;
CREATE POLICY p_select_decisoes ON public.registro_decisoes FOR SELECT TO anon, authenticated USING (nivel_acesso IN ('publico','estrutura','confianca','nucleo'));

DROP POLICY IF EXISTS p_select_fluxo ON public.fluxo_conhecimento;
CREATE POLICY p_select_fluxo ON public.fluxo_conhecimento FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS p_select_notas ON public.notas;
CREATE POLICY p_select_notas ON public.notas FOR SELECT TO anon, authenticated USING (status = 'ativa');

DROP POLICY IF EXISTS p_select_agentes ON public.evo_agentes;
CREATE POLICY p_select_agentes ON public.evo_agentes FOR SELECT TO anon, authenticated USING (status_ativo IS TRUE);

DROP POLICY IF EXISTS p_select_evolucoes ON public.registro_evolucoes;
CREATE POLICY p_select_evolucoes ON public.registro_evolucoes FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS p_select_canais ON public.acessos_canais;
CREATE POLICY p_select_canais ON public.acessos_canais FOR SELECT TO anon, authenticated USING (ativo IS TRUE AND nivel_acesso IN ('publico','estrutura'));
