# Projeto 3 · Mariana — SONAR Pesquisa Contínua Programada

> **Em uma frase:** a pessoa cadastra um tema com objetivo, frequência e profundidade. O SONAR pesquisa sozinho no ritmo escolhido, cada entrega amplia a anterior, e a Mesa Trina (Arquiteto, Engenheiro, Verificador) diz o que mudou e por quê.

Proposta original: `originais/mariana.md`. Base comum: `01-BASE-COMUM.md`.

## 1. O que veio da Mariana

- **Entrada limpa**, desktop-first (1400 px), fundo claro e cartões brancos.
- **Painel Pesquisa Contínua Programada:** tema, objetivo, frequência (diária, semanal ou mensal) e profundidade. Cada nova pesquisa programada atualiza a Mesa Trina.
- **Mesa Trina como base:** três colunas lado a lado: Arquiteto, Engenheiro e Verificador.
- **Entregas que se ampliam:** linha do tempo vertical, Entrega 01 → Entrega 02 (selo "amplia Entrega 01") → Entrega 03. Cada entrega abre com resumo, fontes e conflitos.
- **Fluxo:** cadastro obrigatório → planos de uso → acesso.
- **Planos:**
  - Acadêmico Universitário: fontes primárias, ABNT, síntese de literatura;
  - Acompanhamento Tecnológico: radar semanal, monitoramento, alertas;
  - Ciência Teórica: investigação profunda, confronto de modelos.
- **Barra superior de 64 px:**
  - Alertas e Notificações (gaveta);
  - Bloco de Anotações profissional (gaveta com editor);
  - Calculadora profissional (janela funcional);
  - Blog completo (destaque, grade, categorias e busca);
  - Colaboradores (grade);
  - Contato profissional (formulário que gera rascunho local).
- **Ferramentas para o Claude Code:** MCP Apps, Chrome DevTools MCP, Web Framework Development, MCPs de pesquisa, Code Review/Strix e memória persistente (engram). O mínimo viável seria MCP Apps, Chrome DevTools MCP, Web Framework Development, um MCP de pesquisa e memória persistente.
- **Observação:** o texto começa no item 3. Os itens 1 e 2 não chegaram, e o link do Meta AI não abre deste ambiente. É preciso pedir à Mariana.

## 2. O que o Plasma completou

- o público e o uso de cada plano, e onde entram os escritórios (M1);
- como a entrega "amplia" a anterior de verdade;
- a agenda e o custo, com lotes pela metade do preço;
- o aviso por e-mail, o banco, o preço, as fases e o que conferir.

Nada foi cortado. Blog, colaboradores, calculadora e contato entram depois da primeira venda.

## 3. Para quem, primeiro

- **Acadêmico Universitário:** quem está no TCC, no mestrado ou no doutorado e precisa acompanhar a literatura de um tema (artigos novos, revisões, retratações), com referências em ABNT.
- **Acompanhamento Tecnológico:** engenharia de dados e times de tecnologia acompanhando ferramentas, versões, falhas de segurança, artigos e regulação.
- **Escritórios e empresas** (sugestão do Plasma): acompanhar a legislação e a jurisprudência de um tema, e a regulação do setor.
  - Fontes: LexML, DataJud do CNJ e diários oficiais (conferir a cobertura).
  - Decisão M1 na cédula.
- **Ciência Teórica:** fase posterior, porque investigação profunda e confronto de modelos custam mais e pedem revisão definida.

## 4. Como a pessoa usa

1. Cadastro → escolhe o plano → painel.
2. **Nova pesquisa programada:** tema ("novidades sobre X"), objetivo ("para o capítulo 2 do meu TCC"), frequência e profundidade (rápida, padrão, profunda).
3. **A Entrega 01 sai na hora:** uma investigação completa, que vira a linha de base. Assim a pessoa não espera a semana seguinte para ver valor.
4. Nas datas seguintes, o SONAR procura só o que é novo desde a entrega anterior, compara e publica a **Entrega 02 (amplia a 01)**: o que é novo, o que confirma, o que contradiz e o que não mudou.
5. **A Mesa Trina de cada entrega**, em três colunas:
   - **Arquiteto:** onde a novidade se encaixa no que já se sabia;
   - **Engenheiro:** o método ou o dado se sustenta?
   - **Verificador:** cadê a evidência (fonte primária, conflitos, limites).
