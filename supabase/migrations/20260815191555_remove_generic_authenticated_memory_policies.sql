-- Migração 20260815191555 · remove_generic_authenticated_memory_policies
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

DROP POLICY IF EXISTS "recrutamento agentes leitura autenticada" ON public.evo_recrutamento_agentes;
DROP POLICY IF EXISTS "recrutamento conhecimento leitura autenticada" ON public.evo_recrutamento_conhecimento;
DROP POLICY IF EXISTS "recrutamento fontes leitura autenticada" ON public.evo_recrutamento_fontes;
DROP POLICY IF EXISTS "authenticated_read_meta_lab_auditoria" ON public.meta_lab_auditoria;
DROP POLICY IF EXISTS "authenticated_read_meta_lab_versoes" ON public.meta_lab_versoes;
DROP POLICY IF EXISTS "recrutamento_estrutura_authenticated_insert" ON public.recrutamento_estrutura;
DROP POLICY IF EXISTS "recrutamento_estrutura_authenticated_select" ON public.recrutamento_estrutura;
DROP POLICY IF EXISTS "recrutamento_estrutura_authenticated_update" ON public.recrutamento_estrutura;
DROP POLICY IF EXISTS "recrutas_funcoes_casa_authenticated_insert" ON public.recrutas_funcoes_casa;
DROP POLICY IF EXISTS "recrutas_funcoes_casa_authenticated_select" ON public.recrutas_funcoes_casa;
DROP POLICY IF EXISTS "recrutas_funcoes_casa_authenticated_update" ON public.recrutas_funcoes_casa;
