USE WoodCraft;
GO

-- Exercício 1: Classificação de Etapas de Fabricação

WITH EtapasPorProduto AS (
	
	SELECT  pr.Nome,
			ef.Descricao,
			ef.NumeroEtapa,
			ROW_NUMBER() OVER (PARTITION BY ef.IdProduto ORDER BY ef.NumeroEtapa DESC) as SequenciaEtapaDecrescente
		FROM [dbo].Produto AS pr WITH(NOLOCK)
			INNER JOIN[dbo].[EtapaFabricacao] AS ef
				ON ef.IdProduto = pr.Id
) SELECT  Nome as NomeProduto,
		  Descricao as DescricaoEtapa,
		  NumeroEtapa as NumeroEtapa,
		  SequenciaEtapaDecrescente as SequenciaEtapaDecrescente
	FROM EtapasPorProduto
	WHERE SequenciaEtapaDecrescente = 1
	ORDER BY Nome ASC;

-- Exercício 2: Tempo de Espera (Ociosidade) entre Etapas

SELECT  hp.Id as IdentificadorHistoricoProducao,
		ef.Descricao as DescricaoEtapaFabricacao,
		hp.IdItemPedido as IdentificadorItemPedido,
		hp.DataInicio,
		hp.DataTermino,
		hp.Quantidade,
		LAG(DataTermino) OVER (
			PARTITION BY hp.IdItemPedido
			ORDER BY hp.DataInicio ASC
		) as DataTerminoAnterior,
		DATEDIFF(minute, hp.DataInicio, hp.DataTermino) as MinutosEmEspera
	FROM [dbo].[HistoricoProducao] AS hp WITH(NOLOCK)
		INNER JOIN [dbo].[EtapaFabricacao] AS ef WITH(NOLOCK)
			ON ef.Id = hp.IdEtapaFabricacao
	ORDER BY hp.IdItemPedido, hp.DataInicio ASC;

-- Exercício 3: Fluxo Acumulado de Produção e Dependência

-- 1. Fazer a consulta da CTE

WITH ProdutosEtapasDeFabricao AS (
	SELECT  pr.Nome as Produto,
			ef.Descricao as DescricaoEtapaFabricacao,
			ef.DuracaoMinutos as DuracaoEmMinutos,
			ef.NumeroEtapa as NumeroDaEtapa,
			SUM(ef.DuracaoMinutos) OVER(
				PARTITION BY pr.Id 
				ORDER BY ef.NumeroEtapa ASC
			) as DuracaoAcumuladaMinutos,
			LAG(ef.Descricao) OVER (
				PARTITION BY pr.Id
				ORDER BY ef.NumeroEtapa ASC
			) as EtapaAnteriorDescricao
		FROM [dbo].[Produto] AS pr WITH(NOLOCK)
			INNER JOIN [dbo].EtapaFabricacao AS ef WITH(NOLOCK)
				ON ef.IdProduto = pr.Id
)SELECT  Produto,
		 DescricaoEtapaFabricacao,
		 DuracaoEmMinutos,
		 NumeroDaEtapa,
		 DuracaoAcumuladaMinutos,
		 ISNULL(EtapaAnteriorDescricao, 'Início da Produção') as EtapaAnteriorDescricao
	FROM ProdutosEtapasDeFabricao
	ORDER BY Produto, NumeroDaEtapa ASC;

-- Desafio aula 02

WITH FilaDePedidos AS (
	
	SELECT  pe.Id as IdPedido,
			cl.Id as IdCliente,
			cl.Nome as Cliente,
			pe.DataPedido as DataPedido,
			pe.DataPromessa as DataPromessa,
			ROW_NUMBER() OVER(
				PARTITION BY cl.Id
				ORDER BY pe.DataPedido ASC
			) as NumeroSequenciaPedido,
			LAG(pe.DataPedido) OVER(
				PARTITION BY cl.Id 
				ORDER BY pe.DataPedido ASC
			) as DataPedidoAnterior
		FROM [dbo].[Pedido] AS pe WITH(NOLOCK)
			INNER JOIN [dbo].[Cliente] AS cl WITH(NOLOCK)
				ON cl.Id = pe.IdCliente
) SELECT  IdPedido,
		  IdCliente,
		  Cliente,
		  DataPedido,
		  DataPromessa,
		  NumeroSequenciaPedido,
		  ISNULL(CAST(DataPedidoAnterior AS VARCHAR), 'Pedido único') as DataPedidoAnterior,
		  ISNULL(CAST(DATEDIFF(DAY, DataPedido, DataPedidoAnterior) AS VARCHAR), 'Pedido único') as DiasDesdeOPedidoAnterior
	FROM FilaDePedidos
	ORDER BY Cliente, NumeroSequenciaPedido ASC;
