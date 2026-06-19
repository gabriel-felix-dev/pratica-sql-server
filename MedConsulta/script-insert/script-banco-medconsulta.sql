CREATE DATABASE MedConsulta;
GO

USE MedConsulta;
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

CREATE TABLE Paciente (
    Id INT IDENTITY(1,1),
    IdEndereco INT NULL,
    Nome VARCHAR(150) NOT NULL,
    Documento VARCHAR(20) NOT NULL,
    Telefone VARCHAR(20) NULL,
    TipoPlano VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Paciente PRIMARY KEY (Id),
    CONSTRAINT FK_IdEndereco_Paciente FOREIGN KEY (IdEndereco) REFERENCES Endereco(Id),
    CONSTRAINT UQ_Paciente_Documento UNIQUE (Documento)
);

CREATE TABLE Clinica (
    Id TINYINT IDENTITY(1,1),
    IdEndereco INT NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    CNPJ VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Clinica PRIMARY KEY (Id),
    CONSTRAINT FK_IdEndereco_Clinica FOREIGN KEY (IdEndereco) REFERENCES Endereco(Id),
    CONSTRAINT UQ_Clinica_CNPJ UNIQUE (CNPJ)
);

CREATE TABLE Especialidade (
    Id TINYINT IDENTITY(1,1),
    Nome VARCHAR(50) NOT NULL,
    CONSTRAINT PK_Especialidade PRIMARY KEY (Id)
);

CREATE TABLE Medico (
    Id INT IDENTITY(1,1),
    IdEspecialidade TINYINT NOT NULL,
    IdClinica TINYINT NOT NULL,
    Nome VARCHAR(150) NOT NULL,
    CRM VARCHAR(20) NOT NULL,
    Telefone VARCHAR(20) NULL,
    CONSTRAINT PK_Medico PRIMARY KEY (Id),
    CONSTRAINT FK_IdEspecialidade_Medico FOREIGN KEY (IdEspecialidade) REFERENCES Especialidade(Id),
    CONSTRAINT FK_IdClinica_Medico FOREIGN KEY (IdClinica) REFERENCES Clinica(Id),
    CONSTRAINT UQ_Medico_CRM UNIQUE (CRM)
);

CREATE TABLE TipoAtendimento (
    Id TINYINT IDENTITY(1,1),
    Nome VARCHAR(50) NOT NULL,
    CONSTRAINT PK_TipoAtendimento PRIMARY KEY (Id)
);

CREATE TABLE StatusConsulta (
    Id TINYINT IDENTITY(1,1),
    Nome VARCHAR(50) NOT NULL,
    CONSTRAINT PK_StatusConsulta PRIMARY KEY (Id)
);

CREATE TABLE Consulta (
    Id INT IDENTITY(1,1),
    IdPaciente INT NOT NULL,
    IdMedico INT NOT NULL,
    IdTipoAtendimento TINYINT NOT NULL,
    IdStatusConsulta TINYINT NOT NULL,
    Codigo VARCHAR(50) NOT NULL,
    DataHora DATETIME NOT NULL,
    ValorBase DECIMAL(10,2) NOT NULL,
    TaxaConsultorio DECIMAL(10,2) NULL,
    TaxaPlataforma DECIMAL(10,2) NULL,
    PlataformaTelemedicina VARCHAR(100) NULL,
    TaxaInsumos DECIMAL(10,2) NULL,
    TaxaAnestesia DECIMAL(10,2) NULL,
    CodigoAutorizacao VARCHAR(50) NULL,
    CONSTRAINT PK_Consulta PRIMARY KEY (Id),
    CONSTRAINT FK_IdPaciente_Consulta FOREIGN KEY (IdPaciente) REFERENCES Paciente(Id),
    CONSTRAINT FK_IdMedico_Consulta FOREIGN KEY (IdMedico) REFERENCES Medico(Id),
    CONSTRAINT FK_IdTipoAtendimento_Consulta FOREIGN KEY (IdTipoAtendimento) REFERENCES TipoAtendimento(Id),
    CONSTRAINT FK_IdStatusConsulta_Consulta FOREIGN KEY (IdStatusConsulta) REFERENCES StatusConsulta(Id),
    CONSTRAINT UQ_Consulta_Codigo UNIQUE (Codigo)
);

INSERT INTO TipoAtendimento (Nome) VALUES ('Presencial'), ('Telemedicina'), ('ProcedimentoComplexo');
INSERT INTO StatusConsulta (Nome) VALUES ('Pendente'), ('Confirmada'), ('Realizada'), ('Cancelada');
