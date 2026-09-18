/* 
=====================================================
AVALIAÇÃO BANCO DE DADOS AVANÇADO
Aluno: Gabriel Felix Pinto

===================================================== */

/* 
=====================================================
1. VIEWS
===================================================== */

--código

USE hotel_avaliacao;
GO

-- ==================================================
-- Primeira View

IF EXISTS (
             SELECT  1
				 FROM [dbo].[sysobjects]
				 WHERE Id = OBJECT_ID (N'[dbo].[VW_ConsultaHospedagens_GabrielFelix]')
					AND TYPE = 'V'
		  )
	DROP VIEW [dbo].[VW_ConsultaHospedagens_GabrielFelix];
	GO

CREATE VIEW [dbo].[VW_ConsultaHospedagens_GabrielFelix]
	AS
	/*
		Documentacao
		Arquivo Fonte............: 106-48-gabriel-felix.sql
		Objetivo.................: Retornar a relação de hospedagens em andamento 
		Autor....................: Gabriel Felix
		Data.....................: 14/09/2026
		Ex.......................: SELECT  TOP 10 * 
									   FROM [dbo].[VW_ConsultaHospedagens_GabrielFelix];
	*/
	SELECT  qa.Numero As Quarto,
	        ho.Nome As Hospede,
			re.DataEntrada,
			re.DataSaida,
			re.Situacao As SituacaoHospedagem
	    FROM [dbo].[Hospede] AS ho WITH(NOLOCK)
			INNER JOIN [dbo].[Reserva] AS re WITH(NOLOCK) -- Join de Hospede com Reserva
				ON re.IdHospede = ho.Id
			INNER JOIN [dbo].[Quarto] AS qa WITH(NOLOCK) -- Join de Quarto com Reserva
				ON qa.Id = re.IdQuarto
			INNER JOIN [dbo].[Hospedagem] AS hp WITH(NOLOCK) -- Join de Hospedagem com Reserva 
				ON hp.IdReserva = re.Id
		WHERE hp.DataCheckin <= GETDATE()
			AND hp.DataCheckout IS NULL

GO

-- ==================================================
-- Segunda View

IF EXISTS (
             SELECT  1
				 FROM [dbo].[sysobjects]
				 WHERE Id = OBJECT_ID (N'[dbo].[VW_HistoricoReservas_GabrielFelix]')
					AND TYPE = 'V'
		  )
	DROP VIEW [dbo].[VW_HistoricoReservas_GabrielFelix] 
	GO

CREATE VIEW [dbo].[VW_HistoricoReservas_GabrielFelix] 
	AS
	/*
		Documentacao
		Arquivo Fonte............: 106-48-gabriel-felix.sql
		Objetivo.................: Retornar o histórico de reservas 
		Autor....................: Gabriel Felix
		Data.....................: 14/09/2026
		Ex.......................: SELECT TOP 10 *
			                           FROM [dbo].[VW_HistoricoReservas_GabrielFelix]
									   WHERE Situacao = '...';
	*/
	SELECT  ho.Nome As Hospede,
	        qa.Numero As Quarto,
			CAST(re.DataReserva AS DATE) As DataReserva,
			CAST(re.DataEntrada AS DATE) As DataEntrada,
			CAST(re.DataSaida AS DATE) As DataSaida,
			re.Situacao
		FROM [dbo].[Reserva] AS re WITH(NOLOCK)
			INNER JOIN [dbo].[Hospede] AS ho WITH(NOLOCK) -- Join de Hospede com Reserva
				ON ho.Id = re.IdHospede
			INNER JOIN [dbo].[Quarto] AS qa WITH(NOLOCK) -- Join de Quarto com Reserva
				ON qa.Id = re.IdQuarto
	GO

/*
=====================================================
2. FUNCTIONS
===================================================== */

-- código

-- ==================================================
-- Primeira Function

