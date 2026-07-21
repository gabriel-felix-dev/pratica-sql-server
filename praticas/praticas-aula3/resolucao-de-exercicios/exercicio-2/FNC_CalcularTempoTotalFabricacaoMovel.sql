USE WoodCraft;
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularTempoTotalFabricacaoMovel] (@IdProduto INT)
	RETURNS INT
	AS
	/*
		Documentacao
		Arquivo Fonte............: FNC_CalcularTempoTotalFabricacaoMovel.sql
		Objetivo.................: Calcular o tempo de fabricacao de um produto
		Autor....................: Gabriel Felix
		Data.....................: 21/07/2026
		Ex.......................: DBCC FREEPROCCACHE
								   DBCC DROPCLEANBUFFERS	

								   DECLARE @DataInicio DATETIME = GETDATE();

								   SELECT [dbo].[FNC_CalcularTempoTotalFabricacaoMovel](1) as TempoDeFacricacao

								   SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) as TempoExecucao
	*/
	BEGIN
	-- Declarar variavel que tera o tempo de retorno
	DECLARE @TempoExecucao INT;
	
	-- Fazer a consulta
	SELECT  @TempoExecucao = SUM(ef.DuracaoMinutos) 
		FROM EtapaFabricacao AS ef WITH(NOLOCK)
		WHERE ef.IdProduto = @IdProduto
		GROUP BY ef.IdProduto;

	-- Retornar o valor	
	RETURN ISNULL(@TempoExecucao,0);
	END
GO

-- Declarar variaveis para o loop
DECLARE @Contador INT = 0,
		@QuantidadeDeProdutosCadastrados INT,
		@NomeProduto VARCHAR(100),
		@TempoProducao INT; 

-- Realiazar consulta para preencher a variavel de comparacao do Loop
SELECT  @QuantidadeDeProdutosCadastrados = COUNT(*)
	FROM [dbo].[Produto] WITH(NOLOCK);

-- Realiazar o loop
WHILE @Contador <= @QuantidadeDeProdutosCadastrados
	BEGIN
		SELECT  @NomeProduto = pr.Nome 
			FROM [dbo].[Produto] AS pr WITH(NOLOCK)
			WHERE pr.Id = @Contador;
		
		SELECT  @TempoProducao = [dbo].[FNC_CalcularTempoTotalFabricacaoMovel](@Contador)

		PRINT 'O Produto ' + @NomeProduto + ' leva ' + CAST(@TempoProducao AS VARCHAR) + ' minutos para ser fabricado.'

		SET @Contador = @Contador + 1;
	END
