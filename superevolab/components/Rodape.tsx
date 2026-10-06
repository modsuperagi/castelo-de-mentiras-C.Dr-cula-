import Link from "next/link";
import { site } from "@/lib/site";

export function Rodape() {
  return (
    <footer className="mt-24 border-t border-borda">
      <div className="mx-auto flex max-w-5xl flex-col gap-3 px-4 py-8 text-sm text-apagado sm:flex-row sm:items-center sm:justify-between">
        <p>
          {site.nome} · tutoriais de agentes de IA em português
        </p>
        <ul className="flex gap-5">
          <li>
            <Link href="/sobre" className="hover:text-texto">Sobre</Link>
          </li>
          <li>
            <Link href="/newsletter" className="hover:text-texto">Contato</Link>
          </li>
        </ul>
      </div>
    </footer>
  );
}
