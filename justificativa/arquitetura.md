# Justificativa Técnica da Arquitetura

## Definição da arquitetura

### Escolha tecnológica

**Tipo de banco:** SQL relacional

**Provedor utilizado:** PostgreSQL 17

### Justificativa técnica

O PostgreSQL foi escolhido porque o domínio do projeto possui relacionamentos claros e regras de integridade que são melhor representados em um banco relacional.

Os principais pontos da escolha são:

1. **Integridade referencial**: o relacionamento `usuarios -> tarefas` e a associação N:N entre `tarefas` e `tags` exigem `foreign keys`, `constraints` e unicidade composta.
2. **Consultas analíticas e operacionais**: o projeto precisa demonstrar `joins`, agregações, filtros por período, paginação e `EXPLAIN ANALYZE`, todos bem suportados pelo otimizador do PostgreSQL.
3. **Indexação madura**: índices `B-Tree` atendem diretamente as consultas críticas deste trabalho, como busca por `email`, filtro por `usuario_id`, ordenação por `created_at` e navegação pela tabela pivô.
4. **Conformidade acadêmica**: PostgreSQL permite demonstrar de forma clara DDL, comentários de schema, normalização, restrições e evidências de performance.
5. **Escalabilidade futura**: embora o projeto seja acadêmico, a modelagem suporta expansão com particionamento, replicação e novos índices caso o volume cresça.

## Requisitos do sistema

### Objetivo do sistema

Modelar e implementar um banco de dados para um sistema de gerenciamento de tarefas com tags, capaz de registrar usuários, armazenar tarefas, categorizar tarefas com múltiplas tags e sustentar consultas de listagem, filtragem e análise.

### Principais entidades

1. **`usuarios`**: armazena credenciais de acesso.
2. **`tarefas`**: representa cada atividade cadastrada por um usuário.
3. **`tags`**: define categorias reutilizáveis para classificar tarefas.
4. **`tarefa_tags`**: resolve o relacionamento muitos-para-muitos entre tarefas e tags.

### Volume estimado de dados

- **`usuarios`**: 1.000 a 10.000 registros
- **`tarefas`**: 50.000 a 500.000 registros
- **`tags`**: 100 a 1.000 registros
- **`tarefa_tags`**: 100.000 a 1.000.000 registros

### Quantidade estimada de usuários

- até 500 usuários simultâneos em horários de pico
- predominância de operações de leitura e filtros por usuário

### Principais consultas realizadas

1. busca de usuário por `email`
2. listagem paginada de tarefas por `usuario_id`
3. filtro de tarefas por `tag`
4. filtro de tarefas por período usando `created_at`
5. estatísticas de conclusão por usuário
6. ranking de tags mais utilizadas
7. identificação de tarefas sem tags

## Justificativa de performance

### Índices implementados

- índice implícito da constraint `UNIQUE` em `usuarios.email`
- `idx_tarefas_usuario_created`
- `idx_tarefas_concluida`
- `idx_tarefas_created`
- índice implícito da constraint `UNIQUE` em `tags.nome`
- `idx_tarefa_tags_tarefa`
- `idx_tarefa_tags_tag`
- `uq_tarefa_tag` como restrição de unicidade composta em `tarefa_tags(tarefa_id, tag_id)`

### Normalização

O banco está normalizado até a **3FN**:

- atributos atômicos em todas as tabelas
- dependência total da chave primária em cada relação
- ausência de dependências transitivas entre atributos não chave

A tabela `tarefa_tags` elimina redundância no relacionamento entre tarefas e tags e evita repetição de atributos multivalorados.

### Observações

- o projeto está padronizado em `snake_case` para nomes de tabelas, colunas, aliases e arquivos SQL
- as evidências de otimização estão documentadas em `queries/consultas_avancadas.sql`
- os detalhes de normalização estão em `modelagem/normalizacao.md`
- a estratégia de indexação está em `modelagem/estrategia_indices.md`
