-- Migração 20260924125318 · espelho_lista_turma_fundadora
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-24 a partir de supabase_migrations.schema_migrations.

-- Lista da Turma Fundadora: captação sem login pelo espelho.
-- Visitante só INSERE (não lê nada); leitura e gestão ficam com o Guardião.
CREATE TABLE IF NOT EXISTS public.espelho_interessados (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  email text NOT NULL,
  pacote text NOT NULL DEFAULT 'indefinido',
  mensagem text,
  consentimento boolean NOT NULL DEFAULT false,
  origem text NOT NULL DEFAULT 'Espelho Espelho Evo',
  status text NOT NULL DEFAULT 'novo',
  fio_id uuid NOT NULL DEFAULT 'ee46c360-b95b-426e-86c3-2e5d0ccbe916',
  criado_em timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT interessados_nome_tamanho CHECK (char_length(nome) BETWEEN 2 AND 120),
  CONSTRAINT interessados_email_formato CHECK (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]{2,}$' AND char_length(email) <= 254),
  CONSTRAINT interessados_pacote_valido CHECK (pacote IN ('indefinido','travessia','nucleo','curso','roteiros','trina','sonar','arquitetura')),
  CONSTRAINT interessados_mensagem_tamanho CHECK (mensagem IS NULL OR char_length(mensagem) <= 1000),
  CONSTRAINT interessados_status_valido CHECK (status IN ('novo','contatado','convertido','descartado'))
);

-- Um e-mail por pacote: reenvio vira no-op em vez de duplicata.
CREATE UNIQUE INDEX IF NOT EXISTS interessados_email_pacote_unico
  ON public.espelho_interessados (lower(email), pacote);

ALTER TABLE public.espelho_interessados ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS interessados_insert_publico ON public.espelho_interessados;
CREATE POLICY interessados_insert_publico ON public.espelho_interessados
  FOR INSERT TO anon, authenticated
  WITH CHECK (consentimento IS TRUE AND status = 'novo' AND origem = 'Espelho Espelho Evo');

DROP POLICY IF EXISTS guardiao_admin_total ON public.espelho_interessados;
CREATE POLICY guardiao_admin_total ON public.espelho_interessados
  FOR ALL TO authenticated
  USING (public.eh_guardiao()) WITH CHECK (public.eh_guardiao());

-- Anônimo pode inserir, mas nunca ler de volta.
REVOKE SELECT, UPDATE, DELETE ON public.espelho_interessados FROM anon;
GRANT INSERT ON public.espelho_interessados TO anon, authenticated;
