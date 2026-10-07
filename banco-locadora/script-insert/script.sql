/*
Documentacao
Arquivo Fonte............:  01_estrutura_locadora_sqlserver_padrao.sql
Objetivo.................:  Criar a estrutura fisica oficial da avaliacao de Banco de Dados Avancado (Locadora de Veiculos - diarias)
Autor....................:  Instituto Futuro
Data.....................:  06/10/2026
Schema...................:  dbo
Observacoes..............:
                        Estrutura fisica oficial da avaliacao 10/2026 - nao alterar tabelas ou colunas para adaptar a solucao
                        Cria o banco Locadora quando ele ainda nao existir
                        Os objetos sao qualificados com [dbo] e escritos sem colchetes
                        Todas as chaves estrangeiras possuem indice NONCLUSTERED explicito, exceto quando ja lideram um UNIQUE
                        A reserva e a locacao sao a mesma entidade (Locacao), que muda de situacao ao longo do ciclo
                        Os valores de tarifa e de quilometragem da categoria sao copiados para a Locacao no momento da reserva
                        A carga das tabelas de dominio e da massa inicial fica em 02_dados_iniciais_locadora_sqlserver_padrao.sql
*/

--------------------------------------------------------------------------------
-- CRIACAO DO BANCO DE DADOS
--------------------------------------------------------------------------------

-- Criar o banco de dados da avaliacao caso ainda nao exista
IF DB_ID('Locadora') IS NULL
    CREATE DATABASE Locadora;
GO

USE Locadora;
GO

SET NOCOUNT ON;
GO

--------------------------------------------------------------------------------
-- REMOCAO DAS TABELAS PARA REEXECUCAO DO SCRIPT
--------------------------------------------------------------------------------

-- Remover tabelas em ordem inversa de dependencia
DROP TABLE IF EXISTS [dbo].[Cobranca];
DROP TABLE IF EXISTS [dbo].[Locacao];
DROP TABLE IF EXISTS [dbo].[Manutencao];
DROP TABLE IF EXISTS [dbo].[Veiculo];
DROP TABLE IF EXISTS [dbo].[TarifaCategoria];
DROP TABLE IF EXISTS [dbo].[Categoria];
DROP TABLE IF EXISTS [dbo].[Cliente];
DROP TABLE IF EXISTS [dbo].[TipoCobranca];
DROP TABLE IF EXISTS [dbo].[SituacaoLocacao];
GO

--------------------------------------------------------------------------------
-- TABELAS DE DOMINIO
--------------------------------------------------------------------------------

-- Criar tabela de situacoes da locacao (RESERVADA, EM_ANDAMENTO, FINALIZADA, CANCELADA, NAO_COMPARECEU)
CREATE TABLE [dbo].[SituacaoLocacao] (
    Id TINYINT IDENTITY (1,1) NOT NULL,
    Descricao VARCHAR(50) NOT NULL,

    CONSTRAINT PK_SituacaoLocacao PRIMARY KEY (Id),
    CONSTRAINT UQ_SituacaoLocacao_Descricao UNIQUE (Descricao)
);
GO

-- Criar tabela de tipos de cobranca (DIARIAS, KM_EXCEDENTE, MULTA_ATRASO, TAXA_NAO_COMPARECIMENTO)
CREATE TABLE [dbo].[TipoCobranca] (
    Id TINYINT IDENTITY (1,1) NOT NULL,
    Descricao VARCHAR(50) NOT NULL,

    CONSTRAINT PK_TipoCobranca PRIMARY KEY (Id),
    CONSTRAINT UQ_TipoCobranca_Descricao UNIQUE (Descricao)
);
GO

--------------------------------------------------------------------------------
-- CADASTROS
--------------------------------------------------------------------------------

