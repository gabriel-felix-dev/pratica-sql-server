-- =========================================================================
-- Script de Criação do Banco de Dados Hotel
-- Objetivo: DDL completo das tabelas do Sistema de Gestão de Hospedagem e Controle de Ocupação
-- =========================================================================

CREATE DATABASE hotel_avaliacao;
GO

USE hotel_avaliacao;
GO

-- 1. Tabela de Hóspedes
CREATE TABLE [dbo].[Hospede] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nome VARCHAR(120) NOT NULL,
    Cpf VARCHAR(14) NOT NULL UNIQUE,
    Email VARCHAR(150) NULL,
    Telefone VARCHAR(20) NULL,
    DataNascimento DATE NULL
);
GO

-- 2. Tabela de Quartos
CREATE TABLE [dbo].[Quarto] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Numero VARCHAR(10) NOT NULL UNIQUE,
    Tipo VARCHAR(30) NOT NULL,
    Capacidade INT NOT NULL,
    ValorDiaria DECIMAL(10,2) NOT NULL,
    Ativo BIT NOT NULL DEFAULT 1,
    CONSTRAINT ck_Quarto_Capacidade CHECK (Capacidade > 0),
    CONSTRAINT ck_Quarto_ValorDiaria CHECK (ValorDiaria > 0)
);
GO

-- 3. Tabela de Reservas
CREATE TABLE [dbo].[Reserva] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdHospede INT NOT NULL,
    IdQuarto INT NOT NULL,
    DataReserva DATETIME NOT NULL DEFAULT GETDATE(),
    DataEntrada DATE NOT NULL,
    DataSaida DATE NOT NULL,
    Situacao VARCHAR(20) NOT NULL DEFAULT 'RESERVADA',
    CONSTRAINT fk_IdHospede_Reserva FOREIGN KEY (IdHospede) REFERENCES [dbo].[Hospede] (Id),
    CONSTRAINT fk_IdQuarto_Reserva FOREIGN KEY (IdQuarto) REFERENCES [dbo].[Quarto] (Id),
    CONSTRAINT ck_Reserva_Periodo CHECK (DataSaida > DataEntrada),
    CONSTRAINT ck_Reserva_Situacao CHECK (Situacao IN ('RESERVADA', 'CANCELADA', 'CHECKIN', 'CHECKOUT'))
);
GO

-- 4. Tabela de Hospedagens
CREATE TABLE [dbo].[Hospedagem] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdReserva INT NOT NULL UNIQUE,
    DataCheckin DATETIME NOT NULL,
    DataCheckout DATETIME NULL,
    Observacao VARCHAR(255) NULL,
    CONSTRAINT fk_IdReserva_Hospedagem FOREIGN KEY (IdReserva) REFERENCES [dbo].[Reserva] (Id),
    CONSTRAINT ck_Hospedagem_Checkout CHECK (DataCheckout IS NULL OR DataCheckout >= DataCheckin)
);
GO
