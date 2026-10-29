# Índice da documentação

[Voltar ao repositório](../README.md)

## Protocolo e governança

- [Protocolo operacional](../.claude/skills/castelo-evo/SKILL.md): identidades, P0, Mesa Trina e limites.
- [Instruções do repositório](../CLAUDE.md): mapa técnico e determinações documentadas.
- [Alinhamento EVO](ALINHAMENTO-EVO.md).
- [Instruções Draco/Golden](INSTRUCOES-DRACO-GOLDEN.md).
- [Gatilho Drácula](GATILHO-DRACULA.md).

O protocolo contém seções de épocas diferentes. Descrições de leitura pública, preços e publicação não comprovam a configuração atual. Quando houver conflito, não executar a alternativa mais permissiva: delimitar a operação e obter aprovação. Consultar ou alterar o banco não faz parte de uma organização documental.

## Projetos e produtos

| Área | Documentação | Código |
|---|---|---|
| Super Evo Lab | [Manual](../superevolab/README.md), [organização editorial](../superevolab/ORGANIZACAO.md), [checklist](../superevolab/CHECKLIST.md) | `superevolab/` |
| SONAR | [MVP e checkpoint](SONAR-MVP.md), [instruções do bot](SONAR-BOT-INSTRUCOES.md), [propostas dos projetos](projetos-sonar/) | `sonar/` |
| Espelho e editorial legado | [Mapa do repositório](../CLAUDE.md) | Raiz, `blog/` e `ferramentas/blog/` |
| Castelo | [Protocolo](../.claude/skills/castelo-evo/SKILL.md) | `supabase/` |

## Comercial e divulgação

- [Manual comercial](MANUAL-COMERCIAL.md).
- [Agente Market](AGENTE-MARKET.md).
- [Kit de divulgação](KIT-DIVULGACAO.md).
- [Roteiros do curso](ROTEIROS-CURSO.md).

Planos comerciais são documentação, não ordem para ligar pagamentos, campanhas, formulários ou assinaturas.

## Pesquisa, relatórios e histórico

- [Referências](REFERENCIAS.md).
- [Relatórios](relatorios/).
- [Histórico](historico/).

## Onde guardar cada coisa

- Documentação operacional: nesta pasta, ligada ao índice e ao projeto correspondente.
- Guia editorial do Super Evo Lab: em `superevolab/`; textos em `content/posts/*.mdx`.
- Esquema e migrações: manter os caminhos existentes em `supabase/`, sem renomear migrações aplicadas.
- Arquivos gerados: não editar como fonte quando existir gerador; revisar seu fluxo antes de regenerar.
- Credenciais, registros privados e auditorias privadas: **fora deste repositório público**. `.vercelignore` controla o pacote Vercel, não a visibilidade do GitHub.

Não mover arquivos de produção apenas para deixar a árvore mais bonita: imports, geradores, URLs e workflows dependem desses caminhos.
