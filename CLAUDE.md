# Castelo de Memórias · Espelho Espelho Evo

Repositório do **Espelho Espelho Evo**: a porta pública do organismo EVO e a vitrine
comercial dele, ligada ao Castelo de Memórias no Supabase.

**Antes de agir, carregue a skill `castelo-evo`.** Ela traz o protocolo do organismo: identidades
dos núcleos, regra Hellwolf, P0 e Trina, como registrar travessias e decisões, e o fluxo de deploy.
Para qualquer SQL, schema ou RLS, carregue também `supabase-postgres-best-practices`.
Para mudanças visuais no site, use `frontend-design`.

## Mapa do repositório

| Caminho | O que é | Vai ao ar? |
|---|---|---|
| `index.html` | página inicial (HTML, CSS e JS num só arquivo, sem build). Desde 27/09 segue o documento de mercado do Guardião (`evo_memorias` 0ced7b2c): a pergunta primeiro ("O que você quer investigar?"), quatro caminhos, o método em linguagem de usuário e os planos na escada comercial. Nada de nome de mesa, conta ou login na vitrine | sim |
| `investigar.html` | tela central do SONAR (gerada por `ferramentas/blog`): pedir investigação ou conferir resposta (a pergunta vai em `espelho_interessados.mensagem`, com Pix), radar P0 ao vivo, o relatório em 8 partes aberto com um caso real, trilha e fila pública (`espelho_sinais`) | sim |
| `blog/radar.js` | radar P0: marca no navegador (nada é enviado) normas, datas, números, palavras absolutas, fontes vagas, links e referências, e liga cada marca a uma das 7 verificações; aponta onde olhar, sem veredito. Modo `completo` (Conferir), `curto` (pergunta da home e do Investigar, com o caso parecido) e estático. Evento `radar` em `espelho_eventos` | sim |
| `blog/investigacoes/` | investigações abertas: `casos.json` (fonte única: gera as páginas e alimenta o "caso parecido" do radar) e uma página por caso, gerada por `ferramentas/blog`. Cada caso também fica em `evo_memorias` (coleção `SONAR_INVESTIGACOES`) | sim |
| `porta.html` | Porta dos Núcleos: login e "Selar travessia" em `evo_porta_entrada`, fora da vitrine, `noindex`, sem criação de conta; o link fica no rodapé do `nucleos.html` | sim |
| `nucleos.html` | Espelho dos Núcleos: pulso vivo do Castelo, sem login e sem camada comercial | sim |
| `evo.json` | manifesto de máquina do organismo (fio, API, mesas de leitura aberta, núcleos, regras) | sim |
| `llms.txt` | porta padrão para IAs entenderem e se espelharem no organismo | sim |
| `manifest.webmanifest`, `sw.js`, `icons/` | aplicativo (PWA): instalação, ícones, funcionamento com rede ruim | sim |
| `guia-p0.html`, `blog/` | guia gratuito (isca de inscrição) e artigos do blog; a inscrição grava `canal` (UTM ou página) em `espelho_interessados` | sim |
| `blog/espelho.js`, `blog/escrever.html`, `blog/ressonancias.html` | Espelho editorial (reforma de 27/09): sinais do público em `espelho_sinais` (só insere; entram como RECEBIDO), telemetria sem dado pessoal em `espelho_eventos`, painel "O que está ressoando?" pela função `espelho_ressonancias` (só agregados e o que o organismo marcou como publicável); leitura interna do SONAR editorial (conteúdo, comunidade, investigação, mercado) pela função `espelho_sonar_leitura` (só `service_role`). O artigo leva atalho para a oferta abaixo da linha fina e "Continue lendo" no fim (tema em `conteudo.py`, `META`). Tudo opcional: se o Castelo cair, a página segue igual | sim |
| `robots.txt`, `sitemap.xml` | SEO | sim |
| `vercel.json` | cabeçalhos de segurança na borda (Hellwolf) e cache de ícones e imagens; nada de URL muda | configuração |
| `sonar/` | **SONAR**: outro produto, site de investigação com fontes: Grok Bot como operador e busca própria em `lib/busca/` (o caminho xAI ficou secundário). Projeto Vercel próprio, Root Directory `sonar`. Sem nenhuma ponte ou nome do organismo | pelo projeto dele, não pelo espelho |
| `ferramentas/blog/` | gerador do guia e do blog (`python3 gerar.py`; textos em `conteudo.py`). Regenera as páginas com o mesmo cabeçalho, rodapé e formulário | **não** |
| `docs/SONAR-MVP.md` | documentação e checkpoint do SONAR (endpoints, variáveis, fluxo, status de validação) | **não** |
| `docs/projetos-sonar/` | os três projetos do SONAR (Golden, Sol e Mariana) planejados do início ao fim para a votação dos 7 núcleos: comparação, base comum, cédula e os documentos originais | **não** |
| `docs/SONAR-BOT-INSTRUCOES.md` | as 6 camadas da Mesa Trina como instruções para colar no bot SONAR (Grok Bot) | **não** |
| `docs/KIT-DIVULGACAO.md` | kit de divulgação orgânica de pré-lançamento: posts prontos, calendário, UTMs, links de pagamento | **não** |
| `docs/AGENTE-MARKET.md` | agente Market (MARKET_MERCADO): conselho de marketing e vendas, ciclo diário, assinaturas, limites | **não** |
| `docs/MANUAL-COMERCIAL.md` | tabela de preços, campanha beta, funil, próximos passos | **não** |
| `docs/ROTEIROS-CURSO.md` | roteiros dos 5 módulos do curso (produto pago) | **não** |
| `docs/REFERENCIAS.md` | repositórios públicos que o organismo usa ou estuda | **não** |
| `docs/historico/` | registros antigos (tentativas de captura do espelho do Grok) | **não** |
| `supabase/migrations/` | backup do schema do Castelo: um `.sql` por migração, em ordem | **não** |
| `.claude/skills/` | `castelo-evo` (nossa) + skills públicas com licença e `ORIGEM.txt`: `frontend-design`, `supabase-postgres-best-practices` e, do Superpowers 6.4.1 (sem o gancho de início de sessão), `verification-before-completion` e `systematic-debugging` | **não** |

