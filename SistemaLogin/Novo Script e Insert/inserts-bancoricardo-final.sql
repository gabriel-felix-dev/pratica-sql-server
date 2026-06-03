USE BancoRicardo
GO

-- ========================================
-- PRÉ-REQUISITO (idempotente — seguro para múltiplas execuções)
-- ========================================
IF EXISTS (SELECT 1 FROM sys.indexes
           WHERE object_id = OBJECT_ID('Usuario') AND name = 'UX_Usuario_Email')
    DROP INDEX UX_Usuario_Email ON Usuario;
GO
IF EXISTS (SELECT 1 FROM sys.key_constraints
           WHERE parent_object_id = OBJECT_ID('Usuario') AND name = 'UQ_Email')
    ALTER TABLE Usuario DROP CONSTRAINT UQ_Email;
GO
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID('Usuario') AND name = 'Email' AND is_nullable = 0)
    ALTER TABLE Usuario ALTER COLUMN Email VARCHAR(255) NULL;
GO
CREATE UNIQUE INDEX UX_Usuario_Email ON Usuario (Email) WHERE Email IS NOT NULL;
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
('Dashboard'),     -- Id 1  → 20%
('Relatórios'),    -- Id 2  → 15%
('Vendas'),        -- Id 3  → 10%
('Estoque'),       -- Id 4  →  7%
('Clientes'),      -- Id 5  → 10%
('Financeiro'),    -- Id 6  →  7%
('Pedidos'),       -- Id 7  →  7%
('Configurações'), -- Id 8  →  7%
('Logs'),          -- Id 9  →  7%
('Exportar Dados');-- Id 10 → 10%
GO

-- ========================================
-- USUÁRIOS (1000 registros)
-- 90% DataCriacao em 2025, 10% em 2024 | 95% com email, 5% NULL
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
    SELECT TOP 1000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM master.dbo.spt_values t1 CROSS JOIN master.dbo.spt_values t2
),
Base AS (
    SELECT
        s.N AS RowNum, nm.Nome AS PrimeiroNome, sb.Sobrenome AS Sobrenome,
        CASE
            WHEN s.N % 10 = 0 THEN DATEADD(DAY, (s.N * 37 + s.N % 7)  % 365, '2024-01-01')
            ELSE                   DATEADD(DAY, (s.N * 53 + s.N % 11) % 365, '2025-01-01')
        END AS DataCriacao
    FROM Serie s
    INNER JOIN Nomes      nm ON nm.N = ((s.N - 1) % 40) + 1
    INNER JOIN Sobrenomes sb ON sb.N = ((s.N - 1) % 25) + 1
)
INSERT INTO Usuario (Nome, DataCriacao, Email, Senha)
SELECT
    CONCAT(PrimeiroNome, ' ', Sobrenome, ' ', RIGHT('0000' + CAST(RowNum AS VARCHAR(4)), 4)),
    DataCriacao,
    CASE WHEN RowNum % 20 = 0 THEN NULL
         ELSE LOWER(CONCAT('usr', RIGHT('0000' + CAST(RowNum AS VARCHAR(4)), 4), '@empresa.com.br')) END,
    LEFT(CONCAT('Pw@', CAST(ABS(CHECKSUM(CAST(RowNum AS BIGINT) * 31)) % 999999 AS VARCHAR(10))), 12)
FROM Base;
GO

-- ========================================
-- LOGONS HISTÓRICOS (~15.000 registros)
-- ========================================
WITH Usuarios AS (
    SELECT Id, DataCriacao,
        CASE
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 97)) % 10 = 0  THEN 0
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 97)) % 10 <= 5 THEN (ABS(CHECKSUM(CAST(Id AS BIGINT) * 53)) % 10) + 1
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 97)) % 10 <= 8 THEN (ABS(CHECKSUM(CAST(Id AS BIGINT) * 53)) % 20) + 11
            ELSE                                                       (ABS(CHECKSUM(CAST(Id AS BIGINT) * 53)) % 30) + 31
        END AS QtdLogons,
        CASE WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 137)) % 50 = 0 THEN 1 ELSE 0 END AS AltaFalha
    FROM Usuario
),
Serie AS (
    SELECT TOP 100 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM master.dbo.spt_values
),
Expandido AS (
    SELECT u.Id AS IdUsuario, u.AltaFalha, s.N AS LogonN,
           ABS(CHECKSUM(CAST(u.Id AS BIGINT) * 1000 + s.N)) AS Semente
    FROM Usuarios u INNER JOIN Serie s ON s.N <= u.QtdLogons
)
INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
SELECT
    IdUsuario,
    CASE
        WHEN Semente % 10 < 7 THEN DATEADD(MINUTE, ABS(CHECKSUM(CAST(Semente AS BIGINT) * 3)) % (151 * 24 * 60), '2026-01-01 06:00:00')
        ELSE                       DATEADD(MINUTE, ABS(CHECKSUM(CAST(Semente AS BIGINT) * 7)) % (365 * 24 * 60), '2025-01-01 06:00:00')
    END,
    CASE
        WHEN AltaFalha = 1 THEN CASE WHEN Semente % 10 < 3 THEN 0 ELSE 1 END
        ELSE                    CASE WHEN Semente % 25 = 0  THEN 0 ELSE 1 END
    END