6. **O e-mail sai só quando há mudança relevante.**
   - Quem decide o que é relevante é o Verificador, com regra escrita.
   - Entrega sem novidade vira uma linha ("Sem novidade relevante nesta semana; 14 fontes conferidas") e não gera e-mail.

**Telas do produto mínimo:** Painel (temas e próximas entregas) · Nova pesquisa programada · Linha do tempo do tema · Mesa Trina da entrega · Conta. Barra: Painel · Notificações · Conta.

## 5. A Mesa Trina neste projeto

- É a Mesa do próprio Castelo: Arquiteto, Engenheiro e Verificador, com as lentes das Trindades já registradas. Aristóteles classifica; Wiener pergunta se o laço fecha; Sócrates e Diógenes marcam limite e incoerência.
- São três chamadas separadas, só com o dossiê da entrega e o resumo da anterior. Quem coletou não julga.
- O Verificador tem a palavra final sobre o que é relevante e sobe para o e-mail.
- É o projeto mais fiel ao organismo: a Mesa que o cliente vê é a mesma que valida o Castelo.

## 6. Como a entrega amplia a anterior

- Cada tema guarda as fontes já vistas. A rodada nova busca com filtro de data (GDELT, arXiv, Crossref e OpenAlex aceitam) e descarta o que já foi visto.
- A consolidação compara com a entrega anterior e marca cada ponto como **novo**, **confirma**, **contradiz** ou **sem mudança**.
- Toda entrega aponta para a anterior, e nada é sobrescrito: a linha do tempo é a linhagem do tema.

## 7. Arquitetura

| Camada | Escolha | Reaproveita |
|---|---|---|
| Tela | Next.js e TypeScript (o framework web que a Mariana aponta); tema claro, desktop-first em 1400 px e responsiva para ler aviso e entrega no celular | estados de `sonar/public/app.js`; formato das 8 partes |
| Agenda | `pg_cron` no Supabase: a cada 15 minutos pega os temas vencidos e põe na fila (`pgmq`) | — |
| Trabalhador | etapas curtas (base comum); as rodadas programadas vão pela API de lotes da Anthropic, pela metade do preço e com resultado em até 24 horas | `sonar/lib/busca/`, `sintese.js`, `curadoria.js` |
| Banco | projeto Supabase do SONAR | — |
| Referências ABNT | formatador que não depende de IA, a partir dos metadados do Crossref e do OpenAlex (autores, título, ano, DOI), com testes | — |
| Aviso | e-mail transacional (cota gratuita no começo) e gaveta de notificações | — |
| IA | motor da base comum (D2) | — |

## 8. Banco (projeto do SONAR)

| Tabela | Guarda |
|---|---|
| `perfis` | plano, consentimentos, preferências de aviso |
| `temas` | tema, objetivo, frequência, profundidade, próxima execução, se está ativo |
| `entregas` | número, a entrega que ela amplia, resumo, novidades, marcas (novo, confirma, contradiz, sem mudança), custo |
| `fontes_vistas` | por tema, para não repetir |
| `investigacoes`, `rodadas`, `fontes`, `evidencias`, `posicoes`, `consolidacoes` | as do motor comum, ligadas à entrega |
| `notificacoes` | o que avisar e se foi lido |
| `uso` | temas ativos e entregas do mês |

RLS: o dono lê e escreve o que é seu; a agenda e o trabalhador escrevem pelo servidor.

## 9. Planos e preço

Custo de IA por tema, no motor econômico e com lotes: cada entrega nova custa ~R$ 0,55 (rápida) ou ~R$ 0,90 (padrão). A primeira entrega é uma investigação completa (~R$ 1,80).

| Ritmo | Entregas no mês | Custo por tema por mês (econômico) | Custo por tema por mês (máximo) |
|---|---|---|---|
| Mensal | 1 | ~R$ 0,55 | ~R$ 1,70 |
| Semanal | ~4 | ~R$ 2,40 | ~R$ 7,40 |
| Diário | ~30 | ~R$ 16,50 | ~R$ 51 |

**Proposta de preço** (motor econômico; com o máximo, triplica):

