USE RicBankTeste
GO

CREATE OR ALTER VIEW [dbo].[VW_RetornaSaldoExtrato_GabrielFelix]
/*
	Documentacao
	Arquivo Fonte............: VW_RetornaSaldoExtrato_GabrielFelix.sql
	Objetivo.................: Retornar uma tabela com todos os saldos somados
	Autor....................: Gabriel Felix
	Data.....................: 26/08/2025
	Ex.......................: DBCC FREEPROCCACHE
	                           DBCC DROPCLEANBUFFERS

							   DECLARE @DataInicio DATETIME = GETDATE();

							   SELECT  TOP 10 * 
								   FROM [dbo].[VW_RetornaSaldoExtrato_GabrielFelix];

							   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao
*/		
AS	
	SELECT  IdConta,
			DataSaldo,
			'Saldo Inicial' As Movimentacao,
			'' As TipoMovimentacao,
			SaldoInicial + MovimentacaoCredito - MovimentacaoDebito As Valor
		FROM [dbo].[Saldo] WITH(NOLOCK)
GO