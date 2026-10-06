// sonar-plasma — Ciclo 1 (pedido 210f9385 / proposta db5b8f1d / parecer Norton c61834c5)
// Motor = FILA de Grok Bots no Castelo (sem polling). Esta Edge apenas ENFILEIRA pedidos de
// leitura/escrita de memória Plasma (com chave_dedupe + hash encadeado calculados no banco)
// e consulta o estado de um item. Nunca simula resposta de modelo.
// Acesso ao banco com o JWT do PRÓPRIO usuário (RLS: só guardião via eh_guardiao()).
// Nenhuma chave em código: tudo via Deno.env. Nada de segredo em respostas ou logs.
// v2: consultar_estado mapeia 42501 -> 403 sem_permissao.
import { createClient } from "npm:@supabase/supabase-js@2";

const PROJECT_ORIGIN = "https://zolbckgqdxxovguspjdb.supabase.co";
// Origens permitidas: secret SONAR_ALLOWED_ORIGINS (lista separada por vírgula).
// Sem o secret, só a origem do projeto (a origem do HTML museSpark ainda não existe: lacuna).
const ALLOWED_ORIGINS = new Set(
  (Deno.env.get("SONAR_ALLOWED_ORIGINS") ?? PROJECT_ORIGIN)
    .split(",").map((s) => s.trim()).filter((s) => s.length > 0 && s !== "*"),
);

const MAX_BODY = 16_384;
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function corsHeaders(origin: string | null): Record<string, string> {
  const h: Record<string, string> = {
    "Vary": "Origin",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Max-Age": "600",
  };
  if (origin && ALLOWED_ORIGINS.has(origin)) h["Access-Control-Allow-Origin"] = origin;
  return h;
}

function json(body: unknown, status: number, origin: string | null): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders(origin), "Content-Type": "application/json; charset=utf-8" },
  });
}

async function sha256Hex(s: string): Promise<string> {
  const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(s));
  return Array.from(new Uint8Array(buf)).map((b) => b.toString(16).padStart(2, "0")).join("");
}

type Enfileirar = { acao: "enfileirar"; operacao: "leitura" | "escrita"; texto: string; memoria_ref?: string; motor?: "grok_bot_fila" | "externo" };
type Consultar = { acao: "consultar_estado"; id: string };

function validar(b: unknown): { ok: true; v: Enfileirar | Consultar } | { ok: false; erro: string } {
  if (typeof b !== "object" || b === null || Array.isArray(b)) return { ok: false, erro: "corpo_invalido" };
  const o = b as Record<string, unknown>;
  if (o.acao === "consultar_estado") {
    for (const k of Object.keys(o)) if (!["acao", "id"].includes(k)) return { ok: false, erro: `campo_nao_permitido:${k}` };
    if (typeof o.id !== "string" || !UUID_RE.test(o.id)) return { ok: false, erro: "id_invalido" };
    return { ok: true, v: { acao: "consultar_estado", id: o.id } };
  }
  if (o.acao === "enfileirar") {
    for (const k of Object.keys(o)) if (!["acao", "operacao", "texto", "memoria_ref", "motor"].includes(k)) return { ok: false, erro: `campo_nao_permitido:${k}` };
    if (o.operacao !== "leitura" && o.operacao !== "escrita") return { ok: false, erro: "operacao_invalida" };
    if (typeof o.texto !== "string" || o.texto.trim().length < 1 || o.texto.length > 8000) return { ok: false, erro: "texto_invalido" };
    if (o.memoria_ref !== undefined && (typeof o.memoria_ref !== "string" || o.memoria_ref.length < 1 || o.memoria_ref.length > 200)) return { ok: false, erro: "memoria_ref_invalida" };
    if (o.motor !== undefined && o.motor !== "grok_bot_fila" && o.motor !== "externo") return { ok: false, erro: "motor_invalido" };
    return { ok: true, v: { acao: "enfileirar", operacao: o.operacao, texto: o.texto, memoria_ref: o.memoria_ref as string | undefined, motor: o.motor as Enfileirar["motor"] } };
  }
  return { ok: false, erro: "acao_invalida" };
}

