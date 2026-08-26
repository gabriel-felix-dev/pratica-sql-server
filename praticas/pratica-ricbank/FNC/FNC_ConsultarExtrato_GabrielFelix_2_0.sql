USE RicBankTeste;
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_ConsultarExtrato_GabrielFelix_2_0] (@IdConta TINYINT, @MesExtrato TINYINT, @AnoExtrato SMALLINT)
	RETURNS TABLE
	AS
	/*
		Documentacao
		Arquivo Fonte............: FNC_ConsultarExtrato_GabrielFelix_2_0.sql
		Objetivo.................: Retornar o extrato de uma conta com o saldo inicial e saldo final.
		Autor....................: Gabriel Felix
		Data.....................: 26/08/2026
		Ex.......................: DBCC FREEPROCCACHE
								   DBCC DROPCLEANBUFFERS

		                           SELECT * FROM [dbo].[FNC_ConsultarExtrato_GabrielFelix_2_0] (14, 08, 2026);
	*/
	RETURN (
			 WITH ConsultarExtrato AS ( -- Consulta do Saldo Inicial
									    	SELECT  TOP 1   IdConta,
															DataSaldo,
															Movimentacao,
															TipoMovimentacao,
															Valor
												FROM [dbo].[VW_RetornaSaldoIncialExtrato_GabrielFelix] as vw WITH(NOLOCK)
												WHERE IdConta = @IdConta
													AND DataSaldo 
														-- Retorna o primeiro dia/mes/ano com base no parametro @MesExtrato e @AnoExtrato
														BETWEEN DATEADD( MONTH, -1,DATEFROMPARTS(@AnoExtrato, @MesExtrato, 1)) 
														-- Retorna o ultimo dia/mes/ano com base no parametro @MesExtrato e @AnoExtrato
														AND EOMONTH(DATEADD( MONTH, -1,DATEFROMPARTS(@AnoExtrato, @MesExtrato, 1)))
												ORDER BY DataSaldo DESC

										UNION ALL

										-- Consulta do extrato geral de movimentacoes
										SELECT	sa.IdConta As IdConta,
												CAST(mo.DataHora AS DATE) As DataSaldo,
												tm.Nome as Movimentacao,
												mo.DebCre As TipoMovimentacao,
												CASE WHEN mo.DebCre = 'D' THEN mo.Valor * -1
													 ELSE mo.Valor
												END As Valor
											FROM [dbo].[Saldo] AS sa WITH(NOLOCK)
												INNER JOIN [dbo].[Movimentacao] AS mo WITH(NOLOCK)
													ON mo.IdSaldo = sa.Id
												INNER JOIN [dbo].[TipoMovimentacao] AS tm WITH(NOLOCK)
													ON tm.Id = mo.IdTipoMovimentacao
											WHERE sa.IdConta = @IdConta
												AND mo.DataHora BETWEEN DATEFROMPARTS(@AnoExtrato, @MesExtrato, 1) AND EOMONTH(DATEFROMPARTS(@AnoExtrato, @MesExtrato, 31))

									 ),
			CalculaSaldoFinal AS     ( -- Calcula o Saldo Final
									    SELECT  ROW_NUMBER() OVER (ORDER BY IdConta ASC) As NumeroLinha, -- Cria a numeracao de linhas para ser usada como filtro na consulta da CTe
											   DataSaldo,
											   'Saldo Final ' As Movimentacao,
											   NULL As TipoMovimentacao,
											   Valor,
											   SUM(Valor) OVER (
																	PARTITION BY IdConta
																	ORDER BY DataSaldo ASC
																	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
											) As Saldo
										    FROM ConsultarExtrato
					                 )
	-- Consulta na CTe ConsultarExtrato para retorno o Saldo Inicial unido com o extrato geral das movimentacoes
	SELECT  DataSaldo,
			Movimentacao,
			TipoMovimentacao,
			Valor,
			SUM(Valor) OVER (
								PARTITION BY IdConta
								ORDER BY DataSaldo ASC
								ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
							) As Saldo
		FROM ConsultarExtrato

	UNION ALL

	-- Consulta na CTe CalculaSaldoFinal para o resultado do Saldo Final ser unido com a CTe ConsultarExtrato
	SELECT  TOP 1 DataSaldo,
				  Movimentacao,
				  TipoMovimentacao,
				  NULL As Valor,
				  Saldo
		FROM CalculaSaldoFinal
		WHERE NumeroLinha = ( -- Filtra o resultado da CTe para retornar a ultima linha dela
								SELECT  COUNT(*) 
									FROM CalculaSaldoFinal
		                    )
           );
GO
