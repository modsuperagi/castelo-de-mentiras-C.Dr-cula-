-- Migração 20260926072337 · espelho_interessados_canal_de_origem
-- Exportada do Castelo (zolbckgqdxxovguspjdb) em 2026-09-26 a partir de supabase_migrations.schema_migrations.

-- Contexto: a Lista da Turma Fundadora tinha 0 inscritos e nenhum jeito de saber qual divulgação funciona.
-- Testado como anon (bloco desfeito): canal válido aceito; canal com caracteres perigosos recusado;
-- origem diferente de 'Espelho Espelho Evo' recusada pela policy; leitura anônima continua negada.

-- Canal de origem de cada inscrito (UTM ou página), para saber qual divulgação traz gente.
-- Texto curto e só com caracteres seguros; opcional. A policy de INSERT anônimo não muda.
ALTER TABLE public.espelho_interessados
  ADD COLUMN IF NOT EXISTS canal text
  CONSTRAINT espelho_interessados_canal_check
  CHECK (canal IS NULL OR (char_length(canal) <= 120 AND canal ~ '^[a-z0-9_.:/-]+$'));

COMMENT ON COLUMN public.espelho_interessados.canal IS
  'Origem do inscrito: utm_source/utm_campaign ou página (ex.: instagram/pre-lancamento, blog/ia-inventou). Adicionada em 26/09/2026.';
