USE ricbank;

GO

IF EXISTS (SELECT 1 FROM [dbo].[sysobjects] WHERE Id = OBJECT_ID(N'[dbo].[RBSP_InserirCliente]') AND OBJECTPROPERTY(Id, N'IsProcedure') = 1)
		DROP PROCEDURE [dbo].[RBSP_InserirCliente]
GO

CREATE PROCEDURE [dbo].[RBSP_InserirCliente]
    @IdEndereco     INT,
    @Documento      VARCHAR(14),
    @Nome           VARCHAR(200),
    @DataNascimento DATETIME,
    @Email          VARCHAR(254)

AS
	/*
		Arquivo Fonte............:	RBSP_InserirCliente.sql
		Objetivo.................:	Inserir cliente
		Autor....................:	Cauê Reis
		Data Criação.............:	03/08/2026
		Exemplo..................:	BEGIN TRANSACTION
										
										DBCC FREEPROCCACHE
										DBCC DROPCLEANBUFFERS

										DECLARE @Retorno INT, 
												@DataInicio DATETIME = GETDATE()

										SELECT TOP 2 * FROM [dbo].[Cliente] WITH(NOLOCK) ORDER BY DESC
										 
										EXEC @Retorno = [dbo].[RBSP_InserirCliente]	@IdEndereco = 1,
																				@Documento = 123456789,
																				@Nome = 'Nome completo',
																				@DataNascimento = GETDATE(),
																				@Email = 'email@email.com"

										SELECT TOP 2 * FROM [dbo].[Cliente] WITH(NOLOCK) ORDER BY DESC

										SELECT	@Retorno AS Retorno,
												DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS 'Tempo (ms)'

									ROLLBACK TRANSACTION

		Retornos.................:	0 - Sucesso
									1 - Cliente já cadastrado
									2 - Endereço não cadastrado
									3 - Falha na Execução da inserção
	*/
	BEGIN
		
		IF EXISTS ( SELECT TOP 1 1 
						FROM [dbo].[Cliente] WITH(NOLOCK)
						WHERE Documento = @Documento
				  )
			BEGIN
				PRINT 'Cliente já cadastrado'
				RETURN 1
			END
	
		IF NOT EXISTS ( SELECT TOP 1 1 
						FROM [dbo].[Endereco] WITH(NOLOCK)
						WHERE Id = @IdEndereco
				  )
			BEGIN
				PRINT 'Endereço não cadastrado'
				RETURN 2
			END
	
		BEGIN TRANSACTION 
	
			INSERT INTO [dbo].[Cliente](IdEndereco, Documento, Nome, DataNascimento, Email)
				VALUES(@IdEndereco, @Documento, @Nome, @DataNascimento, @Email)
	
			IF @@ERROR <>0 AND @@ROWCOUNT = 0
				BEGIN
					ROLLBACK TRANSACTION
					RETURN 3
				END
		END
	
		COMMIT TRANSACTION
		RETURN 0

	END
