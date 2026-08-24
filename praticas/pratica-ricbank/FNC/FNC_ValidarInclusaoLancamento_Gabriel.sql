USE RicBankTeste;
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_ValidarInclusaoLancamento_GabrielFelix](@IdConta INT, @Valor DECIMAL(18,2))
	RETURNS TINYINT
	/*
		Documentacao
		Arquivo Fonte............: FNC_ValidarInclusaoLancamento_GabrielFelix.sql
		Obejtivo.................: Retornar se o Cliente pode realizar um lancamento
		Autor....................: Gabriel Felix
		Data.....................: 24/08/2026
		Ex.......................: DBCC FREEPROCCACHE
								   DBCC DROPCLEANBUFFERS

								   DECLARE @DataInicio DATETIME = GETDATE();

								   SELECT  [dbo].[FNC_ValidarInclusaoLancamento_GabrielFelix] (14, 200) As Retorno,
										   [dbo].[FNC_ConsultarSaldo_GabrielFelix] (14, CAST(GETDATE() AS DATE));

								   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;
	*/
	AS
	BEGIN
		-- Declarar variaveis
		DECLARE @DataMomento DATE = CAST(GETDATE() AS DATE),
				@Retorno TINYINT;

		-- Verificar Saldo e 
		;WITH BuscaContaChequeEspecial AS (
			 SELECT  ISNULL([dbo].[FNC_ConsultarSaldo_GabrielFelix] (@IdConta, @DataMomento), 0) As SaldoConta,
			         co.TipoConta,
					 ISNULL(ce.ValorLimite, 0) As ValorChequeEspecial
				 FROM [dbo].[Conta] AS co WITH(NOLOCK)
					 INNER JOIN [dbo].[Saldo] AS sa WITH(NOLOCK)
						 ON sa.IdConta = co.Id
					 INNER JOIN [dbo].[ChequeEspecial] AS ce WITH(NOLOCK)
						 ON ce.IdConta = co.Id 
							AND ce.IdStatusChequeEspecial = 1
				 WHERE co.Id = @IdConta					
		 ) 
		 SELECT  @Retorno = (CASE
					             WHEN TipoConta  = 'CP' THEN (
																	  CASE
																		  WHEN SaldoConta >= @Valor THEN 0
																	  END								                            
															         )
								 WHEN TipoConta = 'CC' THEN (
														     CASE
																 WHEN SaldoConta >= @Valor THEN 0
																 WHEN SaldoConta + ValorChequeEspecial >= @Valor THEN 0
															 END
															)
								 ELSE 1
				             END)
			 FROM BuscaContaChequeEspecial;	

	RETURN @Retorno
	END
GO 
