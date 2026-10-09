USE Locadora;
GO

IF EXISTS (
		       SELECT  1
				   FROM [dbo].[sysobjects]
				   WHERE Id = OBJECT_ID(N'[dbo].[VW_AgendaLocacoesAbertas]')
				       AND TYPE = 'V'
		  )
	DROP VIEW [dbo].[VW_AgendaLocacoesAbertas];
GO

CREATE VIEW [dbo].[VW_AgendaLocacoesAbertas]
AS
/*
	Documentacao
	Arquivo Fonte............: VW_AgendaLocacoesAbertas.sql
	Objetivo.................: Retorna uma consulta que é uma agenda de locações em aberto
	Autor....................: Gabriel Felix
	Data.....................: 07/10/2026
	Ex.......................: SELECT  *
								   FROM [dbo].[VW_AgendaLocacoesAbertas];
*/
SELECT  cl.Nome As Cliente,
		ca.Nome As Categoria,
		ve.Placa,
		sl.Descricao As Situacao,
		COALESCE (lo.DataHoraRetirada, lo.DataRetiradaPrevista) As Dataretirada, --(real, quando já houve retirada, ou prevista),
		lo.DataDevolucaoPrevista, -- data devolução prevista,
		CASE WHEN sl.Descricao = 'EM_ANDAMENTO' AND lo.DataDevolucaoPrevista < CAST(GETDATE() AS DATE) THEN DATEDIFF(DAY, lo.DataDevolucaoPrevista, CAST(GETDATE() AS DATE))
			 ELSE 0
			 END As DiasAtraso, -- dias em atraso (para em_andamento com devolução prevista para data anterior a hoje, senão 0),
		CASE WHEN sl.Descricao = 'RESERVADA' AND ma.IdVeiculo = lo.IdVeiculo THEN 'Atenção necessária'
			 ELSE 'Veiculo liberado'
			 END As AlertaManutencaoEmAndamento-- indicador de alerta para veiculos com situacao de RESERVA ainda estiver em manutenção
	FROM [dbo].[Locacao] AS lo WITH(NOLOCK)
		INNER JOIN [dbo].[SituacaoLocacao] AS sl WITH(NOLOCK)
			ON sl.Id = lo.IdSituacaoLocacao
		INNER JOIN [dbo].[Cliente] AS cl WITH(NOLOCK)
			ON cl.Id = lo.IdCliente AND cl.Ativo = 1
		INNER JOIN [dbo].[Veiculo] AS ve WITH(NOLOCK)
			ON ve.Id = lo.IdVeiculo AND ve.Ativo = 1
		INNER JOIN [dbo].[Categoria] AS ca WITH(NOLOCK)
			ON ca.Id = ve.IdCategoria AND ca.Ativo = 1
		LEFT JOIN (
		               SELECT  mn.IdVeiculo
						   FROM [dbo].[Manutencao] AS mn WITH(NOLOCK)
						   WHERE mn.DataConclusao IS NULL
						   GROUP BY IdVeiculo
				  ) AS ma
			ON ma.IdVeiculo = lo.IdVeiculo
	WHERE sl.Descricao = 'RESERVADA' 
		OR sl.Descricao = 'EM_ANDAMENTO';
GO
