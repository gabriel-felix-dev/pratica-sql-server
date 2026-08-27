USE RicBankTeste
GO

CREATE OR ALTER VIEW [dbo].[VW_RetornaExtratoMovimentacao_GabrielFelix]
/*
	Documentacao
	Arquivo Fonte............: VW_RetornaExtratoMovimentacao_GabrielFelix.sql
	Objetivo.................: Retornar uma tabela com todas as movimentacoes
	Autor....................: Gabriel Felix
	Data.....................: 26/08/2025
	Ex.......................: DBCC FREEPROCCACHE
	                           DBCC DROPCLEANBUFFERS

							   DECLARE @DataInicio DATETIME = GETDATE();

							   SELECT  TOP 10 * 
								   FROM [dbo].[VW_RetornarExtratoMovimentacao_GabrielFelix];

							   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao
*/		
AS	
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
GO
										