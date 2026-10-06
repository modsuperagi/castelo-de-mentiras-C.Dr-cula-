import { ImageResponse } from "next/og";
import { site } from "@/lib/site";

export const alt = site.nome;
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default function Imagem() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          padding: 80,
          background: "#0A0A0A",
          color: "#EDEDED",
        }}
      >
        <div style={{ fontSize: 34, color: "#FFD60A", fontFamily: "monospace" }}>{`>_ ${site.nome}`}</div>
        <div style={{ fontSize: 72, fontWeight: 800, marginTop: 24, lineHeight: 1.1 }}>Skills práticas.</div>
        <div style={{ fontSize: 72, fontWeight: 800, color: "#FFD60A", lineHeight: 1.1 }}>Quem aprende, evolui.</div>
        <div style={{ fontSize: 30, marginTop: 36, color: "#A3A3A3" }}>Tutoriais de agentes de IA em português</div>
      </div>
    ),
    size,
  );
}
