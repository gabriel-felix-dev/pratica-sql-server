USE WoodCraft;
GO

CREATE OR ALTER VIEW [dbo].[VW_PainelProducaoAtiva]
AS
	SELECT  hp.Id AS IdOrdemProducao,
       c.Nome AS NomeCliente,
       prod.Nome AS NomeMovel,
       ef.Descricao AS EtapaProcesso,
       ef.NumeroEtapa,
       hp.Quantidade,
       hp.DataInicio,
       hp.DataTermino,
       CASE
           WHEN hp.DataTermino IS NOT NULL THEN 'Concluído'
           ELSE 'Em Fabricação'
       END AS StatusFabricacao
FROM [dbo].[HistoricoProducao] hp WITH(NOLOCK)
INNER JOIN [dbo].[EtapaFabricacao] ef WITH(NOLOCK) ON hp.IdEtapaFabricacao = ef.Id
INNER JOIN [dbo].[ItemPedido] ip WITH(NOLOCK) ON hp.IdItemPedido = ip.Id
INNER JOIN [dbo].[Pedido] ped WITH(NOLOCK) ON ip.IdPedido = ped.Id
INNER JOIN [dbo].[Cliente] c WITH(NOLOCK) ON ped.IdCliente = c.Id
INNER JOIN [dbo].[Produto] prod WITH(NOLOCK) ON ip.IdProduto = prod.Id;
GO

SELECT *
    FROM VW_PainelProducaoAtiva;
