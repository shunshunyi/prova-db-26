\echo 'Iniciando validacao estrutural do projeto...'

DO $$
DECLARE
    total_usuarios INTEGER;
    total_tags INTEGER;
    total_tarefas INTEGER;
    total_relacionamentos INTEGER;
    relacionamentos_orfaos INTEGER;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = 'usuarios'
    ) THEN
        RAISE EXCEPTION 'Tabela usuarios nao encontrada.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = 'tarefas'
    ) THEN
        RAISE EXCEPTION 'Tabela tarefas nao encontrada.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = 'tags'
    ) THEN
        RAISE EXCEPTION 'Tabela tags nao encontrada.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = 'tarefa_tags'
    ) THEN
        RAISE EXCEPTION 'Tabela tarefa_tags nao encontrada.';
    END IF;

    SELECT COUNT(*) INTO total_usuarios FROM usuarios;
    SELECT COUNT(*) INTO total_tags FROM tags;
    SELECT COUNT(*) INTO total_tarefas FROM tarefas;
    SELECT COUNT(*) INTO total_relacionamentos FROM tarefa_tags;

    IF total_usuarios < 10 THEN
        RAISE EXCEPTION 'Quantidade insuficiente de usuarios: %', total_usuarios;
    END IF;

    IF total_tags < 10 THEN
        RAISE EXCEPTION 'Quantidade insuficiente de tags: %', total_tags;
    END IF;

    IF total_tarefas < 100 THEN
        RAISE EXCEPTION 'Quantidade insuficiente de tarefas: %', total_tarefas;
    END IF;

    IF total_relacionamentos < 100 THEN
        RAISE EXCEPTION 'Quantidade insuficiente de relacionamentos: %', total_relacionamentos;
    END IF;

    IF total_usuarios <> 15 THEN
        RAISE EXCEPTION 'Quantidade inesperada de usuarios: %', total_usuarios;
    END IF;

    IF total_tags <> 20 THEN
        RAISE EXCEPTION 'Quantidade inesperada de tags: %', total_tags;
    END IF;

    IF total_tarefas <> 139 THEN
        RAISE EXCEPTION 'Quantidade inesperada de tarefas: %', total_tarefas;
    END IF;

    IF total_relacionamentos <> 225 THEN
        RAISE EXCEPTION 'Quantidade inesperada de relacionamentos: %', total_relacionamentos;
    END IF;

    SELECT COUNT(*)
    INTO relacionamentos_orfaos
    FROM tarefa_tags tt
    LEFT JOIN tarefas t ON t.id = tt.tarefa_id
    LEFT JOIN tags tag ON tag.id = tt.tag_id
    WHERE t.id IS NULL OR tag.id IS NULL;

    IF relacionamentos_orfaos <> 0 THEN
        RAISE EXCEPTION 'Foram encontrados relacionamentos orfaos em tarefa_tags: %', relacionamentos_orfaos;
    END IF;
END $$;

\echo 'Validando colunas em snake_case...'

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'tarefas'
          AND column_name = 'usuario_id'
    ) THEN
        RAISE EXCEPTION 'Coluna tarefas.usuario_id nao encontrada.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'tarefas'
          AND column_name = 'usuarioId'
    ) THEN
        RAISE EXCEPTION 'Coluna fora do padrao encontrada: tarefas.usuarioId.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'tarefa_tags'
          AND column_name IN ('tarefaId', 'tagId')
    ) THEN
        RAISE EXCEPTION 'Coluna fora do padrao encontrada em tarefa_tags.';
    END IF;
END $$;

\echo 'Validando restricoes e indices principais...'

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_tarefas_usuario'
    ) THEN
        RAISE EXCEPTION 'Constraint fk_tarefas_usuario nao encontrada.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'uq_tarefa_tag'
    ) THEN
        RAISE EXCEPTION 'Constraint uq_tarefa_tag nao encontrada.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conrelid = 'usuarios'::regclass
          AND contype = 'u'
    ) THEN
        RAISE EXCEPTION 'Constraint UNIQUE para usuarios.email nao encontrada.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE schemaname = 'public'
          AND indexname = 'idx_tarefas_usuario_created'
    ) THEN
        RAISE EXCEPTION 'Indice idx_tarefas_usuario_created nao encontrado.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conrelid = 'tags'::regclass
          AND contype = 'u'
    ) THEN
        RAISE EXCEPTION 'Constraint UNIQUE para tags.nome nao encontrada.';
    END IF;
END $$;

\echo 'Validando duplicidade de relacionamento e consistencia de dominio...'

DO $$
DECLARE
    pares_duplicados INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO pares_duplicados
    FROM (
        SELECT tarefa_id, tag_id
        FROM tarefa_tags
        GROUP BY tarefa_id, tag_id
        HAVING COUNT(*) > 1
    ) duplicados;

    IF pares_duplicados <> 0 THEN
        RAISE EXCEPTION 'Foram encontrados pares duplicados em tarefa_tags: %', pares_duplicados;
    END IF;
END $$;

\echo 'Resumo final da carga:'

SELECT 'usuarios' AS entidade, COUNT(*) AS total FROM usuarios
UNION ALL
SELECT 'tags' AS entidade, COUNT(*) AS total FROM tags
UNION ALL
SELECT 'tarefas' AS entidade, COUNT(*) AS total FROM tarefas
UNION ALL
SELECT 'tarefa_tags' AS entidade, COUNT(*) AS total FROM tarefa_tags
ORDER BY entidade;

\echo 'Validacao concluida com sucesso.'
