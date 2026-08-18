USE WoodCraftPratica;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_CadastrarCliente]
	@NomeCliente VARCHAR(100) = NULL,
	@DocumentoCliente VARCHAR(14) = NULL,
	@TelefoneCliente VARCHAR(11) = NULL,
	@TipoCliente BIT = NULL
	AS
	/*
		Documentacao
		Arquivo Fonte............: SP_CadastrarCliente.sql
		Objetivo.................: Cadastrar um usuário na tabela Cliente
		Autor....................: Gabriel Felix
		Data.....................: 10/08/2026
		Ex.......................: BEGIN TRANSACTION

		                           DBCC FREEPROCCACHE
								   DBCC DROPCLEANBUFFERS

								   DECLARE @Retorno INT,
								           @IdBaseParaReseed INT,
										   @DataInicio DATETIME = GETDATE();

								   SELECT  TOP 1 @IdBaseParaReseed = cl.Id
								       FROM [dbo].[Cliente] AS cl WITH(NOLOCK)
									   ORDER BY cl.Id DESC;

								   SELECT  TOP 3 cl.Id,
								                 cl.Nome,
												 cl.Documento,
												 cl.Telefone,
												 cl.TipoCliente
								       FROM [dbo].[Cliente] AS cl WITH(NOLOCK)
									   ORDER BY cl.Id DESC;
								  
								   EXEC @Retorno = [dbo].[SP_CadastrarCliente]	@NomeCliente = 'Gabriel Felix',
																				@DocumentoCliente = '10679691449',
																				@TelefoneCliente = '84992268147',
																				@TipoCliente = 0;

								   SELECT  TOP 3 cl.Id,
								                 cl.Nome,
												 cl.Documento,
												 cl.Telefone,
												 cl.TipoCliente
									   FROM [dbo].[Cliente] AS cl WITH(NOLOCK)
									   ORDER BY cl.Id DESC;

								   SELECT  @Retorno As Retorno,
										   DATEDIFF(MILLISECOND, @Datainicio, GETDATE()) As TempoExecucao
		
								   ROLLBACK TRANSACTION 
								   
								   DBCC CHECKIDENT('Cliente', RESEED, @IdBaseParaReseed);

		Retorno..................: @IdCadastrado - Sucesso
		                           -1 - Cliente já cadastrado
								   -2 - Tipo de Cliente inválido
								   -3 - Documento do cliente fora do padrão de caracteres
								   -4 - Erro de cadastro
	*/
	BEGIN
		-- Validar se não existe nenhum Cliente com o mesmo documento
		IF EXISTS (
		              SELECT  TOP 1 1
						  FROM [dbo].[Cliente] AS cl WITH(NOLOCK)
						  WHERE cl.Documento = @DocumentoCliente
		          )
			BEGIN
				RETURN -1
			END

		-- Validar se o TipoCliente é 1 ou 0
		IF @TipoCliente > 1 OR @TipoCliente < 0
			BEGIN
				RETURN -2
			END

		-- Validar se o documento se não é uma empresa e se o documento possui 11 caracteres
		IF @TipoCliente = 0 
			BEGIN
				IF LEN(@DocumentoCliente) <> 11
					BEGIN 
						RETURN -3
					END
			END

		-- Validar se o documento se é uma empresa e se o documento possui 14 caracteres
		IF @TipoCliente = 1 
			BEGIN
				IF LEN(@DocumentoCliente) <> 14
					BEGIN 
						RETURN -3
					END
			END

		DECLARE @IdCadastrado INT

	    -- Executar o comando
		BEGIN TRANSACTION 

			INSERT INTO [dbo].[Cliente] (Nome, Documento, Telefone, TipoCliente)
				VALUES (@NomeCliente, @DocumentoCliente, @TelefoneCliente, @TipoCliente);

			SET @IdCadastrado = SCOPE_IDENTITY()

			IF @@ERROR <> 0
				BEGIN
					RETURN -4
					ROLLBACK TRANSACTION
				END

			COMMIT TRANSACTION
			RETURN @IdCadastrado

		RETURN 0
	END
GO
