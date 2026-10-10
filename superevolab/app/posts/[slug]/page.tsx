import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { MDXRemote } from "next-mdx-remote/rsc";
import remarkGfm from "remark-gfm";
import { Cartao, Cartoes, Etiqueta, Legenda, Nota } from "@/components/Artigo";
import { BlocoCodigo } from "@/components/BlocoCodigo";
import { FormularioNewsletter } from "@/components/FormularioNewsletter";
import { buscarPost, dataBR, listarPosts } from "@/lib/posts";
import rehypeTabela from "@/lib/rehype-tabela";
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
      images: [{ url: "/og.png", width: 1200, height: 630 }],
    },
  };
}

const componentes = {
  pre: BlocoCodigo,
  Etiqueta,
  Nota,
  Cartoes,
  Cartao,
  Legenda,
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
    <article>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c") }}
      />

      <header className="border-b border-borda bg-black">
        <div className="mx-auto max-w-artigo px-4 pb-8 pt-8 sm:pt-12">
          <Link href="/" className="text-sm text-apagado hover:text-texto">
            ← Todos os textos
          </Link>
          <div className="mt-6 flex flex-wrap items-center gap-3 text-xs">
            <span className="rounded-full border border-amarelo/40 px-2.5 py-0.5 font-medium uppercase tracking-wide text-amarelo">
              {post.categoria}
            </span>
            <time dateTime={post.data} className="text-apagado">
              {dataBR(post.data)}
            </time>
          </div>
          {post.chapeu && (
            <p className="mt-5 text-xs font-medium uppercase tracking-[0.14em] text-apagado">{post.chapeu}</p>
          )}
          <h1 className="mt-3 text-balance font-serif text-4xl font-medium leading-[1.1] text-white sm:text-5xl">
            {post.titulo}
          </h1>
          <p className="mt-4 max-w-[64ch] font-serif text-lg leading-relaxed text-texto/85">{post.resumo}</p>
        </div>
      </header>

      {post.navegacao.length > 0 && (
        <nav aria-label="Seções" className="sticky top-0 z-10 overflow-x-auto whitespace-nowrap border-b border-borda bg-painel/95 backdrop-blur">
          <div className="mx-auto flex max-w-artigo gap-5 px-4 py-3 text-[13px]">
            {post.navegacao.map((s) => (
              <a key={s.id} href={`#${s.id}`} className="text-apagado hover:text-amarelo focus-visible:text-amarelo">
                {s.rotulo}
              </a>
            ))}
          </div>
        </nav>
      )}

      <div className="mx-auto max-w-artigo px-4">
      <div className="conteudo mt-8">
        <MDXRemote
          source={post.conteudo}
          components={componentes}
          options={{ mdxOptions: { remarkPlugins: [remarkGfm], rehypePlugins: [rehypeTabela] } }}
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
      </div>
    </article>
  );
}
