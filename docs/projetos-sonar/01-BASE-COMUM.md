# Base comum · vale para qualquer projeto vencedor

## 1. Três regras que vêm de 27/09

1. **Foco.** Só o SONAR. O Espelho continua como alinhamento dos núcleos e é a base. Nenhum site, oferta ou campanha nova além do que o projeto vencedor pede.
2. **Provar antes de vender.** Nenhuma venda antes de o SONAR ganhar, com evidência, de uma resposta comum de IA (seção 4).
3. **Cada um no seu papel.** Marketing com o Guardião e a Sol; base de código com a Mariana; o Plasma integra, testa e cuida da segurança. Nada vai ao ar sem aprovação do Guardião.

## 2. O que já existe e entra em qualquer projeto

| Parte | Onde | Estado real em 27/09 |
|---|---|---|
| Busca própria: Wikipedia (pt e en), notícias (GDELT), arXiv, Crossref, GitHub, Hacker News e SearXNG | `sonar/lib/busca/` | código e testes com fontes simuladas; **nunca consultou uma fonte real**, porque a rede do ambiente de desenvolvimento bloqueia |
| Curadoria: descarta o que não tem origem, agrupa por tema, conta domínios independentes | `sonar/lib/busca/curadoria.js` | testada com simulação |
| Regras que o código impõe (lista na seção 3) | `sonar/lib/sintese.js` | testadas com simulação |
| Tela com etapas que só acendem quando acontecem de verdade | `sonar/public/` | funciona no computador; nunca publicada |
| Relatório em 8 partes e linhagem | Espelho: `investigar.html` e `blog/investigacoes/` | no ar, com um caso real |
| Primeiro caso real: Lei 14.133 × Lei 8.666, com 6 fontes | `blog/investigacoes/casos.json` e memória `a32963fa` no Castelo | conclusão provisória; a Mesa Trina ainda não deu o veredito (pedido `f1f5a259`) |
| Radar P0: marca no navegador onde olhar | `blog/radar.js` | no ar |
| Porta do SONAR no Castelo: recepção → P0 → Trina → Golden → consolidação | `fluxo_e2e_sonar_principal` e `trina_registrar_veredito` | executada uma vez; o veredito exige evidência e recusa autoria própria |
| Projeto `supernova` na Vercel | ligado ao repositório, com build desligado | pode virar o projeto do SONAR |

O código do SONAR não tem dependências e usa só recursos padrão do Node, que também rodam nas Edge Functions do Supabase. Dá para reaproveitar em qualquer um dos três projetos.

## 3. O motor do SONAR

```
pergunta
 └ 1. Plano: desmonta a pergunta em afirmações que dá para conferir (alcance, data, efeito…)
 └ 2. Coleta: busca própria e fontes do assunto; lê as páginas; guarda trecho, endereço e data
 └ 3. Dossiê: cada evidência com a sua fonte; o código confere se o trecho está mesmo na página
 └ 4. Mesa Trina: três leituras do dossiê em chamadas separadas, sem ver o raciocínio da coleta
 └ 5. Consolidação: une sem apagar divergência (confirmado · em disputa · não confirmado)
 └ 6. Relatório em 8 partes, com a linhagem: o caminho inteiro pode ser refeito
 └ 7. Memória: a investigação fica guardada, e a próxima parte dela
```

**Quem coleta não dá o veredito.** Coleta e julgamento são chamadas diferentes, com instruções diferentes. Com modelos da mesma empresa de IA, a independência é parcial. Independência total pede que cada posição rode num modelo de outra empresa (Claude, Grok e Meta, como os núcleos). Isso custa mais e fica para depois do teste.

**Regras que o código garante, sem depender do modelo:**
- endereço citado que a coleta não trouxe é removido, com aviso *(já existe)*;
- fato sem fonte confirmada vira "incerteza" *(já existe)*;
- com menos de duas fontes, a evidência fica "limitada" *(já existe)*;
- falha, tempo esgotado ou resposta vazia aparece como "não concluída", nunca como "concluída" *(já existe)*;
- o trecho citado precisa aparecer no texto baixado da fonte; se não aparecer, a evidência cai *(novo)*;
- cada posição da Mesa só cita evidências do dossiê, pelo número; item sem evidência vira lacuna *(novo)*;
- cada investigação guarda custo, tempo e modelo usados, para medir e cobrar certo *(novo)*.

