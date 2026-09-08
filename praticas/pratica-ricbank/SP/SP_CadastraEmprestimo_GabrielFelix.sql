USE RicBankTeste;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_CadastraEmprestimo_GabrielFelix]
    @IdContaCorrente INT,
	@IdTipoEmprestimo TINYINT,
	@IdSituacaoEmprestimo TINYINT,
	@IdFormaDePagamento TINYINT,
	@NumeroDeContrato VARCHAR(30),
	@Valor DECIMAL(15,2),
	@TaxaJuros DECIMAL(7,4),
	@QuantidadeParcelas INT
	AS
	/*
		Documentacao
		Arquivo Fonte............: SP_CadastraEmprestimo_GabrielFelix.sql
		Objetivo.................: Cadastrar um emprestimo
		Autor....................: Gabriel Felix
		Data.....................: 08/09/2026
		Ex.......................:
		Sucesso..................: @IdEmprestimo - Sucesso
		                           -1 - Erro:
	*/
	BEGIN
		SELECT  TOP 10 *
			FROM [dbo].[Emprestimo]

		SELECT  TOP 10 *
			FROM [dbo].[TipoEmprestimo]
	RETURN 0
	END
GO
