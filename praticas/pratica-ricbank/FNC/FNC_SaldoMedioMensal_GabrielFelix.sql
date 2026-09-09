USE RicBankTeste;
GO

IF EXISTS (
		     SELECT  1
                 FROM [dbo].[sysobjects]
			     WHERE Id = OBJECT_ID(N'[dbo].[FNC_SaldoMedioMensal_GabrielFelix]')
				     AND TYPE = 'FN'
          )
		DROP FUNCTION [dbo].[FNC_SaldoMedioMensal_GabrielFelix];
GO

CREATE FUNCTION [dbo].[FNC_SaldoMedioMensal_GabrielFelix] (@IdConta INT, @Ano SMALLINT, @Mes TINYINT)
	RETURNS DECIMAL(19,2)
		/*
			Documentacao
			Arquivo Fonte...........: FNC_SaldoMedioMensal_GabrielFelix.sql
			Objetivo................: Calcular o saldo médio mensal de uma conta
			Autor...................: Gabriel Felix
			Data....................: 08/09/2026
			Autor Alteração.........: Gabriel Felix
			Data Alteração..........: 09/09/2026 - Adicionando na Documentacao detalhamento de casos de Sucesso, Caso inválido, Parâmetro inválido e Mês incompleto
			Ex......................: Sucesso................: SELECT [dbo].[FNC_SaldoMedioMensal_GabrielFelix] (14, 2026, 8) As SaldoMedioMensal;
									  Caso inválido..........: SELECT [dbo].[FNC_SaldoMedioMensal_GabrielFelix] (999, 2026, 8) As SaldoMedioMensal;
			                          Parâmetro inválido.....: SELECT [dbo].[FNC_SaldoMedioMensal_GabrielFelix] (14, 1899, 8) As SaldoMedioMensal;
									  Mês incompleto.........: SELECT [dbo].[FNC_SaldoMedioMensal_GabrielFelix] (14, 2026, 9) As SaldoMedioMensal;
		*/
	BEGIN	
	    -- Validar se conta existe
		IF NOT EXISTS (
						 SELECT  TOP 1 1
							 FROM [dbo].[Conta] WITH (NOLOCK)
							 WHERE Id = @IdConta
		              )
			BEGIN
				RETURN NULL
			END

		-- Validar parâmetros nulos
		IF @IdConta IS NULL
		   OR @Ano IS NULL
		   OR @Mes IS NULL
		   BEGIN 
			   RETURN NULL
		   END

		-- Validar se o mês é válido
		IF @Mes NOT BETWEEN 1 AND 12 
			BEGIN
				RETURN NULL
			END

		-- Validar se o ano está no intervalo de 1900 e 9998
		IF @Ano NOT BETWEEN 1900 AND 9998 
			BEGIN
				RETURN NULL
			END

		-- Declarar variáveis para primeiro e último dia do mês
		DECLARE @PrimeiroDia DATE = DATEFROMPARTS(@Ano, @Mes, 1);
		DECLARE @UltimoDia DATE = EOMONTH(@PrimeiroDia);

		-- Declarar variáveis para soma total do mês e quantidade de dias do mês
		DECLARE @ValorTotal DECIMAL(19,2),
				@QuantidadeDias TINYINT;

		-- Inserir valor nas variáveis
		SELECT  @ValorTotal = SUM(SaldoInicial + MovimentacaoCredito - MovimentacaoDebito),
				@QuantidadeDias = COUNT(*)
			FROM [dbo].[Saldo] WITH (NOLOCK)
			WHERE IdConta = @IdConta
				AND DataSaldo BETWEEN @PrimeiroDia
					AND @UltimoDia

		-- Validar mês com dados incompletos
		IF @QuantidadeDias <> CAST(DAY(@UltimoDia) AS TINYINT)
			BEGIN
				RETURN NULL
			END

		RETURN(@ValorTotal / CAST(@QuantidadeDias AS DECIMAL(19,2)))	   
	END
GO
