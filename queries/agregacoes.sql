-- ============================================
-- Consultas de Agregação - Sistema To-Do List com Tags
-- Descrição: Queries com COUNT, SUM, AVG, GROUP BY, HAVING, etc.
-- ============================================

-- ============================================
-- AGREGAÇÃO 1: Estatísticas Básicas do Usuário
-- ============================================
SELECT 
    u.id AS usuario_id,
    u.email,
    COUNT(t.id) AS total_tarefas,
    SUM(CASE WHEN t.concluida = TRUE THEN 1 ELSE 0 END) AS tarefas_concluidas,
    SUM(CASE WHEN t.concluida = FALSE THEN 1 ELSE 0 END) AS tarefas_pendentes,
    ROUND(
        (SUM(CASE WHEN t.concluida = TRUE THEN 1 ELSE 0 END)::numeric / NULLIF(COUNT(t.id), 0)) * 100,
        2
    ) AS percentual_conclusao,
    MIN(t.created_at) AS primeira_tarefa,
    MAX(t.created_at) AS ultima_tarefa
FROM usuarios u
LEFT JOIN tarefas t ON u.id = t.usuario_id
GROUP BY u.id, u.email
ORDER BY total_tarefas DESC;

-- ============================================
-- AGREGAÇÃO 2: Ranking de Tags Mais Utilizadas
-- ============================================
SELECT 
    tag.id AS tag_id,
    tag.nome AS tag_nome,
    tag.cor AS tag_cor,
    COUNT(tt.tarefa_id) AS total_usos,
    COUNT(DISTINCT tt.tarefa_id) AS tarefas_unicas,
    COUNT(DISTINCT t.usuario_id) AS usuarios_que_usaram
FROM tags tag
LEFT JOIN tarefa_tags tt ON tag.id = tt.tag_id
LEFT JOIN tarefas t ON tt.tarefa_id = t.id
GROUP BY tag.id, tag.nome, tag.cor
HAVING COUNT(tt.tarefa_id) > 0
ORDER BY total_usos DESC, tag.nome ASC
LIMIT 20;

-- ============================================
-- AGREGAÇÃO 3: Estatísticas por Período de Tempo
-- ============================================
-- Tarefas criadas por mês e ano
SELECT 
    DATE_TRUNC('month', t.created_at) AS mes_ano,
    COUNT(t.id) AS total_tarefas,
    SUM(CASE WHEN t.concluida = TRUE THEN 1 ELSE 0 END) AS concluidas,
    SUM(CASE WHEN t.concluida = FALSE THEN 1 ELSE 0 END) AS pendentes
FROM tarefas t
GROUP BY DATE_TRUNC('month', t.created_at)
ORDER BY mes_ano DESC;

-- Tarefas criadas por dia da semana
SELECT 
    EXTRACT(DOW FROM t.created_at) AS dia_semana_numero,
    TO_CHAR(t.created_at, 'Day') AS dia_semana_nome,
    COUNT(t.id) AS total_tarefas
FROM tarefas t
GROUP BY EXTRACT(DOW FROM t.created_at), TO_CHAR(t.created_at, 'Day')
ORDER BY dia_semana_numero ASC;

-- ============================================
-- AGREGAÇÃO 4: Análise de Tags por Usuário
-- ============================================
SELECT 
    u.id AS usuario_id,
    u.email,
    COUNT(DISTINCT t.id) AS total_tarefas,
    COUNT(DISTINCT tt.tag_id) AS total_tags_utilizadas,
    ARRAY_AGG(DISTINCT tag.nome ORDER BY tag.nome) AS tags_mais_usadas
FROM usuarios u
LEFT JOIN tarefas t ON u.id = t.usuario_id
LEFT JOIN tarefa_tags tt ON t.id = tt.tarefa_id
LEFT JOIN tags tag ON tt.tag_id = tag.id
GROUP BY u.id, u.email
ORDER BY total_tarefas DESC;

-- ============================================
-- AGREGAÇÃO 5: Tarefas com Múltiplas Tags
-- ============================================
SELECT 
    t.id AS tarefa_id,
    t.titulo,
    COUNT(tt.tag_id) AS numero_tags,
    ARRAY_AGG(tag.nome ORDER BY tag.nome) AS tags_associadas
FROM tarefas t
JOIN tarefa_tags tt ON t.id = tt.tarefa_id
JOIN tags tag ON tt.tag_id = tag.id
GROUP BY t.id, t.titulo
HAVING COUNT(tt.tag_id) > 1
ORDER BY numero_tags DESC, t.created_at DESC;

-- ============================================
-- AGREGAÇÃO 6: Média de Tarefas por Usuário
-- ============================================
SELECT 
    ROUND(AVG(total_tarefas), 2) AS media_tarefas_por_usuario,
    MIN(total_tarefas) AS minimo_tarefas,
    MAX(total_tarefas) AS maximo_tarefas,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_tarefas) AS mediana_tarefas
FROM (
    SELECT COUNT(t.id) AS total_tarefas
    FROM usuarios u
    LEFT JOIN tarefas t ON u.id = t.usuario_id
    GROUP BY u.id
) AS estatisticas_usuarios;

-- ============================================
-- AGREGAÇÃO 7: Tags que NÃO são Utilizadas
-- ============================================
SELECT 
    tag.id AS tag_id,
    tag.nome AS tag_nome,
    tag.cor AS tag_cor,
    tag.created_at AS data_criacao
FROM tags tag
LEFT JOIN tarefa_tags tt ON tag.id = tt.tag_id
WHERE tt.tag_id IS NULL
ORDER BY tag.created_at DESC;

-- ============================================
-- AGREGAÇÃO 8: Performance de Conclusão por Usuário
-- ============================================
-- Usuários ordenados por taxa de conclusão
SELECT 
    u.id AS usuario_id,
    u.email,
    COUNT(t.id) AS total_tarefas,
    SUM(CASE WHEN t.concluida = TRUE THEN 1 ELSE 0 END) AS tarefas_concluidas,
    ROUND(
        (SUM(CASE WHEN t.concluida = TRUE THEN 1 ELSE 0 END)::numeric / NULLIF(COUNT(t.id), 0)) * 100,
        2
    ) AS taxa_conclusao
FROM usuarios u
LEFT JOIN tarefas t ON u.id = t.usuario_id
GROUP BY u.id, u.email
HAVING COUNT(t.id) > 0
ORDER BY taxa_conclusao DESC;