IF EXISTS (
             SELECT  1
				 FROM [dbo].[sysobjects]
				 WHERE Id = OBJECT_ID (N'[dbo].[FNC_ValidaDisponibilidadeParaReserva_GabrielFelix]')
					AND TYPE = 'FN'
		  )
	DROP FUNCTION [dbo].[FNC_ValidaDisponibilidadeParaReserva_GabrielFelix]
	GO

CREATE FUNCTION [dbo].[FNC_ValidaDisponibilidadeParaReserva_GabrielFelix] (@NumeroQuarto VARCHAR(10), @DataEntrada DATE, @DataSaida DATE)
	RETURNS TINYINT
	AS
	/*
		Documentacao
		Arquivo Fonte............: 106-48-gabriel-felix.sql
		Objetivo.................: Retornar se um quarto está disponível para reserva com base em uma data de entrada e saída 
		Autor....................: Gabriel Felix
		Data.....................: 14/09/2026
		Ex.......................: DBCC FREEPROCCACHE
		                           DBCC DROPCLEANBUFFERS

								   DECLARE @DataInicio DATETIME = GETDATE();

		                           SELECT  [dbo].[FNC_ValidaDisponibilidadeParaReserva_GabrielFelix] ('304', '18/09/2026', '19/09/2026') As Resultado;					

								   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;

		Retornos.................: 0 - Sucesso
		                           1 - Erro: Quarto não existe
								   2 - Erro: A data de entrada deve ser maior que a data de hoje
								   3 - Erro: A data de saída é menor que a data de hoje
								   4 - Erro: A data de saída é menor ou igual que a data de entrada
								   5 - Erro: O quarto já está ocupado na data pretendida

	*/
	BEGIN	
		-- Declarar variavel para armazenar a data de hoje
		DECLARE @Datahoje DATE = CAST(GETDATE() AS DATE);

		-- Validar se o quarto existe
		IF NOT EXISTS (
						 SELECT  TOP 1 1
							 FROM [dbo].[Quarto] WITH (NOLOCK)
							 WHERE Numero = @NumeroQuarto
		              )
		  RETURN 1

		-- Validar se a data de entrada é menor que hoje
		IF @DataEntrada < @Datahoje
	      RETURN 2 

		-- Validar se a data de saida é menor que o dia de hoje
		IF @DataSaida < @Datahoje
		  RETURN 3

		-- Validar se a data de saída é menor ou igual a data de entrada
		IF @DataSaida <= @DataEntrada
		  RETURN 4

		-- Armazena o Id do quarto informado

		DECLARE @IdQuarto TINYINT = ( -- Busca o Id do quarto para armazenar na variavel
		                               SELECT  Id 
										   FROM [dbo].[Quarto] WITH(NOLOCK)
										   WHERE Numero = @NumeroQuarto
									);		

		-- Validar se a data esta disponivel
		IF EXISTS (
		             SELECT  *
						 FROM [dbo].[Reserva] WITH(NOLOCK)
						 WHERE Situacao <> 'CANCELADA'
							AND IdQuarto = @IdQuarto
						    AND (@DataEntrada BETWEEN DataEntrada AND DataSaida  
							OR @DataSaida <= DataSaida) 
				  )
		  RETURN 5
		
		-- Sucesso - Quarto disponivel
		RETURN 0
	END
	GO

-- ==================================================
-- Segunda Function

IF EXISTS (
             SELECT  * 
				 FROM [dbo].[sysobjects]
				 WHERE Id = OBJECT_ID(N'[dbo].[FNC_QuantidadeDeQuartosOcupados_GabrielFelix]')
					AND TYPE = 'IF'
		  )
	DROP FUNCTION [dbo].[FNC_QuantidadeDeQuartosOcupados_GabrielFelix];
GO

