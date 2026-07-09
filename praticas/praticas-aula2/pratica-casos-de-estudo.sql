USE WoodCraft;
GO

-- Caso A: Soma Acumulada para Saldo de Estoque Histórico

WITH HistoricoMovimentacoes AS (
	
	SELECT  IdEstoqueMateriaPrima as IdMateriaPrima,
			DataMovimentacao,
			Quantidade,
			CASE
				WHEN IdTipoMovimentacao = 1 THEN Quantidade
				WHEN IdTipoMovimentacao = 2 THEN -Quantidade
				ELSE 0
			END as Variacao
		FROM [dbo].[MovimentacaoEstoqueMateriaPrima] WITH(NOLOCK)
)
SELECT  IdMateriaPrima,
		DataMovimentacao,
		Variacao,
		SUM(Variacao) OVER (
			PARTITION BY IdMateriaPrima
			ORDER BY DataMovimentacao
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
		) as SoldoEstoqueAcumulado
	FROM HistoricoMovimentacoes
	ORDER BY IdMateriaPrima, DataMovimentacao;

-- Caso B: Classificação de Prioridade de Pedidos

SELECT  pe.Id as IdentificadorPedido,
		cl.Nome as Cliente,
		pe.DataPedido as DataPedido,
		pe.DataPromessa as DataPromessa,
		DENSE_RANK () OVER(
			ORDER BY pe.DataPromessa ASC
		) as PrioridadeEntrega
	FROM [dbo].[Pedido] AS pe WITH(NOLOCK)
		INNER JOIN [dbo].[Cliente] AS cl WITH(NOLOCK)
			ON cl.Id = pe.IdCliente
	WHERE pe.DataEntrega IS NULL;
