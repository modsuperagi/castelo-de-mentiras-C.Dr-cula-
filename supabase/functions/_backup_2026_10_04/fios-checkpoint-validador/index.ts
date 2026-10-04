import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.0";

const FIO_UNIVERSAL = "ee46c360-b95b-426e-86c3-2e5d0ccbe916";

Deno.serve(async (req) => {
  try {
    // 1. Recebe payload do webhook (checkpoint inserido)
    const payload = await req.json();
    console.log("🔑 Checkpoint recebido:", payload);

    // 2. Inicializa Supabase
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const checkpoint = payload.record;
    const checkpoint_id = checkpoint.id;

    // 3. VALIDAÇÃO OBRIGATÓRIA
    const validacoes = {
      propósito: checkpoint.mantém_propósito !== false,
      evidência: checkpoint.existe_evidência !== false,
      impacto: !!checkpoint.qual_impacto,
    };

    const passou = validacoes.propósito && validacoes.evidência && validacoes.impacto;

    if (!passou) {
      // ❌ FALHOU: Marca como rejeitado
      await supabase
        .from("fios_checkpoint_universal")
        .update({
          status: "falhado",
          resultado: {
            motivo: "Falha nas 3 validações obrigatórias",
            validacoes,
          },
        })
        .eq("id", checkpoint_id);

      await supabase
        .from("meta_sessões_trina")
        .update({ status: "rejeitado" })
        .eq("checkpoint_id", checkpoint_id);

      return new Response(
        JSON.stringify({ status: "falhado", checkpoint_id, validacoes }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // ✅ PASSOU: Marca como validado
    await supabase
      .from("fios_checkpoint_universal")
      .update({
        status: "validado",
        timestamp_checkpoint: new Date().toISOString(),
      })
      .eq("id", checkpoint_id);

    // 4. PROPAGA para Trina (muda status para em_processamento)
    await supabase
      .from("meta_sessões_trina")
      .update({ status: "em_processamento" })
      .eq("checkpoint_id", checkpoint_id);

    console.log("✅ Checkpoint validado e propagado:", checkpoint_id);

    return new Response(
      JSON.stringify({
        status: "validado_e_propagado",
        checkpoint_id,
        fio: FIO_UNIVERSAL,
        timestamp: new Date().toISOString(),
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("❌ Erro no validador:", error);
    return new Response(
      JSON.stringify({ erro: error instanceof Error ? error.message : String(error) }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
