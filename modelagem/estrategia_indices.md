# Estratégia de Indexação

## Objetivo

Os índices foram criados para acelerar as consultas mais frequentes do sistema: autenticação por e-mail, listagem de tarefas por usuário, filtros por período, filtros por status e navegação pela tabela pivô.

## Índices do projeto

| Índice | Tabela | Campo(s) | Tipo | Motivo |
|---|---|---|---|---|
| `usuarios_email_key` | `usuarios` | `email` | `UNIQUE` com índice implícito | Busca rápida no login sem duplicar estrutura de índice. |
| `idx_tarefas_usuario_created` | `tarefas` | `usuario_id`, `created_at DESC` | `B-Tree` | Listagem de tarefas por usuário já ordenada por data. |
| `idx_tarefas_concluida` | `tarefas` | `concluida` | `B-Tree` | Índice de apoio para segmentações simples por status; não é o índice principal da defesa da banca. |
| `idx_tarefas_created` | `tarefas` | `created_at` | `B-Tree` | Filtros por data e ordenação cronológica. |
| `tags_nome_key` | `tags` | `nome` | `UNIQUE` com índice implícito | Busca por nome de tag sem redundância. |
| `idx_tarefa_tags_tarefa` | `tarefa_tags` | `tarefa_id` | `B-Tree` | Consulta de tags por tarefa. |
| `idx_tarefa_tags_tag` | `tarefa_tags` | `tag_id` | `B-Tree` | Consulta de tarefas por tag. |
| `uq_tarefa_tag` | `tarefa_tags` | `tarefa_id`, `tag_id` | `UNIQUE` | Evita duplicidade de associação e melhora acesso exato ao par. |

## Relação com as consultas críticas

### Consulta 1: busca de usuário por e-mail

- usa o índice implícito da constraint `UNIQUE` em `usuarios.email`
- evita varredura completa em `usuarios`

### Consulta 2: listagem paginada de tarefas por usuário

- usa `idx_tarefas_usuario_created`
- combina filtro por `usuario_id` com ordenação por `created_at DESC`
- serve tanto para `LIMIT/OFFSET` quanto para keyset pagination

### Consulta 3: filtro de tarefas por tag

- usa o índice implícito da constraint `UNIQUE` em `tags.nome`
- usa `idx_tarefa_tags_tag`
- usa `idx_tarefas_usuario_created` para restringir ao usuário antes da ordenação final

### Consulta 4: estatísticas por usuário

- usa `idx_tarefas_usuario_created`
- reduz custo do `join` entre `usuarios` e `tarefas`

### Consulta 5: filtro por período

- usa `idx_tarefas_created`
- permite `range scan` em consultas com intervalo de datas
- quando combinado com `usuario_id`, o índice composto `idx_tarefas_usuario_created` continua sendo o principal candidato do otimizador

### Índice de apoio: filtro por status

- `idx_tarefas_concluida` existe para cenários simples de separação entre tarefas concluídas e pendentes
- ele pode ajudar em consultas administrativas ou filtros diretos por status, mas não é o eixo principal da argumentação de performance deste projeto
- na apresentação, o foco deve permanecer em `usuarios.email`, `idx_tarefas_usuario_created`, `idx_tarefas_created` e nos índices da tabela `tarefa_tags`

## Observações para apresentação

- os índices foram escolhidos com base no padrão de acesso, não por excesso
- índices únicos já fornecem acesso indexado e por isso não receberam duplicação manual
- a tabela `tarefa_tags` precisa de índices nos dois lados da associação porque participa de filtros nos dois sentidos
- o índice composto em `tarefas` é o mais importante para a banca, porque aparece nas listagens, nos filtros por período e nos exemplos de `EXPLAIN ANALYZE`
- o índice em `concluida` deve ser tratado como apoio, não como argumento central de otimização
- o projeto privilegia um desenho simples e explicável, adequado para banca acadêmica
