import Link from "next/link";

export default function NaoEncontrado() {
  return (
    <div className="mx-auto max-w-xl px-4 pt-20 text-center">
      <p className="font-mono text-amarelo">404</p>
      <h1 className="mt-2 text-3xl font-extrabold text-white">Página não encontrada</h1>
      <Link href="/" className="mt-6 inline-block text-amarelo underline underline-offset-4">
        Voltar para os tutoriais
      </Link>
    </div>
  );
}