`.vercelignore` é a fronteira do que fica público. Arquivo novo que não seja para o visitante
precisa entrar nele **antes** do push.

## Regras rápidas

- **Hellwolf**: nenhuma chave, token ou senha em commit, chat, Notion ou HTML. No site, só a chave `sb_publishable_…`.
- **Migração nova** → `get_advisors` (security) → teste de RLS como `anon` ou `authenticated` → exportar para `supabase/migrations/`.
- **Deploy**: branch `claude/…` → fast-forward na `main` → Vercel `p0-pulsa` → conferir `espelho-espelho-evo.vercel.app`.
- **Registrar**: travessia em `evo_porta_entrada`; decisão em `registro_decisoes` (e no Notion Golden, se for comercial ou estrutural). Sempre com `fio_id` `ee46c360-b95b-426e-86c3-2e5d0ccbe916`.
- **Sempre recorra ao Castelo** (ordem do Guardião, 26/09): antes de concluir que algo não existe ou de criar estrutura nova, procure no Castelo, inclusive funções, circulação e pedidos. Ex.: o Sonar entra por `fluxo_e2e_sonar_principal`; pedidos aos bots vão em `pedidos_entre_nucleos`.
- **Mesa Trina planeja e decide; o Sonar abastece**: conhecimento que faltar no Castelo para a Mesa vem pelo Sonar e entra em `payload.conhecimento_sonar` da sessão, com fontes. Quem coleta não dá o veredito (skill `castelo-evo`).
- **Idioma**: português do Brasil, no site, nos commits e nos registros.

## Pendências conhecidas (decisão do Guardião)

- **Leitura anônima** das mesas de núcleo segue aberta (ponte do espelho do Grok, 19/09). Veja a skill `castelo-evo`.
- **Leaked Password Protection** do Supabase Auth exige plano Pro (custo zero manda esperar).
- **Links de pagamento**: adiados. O mapa `LINKS_PAGAMENTO` no `index.html` aguarda os links.
- **Pix**: ligado em 26/09 por determinação do Plasma, com delegação do Guardião ("você assume a determinação Drácula e protege"). A chave e o e-mail de comprovante moram só em `espelho_pagamento_config` (nunca no site, no repositório ou em registro) e só aparecem para quem acabou de se inscrever em algo que o organismo entrega sozinho (`espelho_catalogo.pix_automatico`: planos mensais, Concursos, ENEM e serviços avulsos). Preço, prazo e material pedido moram em `espelho_catalogo` e mudam sem deploy; o uso dos planos se registra em `espelho_uso`. Desliga com um UPDATE (veja `docs/AGENTE-MARKET.md`). Compras se registram em `espelho_assinaturas` (só a referência da transação).
- **SONAR**: operação decidida em 26/09 (Grok Bot → Cursor → Dola/Golden + busca própria em `sonar/lib/busca/`). Faltam as sete entregas do Sonar no Castelo, o projeto Vercel e o primeiro teste real. Veja `docs/SONAR-MVP.md`. Em 27/09 o Guardião pediu o planejamento de três projetos para votação dos núcleos (`docs/projetos-sonar/`): nada do SONAR é construído antes do vencedor, do marketing e da ordem do Guardião.
- Dois deploys antigos do Vercel ainda guardam cópias dos arquivos internos; apagá-los é irreversível e aguarda ordem.
