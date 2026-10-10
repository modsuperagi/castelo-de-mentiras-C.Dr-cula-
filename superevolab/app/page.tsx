import Link from "next/link";
import { CartaoPost } from "@/components/CartaoPost";
import { FormularioNewsletter } from "@/components/FormularioNewsletter";
import { listarPosts, type Post } from "@/lib/posts";
import { EIXOS, type Eixo } from "@/lib/site";

const DESCRICAO: Record<Eixo, string> = {
  lab: "Guias curtos, código que roda e automações para problemas de verdade.",
  radar: "Varreduras do SONAR: o que está acontecendo com agentes de IA, com fonte e grau de evidência.",
};

function Secao({ eixo, posts }: { eixo: Eixo; posts: Post[] }) {
  if (posts.length === 0) return null;
  return (
    <section id={eixo} className="mx-auto mt-14 max-w-5xl scroll-mt-6 px-4" aria-labelledby={`titulo-${eixo}`}>
      <h2 id={`titulo-${eixo}`} className="text-sm font-semibold uppercase tracking-widest text-amarelo">
        {EIXOS[eixo].nome}
      </h2>
      <p className="mb-5 mt-1 text-apagado">{DESCRICAO[eixo]}</p>
      <div className="grid gap-5 sm:grid-cols-2">
        {posts.map((p) => (
          <CartaoPost key={p.slug} post={p} />
        ))}
      </div>
    </section>
  );
}

export default function Home() {
  const posts = listarPosts();
  const lab = posts.filter((p) => p.eixo === "lab");
  const radar = posts.filter((p) => p.eixo === "radar");

  return (
    <>
      <Link
        href="/sonar/"
        className="block border-b border-[#3a1f6b] bg-[#0d0a1f] px-4 py-2.5 text-center text-sm text-[#eee7d7] hover:text-white"
      >
        <span className="text-[#e6b85c]">SONAR em beta:</span> monte a sua equipe de agentes de IA.{" "}
        <span className="underline decoration-[#7fd8f2]/60 underline-offset-4">Conhecer o beta</span>
      </Link>
      <section className="mx-auto max-w-5xl px-4 pb-4 pt-14 sm:pt-20">
        <p className="mb-4 font-mono text-sm text-amarelo">// agentes de IA, em português, na prática</p>
        <h1 className="max-w-3xl text-4xl font-extrabold leading-[1.1] tracking-tight text-white sm:text-6xl">
          Skills práticas. <span className="text-amarelo">Quem aprende, evolui.</span>
        </h1>
        <p className="mt-5 max-w-2xl text-lg text-apagado">
          Tutoriais com código que roda e casos daqui do Brasil. E, no Radar, varreduras com fonte sobre o que
          está acontecendo com agentes de IA no mundo.
        </p>
        <div className="mt-8 flex flex-wrap gap-3">
          {lab[0] && (
            <Link
              href={`/posts/${lab[0].slug}/`}
              className="rounded-md bg-amarelo px-5 py-3 font-bold text-black hover:brightness-95"
            >
              Começar pelo tutorial
            </Link>
          )}
          <Link
            href="#newsletter"
            className="rounded-md border border-borda px-5 py-3 font-semibold text-texto hover:border-amarelo"
          >
            Receber por e-mail
          </Link>
        </div>
      </section>

      <Secao eixo="lab" posts={lab} />
      <Secao eixo="radar" posts={radar} />

      <section
        id="newsletter"
        className="mx-auto mt-20 max-w-5xl scroll-mt-8 px-4"
        aria-labelledby="titulo-newsletter"
      >
        <div className="grid gap-8 rounded-2xl border border-borda bg-painel p-6 sm:grid-cols-2 sm:p-10">
          <div>
            <h2 id="titulo-newsletter" className="text-2xl font-extrabold text-white">
              Um texto novo por vez, direto no e-mail
            </h2>
            <p className="mt-3 text-apagado">
              Sem spam e sem curso milagroso. O próximo tutorial e a próxima varredura do Radar, quando saírem.
            </p>
          </div>
          <FormularioNewsletter />
        </div>
      </section>
    </>
  );
}
