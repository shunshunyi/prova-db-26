# Normalização do Banco

## Visão geral

O banco foi modelado até a **3ª Forma Normal (3FN)** para reduzir redundância, evitar anomalias de atualização e manter consistência entre usuários, tarefas e tags.

## 1FN

A **Primeira Forma Normal** exige atributos atômicos e ausência de grupos repetitivos.

O projeto atende a 1FN porque:

- cada coluna armazena um único valor por linha
- listas de tags não são gravadas em um campo textual
- o relacionamento entre tarefas e tags foi separado para a tabela `tarefa_tags`

**Exemplo de decisão correta**

- errado: guardar várias tags em `tarefas.tags = 'urgente, trabalho, projeto'`
- correto: guardar cada associação em `tarefa_tags`

## 2FN

A **Segunda Forma Normal** exige que todos os atributos não chave dependam da chave inteira, e não apenas de parte dela.

O projeto atende a 2FN porque:

- em `usuarios`, todos os atributos dependem de `id`
- em `tarefas`, os atributos `titulo`, `descricao`, `concluida`, `usuario_id`, `created_at` e `updated_at` dependem de `id`
- em `tags`, os atributos dependem de `id`
- em `tarefa_tags`, não há atributos descritivos que dependam apenas de `tarefa_id` ou apenas de `tag_id`

## 3FN

A **Terceira Forma Normal** exige ausência de dependências transitivas entre atributos não chave.

O projeto atende a 3FN porque:

- dados de usuário ficam apenas em `usuarios`
- dados de tarefa ficam apenas em `tarefas`
- dados de tag ficam apenas em `tags`
- a tabela `tarefa_tags` contém apenas a associação entre entidades, sem duplicar nome de usuário, título da tarefa ou nome da tag

## Desnormalização

Não foi necessária desnormalização neste projeto.

Essa decisão foi tomada porque:

- o volume de dados acadêmico é bem atendido pela modelagem normalizada
- os principais ganhos de performance vieram de índices, não de duplicação de dados
- manter dados normalizados facilita demonstrar integridade referencial e consistência para a banca

## Benefícios obtidos

- eliminação de redundância entre tarefas e tags
- facilidade para aplicar `joins` e filtros por relacionamento
- menor risco de inconsistência ao atualizar ou excluir registros
- modelo mais claro para explicar durante a apresentação
