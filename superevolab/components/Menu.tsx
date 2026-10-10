"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";

// Regra: nenhum item leva a uma página com menos de 2 itens.
// Lab e Radar apontam para as seções da página inicial até terem 3 textos cada.
const PRINCIPAL = [
  { href: "/#lab", rotulo: "Lab · Prática" },
  { href: "/#radar", rotulo: "Radar · SONAR" },
  { href: "/memoria/", rotulo: "Memória" },
];
const SISTEMA = [
  { href: "/sobre/", rotulo: "Sistema · Sobre" },
  { href: "/contato/", rotulo: "Contato" },
  { href: "/newsletter/", rotulo: "Newsletter" },
];

export function Menu() {
  const [aberto, setAberto] = useState(false);
  const caminho = usePathname();

  useEffect(() => setAberto(false), [caminho]);
  useEffect(() => {
    if (!aberto) return;
    const fechar = (e: KeyboardEvent) => e.key === "Escape" && setAberto(false);
    window.addEventListener("keydown", fechar);
    return () => window.removeEventListener("keydown", fechar);
  }, [aberto]);

  return (
    <>
      <button
        type="button"
        onClick={() => setAberto(true)}
        aria-label="Abrir menu"
        aria-expanded={aberto}
        aria-controls="menu-lateral"
        className="grid h-9 w-9 place-items-center rounded-md border border-borda text-texto hover:border-amarelo"
      >
        <svg width="18" height="18" viewBox="0 0 18 18" aria-hidden="true">
          <path d="M2 4h14M2 9h14M2 14h14" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
        </svg>
      </button>

      {aberto && (
        <div className="fixed inset-0 z-50" role="dialog" aria-modal="true" aria-label="Menu">
          <button
            type="button"
            aria-label="Fechar menu"
            className="absolute inset-0 bg-black/70"
            onClick={() => setAberto(false)}
          />
          <nav
            id="menu-lateral"
            className="absolute right-0 top-0 flex h-full w-[min(20rem,85vw)] flex-col border-l border-borda bg-painel p-5"
          >
            <div className="mb-6 flex items-center justify-between">
              <span className="font-mono text-sm text-amarelo">menu</span>
              <button
                type="button"
                onClick={() => setAberto(false)}
                aria-label="Fechar menu"
                className="rounded px-2 py-1 text-xl leading-none text-apagado hover:text-texto"
                autoFocus
              >
                ×
              </button>
            </div>
            <ul className="space-y-1">
              {PRINCIPAL.map((i) => (
                <li key={i.href}>
                  <Link href={i.href} onClick={() => setAberto(false)} className="block rounded-md px-3 py-2.5 text-lg font-semibold text-texto hover:bg-white/5 hover:text-amarelo">
                    {i.rotulo}
                  </Link>
                </li>
              ))}
            </ul>
            <hr className="my-5 border-borda" />
            <ul className="space-y-1">
              {SISTEMA.map((i) => (
                <li key={i.href}>
                  <Link href={i.href} onClick={() => setAberto(false)} className="block rounded-md px-3 py-2 text-apagado hover:bg-white/5 hover:text-texto">
                    {i.rotulo}
                  </Link>
                </li>
              ))}
            </ul>
          </nav>
        </div>
      )}
    </>
  );
}
