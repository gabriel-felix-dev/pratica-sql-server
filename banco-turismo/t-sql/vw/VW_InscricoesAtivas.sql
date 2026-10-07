USE Turismo;
GO	

IF EXISTS (
               SELECT  1
				   FROM [dbo].[sysobjects]
				   WHERE Id = OBJECT_ID(N'[dbo].[VW_InscricoesAtivas]')
					   AND TYPE = 'V'
		  )
	DROP VIEW [dbo].[VW_InscricoesAtivas];
GO

CREATE VIEW [dbo].[VW_InscricoesAtivas]
	AS
	/*
		Documentacao
		Arquivo Fonte............: VW_InscricoesAtivas.sql
		Objetivo.................: Retornar os Clientes que possuem inscrições ativas.
		Autor....................: Gabriel Felix
		Data.....................: 06/10/2026
		Ex.......................: SELECT  *
									   FROM [dbo].[VW_InscricoesAtivas];
	*/
	SELECT  cl.Nome As Cliente,
			pa.Nome As Pacote,
			pa.Destino,
			ex.Codigo As CodigoExcursao,
			ex.DataSaida,
			ic.QuantidadeLugares,
			ic.ValorTotal,
			ic.QuantidadeParcelas,
			si.Descricao As SituacaoInscricao
		FROM [dbo].[Inscricao] AS ic WITH(NOLOCK)
			INNER JOIN [dbo].[Cliente] AS cl WITH(NOLOCK)
				ON cl.Id = ic.IdCliente AND cl.Ativo = 1
			INNER JOIN [dbo].[Excursao] AS ex WITH(NOLOCK)
				ON ex.Id = ic.IdExcursao AND ex.Ativo = 1
			INNER JOIN [dbo].[Pacote] AS pa WITH(NOLOCK)
				ON pa.Id = ex.IdPacote
			INNER JOIN [dbo].[SituacaoInscricao] AS si WITH(NOLOCK)
				ON si.Id = ic.IdSituacaoInscricao
		WHERE si.Descricao = 'ATIVA'
GO
