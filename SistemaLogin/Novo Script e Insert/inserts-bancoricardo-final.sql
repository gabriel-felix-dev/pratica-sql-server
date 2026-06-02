USE BancoRicardo
GO

-- ========================================
-- PRÉ-REQUISITO
-- Substitui UNIQUE CONSTRAINT por índice filtrado
-- que ignora NULL nativamente — permite múltiplos NULL
-- ========================================
ALTER TABLE Usuario ALTER COLUMN Email VARCHAR(255) NULL;
GO

ALTER TABLE Usuario DROP CONSTRAINT UQ_Email;
GO

CREATE UNIQUE INDEX UX_Usuario_Email
    ON Usuario (Email)
    WHERE Email IS NOT NULL;
GO

-- ========================================
-- LIMPEZA
-- ========================================
DELETE OpcaoAcionada;
DELETE Logon;
DELETE Opcao;
DELETE Usuario;
DBCC CHECKIDENT ('OpcaoAcionada', RESEED, 0);
DBCC CHECKIDENT ('Logon',         RESEED, 0);
DBCC CHECKIDENT ('Opcao',         RESEED, 0);
DBCC CHECKIDENT ('Usuario',       RESEED, 0);
GO

-- ========================================
-- OPÇÕES (10 opções fixas)
-- ========================================
INSERT INTO Opcao (Nome) VALUES
('Dashboard'),     -- Id 1  → peso 20%
('Relatórios'),    -- Id 2  → peso 15%
('Vendas'),        -- Id 3  → peso 10%
('Estoque'),       -- Id 4
('Clientes'),      -- Id 5  → peso 10%
('Financeiro'),    -- Id 6
('Pedidos'),       -- Id 7
('Configurações'), -- Id 8
('Logs'),          -- Id 9
('Exportar Dados');-- Id 10
GO

-- ========================================
-- USUÁRIOS (1000 registros)
-- 90% DataCriacao em 2025, 10% em 2024
-- 95% com email, 5% com NULL
-- ========================================
WITH Nomes AS (
    SELECT N, Nome FROM (VALUES
         (1,'Ana'),(2,'Bruno'),(3,'Carlos'),(4,'Daniela'),(5,'Eduardo'),
         (6,'Fernanda'),(7,'Gustavo'),(8,'Helena'),(9,'Igor'),(10,'Juliana'),
        (11,'Kaio'),(12,'Larissa'),(13,'Marcelo'),(14,'Natalia'),(15,'Otavio'),
        (16,'Patricia'),(17,'Rafael'),(18,'Simone'),(19,'Thiago'),(20,'Ursula'),
        (21,'Valdeci'),(22,'Wanda'),(23,'Yasmin'),(24,'Zacharias'),(25,'Adriano'),
        (26,'Beatriz'),(27,'Claudio'),(28,'Denise'),(29,'Emerson'),(30,'Fabiana'),
        (31,'Gabriel'),(32,'Heloisa'),(33,'Ivan'),(34,'Joana'),(35,'Kevin'),
        (36,'Leticia'),(37,'Murilo'),(38,'Nadia'),(39,'Oswaldo'),(40,'Priscila')
    ) AS T(N, Nome)
),
Sobrenomes AS (
    SELECT N, Sobrenome FROM (VALUES
         (1,'Silva'),(2,'Santos'),(3,'Oliveira'),(4,'Costa'),(5,'Ferreira'),
         (6,'Martins'),(7,'Gomes'),(8,'Pereira'),(9,'Alves'),(10,'Rocha'),
        (11,'Dias'),(12,'Souza'),(13,'Mendes'),(14,'Lopes'),(15,'Barbosa'),
        (16,'Moreira'),(17,'Cardoso'),(18,'Castro'),(19,'Teixeira'),(20,'Ribeiro'),
        (21,'Lima'),(22,'Machado'),(23,'Monteiro'),(24,'Neves'),(25,'Nunes')
    ) AS T(N, Sobrenome)
),
Serie AS (
    SELECT TOP 1000
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM master.dbo.spt_values t1
    CROSS JOIN master.dbo.spt_values t2
),
Base AS (
    SELECT
        s.N AS RowNum,
        nm.Nome AS PrimeiroNome,
        sb.Sobrenome AS Sobrenome,
        CASE
            WHEN s.N % 10 = 0
                THEN DATEADD(DAY, (s.N * 37 + s.N % 7)  % 365, '2024-01-01')
            ELSE
                DATEADD(DAY, (s.N * 53 + s.N % 11) % 365, '2025-01-01')
        END AS DataCriacao
    FROM Serie s
    INNER JOIN Nomes      nm ON nm.N = ((s.N - 1) % 40) + 1
    INNER JOIN Sobrenomes sb ON sb.N = ((s.N - 1) % 25) + 1
)
INSERT INTO Usuario (Nome, DataCriacao, Email, Senha)
SELECT
    CONCAT(PrimeiroNome, ' ', Sobrenome, ' ', RIGHT('0000' + CAST(RowNum AS VARCHAR(4)), 4)),
    DataCriacao,
    -- 5% NULL (RowNum % 20 = 0) — permitido pelo índice filtrado
    CASE
        WHEN RowNum % 20 = 0 THEN NULL
        ELSE LOWER(CONCAT('usr', RIGHT('0000' + CAST(RowNum AS VARCHAR(4)), 4), '@empresa.com.br'))
    END,
    LEFT(CONCAT('Pw@', CAST(ABS(CHECKSUM(CAST(RowNum AS BIGINT) * 31)) % 999999 AS VARCHAR(10))), 12)
