// Espelho dos núcleos (ordem do Guardião, 30/09/2026).
// GET ?k=<chave do núcleo> → texto que uma IA lê só abrindo o link. Sem chave válida, nada aparece.
// A chave é conferida no Castelo (espelho_nucleo_ler), que guarda só o hash, expira e pode ser revogada.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const URL_CASTELO = Deno.env.get("SUPABASE_URL")!;
const CHAVE_SERVICO = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const cabecalhos = {
  "Content-Type": "text/plain; charset=utf-8",
  "Cache-Control": "no-store",
  "X-Robots-Tag": "noindex, nofollow",
  "Referrer-Policy": "no-referrer",
};

const invalido = () =>
  new Response("Espelho EVO: link inválido ou expirado. Peça um novo ao Guardião.\n", { status: 404, headers: cabecalhos });

type Item = Record<string, unknown>;
const data = (v: unknown) => (typeof v === "string" ? v.slice(0, 16).replace("T", " ") : "");

function texto(e: Item): string {
  const linhas: string[] = [];
  linhas.push(`# Espelho EVO · núcleo ${e.nucleo}`, `Gerado em ${data(e.gerado_em)} UTC · link vale até ${data(e.link_expira_em)} UTC`, "");
  linhas.push("## Manual", String(e.manual ?? "(manual não encontrado)"), "");

  const pedidos = (e.pedidos_abertos as Item[]) ?? [];
  linhas.push(`## Pedidos abertos (${pedidos.length})`);
  for (const p of pedidos) linhas.push(`- [${p.id}] ${p.de} → ${p.para} (${p.status}, desde ${data(p.desde)}): ${p.pedido}${p.retorno_esperado ? `\n  Retorno esperado: ${p.retorno_esperado}` : ""}`);
  linhas.push("");

  const missoes = (e.missoes_abertas as Item[]) ?? [];
  linhas.push(`## Missões abertas na Mesa Trina (${missoes.length})`);
  for (const m of missoes) linhas.push(`- [${m.id}] ${m.titulo} (aberta por ${m.aberta_por}, desde ${data(m.desde)})\n  Objetivo: ${m.objetivo}\n  Critério de conclusão: ${m.criterio}`);
  linhas.push("");

  const aprend = (e.aprendizados as Item[]) ?? [];
  linhas.push("## Aprendizados e decisões recentes");
  for (const a of aprend) linhas.push(`- (${a.origem}, ${data(a.em)}) ${a.titulo}${a.conteudo ? `: ${a.conteudo}` : ""}`);
  linhas.push("");

  const trav = (e.travessias_recentes as Item[]) ?? [];
  linhas.push("## Travessias recentes");
  for (const t of trav) linhas.push(`- ${data(t.em)} · ${t.identidade ?? ""} (${t.nucleo ?? ""}) ${t.selo ? `[${t.selo}] ` : ""}${t.determinacao ?? ""}`);
  linhas.push("");

  const mesa = (e.mesa as Item) ?? {};
  linhas.push("## Mesa Trina", `Missões em andamento: ${mesa.missoes_em_andamento ?? 0} · pensamentos na fila: ${mesa.pensamentos_na_fila ?? 0}`);
  return linhas.join("\n") + "\n";
}

Deno.serve(async (req: Request) => {
  if (req.method !== "GET") return new Response("Só leitura.\n", { status: 405, headers: cabecalhos });
  const chave = new URL(req.url).searchParams.get("k") ?? "";
  if (!/^[0-9a-f]{48}$/.test(chave)) return invalido();

  const r = await fetch(`${URL_CASTELO}/rest/v1/rpc/espelho_nucleo_ler`, {
    method: "POST",
    headers: { apikey: CHAVE_SERVICO, Authorization: `Bearer ${CHAVE_SERVICO}`, "Content-Type": "application/json" },
    body: JSON.stringify({ p_chave: chave }),
  });
  if (!r.ok) return invalido();
  return new Response(texto(await r.json()), { status: 200, headers: cabecalhos });
});
