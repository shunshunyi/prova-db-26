            -- ============================================
-- Seed Data: Tarefas
-- Descrição: Carga inicial de 139 tarefas distribuidas entre 15 usuarios
-- ============================================

-- Tarefas do usuário 1 (admin@todo.com)
INSERT INTO tarefas (titulo, descricao, concluida, usuario_id, created_at, updated_at) VALUES
('Revisar documentação do projeto', 'Atualizar README e adicionar exemplos', TRUE, 1, '2026-06-01 09:00:00', '2026-06-15 14:00:00'),
('Implementar autenticação JWT', 'Criar middleware de verificação de token', TRUE, 1, '2026-06-02 10:30:00', '2026-06-10 11:00:00'),
('Configurar ambiente Docker', 'Criar docker-compose para dev e prod', TRUE, 1, '2026-06-03 08:15:00', '2026-06-08 16:30:00'),
('Otimizar queries do banco', 'Adicionar índices nas FKs', FALSE, 1, '2026-06-20 11:00:00', '2026-06-20 11:00:00'),
('Escrever testes unitários', 'Cobrir controllers e services', FALSE, 1, '2026-06-22 14:20:00', '2026-06-22 14:20:00'),
('Corrigir bug na paginação', 'OFFSET causando lentidão em páginas grandes', FALSE, 1, '2026-06-25 16:45:00', '2026-06-25 16:45:00'),
('Implementar logs de auditoria', 'Registrar todas as ações dos usuários', FALSE, 1, '2026-06-26 09:30:00', '2026-06-26 09:30:00'),
('Adicionar validação de CPF', 'Validar formato e dígitos verificadores', FALSE, 1, '2026-06-27 10:00:00', '2026-06-27 10:00:00'),
('Criar endpoint de estatísticas', 'Dashboard com métricas de tarefas', FALSE, 1, '2026-06-28 13:15:00', '2026-06-28 13:15:00'),
('Revisar política de CORS', 'Permitir apenas domínios autorizados', FALSE, 1, '2026-06-29 15:00:00', '2026-06-29 15:00:00'),

-- Tarefas do usuário 2 (maria.silva@exemplo.com)
('Comprar material de escritório', 'Canetas, cadernos e post-its', TRUE, 2, '2026-06-01 08:00:00', '2026-06-05 12:00:00'),
('Agendar reunião com cliente', 'Discutir escopo do projeto Q3', TRUE, 2, '2026-06-03 09:30:00', '2026-06-07 14:30:00'),
('Preparar apresentação de resultados', 'Slides com KPIs do trimestre', TRUE, 2, '2026-06-05 10:00:00', '2026-06-12 16:00:00'),
('Revisar contratos de fornecedores', 'Validar cláusulas de pagamento', FALSE, 2, '2026-06-18 11:30:00', '2026-06-18 11:30:00'),
('Organizar evento de integração', 'Happy hour com a equipe na sexta', FALSE, 2, '2026-06-20 14:00:00', '2026-06-20 14:00:00'),
('Fazer backup dos arquivos', 'Copiar documentos para nuvem', FALSE, 2, '2026-06-22 08:45:00', '2026-06-22 08:45:00'),
('Atualizar planilha de despesas', 'Incluir gastos de junho', FALSE, 2, '2026-06-24 13:30:00', '2026-06-24 13:30:00'),
('Conferir relatório fiscal', 'Verificar pendências com contador', FALSE, 2, '2026-06-26 10:15:00', '2026-06-26 10:15:00'),
('Renovar assinatura de software', 'Licenças vencem em 15 dias', FALSE, 2, '2026-06-28 15:45:00', '2026-06-28 15:45:00'),
('Enviar feedback para time', 'Avaliar performance do último sprint', FALSE, 2, '2026-06-29 09:00:00', '2026-06-29 09:00:00'),

