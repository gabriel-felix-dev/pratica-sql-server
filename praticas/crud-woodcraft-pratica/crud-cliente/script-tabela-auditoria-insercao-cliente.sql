USE WoodCraftPratica;
GO

CREATE TABLE AuditoriaCliente(
	Id INT IDENTITY,
	IdCliente INT NOT NULL,
	NomeCliente VARCHAR(100) NOT NULL,
	TipoOperacaoRealizada VARCHAR(100) NOT NULL,
	OperacaoRealizadaPor VARCHAR(254) NOT NULL,
	DataOperacao DATETIME NOT NULL

	CONSTRAINT PK_IdAuditoriaCliente PRIMARY KEY (Id)
)
GO