CREATE FUNCTION [dbo].[FNC_QuantidadeDeQuartosOcupados_GabrielFelix] (@DataReferencia DATE)
	RETURNS TABLE
	AS
	/*
		Documentacao
		Arquivo Fonte............: 106-48-gabriel-felix.sql
		Objetivo.................: Retornar quantidade de quartos ocupados 
		Autor....................: Gabriel Felix
		Data.....................: 14/09/2026
		Ex.......................: DBCC FREEPROCCACHE
		                           DBCC DROPCLEANBUFFERS

								   DECLARE @DataInicio DATETIME = GETDATE();

		                           SELECT  *
								       FROM [dbo].[FNC_QuantidadeDeQuartosOcupados_GabrielFelix] ('14/09/2026');					

								   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;

		Retornos.................: Quantidade de Quartos Ocupados - Sucesso
	*/
		RETURN ( 
				  SELECT COUNT(IdQuarto) As QuantidadeDeQuartosOcupados
					  FROM [dbo].[Reserva]
					  WHERE DataEntrada = @DataReferencia
						  AND DataSaida > @DataReferencia
						  AND (Situacao = 'CANCELADA' OR Situacao = 'RESERVADA')
			   )
GO

/* 
=====================================================
3. PROCEDURES
===================================================== */

-- código

-- ==================================================
-- Primeira Procedure

IF EXISTS (
			 SELECT  *
				 FROM [dbo].[sysobjects]
				 WHERE Id = OBJECT_ID(N'[dbo].[SP_CadastraReserva_GabrielFelix]')
				   AND TYPE = 'P'
          )
	DROP PROCEDURE [dbo].[SP_CadastraReserva_GabrielFelix];
GO

CREATE PROCEDURE [dbo].[SP_CadastraReserva_GabrielFelix]
	@IdHospede INT,
	@IdQuarto SMALLINT,
	@DataEntrada DATE,
	@DataSaida DATE
	AS
	/*
		Documentacao
		Arquivo Fonte............: 106-48-gabriel-felix.sql
		Objetivo.................: Realizar o cadastro de uma reserva
		Autor....................: Gabriel Felix
		Data.....................: 15/09/2026
		Ex.......................: BEGIN TRANSACTION 

									   DBCC FREEPROCCACHE
									   DBCC DROPCLEANBUFFERS

									   DECLARE @Retorno INT,
											   @UltimoIdCadastrado INT,
											   @DataInicio DATETIME = GETDATE();

									   SELECT  TOP 1 @UltimoIdCadastrado = Id
										   FROM [dbo].[Reserva] WITH(NOLOCK)
										   ORDER BY Id DESC

									   EXEC @Retorno = [dbo].[SP_CadastraReserva_GabrielFelix] @IdHospede = 1,
																							   @IdQuarto = 54,
																							   @DataEntrada = '19/09/2026',
																							   @DataSaida = '20/09/2026';									 

									   SELECT  @Retorno As Retorno;

									   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;

								   ROLLBACK TRANSACTION
								   
								   DBCC CHECKIDENT('Reserva', RESEED, @UltimoIdCadastrado);
		
		Retornos.................: @IdReservaCadastrada - Sucesso
		                                             -1 - Erro: Hospede não cadastrado
													 -2 - Erro: Quarto não cadastrado
													 -3 - Erro: Período de reserva solicidato inválido
													 -4 - Erro: Erro ao cadastro da Reserva
	*/
	BEGIN
		-- Valida se o Hospede esta cadastrado
		IF NOT EXISTS ( 
						 SELECT  TOP 1 1
							 FROM [dbo].[Hospede] WITH(NOLOCK)
							 WHERE Id = @IdHospede
					  )
			RETURN -1

		-- Valida se o Quarto existe
		IF NOT EXISTS (
						SELECT  TOP 1 1
								FROM [dbo].[Quarto] WITH(NOLOCK)
								WHERE @IdQuarto = Id
		              )
			RETURN -2
		
		-- Pegar o quarto
		DECLARE @NumeroQuarto VARCHAR(10) = (
		                                       SELECT  Numero
												   FROM [dbo].[Quarto] WITH(NOLOCK)
												   WHERE Id = @IdQuarto
											);

		-- Validar se o período é valido
		IF  (SELECT  [dbo].[FNC_ValidaDisponibilidadeParaReserva_GabrielFelix] (@NumeroQuarto, 
																				@DataEntrada, 
																				@DataSaida)
			) <> 0
			RETURN -3

		BEGIN TRANSACTION

		-- Cria na tabela Reserva uma reserva
		INSERT INTO [dbo].[Reserva] (IdHospede,IdQuarto, DataReserva, DataEntrada, DataSaida, Situacao)
			VALUES (@IdHospede, @IdQuarto, GETDATE(), @DataEntrada,@DataSaida, 'RESERVADA');

		-- Valida se houve algum erro
		IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION
				RETURN -4
			END

		COMMIT TRANSACTION

		-- Declara variável para pegar o último id cadastrado 
		DECLARE @IdReservaCadastrada INT = SCOPE_IDENTITY();

		RETURN @IdReservaCadastrada
	END
