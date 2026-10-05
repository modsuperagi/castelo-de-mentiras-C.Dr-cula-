import type { Metadata } from "next";
import Link from "next/link";
import { site } from "@/lib/site";

export const metadata: Metadata = {
  title: "Sobre",
  description: `O que é o ${site.nome}: um laboratório de tutoriais práticos de agentes de IA em português.`,
  alternates: { canonical: "/sobre" },
};

export default function Sobre() {
  return (
    <div className="mx-auto max-w-leitura px-4 pt-14">
      <h1 className="text-3xl font-extrabold text-white sm:text-4xl">Sobre o {site.nome}</h1>
      <div className="conteudo mt-6 text-texto">
        <p>
          O {site.nome} é um laboratório de tutoriais práticos de agentes de IA, escrito em
          português. A ideia é simples: <strong>ensinar fazendo</strong>. Cada tutorial resolve um
          problema concreto, com código que você copia, roda e adapta.
        </p>
        <h2>O que você encontra aqui</h2>
        <ul>
          <li>Passo a passo curto, do zero até funcionando.</li>
          <li>Código completo, com botão de copiar.</li>
          <li>Comparações honestas entre ferramentas (LangChain, CrewAI, n8n e outras).</li>
          <li>Cenários do Brasil: loja, WhatsApp, logística, etiqueta, interior.</li>
        </ul>
        <h2>Como a gente escreve</h2>
        <ul>
          <li>Tudo às claras: o código que roda é o código que você vê.</li>
          <li>Sem número inventado. Quando um exemplo é ilustrativo, a gente diz que é.</li>
          <li>Sem promessa de renda fácil e sem pedir carteira de cripto.</li>
        </ul>
        <p>
          Quer receber o próximo tutorial? <Link href="/newsletter">Deixe seu e-mail</Link>.
        </p>
      </div>
    </div>
  );
}
