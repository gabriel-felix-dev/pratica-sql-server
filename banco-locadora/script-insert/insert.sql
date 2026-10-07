/*
Documentacao
Arquivo Fonte............:  02_dados_iniciais_locadora_sqlserver_padrao.sql
Objetivo.................:  Carregar as tabelas de dominio e a massa inicial da avaliacao de Banco de Dados Avancado (Locadora)
Autor....................:  Instituto Futuro
Data.....................:  06/10/2026
Schema...................:  dbo
Observacoes..............:
                        Executar SEMPRE logo apos 01_estrutura_locadora_sqlserver_padrao.sql (os Ids abaixo dependem das
                        tabelas recem-criadas e o 01 remove os triggers do aluno, que bloqueariam tarifas retroativas)
                        Todas as datas sao calculadas em relacao a data de execucao (D = hoje; D-3 = tres dias atras)
                        Os valores das locacoes historicas (1 a 5) foram gravados pelo sistema antigo: nao recalcular
                        A carga roda em uma unica transacao: ou tudo e gravado, ou nada

MAPA DA MASSA INICIAL
--------------------------------------------------------------------------------
SituacaoLocacao: 1 RESERVADA | 2 EM_ANDAMENTO | 3 FINALIZADA | 4 CANCELADA | 5 NAO_COMPARECEU
TipoCobranca...: 1 DIARIAS   | 2 KM_EXCEDENTE | 3 MULTA_ATRASO | 4 TAXA_NAO_COMPARECIMENTO

Categorias (idade minima | km livre por dia | valor do km excedente) e tarifas (util / fim de semana)
    1 Economico.....: 18 | ilimitado | 0,00 | D-400: 100/80   D-60: 110/90   D+20: 125/100 (tarifa futura)
    2 Intermediario.: 21 | 200       | 0,80 | D-400: 150/120  D-30: 160/130
    3 SUV...........: 21 | 150       | 1,20 | D-400: 220/190
    4 Premium.......: 25 | 100       | 2,50 | D-400: 380/420  (fim de semana mais caro)
    5 Van...........: CATEGORIA INATIVA
    6 Eletrico......: 21 | 120       | 1,50 | D+10: 240/210  (sem tarifa vigente antes de D+10)

Veiculos (km atual / km da ultima revisao)
    1 Mobi (Econ.) 32000/30000     2 Kwid (Econ.) 15000/10000     3 Argo (Econ.) INATIVO
    4 Onix Plus (Interm.) 48000/40000  - com Felipe, devolucao atrasada
    5 Virtus (Interm.) 59500/50000     - com Gabriela; faltam 500 km para a revisao preventiva (10.000 km)
    6 City (Interm.) 12000/10000       - reservado por Larissa (reserva com retirada ja passada)
    7 Renegade (SUV) 30000/30000       - MANUTENCAO NAO CONCLUIDA (D-2 a D+1) e reservado por Henrique para hoje
    8 Creta (SUV) 22000/20000          - livre
    9 BMW 320i (Premium) 18000/10000   - unico Premium; reservado por Marcos de D+5 a D+8
    10 Ducato (Van) 35000/30000        - categoria inativa
    11 BYD Dolphin (Eletrico) 5000/0   - livre

Clientes
    1 Ana (30 anos), livre                     2 Bruno: completa 25 anos AMANHA
    3 Camila: INATIVA                          4 Diego: CNH vence em D+3
    5 Elisa: 19 anos                           6 Felipe: locacao 7 EM_ANDAMENTO atrasada (prevista D-2)
    7 Gabriela: locacao 8 EM_ANDAMENTO no prazo   8 Henrique: locacao 9 RESERVADA para hoje no veiculo em manutencao
    9 Isabela: locacao 10 RESERVADA para hoje  10 Joao: locacao 11 RESERVADA de D-3 a D-1 (nao compareceu)
    11 Larissa: locacao 12 RESERVADA de D-1 a D+3 (nao compareceu)
    12 Marcos: locacao 13 RESERVADA de D+5 a D+8 no Premium
    13 Natalia e 14 Otavio: historico (locacoes 1 a 6)   15 Paula (40 anos), livre

Locacoes
    1 Natalia  FINALIZADA     veic 1  D-75 a D-72   DIARIAS 300,00
    2 Natalia  FINALIZADA     veic 4  D-45 a D-40   DIARIAS 690,00 + KM_EXCEDENTE 96,00
    3 Otavio   FINALIZADA     veic 8  D-44 a D-41 (devolvida em D-40)  DIARIAS 820,00 + MULTA_ATRASO 123,00
    4 Otavio   FINALIZADA     veic 9  D-20 a D-18   DIARIAS 800,00
    5 Otavio   NAO_COMPARECEU veic 2  D-15 a D-13   TAXA_NAO_COMPARECIMENTO 110,00
    6 Natalia  CANCELADA      veic 6  D-10 a D-8
    7 Felipe   EM_ANDAMENTO   veic 4  D-6 a D-2   retirada D-6 08:00, km 48000, tarifa 160/130
    8 Gabriela EM_ANDAMENTO   veic 5  D-2 a D+2   retirada D-2 09:00, km 59500, tarifa 160/130
    9 Henrique RESERVADA      veic 7  D a D+3     tarifa 220/190
    10 Isabela RESERVADA      veic 2  D a D+2     tarifa 110/90
    11 Joao    RESERVADA      veic 1  D-3 a D-1   tarifa 110/90
    12 Larissa RESERVADA      veic 6  D-1 a D+3   tarifa 160/130
    13 Marcos  RESERVADA      veic 9  D+5 a D+8   tarifa 380/420
*/

