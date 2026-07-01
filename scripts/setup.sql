-- ============================================
-- Script DDL - Sistema de gerenciamento de tarefas com tags
-- Banco de Dados: PostgreSQL 17
-- Descrição: Criação de tabelas, constraints, índices e relacionamentos
-- ============================================

-- Remover tabelas existentes (cuidado em produção!)
DROP TABLE IF EXISTS tarefa_tags CASCADE;
DROP TABLE IF EXISTS tarefas CASCADE;
DROP TABLE IF EXISTS tags CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;

-- ============================================
-- TABELA: usuarios
-- Descrição: Armazena usuários do sistema com credenciais de acesso
-- ============================================
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_usuarios_email_formato
        CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),

    CONSTRAINT chk_usuarios_senha_hash
        CHECK (LENGTH(TRIM(senha)) >= 20)
);

-- Comentários da tabela usuarios
COMMENT ON TABLE usuarios IS 'Armazena informações de usuários cadastrados';
COMMENT ON COLUMN usuarios.id IS 'Identificador único do usuário';
COMMENT ON COLUMN usuarios.email IS 'E-mail do usuário (usado para login, único)';
COMMENT ON COLUMN usuarios.senha IS 'Senha criptografada com bcrypt';
COMMENT ON COLUMN usuarios.created_at IS 'Data e hora de criação do registro';
COMMENT ON COLUMN usuarios.updated_at IS 'Data e hora da última atualização';

-- ============================================
-- TABELA: tarefas
-- Descrição: Armazena tarefas criadas pelos usuários
-- ============================================
CREATE TABLE tarefas (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    concluida BOOLEAN NOT NULL DEFAULT FALSE,
    usuario_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint: Foreign Key para usuarios
    CONSTRAINT fk_tarefas_usuario
        FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    
    -- Constraint: Título não pode estar vazio
    CONSTRAINT chk_titulo_nao_vazio
        CHECK (LENGTH(TRIM(titulo)) > 0)
);

-- Comentários da tabela tarefas
COMMENT ON TABLE tarefas IS 'Armazena tarefas dos usuários';
COMMENT ON COLUMN tarefas.id IS 'Identificador único da tarefa';
COMMENT ON COLUMN tarefas.titulo IS 'Título da tarefa (obrigatório)';
COMMENT ON COLUMN tarefas.descricao IS 'Descrição detalhada da tarefa (opcional)';
COMMENT ON COLUMN tarefas.concluida IS 'Status de conclusão da tarefa (true/false)';
COMMENT ON COLUMN tarefas.usuario_id IS 'ID do usuário dono da tarefa (FK)';
COMMENT ON COLUMN tarefas.created_at IS 'Data e hora de criação da tarefa';
COMMENT ON COLUMN tarefas.updated_at IS 'Data e hora da última atualização';

-- Índices para otimização de consultas
CREATE INDEX idx_tarefas_usuario_created ON tarefas(usuario_id, created_at DESC);
CREATE INDEX idx_tarefas_concluida ON tarefas(concluida);
CREATE INDEX idx_tarefas_created ON tarefas(created_at);

-- ============================================
-- TABELA: tags
-- Descrição: Armazena tags (etiquetas) para categorização de tarefas
-- ============================================
CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL UNIQUE,
    cor VARCHAR(7) NOT NULL DEFAULT '#cccccc',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint: Validação de cor hexadecimal
    CONSTRAINT chk_cor_hexadecimal
        CHECK (cor ~* '^#([0-9a-f]{3}|[0-9a-f]{6})$')
);

-- Comentários da tabela tags
COMMENT ON TABLE tags IS 'Armazena tags para categorização de tarefas';
COMMENT ON COLUMN tags.id IS 'Identificador único da tag';
COMMENT ON COLUMN tags.nome IS 'Nome da tag (único)';
COMMENT ON COLUMN tags.cor IS 'Cor da tag em formato hexadecimal (#RRGGBB)';
COMMENT ON COLUMN tags.created_at IS 'Data e hora de criação da tag';
COMMENT ON COLUMN tags.updated_at IS 'Data e hora da última atualização';

-- ============================================
-- TABELA: tarefa_tags (Tabela Pivô)
-- Descrição: Relacionamento N:N entre tarefas e tags
-- ============================================
CREATE TABLE tarefa_tags (
    id SERIAL PRIMARY KEY,
    tarefa_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint: Foreign Key para tarefas
    CONSTRAINT fk_tarefa_tags_tarefa
        FOREIGN KEY (tarefa_id)
        REFERENCES tarefas(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    
    -- Constraint: Foreign Key para tags
    CONSTRAINT fk_tarefa_tags_tag
        FOREIGN KEY (tag_id)
        REFERENCES tags(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    
    -- Constraint: Unicidade do par (tarefa_id, tag_id)
    CONSTRAINT uq_tarefa_tag
        UNIQUE (tarefa_id, tag_id)
);

-- Comentários da tabela tarefa_tags
COMMENT ON TABLE tarefa_tags IS 'Relacionamento N:N entre tarefas e tags';
COMMENT ON COLUMN tarefa_tags.id IS 'Identificador único do relacionamento';
COMMENT ON COLUMN tarefa_tags.tarefa_id IS 'ID da tarefa (FK)';
COMMENT ON COLUMN tarefa_tags.tag_id IS 'ID da tag (FK)';
COMMENT ON COLUMN tarefa_tags.created_at IS 'Data e hora de criação do relacionamento';
COMMENT ON COLUMN tarefa_tags.updated_at IS 'Data e hora da última atualização';

-- Índices para otimização de consultas de relacionamento
CREATE INDEX idx_tarefa_tags_tarefa ON tarefa_tags(tarefa_id);
CREATE INDEX idx_tarefa_tags_tag ON tarefa_tags(tag_id);

-- ============================================
-- FIM DO SCRIPT DDL
-- ============================================

-- Verificação das tabelas criadas
SELECT 
    tablename AS "Tabela",
    schemaname AS "Schema"
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Verificação dos índices criados
SELECT
    tablename AS "Tabela",
    indexname AS "Índice",
    indexdef AS "Definição"
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
