USE RicBankTeste;
GO

IF EXISTS (
			 SELECT  1
				 FROM [dbo].[sysobjects]
				 WHERE Id = OBJECT_ID(N'[dbo].[USP_RevisarLimitesCartaoDeCredito_GabrielFelix]')
					AND TYPE = 'P'
          )
	DROP PROCEDURE [dbo].[USP_RevisarLimitesCartaoDeCredito_GabrielFelix]
GO

CREATE PROCEDURE [dbo].[USP_RevisarLimitesCartaoDeCredito_GabrielFelix]
	@DataReferencia DATE = NULL,
	@IdTipoLimite TINYINT
	AS
	/*
		Documentacao
		Arquivo Fonte............: USP_RevisarLimitesCartaoDeCredito_GabrielFelix.sql
		Objetivo.................: Revisar o limite das contas
		Auto.....................: Gabriel Felix
		Data.....................: 09/09/2026
		Ex.......................: DBCC FREEPROCCACHE
		                           DBCC DROPCLEANBUFFERS

								   DECLARE @Retorno INT,
										   @DataInicio DATETIME = GETDATE();
							       
								   EXEC @Retorno = [dbo].[[dbo].[USP_RevisarLimitesCartaoDeCredito_GabrielFelix] @DataReferencia = '01/09/2026',
																												 @IdTipoLimite = 1;

								   SELECT  @Retorno As Retorno,
										   DATEDIFF(MILLISECOND, @DataInicio,  GETDATE()) As TempoExecucao

		Retornos.................: 0 - Sucesso
								   -1 - Erro - TipoLimite não encontrado
								   -2 - Erro - 	
	*/
	BEGIN
		-- Valida se a data é nula para definir a data de hoje
		IF @DataReferencia IS NULL
			SET @DataReferencia = CAST(GETDATE() AS DATE)

		-- Valida se o TipoLimite existe
		IF NOT EXISTS (
		                 SELECT  TOP 1 1
							 FROM [dbo].[TipoLimite]
							 WHERE Id = @IdTipoLimite
					  )
			RETURN -1 
	    
		-- Pegar ano e mês da data informada pelo usuário
		DECLARE @Mes TINYINT = MONTH(@DataReferencia),
				@Ano SMALLINT = YEAR(@DataReferencia);

		-- Definir variáveis para armazenar os três meses anteriores

		DECLARE @PrimeiroMes DATE = DATEADD(MONTH, -1, DATEFROMPARTS(@Ano, @Mes, 1)),		
			    @SegundoMes DATE = DATEADD(MONTH, -2, DATEFROMPARTS(@Ano, @Mes, 1)),
				@TerceiroMes DATE = DATEADD(MONTH, -3, DATEFROMPARTS(@Ano, @Mes, 1));

		SELECT * FROM TipoLimite;


		RETURN 0
	END
GO
