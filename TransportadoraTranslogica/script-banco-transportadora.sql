
CREATE DATABASE TransportadoraTransLogica;
GO

USE TransportadoraTransLogica;
GO

CREATE TABLE Estado (
    Id TINYINT IDENTITY(1,1),
    Nome VARCHAR(100) NOT NULL,
    UF CHAR(2) NOT NULL,
    CONSTRAINT PK_Estado PRIMARY KEY (Id)
);

CREATE TABLE Cidade (
    Id INT IDENTITY(1,1),
    IdEstado TINYINT NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Cidade PRIMARY KEY (Id),
    CONSTRAINT FK_IdEstado_Cidade FOREIGN KEY (IdEstado) REFERENCES Estado(Id)
);

CREATE TABLE Endereco (
    Id INT IDENTITY(1,1),
    IdCidade INT NOT NULL,
    Logradouro VARCHAR(255) NOT NULL,
    Numero VARCHAR(20) NULL,
    Bairro VARCHAR(100) NULL,
    CEP VARCHAR(15) NULL,
    CONSTRAINT PK_Endereco PRIMARY KEY (Id),
    CONSTRAINT FK_IdCidade_Endereco FOREIGN KEY (IdCidade) REFERENCES Cidade(Id)
);

CREATE TABLE Cliente (
    Id INT IDENTITY(1,1),
    IdEndereco INT NULL,
    Nome VARCHAR(150) NOT NULL,
    Documento VARCHAR(20) NOT NULL,
    Telefone VARCHAR(20) NULL,
    CONSTRAINT PK_Cliente PRIMARY KEY (Id),
    CONSTRAINT FK_IdEndereco_Cliente FOREIGN KEY (IdEndereco) REFERENCES Endereco(Id),
    CONSTRAINT UQ_Cliente_Documento UNIQUE (Documento)
);

CREATE TABLE Filial (
    Id TINYINT IDENTITY(1,1),
    IdEndereco INT NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Filial PRIMARY KEY (Id),
    CONSTRAINT FK_IdEndereco_Filial FOREIGN KEY (IdEndereco) REFERENCES Endereco(Id)
);

CREATE TABLE Motorista (
    Id INT IDENTITY(1,1),
    Nome VARCHAR(150) NOT NULL,
    CNH VARCHAR(20) NOT NULL,
    Telefone VARCHAR(20) NULL,
    CONSTRAINT PK_Motorista PRIMARY KEY (Id),
    CONSTRAINT UQ_Motorista_CNH UNIQUE (CNH)
);

CREATE TABLE Veiculo (
    Id INT IDENTITY(1,1),
    Placa CHAR(7) NOT NULL,
    Modelo VARCHAR(100) NOT NULL,
    CapacidadePeso DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_Veiculo PRIMARY KEY (Id),
    CONSTRAINT UQ_Veiculo_Placa UNIQUE (Placa)
);

CREATE TABLE Viagem (
    Id INT IDENTITY(1,1),
    IdVeiculo INT NOT NULL,
    IdMotorista INT NOT NULL,
    IdFilialOrigem TINYINT NOT NULL,
    DataSaida DATETIME NOT NULL,
    DataChegada DATETIME NULL,
    QuilometragemInicial INT NOT NULL,
    QuilometragemFinal INT NULL,
    CONSTRAINT PK_Viagem PRIMARY KEY (Id),
    CONSTRAINT FK_IdVeiculo_Viagem FOREIGN KEY (IdVeiculo) REFERENCES Veiculo(Id),
    CONSTRAINT FK_IdMotorista_Viagem FOREIGN KEY (IdMotorista) REFERENCES Motorista(Id),
    CONSTRAINT FK_IdFilialOrigem_Viagem FOREIGN KEY (IdFilialOrigem) REFERENCES Filial(Id)
);

CREATE TABLE ParadaViagem (
    Id INT IDENTITY(1,1),
    IdViagem INT NOT NULL,
    IdCidade INT NOT NULL,
    OrdemParada TINYINT NOT NULL,
    QuilometragemParcial INT NOT NULL,
    DataChegadaParada DATETIME NULL,
    CONSTRAINT PK_ParadaViagem PRIMARY KEY (Id),
    CONSTRAINT FK_IdViagem_ParadaViagem FOREIGN KEY (IdViagem) REFERENCES Viagem(Id),
    CONSTRAINT FK_IdCidade_ParadaViagem FOREIGN KEY (IdCidade) REFERENCES Cidade(Id),
    CONSTRAINT UQ_ParadaViagem_ViagemOrdem UNIQUE (IdViagem, OrdemParada)
);

CREATE TABLE TipoCarga (
    Id TINYINT IDENTITY(1,1),
    Nome VARCHAR(50) NOT NULL,
    CONSTRAINT PK_TipoCarga PRIMARY KEY (Id)
);

CREATE TABLE StatusEnvio (
    Id TINYINT IDENTITY(1,1),
    Nome VARCHAR(50) NOT NULL,
    CONSTRAINT PK_StatusEnvio PRIMARY KEY (Id)
);

CREATE TABLE Carga (
    Id INT IDENTITY(1,1),
    IdCliente INT NOT NULL,
    IdTipoCarga TINYINT NOT NULL,
    IdStatusEnvio TINYINT NOT NULL,
    IdParadaEntrega INT NULL,
    IdEnderecoEntrega INT NULL,
    Codigo VARCHAR(50) NOT NULL,
    Peso DECIMAL(10,2) NOT NULL,
    ValorDeclarado DECIMAL(12,2) NOT NULL,
    MaterialEmbalagem VARCHAR(100) NULL,
    ClasseRisco VARCHAR(50) NULL,
    NumeroONU INT NULL,
    CONSTRAINT PK_Carga PRIMARY KEY (Id),
    CONSTRAINT FK_IdCliente_Carga FOREIGN KEY (IdCliente) REFERENCES Cliente(Id),
    CONSTRAINT FK_IdTipoCarga_Carga FOREIGN KEY (IdTipoCarga) REFERENCES TipoCarga(Id),
    CONSTRAINT FK_IdStatusEnvio_Carga FOREIGN KEY (IdStatusEnvio) REFERENCES StatusEnvio(Id),
    CONSTRAINT FK_IdParadaEntrega_Carga FOREIGN KEY (IdParadaEntrega) REFERENCES ParadaViagem(Id),
    CONSTRAINT FK_IdEnderecoEntrega_Carga FOREIGN KEY (IdEnderecoEntrega) REFERENCES Endereco(Id),
    CONSTRAINT UQ_Carga_Codigo UNIQUE (Codigo)
);

INSERT INTO TipoCarga (Nome) VALUES ('Padrao'), ('Fragil'), ('Perigosa');
INSERT INTO StatusEnvio (Nome) VALUES ('Pendente'), ('Em Transito'), ('Entregue'), ('Cancelado');