-- Tarefas do usuário 3 (joao.santos@exemplo.com)
('Estudar PostgreSQL avançado', 'Focar em otimização e índices', TRUE, 3, '2026-05-15 07:00:00', '2026-05-30 20:00:00'),
('Ler livro Clean Code', 'Terminar capítulos 8 a 12', TRUE, 3, '2026-06-01 19:00:00', '2026-06-10 22:00:00'),
('Fazer curso de Docker', 'Completar módulos 1 a 5', FALSE, 3, '2026-06-15 18:30:00', '2026-06-15 18:30:00'),
('Praticar algoritmos no LeetCode', 'Resolver 5 problemas por dia', FALSE, 3, '2026-06-20 20:00:00', '2026-06-20 20:00:00'),
('Assistir aula de Node.js', 'Módulo sobre streams e buffers', FALSE, 3, '2026-06-22 21:00:00', '2026-06-22 21:00:00'),
('Estudar design patterns', 'Factory, Singleton e Observer', FALSE, 3, '2026-06-24 19:30:00', '2026-06-24 19:30:00'),
('Revisar conteúdo de redes', 'TCP/IP, HTTP e WebSockets', FALSE, 3, '2026-06-26 18:00:00', '2026-06-26 18:00:00'),
('Fazer exercícios de SQL', 'JOINs complexos e subqueries', FALSE, 3, '2026-06-27 20:30:00', '2026-06-27 20:30:00'),
('Ler artigo sobre microserviços', 'Comparar com arquitetura monolítica', FALSE, 3, '2026-06-28 19:00:00', '2026-06-28 19:00:00'),
('Praticar TypeScript', 'Tipos avançados e generics', FALSE, 3, '2026-06-29 21:15:00', '2026-06-29 21:15:00'),

-- Tarefas do usuário 4 (ana.oliveira@exemplo.com)
('Marcar consulta com dentista', 'Limpeza semestral', TRUE, 4, '2026-06-01 10:00:00', '2026-06-03 11:00:00'),
('Renovar carteira de motorista', 'Verificar documentos necessários', TRUE, 4, '2026-06-05 14:30:00', '2026-06-08 16:00:00'),
('Comprar presente de aniversário', 'Aniversário da mãe no dia 25', FALSE, 4, '2026-06-18 12:00:00', '2026-06-18 12:00:00'),
('Pagar conta de luz', 'Vencimento dia 10', FALSE, 4, '2026-06-20 09:00:00', '2026-06-20 09:00:00')
,
('Fazer check-up médico anual', 'Agendar exames de rotina', FALSE, 4, '2026-06-22 11:30:00', '2026-06-22 11:30:00'),
('Organizar armário do quarto', 'Doar roupas que não uso mais', FALSE, 4, '2026-06-24 15:00:00', '2026-06-24 15:00:00'),
('Trocar filtro do ar condicionado', 'Manutenção preventiva', FALSE, 4, '2026-06-26 10:45:00', '2026-06-26 10:45:00'),
('Levar carro para revisão', 'Revisão dos 10 mil km', FALSE, 4, '2026-06-27 08:00:00', '2026-06-27 08:00:00'),
('Comprar remédios da farmácia', 'Lista: paracetamol e vitamina C', FALSE, 4, '2026-06-28 14:20:00', '2026-06-28 14:20:00'),
('Renovar plano de saúde', 'Comparar preços de operadoras', FALSE, 4, '2026-06-29 16:30:00', '2026-06-29 16:30:00'),

