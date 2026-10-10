import Link from "next/link";
import { Menu } from "@/components/Menu";
import { site } from "@/lib/site";

export function Cabecalho() {
  return (
    <header className="border-b border-borda">
      <div className="mx-auto flex max-w-5xl items-center justify-between gap-4 px-4 py-3.5">
        <Link href="/" className="font-mono text-sm font-bold tracking-tight text-texto">
          <span className="text-amarelo">&gt;_</span> {site.nome}
        </Link>
        <div className="flex items-center gap-3">
          <Link
            href="/newsletter/"
            className="rounded-md bg-amarelo px-3 py-1.5 text-sm font-semibold text-black hover:brightness-95"
          >
            Assinar
          </Link>
          <Menu />
        </div>
      </div>
    </header>
  );
}
