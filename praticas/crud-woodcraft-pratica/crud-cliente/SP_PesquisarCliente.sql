USE WoodCraftPratica;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_PesquisarCliente]
	@NomeFiltro VARCHAR(100) = NULL
	AS
	/*
		Documentacao

		Arquivo Fonte............: SP_PesquisarCliente.sql
		Objetivo.................: Pesquisar Clientes com ou sem nome
		Autor....................: Gabriel Felix
		Data.....................: 12/08/2026
		Ex.......................: DBCC FREEPROCCACHE
								   DBCC DROPCLEANBUFFERS
								   
								   DECLARE @Retorno INT,
								           @DataInicio DATETIME = GETDATE();
								   
								   EXEC @Retorno = [dbo].[SP_PesquisarCliente];

								   -- EXEC @Retorno = [dbo].[SP_PesquisarCliente] @NomeFiltro = 'Gabriel';

								   SELECT  @Retorno As RetornoConsulta,
										   DATEDIFF(MILLSECOND, @DataInicio, GETDATE());							   
								   
		Retorno..................: 0 - Sucesso
		                           1 - Cliente não cadastrado
	*/
	BEGIN
		-- Declarar variaveis para consulta
		DECLARE @Filtro NVARCHAR(MAX);

		-- Validar se o nome existe na tabela Cliente

		IF NOT EXISTS (
					      SELECT  TOP 1 1
							  FROM [dbo].[Cliente] AS cl WITH(NOLOCK)
							  WHERE cl.Nome LIKE @NomeFiltro
		              )
			BEGIN
				RETURN 1
			END

		-- Validar se o parametro é nulo
		IF @NomeFiltro IS NULL
			BEGIN
				-- Realizar consulta sem filtro
				SELECT  Id,
						Nome,
						Documento,
						Telefone,
						TipoCLiente
					FROM [dbo].[Cliente] WITH(NOLOCK);
				RETURN 0
			END

		-- Realizar consulta com filtro
		IF @NomeFiltro IS NOT NULL
			BEGIN
				
				RETURN 0
			END	 
	END
GO