-- Tarefas do usuário 5 (pedro.costa@exemplo.com)
('Criar design do novo site', 'Mockups para homepage e contato', TRUE, 5, '2026-06-02 09:00:00', '2026-06-10 18:00:00'),
('Revisar identidade visual', 'Atualizar logos e paleta de cores', TRUE, 5, '2026-06-05 10:30:00', '2026-06-12 15:00:00'),
('Fazer protótipo de app mobile', 'Figma com fluxo de navegação', FALSE, 5, '2026-06-18 11:00:00', '2026-06-18 11:00:00'),
('Editar vídeo institucional', 'Adicionar legendas e efeitos', FALSE, 5, '2026-06-20 13:45:00', '2026-06-20 13:45:00'),
('Criar posts para redes sociais', 'Calendário de conteúdo de julho', FALSE, 5, '2026-06-22 14:30:00', '2026-06-22 14:30:00'),
('Desenvolver banner para campanha', 'Promoção de verão', FALSE, 5, '2026-06-24 09:15:00', '2026-06-24 09:15:00'),
('Revisar material de treinamento', 'Slides para onboarding de novos funcionários', FALSE, 5, '2026-06-26 11:00:00', '2026-06-26 11:00:00'),
('Criar animações para UI', 'Micro-interações para botões', FALSE, 5, '2026-06-27 15:20:00', '2026-06-27 15:20:00'),
('Atualizar portfólio online', 'Adicionar últimos 3 projetos', FALSE, 5, '2026-06-28 10:00:00', '2026-06-28 10:00:00'),
('Fazer benchmark de concorrentes', 'Análise de design de 5 sites', FALSE, 5, '2026-06-29 13:30:00', '2026-06-29 13:30:00'),

-- Tarefas do usuário 6 (julia.fernandes@exemplo.com)
('Planejar cardápio da semana', 'Refeições saudáveis e econômicas', TRUE, 6, '2026-06-01 07:30:00', '2026-06-01 19:00:00'),
('Fazer compras no mercado', 'Lista: frutas, verduras e proteínas', TRUE, 6, '2026-06-02 08:00:00', '2026-06-02 11:00:00'),
('Matricular filho na escola', 'Documentação e matrícula online', TRUE, 6, '2026-06-05 09:30:00', '2026-06-08 14:00:00'),
('Pagar mensalidade do condomínio', 'Vencimento dia 5', FALSE, 6, '2026-06-20 10:00:00', '2026-06-20 10:00:00'),
('Levar pet ao veterinário', 'Vacinação anual do cachorro', FALSE, 6, '2026-06-22 14:00:00', '2026-06-22 14:00:00'),
('Organizar festa de aniversário', 'Aniversário de 5 anos do filho', FALSE, 6, '2026-06-24 11:30:00', '2026-06-24 11:30:00'),
('Contratar diarista', 'Faxina completa da casa', FALSE, 6, '2026-06-26 08:45:00', '2026-06-26 08:45:00'),
('Renovar seguro residencial', 'Comparar seguradoras', FALSE, 6, '2026-06-27 15:00:00', '2026-06-27 15:00:00'),
('Comprar móvel novo para sala', 'Pesquisar sofás em promoção', FALSE, 6, '2026-06-28 12:20:00', '2026-06-28 12:20:00'),
('Agendar limpeza de caixa d''água', 'Serviço semestral obrigatório', FALSE, 6, '2026-06-29 09:15:00', '2026-06-29 09:15:00'),

-- Tarefas do usuário 7 (carlos.almeida@exemplo.com)
('Treinar pernas na academia', 'Agachamento, leg press e extensora', TRUE, 7, '2026-06-01 06:00:00', '2026-06-01 07:30:00'),
('Correr 5km no parque', 'Manter ritmo de 6 min/km', TRUE, 7, '2026-06-03 06:30:00', '2026-06-03 07:15:00'),
('Nadar 1000 metros', 'Treino de resistência', TRUE, 7, '2026-06-05 18:00:00', '2026-06-05 19:00:00'),
('Treinar costas e bíceps', 'Remada, pulldown e rosca', FALSE, 7, '2026-06-20 06:00:00', '2026-06-20 06:00:00'),
('Fazer aula de yoga', 'Alongamento e respiração', FALSE, 7, '2026-06-22 19:00:00', '2026-06-22 19:00:00'),
('Pedalar 20km', 'Treino de bike no fim de semana', FALSE, 7, '2026-06-24 07:00:00', '2026-06-24 07:00:00')
,
('Fazer treino funcional', 'Circuito de 30 minutos', FALSE, 7, '2026-06-26 06:30:00', '2026-06-26 06:30:00'),
('Treinar peito e tríceps', 'Supino, crucifixo e tríceps', FALSE, 7, '2026-06-27 18:30:00', '2026-06-27 18:30:00'),
('Participar de corrida de rua', 'Prova de 10km no sábado', FALSE, 7, '2026-06-28 07:00:00', '2026-06-28 07:00:00'),
('Atualizar ficha de treino', 'Consultar personal trainer', FALSE, 7, '2026-06-29 19:00:00', '2026-06-29 19:00:00'),

