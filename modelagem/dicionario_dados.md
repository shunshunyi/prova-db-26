# Dicionário de dados

## Visão geral

O schema foi implementado em PostgreSQL com quatro tabelas centrais: `usuarios`, `tarefas`, `tags` e `tarefa_tags`. O dicionário abaixo reflete o estado real do DDL em `scripts/setup.sql`, incluindo tipos, constraints, regras de cascata e índices usados nas consultas críticas.

## Tabela `usuarios`

Armazena os usuários cadastrados no sistema e concentra a autenticação por e-mail.

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | `SERIAL` | `PK`, `NOT NULL` | Identificador único do usuário. |
| `email` | `VARCHAR(255)` | `UNIQUE`, `NOT NULL`, `CHECK chk_usuarios_email_formato` | E-mail usado no login e em buscas exatas. |
| `senha` | `VARCHAR(255)` | `NOT NULL`, `CHECK chk_usuarios_senha_hash` | Hash da senha armazenado no banco. |
| `created_at` | `TIMESTAMP` | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` | Data e hora de criação do registro. |
| `updated_at` | `TIMESTAMP` | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` | Data e hora da última atualização. |

**Chaves, constraints e índices**

- chave primária em `id`
- constraint `UNIQUE` em `email`
- `CHECK chk_usuarios_email_formato` para validar formato básico de e-mail
- `CHECK chk_usuarios_senha_hash` para impedir hashes curtos
- índice implícito da constraint `UNIQUE` em `email`

## Tabela `tarefas`

Armazena as tarefas registradas pelos usuários e o histórico temporal usado nas consultas de listagem, filtros e agregações.

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | `SERIAL` | `PK`, `NOT NULL` | Identificador único da tarefa. |
| `titulo` | `VARCHAR(255)` | `NOT NULL`, `CHECK chk_titulo_nao_vazio` | Título principal da tarefa. |
| `descricao` | `TEXT` | `NULL` | Descrição detalhada opcional. |
| `concluida` | `BOOLEAN` | `NOT NULL`, `DEFAULT FALSE` | Situação atual da tarefa. |
| `usuario_id` | `INTEGER` | `FK fk_tarefas_usuario`, `NOT NULL` | Usuário responsável pela tarefa. |
| `created_at` | `TIMESTAMP` | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` | Momento de criação da tarefa. |
| `updated_at` | `TIMESTAMP` | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` | Momento da última atualização. |

**Chaves, constraints e índices**

- chave primária em `id`
- `FK fk_tarefas_usuario` para `usuarios(id)` com `ON UPDATE CASCADE` e `ON DELETE CASCADE`
- `CHECK chk_titulo_nao_vazio` para impedir títulos vazios
- índice composto `idx_tarefas_usuario_created` em `(usuario_id, created_at DESC)`
- índice `idx_tarefas_concluida` em `concluida`
- índice `idx_tarefas_created` em `created_at`

## Tabela `tags`

Armazena as categorias reutilizáveis que podem ser associadas a várias tarefas.

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | `SERIAL` | `PK`, `NOT NULL` | Identificador único da tag. |
| `nome` | `VARCHAR(255)` | `UNIQUE`, `NOT NULL` | Nome da categoria. |
| `cor` | `VARCHAR(7)` | `NOT NULL`, `DEFAULT '#cccccc'`, `CHECK chk_cor_hexadecimal` | Cor da tag em hexadecimal. |
| `created_at` | `TIMESTAMP` | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` | Data e hora de criação da tag. |
| `updated_at` | `TIMESTAMP` | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` | Data e hora da última atualização. |

**Chaves, constraints e índices**

- chave primária em `id`
- constraint `UNIQUE` em `nome`
- `CHECK chk_cor_hexadecimal` para validar cores `#RGB` ou `#RRGGBB`
- índice implícito da constraint `UNIQUE` em `nome`

## Tabela `tarefa_tags`

Resolve o relacionamento muitos-para-muitos entre `tarefas` e `tags`.

| Campo | Tipo | Restrições | Descrição |
|---|---|---|---|
| `id` | `SERIAL` | `PK`, `NOT NULL` | Identificador único da associação. |
| `tarefa_id` | `INTEGER` | `FK fk_tarefa_tags_tarefa`, `NOT NULL` | Tarefa associada. |
| `tag_id` | `INTEGER` | `FK fk_tarefa_tags_tag`, `NOT NULL` | Tag associada. |
| `created_at` | `TIMESTAMP` | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` | Data e hora de criação do vínculo. |
| `updated_at` | `TIMESTAMP` | `NOT NULL`, `DEFAULT CURRENT_TIMESTAMP` | Data e hora da última atualização do vínculo. |

**Chaves, constraints e índices**

- chave primária em `id`
- `FK fk_tarefa_tags_tarefa` para `tarefas(id)` com `ON UPDATE CASCADE` e `ON DELETE CASCADE`
- `FK fk_tarefa_tags_tag` para `tags(id)` com `ON UPDATE CASCADE` e `ON DELETE CASCADE`
- restrição de unicidade `uq_tarefa_tag` em `(tarefa_id, tag_id)`
- índice `idx_tarefa_tags_tarefa` em `tarefa_id`
- índice `idx_tarefa_tags_tag` em `tag_id`

## Relacionamentos

```text
usuarios (1) -> (N) tarefas
tarefas (1) -> (N) tarefa_tags
tags (1) -> (N) tarefa_tags
```

**Cardinalidades**

- um usuário possui muitas tarefas
- uma tarefa pode possuir muitas tags
- uma tag pode aparecer em muitas tarefas

## Regras de negócio

1. ao excluir um usuário, suas tarefas também são removidas
2. ao excluir uma tarefa, seus vínculos em `tarefa_tags` também são removidos
3. ao excluir uma tag, seus vínculos em `tarefa_tags` também são removidos
4. não pode existir usuário com `email` duplicado
5. não pode existir tag com `nome` duplicado
6. não pode existir o mesmo par `(tarefa_id, tag_id)` repetido
7. o campo `cor` precisa respeitar o formato hexadecimal válido
8. o campo `titulo` não pode ser vazio ou composto apenas por espaços
9. o campo `senha` precisa ter tamanho mínimo compatível com hash persistido

## Observações

- o projeto usa `snake_case` em tabelas, colunas, aliases e arquivos
- os campos temporais seguem o padrão `created_at` e `updated_at`
- as decisões de normalização estão em `modelagem/normalizacao.md`
- a estratégia de indexação está detalhada em `modelagem/estrategia_indices.md`