FROM Expandido;
GO

-- ========================================
-- OPÇÕES ACIONADAS HISTÓRICAS
-- FIX: distribuição via fórmula aritmética modular (IdLogon*31 + CliqueN*17) % 100
--      CHECKSUM foi abandonado aqui — distribuía mal (concentrava em 1 bucket)
-- Pesos validados: Dash 20%, Rel 15%, Vendas 10%, Clientes 10%, Exportar 10%, demais 7%
-- ========================================
WITH LogonsSucesso AS (
    SELECT Id, DataLogon,
        CASE
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 41)) % 10 < 5 THEN (ABS(CHECKSUM(CAST(Id AS BIGINT) * 61)) % 3) + 1
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 41)) % 10 < 8 THEN (ABS(CHECKSUM(CAST(Id AS BIGINT) * 61)) % 5) + 4
            ELSE                                                      (ABS(CHECKSUM(CAST(Id AS BIGINT) * 61)) % 7) + 9
        END AS QtdOpcoes
    FROM Logon WHERE Sucesso = 1
),
Serie AS (
    SELECT TOP 15 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM master.dbo.spt_values
),
Expandido AS (
    SELECT l.Id AS IdLogon, l.DataLogon, s.N AS CliqueN,
           -- bucket determinístico e bem distribuído (0–99)
           ABS(CAST(l.Id AS BIGINT) * 31 + s.N * 17) % 100 AS Bucket
    FROM LogonsSucesso l INNER JOIN Serie s ON s.N <= l.QtdOpcoes
)
INSERT INTO OpcaoAcionada (IdLogon, IdOpcao, InstanteLogon)
SELECT
    e.IdLogon,
    CASE
        WHEN e.Bucket < 20 THEN op.Id1
        WHEN e.Bucket < 35 THEN op.Id2
        WHEN e.Bucket < 45 THEN op.Id3
        WHEN e.Bucket < 55 THEN op.Id5
        WHEN e.Bucket < 62 THEN op.Id4
        WHEN e.Bucket < 69 THEN op.Id6
        WHEN e.Bucket < 76 THEN op.Id7
        WHEN e.Bucket < 83 THEN op.Id8
        WHEN e.Bucket < 90 THEN op.Id9
        ELSE                    op.Id10
    END,
    -- progressão crescente por clique dentro da sessão
    DATEADD(MINUTE, e.CliqueN * 3 + (e.IdLogon % 7), e.DataLogon)
FROM Expandido e
CROSS JOIN (
    SELECT
        MIN(CASE WHEN rn=1 THEN Id END) AS Id1, MIN(CASE WHEN rn=2  THEN Id END) AS Id2,
        MIN(CASE WHEN rn=3 THEN Id END) AS Id3, MIN(CASE WHEN rn=4  THEN Id END) AS Id4,
        MIN(CASE WHEN rn=5 THEN Id END) AS Id5, MIN(CASE WHEN rn=6  THEN Id END) AS Id6,
        MIN(CASE WHEN rn=7 THEN Id END) AS Id7, MIN(CASE WHEN rn=8  THEN Id END) AS Id8,
        MIN(CASE WHEN rn=9 THEN Id END) AS Id9, MIN(CASE WHEN rn=10 THEN Id END) AS Id10
    FROM (SELECT Id, ROW_NUMBER() OVER (ORDER BY Id) AS rn FROM Opcao) AS x
) AS op;
GO

