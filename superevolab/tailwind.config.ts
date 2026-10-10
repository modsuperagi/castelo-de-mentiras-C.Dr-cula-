import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        fundo: "#0A0A0A",
        painel: "#141414",
        borda: "#262626",
        texto: "#EDEDED",
        apagado: "#A3A3A3",
        amarelo: "#FFD60A",
      },
      fontFamily: {
        sans: ["var(--fonte-texto)", "system-ui", "sans-serif"],
        mono: ["var(--fonte-codigo)", "ui-monospace", "monospace"],
        serif: ["\"Iowan Old Style\"", "Palatino", "\"Palatino Linotype\"", "Georgia", "serif"],
      },
      maxWidth: { leitura: "44rem", artigo: "54rem" },
    },
  },
  plugins: [],
};

export default config;