USE Locadora;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

DECLARE @Hoje DATE = CAST(GETDATE() AS DATE);
DECLARE @Meia DATETIME2(0) = CAST(@Hoje AS DATETIME2(0));   -- D 00:00

--------------------------------------------------------------------------------
-- TABELAS DE DOMINIO
--------------------------------------------------------------------------------

INSERT INTO [dbo].[SituacaoLocacao] (Descricao) VALUES ('RESERVADA');
INSERT INTO [dbo].[SituacaoLocacao] (Descricao) VALUES ('EM_ANDAMENTO');
INSERT INTO [dbo].[SituacaoLocacao] (Descricao) VALUES ('FINALIZADA');
INSERT INTO [dbo].[SituacaoLocacao] (Descricao) VALUES ('CANCELADA');
INSERT INTO [dbo].[SituacaoLocacao] (Descricao) VALUES ('NAO_COMPARECEU');

INSERT INTO [dbo].[TipoCobranca] (Descricao) VALUES ('DIARIAS');
INSERT INTO [dbo].[TipoCobranca] (Descricao) VALUES ('KM_EXCEDENTE');
INSERT INTO [dbo].[TipoCobranca] (Descricao) VALUES ('MULTA_ATRASO');
INSERT INTO [dbo].[TipoCobranca] (Descricao) VALUES ('TAXA_NAO_COMPARECIMENTO');

--------------------------------------------------------------------------------
-- CLIENTES
--------------------------------------------------------------------------------

