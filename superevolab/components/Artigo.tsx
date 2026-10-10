// Peças do texto editorial, usadas dentro do MDX dos posts.

const ETIQUETAS = {
  empresa: "Empresa",
  independente: "Independente",
  governo: "Governo",
  imprensa: "Imprensa",
  aberto: "Em aberto",
} as const;

export type TipoEtiqueta = keyof typeof ETIQUETAS;

/** Grau de evidência de uma afirmação. */
export function Etiqueta({ tipo }: { tipo: TipoEtiqueta }) {
  return <span className={`etiqueta etiqueta-${tipo}`}>{ETIQUETAS[tipo] ?? tipo}</span>;
}

/** Caixa de aviso no começo do texto ("Como ler"). */
export function Nota({ children }: { children: React.ReactNode }) {
  return <aside className="nota">{children}</aside>;
}

/** Grade de cartões de destaque (duas colunas; uma no celular). */
export function Cartoes({ children }: { children: React.ReactNode }) {
  return <div className="cartoes">{children}</div>;
}

export function Cartao({ titulo, children }: { titulo: string; children: React.ReactNode }) {
  return (
    <div className="cartao">
      <strong>{titulo}</strong>
      {children}
    </div>
  );
}

/** Legenda das etiquetas, uma por linha. */
export function Legenda({ children }: { children: React.ReactNode }) {
  return <div className="legenda">{children}</div>;
}
