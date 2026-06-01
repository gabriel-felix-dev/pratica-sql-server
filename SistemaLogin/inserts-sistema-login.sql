USE SistemaLogin;
GO

-- =============================================
-- 1. OPÇÕES (5 distintas)
-- =============================================
INSERT INTO Opcao (Nome) VALUES
    ('Consultar Saldo'),
    ('Emitir Relatório'),
    ('Alterar Senha'),
    ('Exportar Dados'),
    ('Configurações do Perfil');
GO

-- =============================================
-- 2. USUÁRIOS (50)
-- =============================================
INSERT INTO Usuario (Nome, Email, Senha) VALUES
    ('Alice Souza',       'alice.souza@email.com',       'hK#9mLpQ2r'),
    ('Bruno Lima',        'bruno.lima@email.com',        'xW$7nVcT4s'),
    ('Carla Mendes',      'carla.mendes@email.com',      'pJ!2kRbY8u'),
    ('Diego Ferreira',    'diego.ferreira@email.com',    'mN@5hFwZ1e'),
    ('Eduarda Costa',     'eduarda.costa@email.com',     'qB#8gSxA3i'),
    ('Felipe Rocha',      'felipe.rocha@email.com',      'vL$1jPdC6o'),
    ('Gabriela Nunes',    'gabriela.nunes@email.com',    'yM!4lQeF9a'),
    ('Henrique Alves',    'henrique.alves@email.com',    'wR@7mTbG2s'),
    ('Isabela Carvalho',  'isabela.carvalho@email.com',  'nS#0kUcH5d'),
    ('João Martins',      'joao.martins@email.com',      'oT$3lVdI8f'),
    ('Karen Oliveira',    'karen.oliveira@email.com',    'pU!6mWeJ1g'),
    ('Leonardo Pinto',    'leonardo.pinto@email.com',    'qV@9nXfK4h'),
    ('Mariana Gomes',     'mariana.gomes@email.com',     'rW#2oYgL7i'),
    ('Nicolas Barbosa',   'nicolas.barbosa@email.com',   'sX$5pZhM0j'),
    ('Olivia Ribeiro',    'olivia.ribeiro@email.com',    'tY!8qAiN3k'),
    ('Paulo Santos',      'paulo.santos@email.com',      'uZ@1rBjO6l'),
    ('Quintina Azevedo',  'quintina.azevedo@email.com',  'vA#4sCkP9m'),
    ('Rafael Teixeira',   'rafael.teixeira@email.com',   'wB$7tDlQ2n'),
    ('Sabrina Campos',    'sabrina.campos@email.com',    'xC!0uEmR5o'),
    ('Thiago Pereira',    'thiago.pereira@email.com',    'yD@3vFnS8p'),
    ('Ursula Freitas',    'ursula.freitas@email.com',    'zE#6wGoT1q'),
    ('Vinicius Moura',    'vinicius.moura@email.com',    'aF$9xHpU4r'),
    ('Wandessa Cruz',     'wandessa.cruz@email.com',     'bG!2yIqV7s'),
    ('Xavier Dias',       'xavier.dias@email.com',       'cH@5zJrW0t'),
    ('Yasmin Fonseca',    'yasmin.fonseca@email.com',    'dI#8aKsX3u'),
    ('Zeca Monteiro',     'zeca.monteiro@email.com',     'eJ$1bLtY6v'),
    ('Amanda Vieira',     'amanda.vieira@email.com',     'fK!4cMuZ9w'),
    ('Bernardo Cunha',    'bernardo.cunha@email.com',    'gL@7dNvA2x'),
    ('Cecilia Lopes',     'cecilia.lopes@email.com',     'hM#0eOwB5y'),
    ('Danilo Nascimento', 'danilo.nascimento@email.com', 'iN$3fPxC8z'),
    ('Elaine Cardoso',    'elaine.cardoso@email.com',    'jO!6gQyD1a'),
    ('Fabio Guimarães',   'fabio.guimaraes@email.com',   'kP@9hRzE4b'),
    ('Gloria Medeiros',   'gloria.medeiros@email.com',   'lQ#2iSaF7c'),
    ('Humberto Araújo',   'humberto.araujo@email.com',   'mR$5jTbG0d'),
    ('Ingrid Cavalcante', 'ingrid.cavalcante@email.com', 'nS!8kUcH3e'),
    ('Julio Soares',      'julio.soares@email.com',      'oT@1lVdI6f'),
    ('Karina Bastos',     'karina.bastos@email.com',     'pU#4mWeJ9g'),
    ('Lucas Rezende',     'lucas.rezende@email.com',     'qV$7nXfK2h'),
    ('Monica Borges',     'monica.borges@email.com',     'rW!0oYgL5i'),
    ('Nelson Queiroz',    'nelson.queiroz@email.com',    'sX@3pZhM8j'),
    ('Patricia Melo',     'patricia.melo@email.com',     'tY#6qAiN1k'),
    ('Ricardo Nogueira',  'ricardo.nogueira@email.com',  'uZ$9rBjO4l'),
    ('Simone Correia',    'simone.correia@email.com',    'vA!2sCkP7m'),
    ('Tarcisio Brito',    'tarcisio.brito@email.com',    'wB@5tDlQ0n'),
    ('Umberto Lacerda',   'umberto.lacerda@email.com',   'xC#8uEmR3o'),
    ('Vera Andrade',      'vera.andrade@email.com',      'yD$1vFnS6p'),
    ('Wagner Coelho',     'wagner.coelho@email.com',     'zE!4wGoT9q'),
    ('Xenia Figueiredo',  'xenia.figueiredo@email.com',  'aF@7xHpU2r'),
    ('Yara Drummond',     'yara.drummond@email.com',     'bG#0yIqV5s'),
    ('Zuleica Paiva',     'zuleica.paiva@email.com',     'cH$3zJrW8t');
