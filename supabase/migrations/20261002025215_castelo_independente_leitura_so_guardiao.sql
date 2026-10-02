-- Ordem do Guardião (30/09): o Castelo é independente; o Espelho é para os núcleos, por link com manual, não leitura pública.
-- As políticas públicas não são apagadas: passam a valer só para a conta do Guardião.
ALTER POLICY p_select_canais ON public.acessos_canais TO authenticated USING ((SELECT public.eh_guardiao()));
ALTER POLICY espelho_select_anon_auth ON public.castelo_identidades TO authenticated USING ((SELECT public.eh_guardiao()));
ALTER POLICY espelho_select_anon_auth ON public.checkin_recepcion TO authenticated USING ((SELECT public.eh_guardiao()));
ALTER POLICY historico_leitura ON public.consequencias_historicas TO authenticated USING ((SELECT public.eh_guardiao()));
ALTER POLICY espelho_select_anon_auth ON public.evo_agentes TO authenticated USING ((SELECT public.eh_guardiao()));
ALTER POLICY p_select_agentes ON public.evo_agentes TO authenticated USING ((SELECT public.eh_guardiao()));
ALTER POLICY espelho_select_publico ON public.evo_principios TO authenticated USING ((SELECT public.eh_guardiao()));
ALTER POLICY p_select_principios ON public.evo_principios TO authenticated USING ((SELECT public.eh_guardiao()));
ALTER POLICY espelho_select_anon_auth ON public.fios_checkpoint_universal TO authenticated USING ((SELECT public.eh_guardiao()));
ALTER POLICY p_select_notas ON public.notas TO authenticated USING ((SELECT public.eh_guardiao()));
ALTER POLICY p_select_decisoes ON public.registro_decisoes TO authenticated USING ((SELECT public.eh_guardiao()));
ALTER POLICY espelho_select_anon_auth ON public.sessao_checkpoint TO authenticated USING ((SELECT public.eh_guardiao()));
ALTER POLICY estudo_leitura ON public.sessoes_estudo TO authenticated USING ((SELECT public.eh_guardiao()));
-- Comercial: inscrição, sinais e telemetria públicos deixam de entrar (só o Guardião, se um dia quiser).
ALTER POLICY espelho_eventos_publico_insere ON public.espelho_eventos TO authenticated WITH CHECK ((SELECT public.eh_guardiao()));
ALTER POLICY interessados_insert_publico ON public.espelho_interessados TO authenticated WITH CHECK ((SELECT public.eh_guardiao()));
ALTER POLICY espelho_sinais_publico_insere ON public.espelho_sinais TO authenticated WITH CHECK ((SELECT public.eh_guardiao()));