FROM Base;
GO

-- ========================================
-- LOGONS HISTÓRICOS (~15.000 registros)
-- ~10% usuários → 0 logons
-- ~50% usuários → 1–10 logons
-- ~30% usuários → 11–30 logons
-- ~10% usuários → 31–60 logons
-- 70% em 2026 (jan–mai), 30% em 2025
-- ~2% usuários com alta taxa de falha (~30%), demais ~4%
-- ========================================
WITH Usuarios AS (
    SELECT
        Id,
        DataCriacao,
        CASE
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 97)) % 10 = 0 THEN 0
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 97)) % 10 <= 5 THEN (ABS(CHECKSUM(CAST(Id AS BIGINT) * 53)) % 10) + 1
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 97)) % 10 <= 8 THEN (ABS(CHECKSUM(CAST(Id AS BIGINT) * 53)) % 20) + 11
            ELSE                                                         (ABS(CHECKSUM(CAST(Id AS BIGINT) * 53)) % 30) + 31
        END AS QtdLogons,
        CASE WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 137)) % 50 = 0 THEN 1 ELSE 0 END AS AltaFalha
    FROM Usuario
),
Serie AS (
    SELECT TOP 100
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM master.dbo.spt_values
),
Expandido AS (
    SELECT
        u.Id AS IdUsuario,
        u.AltaFalha,
        s.N  AS LogonN,
        ABS(CHECKSUM(CAST(u.Id AS BIGINT) * 1000 + s.N)) AS Semente
    FROM Usuarios u
    INNER JOIN Serie s ON s.N <= u.QtdLogons
)
INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
SELECT
    IdUsuario,
    CASE
        WHEN Semente % 10 < 7
            THEN DATEADD(MINUTE, ABS(CHECKSUM(CAST(Semente AS BIGINT) * 3)) % (151 * 24 * 60), '2026-01-01 06:00:00')
        ELSE
            DATEADD(MINUTE, ABS(CHECKSUM(CAST(Semente AS BIGINT) * 7)) % (365 * 24 * 60), '2025-01-01 06:00:00')
    END,
    CASE
        WHEN AltaFalha = 1 THEN CASE WHEN Semente % 10 < 3 THEN 0 ELSE 1 END
        ELSE                    CASE WHEN Semente % 25 = 0  THEN 0 ELSE 1 END
    END
FROM Expandido;
GO

