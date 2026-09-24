-- Migração 20260815191546 · lock_metalab_memory_to_owner_and_sol
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- MetaLab/EVO persistent memory: no public or generic authenticated access.
-- The owner can still administer the database through the Supabase project role;
-- Sol's server-side integration uses service_role, which bypasses RLS by design.

ALTER TABLE public.meta_lab_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidacoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meta_lab_auditoria ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meta_lab_versoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evo_memorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evo_recrutamento_agentes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evo_recrutamento_conhecimento ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evo_recrutamento_fontes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.evo_recrutamento_diretrizes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recrutamento_estrutura ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recrutas_funcoes_casa ENABLE ROW LEVEL SECURITY;

-- Remove Data API reachability for anonymous and generic authenticated clients.
REVOKE ALL ON TABLE public.meta_lab_entries, public.consolidacoes, public.meta_lab_auditoria, public.meta_lab_versoes, public.evo_memorias, public.evo_recrutamento_agentes, public.evo_recrutamento_conhecimento, public.evo_recrutamento_fontes, public.evo_recrutamento_diretrizes, public.recrutamento_estrutura, public.recrutas_funcoes_casa FROM anon, authenticated, PUBLIC;

-- Keep the server-side integration path available.
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.meta_lab_entries, public.consolidacoes, public.meta_lab_auditoria, public.meta_lab_versoes, public.evo_memorias, public.evo_recrutamento_agentes, public.evo_recrutamento_conhecimento, public.evo_recrutamento_fontes, public.evo_recrutamento_diretrizes, public.recrutamento_estrutura, public.recrutas_funcoes_casa TO service_role;

-- The prior broad authenticated policy must not reopen memory if a grant is restored later.
DROP POLICY IF EXISTS "Permitir acesso total via authenticated" ON public.meta_lab_entries;
DROP POLICY IF EXISTS "Permitir acesso total via anon" ON public.meta_lab_entries;
DROP POLICY IF EXISTS "Permitir acesso total" ON public.meta_lab_entries;
