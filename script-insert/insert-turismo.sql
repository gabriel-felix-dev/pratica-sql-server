/*
Documentacao
Arquivo Fonte............:  02_dados_iniciais_turismo_sqlserver.sql
Objetivo.................:  Carregar as tabelas de dominio e a massa inicial da avaliacao (Gestao de Excursoes)
Autor....................:  Instituto Futuro
Data.....................:  05/10/2026
Schema...................:  dbo
Observacoes..............:
                        Executar logo apos 01_estrutura_turismo_sqlserver.sql (banco vazio)
                        Todas as datas sao relativas ao dia da execucao (@Hoje); recarregue 01 e 02 em outro dia
                        Os Ids sao gravados explicitamente (IDENTITY_INSERT) para que a massa seja sempre identica
                        As parcelas seguem a RN04 (valor truncado, diferenca na ultima, vencimento dia 5)
                        As parcelas PAGAS e seus pagamentos sao gravados diretamente, pois o Trigger ainda nao existe
*/

USE Turismo;
GO

SET NOCOUNT ON;
GO

--------------------------------------------------------------------------------
-- PROTECAO CONTRA CARGA DUPLICADA
--------------------------------------------------------------------------------

-- Interromper a carga quando o banco ja possuir dados
IF EXISTS (SELECT 1 FROM [dbo].[SituacaoPreReserva])
BEGIN
    RAISERROR('A massa inicial ja foi carregada. Execute novamente o arquivo 01 antes do 02.', 16, 1);
    SET NOEXEC ON;
END
GO

--------------------------------------------------------------------------------
-- CARGA DA MASSA INICIAL
--------------------------------------------------------------------------------

DECLARE @Hoje DATE = CAST(GETDATE() AS DATE);

BEGIN TRANSACTION;

-- Situacoes da pre-reserva
SET IDENTITY_INSERT [dbo].[SituacaoPreReserva] ON;
INSERT INTO [dbo].[SituacaoPreReserva] (Id, Descricao) VALUES
    (1, 'AGUARDANDO'),
    (2, 'CONFIRMADA'),
    (3, 'CANCELADA'),
    (4, 'EXPIRADA');
SET IDENTITY_INSERT [dbo].[SituacaoPreReserva] OFF;

-- Situacoes da inscricao
SET IDENTITY_INSERT [dbo].[SituacaoInscricao] ON;
INSERT INTO [dbo].[SituacaoInscricao] (Id, Descricao) VALUES
    (1, 'ATIVA'),
    (2, 'CANCELADA'),
    (3, 'CONCLUIDA');
SET IDENTITY_INSERT [dbo].[SituacaoInscricao] OFF;

-- Situacoes da parcela
SET IDENTITY_INSERT [dbo].[SituacaoParcela] ON;
INSERT INTO [dbo].[SituacaoParcela] (Id, Descricao) VALUES
    (1, 'ABERTA'),
    (2, 'VENCIDA'),
    (3, 'PAGA'),
    (4, 'CANCELADA');
SET IDENTITY_INSERT [dbo].[SituacaoParcela] OFF;

-- Situacoes do acordo
SET IDENTITY_INSERT [dbo].[SituacaoAcordo] ON;
INSERT INTO [dbo].[SituacaoAcordo] (Id, Descricao) VALUES
    (1, 'ABERTO'),
    (2, 'QUITADO'),
    (3, 'ROMPIDO');
SET IDENTITY_INSERT [dbo].[SituacaoAcordo] OFF;

-- Clientes (Fabio esta inativo)
SET IDENTITY_INSERT [dbo].[Cliente] ON;
INSERT INTO [dbo].[Cliente] (Id, Nome, Cpf, Email, Ativo) VALUES
    (1, 'Ana Beatriz Lima',     '39053344705', 'ana.lima@email.com',       1),
    (2, 'Bruno Carvalho Souza', '11144477735', 'bruno.souza@email.com',    1),
    (3, 'Carla Mendes Rocha',   '52998224725', 'carla.rocha@email.com',    1),
    (4, 'Diego Ferreira Alves', '15350946056', 'diego.alves@email.com',    1),
    (5, 'Elisa Martins Costa',  '86288366757', 'elisa.costa@email.com',    1),
    (6, 'Fabio Nunes Pereira',  '71428793860', 'fabio.pereira@email.com',  0),
    (7, 'Gabriela Torres Dias', '04807864066', 'gabriela.dias@email.com',  1),
    (8, 'Heitor Barbosa Melo',  '31285447001', 'heitor.melo@email.com',    1);
SET IDENTITY_INSERT [dbo].[Cliente] OFF;

