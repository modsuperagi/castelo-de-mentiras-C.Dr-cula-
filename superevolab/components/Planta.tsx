// A planta da estrutura: o castelo em traço de projeto, com as quatro partes que o cliente usa.
export function Planta() {
  return (
    <svg
      viewBox="0 0 560 430"
      className="planta h-auto w-full"
      role="img"
      aria-label="Planta da estrutura: a porta é a sua conta, as salas são os seus agentes, a mesa é onde eles confrontam o que acharam e o cofre guarda o que é sensível."
    >
      <g className="traco" fill="none">
        <path pathLength={1} d="M20 360H430" />
        {/* torres laterais */}
        <path pathLength={1} d="M60 360V190H140M340 190H420V360" />
        <path pathLength={1} d="M55 190L100 140L145 190M335 190L380 140L425 190" />
        {/* corpo e andares */}
        <path pathLength={1} d="M140 360V150H340V360M140 220H340M140 290H340" />
        {/* torre central */}
        <path pathLength={1} d="M205 150V70H275V150M200 70L240 20L280 70" />
        {/* salas */}
        <path pathLength={1} d="M155 232h50v46h-50zM215 232h50v46h-50zM275 232h50v46h-50zM75 230h50v50h-50zM355 230h50v50h-50z" />
        {/* mesa */}
        <path pathLength={1} d="M200 195a40 10 0 1 0 80 0a40 10 0 1 0 -80 0M212 203v12M268 203v12" />
        {/* porta */}
        <path pathLength={1} d="M215 360V320A25 25 0 0 1 265 320V360" />
        {/* cofre */}
        <path pathLength={1} d="M200 372h80v46h-80zM240 387a8 8 0 1 0 0.01 0M240 403v10" />
      </g>
      <g className="guia" fill="none">
        <path d="M282 195H442M330 255H442M266 340H442M282 395H442" />
      </g>
      <g className="ponto">
        <circle cx="240" cy="195" r="3.5" />
        <circle cx="300" cy="255" r="3.5" />
        <circle cx="240" cy="340" r="3.5" />
        <circle cx="240" cy="395" r="3.5" />
      </g>
      <g className="rotulo">
        <text x="450" y="201">Mesa</text>
        <text x="450" y="261">Salas</text>
        <text x="450" y="346">Porta</text>
        <text x="450" y="401">Cofre</text>
      </g>
    </svg>
  );
}
