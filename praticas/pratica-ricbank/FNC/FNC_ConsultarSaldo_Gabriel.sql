USE RicBankTeste;
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_ConsultarSaldo_Gabriel] (@IdConta INT, @DataConsulta DATE)
	RETURNS DECIMAL (10,2)
	AS
	/*
		Documentacao
		Arquivo Fonte............: FNC_ConsultarSaldo_Gabriel.sql
		Obejtivo.................: Retornar o Saldo atual da conta caculando o SaldoInicial, MovimentacaoCredito e MovimentacaoDebito
		Autor....................: Gabriel Felix
		Data.....................: 21/08/2026
		Ex.......................: DBCC FREEPROCCACHE
								   DBCC DROPCLEANBUFFERS

								   DECLARE @DataInicio DATETIME = GETDATE();

								   SELECT  [dbo].[FNC_ConsultarSaldo_Gabriel] (1, '2024-01-05') As SaldoEmConta;

								   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;
	*/
	BEGIN

		RETURN (SELECT  SaldoInicial + MovimentacaoCredito - MovimentacaoDebito
					FROM [dbo].[Saldo] WITH(NOLOCK)
					WHERE IdConta = @IdConta 
						AND DataSaldo = @DataConsulta)
	END
GO