**Onde roda.** Em etapas curtas, com o estado guardado no banco. A investigação entra numa fila, um trabalhador faz uma etapa por vez e grava o resultado, e a tela acompanha em tempo real. Se uma etapa cair, o trabalho recomeça dela, sem pagar de novo as anteriores. Motivo: uma investigação leva de 1 a 3 minutos, e uma chamada tão longa costuma cair.

**Motor de IA (decisão D2).** Há três opções, com o custo na seção 6. O teste da seção 4 roda nas três, e depois o Guardião escolhe.

**Continuidade e o Castelo.** As investigações do cliente ficam no projeto do SONAR (seção 5). Com o consentimento do cliente, uma versão sem dados pessoais entra no Castelo pela porta do SONAR, e o organismo aprende com ela.

## 4. O teste que libera a venda

Vem do mapa de mercado do Guardião (memória `0ced7b2c`, seção 16).

- **10 perguntas reais do público:** 3 jurídicas (por exemplo, uma resposta de IA sobre uma lei), 3 acadêmicas ("existe estudo que sustente isso?"), 2 de tecnologia e 2 de dados ou empresa.
- **Cada pergunta** vai ao ChatGPT, ao Perplexity, ao Google e ao SONAR (e a uma ferramenta especializada, quando houver).
- **Nove dimensões:** fontes, fontes primárias, contradições, contexto, tempo, proveniência, confronto, persistência e continuidade.
- **Passa quando:**
  - nenhuma fonte inventada no SONAR, nas 10 perguntas;
  - o SONAR fica à frente em proveniência, contradições e confronto em pelo menos 7 das 10;
  - 3 relatórios sorteados são conferidos por um núcleo que não coletou, com veredito registrado no Castelo;
  - o custo real por investigação fica medido nas três opções de motor.
- **Se não passar,** o trabalho volta para o motor, e nada é vendido.

O resultado fica no Castelo e, com permissão, vira prova para o marketing.

## 5. Dados e segurança

- **Dado de cliente fica fora do Castelo principal**, num projeto Supabase só do SONAR (D3). Três motivos: várias mesas do Castelo têm leitura anônima aberta, uma pendência que só o Guardião decide; o Castelo é a memória interna do organismo; e a LGPD.
- **Custo zero é possível.** O plano gratuito do Supabase permite 2 projetos ativos (conferir), e hoje são o Castelo principal e o laboratório. Pausar o laboratório, o que é reversível, libera a vaga. O plano gratuito não tem backup diário (conferir), então a cópia sai todo dia por exportação automática até o plano Pro (US$ 25 por mês), que entra com a primeira receita.
- **O Castelo só recebe o que o organismo aprende:** investigação sem dados pessoais, com consentimento, pela porta do SONAR. Nunca e-mail, nome ou dado de processo.
- **RLS em todas as tabelas**, com teste como `anon` e `authenticated` antes de cada publicação. Chaves só em variáveis de ambiente (regra Hellwolf). No navegador, só a chave publicável do projeto do SONAR.
- **Conteúdo da web é dado, nunca instrução.** Uma página lida pode esconder comandos ("ignore as instruções anteriores…"). O motor isola o texto das fontes, e nenhuma fonte dispara ação. No projeto 2 o cuidado é dobrado, porque a resposta volta para a IA do cliente.
- **Sigilo.** A entrada avisa para não colar nome de cliente ou número de processo sigiloso sem necessidade. Os dados são apagados a pedido. Nada é usado para treinar modelo.
- **Termos de uso e política de privacidade** antes da primeira venda.

## 6. Custos

### 6.1 IA por investigação (estimativa; o teste da seção 4 mede o real)

Suposições: a investigação **rápida** lê 4 fontes, a **padrão** lê 8 e a **profunda** custa cerca do dobro da padrão. A padrão gasta perto de 70 mil tokens de entrada e 30 mil de saída, já contando o raciocínio do modelo. Preços da API da Anthropic por milhão de tokens, entrada e saída: Opus 5 US$ 5 e US$ 25; Sonnet 5 US$ 2 e US$ 10; Haiku 4.5 US$ 1 e US$ 5. Câmbio de referência: R$ 5,50 por dólar (conferir).