-- Tarefas do usuário 8 (beatriz.rodrigues@exemplo.com)
('Enviar proposta para cliente', 'Orçamento detalhado do projeto', TRUE, 8, '2026-06-02 10:00:00', '2026-06-05 16:00:00'),
('Revisar contrato de parceria', 'Validar cláusulas com jurídico', TRUE, 8, '2026-06-04 11:30:00', '2026-06-08 14:30:00'),
('Participar de webinar de vendas', 'Técnicas de negociação B2B', TRUE, 8, '2026-06-06 15:00:00', '2026-06-06 17:00:00'),
('Fazer follow-up com leads', 'Contatar 10 leads da semana passada', FALSE, 8, '2026-06-20 09:00:00', '2026-06-20 09:00:00'),
('Atualizar CRM com contatos', 'Adicionar dados de novos prospects', FALSE, 8, '2026-06-22 10:30:00', '2026-06-22 10:30:00'),
('Preparar pitch de vendas', 'Apresentação para reunião com CEO', FALSE, 8, '2026-06-24 13:00:00', '2026-06-24 13:00:00'),
('Analisar métricas de conversão', 'Relatório de taxa de fechamento', FALSE, 8, '2026-06-26 11:15:00', '2026-06-26 11:15:00'),
('Treinar novo vendedor', 'Onboarding sobre produtos', FALSE, 8, '2026-06-27 14:30:00', '2026-06-27 14:30:00'),
('Negociar desconto com fornecedor', 'Reduzir custos em 15%', FALSE, 8, '2026-06-28 10:00:00', '2026-06-28 10:00:00'),
('Enviar relatório de vendas', 'Performance de junho', FALSE, 8, '2026-06-29 16:00:00', '2026-06-29 16:00:00'),

-- Tarefas do usuário 9 (rafael.pereira@exemplo.com)
('Instalar servidor Linux', 'Ubuntu 22.04 LTS em VM', TRUE, 9, '2026-06-01 08:00:00', '2026-06-02 12:00:00'),
('Configurar firewall', 'Regras de iptables para produção', TRUE, 9, '2026-06-03 09:30:00', '2026-06-05 15:00:00'),
('Fazer backup do banco de dados', 'Snapshot diário automatizado', TRUE, 9, '2026-06-07 10:00:00', '2026-06-07 18:00:00'),
('Atualizar certificados SSL', 'Renovar Let''s Encrypt', FALSE, 9, '2026-06-20 11:00:00', '2026-06-20 11:00:00'),
('Monitorar logs de erro', 'Investigar falhas no Nginx', FALSE, 9, '2026-06-22 13:30:00', '2026-06-22 13:30:00'),
('Escalar recursos do servidor', 'Aumentar RAM para 16GB', FALSE, 9, '2026-06-24 14:45:00', '2026-06-24 14:45:00'),
('Configurar load balancer', 'Distribuir carga entre 3 servidores', FALSE, 9, '2026-06-26 09:00:00', '2026-06-26 09:00:00'),
('Implementar CI/CD com Jenkins', 'Pipeline automático de deploy', FALSE, 9, '2026-06-27 10:30:00', '2026-06-27 10:30:00'),
('Auditar segurança do sistema', 'Scan de vulnerabilidades', FALSE, 9, '2026-06-28 15:00:00', '2026-06-28 15:00:00'),
('Documentar arquitetura de rede', 'Diagrama de infraestrutura', FALSE, 9, '2026-06-29 11:20:00', '2026-06-29 11:20:00'),

