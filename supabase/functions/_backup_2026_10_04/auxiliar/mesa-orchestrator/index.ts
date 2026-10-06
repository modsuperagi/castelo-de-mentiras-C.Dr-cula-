import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const url = Deno.env.get("SUPABASE_URL")!;
const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const admin = createClient(url, key);

const P0_CONFIG = {
  scopes_permitidos: ["R1.1", "TESTE-TRINA-RECUPERACAO", "R1", "TRINA"],
  dedup_horas: 24,
};

const json = (d: unknown, s = 200) =>
  new Response(JSON.stringify(d), {
    status: s,
    headers: { "Content-Type": "application/json" },
  });

async function sha256(text: string) {
  const hashBuffer = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(text),
  );
  return Array.from(new Uint8Array(hashBuffer))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

async function auditP0(args: {
  registroId: string;
  regra: string;
  motivo: string;
  hash: string;
  flowId?: string | null;
  extra?: Record<string, unknown>;
}) {
  const { registroId, regra, motivo, hash, flowId = null, extra = {} } = args;
  await admin.from("meta_lab_auditoria").insert({
    tabela_origem: "mesa-orchestrator",
    registro_id: registroId,
    acao: "P0_BLOCK",
    quem_alterou: "SOL",
    motivo,
    autorizacao: "TRINA_P0",
    origem: "mesa-orchestrator",
    flow_id: flowId,
    estado_anterior: "RECEBIDO",
    estado_novo: "ARQUIVADO",
    papel: "SOL",
    evidencia: { p0_block: true, regra, motivo, hash, ...extra },
  });
}