-- Criar tabela de clientes
CREATE TABLE [dbo].[Cliente] (
    Id INT IDENTITY (1,1) NOT NULL,
    Nome VARCHAR(120) NOT NULL,
    Cpf VARCHAR(11) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    DataNascimento DATE NOT NULL,
    NumeroCnh VARCHAR(11) NOT NULL,
    ValidadeCnh DATE NOT NULL,
    DataCriacao DATETIME2(0) NOT NULL CONSTRAINT DF_Cliente_DataCriacao DEFAULT (GETDATE()),
    Ativo BIT NOT NULL CONSTRAINT DF_Cliente_Ativo DEFAULT (1),

    CONSTRAINT PK_Cliente PRIMARY KEY (Id),
    CONSTRAINT UQ_Cliente_Cpf UNIQUE (Cpf),
    CONSTRAINT UQ_Cliente_Email UNIQUE (Email),
    CONSTRAINT UQ_Cliente_NumeroCnh UNIQUE (NumeroCnh),
    CONSTRAINT CK_Cliente_CpfSomenteDigitos CHECK (LEN(Cpf) = 11 AND Cpf NOT LIKE '%[^0-9]%'),
    CONSTRAINT CK_Cliente_NumeroCnhSomenteDigitos CHECK (LEN(NumeroCnh) = 11 AND NumeroCnh NOT LIKE '%[^0-9]%')
);
GO

-- Criar tabela de categorias (KmLivreDia NULL significa quilometragem livre ilimitada)
CREATE TABLE [dbo].[Categoria] (
    Id INT IDENTITY (1,1) NOT NULL,
    Nome VARCHAR(80) NOT NULL,
    IdadeMinima TINYINT NOT NULL,
    KmLivreDia SMALLINT NULL,
    ValorKmExcedente DECIMAL(10,2) NOT NULL,
    Ativo BIT NOT NULL CONSTRAINT DF_Categoria_Ativo DEFAULT (1),

    CONSTRAINT PK_Categoria PRIMARY KEY (Id),
    CONSTRAINT UQ_Categoria_Nome UNIQUE (Nome),
    CONSTRAINT CK_Categoria_IdadeMinimaValida CHECK (IdadeMinima >= 18),
    CONSTRAINT CK_Categoria_KmLivreDiaPositivo CHECK (KmLivreDia IS NULL OR KmLivreDia > 0),
    CONSTRAINT CK_Categoria_ValorKmExcedenteNaoNegativo CHECK (ValorKmExcedente >= 0)
);
GO

-- Criar tabela de tarifas por categoria (historico com inicio de vigencia; vale a de maior inicio <= data consultada)
CREATE TABLE [dbo].[TarifaCategoria] (
    Id INT IDENTITY (1,1) NOT NULL,
    IdCategoria INT NOT NULL,
    InicioVigencia DATE NOT NULL,
    ValorDiaria DECIMAL(10,2) NOT NULL,
    ValorDiariaFimSemana DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_TarifaCategoria PRIMARY KEY (Id),
    CONSTRAINT FK_IdCategoria_TarifaCategoria FOREIGN KEY (IdCategoria) REFERENCES Categoria (Id),
    CONSTRAINT UQ_TarifaCategoria_IdCategoriaInicioVigencia UNIQUE (IdCategoria, InicioVigencia),
    CONSTRAINT CK_TarifaCategoria_ValorDiariaPositivo CHECK (ValorDiaria > 0),
    CONSTRAINT CK_TarifaCategoria_ValorDiariaFimSemanaPositivo CHECK (ValorDiariaFimSemana > 0)
);
GO

