USE RicBankTeste;
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_AutorizarCartaoCredito_Gabriel_Felix]
	ON [dbo].[Compra] 
	FOR INSERT
	AS 
	/*
		Documentacao
		Arquivo Fonte............: TRG_AutorizarCartaoCredito_Gabriel_Felix.sql
		Objetivo.................: Validar se um lançamento de compra é válido
		Autor....................: Gabriel Felix
		Data.....................: 01/09/2026
		Ex.......................: BEGIN TRANSACTION
									 
									 INSERTO INTO [dbo].[Compra] (...)
										VALUES (...)
		                           
								   ROLLBACK TRANSACTION
		
		Retornos.................: 0 - Sucesso
		                           1 - ERRO: O cartão utilizado é de débito
								   2 - 
	*/
	BEGIN
		-- Declarar variáveis
		DECLARE @IdCartao INT,
		        @ValorCompra DECIMAL (18,2),
				@Estabelecimento VARCHAR(100);

		-- Consulta as informações na tabela INSERTED para armazenar os valores nas variáveis

		SELECT  @IdCartao = IdCartao,
				@ValorCompra = Valor,
				@Estabelecimento = Estabelecimento
			FROM INSERTED;

	    -- Validar tipo cartão
		IF (
			  SELECT  Credito
			      FROM [dbo].[Cartao] WITH(NOLOCK)
				  WHERE Id = @IdCartao
		   ) <> 1
			BEGIN
				RAISERROR('ERRO: O cartão utilizado é de débito', 16, 1)
				RETURN
			END

		-- Validar se o cartão está na validade
		IF (
			  SELECT  MesValidade
			      FROM [dbo].[Cartao] WITH(NOLOCK)
				  WHERE Id = @IdCartao
		   ) < DATEPART(MONTH, GETDATE()) OR
		   (
		      SELECT  MesValidade
			      FROM [dbo].[Cartao] WITH(NOLOCK)
				  WHERE Id = @IdCartao
		   ) < DATEPART(YEAR, GETDATE())
			BEGIN
				RAISERROR('ERRO: O cartão utilizado está fora da validade', 16, 2)
				RETURN
			END

		-- Validar a situação do cartão
		IF (
		      SELECT  IdSituacaoCartao
				  FROM [dbo].[Cartao]
				  WHERE Id = @IdCartao
		   ) <> 1 
			BEGIN
				RAISERROR('ERRO: O cartão não está ativo', 16, 3)
				RETURN
			END

		-- Validar limite do cartão
		IF (
		     SELECT  LimiteCredito - LimiteUtilizado
				 FROM [dbo].[Cartao]
				 WHERE Id = @IdCartao
		   ) < @ValorCompra
		    BEGIN
				RAISERROR('ERRO: O cartão não possui o limite para a compra', 16, 4)
				RETURN
			END

		-- Validar se a compra não é igual a compra anterior
		IF (
		     SELECT  Estabelecimento
				 FROM [dbo].[Compra]
				 WHERE IdCartao = @IdCartao
				 ORDER BY Id DESC

		   ) = @Estabelecimento
		   AND (
		          SELECT  Valor
				      FROM [dbo].[Compra]
					  WHERE IdCartao = @IdCartao
					  ORDER BY Id DESC
			   ) = @ValorCompra
			BEGIN
				RAISERROR('ERRO: A Compra é igual à anterior', 16, 5)
				RETURN
			END

		-- Validar se o valor é superior a R$ 1.000,00 e se está fora do horário comercial 08:00 às 17:00 de segunda à sexta
		IF @ValorCompra > 1000.00
			BEGIN
				
				IF DATEPART(HOUR, GETDATE()) BETWEEN 0 AND 7 
					OR DATEPART (HOUR, GETDATE()) BETWEEN 17 AND 23
					BEGIN
						RAISERROR('ERRO: A Compra é igual à anterior', 16, 6)
						RETURN
					END

			END

		INSERT INTO Cliente (NomeCompleto) 
			VALUES ('Nome')
	END
GO
