import { createClient } from "https://esm.sh/@supabase/supabase-js@2.43.0";

const FIO_UNIVERSAL = "ee46c360-b95b-426e-86c3-2e5d0ccbe916";

interface PortalPayload {
  identidade: string;
  selo: string;
  determinacao: string;
  conteudo: string;
  tipo_registro?: string;
  origem_instancia?: string;
}

Deno.serve(async (req) => {
  // CORS para todas as plataformas
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }

  try {
    // 1. Parse payload
    const payload: PortalPayload = await req.json();
    console.log("🔑 Identidade:", payload.identidade);

    // Validacao basica
    if (!payload.identidade || !payload.selo || !payload.conteudo) {
      return new Response(
        JSON.stringify({
          erro: "Faltam: identidade, selo, conteudo",
        }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // 2. Inicializa Supabase
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // 3. Cria entrada em evo_porta_entrada
    const { data: novaPorta, error: erroPorta } = await supabase
      .from("evo_porta_entrada")
      .insert({
        identidade: payload.identidade,
        selo: payload.selo,
        determinacao: payload.determinacao || payload.conteudo.substring(0, 100),
        tipo_registro: payload.tipo_registro || "entrada_plataforma",
        conteudo: payload.conteudo,
        origem_instancia: payload.origem_instancia || payload.identidade,
      })
      .select("id")
      .single();

    if (erroPorta) {
      console.error("❌ Erro porta:", erroPorta);
      return new Response(
        JSON.stringify({ erro: "Erro ao criar porta entrada" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    // 4. Cria checkin_recepcion (dispara o fio)
    const { data: checkin, error: erroCheckin } = await supabase
      .from("checkin_recepcion")
      .insert({
        fio_id: FIO_UNIVERSAL,
        porta_entrada_id: novaPorta.id,
        identidade: payload.identidade,
        selo: payload.selo,
        determinacao: payload.determinacao,
        conteudo_raw: payload.conteudo,
        tipo_registro: payload.tipo_registro || "entrada_plataforma",
        origem_instancia: payload.origem_instancia || payload.identidade,
      })
      .select("id, fio_id, status")
      .single();

    if (erroCheckin) {
      console.error("❌ Erro checkin:", erroCheckin);
      return new Response(
        JSON.stringify({ erro: "Erro ao processar checkin" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    console.log("✅ Entrada registrada:", checkin.id);

    // 5. Retorna sucesso
    return new Response(
      JSON.stringify({
        status: "entrada_registrada",
        fio_id: FIO_UNIVERSAL,
        checkin_id: checkin.id,
        porta_entrada_id: novaPorta.id,
        identidade: payload.identidade,
        timestamp: new Date().toISOString(),
        mensagem: `Registrado no Castelo! Status: ${checkin.status}`,
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (error) {
    console.error("❌ Erro:", error);
    return new Response(
      JSON.stringify({
        erro: error instanceof Error ? error.message : String(error),
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
});
