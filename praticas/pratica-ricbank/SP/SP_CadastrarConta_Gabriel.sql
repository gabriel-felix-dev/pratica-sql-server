USE RicBankTeste;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_CadastrarConta_Gabriel] 
	@IdCliente INT,
	@IdAgencia INT,
	@IdSituacaoConta TINYINT,
	@TipoConta CHAR(2),
	@NumeroConta VARCHAR(20),
	@IdTaxaRendimento INT = NULL,
	@DiaRendimento TINYINT = NULL
	AS
	/*
		Documetacao
		Arquivo Fonte............: SP_CadastrarConta_Gabriel.sql
		Objetivo.................: Cadastrar de uma Conta
		Autor....................: Gabriel Felix
		Data.....................: 21/08/2026
		Ex.......................: BEGIN TRANSACTION
								     
									 DBCC FREEPROCCACHE
									 DBCC DROPCLEANBUFFERS
									 	
									 DECLARE @Retorno INT,
										     @DataInicio DATETIME = GETDATE(),
											 @IdBaseReseed INT;
									 
									 SELECT  TOP 1 @IdBaseReseed = Id
									     FROM [dbo].[Conta] WITH(NOLOCK)
										 ORDER BY Id DESC;
									 
									 SELECT  TOP 2 *
										 FROM [dbo].[Conta] WITH(NOLOCK)
										 ORDER BY Id DESC;
									 
									 EXEC @Retorno = [dbo].[SP_CadastrarConta_Gabriel] @IdCliente = 1,
																					   @IdAgencia = 1,
																					   @IdSituacaoConta = 1,
																					   @TipoConta = CP,
																					   @NumeroConta = '000202020-2',
																					   @IdTaxaRendimento = 1,
																					   @DiaRendimento = 5;
									 SELECT  TOP 2 *
										 FROM [dbo].[Conta] WITH(NOLOCK)
										 ORDER BY Id DESC;
									 
									 SELECT  *
										 FROM [dbo].[Saldo] WITH(NOLOCK)
										 WHERE IdConta = @Retorno;

									 SELECT  @Retorno As RetornoExecucao,
										     DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoDeExecucao
								   
								   ROLLBACK TRANSACTION

								   DBCC CHECKIDENT('Conta', RESEED, @IdBaseReseed)
		
		Retorno..................: @IdContaCastrada - Sucesso
		                           -1 - Cliente nao existe
								   -2 - Agencia nao existe
								   -3 - SituacaoConta nao existe
								   -4 - Conta nao existe
								   -5 - IdTaxaRendimento e DiaRendiemento devem ser preenchidos para conta poupanca (CP)
								   -6 - TaxaRendimento nao existe
								   -7 - DiaRendimento deve ser entre 1 e 31
								   -8 - Erro no cadastro da Conta
								   -9 - Erro no cadastro do Saldo
	*/
	BEGIN
		--Declarar variaveis
		DECLARE @IdContaCastrada INT; -- Armazena a Conta recem casdastrada

		--Validar se o Cliente existe
		IF NOT EXISTS (
			                SELECT TOP 1 1
								FROM [dbo].[Cliente] WITH(NOLOCK)
								WHERE Id = @IdCliente
						)
			BEGIN
				RETURN -1
			END

		--Validar se a agencia existe
		IF NOT EXISTS (
			                SELECT TOP 1 1
								FROM [dbo].[Agencia] WITH(NOLOCK)
								WHERE Id = @IdAgencia
						)
			BEGIN
				RETURN -2
			END	

		--Validar se a SituacaoConta existe
		IF NOT EXISTS (
			                SELECT TOP 1 1
								FROM [dbo].[SituacaoConta] WITH(NOLOCK)
								WHERE Id = @IdSituacaoConta
						)
			BEGIN
				RETURN -3
			END	

		--Validar se o TipoConta e CP ou CC
		IF LEN(@TipoConta) <> 2
			OR @TipoConta NOT IN ('CC', 'CP')
			BEGIN	
				RETURN -4
			END
		
		-- Validar se IdTaxaRendimento e DiaRendimento foram preenchidos para caso de conta poupanca (CP)
		IF @TipoConta = 'CP'
			IF @IdTaxaRendimento IS NULL
				AND @DiaRendimento IS NULL
				BEGIN
					RETURN -5
				END

		--Validar se o IdTaxaRendimento existe se ele for preenchido
		IF @IdTaxaRendimento IS NOT NULL
			IF NOT EXISTS (
			                SELECT TOP 1 1
								FROM [dbo].[TaxaRendimento] WITH(NOLOCK)
								WHERE Id = @IdTaxaRendimento
						)
			BEGIN
				RETURN -6
			END
			
		--Validar se o DiaRendimento e valido se ele for preenchido
		IF @DiaRendimento IS NOT NULL
			IF @DiaRendimento < 0
				OR @DiaRendimento > 31
			BEGIN
				RETURN -7
			END

		--Inserir os dados em Conta
		BEGIN TRANSACTION
			INSERT INTO [dbo].[Conta] (IdCliente, IdAgencia, IdSituacaoConta, TipoConta, Numero, DataCriacao, IdTaxaRendimento, DiaRendimento, CriadoPor)
				VALUES (@IdCliente, @IdAgencia, @IdSituacaoConta, @TipoConta, @NumeroConta, GETDATE(), @IdTaxaRendimento, @DiaRendimento, SUSER_SNAME());

			--Validar se teve algum erro de insercao em Conta
			IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION
					RETURN -8
				END

		COMMIT TRANSACTION
		
		--Armazena o Id da conta criada
		SET @IdContaCastrada = SCOPE_IDENTITY();

		--Criar um novo Saldo
		BEGIN TRANSACTION
			INSERT INTO [dbo].[Saldo] (IdConta, DataSaldo, SaldoInicial, MovimentacaoCredito, MovimentacaoDebito)
				VALUES (@IdContaCastrada, CAST(GETDATE() AS DATE), 0, 0, 0);

		--Validar se houve algum erro na criação
			IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION
					RETURN -9
				END

		COMMIT TRANSACTION

		--Retornar o Id da nova Conta

		RETURN @IdContaCastrada
	END
GO