| Plano | Preço por mês | Inclui |
|---|---|---|
| Acadêmico Universitário | R$ 24,90 | 3 temas semanais; referências em ABNT; síntese de literatura |
| Acompanhamento Tecnológico | R$ 49,90 | 6 temas semanais; alertas |
| Tema diário (adicional) | + R$ 49,90 por tema | para quem precisa todo dia |
| Ciência Teórica | depois | profundidade e confronto de modelos, com revisão definida |

É o projeto com a receita mais estável: quem acompanha um tema paga enquanto o tema importa.

## 10. Fases do início ao fim

| Fase | Entrega | Portão | Prazo |
|---|---|---|---|
| F0 · Preparar | projeto Supabase do SONAR; Vercel; chaves; primeira busca real; três temas piloto de verdade, um por público | a busca real responde com filtro de data | 2 a 3 dias |
| F1 · Motor, "só o novo" e prova | motor comum; modo "só o novo"; comparação com a entrega anterior; os três temas rodando todo dia por 7 dias (21 entregas); teste de qualidade | o teste passa; as entregas não se repetem e não têm fonte inventada; custo por entrega medido com lotes; D2 | 1 semana |
| F2 · Produto mínimo | cadastro; painel; nova pesquisa; linha do tempo; Mesa em três colunas; e-mail de entrega; RLS testada | 3 temas de ponta a ponta por 5 dias sem falha de agenda | 1 a 1,5 semana |
| F3 · Beta fechado | 5 a 10 pessoas com pelo menos um tema ativo | cada uma abre pelo menos 2 entregas; nenhuma falha grave | 1 semana |
| F4 · Lançamento pago | Acadêmico e Tecnológico; pagamento; termos | aprovação do Guardião; primeira venda | 2 a 3 dias |
| F5 · Mês 2 | gaveta de alertas e notificações completa; bloco de anotações por tema; exportar a linha do tempo com ABNT; tema jurídico | — | — |
| F6 · Mês 3 em diante | Ciência Teórica; calculadora; blog (aproveitando o do Espelho); colaboradores; contato; MCP Apps (entregas dentro do Claude e do ChatGPT) | pedido de cliente ou dado de uso | — |

Da ordem do Guardião até a primeira venda: cerca de 4 semanas.

## 11. Riscos e como conter

| Risco | Contenção |
|---|---|
| O valor chegar depois (a pessoa espera a próxima entrega) | a Entrega 01 sai na hora, completa |
| Entrega sem novidade parecer vazia | uma linha honesta ("sem novidade relevante; N fontes conferidas") e nenhum e-mail |
| Agenda falhar em silêncio | cada tema mostra a última e a próxima execução; falha vira aviso ao Plasma e ao cliente |
| Tema diário ficar caro | diário só como adicional pago; lotes pela metade do preço |
| Desktop-first esquecer o celular | aviso e leitura de entrega responsivos desde o produto mínimo |
| "Radar semanal" ser confundido com o Radar P0 do Espelho | nome do recurso a definir no marketing |

## 12. P0 na proposta: o que conferir

- **Itens 1 e 2** do documento não chegaram (o texto começa no 3).
- **MCP Apps:** extensão do MCP para telas dentro do chat; existe (conferir o estado). Serve na F6, não no produto mínimo.
- **Chrome DevTools MCP:** existe; o Plasma já tem o equivalente (Chromium e Playwright) para conferir as telas.
- **"Web Framework Development":** nome de plugin não confirmado. O necessário é o framework (Next.js e TypeScript), não um plugin.
- **MCPs de pesquisa:** servem para desenvolver, não para o produto. O produto usa a busca própria do SONAR, com origem rastreável.
- **Strix:** agente aberto de teste de segurança. É útil antes do lançamento, só contra a versão de teste e com ordem do Guardião.
- **engram (memória persistente):** não confirmado. A memória do organismo já é o Castelo, e a do produto é o projeto do SONAR.
- **Calculadora profissional:** falta dizer para que serve em cada plano (estatística? unidades? juros?). Sem isso, fica de fora.

## 13. O que o marketing recebe

- **Frase do produto** (o marketing reescreve): "Escolha um tema. O SONAR acompanha por você e mostra o que mudou, com fonte."
- **Demonstração:** três temas piloto rodando há uma semana, com a linha do tempo.
- **Entrada:** Acadêmico a R$ 24,90.
- **Público do lançamento:** universitários e times de tecnologia, e escritórios se M1 passar.