GO

-- ==================================================
-- Segunda Procedure

IF EXISTS (
             SELECT  1
				 FROM [dbo].[sysobjects]
				 WHERE Id = OBJECT_ID(N'[dbo].[SP_CancelarReserva_GabrielFelix]')
					AND TYPE = 'P'
		  )
	DROP PROCEDURE [dbo].[SP_CancelarReserva_GabrielFelix];
GO

CREATE PROCEDURE [dbo].[SP_CancelarReserva_GabrielFelix]
	@IdReserva INT
	AS
	/*
		Documentacao
		Arquivo Fonte............: 106-48-gabriel-felix.sql
		Objetivo.................: Realizar a cancelar de uma reserva
		Autor....................: Gabriel Felix
		Data.....................: 15/09/2026
		Ex.......................: BEGIN TRANSACTION 

									   DBCC FREEPROCCACHE
									   DBCC DROPCLEANBUFFERS

									   DECLARE @Retorno TINYINT,
											   @DataInicio DATETIME = GETDATE();

									   SELECT  TOP 1 *
										   FROM [dbo].[Reserva]
										   WHERE Id = 89;

									   EXEC @Retorno = [dbo].[SP_CancelarReserva_GabrielFelix] @IdReserva = 89;										   
									   
									   SELECT  TOP 1 *
										   FROM [dbo].[Reserva]
										   WHERE Id = 89;

									   SELECT  @Retorno As Retorno;

									   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;

								   ROLLBACK TRANSACTION
		
		Retornos.................:  0 - Sucesso
		                           -1 - Erro: Reserva não existe
								   -2 - Erro: O status é diferente de 'Reservada'
								   -3 - Erro: Erro ao alterar a reserva
	*/
	BEGIN
	    -- Validar se o @IdReserva existe
		IF NOT EXISTS (
					     SELECT  TOP 1 1
						     FROM [dbo].[Reserva] WITH(NOLOCK)
						     WHERE @IdReserva = Id
		              )
			RETURN -1 

		-- Validar se a reserva possui um status diferente de Reservado
		IF EXISTS (
		             SELECT  TOP 1 1
						 FROM [dbo].[Reserva] WITH(NOLOCK)
						 WHERE @IdReserva = Id
							AND Situacao <> 'RESERVADA'
				  )
			RETURN -2 

		BEGIN TRANSACTION

		-- Realiza a alteração da situacão da reserva para CANCELADA
		UPDATE Reserva 
			SET Situacao = 'CANCELADA'
			WHERE Id = @IdReserva;	    
		
		-- Valida se houve algum erro
		IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION
				RETURN -3
			END
		
		COMMIT TRANSACTION
		
		RETURN 0
	END
GO

-- ==================================================
-- Terceira Procedure

IF EXISTS (
		    SELECT  1
				FROM [dbo].[sysobjects]
				WHERE Id = OBJECT_ID(N'[dbo].[SP_RealizarCheckin_GabrielFelix]')
					AND TYPE = 'P'
          )
	DROP PROCEDURE [dbo].[SP_RealizarCheckin_GabrielFelix];
