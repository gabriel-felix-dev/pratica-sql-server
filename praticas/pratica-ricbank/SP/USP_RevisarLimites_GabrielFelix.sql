USE RicBankTeste;
GO

IF EXISTS (
			 SELECT  1
				 FROM [dbo].[sysobjects]
				 WHERE Id = OBJECT_ID(N'[dbo].[USP_RevisarLimites_GabrielFelix]')
					AND TYPE = 'P'
          )
	DROP PROCEDURE [dbo].[USP_RevisarLimites_GabrielFelix]
GO

CREATE PROCEDURE [dbo].[USP_RevisarLimites_GabrielFelix]
	@DataReferencia DATE = NULL,
	@IdTipoLimite TINYINT
	AS
	/*
		Documentacao
		Arquivo Fonte............: USP_RevisarLimites_GabrielFelix.sql
		Objetivo.................: 
		Auto.....................: Gabriel Felix
		Data.....................: 09/09/2026
		Ex.......................: DBCC FREEPROCCACHE
		                           DBCC DROPCLEANBUFFERS

								   DECLARE @Retorno INT,
										   @DataInicio DATETIME = GETDATE();
							       
								   EXEC @Retorno = [dbo].[USP_RevisarLimites_GabrielFelix] @DataReferencia = '01/09/2026',
								                                                           @IdTipoLimite = 1;

								   SELECT  @Retorno As Retorno,
										   DATEDIFF(MILLISECOND, @DataInicio,  GETDATE()) As TempoExecucao

		Retornos.................: 0 - Sucesso
								   1 - Erro - TipoLimite não encontrado
	*/
	BEGIN
		-- Valida se a data é nula para definir a data de hoje
		IF @DataReferencia IS NULL
			SET @DataReferencia = CAST(GETDATE() AS DATE)

		-- Valida se o TipoLimite existe
		IF NOT EXISTS ()
			RETURN -1 
		

		RETURN 0
	END
GO
