USE WoodCraftPratica;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_EdicaoCliente] 
	@DocumentoCliente VARCHAR(14),
	@NomeCliente VARCHAR(100) = NULL,
	@TelefoneCliente VARCHAR(11) = NULL,
	@TipoCliente BIT = NULL
	AS
	/*
		Documentacao
		Arquivo Fonte............: SP_EdicaoCliente.sql
		Objtivo..................: Atualizar informações de um cliente usando como base o documento cadastrado
		Autor....................: Gabriel Felix
		Data.....................: 13/08/2026
		Ex.......................: BEGIN TRANSACTION

								   DBCC FREEPROCCACHE
								   DBCC DROPCLEANBUFFERS

								   DECLARE @Retorno INT,
										   @DataInicio DATETIM = GETDATE();
								   
								   SELECT  Id,
								           Nome,
										   Documento,
										   Telefone,
										   TipoCliente
										FROM [dbo].[Cliente] WITH(NOLOCK)
										WHERE Documento = @DocumentoCliente;
								   
								   EXEC @Retorno = [dbo].[SP_EdicaoCliente] = @DocumentoCliente = '[...]', @NomeCliente = '[...]';
								   
								   SELECT  Id,
								           Nome,
										   Documento,
										   Telefone,
										   TipoCliente
										FROM [dbo].[Cliente] WITH(NOLOCK)
										WHERE Documento = @DocumentoCliente;

								   ROLLBACK TRANSACTION

		Retorno..................:  0 - Sucesso
								   -1 - O Cliente com o Documento informado não existe
	*/                     
	BEGIN
		-- Validar se o documento existe 
		-- Validar se o nome 
	END
GO select * from Cliente
