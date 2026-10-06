-- Limpeza de segurança 1cbb42de sob portão Norton ef607abd-1d4b-4f12-841d-d822edc60f55 (03/10/2026). Só REVOKE, DROP POLICY e COMMENT.
-- S1.1 (parcial): REVOKE SELECT de anon em acessos_canais, castelo_identidades, sessao_checkpoint; REVOKE INSERT de anon em espelho_interessados.
-- HOLD: registro_decisoes (Espelho grok.me, página motor, lê registro_decisoes com a chave do cliente). Fora: evo_principios, evo_agentes, fios_checkpoint_universal, checkin_recepcion.
REVOKE SELECT ON TABLE public.acessos_canais FROM anon;
REVOKE SELECT ON TABLE public.castelo_identidades FROM anon;
REVOKE SELECT ON TABLE public.sessao_checkpoint FROM anon;
REVOKE INSERT ON TABLE public.espelho_interessados FROM anon;
-- S2.1: DROP da policy núcleo_apenas (ALL, TO public, auth.uid() IS NOT NULL). Guardião segue coberto por guardiao_admin_total e espelho_select_anon_auth (eh_guardiao()).
DROP POLICY "núcleo_apenas" ON public.castelo_identidades;
-- S3.1 / S3.2: só COMMENT.
COMMENT ON TABLE public.castelo_tabela_responsavel IS 'ACESSO: negado por padrão a anon e authenticated (RLS ativo, sem policy; sem SELECT/INSERT/UPDATE/DELETE para clientes). Só backend (service_role). Documentado em 03/10/2026 pela limpeza 1cbb42de sob o portão Norton ef607abd (S3.1); policy de leitura do Guardião só por proposta própria (S3.3).';
COMMENT ON TABLE public.espelho_chaves_nucleo IS 'ACESSO: negado por padrão a anon e authenticated (RLS ativo, sem policy; sem SELECT/INSERT/UPDATE/DELETE para clientes). Só backend (service_role). Documentado em 03/10/2026 pela limpeza 1cbb42de sob o portão Norton ef607abd (S3.1); policy de leitura do Guardião só por proposta própria (S3.3).';
COMMENT ON TABLE public.registro_evolucoes IS 'ACESSO: negado por padrão a anon e authenticated (RLS ativo, sem policy; sem SELECT/INSERT/UPDATE/DELETE para clientes). Só backend (service_role). Documentado em 03/10/2026 pela limpeza 1cbb42de sob o portão Norton ef607abd (S3.1); policy de leitura do Guardião só por proposta própria (S3.3).';
COMMENT ON TABLE public.espelho_catalogo IS 'Fonte única de preço, prazo, material pedido e limites de cada oferta do Espelho. O Pix automático só vale para o que o organismo entrega sozinho. ACESSO: negado por padrão a anon e authenticated (RLS ativo, sem policy; sem SELECT/INSERT/UPDATE/DELETE para clientes). Só backend (service_role). Documentado em 03/10/2026 pela limpeza 1cbb42de sob o portão Norton ef607abd (S3.1); policy de leitura do Guardião só por proposta própria (S3.3).';
COMMENT ON TABLE public.espelho_pagamento_config IS 'Linha única. Liga as instruções de Pix depois da inscrição. Só liga com determinado_por (Drácula ou Guardião). Ninguém de fora lê. ACESSO: negado por padrão a anon e authenticated (RLS ativo, sem policy; sem SELECT/INSERT/UPDATE/DELETE para clientes). Só backend (service_role). Documentado em 03/10/2026 pela limpeza 1cbb42de sob o portão Norton ef607abd (S3.1); policy de leitura do Guardião só por proposta própria (S3.3).';
COMMENT ON TABLE public.espelho_uso IS 'Cada entrega feita dentro de um plano mensal. Sem conteúdo do cliente: só tipo, data e referência do documento entregue. ACESSO: negado por padrão a anon e authenticated (RLS ativo, sem policy; sem SELECT/INSERT/UPDATE/DELETE para clientes). Só backend (service_role). Documentado em 03/10/2026 pela limpeza 1cbb42de sob o portão Norton ef607abd (S3.1); policy de leitura do Guardião só por proposta própria (S3.3).';
COMMENT ON TABLE public.arquivos_fio_ee46c360 IS 'RLS ativo desde 24/09/2026. A política permissiva temporária ''allow_all_temporario'' citada antes NÃO existe (conferido em 03/10/2026). ACESSO: negado por padrão a anon e authenticated (RLS ativo, sem policy; sem SELECT/INSERT/UPDATE/DELETE para clientes). Só backend (service_role). Documentado em 03/10/2026 pela limpeza 1cbb42de sob o portão Norton ef607abd (S3.1); policy de leitura do Guardião só por proposta própria (S3.3).';
COMMENT ON TABLE public.fluxo_necessidade_capaz IS 'RLS ativo desde 24/09/2026. A política permissiva temporária ''allow_all_temporario'' citada antes NÃO existe (conferido em 03/10/2026). ACESSO: negado por padrão a anon e authenticated (RLS ativo, sem policy; sem SELECT/INSERT/UPDATE/DELETE para clientes). Só backend (service_role). Documentado em 03/10/2026 pela limpeza 1cbb42de sob o portão Norton ef607abd (S3.1); policy de leitura do Guardião só por proposta própria (S3.3).';
COMMENT ON TABLE public.operacao_faixas IS 'RLS ativo desde 24/09/2026. A política permissiva temporária ''allow_all_temporario'' citada antes NÃO existe (conferido em 03/10/2026). ACESSO: negado por padrão a anon e authenticated (RLS ativo, sem policy; sem SELECT/INSERT/UPDATE/DELETE para clientes). Só backend (service_role). Documentado em 03/10/2026 pela limpeza 1cbb42de sob o portão Norton ef607abd (S3.1); policy de leitura do Guardião só por proposta própria (S3.3).';

