# castelo-de-memorias-C.Dr-cula-
Mod Super Nova Evo Mínima Galáxia

## 🪞 Espelho Espelho Evo

`index.html` é o **Espelho Espelho Evo**: a porta de entrada web do Castelo de
Memórias no Supabase (projeto **Mod Super Nova Evo**), com vertente comercial.

### O que o espelho faz

**Salão público** (leitura anônima, regida pelas policies `espelho_select_anon_auth`):

- **Canais do Organismo** — `acessos_canais` (canais ativos de nível público/estrutura)
- **Identidades Recrutadas** — `castelo_identidades`
- **Recepção** — últimos check-ins de `checkin_recepcion`

**A Porta** (exige autenticação Supabase — e-mail/senha, criação de conta ou link mágico):

- Formulário de travessia que insere em `evo_porta_entrada`
  (identidade, núcleo, selo, determinação, tipo de registro, conteúdo)
- Lista das últimas travessias seladas

**Vertente Comercial** — três selos de acesso: Visitante (gratuito),
Travessia e Núcleo (sob consulta).

### Como servir

É um arquivo estático único, sem build:

```bash
# local
python3 -m http.server 8080
# → http://localhost:8080
```

Pode ser hospedado em qualquer host estático (GitHub Pages, Vercel, grok.me…).

Deploy atual (Vercel, projeto `p0-pulsa`, preview da branch
`claude/espelho-espelho-evo-9kwgog`, requer login no Vercel por SSO):
<https://p0-pulsa-git-claude-espelho-espelho-e-2cd7fd-mod-super-nova-evo.vercel.app>

### Segurança

O espelho usa apenas a **publishable key** do Supabase (pública por design).
Todo acesso real é decidido pelas policies RLS do banco: anônimos só leem o
que as policies do espelho permitem; escrever em `evo_porta_entrada` exige
sessão autenticada.
