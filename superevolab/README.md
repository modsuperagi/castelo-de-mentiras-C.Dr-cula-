# Super Evo Lab: blog de tutoriais de agentes de IA

Blog público, em português. **Separado do Castelo**: não usa banco, fio nem nada do organismo.

- Next.js 14 (App Router), TypeScript, Tailwind, posts em MDX
- Sem CMS: cada post é um arquivo em `content/posts/`

## 1. Instalar

Precisa do Node.js 18.17 ou mais novo.

```bash
cd superevolab
npm install
cp .env.example .env.local   # preencha o que quiser (nada ali é segredo)
```

## 2. Rodar no computador

```bash
npm run dev
```

Abra http://localhost:3000. Para ver como fica no celular, use o modo celular do navegador (F12).

Antes de publicar, confira se o build passa:

```bash
npm run build
```

## 3. Escrever um post

Crie `content/posts/meu-post.mdx`. O nome do arquivo vira o endereço: `/posts/meu-post`.

```mdx
---
titulo: "Como [fazer X] com [ferramenta] em 10 min"   # até 60 caracteres
resumo: "Duas linhas dizendo o que a pessoa vai conseguir fazer."
categoria: "WhatsApp"
data: "2026-10-05"
preview: |
  linha de código que aparece no cartão
github: "https://github.com/..."   # opcional
rascunho: true                      # tire quando for publicar
faq:
  - pergunta: "..."
    resposta: "..."
---

Texto em Markdown. Tabelas e blocos de código já ganham estilo e botão Copiar.
```

- `rascunho: true` deixa o post fora do site, do sitemap e das rotas.
- O FAQ vira a seção de perguntas e o dado estruturado `FAQPage` para o Google.
- Regra da casa: **nenhum número inventado**. Exemplo ilustrativo leva o aviso de que é ilustrativo.

## 4. Publicar de graça (Cloudflare Pages)

O blog vira um site estático (pasta `out/`), então roda em hospedagem gratuita, sem Vercel.

1. Crie uma conta grátis em dash.cloudflare.com.
2. **Workers & Pages → Create → Pages → Connect to Git** e autorize o GitHub neste repositório.
3. Configure o build:
   - **Framework preset:** Next.js (Static HTML Export)
   - **Build command:** `npm run build`
   - **Build output directory:** `out`
   - **Root directory:** `superevolab`
4. Em **Environment variables**, coloque `NODE_VERSION` = `20` e as do `.env.example` que for usar.
5. **Save and Deploy**. O blog fica em `https://<nome-do-projeto>.pages.dev`.
6. Se o nome não for `superevolab`, troque `NEXT_PUBLIC_SITE_URL` para o endereço real e publique de novo
   (o sitemap e o canonical usam esse valor).

O arquivo `public/_headers` leva os cabeçalhos de segurança; a Cloudflare e a Netlify leem ele sozinhas.
A Netlify também serve: mesmo comando de build, pasta `superevolab/out`.

## 5. Plugar o domínio depois

Quando comprar `superevolab.com.br` (Registro.br) ou `superevolab.dev`:

1. Cloudflare → projeto → **Custom domains** → adicione o domínio.
2. Copie os registros DNS que a Cloudflare mostrar para o painel onde o domínio foi comprado.
3. Troque `NEXT_PUBLIC_SITE_URL` para o domínio novo e faça novo deploy.

## 6. Formulário (Formspree)

1. Crie um formulário grátis em formspree.io com o seu e-mail.
2. Copie o código do formulário (a parte depois de `/f/` no endpoint).
3. Coloque em `NEXT_PUBLIC_FORMSPREE_ID` na Cloudflare e faça novo deploy.

Sem esse código o formulário aparece, mas avisa que ainda não está ligado. O formulário pede só o
e-mail (obrigatório) e a pergunta "O que você veio despertar em si mesmo?" (opcional).

## 7. Google Ads (opcional)

- `NEXT_PUBLIC_GOOGLE_ADS_ID`: a tag da conta (`AW-…`). Sem ela, nenhum script do Google é carregado.
- `NEXT_PUBLIC_GOOGLE_ADS_CONVERSAO`: o rótulo da conversão (`AW-…/…`). Ela dispara quando
  alguém se inscreve, que é uma conversão melhor que "visualizou a página".
