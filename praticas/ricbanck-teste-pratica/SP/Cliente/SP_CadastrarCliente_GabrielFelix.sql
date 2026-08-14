USE RicBankTeste;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_CadastrarCliente_GabrielFelix]
	@Documento VARCHAR(14),
	@Nome VARCHAR(200),
	@DDDMovel CHAR(2) = NULL,
	@TelefoneMovel VARCHAR(15) = NULL,
	@DDDFixo CHAR(2) = NULL,
	@TelefoneFixo VARCHAR(15) =NULL,
	@DataNascimento DATE,
	@Email VARCHAR(254),
	@Logradouro VARCHAR(100),
	@Numero VARCHAR(10),
	@Complemento VARCHAR(100) = NULL,
	@Bairro  VARCHAR(50),
	@Cidade VARCHAR(40),
	@Uf CHAR(2),
	@Cep CHAR(8)
	AS
	/*
		Documentacao
		Arquivo Fonte............: SP_CadastrarCliente_GabrielFelix.sql
		Objetivo.................: Cadastrar de um Cliente
		Autor....................: Gabriel Felix
		Data.....................: 14/08/2026
		Ex.......................: BEGIN TRANSACTION
								     
									 DBCC FREEPROCCACHE
									 DBCC DROPCLEANBUFFERS
									 	
									 DECLARE @Retorno INT,
										     @DataInicio DATETIME = GETDATE(),
											 @IdBaseReseed INT;
									 
									 SELECT  TOP 1 @IdBaseReseed = Id
									     FROM [dbo].[Cliente] WITH(NOLOCK)
										 ORDER BY Id DESC;
									 
									 SELECT  TOP 3 Id,
									               NomeCompleto,
												   Documento,
												   Email
										 FROM [dbo].[Cliente] WITH(NOLOCK)
										 ORDER BY Id DESC;
									 
									 EXEC @Retorno = [dbo].[SP_CadastrarCliente_GabrielFelix] @Documento = '10779679147',
									                                                          @Nome = 'Gabriel Felix',
																							  @DataNascimento = '20/06/2001',
																							  @Email = 'gabrielfelix099@hotmail.com',
																							  @Logradouro = 'R. Professora Josefa Di Lourenzo',
																							  @Numero = '624',
																							  @Bairro = 'Portal do Sol',
																							  @Cidade = 'João Pessoa',
																							  @Uf = 'PB',
																							  @Cep = '58046701';
									 SELECT  TOP 3 Id,
									               NomeCompleto,
												   Documento,
												   Email
										 FROM [dbo].[Cliente] WITH(NOLOCK)
										 ORDER BY Id DESC;

									 SELECT  @Retorno As RetornoExecucao,
										     DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoDeExecucao
								   
								   ROLLBACK TRANSACTION

								   DBCC CHECKIDENT('Cliente', RESEED, @IdBaseReseed)
		
		Retorno..................: @IdClienteCadastrado - Sucesso
		                           -1 - Documento já cadastrado
								   -2 - Email já cadastrado
								   -3 - Quantidade de caracteres do Documento fora do padrao
								   -4 - Quantidade de caracteres do Cep fora do padrao
								   -5 - Erro de cadastro
	*/
	BEGIN
		-- Validar se o Documento ja esta cadastrado
		IF EXISTS (
				      SELECT  TOP 1 1
					      FROM [dbo].[Cliente] AS cl WITH(NOLOCK)
						  WHERE cl.Documento = @Documento
				  )
			BEGIN
				RETURN -1
			END

		-- Validar se o Email ja esta cadastrado
		IF EXISTS (
				      SELECT  TOP 1 1
					      FROM [dbo].[Cliente] AS cl WITH(NOLOCK)
						  WHERE cl.Email = @Email
				  )
			BEGIN
				RETURN -2
			END

		-- Validar quantidade de caracteres  do Documento para CPF e CNPJ
		IF LEN(@Documento) NOT IN (11, 14)
			OR @Documento LIKE '%[^0-9]%'
			BEGIN
				RETURN -3
			END

		-- Validar quantidade de caracteres do CEP
		IF LEN(@Cep) <> 8
			OR @CEP LIKE '%[^0-9]%'
			BEGIN
				RETURN -4
			END
			
		-- Realizar Insert para cadastro
		BEGIN TRANSACTION 

			INSERT INTO [dbo].[Cliente] (Documento, NomeCompleto, DDDMovel, TelefoneMovel, DDDFixo, TelefoneFixo, DataNascimento, Email, Logradouro, Numero, Complemento, Bairro, Cidade, Uf, Cep, CriadoPor, CriadoEm)
				VALUES (@Documento, @Nome, @DDDMovel, @TelefoneMovel, @DDDFixo, @TelefoneFixo, @DataNascimento, @Email, @Logradouro, @Numero, @Complemento, @Bairro, @Cidade, @Uf, @Cep, SUSER_SNAME(), GETDATE());

			-- Verificar se houve algum erro
			IF @@ERROR <> 0
				BEGIN
					RETURN -5 
					ROLLBACK TRANSACTION 
				END

			-- Declarar variavel para retorno do Id
			DECLARE @IdClienteCadastrado INT = SCOPE_IDENTITY();

		COMMIT TRANSACTION

		RETURN @IdClienteCadastrado		
	END
GO
	