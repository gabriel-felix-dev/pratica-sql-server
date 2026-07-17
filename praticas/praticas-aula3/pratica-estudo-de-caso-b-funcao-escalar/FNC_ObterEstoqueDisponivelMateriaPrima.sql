USE WoodCraft;
GO

-- Função Escalar: no final ela retorna um valor único

CREATE OR ALTER FUNCTION [dbo].[FNC_ObterEstoqueDisponivelMateriaPrima] (@IdMateriaPrima INT)
	RETURNS INT
	AS
	/* 
		Documentacao
		Arquivo Fonte............: FNC_ObterEstoqueDisponivelMateriaPrima.sql
		Objetivo.................: Calcular a quantidade fisica liquida disponivel em estoque
		Autor....................: Gabriel Felix
		Data.....................: 16/07/2026
		Ex.......................: DBCC FREEPROCCACHE
		                           DBCC DROPCLEANBUFFERS

								   DECLARE @DataInicio DATETIME = GETDATE();

								   SELECT  [dbo].[FNC_ObterEstoqueDisponivelMateriaPrima](1) as Resultado;

								   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) as TempoExecucao;
	*/
	BEGIN
		-- Declarar variaveis
		DECLARE @Quantidade INT = 0

		-- Obter quantidade fisica
		SELECT  @Quantidade = QuantidadeFisica
			FROM [dbo].[EstoqueMateriaPrima] WITH(NOLOCK)
			WHERE IdMateriaPrima = @IdMateriaPrima;

		-- Retornar valor
		RETURN ISNULL(@Quantidade, 0);
	END
GO
