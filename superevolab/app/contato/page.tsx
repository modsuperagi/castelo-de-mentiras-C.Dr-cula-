import type { Metadata } from "next";
import Link from "next/link";
import { FormularioNewsletter } from "@/components/FormularioNewsletter";
import { site } from "@/lib/site";

export const metadata: Metadata = {
  title: "Contato",
  description: `Fale com quem escreve o ${site.nome}: dúvida, correção, sugestão de pauta ou caso para o Lab.`,
  alternates: { canonical: "/contato/" },
};

export default function Contato() {
  return (
    <div className="mx-auto max-w-xl px-4 pt-14">
      <h1 className="text-3xl font-extrabold text-white sm:text-4xl">Contato</h1>
      <p className="mb-8 mt-3 text-apagado">
        Achou um erro, tem um caso que daria um bom tutorial ou quer sugerir uma varredura para o Radar? Escreva
        aqui. Correção de fato tem prioridade e entra no próprio texto, com a data.
      </p>
      <FormularioNewsletter tipo="contato" />
      <p className="mt-8 text-sm text-apagado">
        Só quer receber os textos? <Link href="/newsletter/" className="text-amarelo underline underline-offset-4">Assine a newsletter</Link>.
      </p>
    </div>
  );
}
