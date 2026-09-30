-- Determinação do Guardião (Drácula, via Grok Bot M), 30/09/2026: o Castelo fica aberto aos núcleos
-- que entram pela conta do Guardião, não ao público. A Recepção continua sendo a porta de quem chega:
-- evo_agentes, evo_principios, castelo_identidades, checkin_recepcion, sessao_checkpoint e
-- fios_checkpoint_universal seguem com leitura aberta (contrato de evo.json, llms.txt e nucleos.html).
-- Núcleos com a conta do Guardião leem por eh_guardiao(); núcleos de servidor usam service_role.

-- 1. Memória, circulação, Trina, Mariana, ponte e missões Sol: sai a leitura pública.
DROP POLICY IF EXISTS espelho_select_anon_auth ON public.evo_memorias;
DROP POLICY IF EXISTS espelho_select_anon_auth ON public.mariana_casting;
DROP POLICY IF EXISTS espelho_select_anon_auth ON public.ponte_ghost_castelo;
DROP POLICY IF EXISTS espelho_select_anon_auth ON public.coracao_motor_principal;
DROP POLICY IF EXISTS espelho_select_anon_auth ON public.golden_circulacao_principal;
DROP POLICY IF EXISTS espelho_select_anon_auth ON public.trina_circulacao_principal;
DROP POLICY IF EXISTS espelho_select_anon_auth ON public."meta_sessões_trina";
DROP POLICY IF EXISTS espelho_select_anon_auth ON public.fluxo_conhecimento;
DROP POLICY IF EXISTS p_select_fluxo ON public.fluxo_conhecimento;
DROP POLICY IF EXISTS espelho_sol_missions_select ON public.sol_missions;
DROP POLICY IF EXISTS espelho_sol_runs_select ON public.sol_runs;
DROP POLICY IF EXISTS espelho_sol_tasks_select ON public.sol_tasks;
DROP POLICY IF EXISTS p_select_evolucoes ON public.registro_evolucoes;

-- 2. Decisões e canais: volta o filtro que já existia; o público vê só o que é público.
DROP POLICY IF EXISTS espelho_select_anon_auth ON public.registro_decisoes;
DROP POLICY IF EXISTS p_select_decisoes ON public.registro_decisoes;
CREATE POLICY p_select_decisoes ON public.registro_decisoes
  FOR SELECT TO anon, authenticated
  USING (nivel_acesso = 'publico');
DROP POLICY IF EXISTS espelho_select_anon_auth ON public.acessos_canais;

-- 3. Leitura dos núcleos pela conta do Guardião (só leitura; a escrita segue como estava).
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['mariana_casting','ponte_ghost_castelo','coracao_motor_principal',
    'golden_circulacao_principal','trina_circulacao_principal','meta_sessões_trina',
    'fluxo_conhecimento','sol_missions','sol_runs','sol_tasks']
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS guardiao_leitura ON public.%I', t);
    EXECUTE format('CREATE POLICY guardiao_leitura ON public.%I FOR SELECT TO authenticated USING ((SELECT public.eh_guardiao()))', t);
    EXECUTE format('REVOKE SELECT ON public.%I FROM anon', t);
  END LOOP;
END $$;
REVOKE SELECT ON public.evo_memorias FROM anon;

-- 4. Ponte Ghost: UPDATE concedido sem política (achado HOLD do Norton).
REVOKE UPDATE ON public.ponte_ghost_castelo FROM authenticated;

-- 5. Políticas "temporárias" que liberavam tudo (hoje sem GRANT, mas a um GRANT de abrir).
DROP POLICY IF EXISTS allow_all_temporario ON public.arquivos_fio_ee46c360;
DROP POLICY IF EXISTS allow_all_temporario ON public.fluxo_necessidade_capaz;
DROP POLICY IF EXISTS allow_all_temporario ON public.operacao_faixas;
