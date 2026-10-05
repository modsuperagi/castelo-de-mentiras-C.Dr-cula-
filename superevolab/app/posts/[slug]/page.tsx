import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { MDXRemote } from "next-mdx-remote/rsc";
import remarkGfm from "remark-gfm";
import { BlocoCodigo } from "@/components/BlocoCodigo";
import { FormularioNewsletter } from "@/components/FormularioNewsletter";
import { buscarPost, dataBR, listarPosts } from "@/lib/posts";
import { site } from "@/lib/site";

type Params = { params: { slug: string } };

export const dynamicParams = false;

export function generateStaticParams() {
  return listarPosts().map((p) => ({ slug: p.slug }));
}

export function generateMetadata({ params }: Params): Metadata {
  const post = buscarPost(params.slug);
  if (!post) return {};
  const url = `/posts/${post.slug}`;
  return {
    title: post.titulo,
    description: post.resumo,
    alternates: { canonical: url },
    openGraph: {
      type: "article",
      locale: "pt_BR",
      title: post.titulo,
      description: post.resumo,
      url,
      publishedTime: post.data,
    },
  };
}

const componentes = {
  pre: BlocoCodigo,
  table: (props: React.ComponentPropsWithoutRef<"table">) => (
    <div className="tabela">
      <table {...props} />
    </div>
  ),
};

export default function PaginaPost({ params }: Params) {
  const post = buscarPost(params.slug);
  if (!post) notFound();

  const jsonLd = [
    {
      "@context": "https://schema.org",
      "@type": "BlogPosting",
      headline: post.titulo,
      description: post.resumo,
      datePublished: post.data,
      inLanguage: "pt-BR",
      mainEntityOfPage: `${site.url}/posts/${post.slug}`,
      publisher: { "@type": "Organization", name: site.nome },
    },
    ...(post.faq.length
      ? [
          {
            "@context": "https://schema.org",
            "@type": "FAQPage",
            mainEntity: post.faq.map((f) => ({
              "@type": "Question",
              name: f.pergunta,
              acceptedAnswer: { "@type": "Answer", text: f.resposta },
            })),
          },
        ]
      : []),
  ];

  return (
    <article className="mx-auto max-w-leitura px-4 pt-10 sm:pt-14">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c") }}
      />
      <Link href="/" className="text-sm text-apagado hover:text-texto">
        ← Todos os tutoriais
      </Link>

      <header className="mt-6 border-b border-borda pb-8">
        <div className="flex items-center gap-3 text-xs">
          <span className="rounded-full border border-amarelo/40 px-2.5 py-0.5 font-medium uppercase tracking-wide text-amarelo">
            {post.categoria}
          </span>
          <time dateTime={post.data} className="text-apagado">
            {dataBR(post.data)}
          </time>
        </div>
        <h1 className="mt-4 text-3xl font-extrabold leading-tight tracking-tight text-white sm:text-4xl">
          {post.titulo}
        </h1>
        <p className="mt-4 rounded-lg border-l-4 border-amarelo bg-painel p-4 text-texto">
          {post.resumo}
        </p>
      </header>

      <div className="conteudo mt-8">
        <MDXRemote
          source={post.conteudo}
          components={componentes}
          options={{ mdxOptions: { remarkPlugins: [remarkGfm] } }}
        />
      </div>

      {post.github && (
        <p className="mt-10 rounded-lg border border-borda bg-painel p-4 text-sm">
          Código completo deste tutorial:{" "}
          <a href={post.github} className="font-semibold text-amarelo underline underline-offset-4">
            {post.github.replace(/^https?:\/\//, "")}
          </a>
        </p>
      )}

      {post.faq.length > 0 && (
        <section className="mt-14" aria-labelledby="faq">
          <h2 id="faq" className="text-2xl font-extrabold text-white">
            Perguntas frequentes
          </h2>
          <div className="mt-5 divide-y divide-borda rounded-xl border border-borda">
            {post.faq.map((f) => (
              <details key={f.pergunta} className="group p-4">
                <summary className="cursor-pointer list-none font-semibold text-texto marker:hidden">
                  <span className="mr-2 text-amarelo group-open:hidden">+</span>
                  <span className="mr-2 hidden text-amarelo group-open:inline">−</span>
                  {f.pergunta}
                </summary>
                <p className="mt-3 text-apagado">{f.resposta}</p>
              </details>
            ))}
          </div>
        </section>
      )}

      <section className="mt-16 rounded-2xl border border-borda bg-painel p-6 sm:p-8">
        <h2 className="text-xl font-extrabold text-white">Gostou? Receba o próximo tutorial</h2>
        <p className="mb-5 mt-2 text-sm text-apagado">Um por vez, direto no e-mail.</p>
        <FormularioNewsletter />
      </section>
    </article>
  );
}
