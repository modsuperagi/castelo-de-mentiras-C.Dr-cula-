import fs from "node:fs";
import path from "node:path";
import matter from "gray-matter";

const PASTA = path.join(process.cwd(), "content", "posts");

export type Pergunta = { pergunta: string; resposta: string };

export type Post = {
  slug: string;
  titulo: string;
  resumo: string;
  categoria: string;
  data: string; // AAAA-MM-DD
  preview?: string;
  github?: string;
  faq: Pergunta[];
  rascunho: boolean;
  conteudo: string;
};

function ler(arquivo: string): Post {
  const bruto = fs.readFileSync(path.join(PASTA, arquivo), "utf8");
  const { data, content } = matter(bruto);
  return {
    slug: arquivo.replace(/\.mdx$/, ""),
    titulo: String(data.titulo),
    resumo: String(data.resumo),
    categoria: String(data.categoria ?? "Tutorial"),
    data: String(data.data),
    preview: data.preview ? String(data.preview) : undefined,
    github: data.github ? String(data.github) : undefined,
    faq: Array.isArray(data.faq) ? (data.faq as Pergunta[]) : [],
    rascunho: Boolean(data.rascunho),
    conteudo: content,
  };
}

/** Só os posts publicados (rascunhos ficam fora do site, do sitemap e das rotas). */
export function listarPosts(): Post[] {
  return fs
    .readdirSync(PASTA)
    .filter((f) => f.endsWith(".mdx"))
    .map(ler)
    .filter((p) => !p.rascunho)
    .sort((a, b) => (a.data < b.data ? 1 : -1));
}

export function buscarPost(slug: string): Post | undefined {
  return listarPosts().find((p) => p.slug === slug);
}

export function dataBR(iso: string): string {
  const [a, m, d] = iso.split("-").map(Number);
  return new Date(Date.UTC(a, m - 1, d)).toLocaleDateString("pt-BR", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    timeZone: "UTC",
  });
}
