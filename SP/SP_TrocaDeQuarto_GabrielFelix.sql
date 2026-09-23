USE hotel_avaliacao;
GO

IF EXISTS (
             SELECT  1
				 FROM [dbo].[sysobjects]
				 WHERE Id = OBJECT_ID(N'[dbo].[SP_TrocaDeQuarto_GabrielFelix]')
					AND TYPE = 'P'
		  )
	DROP PROCEDURE [dbo].[SP_TrocaDeQuarto_GabrielFelix];
GO

CREATE PROCEDURE [dbo].[SP_TrocaDeQuarto_GabrielFelix] 
	@IdReserva INT,
	@NovoQuarto VARCHAR(10)
	AS 
	/*
		Documentacao
		Arquivo Fonte............: SP_TrocaDeQuarto_GabrielFelix.sql
		Objetivo.................: Realizar a mudança de quarto de um hospede
		Autor....................: Gabriel Felix
		Data.....................: 23/09/2026
		Ex.......................: BEGIN TRANSACTION
									 
									 DBCC FREEPROCCACHE
									 DBCC DROPCLEANBUFFERS
									 
									 DECLARE @Retorno INT,
											 @DataInicio DATETIME = GETDATE(),
											 @IdReferenciaReseedReserva INT = (SELECT  TOP 1 Id FROM [dbo].[Reserva] WITH(NOLOCK) ORDER BY Id DESC),
											 @IdReferenciaReseedHospedagem INT = (SELECT  TOP 1 Id FROM [dbo].[Hospedagem] WITH(NOLOCK) ORDER BY Id DESC);

									 SELECT  TOP 1 *
										 FROM [dbo].[Reserva] WITH(NOLOCK)
										 WHERE Id = 101;
									 
									 SELECT  TOP 1 *
										 FROM [dbo].[Hospedagem] WITH(NOLOCK)
										 WHERE IdReserva = 101;

									 EXEC @Retorno = [dbo].[SP_TrocaDeQuarto_GabrielFelix] @IdReserva = 101,
									                                                       @NovoQuarto = '110';

									 SELECT  TOP 1 *
										 FROM [dbo].[Reserva] WITH(NOLOCK)
										 WHERE Id = 101;

									 SELECT  TOP 1 *
										 FROM [dbo].[Hospedagem] WITH(NOLOCK)
										 WHERE IdReserva = 101;

									 SELECT  TOP 1 *
										 FROM [dbo].[Reserva] WITH(NOLOCK)
										 ORDER BY Id DESC;

									 SELECT  TOP 1 *
										 FROM [dbo].[Hospedagem] WITH(NOLOCK)
										 ORDER BY Id DESC;
					
									 SELECT  @Retorno As Retorno,
									         DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;

		                           ROLLBACK TRANSACTION

								   DBCC CHECKIDENT('Reserva', RESEED, @IdReferenciaReseedReserva);
								   DBCC CHECKIDENT('Hospedagem', RESEED, @IdReferenciaReseedHospedagem);

		Retornos.................: @IdNovaHospedagem - Sucesso
									     		  -1 - Reserva não encontrada
												  -2 - Quarto não encontrado
												  -3 - A reserva não está em CheckIn
												  -4 - O quarto não está ativo
												  -5 - O Quarto não está disponível para mudança
												  -6 - Erro ao realizar o checkout do quarto atual
												  -7 - Erro em registrar a nova reserva
												  -8 - Erro em registrar a nova hospedagem
	*/
	BEGIN
		-- Validar se a reserva existe
		IF NOT EXISTS (
						 SELECT  TOP 1 1
							 FROM [dbo].[Reserva] WITH(NOLOCK)
							 WHERE Id = @IdReserva
					  )
			RETURN -1

		-- Validar se o quarto existe
		IF NOT EXISTS (
		                 SELECT  TOP 1 1
							 FROM [dbo].[Quarto] WITH(NOLOCK)
							 WHERE Numero = @NovoQuarto
					  )
			RETURN -2

		-- Validar se o hospede está com checkin 
		IF (
		      SELECT  Situacao
				  FROM [dbo].[Reserva] WITH(NOLOCK)
				  WHERE Id = @IdReserva
		   ) <> 'CHECKIN'
		    RETURN -3
		
        -- Validar se o quarto que o hospede quer esta ativo
		IF (
		      SELECT  Ativo
				  FROM [dbo].[Quarto] WITH(NOLOCK)
				  WHERE Numero = @NovoQuarto
		   ) <> 1
		   RETURN -4
		
		-- Armazenar as datas de entrada e saida da reserva atual
		DECLARE @DataHoje DATE = CAST(GETDATE() AS DATE),
				@DataSaida DATE = (
									 SELECT  DataSaida
					                     FROM [dbo].[Reserva] WITH(NOLOCK)
									     WHERE Id = @IdReserva
								   );
        
		-- Validar se o quarto que o hospede que trocar está livre 
		IF (
		      SELECT [dbo].[FNC_ValidaDisponibilidadeParaReserva_GabrielFelix] (@NovoQuarto, 
		                                                                        @DataHoje,  
																			    @DataSaida)
		   ) <> 0
			RETURN -5		

		-- Variavel para armazenar o retorno da Procedure de Checkout
		DECLARE @RetornoProcCheckout INT;

        -- Encerrar a ocupação do quarto
		EXEC @RetornoProcCheckout = [dbo].[SP_RealizarCheckout_GabrielFelix] @IdReserva = @IdReserva;

		-- Validar retorno do Checkout
		IF @RetornoProcCheckout <> 0
			RETURN -6

		-- Armazenar o Id do quarto informado
		DECLARE @IdQuarto INT = (SELECT  Id FROM [dbo].[Quarto] WITH(NOLOCK) WHERE Numero = @NovoQuarto),
		        @IdHospede INT = (SELECT  IdHospede FROM [dbo].[Reserva] WITH(NOLOCK) WHERE Id = @IdReserva);

		-- Cadastrar a reserva para o novo quarto
		BEGIN TRANSACTION
		
		INSERT INTO [dbo].[Reserva] (IdHospede, IdQuarto, DataReserva, DataEntrada, DataSaida, Situacao) 
			VALUES (@IdHospede, @IdQuarto, GETDATE(), @DataHoje, @DataSaida, 'CHECKIN')

		-- Validar se houve erro
		IF @@ERROR <> 0 
			BEGIN 
				ROLLBACK TRANSACTION
				RETURN -7
			END

		COMMIT TRANSACTION

		-- Armazenar o Id da nova reserva
		DECLARE @IdNovaReserva INT = SCOPE_IDENTITY();
		
		-- Registrar hospegadem
		BEGIN TRANSACTION

		INSERT INTO [dbo].[Hospedagem] (IdReserva, DataCheckin)
			VALUES (@IdNovaReserva, GETDATE());

		-- Valida se houve erro
		IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION
				RETURN -8
			END

		COMMIT TRANSACTION

		-- Armazenar o Id da nova hospedagem
		DECLARE @IdNovaHospedagem INT = SCOPE_IDENTITY();

		RETURN @IdNovaHospedagem
	END
GO
