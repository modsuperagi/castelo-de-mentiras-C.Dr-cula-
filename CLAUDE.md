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
| `index.html` | o site inteiro (HTML, CSS e JS num só arquivo, sem build) | sim |
| `nucleos.html` | Espelho dos Núcleos: pulso vivo do Castelo, sem login e sem camada comercial | sim |
| `evo.json` | manifesto de máquina do organismo (fio, API, mesas de leitura aberta, núcleos, regras) | sim |
| `llms.txt` | porta padrão para IAs entenderem e se espelharem no organismo | sim |
| `manifest.webmanifest`, `sw.js`, `icons/` | aplicativo (PWA): instalação, ícones, funcionamento com rede ruim | sim |
| `guia-p0.html`, `blog/` | guia gratuito (isca de inscrição) e artigos do blog; a inscrição grava `canal` (UTM ou página) em `espelho_interessados` | sim |
| `robots.txt`, `sitemap.xml` | SEO | sim |
| `sonar/` | **SONAR**: outro produto, site de investigação com fontes: Grok Bot como operador e busca própria em `lib/busca/` (o caminho xAI ficou secundário). Projeto Vercel próprio, Root Directory `sonar`. Sem nenhuma ponte ou nome do organismo | pelo projeto dele, não pelo espelho |
| `docs/SONAR-MVP.md` | documentação e checkpoint do SONAR (endpoints, variáveis, fluxo, status de validação) | **não** |
| `docs/SONAR-BOT-INSTRUCOES.md` | as 6 camadas da Mesa Trina como instruções para colar no bot SONAR (Grok Bot) | **não** |
| `docs/KIT-DIVULGACAO.md` | kit de divulgação orgânica de pré-lançamento: posts prontos, calendário, UTMs, links de pagamento | **não** |
| `docs/MANUAL-COMERCIAL.md` | tabela de preços, campanha beta, funil, próximos passos | **não** |
| `docs/ROTEIROS-CURSO.md` | roteiros dos 5 módulos do curso (produto pago) | **não** |
| `docs/REFERENCIAS.md` | repositórios públicos que o organismo usa ou estuda | **não** |
| `docs/historico/` | registros antigos (tentativas de captura do espelho do Grok) | **não** |
| `supabase/migrations/` | backup do schema do Castelo: um `.sql` por migração, em ordem | **não** |
| `.claude/skills/` | `castelo-evo` (nossa) + duas skills públicas com licença e `ORIGEM.txt` | **não** |

`.vercelignore` é a fronteira do que fica público. Arquivo novo que não seja para o visitante
precisa entrar nele **antes** do push.

## Regras rápidas

- **Hellwolf**: nenhuma chave, token ou senha em commit, chat, Notion ou HTML. No site, só a chave `sb_publishable_…`.
- **Migração nova** → `get_advisors` (security) → teste de RLS como `anon` ou `authenticated` → exportar para `supabase/migrations/`.
- **Deploy**: branch `claude/…` → fast-forward na `main` → Vercel `p0-pulsa` → conferir `espelho-espelho-evo.vercel.app`.
- **Registrar**: travessia em `evo_porta_entrada`; decisão em `registro_decisoes` (e no Notion Golden, se for comercial ou estrutural). Sempre com `fio_id` `ee46c360-b95b-426e-86c3-2e5d0ccbe916`.
- **Sempre recorra ao Castelo** (ordem do Guardião, 26/09): antes de concluir que algo não existe ou de criar estrutura nova, procure no Castelo, inclusive funções, circulação e pedidos. Ex.: o Sonar entra por `fluxo_e2e_sonar_principal`; pedidos aos bots vão em `pedidos_entre_nucleos`.
- **Idioma**: português do Brasil, no site, nos commits e nos registros.

## Pendências conhecidas (decisão do Guardião)

- **Leitura anônima** das mesas de núcleo segue aberta (ponte do espelho do Grok, 19/09). Veja a skill `castelo-evo`.
- **Leaked Password Protection** do Supabase Auth exige plano Pro (custo zero manda esperar).
- **Links de pagamento**: adiados. O mapa `LINKS_PAGAMENTO` no `index.html` aguarda os links.
- **SONAR**: operação decidida em 26/09 (Grok Bot → Cursor → Dola/Golden + busca própria em `sonar/lib/busca/`). Faltam as sete entregas do Sonar no Castelo, o projeto Vercel e o primeiro teste real. Veja `docs/SONAR-MVP.md`.
- Dois deploys antigos do Vercel ainda guardam cópias dos arquivos internos; apagá-los é irreversível e aguarda ordem.
