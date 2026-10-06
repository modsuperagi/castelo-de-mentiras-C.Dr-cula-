import { createClient } from "npm:@supabase/supabase-js@2";

const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
const json = (data: unknown, status = 200) => new Response(JSON.stringify(data), { status, headers: { "Content-Type": "application/json" } });
const has = (p: string, terms: string[]) => terms.some((t) => p.toLowerCase().includes(t));

async function llm(prompt: string) {
  const key = Deno.env.get("ANTHROPIC_API_KEY");
  if (!key) return null;
  const model = Deno.env.get("ANTHROPIC_MODEL") ?? "claude-sonnet-4-20250514";
  try {
    const controller = new AbortController(); const timer = setTimeout(() => controller.abort(), 10000);
    const r = await fetch("https://api.anthropic.com/v1/messages", { method: "POST", headers: { "content-type": "application/json", "x-api-key": key, "anthropic-version": "2023-06-01" }, body: JSON.stringify({ model, max_tokens: 700, messages: [{ role: "user", content: `Você é o ARQUITETO da Mesa Trina. Analise o pedido. Retorne SOMENTE JSON válido: {"score":0-10,"p0_pass":boolean,"reasoning":"..."}. Avalie objetivo, estrutura, fronteiras e dependências. PEDIDO:\n${prompt}` }] }), signal: controller.signal });
    clearTimeout(timer); if (!r.ok) return null; const b = await r.json(); const text = b?.content?.find((x: any) => x.type === "text")?.text; if (!text) return null;
    try { const parsed = JSON.parse(text.replace(/^```json\s*|\s*```$/g, "")); return { ...parsed, tokens: (b.usage?.input_tokens ?? 0) + (b.usage?.output_tokens ?? 0) }; } catch { return null; }
  } catch { return null; }
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);
  const started = Date.now();
  try {
    const { prompt, sessionId } = await req.json();
    if (typeof prompt !== "string" || !prompt.trim() || typeof sessionId !== "string") return json({ error: "prompt e sessionId são obrigatórios" }, 400);
    const p = prompt.trim();
    const checks: Record<string, boolean> = {
      p0_01: p.length > 0,
      p0_02: p.length >= 20,
      p0_03: !has(p, ["ciclo infinito", "dependência circular", "cyclic dependency"]),
      p0_04: has(p, ["frontend", "backend", "api", "supabase", "edge function", "limite", "boundary"]),
    };
    const fallbackScore = Math.max(0, Math.min(10, 6 + Object.values(checks).filter(Boolean).length * 0.75));
    const ai = await llm(p);
    const score = ai && Number.isFinite(Number(ai.score)) ? Math.max(0, Math.min(10, Number(ai.score))) : fallbackScore;
    const reasoning = ai?.reasoning ?? "Avaliação estrutural determinística executada; LLM indisponível ou não configurado.";
    const output = `## Arquiteto\n\n${reasoning}\n\nScore: ${score.toFixed(2)}/10`;
    const latency = Date.now() - started;
    const { error: resultError } = await admin.from("trina_results").upsert({ session_id: sessionId, agent_id: "arquiteto", role: "estrutura", score, output, latency_ms: latency, tokens: ai?.tokens ?? 0, p0_checks: checks }, { onConflict: "session_id,agent_id" });
    if (resultError) throw resultError;
    for (const [checkId, passed] of Object.entries(checks)) {
      const { error } = await admin.from("p0_audit").upsert({ session_id: sessionId, check_id: checkId, passed, reason: passed ? "OK" : `Falhou: ${checkId}`, risk_level: passed ? "low" : "high" }, { onConflict: "session_id,check_id" });
      if (error) throw error;
    }
    return json({ agent: "arquiteto", score, output, p0_checks: checks, latency_ms: latency, tokens: ai?.tokens ?? 0, llm_used: !!ai });
  } catch (e) { return json({ error: e instanceof Error ? e.message : "internal error" }, 500); }
});