-- ========================================
-- OPÇÕES ACIONADAS HISTÓRICAS (~30.000 registros)
-- Apenas logons com Sucesso = 1
-- 50%: 1–3 opções | 30%: 4–8 | 20%: 9–15
-- Pesos: Dashboard 20%, Relatórios 15%, Vendas 10%, Clientes 10%, demais 45%
-- InstanteLogon com progressão crescente por clique
-- ========================================
WITH LogonsSucesso AS (
    SELECT
        Id,
        DataLogon,
        CASE
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 41)) % 10 < 5 THEN (ABS(CHECKSUM(CAST(Id AS BIGINT) * 61)) % 3) + 1
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 41)) % 10 < 8 THEN (ABS(CHECKSUM(CAST(Id AS BIGINT) * 61)) % 5) + 4
            ELSE                                                        (ABS(CHECKSUM(CAST(Id AS BIGINT) * 61)) % 7) + 9
        END AS QtdOpcoes
    FROM Logon
    WHERE Sucesso = 1
),
Serie AS (
    SELECT TOP 15
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM master.dbo.spt_values
),
Expandido AS (
    SELECT
        l.Id        AS IdLogon,
        l.DataLogon,
        s.N         AS CliqueN,
        ABS(CHECKSUM(CAST(l.Id AS BIGINT) * 500 + s.N)) AS Semente
    FROM LogonsSucesso l
    INNER JOIN Serie s ON s.N <= l.QtdOpcoes
),
OpcoesPonderadas AS (
    SELECT
        IdLogon,
        DataLogon,
        CliqueN,
        Semente,
        CASE
            WHEN Semente % 100 < 20 THEN 0
            WHEN Semente % 100 < 35 THEN 1
            WHEN Semente % 100 < 45 THEN 2
            WHEN Semente % 100 < 55 THEN 4
            ELSE ABS(CHECKSUM(CAST(Semente AS BIGINT) * 73)) % 10
        END AS OpcaoOffset
    FROM Expandido
)
INSERT INTO OpcaoAcionada (IdLogon, IdOpcao, InstanteLogon)
SELECT
    op.IdLogon,
    op_ref.MinId + op.OpcaoOffset,
    DATEADD(MINUTE,
        op.CliqueN * (1 + ABS(CHECKSUM(CAST(op.Semente AS BIGINT) * 11)) % 10),
        op.DataLogon)
FROM OpcoesPonderadas op
CROSS JOIN (SELECT MIN(Id) AS MinId FROM Opcao) AS op_ref;
GO

-- ========================================
-- LOGONS DE HOJE (80 registros)
-- Usuários distribuídos por primo grande (sem NEWID())
-- Horários entre 06:00 e 22:00, não sequenciais
-- ========================================
WITH UsuariosOrdenados AS (
    SELECT
        Id,
        ROW_NUMBER() OVER (ORDER BY ABS(CHECKSUM(CAST(Id AS BIGINT) * 7919)) % 1000000) AS Pos,
        CASE WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 137)) % 50 = 0 THEN 1 ELSE 0 END AS AltaFalha
    FROM Usuario
),
Top80 AS (
    SELECT TOP 80 Id, Pos, AltaFalha
    FROM UsuariosOrdenados
    ORDER BY Pos
)
INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
SELECT
    Id,
    DATEADD(MINUTE,
        (ABS(CHECKSUM(CAST(Id AS BIGINT) * 113 + Pos)) % 960) + 360,
        CAST(CAST(GETDATE() AS DATE) AS DATETIME)),
    CASE
        WHEN AltaFalha = 1 THEN CASE WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 19)) % 10 < 3 THEN 0 ELSE 1 END
        ELSE                    CASE WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 19)) % 25 = 0  THEN 0 ELSE 1 END
    END
FROM Top80;
GO