GO

CREATE PROCEDURE [dbo].[SP_RealizarCheckin_GabrielFelix]
	@IdReserva INT,
	@ObservacaoHospedagem VARCHAR(255) = NULL
	AS
	/*
		Documentacao
		Arquivo Fonte............: 106-48-gabriel-felix.sql
		Objetivo.................: Realizar o checkin de uma reserva
		Autor....................: Gabriel Felix
		Data.....................: 16/09/2026
		Ex.......................: BEGIN TRANSACTION
									 
									 DBCC FREEPROCCACHE 
									 DBCC DROPCLEANBUFFERS

									 DECLARE @Retorno INT,
									         @DataInicio DATETIME = GETDATE();

									 SELECT  TOP 1 *
										 FROM [dbo].[Reserva] WITH(NOLOCK)
										 WHERE Id = 76
									 
									 EXEC @Retorno = [dbo].[SP_RealizarCheckin_GabrielFelix] @IdReserva = 76;

									 SELECT  TOP 1 *
										 FROM [dbo].[Reserva] WITH (NOLOCK)
										 WHERE Id = 76

									 SELECT  TOP 1 *
										 FROM [dbo].[Hospedagem] WITH (NOLOCK)
										 WHERE IdReserva = 76

									 DECLARE @UltimoIdRegistrado INT = (SELECT  TOP 1 Id FROM [dbo].[Hospedagem] ORDER BY Id DESC);

									 SELECT  @Retorno As Retorno,
									         DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao

								   ROLLBACK TRANSACTION 

								   DBCC CHECKIDENT('Hospedagem', RESEED, @UltimoIdRegistrado);
									
		Retorno..................:  0 - Sucesso
		                           -1 - Erro: A Reserva não existe
								   -2 - Erro: A Reserva possui uma situacao diferente de 'RESERVADA'
								   -3 - Erro: A Reserva está fora da Data de Entrada
								   -4 - Erro: Falha na alteração
								   -5 - Erro: Falha no cadastro da hospedagem
	*/
	BEGIN
		-- Validar se a reserva existe
		IF NOT EXISTS (
		                 SELECT TOP 1 1
							 FROM [dbo].[Reserva] WITH(NOLOCK)
							 WHERE Id = @IdReserva
					  )
			RETURN -1 

		-- Validar se a Situaco da reserva é diferente de 'RESERVADA'
		IF EXISTS (
		             SELECT  TOP 1 1
						 FROM [dbo].[Reserva] WITH(NOLOCK)
						 WHERE Id = @IdReserva 
							AND Situacao <> 'RESERVADA'
		          )
			RETURN -2
		
		-- Declara data e hora do momento

		DECLARE @DataHoje DATE = CAST(GETDATE() AS DATE);

		-- Validar a DataEntrada é igual a data da tentativa de CheckIn

		IF @DataHoje <> (
						  SELECT  TOP 1 DataEntrada
							  FROM [dbo].[Reserva] WITH(NOLOCK)
							  WHERE Id = @IdReserva
						)
			RETURN -3

		-- Abre transação para update em Reserva
		BEGIN TRANSACTION

		-- Alterar a Situacao da Reserva

		UPDATE [dbo].[Reserva]
			SET Situacao = 'CHECKIN'
			WHERE Id = @IdReserva;

		-- Validar se houve erro
		IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION
				RETURN -4
			END

		COMMIT TRANSACTION
		
		-- Abre transação para insert em Hospedagem
		BEGIN TRANSACTION

		-- Registrar hospedagem
		
		INSERT INTO [dbo].[Hospedagem] (IdReserva, DataCheckin, Observacao)
			VALUES (@IdReserva, GETDATE(), @ObservacaoHospedagem);

		-- Valida se tem erro no registro da hospedagem
		IF @@ERROR <> 0 
			BEGIN
				ROLLBACK TRANSACTION
				RETURN -5
			END

		COMMIT TRANSACTION
		
		RETURN 0
	END
