-- Migração 20260913170931 · 009_habilitar_rls_todas_tabelas
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.


-- HABILITA RLS em todas as 11 tabelas sem proteção

-- 1. castelo_identidades
ALTER TABLE public.castelo_identidades ENABLE ROW LEVEL SECURITY;
CREATE POLICY "núcleo_apenas" ON public.castelo_identidades
  FOR ALL USING (auth.uid() IS NOT NULL);

-- 2. sessoes_estudo
ALTER TABLE public.sessoes_estudo ENABLE ROW LEVEL SECURITY;
CREATE POLICY "estudo_leitura" ON public.sessoes_estudo
  FOR SELECT USING (true);

-- 3. validacoes_obrigatorias
ALTER TABLE public.validacoes_obrigatorias ENABLE ROW LEVEL SECURITY;
CREATE POLICY "validacoes_privado" ON public.validacoes_obrigatorias
  FOR ALL USING (auth.uid() IS NOT NULL);

-- 4. fluxo_conhecimento
ALTER TABLE public.fluxo_conhecimento ENABLE ROW LEVEL SECURITY;
CREATE POLICY "conhecimento_permissivo" ON public.fluxo_conhecimento
  FOR SELECT USING (true);

-- 5. consequencias_historicas
ALTER TABLE public.consequencias_historicas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "historico_leitura" ON public.consequencias_historicas
  FOR SELECT USING (true);

-- 6. evo_principios
ALTER TABLE public.evo_principios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "principios_admin_apenas" ON public.evo_principios
  FOR ALL USING (auth.uid() IS NOT NULL);

-- 7. registro_decisoes
ALTER TABLE public.registro_decisoes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "decisoes_leitura" ON public.registro_decisoes
  FOR SELECT USING (true);

-- 8. notas
ALTER TABLE public.notas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "notas_pessoal" ON public.notas
  FOR ALL USING (auth.uid() IS NOT NULL);

-- 9. agentes
ALTER TABLE public.agentes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "agentes_nucleo" ON public.agentes
  FOR ALL USING (auth.uid() IS NOT NULL);

-- 10. registro_evolucoes
ALTER TABLE public.registro_evolucoes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "evolucoes_rastreavel" ON public.registro_evolucoes
  FOR SELECT USING (true);

-- 11. acessos_canais
ALTER TABLE public.acessos_canais ENABLE ROW LEVEL SECURITY;
CREATE POLICY "acessos_restrito" ON public.acessos_canais
  FOR ALL USING (auth.uid() IS NOT NULL);