-- Pacotes (Pantanal esta inativo; Chapada foi reajustado de 1750,00 para 1850,00)
SET IDENTITY_INSERT [dbo].[Pacote] ON;
INSERT INTO [dbo].[Pacote] (Id, Nome, Destino, ValorPorPessoa, Ativo) VALUES
    (1, 'Chapada Diamantina',  'Lencois - BA',            1850.00, 1),
    (2, 'Fernando de Noronha', 'Fernando de Noronha - PE', 4500.00, 1),
    (3, 'Jalapao',             'Mateiros - TO',           2400.00, 1),
    (4, 'Pantanal',            'Pocone - MT',             3200.00, 0);
SET IDENTITY_INSERT [dbo].[Pacote] OFF;

-- Excursoes
--   CHD-A: saida em 120 dias, 20 assentos
--   FEN-A: saida em 90 dias, apenas 4 assentos (fica lotada)
--   JAL-A: saida em 10 dias (menos de 15 dias)
--   JAL-B: excursao inativa
--   PAN-A: excursao ativa de pacote inativo
--   CHD-B: saida em 200 dias, concentra as inscricoes antigas
--   CHD-Z: saida ha 5 dias (ja partiu)
SET IDENTITY_INSERT [dbo].[Excursao] ON;
INSERT INTO [dbo].[Excursao] (Id, IdPacote, Codigo, DataSaida, DataRetorno, QuantidadeAssentos, Ativo) VALUES
    (1, 1, 'CHD-A', DATEADD(DAY, 120, @Hoje), DATEADD(DAY, 125, @Hoje), 20, 1),
    (2, 2, 'FEN-A', DATEADD(DAY,  90, @Hoje), DATEADD(DAY,  96, @Hoje),  4, 1),
    (3, 3, 'JAL-A', DATEADD(DAY,  10, @Hoje), DATEADD(DAY,  15, @Hoje), 15, 1),
    (4, 3, 'JAL-B', DATEADD(DAY, 150, @Hoje), DATEADD(DAY, 155, @Hoje), 10, 0),
    (5, 4, 'PAN-A', DATEADD(DAY, 100, @Hoje), DATEADD(DAY, 105, @Hoje), 10, 1),
    (6, 1, 'CHD-B', DATEADD(DAY, 200, @Hoje), DATEADD(DAY, 205, @Hoje), 30, 1),
    (7, 1, 'CHD-Z', DATEADD(DAY,  -5, @Hoje), @Hoje,                    12, 1);
SET IDENTITY_INSERT [dbo].[Excursao] OFF;

-- Pre-reservas
--   1 a 6 : CONFIRMADAS (originaram as inscricoes 1 a 6)
--   7     : Gabriela em FEN-A, AGUARDANDO vigente, 2 lugares
--   8     : Heitor em FEN-A, AGUARDANDO com expiracao vencida (expirada)
--   9     : Bruno em CHD-A, CANCELADA
--   10    : Carla em CHD-A, AGUARDANDO vigente, 1 lugar
--   11    : Elisa em CHD-A, EXPIRADA
SET IDENTITY_INSERT [dbo].[PreReserva] ON;
INSERT INTO [dbo].[PreReserva] (Id, IdCliente, IdExcursao, IdSituacaoPreReserva, QuantidadeLugares, DataPreReserva, DataExpiracao) VALUES
    (1,  1, 6, 2, 2, DATEADD(DAY, -100, @Hoje), DATEADD(DAY, -95,  @Hoje)),
    (2,  2, 6, 2, 1, DATEADD(DAY, -100, @Hoje), DATEADD(DAY, -95,  @Hoje)),
    (3,  3, 6, 2, 1, DATEADD(DAY, -100, @Hoje), DATEADD(DAY, -95,  @Hoje)),
    (4,  4, 6, 2, 1, DATEADD(DAY, -100, @Hoje), DATEADD(DAY, -95,  @Hoje)),
    (5,  5, 2, 2, 2, DATEADD(DAY,   -3, @Hoje), DATEADD(DAY,   2,  @Hoje)),
    (6,  8, 7, 2, 1, DATEADD(DAY, -120, @Hoje), DATEADD(DAY, -115, @Hoje)),
    (7,  7, 2, 1, 2, DATEADD(DAY,   -1, @Hoje), DATEADD(DAY,   4,  @Hoje)),
    (8,  8, 2, 1, 1, DATEADD(DAY,  -10, @Hoje), DATEADD(DAY,  -5,  @Hoje)),
    (9,  2, 1, 3, 1, DATEADD(DAY,  -20, @Hoje), DATEADD(DAY, -15,  @Hoje)),
    (10, 3, 1, 1, 1, DATEADD(DAY,   -2, @Hoje), DATEADD(DAY,   3,  @Hoje)),
    (11, 5, 1, 4, 1, DATEADD(DAY,  -30, @Hoje), DATEADD(DAY, -25,  @Hoje));
