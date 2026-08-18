USE WoodCraftPratica;
GO

CREATE TABLE v(
	Id INT IDENTITY,
	IdCliente INT NOT NULL,
	NomeAnterior VARCHAR(100) NOT NULL,
	NomeNovo VARCHAR(100) NOT NULL,
	DocumentoAnterior VARCHAR(14) NOT NULL,
	DocumentoNovo VARCHAR(14) NOT NULL,
	TelefoneAnterior VARCHAR(11) NOT NULL,
	TelefoneNovo VARCHAR(11) NOT NULL,
	TipoClienteAntigo BIT NOT NULL,
	TipoClienteNovo BIT NOT NULL,
	AlteradorPor VARCHAR(254) NOT NULL,
	AlteradoEm DATETIME NOT NULL

	CONSTRAINT PK_IdAuditoriaAlteracaoCliente PRIMARY KEY (Id)
)
GO
