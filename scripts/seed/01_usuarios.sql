-- ============================================
-- Seed Data: Usuários
-- Descrição: Carga inicial de 15 usuários de teste
-- Nota: Senhas são hashes bcrypt de "senha123" (custo 10)
-- ============================================

INSERT INTO usuarios (email, senha, created_at, updated_at) VALUES
('admin@todo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-01-15 10:00:00', '2026-01-15 10:00:00'),
('maria.silva@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-01-20 14:30:00', '2026-01-20 14:30:00'),
('joao.santos@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-02-05 09:15:00', '2026-02-05 09:15:00'),
('ana.oliveira@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-02-12 16:45:00', '2026-02-12 16:45:00'),
('pedro.costa@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-02-28 11:20:00', '2026-02-28 11:20:00'),
('julia.fernandes@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-03-10 08:00:00', '2026-03-10 08:00:00'),
('carlos.almeida@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-03-18 13:30:00', '2026-03-18 13:30:00'),
('beatriz.rodrigues@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-04-02 10:10:00', '2026-04-02 10:10:00'),
('rafael.pereira@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-04-15 15:25:00', '2026-04-15 15:25:00'),
('fernanda.martins@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-05-01 12:00:00', '2026-05-01 12:00:00'),
('lucas.souza@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-05-10 09:45:00', '2026-05-10 09:45:00'),
('camila.lima@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-05-20 14:20:00', '2026-05-20 14:20:00'),
('bruno.carvalho@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-06-01 11:00:00', '2026-06-01 11:00:00'),
('larissa.gomes@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-06-10 16:30:00', '2026-06-10 16:30:00'),
('thiago.ribeiro@exemplo.com', '$2b$10$rN7vZXk3wFjU8YLq5VhGOeZQX.xH9v4kRzLMpJN5qP8tK2eM3fGHi', '2026-06-20 10:15:00', '2026-06-20 10:15:00');

-- Verificação
SELECT COUNT(*) AS total_usuarios FROM usuarios;
SELECT email, created_at FROM usuarios ORDER BY created_at ASC;
