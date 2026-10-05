import Link from "next/link";
import { CartaoPost } from "@/components/CartaoPost";
import { FormularioNewsletter } from "@/components/FormularioNewsletter";
import { listarPosts } from "@/lib/posts";
import { site } from "@/lib/site";

export default function Home() {
  const posts = listarPosts();

  return (
    <>
      <section className="mx-auto max-w-5xl px-4 pb-12 pt-14 sm:pt-20">
        <p className="mb-4 font-mono text-sm text-amarelo">// agentes de IA, em português, na prática</p>
        <h1 className="max-w-3xl text-4xl font-extrabold leading-[1.1] tracking-tight text-white sm:text-6xl">
          Skills práticas. <span className="text-amarelo">Quem aprende, evolui.</span>
        </h1>
        <p className="mt-5 max-w-2xl text-lg text-apagado">
          Tutoriais curtos para criar agentes de IA que resolvem problema de verdade: atendimento,
          automação, etiqueta, entrega. Código que roda e casos daqui do Brasil.
        </p>
        <div className="mt-8 flex flex-wrap gap-3">
          {posts[0] && (
            <Link
              href={`/posts/${posts[0].slug}`}
              className="rounded-md bg-amarelo px-5 py-3 font-bold text-black hover:brightness-95"
            >
              Começar pelo tutorial #01
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

      <section className="mx-auto max-w-5xl px-4" aria-labelledby="titulo-posts">
        <h2 id="titulo-posts" className="mb-5 text-sm font-semibold uppercase tracking-widest text-apagado">
          Tutoriais
        </h2>
        <div className="grid gap-5 sm:grid-cols-2">
          {posts.map((p) => (
            <CartaoPost key={p.slug} post={p} />
          ))}
        </div>
        <p className="mt-6 text-sm text-apagado">
          Próximos: LangChain vs CrewAI vs AutoGen vs LlamaIndex, agente com a API do Grok, automação
          de etiquetas e envios.
        </p>
      </section>

      <section
        id="newsletter"
        className="mx-auto mt-20 max-w-5xl scroll-mt-8 px-4"
        aria-labelledby="titulo-newsletter"
      >
        <div className="grid gap-8 rounded-2xl border border-borda bg-painel p-6 sm:grid-cols-2 sm:p-10">
          <div>
            <h2 id="titulo-newsletter" className="text-2xl font-extrabold text-white">
              Um tutorial novo por vez, direto no e-mail
            </h2>
            <p className="mt-3 text-apagado">
              Sem spam e sem curso milagroso. Só o próximo passo prático para quem está construindo
              com IA. {site.nome}.
            </p>
          </div>
          <FormularioNewsletter />
        </div>
      </section>
    </>
  );
}