SET IDENTITY_INSERT [dbo].[PreReserva] OFF;

-- Inscricoes (todas ATIVAS; valores de Chapada na epoca = 1750,00 por pessoa)
SET IDENTITY_INSERT [dbo].[Inscricao] ON;
INSERT INTO [dbo].[Inscricao] (Id, IdPreReserva, IdCliente, IdExcursao, IdSituacaoInscricao, DataInscricao, QuantidadeLugares, ValorTotal, QuantidadeParcelas) VALUES
    (1, 1, 1, 6, 1, DATEADD(DAY, -100, @Hoje), 2, 3500.00, 6),
    (2, 2, 2, 6, 1, DATEADD(DAY, -100, @Hoje), 1, 1750.00, 4),
    (3, 3, 3, 6, 1, DATEADD(DAY, -100, @Hoje), 1, 1750.00, 2),
    (4, 4, 4, 6, 1, DATEADD(DAY, -100, @Hoje), 1, 1750.00, 4),
    (5, 5, 5, 2, 1, DATEADD(DAY,   -3, @Hoje), 2, 9000.00, 2),
    (6, 6, 8, 7, 1, DATEADD(DAY, -120, @Hoje), 1, 1750.00, 3);
SET IDENTITY_INSERT [dbo].[Inscricao] OFF;

-- Parcelas de todas as inscricoes, geradas conforme a RN04 (todas ABERTAS inicialmente)
WITH Numeros AS (
    SELECT TOP (10) CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS TINYINT) AS Numero
    FROM sys.all_objects
)
INSERT INTO [dbo].[Parcela] (IdInscricao, IdSituacaoParcela, Numero, ValorOriginal, DataVencimento)
SELECT
    i.Id,
    1,
    n.Numero,
    CASE
        WHEN n.Numero < i.QuantidadeParcelas
            THEN ROUND(i.ValorTotal / i.QuantidadeParcelas, 2, 1)
        ELSE i.ValorTotal - ROUND(i.ValorTotal / i.QuantidadeParcelas, 2, 1) * (i.QuantidadeParcelas - 1)
    END,
    DATEADD(MONTH, n.Numero - 1,
        DATEFROMPARTS(
            YEAR(DATEADD(MONTH, 1, CAST(i.DataInscricao AS DATE))),
            MONTH(DATEADD(MONTH, 1, CAST(i.DataInscricao AS DATE))),
            5))
FROM [dbo].[Inscricao] i
INNER JOIN Numeros n ON n.Numero <= i.QuantidadeParcelas;

-- Parcelas ja quitadas
UPDATE [dbo].[Parcela]
SET IdSituacaoParcela = 3
WHERE (IdInscricao = 1 AND Numero IN (1, 2))
   OR (IdInscricao = 2 AND Numero = 1)
   OR (IdInscricao = 3 AND Numero IN (1, 2))
   OR (IdInscricao = 4 AND Numero = 1)
   OR (IdInscricao = 6 AND Numero IN (1, 2, 3));

-- Parcela gravada explicitamente como VENCIDA (as demais atrasadas continuam gravadas como ABERTA - RN07)
UPDATE [dbo].[Parcela]
SET IdSituacaoParcela = 2
WHERE IdInscricao = 2 AND Numero = 2;

-- Pagamentos das parcelas PAGAS, feitos no dia do vencimento e pelo valor original
INSERT INTO [dbo].[Pagamento] (IdParcela, DataPagamento, ValorPago)
SELECT Id, DataVencimento, ValorOriginal
FROM [dbo].[Parcela]
WHERE IdSituacaoParcela = 3;

-- Acordos
--   Inscricao 1: apenas acordo ROMPIDO
--   Inscricao 2: um ABERTO e um QUITADO
--   Inscricao 4: apenas acordo ABERTO
SET IDENTITY_INSERT [dbo].[Acordo] ON;
INSERT INTO [dbo].[Acordo] (Id, IdInscricao, IdSituacaoAcordo, DataAcordo, ValorAcordado) VALUES
    (1, 2, 1, DATEADD(DAY, -30, @Hoje), 900.00),
    (2, 2, 2, DATEADD(DAY, -15, @Hoje), 450.00),
    (3, 4, 1, DATEADD(DAY,  -5, @Hoje), 900.00),
    (4, 1, 3, DATEADD(DAY, -40, @Hoje), 600.00);
SET IDENTITY_INSERT [dbo].[Acordo] OFF;

COMMIT TRANSACTION;
GO

SET NOEXEC OFF;
GO