GO

-- ==================================================
-- Quarta Procedure

IF EXISTS (
			SELECT  1
				FROM [dbo].[sysobjects]
				WHERE Id = OBJECT_ID(N'[dbo].[SP_RealizarCheckout_GabrielFelix]')
					AND TYPE = 'P'
          )
	DROP PROCEDURE [dbo].[SP_RealizarCheckout_GabrielFelix];
GO

CREATE PROCEDURE [dbo].[SP_RealizarCheckout_GabrielFelix]
	@IdReserva INT,
	@Observacao VARCHAR(255) = NULL
	AS
	/*
		Documentacao
		
		Arquivo Fonte............: 106-48-gabriel-felix.sql
		Objetivo.................: Realizar um checkout de uma reserva
		Autor....................: Gabriel Felix
		Data.....................: 16/09/2026
		Ex.......................: BEGIN TRANSACTION
		                             
									 DBCC FREEPROCCACHE
									 DBCC DROPCLEANBUFFERS

									 DECLARE @Retorno INT,
											 @DataInicio DATETIME = GETDATE();

									 SELECT  TOP 1 *
										 FROM [dbo].[Reserva] WITH(NOLOCK)
										 WHERE Id = 52;

									 SELECT  TOP 1 *
										 FROM [dbo].[Hospedagem] WITH(NOLOCK)
										 WHERE IdReserva = 52;

									 EXEC @Retorno = [dbo].[SP_RealizarCheckout_GabrielFelix] @IdReserva = 52

									 SELECT  TOP 1 *
										 FROM [dbo].[Reserva] WITH(NOLOCK)
										 WHERE Id = 52;

									 SELECT  TOP 1 *
										 FROM [dbo].[Hospedagem] WITH(NOLOCK)
										 WHERE IdReserva = 52;

								   ROLLBACK TRANSACTION

		Retorno..................:  0 - Sucesso
		                           -1 - Erro: Reserva não cadastrada
								   -2 - Erro: Reserva não cadastrada em hospedagem
								   -4 - Erro: Erro em alterar a Situacao em Reserva
								   -5 - Erro: Erro em registrar a data de Checkout em Hospedagem
	*/
	BEGIN
		-- Validar se a Reserva existe
		IF NOT EXISTS (
		                 SELECT  TOP 1 1
							 FROM [dbo].[Reserva] WITH(NOLOCK)
							 WHERE Id = @IdReserva
					  )
			RETURN -1 

		-- Validar se ela está registrada em Hospedagem
		IF NOT EXISTS (
		                 SELECT  TOP 1 1
							 FROM [dbo].[Hospedagem] WITH(NOLOCK)
							 WHERE IdReserva = @IdReserva
					  )
			RETURN -2

		-- Armazena a data de hoje

		DECLARE @DataHoje DATE = CAST(GETDATE() AS DATE)

		-- Validar se a data de Checkout é menor que a data de entrada
		IF @DataHoje <= (
							SELECT  TOP 1 DataEntrada
								FROM [dbo].[Reserva] WITH(NOLOCK)
								WHERE Id = @IdReserva
						)
			RETURN -3

		-- Realizar a alteração em Reserva de Checkin para CHECKOUT
		BEGIN TRANSACTION
		UPDATE Reserva
			SET Situacao = 'CHECKOUT'
			WHERE Id = @IdReserva

		-- Verificar se houve erro
		IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION
				RETURN -4
			END

		COMMIT TRANSACTION

		-- Registrar a data de CHECKOUT em Hospedagem
		BEGIN TRANSACTION

		UPDATE Hospedagem
			SET DataCheckout = GETDATE()
			WHERE IdReserva = @IdReserva;

		-- Verificar se houve erro
		IF @@ERROR <> 0
			BEGIN
				ROLLBACK TRANSACTION
				RETURN -5
			END

		COMMIT TRANSACTION

		RETURN 0
	END
GO

