USE RicBankTeste
GO

CREATE OR ALTER VIEW [dbo].[VW_ConsultaExtrato]
AS
/*
	Objetivo: Elaborar uma View que retorne o extrato de uma conta com o filtro do Id da Conta, Mês e Ano

	Resultado esperado pela execução:
	
	Data  - Historico     - TipoMovimentacao - Valor - Saldo
	xx/xx | Saldo Inicial |          -       | 100   |  100
	
	.
	.
	.

	xx/xx | Saldo Final   |          -       | 100   |  100
*/
	WITH RetornaExtrato AS(
							 SELECT  mo.IdSaldo,
							         CAST(mo.DataHora AS VARCHAR) as DataHora,
									 tm.Nome As Historico,
									 mo.DebCre As TipoMovimentacao,
									 CASE WHEN DebCre = 'D' THEN mo.Valor * -1
										  ELSE mo.Valor
									 END As Valor,
									 ROW_NUMBER() OVER (ORDER BY IdSaldo ASC) As NumeroLinha
								 FROM [dbo].[Movimentacao] AS mo WITH(NOLOCK)
								    INNER JOIN [dbo].[TipoMovimentacao] AS tm WITH(NOLOCK)
										ON tm.Id = mo.IdTipoMovimentacao
								 WHERE mo.IdSaldo = 1
						  )
	SELECT  NumeroLinha,
	        CASE WHEN NumeroLinha = 1 THEN 'Saldo Inicial'
				 WHEN NumeroLinha = (
				                       SELECT  TOP 1 NumeroLinha
										   FROM RetornaExtrato
										   ORDER BY NumeroLinha DESC
				                    ) THEN 'Saldo Final'
			     ELSE DataHora 
			END As DataSalso,
			Historico,
			TipoMovimentacao,
			Valor,
			SUM(Valor) OVER (
			                 PARTITION BY IdSaldo
							 ORDER BY DataHora DESC
							) As Saldo
		FROM RetornaExtrato

GO

SELECT * FROM Movimentacao WHERE IdSaldo = 1