GO

-- =============================================
-- 3. LOGONS (100) — ~70% sucesso, ~30% falha
-- =============================================
INSERT INTO Logon (IdUsuario, SucessoLogin) VALUES
    (1,  1), (2,  1), (3,  0), (4,  1), (5,  1),
    (6,  0), (7,  1), (8,  1), (9,  1), (10, 0),
    (11, 1), (12, 1), (13, 0), (14, 1), (15, 1),
    (16, 1), (17, 0), (18, 1), (19, 1), (20, 0),
    (21, 1), (22, 1), (23, 1), (24, 0), (25, 1),
    (26, 1), (27, 0), (28, 1), (29, 1), (30, 1),
    (31, 0), (32, 1), (33, 1), (34, 1), (35, 0),
    (36, 1), (37, 1), (38, 0), (39, 1), (40, 1),
    (41, 1), (42, 0), (43, 1), (44, 1), (45, 1),
    (46, 0), (47, 1), (48, 1), (49, 0), (50, 1),
    (1,  1), (3,  1), (5,  0), (7,  1), (9,  1),
    (11, 0), (13, 1), (15, 1), (17, 1), (19, 0),
    (21, 1), (23, 1), (25, 0), (27, 1), (29, 1),
    (31, 1), (33, 0), (35, 1), (37, 1), (39, 0),
    (41, 1), (43, 1), (45, 1), (47, 0), (49, 1),
    (2,  1), (4,  0), (6,  1), (8,  1), (10, 1),
    (12, 0), (14, 1), (16, 1), (18, 0), (20, 1),
    (22, 1), (24, 1), (26, 0), (28, 1), (30, 1),
    (32, 0), (34, 1), (36, 1), (38, 1), (40, 0),
    (42, 1), (44, 1), (46, 1), (48, 0), (50, 1);
GO

-- =============================================
-- 4. ACIONAMENTOS (100)
--    Apenas sobre logons bem-sucedidos
--    IDs de logons com SucessoLogin = 1:
--    1,2,4,5,7,8,9,11,12,14,15,16,18,19,21,22,23,25,
--    26,28,29,30,32,33,34,36,37,39,40,41,43,44,45,47,
--    48,50,51,52,54,55,57,58,59,61,62,64,65,67,68,69,
--    71,72,74,75,76,78,79,81,82,83,85,86,88,89,91,92,
--    93,95,97,98,99
-- =============================================
INSERT INTO OpcaoAcionada (IdLogon, IdOpcao) VALUES
    (1,  1), (1,  3), (2,  2), (4,  5), (5,  1),
    (7,  4), (8,  2), (9,  3), (11, 1), (12, 5),
    (14, 2), (15, 4), (16, 1), (18, 3), (19, 2),
    (21, 5), (22, 1), (23, 4), (25, 2), (26, 3),
    (28, 1), (29, 5), (30, 2), (32, 4), (33, 1),
    (34, 3), (36, 2), (37, 5), (39, 1), (40, 4),
    (41, 2), (43, 3), (44, 1), (45, 5), (47, 2),
    (48, 4), (50, 1), (51, 3), (52, 2), (54, 5),
    (55, 1), (57, 4), (58, 2), (59, 3), (61, 1),
    (62, 5), (64, 2), (65, 4), (67, 1), (68, 3),
    (69, 2), (71, 5), (72, 1), (74, 4), (75, 2),
    (76, 3), (78, 1), (79, 5), (81, 2), (82, 4),
    (83, 1), (85, 3), (86, 2), (88, 5), (89, 1),
    (91, 4), (92, 2), (93, 3), (95, 1), (97, 5),
    (98, 2), (99, 4), (1,  2), (2,  4), (4,  1),
    (5,  3), (7,  5), (8,  1), (9,  2), (11, 4),
    (12, 3), (14, 5), (15, 1), (16, 2), (18, 4),
    (19, 5), (21, 3), (22, 2), (25, 4), (26, 1),
    (28, 5), (29, 3), (30, 4), (32, 2), (33, 5),
    (34, 1), (36, 4), (37, 2), (39, 5), (40, 3);
GO