INSERT INTO [dbo].[Cliente] (Nome, Cpf, Email, DataNascimento, NumeroCnh, ValidadeCnh, Ativo) VALUES
    ('Ana Beatriz Souza',       '20345678901', 'ana.souza@email.com',      DATEADD(YEAR, -30, @Hoje),                         '60011122201', DATEADD(YEAR, 3, @Hoje), 1),
    ('Bruno Carvalho Lima',     '20345678902', 'bruno.lima@email.com',     DATEADD(DAY, 1, DATEADD(YEAR, -25, @Hoje)),        '60011122202', DATEADD(YEAR, 4, @Hoje), 1),
    ('Camila Ferreira Rocha',   '20345678903', 'camila.rocha@email.com',   DATEADD(YEAR, -35, @Hoje),                         '60011122203', DATEADD(YEAR, 2, @Hoje), 0),
    ('Diego Martins Alves',     '20345678904', 'diego.alves@email.com',    DATEADD(YEAR, -28, @Hoje),                         '60011122204', DATEADD(DAY, 3, @Hoje),  1),
    ('Elisa Nogueira Pinto',    '20345678905', 'elisa.pinto@email.com',    DATEADD(DAY, -10, DATEADD(YEAR, -19, @Hoje)),      '60011122205', DATEADD(YEAR, 5, @Hoje), 1),
    ('Felipe Araujo Costa',     '20345678906', 'felipe.costa@email.com',   DATEADD(YEAR, -33, @Hoje),                         '60011122206', DATEADD(YEAR, 3, @Hoje), 1),
    ('Gabriela Ribeiro Dias',   '20345678907', 'gabriela.dias@email.com',  DATEADD(YEAR, -27, @Hoje),                         '60011122207', DATEADD(YEAR, 2, @Hoje), 1),
    ('Henrique Barbosa Melo',   '20345678908', 'henrique.melo@email.com',  DATEADD(YEAR, -41, @Hoje),                         '60011122208', DATEADD(YEAR, 5, @Hoje), 1),
    ('Isabela Teixeira Gomes',  '20345678909', 'isabela.gomes@email.com',  DATEADD(YEAR, -24, @Hoje),                         '60011122209', DATEADD(YEAR, 2, @Hoje), 1),
    ('Joao Pedro Cardoso',      '20345678910', 'joao.cardoso@email.com',   DATEADD(YEAR, -38, @Hoje),                         '60011122210', DATEADD(YEAR, 3, @Hoje), 1),
    ('Larissa Monteiro Ramos',  '20345678911', 'larissa.ramos@email.com',  DATEADD(YEAR, -29, @Hoje),                         '60011122211', DATEADD(YEAR, 1, @Hoje), 1),
    ('Marcos Vinicius Freitas', '20345678912', 'marcos.freitas@email.com', DATEADD(YEAR, -45, @Hoje),                         '60011122212', DATEADD(YEAR, 2, @Hoje), 1),
    ('Natalia Duarte Campos',   '20345678913', 'natalia.campos@email.com', DATEADD(YEAR, -31, @Hoje),                         '60011122213', DATEADD(YEAR, 4, @Hoje), 1),
    ('Otavio Pereira Nunes',    '20345678914', 'otavio.nunes@email.com',   DATEADD(YEAR, -52, @Hoje),                         '60011122214', DATEADD(YEAR, 2, @Hoje), 1),
    ('Paula Rezende Lopes',     '20345678915', 'paula.lopes@email.com',    DATEADD(YEAR, -40, @Hoje),                         '60011122215', DATEADD(YEAR, 3, @Hoje), 1);

--------------------------------------------------------------------------------
-- CATEGORIAS, TARIFAS E VEICULOS
--------------------------------------------------------------------------------

INSERT INTO [dbo].[Categoria] (Nome, IdadeMinima, KmLivreDia, ValorKmExcedente, Ativo) VALUES
    ('Economico',     18, NULL, 0.00, 1),
    ('Intermediario', 21, 200,  0.80, 1),
    ('SUV',           21, 150,  1.20, 1),
    ('Premium',       25, 100,  2.50, 1),
    ('Van',           21, 200,  1.00, 0),
    ('Eletrico',      21, 120,  1.50, 1);

INSERT INTO [dbo].[TarifaCategoria] (IdCategoria, InicioVigencia, ValorDiaria, ValorDiariaFimSemana) VALUES
    (1, DATEADD(DAY, -400, @Hoje), 100.00,  80.00),
    (1, DATEADD(DAY,  -60, @Hoje), 110.00,  90.00),
    (1, DATEADD(DAY,   20, @Hoje), 125.00, 100.00),
    (2, DATEADD(DAY, -400, @Hoje), 150.00, 120.00),
    (2, DATEADD(DAY,  -30, @Hoje), 160.00, 130.00),
    (3, DATEADD(DAY, -400, @Hoje), 220.00, 190.00),
    (4, DATEADD(DAY, -400, @Hoje), 380.00, 420.00),
    (5, DATEADD(DAY, -400, @Hoje), 260.00, 230.00),
    (6, DATEADD(DAY,   10, @Hoje), 240.00, 210.00);

INSERT INTO [dbo].[Veiculo] (IdCategoria, Placa, Modelo, AnoFabricacao, Quilometragem, KmUltimaRevisao, Ativo) VALUES
    (1, 'QWE1A11', 'Fiat Mobi',           2024, 32000, 30000, 1),
    (1, 'QWE1A12', 'Renault Kwid',        2025, 15000, 10000, 1),
    (1, 'QWE1A13', 'Fiat Argo',           2022, 41000, 40000, 0),
    (2, 'RTY2B21', 'Chevrolet Onix Plus', 2024, 48000, 40000, 1),
    (2, 'RTY2B22', 'Volkswagen Virtus',   2023, 59500, 50000, 1),
    (2, 'RTY2B23', 'Honda City',          2025, 12000, 10000, 1),
    (3, 'UIO3C31', 'Jeep Renegade',       2024, 30000, 30000, 1),
    (3, 'UIO3C32', 'Hyundai Creta',       2025, 22000, 20000, 1),
    (4, 'PAS4D41', 'BMW 320i',            2025, 18000, 10000, 1),
    (5, 'DFG5E51', 'Fiat Ducato',         2023, 35000, 30000, 1),
    (6, 'HJK6F61', 'BYD Dolphin',         2025,  5000,     0, 1);

