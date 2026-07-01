-- ============================================
-- Consultas Avancadas - Sistema de tarefas com tags
-- Descricao: consultas criticas com EXPLAIN ANALYZE para banca
-- Observacao: execute este arquivo somente apos setup, seeds e ANALYZE
-- Nota: com a massa atual de dados, o otimizador pode preferir Seq Scan.
-- Isso e esperado em tabelas pequenas e nao invalida a estrategia de indices.
-- ============================================

-- ============================================
-- CONSULTA 1: autenticacao por e-mail
-- Importancia: busca critica do login
-- O que observar no plano:
-- - uso do indice criado automaticamente pela constraint UNIQUE em usuarios.email
-- - retorno de no maximo uma linha
-- ============================================
EXPLAIN ANALYZE
SELECT
    id,
    email,
    senha,
    created_at,
    updated_at
FROM usuarios
WHERE email = 'admin@todo.com';

-- ============================================
-- CONSULTA 2: listagem paginada de tarefas por usuario
-- Importancia: consulta principal da aplicacao
-- O que observar no plano:
-- - filtro por usuario_id
-- - ordenacao por created_at DESC
-- - uso do indice composto idx_tarefas_usuario_created
-- ============================================
EXPLAIN ANALYZE
SELECT
    t.id,
    t.titulo,
    t.descricao,
    t.concluida,
    t.created_at,
    t.updated_at
FROM tarefas t
WHERE t.usuario_id = 1
ORDER BY t.created_at DESC
LIMIT 5 OFFSET 0;

-- Variacao: keyset pagination com cursor valido para a base atual
-- O que observar:
-- - continua a listagem apos a primeira pagina
-- - evita custo crescente de OFFSET em paginas grandes
-- - reusa a ordenacao por created_at DESC
EXPLAIN ANALYZE
SELECT
    t.id,
    t.titulo,
    t.descricao,
    t.concluida,
    t.created_at
FROM tarefas t
WHERE t.usuario_id = 1
  AND t.created_at < '2026-06-25 16:45:00'
ORDER BY t.created_at DESC
LIMIT 5;

-- ============================================
-- CONSULTA 3: filtro por tag com join
-- Importancia: busca por categoria
-- O que observar no plano:
-- - join entre tarefas, tarefa_tags e tags
-- - uso do indice unico de tags.nome e dos indices da tabela pivo
-- - ordenacao final por created_at
-- ============================================
EXPLAIN ANALYZE
SELECT DISTINCT
    t.id,
    t.titulo,
    t.descricao,
    t.concluida,
    t.created_at
FROM tarefas t
JOIN tarefa_tags tt ON t.id = tt.tarefa_id
JOIN tags tag ON tt.tag_id = tag.id
WHERE tag.nome = 'urgente'
  AND t.usuario_id = 1
ORDER BY t.created_at DESC;

-- ============================================
-- CONSULTA 4: filtro por periodo
-- Importancia: relatorios temporais e telas com filtro de data
-- O que observar no plano:
-- - busca por faixa de created_at
-- - combinacao com usuario_id
-- - plano deve mostrar acesso eficiente por indice
-- ============================================
EXPLAIN ANALYZE
SELECT
    t.id,
    t.titulo,
    t.descricao,
    t.concluida,
    t.created_at
FROM tarefas t
WHERE t.usuario_id = 1
  AND t.created_at >= '2026-06-01 00:00:00'
  AND t.created_at < '2026-07-01 00:00:00'
ORDER BY t.created_at DESC;

-- ============================================
-- CONSULTA 5: estatisticas por usuario
-- Importancia: dashboard de produtividade
-- O que observar no plano:
-- - join entre usuarios e tarefas
-- - agregacoes com COUNT e SUM
-- - protecao contra divisao por zero com NULLIF
-- ============================================
EXPLAIN ANALYZE
SELECT
    u.id AS usuario_id,
    u.email,
    COUNT(t.id) AS total_tarefas,
    SUM(CASE WHEN t.concluida THEN 1 ELSE 0 END) AS tarefas_concluidas,
    SUM(CASE WHEN NOT t.concluida THEN 1 ELSE 0 END) AS tarefas_pendentes,
    ROUND(
        (
            SUM(CASE WHEN t.concluida THEN 1 ELSE 0 END)::numeric
            / NULLIF(COUNT(t.id), 0)
        ) * 100,
        2
    ) AS percentual_conclusao
FROM usuarios u
LEFT JOIN tarefas t ON u.id = t.usuario_id
WHERE u.id = 1
GROUP BY u.id, u.email;

-- ============================================
-- CONSULTA 6: ranking de tags
-- Importancia: relatorio administrativo e analise de categorizacao
-- O que observar no plano:
-- - LEFT JOIN para manter tags sem uso
-- - agregacao por tag
-- - uso do indice em tarefa_tags.tag_id
-- ============================================
EXPLAIN ANALYZE
SELECT
    tag.id,
    tag.nome,
    tag.cor,
    COUNT(tt.tarefa_id) AS quantidade_tarefas,
    COUNT(DISTINCT tt.tarefa_id) AS tarefas_unicas
FROM tags tag
LEFT JOIN tarefa_tags tt ON tag.id = tt.tag_id
GROUP BY tag.id, tag.nome, tag.cor
ORDER BY quantidade_tarefas DESC, tag.nome ASC
LIMIT 10;

-- ============================================
-- CONSULTA 7: busca textual por titulo e descricao
-- Importancia: campo de busca da aplicacao
-- O que observar no plano:
-- - o filtro por usuario_id reduz o universo pesquisado
-- - ILIKE com wildcard inicial nao usa indice B-Tree
-- - esta consulta evidencia um limite conhecido do modelo atual
-- ============================================
EXPLAIN ANALYZE
SELECT
    t.id,
    t.titulo,
    t.descricao,
    t.concluida,
    t.created_at
FROM tarefas t
WHERE t.usuario_id = 1
  AND (
      t.titulo ILIKE '%projeto%'
      OR t.descricao ILIKE '%projeto%'
  )
ORDER BY t.created_at DESC;

/*
Observacao para defesa:
- esta consulta e relevante porque demonstra uma necessidade comum de busca textual
- o projeto atual nao cria GIN com pg_trgm ou tsvector
- portanto, a otimizacao aqui esta limitada ao filtro inicial por usuario_id
*/