-- ========================================
-- LOGONS DE HOJE (80 registros, usuários distribuídos)
-- ========================================
WITH UsuariosOrdenados AS (
    SELECT Id,
        ROW_NUMBER() OVER (ORDER BY ABS(CHECKSUM(CAST(Id AS BIGINT) * 7919)) % 1000000) AS Pos,
        CASE WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 137)) % 50 = 0 THEN 1 ELSE 0 END AS AltaFalha
    FROM Usuario
),
Top80 AS (SELECT TOP 80 Id, Pos, AltaFalha FROM UsuariosOrdenados ORDER BY Pos)
INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
SELECT
    Id,
    DATEADD(MINUTE, (ABS(CHECKSUM(CAST(Id AS BIGINT) * 113 + Pos)) % 960) + 360,
            CAST(CAST(GETDATE() AS DATE) AS DATETIME)),
    CASE
        WHEN AltaFalha = 1 THEN CASE WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 19)) % 10 < 3 THEN 0 ELSE 1 END
        ELSE                    CASE WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 19)) % 25 = 0  THEN 0 ELSE 1 END
    END
FROM Top80;
GO

-- ========================================
-- OPÇÕES ACIONADAS DE HOJE (mesma lógica de distribuição)
-- ========================================
WITH LogonsHoje AS (
    SELECT Id, DataLogon,
        CASE
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 41)) % 10 < 5 THEN (ABS(CHECKSUM(CAST(Id AS BIGINT) * 61)) % 3) + 1
            WHEN ABS(CHECKSUM(CAST(Id AS BIGINT) * 41)) % 10 < 8 THEN (ABS(CHECKSUM(CAST(Id AS BIGINT) * 61)) % 5) + 4
            ELSE                                                      (ABS(CHECKSUM(CAST(Id AS BIGINT) * 61)) % 7) + 9
        END AS QtdOpcoes
    FROM Logon
    WHERE Sucesso = 1 AND CAST(DataLogon AS DATE) = CAST(GETDATE() AS DATE)
),
Serie AS (
    SELECT TOP 15 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N FROM master.dbo.spt_values
),
Expandido AS (
    SELECT l.Id AS IdLogon, l.DataLogon, s.N AS CliqueN,
           ABS(CAST(l.Id AS BIGINT) * 31 + s.N * 17) % 100 AS Bucket
    FROM LogonsHoje l INNER JOIN Serie s ON s.N <= l.QtdOpcoes
)
INSERT INTO OpcaoAcionada (IdLogon, IdOpcao, InstanteLogon)
SELECT
    e.IdLogon,
    CASE
        WHEN e.Bucket < 20 THEN op.Id1
        WHEN e.Bucket < 35 THEN op.Id2
        WHEN e.Bucket < 45 THEN op.Id3
        WHEN e.Bucket < 55 THEN op.Id5
        WHEN e.Bucket < 62 THEN op.Id4
        WHEN e.Bucket < 69 THEN op.Id6
        WHEN e.Bucket < 76 THEN op.Id7
        WHEN e.Bucket < 83 THEN op.Id8
        WHEN e.Bucket < 90 THEN op.Id9
        ELSE                    op.Id10
    END,
    DATEADD(MINUTE, e.CliqueN * 3 + (e.IdLogon % 7), e.DataLogon)
FROM Expandido e
CROSS JOIN (
    SELECT
        MIN(CASE WHEN rn=1 THEN Id END) AS Id1, MIN(CASE WHEN rn=2  THEN Id END) AS Id2,
        MIN(CASE WHEN rn=3 THEN Id END) AS Id3, MIN(CASE WHEN rn=4  THEN Id END) AS Id4,
        MIN(CASE WHEN rn=5 THEN Id END) AS Id5, MIN(CASE WHEN rn=6  THEN Id END) AS Id6,
        MIN(CASE WHEN rn=7 THEN Id END) AS Id7, MIN(CASE WHEN rn=8  THEN Id END) AS Id8,
        MIN(CASE WHEN rn=9 THEN Id END) AS Id9, MIN(CASE WHEN rn=10 THEN Id END) AS Id10
    FROM (SELECT Id, ROW_NUMBER() OVER (ORDER BY Id) AS rn FROM Opcao) AS x
) AS op;
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
UNION ALL SELECT 'Logons de hoje',           COUNT(*) FROM Logon
    WHERE CAST(DataLogon AS DATE) = CAST(GETDATE() AS DATE)
UNION ALL SELECT 'Logons com Sucesso',       COUNT(*) FROM Logon WHERE Sucesso = 1
UNION ALL SELECT 'Logons Falhados',          COUNT(*) FROM Logon WHERE Sucesso = 0
UNION ALL SELECT 'Opções Acionadas',         COUNT(*) FROM OpcaoAcionada;
GO

-- Distribuição de opções acionadas (verificar variabilidade)
SELECT op.Nome, COUNT(oa.Id) AS Total
FROM Opcao op
LEFT JOIN OpcaoAcionada oa ON oa.IdOpcao = op.Id
GROUP BY op.Id, op.Nome
ORDER BY op.Id;
GO
