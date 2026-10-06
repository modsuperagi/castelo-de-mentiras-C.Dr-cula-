import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

type EvidenceStatus = "produzido" | "observado" | "verificado" | "rejeitado";
type GoalLayer = "princípios" | "decisões" | "conhecimento" | "notas" | "agentes" | "evoluções";

interface MetaIAPrompt {
  humanInput: string;
  context?: string;
  userId?: string;
  sessionId?: string;
  goalLayer?: GoalLayer;
  allowErosion?: boolean;
}

interface MesaResult {
  sessionId: string;
  status: string;
  p0Pass: boolean;
  p0Id?: string;
  porta?: unknown;
  trina: {
    score: number | null;
    consenso: Record<string, unknown>;
    results: Array<Record<string, unknown>>;
  };
  latency_ms: number;
}

interface GoldenEvidence {
  claim: string;
  evidence: string;
  status: EvidenceStatus;
  source: string;
}

interface MarianaMark {
  erosionLevel: number;
  chaosIngested: string[];
  weightCarried: string[];
  foundationStrength: number;
}

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const MESA_URL = Deno.env.get("MESA_URL") || `${SUPABASE_URL}/functions/v1/mesa-orchestrator`;
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (data: unknown, status = 200) =>
  new Response(JSON.stringify(data, null, 2), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

function requireBearer(req: Request): string {
  const auth = req.headers.get("Authorization");
  if (!auth?.startsWith("Bearer ")) throw new Error("Authentication required");
  return auth;
}

async function callMesa(
  input: MetaIAPrompt,
  bearer: string,
): Promise<MesaResult> {
  const prompt = input.context?.trim()
    ? `${input.humanInput.trim()}\n\nCONTEXTO:\n${input.context.trim()}`
    : input.humanInput.trim();

  const body = {
    prompt,
    userId: input.userId,
    sessionId: input.sessionId,
    goalLayer: input.goalLayer,
    agentName: "meta-ia-amplifier",
    camadaEvo: input.goalLayer || "EVO5",
    nivelAcesso: "estrutura",
  };

  const response = await fetch(MESA_URL, {
    method: "POST",
    headers: {
      "Authorization": bearer,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });

  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(`Mesa ${response.status}: ${data?.error || data?.resultado || "request failed"}`);
  }
  return data as MesaResult;
}

function hasConsensus(results: Array<Record<string, unknown>>): boolean {
  const scores = results
    .map((r) => Number(r.score))
    .filter((n) => Number.isFinite(n));
  if (scores.length !== 3) return false;
  const min = Math.min(...scores);
  const max = Math.max(...scores);
  return min >= 6.5 && max - min <= 2;
}

function processMariana(mesa: MesaResult): MarianaMark {
  const score = mesa.trina.score ?? 0;
  const results = mesa.trina.results;
  const chaosIngested: string[] = [];
  const weightCarried: string[] = [];

  if (!mesa.p0Pass) chaosIngested.push("P0 bloqueado: material para o próximo ciclo");
  if (score < 7) chaosIngested.push(`Score Trina abaixo de 7: ${score}/10`);
  if (results.some((r) => Number(r.score) < 5)) chaosIngested.push("Agente com baixa confiança registrado como erosão");
  if (mesa.p0Pass) weightCarried.push(`P0 ${mesa.p0Id || "sem-id"}: porta operacional autorizada`);
  weightCarried.push(`Sessão ${mesa.sessionId}: ciclo recebido pela Mesa`);

  return {
    erosionLevel: Math.max(0, Number((10 - score).toFixed(2))),
    chaosIngested,
    weightCarried,
    foundationStrength: Math.min(10, Number((0.5 + score * 0.5).toFixed(2))),
  };
}

function extractInsights(mesa: MesaResult) {
  const insights: string[] = [];
  const patterns: string[] = [];
  const blindSpots: string[] = [];
  const nextSteps: string[] = [];

  const byAgent = new Map(mesa.trina.results.map((r) => [String(r.agent), Number(r.score)]));
  if ((byAgent.get("arquiteto") ?? 0) >= 7) insights.push(`Arquitetura clara: ${byAgent.get("arquiteto")}/10`);
  if ((byAgent.get("engenheiro") ?? 0) >= 7) insights.push(`Execução viável: ${byAgent.get("engenheiro")}/10`);
  if ((byAgent.get("verificador") ?? 0) < 6) patterns.push("Validação com risco não mitigado");
  if ((mesa.trina.score ?? 0) < 6.5) blindSpots.push("Gaps significativos exigem refinamento");

  if (mesa.p0Pass) {
    nextSteps.push("P0 passou: o caminho operacional foi autorizado pelo orchestrator");
    nextSteps.push("Prosseguir para Trina/Golden conforme o estado retornado");
  } else {
    nextSteps.push("P0 bloqueou: não consolidar nem declarar execução autorizada");
    nextSteps.push("Registrar o motivo e usar o bloqueio como material do próximo ciclo");
  }
  return { insights, patterns, blindSpots, nextSteps };
}

function buildEvidence(mesa: MesaResult): GoldenEvidence[] {
  const consensus = hasConsensus(mesa.trina.results);
  return [
    {
      claim: "P0 autorizou a passagem operacional",
      evidence: `p0Pass=${mesa.p0Pass}; p0Id=${mesa.p0Id || "n/a"}; porta retornada=${mesa.porta !== undefined}`,
      status: mesa.p0Pass ? "observado" : "rejeitado",
      source: "mesa-orchestrator/p0",
    },
    {
      claim: "Trina produziu três resultados",
      evidence: `resultados=${mesa.trina.results.length}`,
      status: mesa.trina.results.length === 3 ? "produzido" : "rejeitado",
      source: "mesa-orchestrator/trina",
    },
    {
      claim: "Consenso estrutural entre os três agentes",
      evidence: `scores=${mesa.trina.results.map((r) => r.score).join(",")}; regra=min>=6.5 e spread<=2`,
      status: consensus ? "observado" : "rejeitado",
      source: "meta-ia/consensus-rule",
    },
    {
      claim: "Processamento dentro de 10 segundos",
      evidence: `latency_ms=${mesa.latency_ms}`,
      status: mesa.latency_ms < 10000 ? "observado" : "rejeitado",
      source: "mesa-orchestrator/performance",
    },
  ];
}

function calculateEvolutionScore(evidences: GoldenEvidence[]): number {
  const weights: Record<EvidenceStatus, number> = {
    produzido: 0.25,
    observado: 0.6,
    verificado: 1,
    rejeitado: 0,
  };
  if (!evidences.length) return 0;
  const value = evidences.reduce((sum, e) => sum + weights[e.status], 0) / evidences.length;
  return Number((value * 10).toFixed(2));
}

async function saveAudit(sessionId: string, input: string, output: unknown, status: string) {
  const { error } = await supabase.from("meta_lab_auditoria").insert({
    session_id: sessionId,
    event_type: "meta_ia_evolution",
    input,
    output: JSON.stringify(output),
    status,
    created_at: new Date().toISOString(),
  });
  if (error) throw new Error(`Audit save failed: ${error.message}`);
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "POST only" }, 405);

  try {
    const bearer = requireBearer(req);
    const body = await req.json();
    const input: MetaIAPrompt = {
      humanInput: body?.prompt || body?.humanInput,
      context: body?.context,
      userId: body?.userId,
      sessionId: body?.sessionId,
      goalLayer: body?.goalLayer,
      allowErosion: body?.allowErosion,
    };

    if (typeof input.humanInput !== "string" || !input.humanInput.trim()) {
      return json({ error: "P0-03 FAIL: propósito vazio" }, 400);
    }

    const mesa = await callMesa(input, bearer);
    const amplification = extractInsights(mesa);
    const mariana = input.allowErosion === false ? undefined : processMariana(mesa);
    const evidences = buildEvidence(mesa);
    const evolutionScore = calculateEvolutionScore(evidences);

    // A Meta-IA não inventa consolidação: o estado é derivado do P0/Mesa.
    const status = mesa.p0Pass ? "verificado" : "pendente_verificacao";

    const knowledgeLayers = [
      {
        layerId: "EVO1",
        layerName: "Guardião (Princípios)",
        content: `Pedido recebido e submetido à Mesa com P0 antes da execução. Resultado: ${mesa.status}.`,
        evidenceLevel: "observado",
      },
      {
        layerId: "EVO2",
        layerName: "Trina (Agentes)",
        content: JSON.stringify(mesa.trina),
        evidenceLevel: "produzido",
      },
      {
        layerId: "EVO3",
        layerName: "Conhecimento (Fluxo)",
        content: `P0=${mesa.p0Pass}; session=${mesa.sessionId}; p0Id=${mesa.p0Id || "n/a"}`,
        evidenceLevel: mesa.p0Pass ? "observado" : "rejeitado",
      },
      {
        layerId: "EVO4",
        layerName: "Golden (Decisão)",
        content: JSON.stringify(evidences),
        evidenceLevel: "observado",
      },
      {
        layerId: "EVO5",
        layerName: "Metodologia (Evolução)",
        content: JSON.stringify(amplification),
        evidenceLevel: "observado",
      },
      {
        layerId: "EVO6",
        layerName: "Consolidação (Notas)",
        content: mesa.p0Pass ? "Ciclo retornado pela Mesa; consolidação não é inferida além da evidência disponível." : "Ciclo bloqueado no P0.",
        evidenceLevel: "observado",
      },
    ];

    if (mariana) {
      knowledgeLayers.push({
        layerId: "EVO7",
        layerName: "Mariana (Fundação Viva)",
        content: JSON.stringify(mariana),
        evidenceLevel: "observado",
      });
    }

    const auditPayload = {
      sessionId: mesa.sessionId,
      p0Id: mesa.p0Id,
      p0Pass: mesa.p0Pass,
      porta: mesa.porta,
      trina: mesa.trina,
      evidences,
      evolutionScore,
      amplification,
      mariana,
    };

    await saveAudit(mesa.sessionId, input.humanInput, auditPayload, status);

    return json({
      evolution: {
        id: `meta-${crypto.randomUUID()}`,
        sessionId: mesa.sessionId,
        humanInput: input.humanInput,
        mesaOutput: mesa,
        knowledgeLayers,
        amplification,
        goldenEvidences: evidences,
        evolutionScore,
        status,
      },
      humanReadable: {
        summary: `META IA → MESA → P0 → ${mesa.p0Pass ? "PORTA ABERTA → TRINA" : "BLOQUEADO"}`,
        insights: amplification.insights,
        nextActions: amplification.nextSteps,
        evidencesSummary: evidences.map((e) => `${e.status}: ${e.claim}`).join("\n"),
      },
      rastreability: {
        produced: knowledgeLayers.map((k) => k.layerId),
        verified: evidences.filter((e) => e.status === "verificado").map((e) => e.claim),
        consolidated: [],
      },
    });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : "internal error" }, 500);
  }
});
