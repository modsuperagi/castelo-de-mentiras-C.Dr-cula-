import Link from "next/link";
import { site } from "@/lib/site";

export function Cabecalho() {
  return (
    <header className="border-b border-borda">
      <nav className="mx-auto flex max-w-5xl items-center justify-between gap-4 px-4 py-4">
        <Link href="/" className="font-mono text-sm font-bold tracking-tight text-texto">
          <span className="text-amarelo">&gt;_</span> {site.nome}
        </Link>
        <ul className="flex items-center gap-5 text-sm text-apagado">
          <li>
            <Link href="/sobre" className="hover:text-texto">
              Sobre
            </Link>
          </li>
          <li>
            <Link
              href="/newsletter"
              className="rounded-md bg-amarelo px-3 py-1.5 font-semibold text-black hover:brightness-95"
            >
              Newsletter
            </Link>
          </li>
        </ul>
      </nav>
    </header>
  );
}
