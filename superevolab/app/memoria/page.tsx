import type { Metadata } from "next";
import { site } from "@/lib/site";

export const metadata: Metadata = {
  title: "Memória",
  description: `Linha do tempo do ${site.nome}: o que foi feito, quando e por quê.`,
  alternates: { canonical: "/memoria/" },
};

// Mais recente primeiro. Só entra o que de fato aconteceu, com data.
const MARCOS = [
  {
    data: "10 out 2026",
    titulo: "Dois eixos: Lab e Radar",
    texto:
      "Uma leitura de fora do próprio blog mostrou que ele tinha duas naturezas misturadas. O site passa a separar tutoriais (Lab) de varreduras (Radar SONAR), com selo de origem em cada texto e quem escreve no pé.",
  },
  {
    data: "10 out 2026",
    titulo: "Primeira análise do Radar",
    texto:
      "Sai “Agentes fora da caixa”, sobre escapes e intrusões de agentes de IA de maio a outubro de 2026. Com ela, o modelo editorial: menu de seções, etiquetas de evidência e tabelas que viram cartões no celular.",
  },
  {
    data: "8 out 2026",
    titulo: "Site estático e publicação grátis",
    texto:
      "O blog vira um site estático, sem servidor, e passa a ser publicado na Cloudflare sem custo.",
  },
  {
    data: "5 out 2026",
    titulo: "Nasce o Super Evo Lab",
    texto:
      "Estrutura do blog e o primeiro tutorial: um agente de WhatsApp para loja, com código em Python e um cenário no Vale do Aço.",
  },
];

export default function Memoria() {
  return (
    <div className="mx-auto max-w-leitura px-4 pt-14">
      <h1 className="text-3xl font-extrabold text-white sm:text-4xl">Memória</h1>
      <p className="mt-3 text-apagado">
        A linha do tempo do {site.nome}. O que mudou, quando e por quê, para quem chega depois entender o caminho.
      </p>
      <ol className="mt-10 border-l border-borda">
        {MARCOS.map((m) => (
          <li key={m.titulo} className="relative mb-10 pl-6">
            <span aria-hidden="true" className="absolute -left-[5px] top-1.5 h-2.5 w-2.5 rounded-full bg-amarelo" />
            <p className="font-mono text-xs uppercase tracking-wider text-amarelo">{m.data}</p>
            <h2 className="mt-1 text-lg font-bold text-white">{m.titulo}</h2>
            <p className="mt-1 text-apagado">{m.texto}</p>
          </li>
        ))}
      </ol>
    </div>
  );
}