-- Tarefas do usuário 10 (fernanda.martins@exemplo.com)
('Escrever artigo para blog', 'Tema: Tendências de UX em 2026', TRUE, 10, '2026-06-01 14:00:00', '2026-06-05 18:00:00'),
('Gravar podcast sobre design', 'Episódio sobre acessibilidade', TRUE, 10, '2026-06-03 16:00:00', '2026-06-07 20:00:00'),
('Editar fotos do portfólio', 'Tratamento e correção de cores', TRUE, 10, '2026-06-05 10:30:00', '2026-06-08 14:00:00'),
('Criar newsletter mensal', 'Resumo de conteúdos de junho', FALSE, 10, '2026-06-20 15:00:00', '2026-06-20 15:00:00'),
('Responder comentários no Instagram', 'Engajamento com seguidores', FALSE, 10, '2026-06-22 09:30:00', '2026-06-22 09:30:00'),
('Fazer live sobre carreira', 'Dicas para iniciantes em design', FALSE, 10, '2026-06-24 19:00:00', '2026-06-24 19:00:00'),
('Atualizar site pessoal', 'Adicionar seção de depoimentos', FALSE, 10, '2026-06-26 11:00:00', '2026-06-26 11:00:00'),
('Criar templates para Notion', 'Organização de projetos freelance', FALSE, 10, '2026-06-27 14:20:00', '2026-06-27 14:20:00'),
('Participar de evento de networking', 'Meetup de designers em SP', FALSE, 10, '2026-06-28 18:00:00', '2026-06-28 18:00:00'),
('Revisar propostas de clientes', 'Analisar viabilidade de 3 projetos', FALSE, 10, '2026-06-29 10:15:00', '2026-06-29 10:15:00')
,

-- Tarefas do usuário 11-15 (restante dos usuários)
('Estudar inglês avançado', 'Praticar conversação', TRUE, 11, '2026-06-01 20:00:00', '2026-06-10 21:30:00'),
('Fazer curso de Excel avançado', 'Macros e tabelas dinâmicas', FALSE, 11, '2026-06-20 19:00:00', '2026-06-20 19:00:00'),
('Ler livro de ficção científica', 'Terminar Fundação de Asimov', FALSE, 11, '2026-06-22 21:00:00', '2026-06-22 21:00:00'),
('Assistir documentário', 'Série sobre história do Brasil', FALSE, 11, '2026-06-24 20:30:00', '2026-06-24 20:30:00'),
('Praticar violão', 'Aprender 3 músicas novas', FALSE, 11, '2026-06-26 19:15:00', '2026-06-26 19:15:00'),
('Fazer aula de culinária online', 'Receitas vegetarianas', FALSE, 11, '2026-06-28 18:00:00', '2026-06-28 18:00:00'),
('Organizar fotos no Google Photos', 'Criar álbuns por ano', FALSE, 11, '2026-06-29 15:30:00', '2026-06-29 15:30:00'),

('Planejar viagem de férias', 'Roteiro para Europa em julho', TRUE, 12, '2026-06-02 10:00:00', '2026-06-10 16:00:00'),
('Comprar passagens aéreas', 'Buscar melhor preço e horário', TRUE, 12, '2026-06-05 11:30:00', '2026-06-08 14:00:00'),
('Reservar hotéis', 'Acomodações em 5 cidades', FALSE, 12, '2026-06-20 12:00:00', '2026-06-20 12:00:00'),
('Fazer seguro viagem', 'Cobertura para 30 dias', FALSE, 12, '2026-06-22 09:45:00', '2026-06-22 09:45:00'),
('Renovar passaporte', 'Validade expirada', FALSE, 12, '2026-06-24 08:30:00', '2026-06-24 08:30:00'),
('Comprar malas novas', 'Bagagem de mão e despachada', FALSE, 12, '2026-06-26 14:20:00', '2026-06-26 14:20:00'),
('Trocar moeda estrangeira', 'Euros para viagem', FALSE, 12, '2026-06-28 10:00:00', '2026-06-28 10:00:00'),
('Fazer lista de roupas para viagem', 'Preparar mala 1 semana antes', FALSE, 12, '2026-06-29 16:45:00', '2026-06-29 16:45:00'),

