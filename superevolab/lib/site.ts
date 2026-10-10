export const site = {
  nome: "Super Evo Lab",
  descricao:
    "Agentes de IA em português: tutoriais que rodam (Lab) e varreduras com fonte sobre risco e governança (Radar SONAR).",
  url: (process.env.NEXT_PUBLIC_SITE_URL ?? "https://castelo-blog.pages.dev").replace(/\/$/, ""),
  lema: "Skills práticas. Quem aprende, evolui.",
  // Quem assina. Nome público provisório: confirmar com o Super antes de divulgar em canais.
  autor: {
    nome: "Super",
    frase: "Edita o Super Evo Lab e escreve com uma equipe de agentes de IA. A palavra final de cada texto é humana.",
  },
};

/** Os dois eixos de conteúdo. O terceiro, Sistema, mora em /sobre/. */
export const EIXOS = {
  lab: { nome: "Lab · Prática", selo: "Lab · mão na massa", botao: "Ler tutorial" },
  radar: { nome: "Radar · SONAR", selo: "Sinal SONAR", botao: "Ler análise" },
} as const;

export type Eixo = keyof typeof EIXOS;