-- Criar tabela de veiculos da frota
CREATE TABLE [dbo].[Veiculo] (
    Id INT IDENTITY (1,1) NOT NULL,
    IdCategoria INT NOT NULL,
    Placa VARCHAR(7) NOT NULL,
    Modelo VARCHAR(80) NOT NULL,
    AnoFabricacao SMALLINT NOT NULL,
    Quilometragem INT NOT NULL,
    KmUltimaRevisao INT NOT NULL,
    Ativo BIT NOT NULL CONSTRAINT DF_Veiculo_Ativo DEFAULT (1),

    CONSTRAINT PK_Veiculo PRIMARY KEY (Id),
    CONSTRAINT FK_IdCategoria_Veiculo FOREIGN KEY (IdCategoria) REFERENCES Categoria (Id),
    CONSTRAINT UQ_Veiculo_Placa UNIQUE (Placa),
    CONSTRAINT CK_Veiculo_PlacaValida CHECK (LEN(Placa) = 7),
    CONSTRAINT CK_Veiculo_AnoFabricacaoValido CHECK (AnoFabricacao >= 2000),
    CONSTRAINT CK_Veiculo_QuilometragemNaoNegativa CHECK (Quilometragem >= 0),
    CONSTRAINT CK_Veiculo_KmUltimaRevisaoValida CHECK (KmUltimaRevisao BETWEEN 0 AND Quilometragem)
);
GO

-- Criar tabela de manutencoes (DataConclusao NULL significa manutencao ainda nao concluida)
CREATE TABLE [dbo].[Manutencao] (
    Id INT IDENTITY (1,1) NOT NULL,
    IdVeiculo INT NOT NULL,
    Motivo VARCHAR(100) NOT NULL,
    DataInicio DATE NOT NULL,
    DataPrevistaFim DATE NOT NULL,
    DataConclusao DATE NULL,
    KmVeiculo INT NOT NULL,

    CONSTRAINT PK_Manutencao PRIMARY KEY (Id),
    CONSTRAINT FK_IdVeiculo_Manutencao FOREIGN KEY (IdVeiculo) REFERENCES Veiculo (Id),
    CONSTRAINT CK_Manutencao_DataPrevistaFimValida CHECK (DataPrevistaFim >= DataInicio),
    CONSTRAINT CK_Manutencao_DataConclusaoValida CHECK (DataConclusao IS NULL OR DataConclusao >= DataInicio),
    CONSTRAINT CK_Manutencao_KmVeiculoNaoNegativo CHECK (KmVeiculo >= 0)
);
GO

--------------------------------------------------------------------------------
-- LOCACAO
--------------------------------------------------------------------------------

-- Criar tabela de locacoes (reserva -> retirada -> devolucao)
CREATE TABLE [dbo].[Locacao] (
    Id INT IDENTITY (1,1) NOT NULL,
    IdCliente INT NOT NULL,
    IdVeiculo INT NOT NULL,
    IdSituacaoLocacao TINYINT NOT NULL,
    DataCriacao DATETIME2(0) NOT NULL CONSTRAINT DF_Locacao_DataCriacao DEFAULT (GETDATE()),
    DataRetiradaPrevista DATE NOT NULL,
    DataDevolucaoPrevista DATE NOT NULL,
    ValorDiaria DECIMAL(10,2) NOT NULL,
    ValorDiariaFimSemana DECIMAL(10,2) NOT NULL,
    KmLivreDia SMALLINT NULL,
    ValorKmExcedente DECIMAL(10,2) NOT NULL,
    DataHoraRetirada DATETIME2(0) NULL,
    KmRetirada INT NULL,
    DataHoraDevolucao DATETIME2(0) NULL,
    KmDevolucao INT NULL,
    ValorTotal DECIMAL(12,2) NULL,

    CONSTRAINT PK_Locacao PRIMARY KEY (Id),
    CONSTRAINT FK_IdCliente_Locacao FOREIGN KEY (IdCliente) REFERENCES Cliente (Id),
    CONSTRAINT FK_IdVeiculo_Locacao FOREIGN KEY (IdVeiculo) REFERENCES Veiculo (Id),
    CONSTRAINT FK_IdSituacaoLocacao_Locacao FOREIGN KEY (IdSituacaoLocacao) REFERENCES SituacaoLocacao (Id),
    CONSTRAINT CK_Locacao_PeriodoPrevistoValido CHECK (DataDevolucaoPrevista > DataRetiradaPrevista),
    CONSTRAINT CK_Locacao_ValorDiariaPositivo CHECK (ValorDiaria > 0 AND ValorDiariaFimSemana > 0),
    CONSTRAINT CK_Locacao_KmLivreDiaPositivo CHECK (KmLivreDia IS NULL OR KmLivreDia > 0),
    CONSTRAINT CK_Locacao_ValorKmExcedenteNaoNegativo CHECK (ValorKmExcedente >= 0),
    CONSTRAINT CK_Locacao_RetiradaCompleta CHECK ((DataHoraRetirada IS NULL AND KmRetirada IS NULL) OR (DataHoraRetirada IS NOT NULL AND KmRetirada IS NOT NULL)),
    CONSTRAINT CK_Locacao_DevolucaoCompleta CHECK ((DataHoraDevolucao IS NULL AND KmDevolucao IS NULL) OR (DataHoraDevolucao IS NOT NULL AND KmDevolucao IS NOT NULL AND DataHoraRetirada IS NOT NULL)),
    CONSTRAINT CK_Locacao_DevolucaoPosteriorRetirada CHECK (DataHoraDevolucao IS NULL OR DataHoraDevolucao > DataHoraRetirada),
    CONSTRAINT CK_Locacao_KmDevolucaoValida CHECK (KmDevolucao IS NULL OR KmDevolucao >= KmRetirada),
    CONSTRAINT CK_Locacao_ValorTotalNaoNegativo CHECK (ValorTotal IS NULL OR ValorTotal >= 0)
);
GO

