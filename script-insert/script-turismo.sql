/*
Documentacao
Arquivo Fonte............:  01_estrutura_turismo_sqlserver.sql
Objetivo.................:  Criar a estrutura fisica oficial da avaliacao de Banco de Dados Avancado (Gestao de Excursoes)
Autor....................:  Instituto Futuro
Data.....................:  05/10/2026
Schema...................:  dbo
Observacoes..............:
                        Estrutura fisica oficial da avaliacao - nao alterar tabelas ou colunas para adaptar a solucao
                        Cria o banco Turismo quando ele ainda nao existir
                        Os objetos sao qualificados com [dbo]
                        Todas as chaves estrangeiras possuem indice NONCLUSTERED explicito, exceto quando ja lideram um UNIQUE
                        As situacoes (pre-reserva, inscricao, parcela e acordo) sao tabelas de dominio em TINYINT
                        A carga das tabelas de dominio e da massa inicial fica em 02_dados_iniciais_turismo_sqlserver.sql
*/

--------------------------------------------------------------------------------
-- CRIACAO DO BANCO DE DADOS
--------------------------------------------------------------------------------

-- Criar o banco de dados da avaliacao caso ainda nao exista
IF DB_ID('Turismo') IS NULL
    CREATE DATABASE Turismo;
GO

USE Turismo;
GO

SET NOCOUNT ON;
GO

--------------------------------------------------------------------------------
-- REMOCAO DAS TABELAS PARA REEXECUCAO DO SCRIPT
--------------------------------------------------------------------------------

-- Remover tabelas em ordem inversa de dependencia (triggers sao removidos junto com suas tabelas)
DROP TABLE IF EXISTS [dbo].[Acordo];
DROP TABLE IF EXISTS [dbo].[Pagamento];
DROP TABLE IF EXISTS [dbo].[Parcela];
DROP TABLE IF EXISTS [dbo].[Inscricao];
DROP TABLE IF EXISTS [dbo].[PreReserva];
DROP TABLE IF EXISTS [dbo].[Excursao];
DROP TABLE IF EXISTS [dbo].[Pacote];
DROP TABLE IF EXISTS [dbo].[Cliente];
DROP TABLE IF EXISTS [dbo].[SituacaoAcordo];
DROP TABLE IF EXISTS [dbo].[SituacaoParcela];
DROP TABLE IF EXISTS [dbo].[SituacaoInscricao];
DROP TABLE IF EXISTS [dbo].[SituacaoPreReserva];
GO

--------------------------------------------------------------------------------
-- TABELAS DE DOMINIO
--------------------------------------------------------------------------------

-- Criar tabela de situacoes da pre-reserva
CREATE TABLE [dbo].[SituacaoPreReserva] (
    Id TINYINT IDENTITY (1,1) NOT NULL,
    Descricao VARCHAR(50) NOT NULL,

    CONSTRAINT PK_SituacaoPreReserva PRIMARY KEY (Id),
    CONSTRAINT UQ_SituacaoPreReserva_Descricao UNIQUE (Descricao)
);
GO

-- Criar tabela de situacoes da inscricao
CREATE TABLE [dbo].[SituacaoInscricao] (
    Id TINYINT IDENTITY (1,1) NOT NULL,
    Descricao VARCHAR(50) NOT NULL,

    CONSTRAINT PK_SituacaoInscricao PRIMARY KEY (Id),
    CONSTRAINT UQ_SituacaoInscricao_Descricao UNIQUE (Descricao)
);
GO

-- Criar tabela de situacoes da parcela
CREATE TABLE [dbo].[SituacaoParcela] (
    Id TINYINT IDENTITY (1,1) NOT NULL,
    Descricao VARCHAR(50) NOT NULL,

    CONSTRAINT PK_SituacaoParcela PRIMARY KEY (Id),
    CONSTRAINT UQ_SituacaoParcela_Descricao UNIQUE (Descricao)
);
GO

