// Copia o texto de cada cabeçalho de coluna para data-l nas células da mesma coluna.
// No celular a tabela vira uma pilha de cartões e cada célula mostra seu rótulo (globals.css).

type No = {
  type: string;
  tagName?: string;
  value?: string;
  properties?: Record<string, unknown>;
  children?: No[];
};

function texto(no: No): string {
  if (no.type === "text") return no.value ?? "";
  return (no.children ?? []).map(texto).join("");
}

function filhos(no: No, tag: string): No[] {
  return (no.children ?? []).filter((c) => c.type === "element" && c.tagName === tag);
}

function rotular(tabela: No) {
  const [thead] = filhos(tabela, "thead");
  const [tbody] = filhos(tabela, "tbody");
  if (!thead || !tbody) return;
  const [linhaCab] = filhos(thead, "tr");
  if (!linhaCab) return;
  const rotulos = filhos(linhaCab, "th").map((th) => texto(th).trim());
  for (const tr of filhos(tbody, "tr")) {
    filhos(tr, "td").forEach((td, i) => {
      if (rotulos[i]) td.properties = { ...td.properties, dataL: rotulos[i] };
    });
  }
}

function percorrer(no: No) {
  if (no.type === "element" && no.tagName === "table") rotular(no);
  (no.children ?? []).forEach(percorrer);
}

export default function rehypeTabela() {
  return (arvore: No) => percorrer(arvore);
}
