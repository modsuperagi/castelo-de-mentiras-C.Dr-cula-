# Checklist para pôr o blog no ar

## Antes de publicar
- [ ] `npm run build` passa sem erro
- [ ] Abre no celular, o Post #01 é legível e o botão Copiar funciona
- [ ] O formulário pede só e-mail + "O que você veio despertar em si mesmo?"
- [ ] Nenhum número de tráfego ou resultado inventado nos posts

## GitHub
- [ ] Código no repositório (hoje está na pasta `superevolab/` deste repositório)
- [ ] Se quiser o blog totalmente separado: criar um repositório só para ele e mover a pasta
- [ ] Criar o repositório público do exemplo do Post #01 e ligar o campo `github` no post

## Hospedagem (Cloudflare Pages, grátis)
- [ ] Conta Cloudflare criada e ligada ao GitHub
- [ ] Projeto Pages: Root directory `superevolab`, build `npm run build`, saída `out`, `NODE_VERSION=20`
- [ ] Variáveis: `NEXT_PUBLIC_SITE_URL`, `NEXT_PUBLIC_FORMSPREE_ID`
- [ ] Endereço `*.pages.dev` conferido no celular

## Formulário
- [ ] Formulário criado no Formspree e testado com um e-mail seu

## Google Ads (só depois do site no ar)
- [ ] `NEXT_PUBLIC_GOOGLE_ADS_ID` configurado
- [ ] Conversão de inscrição criada no Google Ads e em `NEXT_PUBLIC_GOOGLE_ADS_CONVERSAO`
- [ ] Campanha de Pesquisa com poucas palavras e teto diário baixo

## Domínio
- [ ] Comprar `superevolab.com.br` ou `superevolab.dev` (ainda não comprado)
- [ ] Ligar na Cloudflare e trocar `NEXT_PUBLIC_SITE_URL`

## Chave de API (só se for testar o código do Post #01)
- [ ] Chave da Anthropic e token do WhatsApp **só** em variável de ambiente, nunca no código nem no repositório