('Revisar código do projeto', 'Code review de 5 pull requests', TRUE, 13, '2026-06-01 09:00:00', '2026-06-03 17:00:00'),
('Fazer deploy em produção', 'Release versão 2.0', TRUE, 13, '2026-06-05 14:00:00', '2026-06-06 10:00:00'),
('Corrigir bugs reportados', '15 issues abertas no GitHub', FALSE, 13, '2026-06-20 10:30:00', '2026-06-20 10:30:00'),
('Atualizar dependências npm', 'Verificar vulnerabilidades', FALSE, 13, '2026-06-22 11:00:00', '2026-06-22 11:00:00'),
('Escrever documentação de API', 'Swagger completo de endpoints', FALSE, 13, '2026-06-24 13:45:00', '2026-06-24 13:45:00'),
('Refatorar módulo de autenticação', 'Melhorar legibilidade do código', FALSE, 13, '2026-06-26 15:20:00', '2026-06-26 15:20:00'),
('Implementar testes E2E', 'Cypress para fluxos críticos', FALSE, 13, '2026-06-28 09:00:00', '2026-06-28 09:00:00'),
('Otimizar bundle do frontend', 'Reduzir tamanho em 30%', FALSE, 13, '2026-06-29 14:00:00', '2026-06-29 14:00:00'),

('Investir em ações', 'Comprar 100 ações da PETR4', TRUE, 14, '2026-06-01 10:00:00', '2026-06-02 11:30:00'),
('Pagar cartão de crédito', 'Fatura de maio', TRUE, 14, '2026-06-05 09:00:00', '2026-06-05 12:00:00'),
('Declarar imposto de renda', 'Reunir documentos', FALSE, 14, '2026-06-20 11:30:00', '2026-06-20 11:30:00'),
('Revisar investimentos', 'Rebalancear carteira', FALSE, 14, '2026-06-22 14:00:00', '2026-06-22 14:00:00'),
('Negociar dívidas', 'Acordo com banco', FALSE, 14, '2026-06-24 10:15:00', '2026-06-24 10:15:00'),
('Criar planilha de orçamento', 'Controle mensal de gastos', FALSE, 14, '2026-06-26 13:30:00', '2026-06-26 13:30:00'),
('Abrir conta em corretora', 'Investir em renda fixa', FALSE, 14, '2026-06-28 11:00:00', '2026-06-28 11:00:00'),
('Estudar sobre criptomoedas', 'Entender blockchain', FALSE, 14, '2026-06-29 19:00:00', '2026-06-29 19:00:00'),

('Limpar caixa de entrada', 'Organizar 500 emails', TRUE, 15, '2026-06-01 08:00:00', '2026-06-03 12:00:00'),
('Fazer backup do computador', 'HD externo e nuvem', TRUE, 15, '2026-06-05 10:00:00', '2026-06-05 15:00:00'),
('Desinstalar programas não usados', 'Liberar espaço no SSD', FALSE, 15, '2026-06-20 14:30:00', '2026-06-20 14:30:00'),
('Atualizar drivers gráficos', 'Nova versão da NVIDIA', FALSE, 15, '2026-06-22 16:00:00', '2026-06-22 16:00:00'),
('Organizar arquivos no desktop', 'Criar pastas por categoria', FALSE, 15, '2026-06-24 09:45:00', '2026-06-24 09:45:00'),
('Fazer scan de vírus', 'Verificação completa do sistema', FALSE, 15, '2026-06-26 11:30:00', '2026-06-26 11:30:00'),
('Limpar cache do navegador', 'Melhorar performance', FALSE, 15, '2026-06-28 13:15:00', '2026-06-28 13:15:00'),
('Reinstalar sistema operacional', 'Windows 11 clean install', FALSE, 15, '2026-06-29 08:00:00', '2026-06-29 08:00:00');

-- Verificação
SELECT COUNT(*) AS total_tarefas FROM tarefas;
SELECT usuario_id, COUNT(*) AS qtd_tarefas
FROM tarefas
GROUP BY usuario_id
ORDER BY usuario_id;
