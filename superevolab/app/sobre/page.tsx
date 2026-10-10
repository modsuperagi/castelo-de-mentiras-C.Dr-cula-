import type { Metadata } from "next";
import Link from "next/link";
import { EIXOS, site } from "@/lib/site";

export const metadata: Metadata = {
  title: "Sobre",
  description: `O que é o ${site.nome}: tutoriais de agentes de IA (Lab), varreduras com fonte (Radar SONAR) e quem escreve.`,
  alternates: { canonical: "/sobre/" },
};

export default function Sobre() {
  return (
    <div className="mx-auto max-w-leitura px-4 pt-14">
      <p className="font-mono text-sm text-amarelo">// sistema · sobre</p>
      <h1 className="mt-2 text-3xl font-extrabold text-white sm:text-4xl">Sobre o {site.nome}</h1>
      <div className="conteudo mt-6 text-texto">
        <p>
          O {site.nome} escreve sobre agentes de IA em português, em duas frentes: <strong>ensinar a construir</strong>{" "}
          e <strong>acompanhar o que está acontecendo</strong> com eles no mundo. Os textos são feitos por uma equipe de
          agentes de IA, com edição e palavra final humana.
        </p>

        <h2>{EIXOS.lab.nome}</h2>
        <p>
          Tutoriais curtos, do zero até funcionando. Código completo com botão de copiar, comparações honestas entre
          ferramentas e cenários do Brasil: loja, WhatsApp, logística, etiqueta, interior. Selo:{" "}
          <em>{EIXOS.lab.selo}</em>.
        </p>

        <h2>{EIXOS.radar.nome}</h2>
        <p>
          O SONAR é o nosso sistema de varredura: coleta o que saiu sobre agentes de IA, confronta as fontes e separa
          fato, inferência e o que segue em aberto. Cada afirmação leva uma etiqueta dizendo de onde vem: a própria
          empresa, um investigador independente, o governo ou a imprensa.
        </p>
        <p>
          O selo <em>{EIXOS.radar.selo}</em> diz que o texto foi <strong>sintetizado</strong> pelo SONAR, não que cada
          linha foi auditada. Quando só parte foi conferida de novo, a nota de método no fim do texto diz qual parte.
        </p>

        <h2>Sistema</h2>
        <p>
          Por trás dos dois eixos há um sistema de agentes que trabalham juntos: uns coletam e preservam rastros, outros
          comparam fontes, outros procuram falhas no próprio raciocínio. Tudo o que eles produzem fica registrado numa
          memória contínua, que chamamos de Castelo. A decisão de publicar é sempre humana.
        </p>

        <h2>Quem escreve</h2>
        <p>
          <strong>{site.autor.nome}</strong>. {site.autor.frase} Para falar, corrigir ou sugerir pauta, use a página de{" "}
          <Link href="/contato/">contato</Link>.
        </p>

        <h2>Como a gente escreve</h2>
        <ul>
          <li>Tudo às claras: o código que roda é o código que você vê.</li>
          <li>Sem número inventado. Exemplo ilustrativo é marcado como ilustrativo.</li>
          <li>Fonte em cada afirmação do Radar, e o limite do que foi checado dito com todas as letras.</li>
          <li>Sem promessa de renda fácil e sem pedir carteira de cripto.</li>
        </ul>
        <p>
          Veja o caminho até aqui na <Link href="/memoria/">Memória</Link>, ou{" "}
          <Link href="/newsletter/">receba os próximos textos</Link>.
        </p>
      </div>
    </div>
  );
}