--------------------------------------------------------------------------------
-- MANUTENCOES
--------------------------------------------------------------------------------

INSERT INTO [dbo].[Manutencao] (IdVeiculo, Motivo, DataInicio, DataPrevistaFim, DataConclusao, KmVeiculo) VALUES
    (8, 'REVISAO PREVENTIVA', DATEADD(DAY, -100, @Hoje), DATEADD(DAY, -98, @Hoje), DATEADD(DAY, -98, @Hoje), 20000),
    (7, 'TROCA DE PNEUS',     DATEADD(DAY,   -2, @Hoje), DATEADD(DAY,   1, @Hoje), NULL,                     30000);

--------------------------------------------------------------------------------
-- LOCACOES
--------------------------------------------------------------------------------

INSERT INTO [dbo].[Locacao]
    (IdCliente, IdVeiculo, IdSituacaoLocacao, DataCriacao, DataRetiradaPrevista, DataDevolucaoPrevista,
     ValorDiaria, ValorDiariaFimSemana, KmLivreDia, ValorKmExcedente,
     DataHoraRetirada, KmRetirada, DataHoraDevolucao, KmDevolucao, ValorTotal)
VALUES
    -- 1 Natalia FINALIZADA
    (13, 1, 3, DATEADD(DAY, -80, @Meia), DATEADD(DAY, -75, @Hoje), DATEADD(DAY, -72, @Hoje), 100.00,  80.00, NULL, 0.00,
     DATEADD(HOUR, 9, DATEADD(DAY, -75, @Meia)), 29000, DATEADD(MINUTE, 570, DATEADD(DAY, -72, @Meia)), 29600, 300.00),
    -- 2 Natalia FINALIZADA com km excedente
    (13, 4, 3, DATEADD(DAY, -50, @Meia), DATEADD(DAY, -45, @Hoje), DATEADD(DAY, -40, @Hoje), 150.00, 120.00, 200,  0.80,
     DATEADD(HOUR, 10, DATEADD(DAY, -45, @Meia)), 45000, DATEADD(MINUTE, 630, DATEADD(DAY, -40, @Meia)), 46120, 786.00),
    -- 3 Otavio FINALIZADA com atraso
    (14, 8, 3, DATEADD(DAY, -46, @Meia), DATEADD(DAY, -44, @Hoje), DATEADD(DAY, -41, @Hoje), 220.00, 190.00, 150,  1.20,
     DATEADD(HOUR, 10, DATEADD(DAY, -44, @Meia)), 20500, DATEADD(HOUR, 11, DATEADD(DAY, -40, @Meia)), 21000, 943.00),
    -- 4 Otavio FINALIZADA no Premium
    (14, 9, 3, DATEADD(DAY, -25, @Meia), DATEADD(DAY, -20, @Hoje), DATEADD(DAY, -18, @Hoje), 380.00, 420.00, 100,  2.50,
     DATEADD(HOUR, 9, DATEADD(DAY, -20, @Meia)), 17500, DATEADD(HOUR, 8, DATEADD(DAY, -18, @Meia)), 17700, 800.00),
    -- 5 Otavio NAO_COMPARECEU
    (14, 2, 5, DATEADD(DAY, -18, @Meia), DATEADD(DAY, -15, @Hoje), DATEADD(DAY, -13, @Hoje), 110.00,  90.00, NULL, 0.00,
     NULL, NULL, NULL, NULL, 110.00),
    -- 6 Natalia CANCELADA
    (13, 6, 4, DATEADD(DAY, -12, @Meia), DATEADD(DAY, -10, @Hoje), DATEADD(DAY, -8, @Hoje), 160.00, 130.00, 200,  0.80,
     NULL, NULL, NULL, NULL, NULL),
    -- 7 Felipe EM_ANDAMENTO atrasada
    (6,  4, 2, DATEADD(DAY, -8, @Meia),  DATEADD(DAY, -6, @Hoje),  DATEADD(DAY, -2, @Hoje),  160.00, 130.00, 200,  0.80,
     DATEADD(HOUR, 8, DATEADD(DAY, -6, @Meia)), 48000, NULL, NULL, NULL),
    -- 8 Gabriela EM_ANDAMENTO no prazo
    (7,  5, 2, DATEADD(DAY, -4, @Meia),  DATEADD(DAY, -2, @Hoje),  DATEADD(DAY, 2, @Hoje),   160.00, 130.00, 200,  0.80,
     DATEADD(HOUR, 9, DATEADD(DAY, -2, @Meia)), 59500, NULL, NULL, NULL),
    -- 9 Henrique RESERVADA para hoje (veiculo em manutencao)
    (8,  7, 1, DATEADD(DAY, -5, @Meia),  @Hoje,                    DATEADD(DAY, 3, @Hoje),   220.00, 190.00, 150,  1.20,
     NULL, NULL, NULL, NULL, NULL),
    -- 10 Isabela RESERVADA para hoje
    (9,  2, 1, DATEADD(DAY, -3, @Meia),  @Hoje,                    DATEADD(DAY, 2, @Hoje),   110.00,  90.00, NULL, 0.00,
     NULL, NULL, NULL, NULL, NULL),
    -- 11 Joao RESERVADA no passado (nao compareceu)
    (10, 1, 1, DATEADD(DAY, -7, @Meia),  DATEADD(DAY, -3, @Hoje),  DATEADD(DAY, -1, @Hoje),  110.00,  90.00, NULL, 0.00,
     NULL, NULL, NULL, NULL, NULL),
    -- 12 Larissa RESERVADA com retirada ontem (nao compareceu)
    (11, 6, 1, DATEADD(DAY, -6, @Meia),  DATEADD(DAY, -1, @Hoje),  DATEADD(DAY, 3, @Hoje),   160.00, 130.00, 200,  0.80,
     NULL, NULL, NULL, NULL, NULL),
    -- 13 Marcos RESERVADA futura no Premium
    (12, 9, 1, DATEADD(DAY, -1, @Meia),  DATEADD(DAY, 5, @Hoje),   DATEADD(DAY, 8, @Hoje),   380.00, 420.00, 100,  2.50,
     NULL, NULL, NULL, NULL, NULL);

