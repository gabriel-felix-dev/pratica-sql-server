USE RicBankTeste;
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_ValidarInclusaoLancamento_Gabriel] (@IdConta INT, @Valor DECIMAL(18,2))
	RETURNS TINYINT
	AS
	/*
		Documentacao
		Arquivo Fonte............: FNC_ValidarInclusaoLancamento_Gabriel.sql
		Obejtivo.................: Validar Inclusao Lancamento
		Autor....................: Gabriel Felix
		Data.....................: 21/08/2026
		Ex.......................: DBCC FREEPROCCACHE
								   DBCC DROPCLEANBUFFERS

								   DECLARE @DataInicio DATETIME = GETDATE();

								   SELECT  [dbo].[FNC_ValidarInclusaoLancamento_Gabriel] (1, '2024-01-05') As Resultado;

								   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;
		
		Retorno..................: 0 - Sucesso
		                           1 - Erro: Conta nao existe
	*/
	BEGIN
		IF NOT EXISTS (
		                  SELECT  TOP 1 1
							  FROM [dbo].[Conta] WITH(NOLOCK)
							  WHERE Id = @IdConta
					  )
			RETURN 1



		RETURN 0
	END
GO

