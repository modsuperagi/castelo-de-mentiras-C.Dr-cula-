// Mesa Trina · processador automático — NEUTRALIZADO em 26/09/2026 (reforma do cerebelo, Plasma por autorização do Guardião).
// Backup da versão 2 publicada no Castelo (zolbckgqdxxovguspjdb), verify_jwt = true.
//
// A versão 1 marcava toda sessão aguardando_trina como 'validado' com validacao_p0: true fixo,
// sem ler o conteúdo nem a evidência. Isso viola a lei do organismo: sem sucesso sem evidência.
//
// Agora esta função NÃO valida nada. Ela só responde para onde o trabalho deve ir:
// o veredito da Trina é dado pelo motor (Claude/Plasma ou outro núcleo que não seja o autor)
// pela porta oficial public.trina_registrar_veredito, a partir da fila public.v_trina_pendente.

const FIO_UNIVERSAL = "ee46c360-b95b-426e-86c3-2e5d0ccbe916";

Deno.serve(async (req) => {
  let id: string | null = null;
  try {
    const payload = await req.json();
    id = payload?.record?.id ?? null;
  } catch {
    // corpo ausente ou inválido: a resposta é a mesma
  }
  console.log("Trina: pedido de validação automática recusado", id);
  return new Response(
    JSON.stringify({
      status: "recusado",
      motivo: "Validação automática sem leitura foi desativada. Veredito só com evidência, pelo motor da Mesa.",
      fila: "public.v_trina_pendente",
      porta: "public.trina_registrar_veredito(coracao_id, resultado, escopo_provado, escopo_nao_provado, limites, validador)",
      trina_id: id,
      fio: FIO_UNIVERSAL,
    }),
    { status: 409, headers: { "Content-Type": "application/json" } },
  );
});
