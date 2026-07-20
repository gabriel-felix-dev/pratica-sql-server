USE WoodCraft;
Go

-- Exercício 1: View de Painel Financeiro e de Expedição

CREATE OR ALTER VIEW [dbo].[VW_ResumoPedidosClientes]
AS
SELECT  pe.Id as IdPedido,	
		cl.Nome as Cliente,
		pe.DataPedido as DataEmissao,
		SUM(tp.Quantidade) as QuantidadeItens,
		CASE
			WHEN pe.DataEntrega IS NOT NULL THEN 'Entregue'
			WHEN pe.DataEntrega IS NULL AND pe.DataPromessa < CAST(GETDATE() AS DATE) THEN 'Atrasado'
			WHEN pe.DataEntrega IS NULL AND pe.DataPromessa >= CAST(GETDATE() AS DATE) THEN 'Em Andamento'
		END as StatusPedido
	FROM [dbo].[Cliente] AS cl WITH(NOLOCK)
		INNER JOIN [dbo].[Pedido] AS pe WITH(NOLOCK)
			ON pe.IdCliente = cl.Id
		INNER JOIN [dbo].[ItemPedido] AS tp WITH(NOLOCK)
			ON tp.IdPedido = pe.Id
	GROUP BY pe.Id, cl.Nome, pe.DataPedido, pe.DataEntrega, pe.DataPromessa
GO

SELECT  *
	FROM [dbo].[VW_ResumoPedidosClientes];
