# Projeto 1 · Golden — SONAR Pesquisa Contínua

> **Em uma frase:** a pessoa pergunta, o SONAR investiga e a tela mostra, lado a lado, o que sustenta, o que contradiz e o que falta. A investigação não termina no relatório: continua viva para reavaliar, aprofundar, conectar ou arquivar.

Proposta original: `originais/golden.md`. Base comum: `01-BASE-COMUM.md`.

## 1. O que veio do Golden

- **Princípio:** "Simples por fora · Trina por dentro. Nada brilha à toa. Nada interrompe. Tudo respira." Um bloco por vez; o resto descansa.
- **Fluxo:** Entrada ("O que você quer investigar?") → SONAR (coleta, cruza, rastreia) → Mesa Trina (Sinal a favor · Contra · Lacuna) → Consolidação (Concluído · Em aberto · Em andamento) → Continuidade (Reavaliar · Conectar · Aprofundar · Arquivar).
- **Visual:** fundo #050505, texto #dcdad5, dourado #b8941f só onde importa.
- **Telas:**
  - principal, com a entrada e as pesquisas em andamento (status e ações Ver, Continuar, Arquivar);
  - detalhe, com a pergunta original, três colunas com a contagem de fontes, a consolidação e o bloco "Continuar investigação" (adicionar perspectiva, conectar com pesquisa anterior, marcar etapa).
- **Barra:** SONAR · Bloco de anotações · Calculadora · Alerta · Notificações.
- **Bloco de anotações:** preso à pesquisa aberta; salva sozinho no Castelo; versões rascunho → consolidado → referência; exporta PDF, DOCX e link.
- **Calculadora profissional:** ligada ao tema da pesquisa (unidades, conversões, fórmulas); os resultados ficam arquivados na investigação.
- **Blog** por categorias: Pesquisa Acadêmica, Acompanhamento Tecnológico, Ciência Teórica, Colaboradores, Contato Profissional e Sobre o EVO.
- **Acesso:** cadastro antes de entrar ("Você é o primeiro a saber. Crie sua conta para acessar."); planos depois do login.
- **Planos:**
  - Base (curioso, estudante): 3 pesquisas por mês, guarda 7 dias, público;
  - Acadêmico: 15 por mês, guarda para sempre, anotações, citações;
  - Tecnológico: 30 por mês, alertas de avanço, comparação de modelos, API básica;
  - Ciência: ilimitado, revisão por pares, continuidade prioritária, dados brutos;
  - Institucional: equipe, white-label, suporte dedicado, volume especial.
- **Ferramentas:**
  - base: Claude Code; Supabase (autenticação, banco, Edge Functions, RLS); React e Next.js; TypeScript; Tailwind; Vercel;
  - busca: SerpAPI ou Tavily, arXiv, CrossRef ou Semantic Scholar, NewsAPI;
  - motor: Claude API com instruções separadas por função (o Analista encontra o que é a favor, o Crítico encontra o contra, o Investigador aponta a lacuna) e um Consolidador que "une sem apagar divergência";
  - interface: Lucide, React Markdown, Recharts, TipTap ou Quill, MathJax;
  - guarda: Supabase Storage, Fio Raiz e linhagem de cada alteração.
- **Ordem de construção:** 1 entrada e cadastro · 2 pesquisa e Trina · 3 salvar e retomar · 4 bloco de anotações · 5 planos e limites · 6 blog e colaboradores · 7 calculadora · 8 alertas e notificações.

## 2. O que o Plasma completou

- quem compra primeiro, e onde entram os escritórios (G1);
- como a continuidade funciona: cada ação vira uma rodada nova guardada;
- o motor comum, com as regras que o código garante;
- o banco (tabelas e acesso). O Golden diz "salva no Castelo"; com D3, o dado do cliente fica no projeto do SONAR, e só o aprendizado sem dados pessoais sobe ao Castelo;
- um preço que caiba no "barato para entrar", com a conta do custo;
- fases com portões e prazos;
- o que conferir na proposta (seção 12).

Nada da proposta foi cortado. Anotações, blog, colaboradores, calculadora e alertas seguem a ordem do próprio Golden (itens 4, 6, 7 e 8), só que depois da primeira venda.

## 3. Para quem, primeiro

- **Universitários e pós-graduação:** TCC, revisão de literatura, "existe estudo que sustente isso?". Plano Acadêmico, com OpenAlex, Crossref, arXiv e Semantic Scholar.
- **Profissionais que usam IA no trabalho e precisam provar o que entregam:** engenharia de dados, consultoria, empresas. Plano Tecnológico.
- **Escritórios de advocacia:** auditar a resposta jurídica de uma IA, o território que o mapa de mercado aponta.
  - Na proposta original, entram pelo Institucional.
  - O Plasma sugere abrir já no lançamento: o Tecnológico vira **Profissional**, com fontes jurídicas abertas (LexML e DataJud, do CNJ; conferir a cobertura).
  - Decisão G1 na cédula.