-- Criar tabela de situacoes do acordo
CREATE TABLE [dbo].[SituacaoAcordo] (
    Id TINYINT IDENTITY (1,1) NOT NULL,
    Descricao VARCHAR(50) NOT NULL,

    CONSTRAINT PK_SituacaoAcordo PRIMARY KEY (Id),
    CONSTRAINT UQ_SituacaoAcordo_Descricao UNIQUE (Descricao)
);
GO

--------------------------------------------------------------------------------
-- ENTIDADES PRINCIPAIS
--------------------------------------------------------------------------------

-- Criar tabela de clientes
CREATE TABLE [dbo].[Cliente] (
    Id INT IDENTITY (1,1) NOT NULL,
    Nome VARCHAR(120) NOT NULL,
    Cpf VARCHAR(11) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    DataCriacao DATETIME2(3) NOT NULL CONSTRAINT DF_Cliente_DataCriacao DEFAULT (GETDATE()),
    Ativo BIT NOT NULL CONSTRAINT DF_Cliente_Ativo DEFAULT (1),

    CONSTRAINT PK_Cliente PRIMARY KEY (Id),
    CONSTRAINT UQ_Cliente_Cpf UNIQUE (Cpf),
    CONSTRAINT UQ_Cliente_Email UNIQUE (Email),
    CONSTRAINT CK_Cliente_CpfSomenteDigitos CHECK (LEN(Cpf) = 11 AND Cpf NOT LIKE '%[^0-9]%')
);
GO

-- Criar tabela de pacotes turisticos
CREATE TABLE [dbo].[Pacote] (
    Id INT IDENTITY (1,1) NOT NULL,
    Nome VARCHAR(120) NOT NULL,
    Destino VARCHAR(120) NOT NULL,
    ValorPorPessoa DECIMAL(14,2) NOT NULL,
    Ativo BIT NOT NULL CONSTRAINT DF_Pacote_Ativo DEFAULT (1),

    CONSTRAINT PK_Pacote PRIMARY KEY (Id),
    CONSTRAINT UQ_Pacote_Nome UNIQUE (Nome),
    CONSTRAINT CK_Pacote_ValorPorPessoaPositivo CHECK (ValorPorPessoa > 0)
);
GO

-- Criar tabela de excursoes (saidas programadas de um pacote)
CREATE TABLE [dbo].[Excursao] (
    Id INT IDENTITY (1,1) NOT NULL,
    IdPacote INT NOT NULL,
    Codigo VARCHAR(20) NOT NULL,
    DataSaida DATE NOT NULL,
    DataRetorno DATE NOT NULL,
    QuantidadeAssentos SMALLINT NOT NULL,
    Ativo BIT NOT NULL CONSTRAINT DF_Excursao_Ativo DEFAULT (1),

    CONSTRAINT PK_Excursao PRIMARY KEY (Id),
    CONSTRAINT FK_IdPacote_Excursao FOREIGN KEY (IdPacote) REFERENCES Pacote (Id),
    CONSTRAINT UQ_Excursao_Codigo UNIQUE (Codigo),
    CONSTRAINT CK_Excursao_PeriodoValido CHECK (DataRetorno >= DataSaida),
    CONSTRAINT CK_Excursao_QuantidadeAssentosPositiva CHECK (QuantidadeAssentos > 0)
);
GO

--------------------------------------------------------------------------------
-- PRE-RESERVA E INSCRICAO
--------------------------------------------------------------------------------

