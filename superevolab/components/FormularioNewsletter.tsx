"use client";

import { useState, type FormEvent } from "react";

type Estado = "parado" | "enviando" | "ok" | "erro";

declare global {
  interface Window {
    gtag?: (...args: unknown[]) => void;
  }
}

const FORMSPREE_ID = process.env.NEXT_PUBLIC_FORMSPREE_ID;
const CONVERSAO = process.env.NEXT_PUBLIC_GOOGLE_ADS_CONVERSAO;

export function FormularioNewsletter() {
  const [estado, setEstado] = useState<Estado>("parado");

  async function enviar(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!FORMSPREE_ID) {
      setEstado("erro");
      return;
    }
    setEstado("enviando");
    const dados = new FormData(e.currentTarget);
    try {
      const r = await fetch(`https://formspree.io/f/${FORMSPREE_ID}`, {
        method: "POST",
        body: dados,
        headers: { Accept: "application/json" },
      });
      if (!r.ok) throw new Error(String(r.status));
      setEstado("ok");
      if (CONVERSAO && window.gtag) {
        window.gtag("event", "conversion", { send_to: CONVERSAO });
      }
    } catch {
      setEstado("erro");
    }
  }

  if (estado === "ok") {
    return (
      <p className="rounded-lg border border-amarelo/50 bg-amarelo/10 p-4 text-texto">
        Pronto. Você vai receber os próximos tutoriais no seu e-mail.
      </p>
    );
  }

  return (
    <form onSubmit={enviar} className="flex flex-col gap-4">
      <label className="flex flex-col gap-1.5 text-sm">
        <span className="font-semibold text-texto">Seu e-mail</span>
        <input
          type="email"
          name="email"
          required
          autoComplete="email"
          placeholder="voce@exemplo.com"
          className="rounded-md border border-borda bg-black px-3 py-2.5 text-base text-texto placeholder:text-apagado/60 focus:border-amarelo focus:outline-none"
        />
      </label>
      <label className="flex flex-col gap-1.5 text-sm">
        <span className="font-semibold text-texto">
          O que você veio despertar em si mesmo? <span className="font-normal text-apagado">(opcional)</span>
        </span>
        <textarea
          name="despertar"
          rows={3}
          maxLength={500}
          className="rounded-md border border-borda bg-black px-3 py-2.5 text-base text-texto focus:border-amarelo focus:outline-none"
        />
      </label>
      <button
        type="submit"
        disabled={estado === "enviando"}
        className="rounded-md bg-amarelo px-4 py-3 font-bold text-black hover:brightness-95 disabled:opacity-60"
      >
        {estado === "enviando" ? "Enviando…" : "Quero receber os tutoriais"}
      </button>
      {estado === "erro" && (
        <p className="text-sm text-red-400" role="alert">
          {FORMSPREE_ID
            ? "Não deu para enviar agora. Tente de novo em instantes."
            : "O formulário ainda não está ligado. Volte em breve."}
        </p>
      )}
      <p className="text-xs text-apagado">
        Usamos seu e-mail só para mandar os tutoriais. Para sair, é só responder pedindo.
      </p>
    </form>
  );
}
