import type { Metadata, Viewport } from "next";
import Script from "next/script";
import { Inter, JetBrains_Mono } from "next/font/google";
import { Cabecalho } from "@/components/Cabecalho";
import { Rodape } from "@/components/Rodape";
import { site } from "@/lib/site";
import "./globals.css";

const texto = Inter({ subsets: ["latin"], variable: "--fonte-texto", display: "swap" });
const codigo = JetBrains_Mono({ subsets: ["latin"], variable: "--fonte-codigo", display: "swap" });

const GOOGLE_ADS_ID = process.env.NEXT_PUBLIC_GOOGLE_ADS_ID;

export const metadata: Metadata = {
  metadataBase: new URL(site.url),
  title: { default: `${site.nome} · tutoriais de agentes de IA`, template: `%s · ${site.nome}` },
  description: site.descricao,
  alternates: { canonical: "/" },
  openGraph: {
    type: "website",
    locale: "pt_BR",
    siteName: site.nome,
    title: site.nome,
    description: site.descricao,
    url: "/",
  },
  twitter: { card: "summary_large_image" },
};

export const viewport: Viewport = {
  themeColor: "#0A0A0A",
  width: "device-width",
  initialScale: 1,
};

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="pt-BR" className={`${texto.variable} ${codigo.variable}`}>
      <body className="min-h-screen font-sans">
        <Cabecalho />
        <main>{children}</main>
        <Rodape />
        {GOOGLE_ADS_ID && (
          <>
            <Script
              src={`https://www.googletagmanager.com/gtag/js?id=${GOOGLE_ADS_ID}`}
              strategy="afterInteractive"
            />
            <Script id="gtag" strategy="afterInteractive">
              {`window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments);}gtag('js',new Date());gtag('config','${GOOGLE_ADS_ID}');`}
            </Script>
          </>
        )}
      </body>
    </html>
  );
}
