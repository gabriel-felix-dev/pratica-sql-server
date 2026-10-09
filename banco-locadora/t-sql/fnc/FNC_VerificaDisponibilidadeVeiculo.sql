USE Locadora;
GO

IF EXISTS (
		       SELECT  1
				   FROM [dbo].[sysobjects]
				   WHERE Id = OBJECT_ID(N'[dbo].[FNC_VerificaDisponibilidadeVeiculo]')
				       AND TYPE = 'FN'
		  )
	DROP FUNCTION [dbo].[FNC_VerificaDisponibilidadeVeiculo];
GO

CREATE FUNCTION [dbo].[FNC_VerificaDisponibilidadeVeiculo] (@IdVeiculo INT, @DataInicial DATE, @DataFinal DATE)
	RETURNS SMALLINT
AS
/*
	Documentacao
	Arquivo Fonte............: FNC_VerificaDisponibilidadeVeiculo.sql
	Objetivo.................: Retorna se um Veiculo está disponivel em determinada data
	Autor....................: Gabriel Felix
	Data.....................: 09/10/2026
	Ex.......................: DBCC FREEPROCCACHE
							   DBCC DROPCLEANBUFFERS

							   DECLARE @DataInicio DATETIME = GETDATE();

							   SELECT [dbo].[FNC_VerificaDisponibilidadeVeiculo] (9, '2026-10-17', '2026-10-17') As Retorno,
									  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;

	Retorno..................:  1 - Veiculo disponível
						        0 - Veiculo indisponível
							   -1 - Erro: Todos os campos devem ser preenchidos
							   -2 - Erro: Veículo não cadastrado
							   -3 - Erro: O Veículo seleciona está desativado
							   -4 - Erro: A Categoria do veículo está indisponível. Verificar status do veículo
							   -5 - Erro: A data inicial deve ser menor que a data final
							   -6 - Erro: O veículo está em manutenção
*/
BEGIN
	-- Validar se algum campo é nulo
	IF @IdVeiculo IS NULL
		OR @DataFinal IS NULL
		OR @DataInicial IS NULL
		RETURN -1

	-- Validar se o veiculo existe
	IF NOT EXISTS (
				      SELECT  TOP 1 1
						  FROM [dbo].[Veiculo] WITH(NOLOCK)
						  WHERE Id = @IdVeiculo
				  )
		RETURN -2

	-- Validar se o veiculo está ativo
	IF (
	        SELECT  TOP 1 Ativo
				FROM [dbo].[Veiculo]  WITH(NOLOCK)
				WHERE Id = @IdVeiculo
	   ) = 0
		RETURN -3

	-- Verificar se categoria do veículo está disponível
	IF (
	       SELECT  ca.Ativo	
			   FROM [dbo].[Categoria] AS ca
			       INNER JOIN [dbo].[Veiculo] As ve
				       ON ve.IdCategoria = ca.Id AND ve.Id = @IdVeiculo 
	   ) = 0
		RETURN -4

	-- Validar se a data inicial é maior que a data final
	IF @DataInicial > @DataFinal
		RETURN -5

	-- Verificar se o veículo está em manutenção
	IF EXISTS (
				SELECT  1
					FROM [dbo].[Manutencao]
					WHERE IdVeiculo = @IdVeiculo
						AND DataConclusao IS NULL
			  )
		RETURN -6

	-- Verificar se o veículo está disponivel no período desejado
	IF EXISTS (
	       --        SELECT  1
					   --FROM [dbo].[Locacao] WITH(NOLOCK)
					   --WHERE IdVeiculo = @IdVeiculo
						  -- AND IdSituacaoLocacao IN (1,2)
						  -- AND (
								--DataRetiradaPrevista = @DataInicial OR DataDevolucaoPrevista = @DataFinal
								--OR (
								--	DataRetiradaPrevista <= @DataFinal AND DataDevolucaoPrevista >= @DataInicial
								--	)
							 --  )
				   SELECT  1
					   FROM [dbo].[Locacao] WITH(NOLOCK)
					   WHERE IdVeiculo = @IdVeiculo
						   AND IdSituacaoLocacao IN (1,2)
						   AND DataRetiradaPrevista <= @DataFinal 
						   AND DataDevolucaoPrevista >= @DataInicial 
			  )
		RETURN 0

	RETURN 1
END
GO