-- ROLLBACK EXATO (não executar sem decisão do Norton/Golden):
-- GRANT SELECT ON TABLE public.acessos_canais TO anon;
-- GRANT SELECT ON TABLE public.castelo_identidades TO anon;
-- GRANT SELECT ON TABLE public.sessao_checkpoint TO anon;
-- GRANT INSERT ON TABLE public.espelho_interessados TO anon;
-- CREATE POLICY "núcleo_apenas" ON public.castelo_identidades AS PERMISSIVE FOR ALL TO public USING ((( SELECT auth.uid() AS uid) IS NOT NULL)) WITH CHECK ((( SELECT auth.uid() AS uid) IS NOT NULL));
-- COMMENT ON TABLE public.castelo_tabela_responsavel IS NULL;
-- COMMENT ON TABLE public.espelho_chaves_nucleo IS NULL;
-- COMMENT ON TABLE public.registro_evolucoes IS NULL;
-- COMMENT ON TABLE public.espelho_catalogo IS 'Fonte única de preço, prazo, material pedido e limites de cada oferta do Espelho. O Pix automático só vale para o que o organismo entrega sozinho.';
-- COMMENT ON TABLE public.espelho_pagamento_config IS 'Linha única. Liga as instruções de Pix depois da inscrição. Só liga com determinado_por (Drácula ou Guardião). Ninguém de fora lê.';
-- COMMENT ON TABLE public.espelho_uso IS 'Cada entrega feita dentro de um plano mensal. Sem conteúdo do cliente: só tipo, data e referência do documento entregue.';
-- COMMENT ON TABLE public.arquivos_fio_ee46c360 IS 'RLS ativado 24/09/2026 com política permissiva temporária (allow_all_temporario) para preservar acesso atual. Política restritiva real: pendente de definição. Ver registro_decisoes.';
-- COMMENT ON TABLE public.fluxo_necessidade_capaz IS 'RLS ativado 24/09/2026 com política permissiva temporária (allow_all_temporario) para preservar acesso atual. Política restritiva real: pendente de definição. Ver registro_decisoes.';
-- COMMENT ON TABLE public.operacao_faixas IS 'RLS ativado 24/09/2026 com política permissiva temporária (allow_all_temporario) para preservar acesso atual. Política restritiva real: pendente de definição. Ver registro_decisoes.';
