CREATE TABLE ReservaHistorico (
	Id INT IDENTITY,
	IdReserva INT NOT NULL,
	SituacaoAnterior VARCHAR(20) NOT NULL,
	SituacaoNova VARCHAR(20) NOT NULL,
	AlteradoPor VARCHAR(255) NOT NULL,
	AlteradoEm DATETIME NOT NULL
	
	CONSTRAINT PK_IdReservaHistorico PRIMARY KEY (Id),
	CONSTRAINT FK_IdReserva_ReservaHistorico FOREIGN KEY (IdReserva) REFERENCES Reserva (Id)
)
GO
