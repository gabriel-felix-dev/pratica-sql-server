USE WoodCraft;
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_ConsultarEtapasPendentesPedido](@IdPedido INT)
	RETURNS TABLE
	AS
	/*
		Documentaco
		Arquivo Fonte............: FNC_ConsultarEtapasPendentesPedido.sql
		Objetivo.................: Retornar uma tabela que informe as etapas pendentes de um pedido
		Autor....................: Gabriel Felix 
		Data.....................: 22/07/2026
		Ex.......................: DBCC FREEPROCCACHE
								   DBCC DROPCLEANBUFFERS

								   DECLARE @DataInicio DATETIME = GETDATE();
								   
								   SELECT  *
									   FROM [dbo].[Pedido];

								   SELECT  *
									   FROM [dbo].[FNC_ConsultarEtapasPendentesPedido](1);

								   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) as TempoExecucao 

	*/
	RETURN(
	    SELECT  pe.Id as IdPedido,
				cl.Nome as Cliente,
				pr.Nome as Produto,
				ef.NumeroEtapa as NumeroEtapa,
				ef.Descricao as DescricaoEtapa,
				ef.DuracaoMinutos as DuracaoMinutos,
				CASE 
					WHEN hp.Id IS NOT NULL AND hp.DataInicio IS NOT NULL THEN 'Concluído'
					WHEN hp.Id IS NOT NULL AND hp.DataTermino IS NULL THEN 'Em Andamento'
					ELSE 'Não Iniciado'
				END as StatusEtapa
			FROM [dbo].[Pedido] AS pe WITH(NOLOCK)
				INNER JOIN [dbo].[Cliente] AS cl WITH(NOLOCK)
					ON cl.Id = pe.IdCliente
				INNER JOIN [dbo].[ItemPedido] AS tp WITH(NOLOCK)
					ON tp.IdPedido = pe.Id
				INNER JOIN [dbo].[Produto] AS pr WITH(NOLOCK)
					ON pr.Id = tp.IdProduto
				INNER JOIN [dbo].[EtapaFabricacao] AS ef WITH(NOLOCK)
					ON ef.IdProduto = pr.Id
				LEFT JOIN [dbo].[HistoricoProducao] AS hp WITH(NOLOCK)
					ON hp.IdEtapaFabricacao = ef.Id
						AND hp.IdItemPedido = tp.Id
			WHERE pe.Id = @IdPedido
	)
GO
