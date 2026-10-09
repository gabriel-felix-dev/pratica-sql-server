USE Locadora;
GO

SELECT * FROM [dbo].[Cliente];
SELECT * FROM [dbo].[Categoria];
SELECT * FROM [dbo].[TarifaCategoria];
SELECT * FROM [dbo].[Veiculo];
SELECT * FROM [dbo].[Manutencao]; SELECT * FROM [dbo].[Veiculo];
SELECT * FROM [dbo].[Locacao]; SELECT * FROM [dbo].[SituacaoLocacao] ORDER BY Id;
SELECT * FROM [dbo].[Cobranca]; SELECT * FROM [dbo].[TipoCobranca];

SELECT lo.Id, lo.ValorTotal, co.Valor, lo.DataHoraDevolucao 
	FROM [dbo].[Locacao] AS lo WITH(NOLOCK)
		INNER JOIN [dbo].[Veiculo] AS ve WITH(NOLOCK)
			ON ve.id = lo.IdVeiculo AND ve.Ativo = 1
		INNER JOIN [dbo].[Cobranca] AS co WITH(NOLOCK)
			ON co.IdLocacao = lo.Id
		RIGHT JOIN [dbo].[Categoria] AS ca WITH(NOLOCK)
			ON ca.Id = ve.IdCategoria AND ca.Ativo = 1;