/*
=====================================================
4. TESTES
===================================================== */ 

--código

--Reserva válida.

BEGIN TRANSACTION  -- Transação para simular o cadastro de uma reserva

	DBCC FREEPROCCACHE
	DBCC DROPCLEANBUFFERS

	DECLARE @Retorno INT, -- O retorno da procedure será o id cadastrado ou um número negativo para simbolizar o erro 
			@UltimoIdCadastrado INT,
			@DataInicio DATETIME = GETDATE();

	SELECT  TOP 1 @UltimoIdCadastrado = Id
		FROM [dbo].[Reserva] WITH(NOLOCK)
		ORDER BY Id DESC

	EXEC @Retorno = [dbo].[SP_CadastraReserva_GabrielFelix] @IdHospede = 1,
															@IdQuarto = 54,
															@DataEntrada = '19/09/2026',
															@DataSaida = '20/09/2026';									 

	SELECT  @Retorno As Retorno;

	SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;

ROLLBACK TRANSACTION
								   
DBCC CHECKIDENT('Reserva', RESEED, @UltimoIdCadastrado); -- Volta ao id que estava antes do teste
GO

--Tentativa de reserva com conflito de período.

BEGIN TRANSACTION  -- Transação para simular o cadastro de uma reserva

	DBCC FREEPROCCACHE
	DBCC DROPCLEANBUFFERS

	DECLARE @Retorno INT, -- O retorno da procedure será o id cadastrado ou um número negativo para simbolizar o erro
			@UltimoIdCadastrado INT,
			@DataInicio DATETIME = GETDATE();

	SELECT  TOP 1 @UltimoIdCadastrado = Id
		FROM [dbo].[Reserva] WITH(NOLOCK)
		ORDER BY Id DESC

	EXEC @Retorno = [dbo].[SP_CadastraReserva_GabrielFelix] @IdHospede = 1,
															@IdQuarto = 7,
															@DataEntrada = '24/09/2026', -- As datas já possuem uma reserva
															@DataSaida = '27/09/2026';									 

	SELECT  @Retorno As Retorno;

	SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;

ROLLBACK TRANSACTION
								   
DBCC CHECKIDENT('Reserva', RESEED, @UltimoIdCadastrado); -- Volta ao id que estava antes do teste
GO

--Cancelamento de reserva.

BEGIN TRANSACTION 

	DBCC FREEPROCCACHE
	DBCC DROPCLEANBUFFERS

	DECLARE @Retorno TINYINT,
			@DataInicio DATETIME = GETDATE();

	SELECT  TOP 1 *
		FROM [dbo].[Reserva]
		WHERE Id = 89;

	EXEC @Retorno = [dbo].[SP_CancelarReserva_GabrielFelix] @IdReserva = 89;										   
									   
	SELECT  TOP 1 *
		FROM [dbo].[Reserva]
		WHERE Id = 89;

	SELECT  @Retorno As Retorno;

	SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;

ROLLBACK TRANSACTION
GO

--Nova reserva em período anteriormente associado a uma reserva cancelada.

BEGIN TRANSACTION  -- Transação para simular o cadastro de uma reserva

	DBCC FREEPROCCACHE
	DBCC DROPCLEANBUFFERS

	DECLARE @Retorno INT, -- O retorno da procedure será o id cadastrado ou um 
			@UltimoIdCadastrado INT,
			@DataInicio DATETIME = GETDATE();

	SELECT  TOP 1 @UltimoIdCadastrado = Id
		FROM [dbo].[Reserva] WITH(NOLOCK)
		ORDER BY Id DESC

	EXEC @Retorno = [dbo].[SP_CadastraReserva_GabrielFelix] @IdHospede = 1,
															@IdQuarto = 94,
															@DataEntrada = '03/11/2026',
															@DataSaida = '07/11/2026';									 

	SELECT  @Retorno As Retorno;

	SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;

ROLLBACK TRANSACTION
								   
