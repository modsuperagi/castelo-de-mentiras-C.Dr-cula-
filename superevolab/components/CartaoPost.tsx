import Link from "next/link";
import { dataBR, type Post } from "@/lib/posts";

export function CartaoPost({ post }: { post: Post }) {
  return (
    <article className="group relative flex min-w-0 flex-col rounded-xl border border-borda bg-painel p-5 transition hover:border-amarelo/60">
      <div className="mb-3 flex items-center justify-between gap-3 text-xs">
        <span className="rounded-full border border-amarelo/40 px-2.5 py-0.5 font-medium uppercase tracking-wide text-amarelo">
          {post.categoria}
        </span>
        <time dateTime={post.data} className="text-apagado">
          {dataBR(post.data)}
        </time>
      </div>
      <h2 className="text-lg font-bold leading-snug text-texto">
        <Link href={`/posts/${post.slug}`} className="after:absolute after:inset-0">
          {post.titulo}
        </Link>
      </h2>
      <p className="mt-2 line-clamp-2 text-sm text-apagado">{post.resumo}</p>
      {post.preview && (
        <pre className="mt-4 overflow-x-auto rounded-lg border border-borda bg-black p-3 font-mono text-xs leading-relaxed text-texto/80">
          <code>{post.preview}</code>
        </pre>
      )}
      <span className="mt-4 text-sm font-semibold text-amarelo group-hover:underline">
        Ler tutorial →
      </span>
    </article>
  );
}
