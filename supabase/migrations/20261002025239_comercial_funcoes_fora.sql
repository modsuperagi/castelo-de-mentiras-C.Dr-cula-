-- Funções do comercial (instruções de Pix e painel de ressonâncias): ninguém de fora chama.
REVOKE EXECUTE ON FUNCTION public.espelho_instrucoes_pagamento(text) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.espelho_ressonancias() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.espelho_instrucoes_pagamento(text), public.espelho_ressonancias() TO service_role;
