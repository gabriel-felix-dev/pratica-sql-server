IF DB_ID(N'RicBank') IS NULL
BEGIN
    CREATE DATABASE RicBank;
END
GO

USE RicBank;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

BEGIN TRANSACTION;

BEGIN TRY

    IF OBJECT_ID(N'[dbo].[Compra]', N'U') IS NULL
    CREATE TABLE [dbo].[Compra] (
        Id INT IDENTITY(1,1) NOT NULL,
        QuantidadeParcelas INT NOT NULL,
        EstabelecimentoDestino VARCHAR(100) NOT NULL,
        Descricao VARCHAR(200) NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_Compra_CriadoEm] DEFAULT SYSUTCDATETIME(),
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_Compra] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [CK_Compra_QuantidadeParcelas] CHECK (QuantidadeParcelas >= 0)
    );

    IF OBJECT_ID(N'[dbo].[Dependente]', N'U') IS NULL
    CREATE TABLE [dbo].[Dependente] (
        Id INT IDENTITY(1,1) NOT NULL,
        CPF CHAR(11) NOT NULL,
        Nome VARCHAR(100) NOT NULL,
        Situacao BIT NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_Dependente_CriadoEm] DEFAULT SYSUTCDATETIME(),
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_Dependente] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_Dependente_CPF] UNIQUE (CPF)
    );

    IF OBJECT_ID(N'[dbo].[FormaDePagamentoEmprestimo]', N'U') IS NULL
    CREATE TABLE [dbo].[FormaDePagamentoEmprestimo] (
        Id TINYINT NOT NULL,
        Nome VARCHAR(80) NOT NULL,

        CONSTRAINT [PK_FormaDePagamentoEmprestimo] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_FormaDePagamentoEmprestimo_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[Taxa]', N'U') IS NULL
    CREATE TABLE [dbo].[Taxa] (
        Id INT IDENTITY(1,1) NOT NULL,
        NomeTaxa VARCHAR(100) NOT NULL,
        Porcentagem DECIMAL(5,2) NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_Taxa_CriadoEm] DEFAULT SYSUTCDATETIME(),

        CONSTRAINT [PK_Taxa] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [CK_Taxa_Porcentagem] CHECK (Porcentagem BETWEEN 0 AND 100)
    );

    IF OBJECT_ID(N'[dbo].[Saldo]', N'U') IS NULL
    CREATE TABLE [dbo].[Saldo] (
        Id INT IDENTITY(1,1) NOT NULL,
        SaldoInicial DECIMAL(10,2) NOT NULL,
        Credito DECIMAL(10,2) NOT NULL,
        Debito DECIMAL(10,2) NOT NULL,

        CONSTRAINT [PK_Saldo] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [CK_Saldo_Credito] CHECK (Credito >= 0),
        CONSTRAINT [CK_Saldo_Debito] CHECK (Debito >= 0)
    );

    IF OBJECT_ID(N'[dbo].[SituacaoCartao]', N'U') IS NULL
    CREATE TABLE [dbo].[SituacaoCartao] (
        Id INT IDENTITY(1,1) NOT NULL,
        Nome VARCHAR(50) NOT NULL,

        CONSTRAINT [PK_SituacaoCartao] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_SituacaoCartao_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[SituacaoConsorcio]', N'U') IS NULL
    CREATE TABLE [dbo].[SituacaoConsorcio] (
        Id TINYINT NOT NULL,
        Nome VARCHAR(50) NOT NULL,

        CONSTRAINT [PK_SituacaoConsorcio] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_SituacaoConsorcio_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[SituacaoConta]', N'U') IS NULL
    CREATE TABLE [dbo].[SituacaoConta] (
        Id TINYINT NOT NULL,
        Nome VARCHAR(20) NOT NULL,

        CONSTRAINT [PK_SituacaoConta] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_SituacaoConta_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[SituacaoEmprestimo]', N'U') IS NULL
    CREATE TABLE [dbo].[SituacaoEmprestimo] (
        Id TINYINT NOT NULL,
        Nome VARCHAR(50) NOT NULL,

        CONSTRAINT [PK_SituacaoEmprestimo] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_SituacaoEmprestimo_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[TipoChavePix]', N'U') IS NULL
    CREATE TABLE [dbo].[TipoChavePix] (
        Id TINYINT NOT NULL,
        Nome VARCHAR(50) NOT NULL,

        CONSTRAINT [PK_TipoChavePix] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_TipoChavePix_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[TipoEmprestimo]', N'U') IS NULL
    CREATE TABLE [dbo].[TipoEmprestimo] (
        Id TINYINT NOT NULL,
        Nome VARCHAR(50) NOT NULL,

        CONSTRAINT [PK_TipoEmprestimo] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_TipoEmprestimo_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[TipoInvestimento]', N'U') IS NULL
    CREATE TABLE [dbo].[TipoInvestimento] (
        Id INT IDENTITY(1,1) NOT NULL,
        Nome VARCHAR(50) NOT NULL,

        CONSTRAINT [PK_TipoInvestimento] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_TipoInvestimento_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[TipoLimite]', N'U') IS NULL
    CREATE TABLE [dbo].[TipoLimite] (
        Id TINYINT NOT NULL,
        Nome VARCHAR(50) NOT NULL,

        CONSTRAINT [PK_TipoLimite] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_TipoLimite_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[TipoMovimentacao]', N'U') IS NULL
    CREATE TABLE [dbo].[TipoMovimentacao] (
        Id TINYINT NOT NULL,
        Nome VARCHAR(50) NOT NULL,

        CONSTRAINT [PK_TipoMovimentacao] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_TipoMovimentacao_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[TipoPagamento]', N'U') IS NULL
    CREATE TABLE [dbo].[TipoPagamento] (
        Id INT IDENTITY(1,1) NOT NULL,
        Nome VARCHAR(50) NOT NULL,

        CONSTRAINT [PK_TipoPagamento] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_TipoPagamento_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[TipoSituacaoInvestimento]', N'U') IS NULL
    CREATE TABLE [dbo].[TipoSituacaoInvestimento] (
        Id INT IDENTITY(1,1) NOT NULL,
        Nome VARCHAR(50) NOT NULL,

        CONSTRAINT [PK_TipoSituacaoInvestimento] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_TipoSituacaoInvestimento_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[StatusChequeEspecial]', N'U') IS NULL
    CREATE TABLE [dbo].[StatusChequeEspecial] (
        Id TINYINT IDENTITY(1,1) NOT NULL,
        Nome VARCHAR(100) NOT NULL,

        CONSTRAINT [PK_StatusChequeEspecial] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_StatusChequeEspecial_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[TaxaRendimento]', N'U') IS NULL
    CREATE TABLE [dbo].[TaxaRendimento] (
        Id INT IDENTITY(1,1) NOT NULL,
        Valor DECIMAL(5,2) NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_TaxaRendimento_CriadoEm] DEFAULT SYSUTCDATETIME(),

        CONSTRAINT [PK_TaxaRendimento] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [CK_TaxaRendimento_Valor] CHECK (Valor BETWEEN 0 AND 100)
    );

    IF OBJECT_ID(N'[dbo].[TipoTaxaChequeEspecial]', N'U') IS NULL
    CREATE TABLE [dbo].[TipoTaxaChequeEspecial] (
        Id SMALLINT NOT NULL,
        Nome VARCHAR(100) NOT NULL,
        Porcentagem DECIMAL(5,2) NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_TipoTaxaChequeEspecial_CriadoEm] DEFAULT SYSUTCDATETIME(),

        CONSTRAINT [PK_TipoTaxaChequeEspecial] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [CK_TipoTaxaChequeEspecial_Porcentagem] CHECK (Porcentagem BETWEEN 0 AND 100),
        CONSTRAINT [UQ_TipoTaxaChequeEspecial_Nome] UNIQUE (Nome)
    );

    IF OBJECT_ID(N'[dbo].[Agencia]', N'U') IS NULL
    CREATE TABLE [dbo].[Agencia] (
        Id INT IDENTITY(1,1) NOT NULL,
        Codigo VARCHAR(6) NOT NULL,
        Nome VARCHAR(50) NOT NULL,
        TelefoneFixo VARCHAR(15) NULL,
        Ativo BIT NOT NULL,

        -- endereco (desnormalizado: endereco de agencia nao e compartilhado)
        Logradouro VARCHAR(100) NOT NULL,
        Numero VARCHAR(10) NOT NULL,
        Complemento VARCHAR(100) NULL,
        Bairro VARCHAR(50) NOT NULL,
        Cidade VARCHAR(40) NOT NULL,
        Uf CHAR(2) NOT NULL,
        Cep CHAR(8) NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_Agencia_CriadoEm] DEFAULT SYSUTCDATETIME(),
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_Agencia] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_Agencia_Codigo] UNIQUE (Codigo)
    );

    IF OBJECT_ID(N'[dbo].[Cliente]', N'U') IS NULL
    CREATE TABLE [dbo].[Cliente] (
        Id INT IDENTITY(1,1) NOT NULL,
        Documento VARCHAR(14) NOT NULL,
        NomeCompleto VARCHAR(200) NOT NULL,
        TelefoneMovel VARCHAR(15) NULL,
        TelefoneFixo VARCHAR(15) NULL,
        DataNascimento DATE NOT NULL,
        Email VARCHAR(254) NOT NULL,

        -- endereco (desnormalizado: endereco residencial e proprio do cliente)
        Logradouro VARCHAR(100) NOT NULL,
        Numero VARCHAR(10) NOT NULL,
        Complemento VARCHAR(100) NULL,
        Bairro VARCHAR(50) NOT NULL,
        Cidade VARCHAR(40) NOT NULL,
        Uf CHAR(2) NOT NULL,
        Cep CHAR(8) NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_Cliente_CriadoEm] DEFAULT SYSUTCDATETIME(),
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_Cliente] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_Cliente_Documento] UNIQUE (Documento),
        CONSTRAINT [UQ_Cliente_Email] UNIQUE (Email)
    );


    IF OBJECT_ID(N'[dbo].[ContaCorrente]', N'U') IS NULL
    CREATE TABLE [dbo].[ContaCorrente] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdCliente INT NOT NULL,
        IdAgencia INT NOT NULL,
        IdSituacaoConta TINYINT NOT NULL,
        IdSaldo INT NOT NULL,
        Numero VARCHAR(20) NOT NULL,
        DataCriacao DATETIME NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        -- CriadoEm: ver DataCriacao acima (equivalente, mantida por compatibilidade)
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_ContaCorrente] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_ContaCorrente_Numero] UNIQUE (Numero),
        CONSTRAINT [FK_IdAgencia_ContaCorrente] FOREIGN KEY (IdAgencia) REFERENCES [dbo].[Agencia] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdSituacaoConta_ContaCorrente] FOREIGN KEY (IdSituacaoConta) REFERENCES [dbo].[SituacaoConta] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdCliente_ContaCorrente] FOREIGN KEY (IdCliente) REFERENCES [dbo].[Cliente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdSaldo_ContaCorrente] FOREIGN KEY (IdSaldo) REFERENCES [dbo].[Saldo] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [UQ_ContaCorrente_IdSaldo] UNIQUE (IdSaldo)
    );

    IF OBJECT_ID(N'[dbo].[ContaPoupanca]', N'U') IS NULL
    CREATE TABLE [dbo].[ContaPoupanca] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdSituacaoConta TINYINT NOT NULL,
        IdTaxaRendimento INT NOT NULL,
        IdSaldo INT NOT NULL,
        IdCliente INT NOT NULL,
        IdAgencia INT NOT NULL,
        Codigo VARCHAR(100) NOT NULL,
        DataCriacao DATETIME NOT NULL,
        DiaRendimento TINYINT NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        -- CriadoEm: ver DataCriacao acima (equivalente, mantida por compatibilidade)
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_ContaPoupanca] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [FK_IdTaxaRendimento_ContaPoupanca] FOREIGN KEY (IdTaxaRendimento) REFERENCES [dbo].[TaxaRendimento] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdSituacaoConta_Poupanca] FOREIGN KEY (IdSituacaoConta) REFERENCES [dbo].[SituacaoConta] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdCliente_ContaPoupanca] FOREIGN KEY (IdCliente) REFERENCES [dbo].[Cliente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdSaldo_ContaPoupanca] FOREIGN KEY (IdSaldo) REFERENCES [dbo].[Saldo] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdAgencia_ContaPoupanca] FOREIGN KEY (IdAgencia) REFERENCES [dbo].[Agencia] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [UQ_ContaPoupanca_IdSaldo] UNIQUE (IdSaldo),
        CONSTRAINT [UQ_ContaPoupanca_Codigo] UNIQUE (Codigo),
        CONSTRAINT [CK_ContaPoupanca_DiaRendimento] CHECK (DiaRendimento BETWEEN 1 AND 31)
    );

    IF OBJECT_ID(N'[dbo].[Cartao]', N'U') IS NULL
    CREATE TABLE [dbo].[Cartao] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdContaCorrente INT NOT NULL,
        IdSituacaoCartao INT NOT NULL,
        NumeroMascarado VARCHAR(19) NOT NULL,
        MesValidade TINYINT NOT NULL,
        AnoValidade SMALLINT NOT NULL,
        DiaVencimento TINYINT NOT NULL,
        DiaFechamento TINYINT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_Cartao_CriadoEm] DEFAULT SYSUTCDATETIME(),
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_Cartao] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [CK_Cartao_MesValidade] CHECK (MesValidade BETWEEN 1 AND 12),
        CONSTRAINT [CK_Cartao_AnoValidade] CHECK (AnoValidade BETWEEN 2020 AND 2100),
        CONSTRAINT [FK_IdContaCorrente_Cartao] FOREIGN KEY (IdContaCorrente) REFERENCES [dbo].[ContaCorrente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdSituacaoCartao_Cartao] FOREIGN KEY (IdSituacaoCartao) REFERENCES [dbo].[SituacaoCartao] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_Cartao_DiaVencimento] CHECK (DiaVencimento BETWEEN 1 AND 31),
        CONSTRAINT [CK_Cartao_DiaFechamento] CHECK (DiaFechamento IS NULL OR DiaFechamento BETWEEN 1 AND 31)
    );

    IF OBJECT_ID(N'[dbo].[Consorcio]', N'U') IS NULL
    CREATE TABLE [dbo].[Consorcio] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdContaCorrente INT NOT NULL,
        IdSituacaoConsorcio TINYINT NOT NULL,
        NumeroGrupo VARCHAR(20) NOT NULL,
        NumeroDeContrato VARCHAR(20) NOT NULL,
        DataInicio DATE NOT NULL,
        DataContemplacao DATE NULL,
        ValorCredito DECIMAL(10,2) NOT NULL,
        DataFim DATE NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_Consorcio_CriadoEm] DEFAULT SYSUTCDATETIME(),
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_Consorcio] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_Consorcio_NumeroDeContrato] UNIQUE (NumeroDeContrato),
        CONSTRAINT [FK_IdContaCorrente_Consorcio] FOREIGN KEY (IdContaCorrente) REFERENCES [dbo].[ContaCorrente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdSituacaoConsorcio_Consorcio] FOREIGN KEY (IdSituacaoConsorcio) REFERENCES [dbo].[SituacaoConsorcio] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_Consorcio_Periodo] CHECK (DataFim >= DataInicio),
        CONSTRAINT [CK_Consorcio_Contemplacao] CHECK (DataContemplacao IS NULL OR DataContemplacao >= DataInicio),
        CONSTRAINT [CK_Consorcio_ValorCredito] CHECK (ValorCredito >= 0)
    );

    IF OBJECT_ID(N'[dbo].[ContaChavePix]', N'U') IS NULL
    CREATE TABLE [dbo].[ContaChavePix] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdContaCorrente INT NOT NULL,
        IdTipoChavePix TINYINT NOT NULL,
        ChavePix VARCHAR(77) NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_ContaChavePix_CriadoEm] DEFAULT SYSUTCDATETIME(),
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_ContaChavePix] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_ContaChavePix_ChavePix] UNIQUE (ChavePix),
        CONSTRAINT [FK_IdContaCorrente_ContaChavePix] FOREIGN KEY (IdContaCorrente) REFERENCES [dbo].[ContaCorrente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdTipoChavePix_ContaChavePix] FOREIGN KEY (IdTipoChavePix) REFERENCES [dbo].[TipoChavePix] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION
    );

    IF OBJECT_ID(N'[dbo].[ContaDependente]', N'U') IS NULL
    CREATE TABLE [dbo].[ContaDependente] (
        IdDependente INT NOT NULL,
        IdContaCorrente INT NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_ContaDependente_CriadoEm] DEFAULT SYSUTCDATETIME(),

        CONSTRAINT [PK_ContaDependente] PRIMARY KEY CLUSTERED (IdDependente, IdContaCorrente),
        CONSTRAINT [FK_IdContaCorrente_ContaDependente] FOREIGN KEY (IdContaCorrente) REFERENCES [dbo].[ContaCorrente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdDependente_ContaDependente] FOREIGN KEY (IdDependente) REFERENCES [dbo].[Dependente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION
    );

    IF OBJECT_ID(N'[dbo].[Emprestimo]', N'U') IS NULL
    CREATE TABLE [dbo].[Emprestimo] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdContaCorrente INT NOT NULL,
        IdTipoEmprestimo TINYINT NOT NULL,
        IdSituacaoEmprestimo TINYINT NOT NULL,
        IdFormaDePagamento TINYINT NOT NULL,
        NumeroDeContrato VARCHAR(30) NOT NULL,
        Valor DECIMAL(10,2) NOT NULL,
        TaxaJuros DECIMAL(5,2) NOT NULL,
        QuantidadeParcelas INT NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_Emprestimo_CriadoEm] DEFAULT SYSUTCDATETIME(),
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_Emprestimo] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_Emprestimo_NumeroDeContrato] UNIQUE (NumeroDeContrato),
        CONSTRAINT [FK_IdContaCorrente_Emprestimo] FOREIGN KEY (IdContaCorrente) REFERENCES [dbo].[ContaCorrente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdTipoEmprestimo_Emprestimo] FOREIGN KEY (IdTipoEmprestimo) REFERENCES [dbo].[TipoEmprestimo] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdSituacaoEmprestimo_Emprestimo] FOREIGN KEY (IdSituacaoEmprestimo) REFERENCES [dbo].[SituacaoEmprestimo] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdFormaDePagamento_Emprestimo] FOREIGN KEY (IdFormaDePagamento) REFERENCES [dbo].[FormaDePagamentoEmprestimo] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_Emprestimo_Valor] CHECK (Valor >= 0),
        CONSTRAINT [CK_Emprestimo_QuantidadeParcelas] CHECK (QuantidadeParcelas >= 0),
        CONSTRAINT [CK_Emprestimo_TaxaJuros] CHECK (TaxaJuros BETWEEN 0 AND 100)
    );

    IF OBJECT_ID(N'[dbo].[Investimento]', N'U') IS NULL
    CREATE TABLE [dbo].[Investimento] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdContaCorrente INT NOT NULL,
        IdTipoInvestimento INT NOT NULL,
        IdSituacaoInvestimento INT NOT NULL,
        ValorInvestido DECIMAL(11,2) NOT NULL,
        ValorLiquido DECIMAL(10,2) NOT NULL,
        ValorBruto DECIMAL(10,2) NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_Investimento_CriadoEm] DEFAULT SYSUTCDATETIME(),
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_Investimento] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [FK_IdContaCorrente_Investimento] FOREIGN KEY (IdContaCorrente) REFERENCES [dbo].[ContaCorrente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdTipoInvestimento_Investimento] FOREIGN KEY (IdTipoInvestimento) REFERENCES [dbo].[TipoInvestimento] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdSituacaoInvestimento_Investimento] FOREIGN KEY (IdSituacaoInvestimento) REFERENCES [dbo].[TipoSituacaoInvestimento] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_Investimento_ValorInvestido] CHECK (ValorInvestido >= 0),
        CONSTRAINT [CK_Investimento_ValorLiquido] CHECK (ValorLiquido >= 0),
        CONSTRAINT [CK_Investimento_ValorBruto] CHECK (ValorBruto >= 0)
    );

    IF OBJECT_ID(N'[dbo].[LimiteConta]', N'U') IS NULL
    CREATE TABLE [dbo].[LimiteConta] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdContaCorrente INT NOT NULL,
        IdTipoLimite TINYINT NOT NULL,
        Valor DECIMAL(10,2) NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_LimiteConta_CriadoEm] DEFAULT SYSUTCDATETIME(),
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_LimiteConta] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [FK_IdContaCorrente_LimiteConta] FOREIGN KEY (IdContaCorrente) REFERENCES [dbo].[ContaCorrente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdTipoLimite_LimiteConta] FOREIGN KEY (IdTipoLimite) REFERENCES [dbo].[TipoLimite] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_LimiteConta_Valor] CHECK (Valor >= 0)
    );

    IF OBJECT_ID(N'[dbo].[LimiteDependente]', N'U') IS NULL
    CREATE TABLE [dbo].[LimiteDependente] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdTipoLimite TINYINT NOT NULL,
        IdDependente INT NOT NULL,
        IdContaCorrente INT NOT NULL,
        ValorMaximo DECIMAL(10,2) NOT NULL,
        ValorDisponivel DECIMAL(10,2) NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_LimiteDependente_CriadoEm] DEFAULT SYSUTCDATETIME(),
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_LimiteDependente] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [FK_IdTipoLimite_LimiteDependente] FOREIGN KEY (IdTipoLimite) REFERENCES [dbo].[TipoLimite] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdContaCorrente_LimiteDependente] FOREIGN KEY (IdContaCorrente) REFERENCES [dbo].[ContaCorrente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdDependente_LimiteDependente] FOREIGN KEY (IdDependente) REFERENCES [dbo].[Dependente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_LimiteDependente_ValorMaximo] CHECK (ValorMaximo >= 0),
        CONSTRAINT [CK_LimiteDependente_ValorDisponivel] CHECK (ValorDisponivel >= 0)
    );

    IF OBJECT_ID(N'[dbo].[Movimentacao]', N'U') IS NULL
    CREATE TABLE [dbo].[Movimentacao] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdContaCorrente INT NOT NULL,
        IdTipoMovimentacao TINYINT NOT NULL,
        Valor DECIMAL(10,2) NOT NULL,
        DataHora DATETIME NOT NULL,
        Descricao VARCHAR(200) NOT NULL,
        Destino VARCHAR(50) NOT NULL,
        Origem VARCHAR(50) NOT NULL,

        CONSTRAINT [PK_Movimentacao] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [FK_IdContaCorrente_Movimentacao] FOREIGN KEY (IdContaCorrente) REFERENCES [dbo].[ContaCorrente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdTipoMovimentacao_Movimentacao] FOREIGN KEY (IdTipoMovimentacao) REFERENCES [dbo].[TipoMovimentacao] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_Movimentacao_Valor] CHECK (Valor >= 0)
    );

    IF OBJECT_ID(N'[dbo].[ChequeEspecial]', N'U') IS NULL
    CREATE TABLE [dbo].[ChequeEspecial] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdContaCorrente INT NOT NULL,
        IdStatusChequeEspecial TINYINT NOT NULL,
        ValorLimite DECIMAL(10,2) NOT NULL,
        ValorUtilizado DECIMAL(15,2) NOT NULL DEFAULT (0),
        InicioVigencia DATE NOT NULL,
        FimVigencia DATE NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_ChequeEspecial_CriadoEm] DEFAULT SYSUTCDATETIME(),
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_ChequeEspecial] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [UQ_ChequeEspecial_IdContaCorrente] UNIQUE (IdContaCorrente),
        CONSTRAINT [CK_ChequeEspecial_ValorUtilizado] CHECK (ValorUtilizado >= 0),
        CONSTRAINT [FK_IdContaCorrente_ChequeEspecial] FOREIGN KEY (IdContaCorrente) REFERENCES [dbo].[ContaCorrente] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdStatusChequeEspecial_ChequeEspecial] FOREIGN KEY (IdStatusChequeEspecial) REFERENCES [dbo].[StatusChequeEspecial] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_ChequeEspecial_LimiteRespeitado] CHECK (ValorUtilizado <= ValorLimite),
        CONSTRAINT [CK_ChequeEspecial_Vigencia] CHECK (FimVigencia >= InicioVigencia),
        CONSTRAINT [CK_ChequeEspecial_ValorLimite] CHECK (ValorLimite >= 0)
    );

    IF OBJECT_ID(N'[dbo].[Fatura]', N'U') IS NULL
    CREATE TABLE [dbo].[Fatura] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdCartao INT NOT NULL,
        IdTipoPagamento INT NOT NULL,
        NumeroParcela INT NOT NULL,
        Valor DECIMAL(10,2) NOT NULL,
        DataVencimento DATE NOT NULL,
        DataPagamento DATE NULL,
        DataFechamento DATETIME NOT NULL,
        ValorPago DECIMAL(10,2) NULL,
        ValorMinimo DECIMAL(10,2) NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_Fatura_CriadoEm] DEFAULT SYSUTCDATETIME(),
        AlteradoPor VARCHAR(128) NULL,
        AlteradoEm DATETIME2 NULL,

        CONSTRAINT [PK_Fatura] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [FK_IdCartao_ParcelaCartao] FOREIGN KEY (IdCartao) REFERENCES [dbo].[Cartao] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdTipoPagamento_ParcelaCartao] FOREIGN KEY (IdTipoPagamento) REFERENCES [dbo].[TipoPagamento] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [UQ_Fatura_Cartao_Parcela] UNIQUE (IdCartao, NumeroParcela),
        CONSTRAINT [CK_Fatura_FechamentoVencimento] CHECK (DataVencimento >= CAST(DataFechamento AS DATE)),
        CONSTRAINT [CK_Fatura_Valor] CHECK (Valor >= 0),
        CONSTRAINT [CK_Fatura_ValorPago] CHECK (ValorPago IS NULL OR ValorPago >= 0),
        CONSTRAINT [CK_Fatura_ValorMinimo] CHECK (ValorMinimo IS NULL OR ValorMinimo >= 0)
    );

    IF OBJECT_ID(N'[dbo].[Lance]', N'U') IS NULL
    CREATE TABLE [dbo].[Lance] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdConsorcio INT NOT NULL,
        Valor DECIMAL(10,2) NOT NULL,
        Data DATE NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_Lance_CriadoEm] DEFAULT SYSUTCDATETIME(),

        CONSTRAINT [PK_Lance] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [FK_IdConsorcio_Lance] FOREIGN KEY (IdConsorcio) REFERENCES [dbo].[Consorcio] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_Lance_Valor] CHECK (Valor >= 0)
    );

    IF OBJECT_ID(N'[dbo].[ParcelaConsorcio]', N'U') IS NULL
    CREATE TABLE [dbo].[ParcelaConsorcio] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdConsorcio INT NOT NULL,
        IdTipoPagamento INT NULL,
        NumeroParcela SMALLINT NOT NULL,
        Valor DECIMAL(10,2) NOT NULL,
        DataVencimento DATE NOT NULL,
        DataPagamento DATE NULL,

        CONSTRAINT [PK_ParcelaConsorcio] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [FK_IdConsorcio_ParcelaConsorcio] FOREIGN KEY (IdConsorcio) REFERENCES [dbo].[Consorcio] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdTipoPagamento_ParcelaConsorcio] FOREIGN KEY (IdTipoPagamento) REFERENCES [dbo].[TipoPagamento] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_ParcelaConsorcio_Valor] CHECK (Valor >= 0)
    );

    IF OBJECT_ID(N'[dbo].[ParcelaEmprestimo]', N'U') IS NULL
    CREATE TABLE [dbo].[ParcelaEmprestimo] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdEmprestimo INT NOT NULL,
        NumeroParcela INT NOT NULL,
        Valor DECIMAL(10,2) NOT NULL,
        DataVencimento DATE NOT NULL,
        DataPagamento DATE NULL,
        IdTipoPagamento INT NULL,

        CONSTRAINT [PK_ParcelaEmprestimo] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [FK_IdEmprestimo_ParcelaEmprestimo] FOREIGN KEY (IdEmprestimo) REFERENCES [dbo].[Emprestimo] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdTipoPagamento_ParcelaEmprestimo] FOREIGN KEY (IdTipoPagamento) REFERENCES [dbo].[TipoPagamento] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_ParcelaEmprestimo_Valor] CHECK (Valor >= 0)
    );

    IF OBJECT_ID(N'[dbo].[TaxaChequeEspecial]', N'U') IS NULL
    CREATE TABLE [dbo].[TaxaChequeEspecial] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdChequeEspecial INT NOT NULL,
        IdTaxaChequeEspecial SMALLINT NOT NULL,
        IdFatura INT NOT NULL,
        DataReferencia DATETIME NOT NULL,
        Porcentagem DECIMAL(5,2) NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_TaxaChequeEspecial_CriadoEm] DEFAULT SYSUTCDATETIME(),

        CONSTRAINT [PK_TaxaChequeEspecial] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [FK_IdTipoTaxaChequeEspecial_TaxaChequeEspecial] FOREIGN KEY (IdTaxaChequeEspecial) REFERENCES [dbo].[TipoTaxaChequeEspecial] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdChequeEspecial_TaxaChequeEspecial] FOREIGN KEY (IdChequeEspecial) REFERENCES [dbo].[ChequeEspecial] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdFatura_TaxaChequeEspecial] FOREIGN KEY (IdFatura) REFERENCES [dbo].[Fatura] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_TaxaChequeEspecial_Porcentagem] CHECK (Porcentagem BETWEEN 0 AND 100)
    );

    IF OBJECT_ID(N'[dbo].[Parcela]', N'U') IS NULL
    CREATE TABLE [dbo].[Parcela] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdCompra INT NOT NULL,
        IdFatura INT NOT NULL,
        NumeroParcela INT NOT NULL,
        Valor DECIMAL(10,2) NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_Parcela_CriadoEm] DEFAULT SYSUTCDATETIME(),

        CONSTRAINT [PK_Parcela] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [FK_IdFatura_Parcela] FOREIGN KEY (IdFatura) REFERENCES [dbo].[Fatura] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdCompra_Parcela] FOREIGN KEY (IdCompra) REFERENCES [dbo].[Compra] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_Parcela_Valor] CHECK (Valor >= 0)
    );

    IF OBJECT_ID(N'[dbo].[TaxaFatura]', N'U') IS NULL
    CREATE TABLE [dbo].[TaxaFatura] (
        Id INT IDENTITY(1,1) NOT NULL,
        IdTaxa INT NOT NULL,
        IdFatura INT NOT NULL,
        Porcentagem DECIMAL(5,2) NOT NULL,

        -- auditoria
        CriadoPor VARCHAR(128) NOT NULL,
        CriadoEm DATETIME2 NOT NULL CONSTRAINT [DF_TaxaFatura_CriadoEm] DEFAULT SYSUTCDATETIME(),

        CONSTRAINT [PK_TaxaFatura] PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT [FK_IdTaxa_TaxaFatura] FOREIGN KEY (IdTaxa) REFERENCES [dbo].[Taxa] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [FK_IdFatura_TaxaFatura] FOREIGN KEY (IdFatura) REFERENCES [dbo].[Fatura] (Id) ON DELETE NO ACTION ON UPDATE NO ACTION,
        CONSTRAINT [CK_TaxaFatura_Porcentagem] CHECK (Porcentagem BETWEEN 0 AND 100)
    );

    -- =====================================================================
    -- M5: indices nas colunas de FK (SQL Server nao cria automaticamente)
    -- =====================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContaCorrente_IdAgencia' AND object_id = OBJECT_ID(N'[dbo].[ContaCorrente]'))
        CREATE NONCLUSTERED INDEX [IX_ContaCorrente_IdAgencia] ON [dbo].[ContaCorrente] (IdAgencia);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContaCorrente_IdSituacaoConta' AND object_id = OBJECT_ID(N'[dbo].[ContaCorrente]'))
        CREATE NONCLUSTERED INDEX [IX_ContaCorrente_IdSituacaoConta] ON [dbo].[ContaCorrente] (IdSituacaoConta);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContaCorrente_IdCliente' AND object_id = OBJECT_ID(N'[dbo].[ContaCorrente]'))
        CREATE NONCLUSTERED INDEX [IX_ContaCorrente_IdCliente] ON [dbo].[ContaCorrente] (IdCliente);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContaCorrente_IdSaldo' AND object_id = OBJECT_ID(N'[dbo].[ContaCorrente]'))
        CREATE NONCLUSTERED INDEX [IX_ContaCorrente_IdSaldo] ON [dbo].[ContaCorrente] (IdSaldo);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContaPoupanca_IdTaxaRendimento' AND object_id = OBJECT_ID(N'[dbo].[ContaPoupanca]'))
        CREATE NONCLUSTERED INDEX [IX_ContaPoupanca_IdTaxaRendimento] ON [dbo].[ContaPoupanca] (IdTaxaRendimento);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContaPoupanca_IdSituacaoConta' AND object_id = OBJECT_ID(N'[dbo].[ContaPoupanca]'))
        CREATE NONCLUSTERED INDEX [IX_ContaPoupanca_IdSituacaoConta] ON [dbo].[ContaPoupanca] (IdSituacaoConta);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContaPoupanca_IdCliente' AND object_id = OBJECT_ID(N'[dbo].[ContaPoupanca]'))
        CREATE NONCLUSTERED INDEX [IX_ContaPoupanca_IdCliente] ON [dbo].[ContaPoupanca] (IdCliente);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContaPoupanca_IdSaldo' AND object_id = OBJECT_ID(N'[dbo].[ContaPoupanca]'))
        CREATE NONCLUSTERED INDEX [IX_ContaPoupanca_IdSaldo] ON [dbo].[ContaPoupanca] (IdSaldo);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContaPoupanca_IdAgencia' AND object_id = OBJECT_ID(N'[dbo].[ContaPoupanca]'))
        CREATE NONCLUSTERED INDEX [IX_ContaPoupanca_IdAgencia] ON [dbo].[ContaPoupanca] (IdAgencia);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Cartao_IdContaCorrente' AND object_id = OBJECT_ID(N'[dbo].[Cartao]'))
        CREATE NONCLUSTERED INDEX [IX_Cartao_IdContaCorrente] ON [dbo].[Cartao] (IdContaCorrente);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Cartao_IdSituacaoCartao' AND object_id = OBJECT_ID(N'[dbo].[Cartao]'))
        CREATE NONCLUSTERED INDEX [IX_Cartao_IdSituacaoCartao] ON [dbo].[Cartao] (IdSituacaoCartao);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Consorcio_IdContaCorrente' AND object_id = OBJECT_ID(N'[dbo].[Consorcio]'))
        CREATE NONCLUSTERED INDEX [IX_Consorcio_IdContaCorrente] ON [dbo].[Consorcio] (IdContaCorrente);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Consorcio_IdSituacaoConsorcio' AND object_id = OBJECT_ID(N'[dbo].[Consorcio]'))
        CREATE NONCLUSTERED INDEX [IX_Consorcio_IdSituacaoConsorcio] ON [dbo].[Consorcio] (IdSituacaoConsorcio);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContaChavePix_IdContaCorrente' AND object_id = OBJECT_ID(N'[dbo].[ContaChavePix]'))
        CREATE NONCLUSTERED INDEX [IX_ContaChavePix_IdContaCorrente] ON [dbo].[ContaChavePix] (IdContaCorrente);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContaChavePix_IdTipoChavePix' AND object_id = OBJECT_ID(N'[dbo].[ContaChavePix]'))
        CREATE NONCLUSTERED INDEX [IX_ContaChavePix_IdTipoChavePix] ON [dbo].[ContaChavePix] (IdTipoChavePix);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ContaDependente_IdContaCorrente' AND object_id = OBJECT_ID(N'[dbo].[ContaDependente]'))
        CREATE NONCLUSTERED INDEX [IX_ContaDependente_IdContaCorrente] ON [dbo].[ContaDependente] (IdContaCorrente);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Emprestimo_IdContaCorrente' AND object_id = OBJECT_ID(N'[dbo].[Emprestimo]'))
        CREATE NONCLUSTERED INDEX [IX_Emprestimo_IdContaCorrente] ON [dbo].[Emprestimo] (IdContaCorrente);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Emprestimo_IdTipoEmprestimo' AND object_id = OBJECT_ID(N'[dbo].[Emprestimo]'))
        CREATE NONCLUSTERED INDEX [IX_Emprestimo_IdTipoEmprestimo] ON [dbo].[Emprestimo] (IdTipoEmprestimo);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Emprestimo_IdSituacaoEmprestimo' AND object_id = OBJECT_ID(N'[dbo].[Emprestimo]'))
        CREATE NONCLUSTERED INDEX [IX_Emprestimo_IdSituacaoEmprestimo] ON [dbo].[Emprestimo] (IdSituacaoEmprestimo);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Emprestimo_IdFormaDePagamento' AND object_id = OBJECT_ID(N'[dbo].[Emprestimo]'))
        CREATE NONCLUSTERED INDEX [IX_Emprestimo_IdFormaDePagamento] ON [dbo].[Emprestimo] (IdFormaDePagamento);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Investimento_IdContaCorrente' AND object_id = OBJECT_ID(N'[dbo].[Investimento]'))
        CREATE NONCLUSTERED INDEX [IX_Investimento_IdContaCorrente] ON [dbo].[Investimento] (IdContaCorrente);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Investimento_IdTipoInvestimento' AND object_id = OBJECT_ID(N'[dbo].[Investimento]'))
        CREATE NONCLUSTERED INDEX [IX_Investimento_IdTipoInvestimento] ON [dbo].[Investimento] (IdTipoInvestimento);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Investimento_IdSituacaoInvestimento' AND object_id = OBJECT_ID(N'[dbo].[Investimento]'))
        CREATE NONCLUSTERED INDEX [IX_Investimento_IdSituacaoInvestimento] ON [dbo].[Investimento] (IdSituacaoInvestimento);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_LimiteConta_IdContaCorrente' AND object_id = OBJECT_ID(N'[dbo].[LimiteConta]'))
        CREATE NONCLUSTERED INDEX [IX_LimiteConta_IdContaCorrente] ON [dbo].[LimiteConta] (IdContaCorrente);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_LimiteConta_IdTipoLimite' AND object_id = OBJECT_ID(N'[dbo].[LimiteConta]'))
        CREATE NONCLUSTERED INDEX [IX_LimiteConta_IdTipoLimite] ON [dbo].[LimiteConta] (IdTipoLimite);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_LimiteDependente_IdTipoLimite' AND object_id = OBJECT_ID(N'[dbo].[LimiteDependente]'))
        CREATE NONCLUSTERED INDEX [IX_LimiteDependente_IdTipoLimite] ON [dbo].[LimiteDependente] (IdTipoLimite);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_LimiteDependente_IdContaCorrente' AND object_id = OBJECT_ID(N'[dbo].[LimiteDependente]'))
        CREATE NONCLUSTERED INDEX [IX_LimiteDependente_IdContaCorrente] ON [dbo].[LimiteDependente] (IdContaCorrente);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_LimiteDependente_IdDependente' AND object_id = OBJECT_ID(N'[dbo].[LimiteDependente]'))
        CREATE NONCLUSTERED INDEX [IX_LimiteDependente_IdDependente] ON [dbo].[LimiteDependente] (IdDependente);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Movimentacao_IdContaCorrente' AND object_id = OBJECT_ID(N'[dbo].[Movimentacao]'))
        CREATE NONCLUSTERED INDEX [IX_Movimentacao_IdContaCorrente] ON [dbo].[Movimentacao] (IdContaCorrente);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Movimentacao_IdTipoMovimentacao' AND object_id = OBJECT_ID(N'[dbo].[Movimentacao]'))
        CREATE NONCLUSTERED INDEX [IX_Movimentacao_IdTipoMovimentacao] ON [dbo].[Movimentacao] (IdTipoMovimentacao);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ChequeEspecial_IdStatusChequeEspecial' AND object_id = OBJECT_ID(N'[dbo].[ChequeEspecial]'))
        CREATE NONCLUSTERED INDEX [IX_ChequeEspecial_IdStatusChequeEspecial] ON [dbo].[ChequeEspecial] (IdStatusChequeEspecial);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Fatura_IdCartao' AND object_id = OBJECT_ID(N'[dbo].[Fatura]'))
        CREATE NONCLUSTERED INDEX [IX_Fatura_IdCartao] ON [dbo].[Fatura] (IdCartao);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Fatura_IdTipoPagamento' AND object_id = OBJECT_ID(N'[dbo].[Fatura]'))
        CREATE NONCLUSTERED INDEX [IX_Fatura_IdTipoPagamento] ON [dbo].[Fatura] (IdTipoPagamento);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Lance_IdConsorcio' AND object_id = OBJECT_ID(N'[dbo].[Lance]'))
        CREATE NONCLUSTERED INDEX [IX_Lance_IdConsorcio] ON [dbo].[Lance] (IdConsorcio);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ParcelaConsorcio_IdConsorcio' AND object_id = OBJECT_ID(N'[dbo].[ParcelaConsorcio]'))
        CREATE NONCLUSTERED INDEX [IX_ParcelaConsorcio_IdConsorcio] ON [dbo].[ParcelaConsorcio] (IdConsorcio);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ParcelaConsorcio_IdTipoPagamento' AND object_id = OBJECT_ID(N'[dbo].[ParcelaConsorcio]'))
        CREATE NONCLUSTERED INDEX [IX_ParcelaConsorcio_IdTipoPagamento] ON [dbo].[ParcelaConsorcio] (IdTipoPagamento);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ParcelaEmprestimo_IdEmprestimo' AND object_id = OBJECT_ID(N'[dbo].[ParcelaEmprestimo]'))
        CREATE NONCLUSTERED INDEX [IX_ParcelaEmprestimo_IdEmprestimo] ON [dbo].[ParcelaEmprestimo] (IdEmprestimo);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ParcelaEmprestimo_IdTipoPagamento' AND object_id = OBJECT_ID(N'[dbo].[ParcelaEmprestimo]'))
        CREATE NONCLUSTERED INDEX [IX_ParcelaEmprestimo_IdTipoPagamento] ON [dbo].[ParcelaEmprestimo] (IdTipoPagamento);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_TaxaChequeEspecial_IdTaxaChequeEspecial' AND object_id = OBJECT_ID(N'[dbo].[TaxaChequeEspecial]'))
        CREATE NONCLUSTERED INDEX [IX_TaxaChequeEspecial_IdTaxaChequeEspecial] ON [dbo].[TaxaChequeEspecial] (IdTaxaChequeEspecial);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_TaxaChequeEspecial_IdChequeEspecial' AND object_id = OBJECT_ID(N'[dbo].[TaxaChequeEspecial]'))
        CREATE NONCLUSTERED INDEX [IX_TaxaChequeEspecial_IdChequeEspecial] ON [dbo].[TaxaChequeEspecial] (IdChequeEspecial);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_TaxaChequeEspecial_IdFatura' AND object_id = OBJECT_ID(N'[dbo].[TaxaChequeEspecial]'))
        CREATE NONCLUSTERED INDEX [IX_TaxaChequeEspecial_IdFatura] ON [dbo].[TaxaChequeEspecial] (IdFatura);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Parcela_IdFatura' AND object_id = OBJECT_ID(N'[dbo].[Parcela]'))
        CREATE NONCLUSTERED INDEX [IX_Parcela_IdFatura] ON [dbo].[Parcela] (IdFatura);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Parcela_IdCompra' AND object_id = OBJECT_ID(N'[dbo].[Parcela]'))
        CREATE NONCLUSTERED INDEX [IX_Parcela_IdCompra] ON [dbo].[Parcela] (IdCompra);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_TaxaFatura_IdTaxa' AND object_id = OBJECT_ID(N'[dbo].[TaxaFatura]'))
        CREATE NONCLUSTERED INDEX [IX_TaxaFatura_IdTaxa] ON [dbo].[TaxaFatura] (IdTaxa);
    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_TaxaFatura_IdFatura' AND object_id = OBJECT_ID(N'[dbo].[TaxaFatura]'))
        CREATE NONCLUSTERED INDEX [IX_TaxaFatura_IdFatura] ON [dbo].[TaxaFatura] (IdFatura);

    COMMIT TRANSACTION;
    PRINT 'Banco de dados criado com sucesso.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Erro ao criar o banco de dados. Rollback executado.';
    THROW;
END CATCH
GO
