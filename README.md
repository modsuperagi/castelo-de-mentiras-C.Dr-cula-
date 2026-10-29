# Castelo de Memórias · Mod Super Nova Evo

Este repositório reúne o código e a documentação do Castelo, o Espelho e dois produtos separados: **Super Evo Lab** e **SONAR**. Compartilhar o repositório não significa compartilhar banco, acesso ou publicação.

## Comece pelo caminho certo

| Quero… | Caminho |
|---|---|
| Entender o protocolo do Castelo | [CLAUDE.md](CLAUDE.md) e [skill castelo-evo](.claude/skills/castelo-evo/SKILL.md) |
| Encontrar documentação por assunto | [Índice da documentação](docs/README.md) |
| Trabalhar no blog Super Evo Lab | [Manual do blog](superevolab/README.md) e [checklist editorial](superevolab/CHECKLIST.md) |
| Entender o produto SONAR | [Checkpoint do SONAR](docs/SONAR-MVP.md) |
| Alterar o blog editorial antigo do Espelho | [Gerador](ferramentas/blog/) e [páginas geradas](blog/) |

## Mapa de responsabilidades

| Área | Arquivos | Limite |
|---|---|---|
| Castelo | `supabase/`, `.claude/skills/`, documentação | Código e migrações versionadas não comprovam o estado atual do banco |
| Espelho | `index.html`, `nucleos.html`, `porta.html`, `evo.json`, `llms.txt` | Não reabrir acessos nem acionar registros sem autorização |
| Editorial do Espelho | `blog/`, `guia-p0.html`, `investigar.html`, `ferramentas/blog/` | Não confundir com o Super Evo Lab; há integrações documentadas com o Castelo |
| Super Evo Lab | `superevolab/` | Blog independente, Next.js/MDX, exportação estática; sem banco ou fio do Castelo |
| SONAR | `sonar/` | Produto independente; não é a raiz do Espelho nem o blog |
| Documentação | `docs/` | Índice temático, planos, referências e histórico |

## Publicação: separar os destinos

- **Espelho/Vercel:** o protocolo registra fechamento das portas em 04/10 e publicação Git desativada desde 08/10. São declarações documentais, não uma verificação atual dos serviços. Não reativar como parte de uma organização do repositório.
- **Super Evo Lab/Cloudflare Pages:** o workflow [Blog](.github/workflows/blog.yml) monta o site em mudanças de `superevolab/` ou do próprio workflow. Em `main`, pode publicar no projeto `castelo-blog` se os segredos necessários estiverem disponíveis. Pull requests montam o site, mas não executam a etapa de publicação desse workflow.
- **SONAR:** possui diretório e configuração próprios. Não publicar pelo projeto do Espelho.
- `.vercelignore` exclui diretórios do pacote do Espelho. **Não torna arquivos privados no GitHub**; este repositório é público.

## Regras para qualquer trabalho

1. Ler o protocolo antes de operar. Documento ou comentário não substitui autorização explícita para uma ação com efeitos.
2. Separar inspeção de código, consultas autenticadas, execução de funções, alterações de banco e deploy. A aprovação de uma etapa não libera as demais.
3. Não tratar check-in, checkpoint ou autodiagnóstico como simples leitura: podem gravar e disparar fluxos.
4. Nunca versionar credenciais, dados privados ou relatórios privados de auditoria. Configuração pública não substitui controle de acesso.
5. Preservar caminhos operacionais e URLs ao organizar documentação; usar branch e revisar o diff antes de integrar.
6. Quando documentos discordarem sobre portas abertas ou fechadas, registrar a lacuna e verificar com autorização. Não presumir acesso atual a partir de um manual antigo.

## Desenvolvimento local do blog

Consulte o [manual do Super Evo Lab](superevolab/README.md). O workflow usa Node.js 22 e `npm ci`; utilize a mesma versão para reduzir diferenças entre o ambiente local e a integração contínua.

A organização documental não altera políticas, serviços, preços, conteúdo publicado ou configuração de deploy.
