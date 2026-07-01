-- ============================================
-- Consultas CRUD - Sistema de tarefas com tags
-- Descrição: demonstração executável de create, read, update e delete
-- Observação: o script roda dentro de uma transação e termina com ROLLBACK
-- ============================================

BEGIN;

-- ============================================
-- CREATE
-- ============================================

\echo 'CRUD DEMO - CREATE'

INSERT INTO usuarios (email, senha, created_at, updated_at)
VALUES ('crud_demo@exemplo.com', '$2b$10$abcdefghijklmnopqrstuv1234567890ABCDEFG', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO tags (nome, cor, created_at, updated_at)
VALUES
    ('crud_urgente', '#ff5733', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('crud_trabalho', '#3498db', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    ('crud_estudos', '#9b59b6', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO tarefas (titulo, descricao, concluida, usuario_id, created_at, updated_at)
VALUES (
    'crud_demo_tarefa',
    'Tarefa criada para demonstrar operacoes CRUD sem persistencia final.',
    FALSE,
    (SELECT id FROM usuarios WHERE email = 'crud_demo@exemplo.com'),
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

INSERT INTO tarefa_tags (tarefa_id, tag_id, created_at, updated_at)
VALUES
    (
        (SELECT id FROM tarefas WHERE titulo = 'crud_demo_tarefa'),
        (SELECT id FROM tags WHERE nome = 'crud_urgente'),
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    ),
    (
        (SELECT id FROM tarefas WHERE titulo = 'crud_demo_tarefa'),
        (SELECT id FROM tags WHERE nome = 'crud_trabalho'),
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );

-- ============================================
-- READ
-- ============================================

\echo 'CRUD DEMO - READ'

SELECT id, email, created_at, updated_at
FROM usuarios
WHERE email = 'crud_demo@exemplo.com';

SELECT id, titulo, descricao, concluida, usuario_id, created_at, updated_at
FROM tarefas
WHERE titulo = 'crud_demo_tarefa';

SELECT
    tarefa.id AS tarefa_id,
    tarefa.titulo,
    tag.nome AS tag_nome,
    tag.cor AS tag_cor
FROM tarefas tarefa
JOIN tarefa_tags tt ON tarefa.id = tt.tarefa_id
JOIN tags tag ON tag.id = tt.tag_id
WHERE tarefa.titulo = 'crud_demo_tarefa'
ORDER BY tag.nome;

SELECT
    usuario_id,
    COUNT(*) AS total_tarefas
FROM tarefas
WHERE usuario_id = (SELECT id FROM usuarios WHERE email = 'crud_demo@exemplo.com')
GROUP BY usuario_id;

-- ============================================
-- UPDATE
-- ============================================

\echo 'CRUD DEMO - UPDATE'

UPDATE usuarios
SET email = 'crud_demo_atualizado@exemplo.com',
    updated_at = CURRENT_TIMESTAMP
WHERE email = 'crud_demo@exemplo.com';

UPDATE tarefas
SET titulo = 'crud_demo_tarefa_atualizada',
    descricao = 'Descricao ajustada durante a etapa de update.',
    concluida = TRUE,
    updated_at = CURRENT_TIMESTAMP
WHERE titulo = 'crud_demo_tarefa';

UPDATE tags
SET nome = 'crud_muito_urgente',
    cor = '#ff0000',
    updated_at = CURRENT_TIMESTAMP
WHERE nome = 'crud_urgente';

SELECT id, email, updated_at
FROM usuarios
WHERE email = 'crud_demo_atualizado@exemplo.com';

SELECT id, titulo, concluida, updated_at
FROM tarefas
WHERE titulo = 'crud_demo_tarefa_atualizada';

SELECT id, nome, cor, updated_at
FROM tags
WHERE nome = 'crud_muito_urgente';

-- ============================================
-- DELETE
-- ============================================

\echo 'CRUD DEMO - DELETE'

DELETE FROM tarefa_tags
WHERE tarefa_id = (SELECT id FROM tarefas WHERE titulo = 'crud_demo_tarefa_atualizada');

DELETE FROM tarefas
WHERE titulo = 'crud_demo_tarefa_atualizada';

DELETE FROM tags
WHERE nome IN ('crud_muito_urgente', 'crud_trabalho', 'crud_estudos');

DELETE FROM usuarios
WHERE email = 'crud_demo_atualizado@exemplo.com';

-- ============================================
-- Verificacoes finais da demonstracao
-- ============================================

\echo 'CRUD DEMO - CHECK E ROLLBACK'

SELECT COUNT(*) AS usuario_demo_restante
FROM usuarios
WHERE email IN ('crud_demo@exemplo.com', 'crud_demo_atualizado@exemplo.com');

SELECT COUNT(*) AS tarefa_demo_restante
FROM tarefas
WHERE titulo IN ('crud_demo_tarefa', 'crud_demo_tarefa_atualizada');

ROLLBACK;