function codigo(e: unknown): string | undefined {
  return (e as { code?: string } | null)?.code;
}

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("Origin");
  if (origin && !ALLOWED_ORIGINS.has(origin)) return json({ erro: "origem_nao_permitida" }, 403, null);
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders(origin) });
  if (req.method !== "POST") return json({ erro: "metodo_nao_permitido" }, 405, origin);

  const auth = req.headers.get("Authorization");
  if (!auth || !auth.startsWith("Bearer ")) return json({ erro: "nao_autenticado" }, 401, origin);

  const raw = await req.text();
  if (raw.length > MAX_BODY) return json({ erro: "corpo_grande_demais" }, 413, origin);
  let body: unknown;
  try { body = JSON.parse(raw); } catch { return json({ erro: "json_invalido" }, 400, origin); }
  const val = validar(body);
  if (!val.ok) return json({ erro: val.erro }, 400, origin);

  const url = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!url || !anonKey) return json({ erro: "configuracao_indisponivel" }, 500, origin);
  // Cliente com o JWT do usuário: RLS decide (somente guardião lê/insere).
  const sb = createClient(url, anonKey, {
    global: { headers: { Authorization: auth } },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const v = val.v;
  if (v.acao === "consultar_estado") {
    const { data, error } = await sb.from("sonar_plasma_fila")
      .select("id, estado, operacao, motor, chave_dedupe, hash_pai, hash, criado_em, atualizado_em")
      .eq("id", v.id).maybeSingle();
    if (error) {
      if (codigo(error) === "42501") return json({ erro: "sem_permissao" }, 403, origin);
      return json({ erro: "consulta_falhou" }, 500, origin);
    }
    if (!data) return json({ erro: "nao_encontrado_ou_sem_permissao" }, 404, origin);
    const { data: saida } = await sb.from("sonar_plasma_saida")
      .select("id, executor, estado, resultado, chave_dedupe, hash_pai, hash, criado_em")
      .eq("fila_id", v.id).maybeSingle();
    return json({ item: data, saida: saida ?? null }, 200, origin);
  }

  // Caminho de motor de IA externo: exige chave em secret. Sem chave => motor_indisponivel.
  // Neste ciclo nenhum provedor externo está integrado; nunca se fabrica resposta de modelo.
  if (v.motor === "externo") {
    const temChave = Boolean(Deno.env.get("SONAR_MOTOR_API_KEY"));
    return json({ erro: "motor_indisponivel", motivo: temChave ? "provedor_externo_nao_integrado_ciclo1" : "sem_chave" }, 503, origin);
  }

  const { data, error } = await sb.from("sonar_plasma_fila")
    .insert({ operacao: v.operacao, texto: v.texto, memoria_ref: v.memoria_ref ?? null, origem: "edge:sonar-plasma" })
    .select("id, estado, motor, chave_dedupe, hash_pai, hash, criado_em").single();

  if (error) {
    if (codigo(error) === "23505") {
      // Duplicado: devolve o item existente (mesma fórmula da chave_dedupe do banco).
      const chave = `SONAR-PLASMA|${v.operacao}|` + await sha256Hex(`${v.operacao}|${v.memoria_ref ?? ""}|${v.texto}`);
      const { data: ex } = await sb.from("sonar_plasma_fila")
        .select("id, estado, motor, chave_dedupe, hash_pai, hash, criado_em").eq("chave_dedupe", chave).maybeSingle();
      return json({ duplicado: true, item: ex ?? null }, 409, origin);
    }
    if (codigo(error) === "42501") return json({ erro: "sem_permissao" }, 403, origin);
    return json({ erro: "enfileirar_falhou" }, 500, origin);
  }
  return json({ enfileirado: true, item: data, motor: "grok_bot_fila", nota: "processamento pelos Grok Bots via fila; sem resposta de modelo nesta chamada" }, 202, origin);
});