-- Criar tabela de pre-reservas de assentos
CREATE TABLE [dbo].[PreReserva] (
    Id INT IDENTITY (1,1) NOT NULL,
    IdCliente INT NOT NULL,
    IdExcursao INT NOT NULL,
    IdSituacaoPreReserva TINYINT NOT NULL,
    QuantidadeLugares TINYINT NOT NULL,
    DataPreReserva DATETIME2(3) NOT NULL CONSTRAINT DF_PreReserva_DataPreReserva DEFAULT (GETDATE()),
    DataExpiracao DATE NOT NULL,

    CONSTRAINT PK_PreReserva PRIMARY KEY (Id),
    CONSTRAINT FK_IdCliente_PreReserva FOREIGN KEY (IdCliente) REFERENCES Cliente (Id),
    CONSTRAINT FK_IdExcursao_PreReserva FOREIGN KEY (IdExcursao) REFERENCES Excursao (Id),
    CONSTRAINT FK_IdSituacaoPreReserva_PreReserva FOREIGN KEY (IdSituacaoPreReserva) REFERENCES SituacaoPreReserva (Id),
    CONSTRAINT CK_PreReserva_QuantidadeLugaresValida CHECK (QuantidadeLugares BETWEEN 1 AND 4),
    CONSTRAINT CK_PreReserva_DataExpiracaoValida CHECK (DataExpiracao >= CAST(DataPreReserva AS DATE))
);
GO

-- Criar tabela de inscricoes
CREATE TABLE [dbo].[Inscricao] (
    Id INT IDENTITY (1,1) NOT NULL,
    IdPreReserva INT NOT NULL,
    IdCliente INT NOT NULL,
    IdExcursao INT NOT NULL,
    IdSituacaoInscricao TINYINT NOT NULL,
    DataInscricao DATETIME2(3) NOT NULL CONSTRAINT DF_Inscricao_DataInscricao DEFAULT (GETDATE()),
    QuantidadeLugares TINYINT NOT NULL,
    ValorTotal DECIMAL(14,2) NOT NULL,
    QuantidadeParcelas TINYINT NOT NULL,

    CONSTRAINT PK_Inscricao PRIMARY KEY (Id),
    CONSTRAINT FK_IdPreReserva_Inscricao FOREIGN KEY (IdPreReserva) REFERENCES PreReserva (Id),
    CONSTRAINT FK_IdCliente_Inscricao FOREIGN KEY (IdCliente) REFERENCES Cliente (Id),
    CONSTRAINT FK_IdExcursao_Inscricao FOREIGN KEY (IdExcursao) REFERENCES Excursao (Id),
    CONSTRAINT FK_IdSituacaoInscricao_Inscricao FOREIGN KEY (IdSituacaoInscricao) REFERENCES SituacaoInscricao (Id),
    CONSTRAINT UQ_Inscricao_IdPreReserva UNIQUE (IdPreReserva),
    CONSTRAINT CK_Inscricao_QuantidadeLugaresValida CHECK (QuantidadeLugares BETWEEN 1 AND 4),
    CONSTRAINT CK_Inscricao_ValorTotalPositivo CHECK (ValorTotal > 0),
    CONSTRAINT CK_Inscricao_QuantidadeParcelasValida CHECK (QuantidadeParcelas BETWEEN 1 AND 10)
);
GO

--------------------------------------------------------------------------------
-- FINANCEIRO
--------------------------------------------------------------------------------

-- Criar tabela de parcelas
CREATE TABLE [dbo].[Parcela] (
    Id INT IDENTITY (1,1) NOT NULL,
    IdInscricao INT NOT NULL,
    IdSituacaoParcela TINYINT NOT NULL,
    Numero TINYINT NOT NULL,
    ValorOriginal DECIMAL(14,2) NOT NULL,
    DataVencimento DATE NOT NULL,

    CONSTRAINT PK_Parcela PRIMARY KEY (Id),
    CONSTRAINT FK_IdInscricao_Parcela FOREIGN KEY (IdInscricao) REFERENCES Inscricao (Id),
    CONSTRAINT FK_IdSituacaoParcela_Parcela FOREIGN KEY (IdSituacaoParcela) REFERENCES SituacaoParcela (Id),
    CONSTRAINT UQ_Parcela_IdInscricaoNumero UNIQUE (IdInscricao, Numero),
    CONSTRAINT CK_Parcela_NumeroValido CHECK (Numero BETWEEN 1 AND 10),
    CONSTRAINT CK_Parcela_ValorOriginalPositivo CHECK (ValorOriginal > 0)
);
GO