## 4. Como a pessoa usa

Cadastro → escolhe o plano → tela principal → pergunta → acompanha as etapas → detalhe → continua.

**Telas do produto mínimo:**
1. **Entrada.** "O que você quer investigar?", com duas coisas:
   - o Radar P0 no campo, que marca normas, datas, números e palavras absolutas (já existe);
   - a lista "Pesquisas em andamento": Em confronto · Aguardando aprofundamento · Consolidada.
2. **Investigando.** Etapas que só acendem quando acontecem de verdade: coletando fontes → lendo → Mesa Trina → consolidando. O padrão já existe em `sonar/public/app.js`.
3. **Detalhe.**
   - a pergunta original;
   - três colunas (✅ A favor · ⚠️ Contra · ❔ Lacuna), com a contagem; cada item abre o trecho, a fonte, a data e o tipo de fonte;
   - a consolidação;
   - o bloco Continuar.
4. **Relatório.** As 8 partes, no formato do Espelho, para baixar ou compartilhar.
5. **Conta.** Plano, uso do mês, dados pessoais, sair e apagar a conta.

No produto mínimo a barra tem só SONAR e Conta. O resto entra por fase.

## 5. A Mesa Trina neste projeto

- **Analista** lê o dossiê e separa o que sustenta a afirmação (A favor).
- **Crítico** procura o que contradiz ou limita (Contra).
- **Investigador** aponta o que falta e diz qual fonte resolveria (Lacuna).
- **Consolidador** une sem apagar divergência:
  - **Concluído**: fontes independentes concordam;
  - **Em aberto**: há conflito sem desempate;
  - **Em andamento**: uma nova rodada pode fechar a lacuna.
- São três chamadas separadas, cada uma só com o dossiê. O código confere que todo item cita uma evidência do dossiê.
- Estas lentes julgam a pergunta do cliente. As posições do Castelo (Arquiteto, Engenheiro, Verificador) continuam validando o que entra no Castelo, inclusive os casos de demonstração.

## 6. Continuidade, o diferencial

| Ação | O que acontece | Custo |
|---|---|---|
| Reavaliar | a pessoa acrescenta uma fonte ou perspectiva, e a Mesa relê o dossiê sem refazer a coleta | menos que uma rápida |
| Aprofundar | nova coleta só nas lacunas (cada lacuna já diz o que procurar) | uma rápida |
| Conectar | liga duas investigações; a consolidação diz o que uma muda na outra | leitura e consolidação |
| Arquivar | sai da lista e continua guardada | zero |

Cada ação vira uma **rodada** nova, e nada é sobrescrito. A linhagem mostra a história inteira da investigação.

## 7. Arquitetura

| Camada | Escolha | Reaproveita |
|---|---|---|
| Tela | Next.js, TypeScript e Tailwind (escolha do Golden), ícones Lucide, React Markdown | radar P0, formato das 8 partes, estados de `sonar/public/app.js` |
| Servidor | rotas do Next.js na Vercel: abrir investigação, ler estado, exportar | limite de uso (`sonar/lib/limite.js`) |
| Trabalhador | etapas curtas numa fila (base comum, seção 3) | `sonar/lib/busca/`, `sintese.js`, `curadoria.js` |
| Banco | projeto Supabase do SONAR: autenticação, Postgres com RLS, tempo real para o progresso e Storage para exportações | — |
| Busca | busca própria; OpenAlex e Semantic Scholar para o acadêmico; GDELT para notícias, no lugar da NewsAPI; web geral por SearXNG próprio ou Tavily | tudo em `sonar/lib/busca/` |
| IA | motor da base comum (D2), com as quatro instruções do Golden | — |

## 8. Banco (projeto do SONAR)

| Tabela | Guarda | Quem acessa |
|---|---|---|
| `perfis` | nome, plano, consentimentos | o próprio usuário |
| `investigacoes` | pergunta, estado, profundidade, se é pública | o dono; todos, se for pública (plano Base) |
| `rodadas` | cada execução ou continuação: tipo, custo, modelo, tempo | o dono |
| `fontes` | endereço, título, domínio, data, tipo (primária, oficial, acadêmica, notícia…) | o dono |
| `evidencias` | trecho, fonte, se foi conferida no texto | o dono |
| `posicoes` | a favor, contra e lacuna, com os números das evidências | o dono |
| `consolidacoes` | concluído, em aberto, em andamento; grau de segurança | o dono |
| `conexoes` | investigação ↔ investigação, com o que uma muda na outra | o dono |
| `uso` | créditos do mês | o dono lê; só o servidor escreve |

RLS em todas as tabelas. O trabalhador usa a chave de serviço só no servidor. Teste como `anon` e `authenticated` antes de cada publicação.

## 9. Planos e preço

**A proposta do Golden, com o custo da cota** (investigações padrão; regra da base comum: preço ≥ 3 × custo):

