USE RicBankTeste;
GO

IF EXISTS (
			SELECT  *
				FROM [dbo].[sysobjects]
				WHERE Id = OBJECT_ID(N'[dbo].[USP_ResumoSaldoMedioAgencia_GabrielFelix]')
					AND TYPE = 'P'
		  )
	DROP PROCEDURE [dbo].[USP_ResumoSaldoMedioAgencia_GabrielFelix]
GO

CREATE PROCEDURE [dbo].[USP_ResumoSaldoMedioAgencia_GabrielFelix]
	@IdAgencia INT,
    @Ano SMALLINT,
	@Mes TINYINT
	AS
	/*
		Documentacao
		Arquivo Fonte...........: USP_ResumoSaldoMedioAgencia_GabrielFelix.sql
		Objetivo................: Retonar a distribuição das contas de uma agência por faixa de saldo médio mensal
		Autor...................: Gabriel Felix
		Data....................: 08/09/2026
		Autor Alteração.........: Gabriel Felix
		Data Alteração..........: 09/09/2026 - Adicionando a CTe "BuscaIdConta" para reliazar as consultas de buscas para filtrar as contagens.
		Ex......................: DBCC FREEPROCCACHE
		                          DBCC DROPCLEANBUFFERS

								  DECLARE @Retorno AS INT,
										  @DataInicio DATETIME = GETDATE();

								  EXEC @Retorno = USP_ResumoSaldoMedioAgencia_GabrielFelix @IdAgencia = 1,
								                                                           @Ano = 2026,
																						   @Mes = 8;
								  
								  SELECT  @Retorno As Retorno;
								  
								  SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao

		Sucesso.................: 0 - Sucesso
		                          -1 - Erro: Conta não encontrada
								  -2 - Erro: Ano informado inválido
								  -3 - Erro: Mes informado inválido
	*/
	BEGIN
		-- Validar IdAgencia
		IF NOT EXISTS (
		                 SELECT  TOP 1 1
							 FROM [dbo].[Agencia] WITH(NOLOCK)
							 WHERE Id = @IdAgencia
					  )
			RETURN -1

		-- Validar Ano
		IF @Ano NOT BETWEEN 1900 AND 9998
			RETURN -2 

		-- Validar Mes
		IF @Mes NOT BETWEEN 1 AND 12
			RETURN -3 
		
		-- CTe para armazenar os Id's das contas com o @IdAgencia
		;WITH BuscaIdConta AS (
		                         SELECT  Id
						             FROM [dbo].[Conta] WITH(NOLOCK)
						             WHERE IdAgencia = 1
					          )
		-- Consulta contas com média igual a 0 e menor/igual a 5.000
		SELECT  'De zero a 5.000' As Faixa,
				COUNT ( 
				        CASE WHEN [dbo].[FNC_SaldoMedioMensal_GabrielFelix](Id, @Ano, @Mes) >=0 AND [dbo].[FNC_SaldoMedioMensal_GabrielFelix](Id, @Ano, @Mes) <= 5000.00 THEN 1
			            END
					  ) As QuantidadeContas
			FROM BuscaIdConta
		
		UNION ALL
		
		-- Consulta contas com média maior que 5.000 e menor/igual a 10.000
		SELECT  'De 5.000,01 a 10.000' As Faixa,
				COUNT ( 
				        CASE WHEN [dbo].[FNC_SaldoMedioMensal_GabrielFelix](Id, @Ano, @Mes) > 5000.00 AND [dbo].[FNC_SaldoMedioMensal_GabrielFelix](Id, @Ano, @Mes) <= 10000.00 THEN 1
			            END
					  ) As QuantidadeContas
			FROM BuscaIdConta

		UNION ALL

		-- Consulta contas com média maior 10.000
		SELECT  'Acima de 10.000' As Faixa,
				COUNT ( 
				        CASE WHEN [dbo].[FNC_SaldoMedioMensal_GabrielFelix](Id, @Ano, @Mes) > 10000.00 THEN 1
			            END
					  ) As QuantidadeContas
			FROM BuscaIdConta
	END
GO
