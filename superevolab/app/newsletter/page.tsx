import type { Metadata } from "next";
import { FormularioNewsletter } from "@/components/FormularioNewsletter";

export const metadata: Metadata = {
  title: "Newsletter e contato",
  description: "Receba os próximos tutoriais de agentes de IA em português no seu e-mail.",
  alternates: { canonical: "/newsletter" },
};

export default function Newsletter() {
  return (
    <div className="mx-auto max-w-xl px-4 pt-14">
      <h1 className="text-3xl font-extrabold text-white sm:text-4xl">Newsletter e contato</h1>
      <p className="mb-8 mt-3 text-apagado">
        Deixe seu e-mail para receber os próximos tutoriais. Quer falar com a gente? Responda
        qualquer e-mail da newsletter.
      </p>
      <FormularioNewsletter />
    </div>
  );
}
