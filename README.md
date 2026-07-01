# Projeto 2º Bimestre - Banco de Dados

Este repositório entrega a modelagem, a implementação SQL e a validação de um banco de dados relacional para um sistema de gerenciamento de tarefas com tags. O objetivo da entrega é demonstrar, em PostgreSQL, arquitetura, modelagem, normalização, carga de dados, consultas críticas, evidências de performance e organização de repositório conforme o enunciado da prova.

## Visão do projeto

O domínio escolhido é um sistema de tarefas com categorização por tags, composto pelas tabelas `usuarios`, `tarefas`, `tags` e `tarefa_tags`.

O projeto foi estruturado para responder diretamente aos pontos cobrados:

- arquitetura e justificativa técnica em `justificativa/arquitetura.md`
- DER, modelo lógico e dicionário de dados em `modelagem/`
- DDL, validação e scripts de carga em `scripts/`
- consultas CRUD, avançadas e de agregação em `queries/`
- normalização e estratégia de indexação em `modelagem/normalizacao.md` e `modelagem/estrategia_indices.md`
- checklist final de aderência em `verificacao_final.md`

## Como defender o projeto

Durante a banca, os arquivos principais a apresentar são:

- `justificativa/arquitetura.md`: tipo de banco, provedor, justificativa, objetivo do sistema, entidades, volume estimado, quantidade estimada de usuários e consultas principais
- `modelagem/der.png` e `modelagem/modelo_logico.png`: visão conceitual e lógica
- `modelagem/dicionario_dados.md`: tabelas, tipos, constraints, índices e regras de negócio
- `modelagem/normalizacao.md`: justificativa de 1FN, 2FN e 3FN
- `modelagem/estrategia_indices.md`: motivo de cada índice a partir dos padrões de consulta
- `scripts/setup.sql`: implementação do schema
- `scripts/validacao.sql`: evidência de integridade e volumetria
- `queries/consultas_avancadas.sql`: consultas críticas com `EXPLAIN ANALYZE`
- `queries/agregacoes.sql`: relatórios e análises
- `showcase.ps1`: fluxo único de demonstração no Windows PowerShell

## Estrutura do repositório

```text
prova-db-26/
├── README.md
├── apresentacao.md
├── verificacao_final.md
├── showcase.ps1
├── justificativa/
│   └── arquitetura.md
├── modelagem/
│   ├── der.png
│   ├── dicionario_dados.md
│   ├── estrategia_indices.md
│   ├── modelo_logico.png
│   └── normalizacao.md
├── queries/
│   ├── agregacoes.sql
│   ├── consultas_avancadas.sql
│   └── crud.sql
└── scripts/
    ├── setup.sql
    ├── validacao.sql
    └── seed/
        ├── 01_usuarios.sql
        ├── 02_tags.sql
        ├── 03_tarefas.sql
        └── 04_tarefa_tags.sql
```

Essa estrutura já corresponde ao que a prova pede: documentação técnica, modelagem, DDL, carga, consultas e justificativa separados por responsabilidade.

## Dados para teste

Os scripts de carga entregam uma massa coerente com o domínio e suficiente para avaliação:

- `15` usuários
- `20` tags
- `139` tarefas
- `225` relacionamentos em `tarefa_tags`

Esse conjunto atende ao requisito mínimo de mais de `100` registros relevantes e permite demonstrar integridade referencial, `JOIN`, filtros por período, agregações e uso de índices.

## Consultas críticas

O projeto já inclui consultas suficientes para a banca, com foco em uso real do schema:

1. autenticação por e-mail
2. listagem paginada de tarefas por usuário
3. filtro de tarefas por tag com `JOIN`
4. filtro por período usando `created_at`
5. estatísticas por usuário
6. ranking de tags mais utilizadas

As evidências de execução e otimização estão em `queries/consultas_avancadas.sql`, com `EXPLAIN ANALYZE` e observações coerentes com a massa de dados atual.

## Execução para banca

### Fluxo canônico

No Windows PowerShell, a forma recomendada de demonstração é:

```powershell
.\showcase.ps1 -Mode Docker -Cleanup
```

Esse script:

- valida a presença dos arquivos esperados
- inicializa o banco
- aplica `scripts/setup.sql`
- carrega os arquivos de `scripts/seed/`
- executa `ANALYZE`
- roda `scripts/validacao.sql`
- executa consultas selecionadas
- encerra com um resumo por etapa

### Diferença entre `Docker` e `Local`