-- Criar tabela de pagamentos
CREATE TABLE [dbo].[Pagamento] (
    Id INT IDENTITY (1,1) NOT NULL,
    IdParcela INT NOT NULL,
    DataPagamento DATETIME2(3) NOT NULL CONSTRAINT DF_Pagamento_DataPagamento DEFAULT (GETDATE()),
    ValorPago DECIMAL(14,2) NOT NULL,

    CONSTRAINT PK_Pagamento PRIMARY KEY (Id),
    CONSTRAINT FK_IdParcela_Pagamento FOREIGN KEY (IdParcela) REFERENCES Parcela (Id),
    CONSTRAINT CK_Pagamento_ValorPagoPositivo CHECK (ValorPago > 0)
);
GO

-- Criar tabela de acordos de debito
CREATE TABLE [dbo].[Acordo] (
    Id INT IDENTITY (1,1) NOT NULL,
    IdInscricao INT NOT NULL,
    IdSituacaoAcordo TINYINT NOT NULL,
    DataAcordo DATETIME2(3) NOT NULL CONSTRAINT DF_Acordo_DataAcordo DEFAULT (GETDATE()),
    ValorAcordado DECIMAL(14,2) NOT NULL,

    CONSTRAINT PK_Acordo PRIMARY KEY (Id),
    CONSTRAINT FK_IdInscricao_Acordo FOREIGN KEY (IdInscricao) REFERENCES Inscricao (Id),
    CONSTRAINT FK_IdSituacaoAcordo_Acordo FOREIGN KEY (IdSituacaoAcordo) REFERENCES SituacaoAcordo (Id),
    CONSTRAINT CK_Acordo_ValorAcordadoPositivo CHECK (ValorAcordado > 0)
);
GO

--------------------------------------------------------------------------------
-- INDICES DAS CHAVES ESTRANGEIRAS
--------------------------------------------------------------------------------

-- Criar indices da tabela Excursao
CREATE NONCLUSTERED INDEX IX_Excursao_IdPacote ON [dbo].[Excursao] (IdPacote);
GO

-- Criar indices da tabela PreReserva
CREATE NONCLUSTERED INDEX IX_PreReserva_IdCliente ON [dbo].[PreReserva] (IdCliente);
GO
CREATE NONCLUSTERED INDEX IX_PreReserva_IdExcursao ON [dbo].[PreReserva] (IdExcursao);
GO
CREATE NONCLUSTERED INDEX IX_PreReserva_IdSituacaoPreReserva ON [dbo].[PreReserva] (IdSituacaoPreReserva);
GO

-- Criar indices da tabela Inscricao (IdPreReserva ja e coberto por UQ_Inscricao_IdPreReserva)
CREATE NONCLUSTERED INDEX IX_Inscricao_IdCliente ON [dbo].[Inscricao] (IdCliente);
GO
CREATE NONCLUSTERED INDEX IX_Inscricao_IdExcursao ON [dbo].[Inscricao] (IdExcursao);
GO
CREATE NONCLUSTERED INDEX IX_Inscricao_IdSituacaoInscricao ON [dbo].[Inscricao] (IdSituacaoInscricao);
GO

-- Criar indices da tabela Parcela (IdInscricao ja e coberto por UQ_Parcela_IdInscricaoNumero)
CREATE NONCLUSTERED INDEX IX_Parcela_IdSituacaoParcela ON [dbo].[Parcela] (IdSituacaoParcela);
GO

-- Criar indices da tabela Pagamento
CREATE NONCLUSTERED INDEX IX_Pagamento_IdParcela ON [dbo].[Pagamento] (IdParcela);
GO

-- Criar indices da tabela Acordo
CREATE NONCLUSTERED INDEX IX_Acordo_IdInscricao ON [dbo].[Acordo] (IdInscricao);
GO
CREATE NONCLUSTERED INDEX IX_Acordo_IdSituacaoAcordo ON [dbo].[Acordo] (IdSituacaoAcordo);
GO
