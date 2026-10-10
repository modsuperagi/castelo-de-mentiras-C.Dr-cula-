import type { Metadata } from "next";
import { Planta } from "@/components/Planta";
import { produto } from "@/lib/produto";

const descricao = `${produto.nome}: a estrutura brasileira onde a sua equipe de agentes de IA trabalha com fonte, registro e aprovação humana. Beta de ${produto.meses} meses.`;

export const metadata: Metadata = {
  title: `${produto.nome} · beta`,
  description: descricao,
  alternates: { canonical: "/sonar/" },
  openGraph: { title: `${produto.nome} · beta`, description: descricao, url: "/sonar/" },
};

const PARTES = [
  { nome: "Porta", texto: "A sua conta, com login e senha. Só a sua equipe entra." },
  {
    nome: "Salas",
    texto: "Cada agente da sua equipe tem uma sala: um papel, instruções e só as ferramentas que você liberou.",
  },
  {
    nome: "Mesa",
    texto: "Onde os agentes confrontam o que encontraram: o que confirma, o que contradiz e o que ainda está em aberto.",
  },
  {
    nome: "Cofre",
    texto: "O que é sensível fica guardado. Regra da casa: nunca pedimos a senha das suas outras contas.",
  },
];

const ETAPAS = [
  "Conta e equipe: login, senha e convite para quem trabalha com você.",
  "Cadastro de agentes: a ficha de cada um, com papel, instruções e permissões.",
  "Investigação com fontes: os agentes pesquisam, a estrutura organiza e você aprova o que segue.",
  "Motor próprio: a Nemotron rodando e ajustada por nós.",
];

const PERGUNTAS = [
  {
    p: "O que eu recebo ao assinar?",
    r: `Acesso ao ${produto.nome} durante os ${produto.meses} meses do beta, com uso total das ferramentas conforme elas forem liberadas.`,
  },
  {
    p: "Como é a cobrança?",
    r: `${produto.preco} por mês, a partir do primeiro pagamento, durante ${produto.meses} meses. O pagamento é feito pela InfinitePay.`,
  },
  {
    p: "Como recebo o acesso?",
    r: "Pelo contato que você informar no pagamento. A cada ferramenta liberada, você é avisado por ali.",
  },
  {
    p: "Onde ficam os meus dados?",
    r: `Num ambiente só do ${produto.nome}, separado de tudo o mais. Não pedimos a senha das suas outras contas.`,
  },
];

function Assinar({ className = "" }: { className?: string }) {
  return (
    <a href={produto.assinatura} target="_blank" rel="noopener" className={`beta-botao ${className}`}>
      Assinar o beta
    </a>
  );
}

export default function Sonar() {
  return (
    <div className="beta">
      <section className="mx-auto grid max-w-6xl items-center gap-10 px-4 pb-16 pt-14 md:grid-cols-[1.05fr_1fr] md:pt-20">
        <div>
          <p className="beta-marca">{produto.nome}, em beta</p>
          <h1 className="beta-titulo mt-4">Você monta a equipe de agentes. A estrutura é nossa.</h1>
          <p className="beta-texto mt-6 max-w-[34rem] text-lg">
            Uma estrutura brasileira para agentes de IA trabalharem juntos: cada um com o seu papel, toda resposta
            com fonte, e nenhuma ação importante sem a sua aprovação.
          </p>
          <div className="mt-9 flex flex-wrap items-center gap-x-6 gap-y-3">
            <Assinar />
            <a href="#beta" className="beta-link">
              Ver o que está incluído
            </a>
          </div>
          <p className="beta-nota mt-4">
            {produto.preco} por mês, durante {produto.meses} meses.
          </p>
        </div>
        <Planta />
      </section>

      <section className="mx-auto max-w-6xl px-4 py-16">
        <h2 className="beta-subtitulo max-w-[30rem]">Por dentro da estrutura</h2>
        <dl className="mt-10 grid gap-x-12 gap-y-9 sm:grid-cols-2">
          {PARTES.map((parte) => (
            <div key={parte.nome} className="beta-parte">
              <dt>{parte.nome}</dt>
              <dd>{parte.texto}</dd>
            </div>
          ))}
        </dl>
      </section>

      <section className="mx-auto max-w-6xl px-4 py-16">
        <h2 className="beta-subtitulo">Como funciona</h2>
        <ol className="beta-passos mt-10">
          <li>Assine o beta e receba o acesso.</li>
          <li>Monte a sua equipe e cadastre os seus agentes, cada um com o seu papel.</li>
          <li>Peça uma investigação. Os agentes pesquisam, a estrutura organiza as fontes e você aprova o que segue.</li>
        </ol>
      </section>

      <section className="mx-auto max-w-6xl px-4 py-16">
        <div className="max-w-[40rem]">
          <h2 className="beta-subtitulo">Um motor aberto</h2>
          <p className="beta-texto mt-5 text-lg">
            A estrutura roda sobre a Nemotron 3 Super, um modelo da NVIDIA com pesos abertos. Isso quer dizer que
            podemos rodar, ajustar e treinar o motor do nosso jeito, em vez de depender de uma caixa-preta.
          </p>
        </div>
      </section>

      <section id="beta" className="mx-auto grid max-w-6xl gap-12 px-4 py-16 md:grid-cols-2">
        <div className="beta-plano">
          <h2 className="beta-subtitulo">Plano beta</h2>
          <p className="beta-preco mt-6">
            {produto.preco}
            <span> por mês</span>
          </p>
          <ul className="beta-lista mt-6">
            <li>Cobrança mensal a partir do primeiro pagamento</li>
            <li>Duração de {produto.meses} meses</li>
            <li>Uso total das ferramentas durante o beta, conforme elas entram no ar</li>
          </ul>
          <Assinar className="mt-8" />
          <p className="beta-nota mt-4">Pagamento processado pela InfinitePay.</p>
        </div>
        <div>
          <h2 className="beta-subtitulo">O que entra, e em que ordem</h2>
          <p className="beta-texto mt-5">
            O beta é a construção acontecendo com você dentro. As ferramentas entram por etapas, e quem assina usa
            cada uma assim que ela é liberada.
          </p>
          <ol className="beta-etapas mt-7">
            {ETAPAS.map((e) => (
              <li key={e}>{e}</li>
            ))}
          </ol>
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-4 py-16">
        <h2 className="beta-subtitulo">Perguntas</h2>
        <div className="mt-8 max-w-[44rem]">
          {PERGUNTAS.map((q) => (
            <details key={q.p} className="beta-pergunta">
              <summary>{q.p}</summary>
              <p>{q.r}</p>
            </details>
          ))}
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-4 pb-24 pt-10">
        <h2 className="beta-titulo beta-titulo--menor max-w-[36rem]">Entre enquanto a estrutura é construída.</h2>
        <Assinar className="mt-8" />
      </section>
    </div>
  );
}