--------------------------------------------------------------------------------
-- COBRANCAS HISTORICAS
--------------------------------------------------------------------------------

INSERT INTO [dbo].[Cobranca] (IdLocacao, IdTipoCobranca, Valor, DataCobranca) VALUES
    (1, 1, 300.00, DATEADD(MINUTE, 570, DATEADD(DAY, -72, @Meia))),
    (2, 1, 690.00, DATEADD(MINUTE, 630, DATEADD(DAY, -40, @Meia))),
    (2, 2,  96.00, DATEADD(MINUTE, 630, DATEADD(DAY, -40, @Meia))),
    (3, 1, 820.00, DATEADD(HOUR, 11, DATEADD(DAY, -40, @Meia))),
    (3, 3, 123.00, DATEADD(HOUR, 11, DATEADD(DAY, -40, @Meia))),
    (4, 1, 800.00, DATEADD(HOUR, 8, DATEADD(DAY, -18, @Meia))),
    (5, 4, 110.00, DATEADD(DAY, -14, @Meia));

COMMIT TRANSACTION;
GO

--------------------------------------------------------------------------------
-- CONFERENCIA DA CARGA
--------------------------------------------------------------------------------

SELECT 'Cliente' AS Tabela, COUNT(*) AS Registros FROM [dbo].[Cliente]
UNION ALL SELECT 'Categoria', COUNT(*) FROM [dbo].[Categoria]
UNION ALL SELECT 'TarifaCategoria', COUNT(*) FROM [dbo].[TarifaCategoria]
UNION ALL SELECT 'Veiculo', COUNT(*) FROM [dbo].[Veiculo]
UNION ALL SELECT 'Manutencao', COUNT(*) FROM [dbo].[Manutencao]
UNION ALL SELECT 'Locacao', COUNT(*) FROM [dbo].[Locacao]
UNION ALL SELECT 'Cobranca', COUNT(*) FROM [dbo].[Cobranca];
GO
