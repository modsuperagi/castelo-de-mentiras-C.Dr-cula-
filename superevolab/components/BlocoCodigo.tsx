"use client";

import { useRef, useState, type ComponentPropsWithoutRef } from "react";

/** Substitui o <pre> do MDX: mostra a linguagem e um botão Copiar. */
export function BlocoCodigo(props: ComponentPropsWithoutRef<"pre">) {
  const ref = useRef<HTMLPreElement>(null);
  const [copiado, setCopiado] = useState(false);

  const filho = props.children as { props?: { className?: string } } | undefined;
  const linguagem = filho?.props?.className?.replace("language-", "") ?? "";

  async function copiar() {
    const texto = ref.current?.innerText ?? "";
    try {
      await navigator.clipboard.writeText(texto);
      setCopiado(true);
      setTimeout(() => setCopiado(false), 1800);
    } catch {
      setCopiado(false);
    }
  }

  return (
    <div className="bloco-codigo my-6 overflow-hidden rounded-lg border border-borda bg-black">
      <div className="flex items-center justify-between border-b border-borda px-3 py-1.5 text-xs text-apagado">
        <span className="font-mono">{linguagem || "código"}</span>
        <button
          type="button"
          onClick={copiar}
          className="rounded px-2 py-1 font-semibold text-amarelo hover:bg-white/5"
          aria-label="Copiar código"
        >
          {copiado ? "Copiado ✓" : "Copiar"}
        </button>
      </div>
      <pre ref={ref} {...props} className="overflow-x-auto p-4 font-mono text-[13px] leading-relaxed" />
    </div>
  );
}