-- ========================================
-- OPÇÕES ACIONADAS DE HOJE
-- Mesmas regras das históricas
-- ========================================
WITH LogonsHoje AS (
    SELECT
        Id,
        DataLogon,
        CASE
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 41)) % 10 < 5 THEN (ABS(CHECKSUM(CAST(Id AS BIGINT) * 61)) % 3) + 1
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 41)) % 10 < 8 THEN (ABS(CHECKSUM(CAST(Id AS BIGINT) * 61)) % 5) + 4
            ELSE                                                        (ABS(CHECKSUM(CAST(Id AS BIGINT) * 61)) % 7) + 9
        END AS QtdOpcoes
    FROM Logon
    WHERE Sucesso = 1
      AND CAST(DataLogon AS DATE) = CAST(GETDATE() AS DATE)
),
Serie AS (
    SELECT TOP 15
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM master.dbo.spt_values
),
Expandido AS (
    SELECT
        l.Id        AS IdLogon,
        l.DataLogon,
        s.N         AS CliqueN,
        ABS(CHECKSUM(CAST(l.Id AS BIGINT) * 500 + s.N)) AS Semente
    FROM LogonsHoje l
    INNER JOIN Serie s ON s.N <= l.QtdOpcoes
),
OpcoesPonderadas AS (
    SELECT
        IdLogon,
        DataLogon,
        CliqueN,
        Semente,
        CASE
            WHEN Semente % 100 < 20 THEN 0
            WHEN Semente % 100 < 35 THEN 1
            WHEN Semente % 100 < 45 THEN 2
            WHEN Semente % 100 < 55 THEN 4
            ELSE ABS(CHECKSUM(CAST(Semente AS BIGINT) * 73)) % 10
        END AS OpcaoOffset
    FROM Expandido
)
INSERT INTO OpcaoAcionada (IdLogon, IdOpcao, InstanteLogon)
SELECT
    op.IdLogon,
    op_ref.MinId + op.OpcaoOffset,
    DATEADD(MINUTE,
        op.CliqueN * (1 + ABS(CHECKSUM(CAST(op.Semente AS BIGINT) * 11)) % 10),
        op.DataLogon)
FROM OpcoesPonderadas op
CROSS JOIN (SELECT MIN(Id) AS MinId FROM Opcao) AS op_ref;
GO

-- ========================================
-- RESUMO FINAL
-- ========================================
SELECT 'Usuários'                 AS Tabela, COUNT(*) AS Total FROM Usuario
UNION ALL SELECT 'Usuários sem email',        COUNT(*) FROM Usuario WHERE Email IS NULL
UNION ALL SELECT 'Usuários sem logon',        COUNT(*) FROM Usuario
    WHERE Id NOT IN (SELECT DISTINCT IdUsuario FROM Logon)
UNION ALL SELECT 'Opções',                   COUNT(*) FROM Opcao
UNION ALL SELECT 'Logons total',             COUNT(*) FROM Logon
UNION ALL SELECT 'Logons históricos',        COUNT(*) FROM Logon
    WHERE CAST(DataLogon AS DATE) < CAST(GETDATE() AS DATE)
UNION ALL SELECT 'Logons de hoje',           COUNT(*) FROM Logon
    WHERE CAST(DataLogon AS DATE) = CAST(GETDATE() AS DATE)
UNION ALL SELECT 'Logons com Sucesso',       COUNT(*) FROM Logon WHERE Sucesso = 1
UNION ALL SELECT 'Logons Falhados',          COUNT(*) FROM Logon WHERE Sucesso = 0
UNION ALL SELECT 'Opções Acionadas',         COUNT(*) FROM OpcaoAcionada
UNION ALL SELECT 'Opções Acionadas Hoje',    COUNT(*) FROM OpcaoAcionada
    WHERE CAST(InstanteLogon AS DATE) = CAST(GETDATE() AS DATE);
GO

-- Distribuição de opções acionadas (verificar pesos)
SELECT op.Nome, COUNT(oa.Id) AS Total
FROM Opcao op
LEFT JOIN OpcaoAcionada oa ON oa.IdOpcao = op.Id
GROUP BY op.Id, op.Nome
ORDER BY op.Id;
GO