| Plano | Cota do Golden | Custo de IA por mês (econômico – máximo) | Preço mínimo |
|---|---|---|---|
| Base | 3 | R$ 5 – 18 | R$ 16 – 54 |
| Acadêmico | 15 | R$ 27 – 90 | R$ 81 – 270 |
| Tecnológico | 30 | R$ 54 – 180 | R$ 162 – 540 |
| Ciência | ilimitado | sem limite, não há como calcular | inviável: trocar por uso justo |
| Institucional | equipe | sob consulta | — |

**Proposta do Plasma para caber no "barato para entrar"** (motor econômico; com o máximo, os preços triplicam):

| Plano | Preço por mês | Cota |
|---|---|---|
| Base | R$ 9,90 | 3 investigações rápidas; as investigações ficam públicas e anonimizadas (é a leitura do "público" da proposta; confirmar com o Golden) |
| Acadêmico | R$ 39,90 | 12 rápidas ou 7 padrão; guarda para sempre; relatório com referências |
| Profissional (o Tecnológico) | R$ 79,90 | 24 rápidas ou 14 padrão; prioridade na fila |
| Investigação profunda avulsa | R$ 14,90 | uma por compra |
| Ciência e Institucional | depois | com uso justo e revisão definida |

## 10. Fases do início ao fim

| Fase | Entrega | Portão (pronto quando) | Prazo |
|---|---|---|---|
| F0 · Preparar | projeto Supabase do SONAR; projeto na Vercel; chaves com o Guardião; primeira busca real | a busca própria responde de verdade, ou diz qual fonte falhou | 2 a 3 dias |
| F1 · Motor e prova | motor comum com as quatro instruções do Golden; teste de qualidade nas três opções de motor | o teste passa; custo real medido; o Guardião escolhe o motor (D2) | 1 semana |
| F2 · Produto mínimo | telas 1 a 5; cadastro; continuar (reavaliar, aprofundar, arquivar); RLS testada | 20 investigações de ponta a ponta sem erro e sem fonte inventada | 1 a 1,5 semana |
| F3 · Beta fechado | 5 a 10 pessoas do público, convidadas pelo marketing | cada uma faz 3 investigações; nenhuma falha grave; metade usa "continuar" | 1 semana |
| F4 · Lançamento pago | Base, Acadêmico e Profissional; pagamento; termos e privacidade; Vercel e Supabase comerciais | aprovação do Guardião; primeira venda | 2 a 3 dias |
| F5 · Mês 2 | bloco de anotações com versões e exportação; conectar investigações; alertas por e-mail | dado de uso: quem usa anotações renova mais? | — |
| F6 · Mês 3 em diante | blog nas categorias do Golden (aproveitando o do Espelho), colaboradores, calculadora, Ciência e Institucional | cada item entra com pedido de cliente ou dado de uso | — |

Da ordem do Guardião até a primeira venda: cerca de 4 semanas.

## 11. Riscos e como conter

| Risco | Contenção |
|---|---|
| Crescer em telas (são oito componentes) e perder o brilho | produto mínimo só com as telas 1 a 5; o resto por fase, com portão |
| Fundo quase preto cansar em leitura longa | testar no beta; relatório exportado em fundo claro |
| Reescrever em Next.js custar tempo | a lógica do motor não muda; só a tela é nova |
| Custo sair do controle ("ilimitado") | créditos por mês e uso justo; custo guardado em cada rodada |
| Busca web paga encarecer | começar pela busca própria; pagar busca só se o teste mostrar falta |

## 12. P0 na proposta: o que conferir

- **NewsAPI:** o plano gratuito é só para desenvolvimento, e o uso comercial exige plano pago caro (conferir). Trocar por GDELT, que já está no código.
- **SerpAPI e Tavily** são pagos acima da cota gratuita (conferir). Alternativa: SearXNG próprio.
- **Semantic Scholar** pede chave e tem limite de taxa; o OpenAlex é aberto e cobre mais (conferir).
- **"Ilimitado"**, com custo por uso, não fecha a conta. Trocar por uso justo.
- **"Revisão por pares"** (plano Ciência) precisa dizer quem revisa. Sem isso, não entra na venda.
- **"API básica"** (Tecnológico) é, na prática, o projeto 2. Fica para depois, ou vem de lá.
- **MathJax** funciona; KaTeX é mais leve (opcional).
- **"público"** no plano Base: o Plasma leu como "investigações públicas". Confirmar com o Golden.

## 13. O que o marketing recebe

- **Frase do produto** (o marketing reescreve): "Pergunte uma vez. Veja o que sustenta, o que contradiz e o que falta. Continue quando quiser."
- **Demonstração:** a investigação da Lei 14.133 × 8.666 refeita no produto, lado a lado com a resposta de uma IA comum.
- **Prova:** o resultado do teste de qualidade, com permissão.
- **Entrada:** Base a R$ 9,90; Acadêmico a R$ 39,90 (motor econômico).
- **Público do lançamento:** universitários e profissionais, e escritórios se G1 passar.