DBCC CHECKIDENT('Reserva', RESEED, @UltimoIdCadastrado); -- Volta ao id que estava antes do teste
GO

--Realização de check-in.

BEGIN TRANSACTION
									 
	DBCC FREEPROCCACHE 
	DBCC DROPCLEANBUFFERS

	DECLARE @Retorno INT,
			@DataInicio DATETIME = GETDATE();

	SELECT  TOP 1 *
		FROM [dbo].[Reserva] WITH(NOLOCK)
		WHERE Id = 76
									 
	EXEC @Retorno = [dbo].[SP_RealizarCheckin_GabrielFelix] @IdReserva = 76;

	SELECT  TOP 1 *
		FROM [dbo].[Reserva] WITH (NOLOCK)
		WHERE Id = 76

	SELECT  TOP 1 *
		FROM [dbo].[Hospedagem] WITH (NOLOCK)
		WHERE IdReserva = 76

	DECLARE @UltimoIdRegistrado INT = (SELECT  TOP 1 Id FROM [dbo].[Hospedagem] ORDER BY Id DESC);

	SELECT  @Retorno As Retorno,
			DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao

ROLLBACK TRANSACTION 

DBCC CHECKIDENT('Hospedagem', RESEED, @UltimoIdRegistrado);
GO

--Tentativa de check-in inválido.

BEGIN TRANSACTION
	DBCC FREEPROCCACHE 
	DBCC DROPCLEANBUFFERS

	DECLARE @Retorno INT,
			@DataInicio DATETIME = GETDATE();

	SELECT  TOP 1 *
		FROM [dbo].[Reserva] WITH(NOLOCK)
		WHERE Id = 76
									 
	EXEC @Retorno = [dbo].[SP_RealizarCheckin_GabrielFelix] @IdReserva = 1;

	SELECT  TOP 1 *
		FROM [dbo].[Reserva] WITH (NOLOCK)
		WHERE Id = 76

	SELECT  TOP 1 *
		FROM [dbo].[Hospedagem] WITH (NOLOCK)
		WHERE IdReserva = 76

	DECLARE @UltimoIdRegistrado INT = (SELECT  TOP 1 Id FROM [dbo].[Hospedagem] ORDER BY Id DESC);

	SELECT  @Retorno As Retorno,
			DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao

ROLLBACK TRANSACTION 

DBCC CHECKIDENT('Hospedagem', RESEED, @UltimoIdRegistrado);
GO

--Realização de check-out.

BEGIN TRANSACTION
		                             
	DBCC FREEPROCCACHE
	DBCC DROPCLEANBUFFERS

	DECLARE @Retorno INT,
			@DataInicio DATETIME = GETDATE();

	SELECT  TOP 1 *
		FROM [dbo].[Reserva] WITH(NOLOCK)
		WHERE Id = 52;

	SELECT  TOP 1 *
		FROM [dbo].[Hospedagem] WITH(NOLOCK)
		WHERE IdReserva = 52;

	EXEC @Retorno = [dbo].[SP_RealizarCheckout_GabrielFelix] @IdReserva = 52

	SELECT  TOP 1 *
		FROM [dbo].[Reserva] WITH(NOLOCK)
		WHERE Id = 52;

	SELECT  TOP 1 *
		FROM [dbo].[Hospedagem] WITH(NOLOCK)
		WHERE IdReserva = 52;

ROLLBACK TRANSACTION
GO

--Consulta da ocupação e/ou histórico por meio das Views.

SELECT  * 
	FROM [dbo].[VW_ConsultaHospedagens_GabrielFelix];

--Execução das Functions implementadas.

-- Primera Function

SELECT  [dbo].[FNC_ValidaDisponibilidadeParaReserva_GabrielFelix] ('304', '18/09/2026', '19/09/2026') As Resultado; -- Retorno 0 - Sucesso

-- Segunda Function

SELECT  *
	FROM [dbo].[FNC_QuantidadeDeQuartosOcupados_GabrielFelix] ('14/09/2026');
