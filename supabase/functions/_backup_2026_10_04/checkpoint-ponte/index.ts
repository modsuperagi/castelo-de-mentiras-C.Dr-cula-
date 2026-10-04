import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const url = Deno.env.get("SUPABASE_URL")!;
const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const db = createClient(url, serviceKey);

const json = (data: unknown, status = 200) =>
  new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  try {
    if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

    const auth = req.headers.get("Authorization");
    if (!auth?.startsWith("Bearer ")) return json({ error: "Authentication required" }, 401);
    const token = auth.slice(7);
    const { data: { user }, error: authError } = await db.auth.getUser(token);
    if (authError || !user) return json({ error: "Invalid authentication" }, 401);

    const body = await req.json();
    const action = body?.action;
    const flowId = body?.flow_id;
    if (typeof flowId !== "string") return json({ error: "flow_id é obrigatório" }, 400);

    if (action === "buscar") {
      const { data, error } = await db.rpc("buscar_checkpoint", { p_flow_id: flowId });
      if (error) return json({ error: error.message }, 500);
      return json({ ok: true, action, flow_id: flowId, checkpoint: data ?? null });
    }

    if (action === "salvar") {
      const ponto = typeof body?.ponto_retomada === "string" ? body.ponto_retomada.trim() : "";
      if (!ponto) return json({ error: "ponto_retomada é obrigatório" }, 400);
      const { data, error } = await db.rpc("salvar_checkpoint", {
        p_flow_id: flowId,
        p_identidade: body?.identidade ?? {},
        p_ponto_retomada: ponto,
        p_pergunta_aberta: body?.pergunta_aberta ?? null,
        p_fio_raciocinio: body?.fio_raciocinio ?? null,
        p_estado: { ...(body?.estado ?? {}), saved_by: user.id },
      });
      if (error) return json({ error: error.message }, 500);
      return json({ ok: true, action, flow_id: flowId, checkpoint: data });
    }

    return json({ error: "action deve ser buscar ou salvar" }, 400);
  } catch (e) {
    return json({ error: e instanceof Error ? e.message : "internal error" }, 500);
  }
});
