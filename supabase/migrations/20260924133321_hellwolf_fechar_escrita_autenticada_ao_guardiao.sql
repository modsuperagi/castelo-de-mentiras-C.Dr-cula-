-- Migração 20260924133321 · hellwolf_fechar_escrita_autenticada_ao_guardiao
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- Contexto: a migração 20260919063408 deu INSERT/UPDATE a toda conta autenticada com policies USING/WITH CHECK (true).
-- Desde 24/09 o espelho público oferece cadastro, então qualquer estranho que se cadastrasse escreveria no núcleo.
-- Escrita de conta autenticada passa a exigir o papel guardiao. service_role (Sol Edge) continua com bypass de RLS.
-- Reverter: trocar (select public.eh_guardiao()) por true nas mesmas policies.

ALTER POLICY castelo_auth_write  ON public.evo_memorias              WITH CHECK ((select public.eh_guardiao()));
ALTER POLICY castelo_auth_update ON public.evo_memorias              USING ((select public.eh_guardiao())) WITH CHECK ((select public.eh_guardiao()));
ALTER POLICY castelo_auth_write  ON public.checkin_recepcion         WITH CHECK ((select public.eh_guardiao()));
ALTER POLICY castelo_auth_update ON public.checkin_recepcion         USING ((select public.eh_guardiao())) WITH CHECK ((select public.eh_guardiao()));
ALTER POLICY castelo_auth_write  ON public.registro_decisoes         WITH CHECK ((select public.eh_guardiao()));
ALTER POLICY castelo_auth_write  ON public.fios_checkpoint_universal WITH CHECK ((select public.eh_guardiao()));
ALTER POLICY castelo_auth_write  ON public.ponte_ghost_castelo       WITH CHECK ((select public.eh_guardiao()));

-- Porta de entrada: faltava grant (a travessia pelo espelho nunca funcionou). Leitura e escrita pela conta: Guardião.
-- Membros do Selo de Travessia ganharão papel próprio quando existirem.
GRANT SELECT, INSERT ON public.evo_porta_entrada TO authenticated;
ALTER POLICY evo_porta_entrada_insert_authenticated ON public.evo_porta_entrada WITH CHECK ((select public.eh_guardiao()));
ALTER POLICY evo_porta_entrada_read_authenticated   ON public.evo_porta_entrada USING ((select public.eh_guardiao()));

-- Princípios: a policy pública existia (20260924124050), faltava o grant.
GRANT SELECT ON public.evo_principios TO anon, authenticated;
