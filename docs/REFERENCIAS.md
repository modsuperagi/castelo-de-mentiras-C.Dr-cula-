# Repositórios públicos que agregam ao organismo

Registro do que o organismo incorpora ou estuda de fora, e por quê. Custo zero em todos:
nada aqui vira dependência paga nem serviço externo.

## Incorporados (versionados em `.claude/skills/`)

| Repositório | O que trouxemos | Commit | Licença | Por que |
|---|---|---|---|---|
| [supabase/agent-skills](https://github.com/supabase/agent-skills) | `supabase-postgres-best-practices`: 30+ regras em 8 categorias (performance, conexões, segurança/RLS, schema, concorrência…) | `551274e` | MIT | O Castelo tem 40+ mesas e dezenas de policies. Esta skill guiou a migração `hellwolf_fechar_escrita_autenticada_ao_guardiao` (funções de RLS envolvidas em `select`, avaliadas uma vez por consulta). |
| [anthropics/skills](https://github.com/anthropics/skills) | `frontend-design`: direção visual intencional, tipografia, fuga de padrões genéricos | `34040c9` | Apache 2.0 | Guia as próximas evoluções visuais do espelho. |

**Atualizar:** clonar o repositório de origem, comparar com a pasta local, copiar por cima e
trocar o commit no `ORIGEM.txt` da skill. Nunca editar o conteúdo delas à mão: ajustes
do organismo vão na skill `castelo-evo`.

## Estudados (referência, sem código incorporado)

### [getzep/graphiti](https://github.com/getzep/graphiti) · Apache 2.0
Memória em grafo **temporal**: cada fato guarda uma janela de validade (quando passou a valer
e quando deixou de valer) e a proveniência (de qual episódio veio). É o mesmo princípio do nosso
Fio Mestre, levado ao nível do fato.

**Proposta para o Castelo (não aplicada, exige decisão):** colunas `valido_de timestamptz` e
`valido_ate timestamptz` em `evo_memorias`. Uma memória superada deixa de ser apagada ou
sobrescrita: recebe `valido_ate` e aponta para a que a substituiu. O Castelo ganharia a
capacidade de responder "o que o organismo sabia em tal data".
Usar o Graphiti como software exigiria Neo4j e chave de LLM, o que fere o custo zero. Só o padrão serve.

### [NirDiamant/Agent_Memory_Techniques](https://github.com/NirDiamant/Agent_Memory_Techniques)
30 notebooks executáveis de técnicas de memória para agentes: buffers, vetores, grafos,
memória episódica e semântica, MemGPT/Letta, Mem0, Zep, Graphiti, benchmarks LoCoMo.
**Uso:** material de estudo para os núcleos e base de comparação para o módulo 5 do curso
("Erga o Seu"). Mostra ao aluno onde o Castelo se situa no panorama.

## Plugins do catálogo sugeridos ao Guardião (24/09/2026)

Instalação pelo card no claude.ai (depende do clique do Guardião):
- **Marketing** (Anthropic): campanha da Turma Fundadora, sequência de e-mail para a lista.
- **Design** (Anthropic): crítica e acessibilidade do espelho antes da divulgação em massa.
- **SearchFit SEO** (gratuito): schema markup e palavras-chave em português.
