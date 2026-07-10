USE WoodCraft;
GO

-- Caso A: Stored Procedure com SQL Dinâmico Seguro

CREATE OR ALTER PROCEDURE [dbo].[SP_ConsultarMovelFiltros]
	@NomeFiltro VARCHAR(100) = NULL
	AS
	/*
		Documentacao
		Arquivo Fonte............:	SP_ConsultarMolvelFiltros.sql 
		Objetivo.................:  Listar móveis filtrando pelo nome de forma opcional
		Autor....................:	Gabriel Felix
		Data.....................:  09/07/2026
		Ex.......................:	DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Retorno INT,
											@DataInicio DATETIME = GETDATE() 

									EXEC @Retorno = [dbo].[SP_ConsultarMolvelFiltros] @NomeFiltro = '%Carvalho%'

									SELECT  @Retorno AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo
		Retornos.................:	0 - Sucesso
									1 - Erro: Filtro Vazio
	*/
	BEGIN
		-- Declarar variaveis
		DECLARE @Comando NVARCHAR(MAX),
				@Parametros NVARCHAR(1000),
				@Where BIT
		
		-- Montar comando base
		SET @Comando = N'
						SELECT  Id,
								Nome
							FROM [dbo].[Produto] WITH(NOLOCK)
							WHERE 1=1'
		SET @Where = 0

		-- Adicionar filtro caso o parametro seja informado
		IF @NomeFiltro IS NOT NULL
			BEGIN
				SET @Comando = @Comando + N' AND Nome LIKE @pNomeFiltro'
				SET @Where = 1
			END

		-- Definicao do tipo do parametro interno do sp_executesql
		SET @Parametros = N'@pNomeFiltro VARCHAR(100)'

		-- Verificar se ha parametros (exemplo de validacao)
		--IF RIGHT(@Comando, 1) = ' '
		--	BEGIN
		--		RETURN 1
		--	END

		-- Executar comando
			EXEC sp_executesql @Comando,
							   @Parametros,
							   @pNomeFiltro = @NomeFiltro

		RETURN 0
	END

-- -> Comandos para execução

DECLARE @Retorno INT;

EXEC @Retorno = [dbo].[SP_ConsultarMovelFiltros];
SELECT  @Retorno as Retorno;

EXEC [dbo].[SP_ConsultarMolvelFiltros];
EXEC [dbo].[SP_ConsultarMovelFiltros] @NomeFiltro = '%Carvalho%';