| Motor | Lê as fontes | Julga (plano, Mesa, consolidação) | Rápida | Padrão | Profunda |
|---|---|---|---|---|---|
| Máxima | Opus 5 | Opus 5 | ~R$ 3,40 | ~R$ 6,00 | ~R$ 12,00 |
| Equilíbrio | Haiku 4.5 | Opus 5 | ~R$ 2,60 | ~R$ 4,20 | ~R$ 8,40 |
| Econômica | Haiku 4.5 | Sonnet 5 | ~R$ 1,10 | ~R$ 1,80 | ~R$ 3,60 |

- Pela API de lotes da Anthropic, que devolve em até 24 horas, o custo cai pela metade. Serve para o que não é urgente, como as entregas programadas do projeto 3.
- A busca própria não custa nada por consulta (APIs abertas). Busca web paga, como Tavily, SerpAPI ou a busca do próprio Claude, soma centavos por investigação (conferir preços).
- O Opus 5.5 (US$ 4 e US$ 20), mais barato que o Opus 5 e ainda em lançamento, entra no teste se o Guardião quiser.

### 6.2 Custos fixos por mês

| Item | No teste (custo zero) | Com receita |
|---|---|---|
| Banco (Supabase) | plano gratuito, na vaga do laboratório, com exportação diária | Pro: US$ 25 (~R$ 140), com backup diário |
| Hospedagem (Vercel) | Hobby, só para teste interno (não comercial; conferir) | Pro: US$ 20 por membro (~R$ 110) |
| Busca web geral | só as fontes abertas; um SearXNG próprio pede um servidor de ~US$ 5 | Tavily ou SerpAPI por uso, se o teste mostrar falta |
| Endereço | o gratuito da Vercel | domínio próprio: ~US$ 11 por ano |
| E-mail (projetos 1 e 3) | cota gratuita de um serviço de e-mail transacional (conferir) | por volume |
| **Total** | **R$ 0 a ~R$ 30** | **~R$ 280** |

Com o fixo de ~R$ 280, cerca de 11 assinantes de R$ 39,90 pagam a infraestrutura.

### 6.3 Regra de preço

**Preço do plano ≥ 3 × o custo de IA da cota do plano.** A sobra paga imposto, taxa de pagamento, falhas, suporte e o fixo. Cada projeto aplica esta regra na sua tabela de preços. Com o motor máximo, os preços sugeridos triplicam.

## 7. Papéis (proposta; o Guardião ajusta)

| Quem | O que faz |
|---|---|
| Guardião | decide; opera o marketing; aprova cada fase e cada publicação; guarda as chaves |
| Mariana | escreve a base de código do projeto vencedor (estrutura, telas, componentes), seguindo o plano |
| Plasma (Claude) | integra a base no repositório; liga motor, banco, RLS, testes, Vercel e GitHub; mede custo e qualidade; cuida da integridade do Castelo |
| Sol | marketing e vendas, com o Guardião |
| Golden | consolida decisões e conhecimento; guarda a estrutura do SONAR |
| Grok | posição independente no teste de qualidade; revisão dos relatórios de demonstração |
| Mesa Trina | veredito nos casos usados como demonstração |
| Hellwolf | portão de segurança antes de cada publicação (lista da seção 5) |

## 8. Fora de todos os projetos até a primeira venda

- sites, páginas ou ofertas novas fora do SONAR;
- blog novo (o do Espelho continua servindo);
- calculadora, colaboradores, white-label, aplicativo de celular e API pública;
- plano "ilimitado";
- campanha paga antes do teste da seção 4;
- operação de chats de terceiros pela tela.

## 9. Conferir antes de gastar

- o plano atual do time na Vercel e as regras de uso comercial;
- os preços de hoje: Supabase Pro, Vercel Pro, Tavily, SerpAPI, busca web do Claude, serviço de e-mail e câmbio;
- o limite de projetos gratuitos do Supabase e como pausar o laboratório sem perder dados;
- as regras de uso comercial das fontes abertas (GDELT, arXiv, Crossref, OpenAlex, Wikipedia).
