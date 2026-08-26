USE RicBankTeste
GO

CREATE OR ALTER VIEW [dbo].[VW_RetornaSaldoIncialExtrato_GabrielFelix]
AS

	SELECT  IdConta,
			DataSaldo,
			'Saldo Inicial' As Movimentacao,
			NULL As TipoMovimentacao,
			SaldoInicial + MovimentacaoCredito - MovimentacaoDebito As Valor
		FROM [dbo].[Saldo] WITH(NOLOCK)
GO