USE Locadora;
GO

IF EXISTS (
		       SELECT  1
				   FROM [dbo].[sysobjects]
				   WHERE Id = OBJECT_ID(N'[dbo].[VW_FaturamentoCategoria]')
				       AND TYPE = 'V'
		  )
	DROP VIEW [dbo].[VW_FaturamentoCategoria];
GO

CREATE VIEW [dbo].[VW_FaturamentoCategoria]
AS
/*
	Documentacao
	Arquivo Fonte............: VW_FaturamentoCategoria.sql
	Objetivo.................: Retorna o faturamento de cada categoria, as locações finalizadas e as locações que houve comparecimento
	Autor....................: Gabriel Felix
	Data.....................: 07/10/2026
	Ex.......................: SELECT  *
								   FROM [dbo].[VW_FaturamentoCategoria];
*/
SELECT  ca.Nome As Categoria,
		COUNT(CASE WHEN lo.IdSituacaoLocacao = 3 THEN 1
			  END) As LocacoesFinalizadas, -- Quantidade de locações finalizadas,
		COUNT (CASE WHEN lo.IdSituacaoLocacao = 5 THEN 1
			   END) As NaoCompareceu,-- não compareceu
		ISNULL(SUM(co.ValorTotalCobrancas), 0.00) As ValorTotalFaturado-- valor total faturado -- categoria sem faturamnete deve aparecer como nulo
	FROM [dbo].[Locacao] AS lo WITH(NOLOCK)
		INNER JOIN [dbo].[Veiculo] AS ve WITH(NOLOCK)
			ON ve.id = lo.IdVeiculo
		LEFT JOIN (
				       SELECT  IdLocacao,
							   SUM(Valor) As ValorTotalCobrancas
						   FROM [dbo].[Cobranca] WITH(NOLOCK)
						   GROUP BY IdLocacao
				  ) AS co
			ON co.IdLocacao = lo.Id
		RIGHT JOIN [dbo].[Categoria] AS ca WITH(NOLOCK)
			ON ca.Id = ve.IdCategoria AND ca.Ativo = 1
	GROUP BY ca.Nome, ca.Id
GO
