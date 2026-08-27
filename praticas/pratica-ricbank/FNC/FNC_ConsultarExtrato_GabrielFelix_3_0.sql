USE RicBankTeste;
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_ConsultarExtrato_GabrielFelix_3_0] (@IdConta TINYINT, @MesExtrato TINYINT, @AnoExtrato SMALLINT)
	RETURNS TABLE
	AS
	/*
		Documentacao
		Arquivo Fonte............: FNC_ConsultarExtrato_GabrielFelix_3_0.sql
		Objetivo.................: Retornar o extrato de uma conta com o saldo inicial e saldo final.
		Autor....................: Gabriel Felix
		Data.....................: 27/08/2026
		Ex.......................: DBCC FREEPROCCACHE
								   DBCC DROPCLEANBUFFERS

								   DECLARE @DataInicio DATETIME = GETDATE();

		                           SELECT * FROM [dbo].[FNC_ConsultarExtrato_GabrielFelix_3_0] (14, 08, 2026);

								   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;
	*/
	RETURN (
			 WITH ConsultarExtrato AS (
										-- Acessa a View: VW_RetornaSaldoIncialExtrato_GabrielFelix - e retorna o ultimo dia com saldo do mes anterior ao informado no parametro da Function
										SELECT  TOP 1 *
											FROM [dbo].[VW_RetornaSaldoExtrato_GabrielFelix] as vw WITH(NOLOCK)
											WHERE IdConta = @IdConta
											AND DataSaldo 
												-- Retorna o primeiro dia/mes/ano com base no parametro @MesExtrato e @AnoExtrato
												BETWEEN DATEADD( MONTH, -1,DATEFROMPARTS(@AnoExtrato, @MesExtrato, 1)) 
												-- Retorna o ultimo dia/mes/ano com base no parametro @MesExtrato e @AnoExtrato
												AND EOMONTH(DATEADD( MONTH, -1,DATEFROMPARTS(@AnoExtrato, @MesExtrato, 1)))
											ORDER BY DataSaldo DESC

										UNION ALL

										-- Acessa a View: VW_RetornaExtratoMovimentacao_GabrielFelix - e retorna o do mes e ano informado no parametro
										SELECT  *
											FROM [dbo].[VW_RetornaExtratoMovimentacao_GabrielFelix] WITH(NOLOCK)
											WHERE IdConta = @IdConta
											AND DataSaldo 
												-- Pega o primeiro dia do mes 01/xx/xxxx com base nos parametros inseridos
												BETWEEN DATEFROMPARTS(@AnoExtrato, @MesExtrato, 1) 
												-- Pega o ultimo dia do mes 28/29/30/31/xx/xxxx com base nos parametros inseridos
												AND EOMONTH(DATEFROMPARTS(@AnoExtrato, @MesExtrato, 31))

										UNION ALL

										-- Acessa a View: VW_RetornaSaldoIncialExtrato_GabrielFelix - e retorna o ultimo dia com saldo do mes ao informado no parametro da Function
										SELECT  TOP 1 IdConta,
													  DataSaldo,
													  'Saldo Final' As Movimentacao,
													  TipoMovimentacao,
													  Valor
											FROM [dbo].[VW_RetornaSaldoExtrato_GabrielFelix] as vw WITH(NOLOCK)
											WHERE IdConta = @IdConta
											AND DataSaldo 
												-- Retorna o primeiro dia/mes/ano com base no parametro @MesExtrato e @AnoExtrato
												BETWEEN DATEFROMPARTS(@AnoExtrato, @MesExtrato, 1) 
												-- Retorna o ultimo dia/mes/ano com base no parametro @MesExtrato e @AnoExtrato
												AND EOMONTH(DATEFROMPARTS(@AnoExtrato, @MesExtrato, 31))
											ORDER BY DataSaldo DESC
									  )
    
	-- Consulta na CTe as informações para retornar o extrato
	SELECT DataSaldo,
		Movimentacao,
		TipoMovimentacao,
		Valor,
		SUM(Valor) OVER (
							PARTITION BY IdConta
							ORDER BY DataSaldo ASC
							ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
						) As Saldo
	FROM ConsultarExtrato
		   );
GO
