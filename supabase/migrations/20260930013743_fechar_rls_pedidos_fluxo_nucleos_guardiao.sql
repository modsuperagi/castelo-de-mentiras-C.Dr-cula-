-- Aplicada no Castelo pelo Grok Bot M em 30/09/2026. Exportada pelo Plasma em 30/09/2026, sem alteração.
-- Fecha RLS: somente Guardião (JWT app_metadata.role='guardiao') via authenticated; service_role ignora RLS.
DROP POLICY IF EXISTS allow_all_temporario ON public.pedidos_entre_nucleos;
DROP POLICY IF EXISTS allow_all_temporario ON public.fluxo_nos_nucleos;

ALTER TABLE public.pedidos_entre_nucleos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fluxo_nos_nucleos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS guardiao_admin_total ON public.pedidos_entre_nucleos;
CREATE POLICY guardiao_admin_total ON public.pedidos_entre_nucleos
  FOR ALL TO authenticated
  USING (public.eh_guardiao()) WITH CHECK (public.eh_guardiao());

DROP POLICY IF EXISTS guardiao_admin_total ON public.fluxo_nos_nucleos;
CREATE POLICY guardiao_admin_total ON public.fluxo_nos_nucleos
  FOR ALL TO authenticated
  USING (public.eh_guardiao()) WITH CHECK (public.eh_guardiao());

REVOKE INSERT, UPDATE, DELETE ON public.pedidos_entre_nucleos FROM anon;
REVOKE INSERT, UPDATE, DELETE ON public.fluxo_nos_nucleos FROM anon;

-- Sem este GRANT a policy do Guardião não teria efeito (authenticated não tinha privilégio de tabela). RLS limita ao Guardião.
GRANT SELECT, INSERT, UPDATE, DELETE ON public.pedidos_entre_nucleos TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.fluxo_nos_nucleos TO authenticated;
