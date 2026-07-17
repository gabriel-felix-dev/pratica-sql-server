USE WoodCraft;
GO

-- Função Tabular: Retorna uma tabela

CREATE OR ALTER FUNCTION [dbo].[FNC_ListarInsumosMovel] (@IdProduto INT)
	RETURNS TABLE
	AS
	/*
		Documentacao
		Arquivo Fonte............: FNC_ListarInsumosMovel.sql
		Objetivo.................: Retorna insumos ncessarios e quantidades para o movel
		Autor....................: Gabriel Felix
		Data.....................: 17/07/2026
		Ex.......................: DBCC FREEPROCCACHE
		                           DBCC DROPCLEANBUFFERS

								   DECLARE @DataInicio DATETIME = GETDATE();

								   SELECT  *
								       FROM [dbo].[FNC_ListarInsumosMovel](1);

								   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) as TempoExecucao;
	*/
	RETURN(
		SELECT  co.IdProduto as IdProduto,
				pr.Nome as Produto,
				co.IdMateriaPrima as IdMateriaPrima,
				mp.Nome as MateriaPrima,
				co.Quantidade as QuantidadeNecessaria
			FROM [dbo].[Composicao] AS co WITH(NOLOCK)
				INNER JOIN [dbo].[Produto] AS pr WITH(NOLOCK)
					ON pr.Id = co.IdProduto
				INNER JOIN [dbo].[MateriaPrima] AS mp WITH(NOLOCK)
					ON mp.Id = co.IdMateriaPrima
			WHERE co.IdProduto = @IdProduto
	);
GO