async function call(slug: string, body: unknown) {
  const r = await fetch(`${url}/functions/v1/${slug}`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${key}`,
      apikey: key,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  const b = await r.json().catch(() => ({ error: "invalid json" }));
  if (!r.ok) throw new Error(`${slug}: ${b?.error ?? r.status}`);
  return b;
}

Deno.serve(async (req) => {
  try {
    if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

    const auth = req.headers.get("Authorization");
    if (!auth?.startsWith("Bearer ")) {
      return json({ error: "Authentication required" }, 401);
    }

    const token = auth.slice(7);
    const { data: { user }, error: ue } = await admin.auth.getUser(token);
    if (ue || !user) return json({ error: "Invalid authentication" }, 401);

    const body = await req.json();
    const incoming = body.missao ?? body;
    const title = String(incoming.title ?? incoming.titulo ?? "").trim();
    const instruction = String(
      incoming.instruction ?? incoming.descricao ?? incoming.description ?? incoming.prompt ?? "",
    ).trim();
    const contextRaw = incoming.context && typeof incoming.context === "object"
      ? incoming.context
      : {};
    const escopo = String(
      incoming.escopo ?? contextRaw.escopo ?? contextRaw.scope ?? "R1.1",
    ).trim();
    const evidencias = incoming.evidencias ?? body.evidencias ?? [];

    if (!Array.isArray(evidencias)) {
      return json({ error: "evidencias deve ser array" }, 400);
    }

    const p0Hash = await sha256(`${title}|${escopo}|${instruction}`);

    const dedupSince = new Date(
      Date.now() - P0_CONFIG.dedup_horas * 3600000,
    ).toISOString();
    const { data: dup, error: dupErr } = await admin
      .from("sol_missions")
      .select("id, p0_hash, created_at")
      .eq("p0_hash", p0Hash)
      .gte("created_at", dedupSince)
      .limit(1);

    if (dupErr) throw dupErr;

    if (dup && dup.length > 0) {
      await auditP0({
        registroId: String(dup[0].id),
        regra: "DEDUP",
        motivo: `Duplicada de ${dup[0].id}`,
        hash: p0Hash,
        extra: { title },
      });
      return json({
        p0_blocked: true,
        regra: "DEDUP",
        duplicada_de: dup[0].id,
        hash: p0Hash,
      }, 409);
    }

    const scopeOk = P0_CONFIG.scopes_permitidos.some((s) => escopo.includes(s));
    if (!scopeOk) {
      await auditP0({
        registroId: p0Hash.substring(0, 8),
        regra: "SCOPE",
        motivo: `Escopo ${escopo} não permitido`,
        hash: p0Hash,
        extra: { escopo },
      });
      return json({ p0_blocked: true, regra: "SCOPE", escopo }, 403);
    }

    if (!title || title.length < 5) {
      await auditP0({
        registroId: p0Hash.substring(0, 8),
        regra: "STRUCTURE",
        motivo: "title inválido",
        hash: p0Hash,
      });
      return json({ p0_blocked: true, regra: "STRUCTURE" }, 400);
    }

    const flowId = crypto.randomUUID();
    const context = {
      ...contextRaw,
      escopo,
      descricao: incoming.descricao ?? instruction,
      origem: incoming.origem ?? "LAB xrgapxeauoccaruvcfhs",
      evidencias_externas: evidencias,
    };

    const { data: mission, error: me } = await admin
      .from("sol_missions")
      .insert({
        id: undefined,
        flow_id: flowId,
        title,
        instruction,
        created_by: user.id,
        status: "PENDING",
        context,
        trina_estado: "RECEBIDO",
        p0_hash: p0Hash,
        p0_enforcement: {
          allowed: true,
          hash: p0Hash,
          escopo,
          timestamp: new Date().toISOString(),
        },
      })
      .select("id,flow_id,trina_estado")
      .single();

    if (me) return json({ error: "insert_mission_failed", details: me }, 500);

    const { data: session, error: se } = await admin
      .from("sessions")
      .insert({
        prompt: instruction,
        user_id: user.id,
        status: "processando",
        created_at_ms: Date.now(),
        p0_pass: true,
      })
      .select("id")
      .single();

    if (se) return json({ error: "insert_session_failed", details: se }, 500);
    const sessionId = session.id;

    const architect = await call("trina-arquiteto", {
      flowId,
      sessionId,
      prompt: instruction,
      instancia: "ARQUITETO_TESTE",
    });

    const engineer = await call("trina-engenheiro", {
      flowId,
      sessionId,
      prompt: instruction,
      entradaAnterior: { arquitetura: architect.output, score: architect.score },
      evidencias,
      instancia: "ENGENHEIRO_TESTE",
    });

    const verifier = await call("trina-verificador", {
      flowId,
      sessionId,
      prompt: instruction,
      especificacao: { arquitetura: architect.output },
      resultadoEngenheiro: {
        output: engineer.output,
        score: engineer.score,
        evidence: engineer.evidence,
      },
      evidencias,
      instancia: "VERIFICADOR_TESTE",
    });

    const golden = await call("trina-golden", {
      flowId,
      sessionId,
      parecerVerificador: {
        tipo_parecer: verifier.tipo_parecer,
        limites_explicitos: verifier.limites,
        escopo_provado: verifier.escopo_provado ?? "Itens verificados contra evidências recebidas",
        escopo_nao_provado: verifier.escopo_nao_provado ?? "Itens sem evidência suficiente permanecem não confirmados",
      },
      escopoFinal: "Radar de Estado da Arte — resultado validado pela Mesa Trina",
      instancia: "GOLDEN_TESTE",
    });

    await admin.from("sessions").update({
      status: "aprovada",
      trina_score: verifier.score,
      p0_pass: true,
      trina_consenso: {
        flow_id: flowId,
        arquiteto: architect.score,
        engenheiro: engineer.score,
        verificador: verifier.score,
        golden: true,
      },
    }).eq("id", sessionId);

    return json({
      ok: true,
      p0_allowed: true,
      flowId,
      sessionId,
      mission_id: mission.id,
      estado_final: golden.status,
      hash: p0Hash,
      trina_estado: mission.trina_estado,
      etapas: { architect, engineer, verifier, golden },
    });
  } catch (e) {
    return json({ error: e instanceof Error ? e.message : String(e) }, 500);
  }
});