-- Criar tabela de cobrancas (cada tipo aparece no maximo uma vez por locacao)
CREATE TABLE [dbo].[Cobranca] (
    Id INT IDENTITY (1,1) NOT NULL,
    IdLocacao INT NOT NULL,
    IdTipoCobranca TINYINT NOT NULL,
    Valor DECIMAL(12,2) NOT NULL,
    DataCobranca DATETIME2(0) NOT NULL CONSTRAINT DF_Cobranca_DataCobranca DEFAULT (GETDATE()),

    CONSTRAINT PK_Cobranca PRIMARY KEY (Id),
    CONSTRAINT FK_IdLocacao_Cobranca FOREIGN KEY (IdLocacao) REFERENCES Locacao (Id),
    CONSTRAINT FK_IdTipoCobranca_Cobranca FOREIGN KEY (IdTipoCobranca) REFERENCES TipoCobranca (Id),
    CONSTRAINT UQ_Cobranca_IdLocacaoIdTipoCobranca UNIQUE (IdLocacao, IdTipoCobranca),
    CONSTRAINT CK_Cobranca_ValorPositivo CHECK (Valor > 0)
);
GO

--------------------------------------------------------------------------------
-- INDICES DAS CHAVES ESTRANGEIRAS
--------------------------------------------------------------------------------

-- TarifaCategoria.IdCategoria ja e coberto por UQ_TarifaCategoria_IdCategoriaInicioVigencia
CREATE NONCLUSTERED INDEX IX_Veiculo_IdCategoria ON [dbo].[Veiculo] (IdCategoria);
GO
CREATE NONCLUSTERED INDEX IX_Manutencao_IdVeiculo ON [dbo].[Manutencao] (IdVeiculo);
GO
CREATE NONCLUSTERED INDEX IX_Locacao_IdCliente ON [dbo].[Locacao] (IdCliente);
GO
CREATE NONCLUSTERED INDEX IX_Locacao_IdVeiculo ON [dbo].[Locacao] (IdVeiculo);
GO
CREATE NONCLUSTERED INDEX IX_Locacao_IdSituacaoLocacao ON [dbo].[Locacao] (IdSituacaoLocacao);
GO
-- Cobranca.IdLocacao ja e coberto por UQ_Cobranca_IdLocacaoIdTipoCobranca
CREATE NONCLUSTERED INDEX IX_Cobranca_IdTipoCobranca ON [dbo].[Cobranca] (IdTipoCobranca);
GO
