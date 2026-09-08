USE RicBankTeste;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_CadastroCartao_GabrielFelix]
	@IdConta INT,
	@NumeroMascarado VARCHAR(16),
	@TipoCartao CHAR(1)
	AS
	/*
		Documentacao
		Arquivo Fonte............: SP_CadastroCartao_GabrielFelix.sql
		Objetivo.................: Realizar o cadasto de um cartão de crédito ou débito
		Autor....................: Gabriel Felix
		Data.....................: 03/09/2026
		Ex.......................: 
		Retorno..................: IdCartao - Sucesso
		                           -1 - Erro:
	*/
	BEGIN
		RETURN @IdConta
	END
GO