| Modo | Onde o PostgreSQL roda | Onde o `psql` roda | O que o host precisa |
|---|---|---|---|
| `Docker` | em um container temporário | dentro do container via `docker exec` | `docker` |
| `Local` | em uma instância PostgreSQL já existente | no host Windows | `psql` no `PATH` ou informado em `-PsqlExe` |

Ponto importante: o modo `Docker` do `showcase.ps1` **não** depende de `psql` instalado no host. Já o fluxo manual com `psql -h localhost ...` é uma alternativa de contingência e não o mecanismo usado internamente pelo script nesse modo.

### Exemplos de uso do `showcase.ps1`

#### Docker padrão

```powershell
.\showcase.ps1 -Mode Docker -Cleanup
```

#### Docker com raiz do projeto explícita

```powershell
.\showcase.ps1 -Mode Docker -ProjectRoot 'C:\caminho\para\prova-db-26' -Cleanup
```

#### Docker com nome de container personalizado

```powershell
.\showcase.ps1 -Mode Docker -ContainerName 'prova_db_26_demo' -Cleanup
```

#### Local com `psql` no `PATH`

```powershell
$env:PGPASSWORD = 'postgres'
.\showcase.ps1 -Mode Local -HostName 'localhost' -Port 5432 -DatabaseName 'prova_db_26' -UserName 'postgres'
```

#### Local com `-PsqlExe` apontando para caminho com espaços

```powershell
$env:PGPASSWORD = 'postgres'
.\showcase.ps1 -Mode Local -PsqlExe 'C:\Program Files\PostgreSQL\17\bin\psql.exe' -HostName 'localhost' -Port 5432 -DatabaseName 'prova_db_26' -UserName 'postgres'
```

## Execução manual de contingência

Os comandos abaixo são úteis apenas como plano B ou para inspeção manual do banco. Eles não substituem o fluxo canônico via `showcase.ps1`.

### Cenário `Local`

```powershell
$env:PGPASSWORD = 'postgres'
createdb prova_db_26
psql -d prova_db_26 -f 'scripts/setup.sql'
psql -d prova_db_26 -f 'scripts/seed/01_usuarios.sql'
psql -d prova_db_26 -f 'scripts/seed/02_tags.sql'
psql -d prova_db_26 -f 'scripts/seed/03_tarefas.sql'
psql -d prova_db_26 -f 'scripts/seed/04_tarefa_tags.sql'
psql -d prova_db_26 -f 'scripts/validacao.sql'
```

### Cenário `Docker` manual

```powershell
$env:PGPASSWORD = 'postgres'
docker run --name prova_db_26 -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=prova_db_26 -p 5432:5432 -d postgres:17-alpine
psql -h 'localhost' -U 'postgres' -d 'prova_db_26' -f 'scripts/setup.sql'
psql -h 'localhost' -U 'postgres' -d 'prova_db_26' -f 'scripts/seed/01_usuarios.sql'
psql -h 'localhost' -U 'postgres' -d 'prova_db_26' -f 'scripts/seed/02_tags.sql'
psql -h 'localhost' -U 'postgres' -d 'prova_db_26' -f 'scripts/seed/03_tarefas.sql'
psql -h 'localhost' -U 'postgres' -d 'prova_db_26' -f 'scripts/seed/04_tarefa_tags.sql'
psql -h 'localhost' -U 'postgres' -d 'prova_db_26' -f 'scripts/validacao.sql'
```

## Arquivos principais

- `scripts/setup.sql`: cria tabelas, constraints, chaves e índices
- `scripts/validacao.sql`: testa integridade estrutural, massa mínima e contagens exatas
- `queries/crud.sql`: demonstra operações de inserção, leitura, atualização e remoção
- `queries/consultas_avancadas.sql`: concentra as consultas críticas com `EXPLAIN ANALYZE`
- `queries/agregacoes.sql`: reúne consultas analíticas e relatórios
- `apresentacao.md`: roteiro de defesa para a banca
- `showcase.ps1`: execução canônica do projeto no Windows PowerShell
- `verificacao_final.md`: checklist final de aderência ao enunciado

## Observações finais

- O projeto está padronizado em `snake_case` para tabelas, colunas, aliases e scripts SQL.
- As imagens de modelagem já estavam em conformidade com a estrutura pedida no enunciado.
- O DDL atual foi mantido como implementação oficial do projeto e serve de fonte de verdade para o dicionário de dados.
- O `showcase.ps1` é a forma principal de demonstração; os comandos manuais existem apenas como contingência.
