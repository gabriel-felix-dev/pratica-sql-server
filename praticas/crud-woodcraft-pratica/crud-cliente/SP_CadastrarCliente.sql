USE WoodCraft;

CREATE OR ALTER PROCEDURE [dbo].[SP_CadastrarCliente]
	@NomeCliente VARCHAR(100) = NULL
	AS
	/*
		Documentacao
		Arquivo Fonte............: SP_CadastrarCliente.sql
		Objetivo.................: Cadastrar um usuário na tabela Cliente
		Autor....................: Gabriel Felix
		Data.....................: 10/08/2026
		Ex.......................: BEGIN TRANSACTION

		                           DBCC FREEPROCCACHE
								   DBCC DROPCLEANBUFFERS

								   DECLARE @Retorno INT,
										   @DataInicio DATETIME = GETDATE();
								  
								   EXEC @Retorno = [dbo].[SP_CadastrarCliente] @NomeCliente = 'Madereira Lá Ele LTA.';

								   SELECT  @Retorno As Retorno,
										   DATEDIFF(MILLISECOND, @Datainicio, GETDATE()) As TempoExecucao

								   ROLLBACK TRANSACTION 

		Retorno..................: 0 - Sucesso
		                           1 - Cliente já cadastrado
								   2 - Erro ao cadastrar Cliente
	*/
	BEGIN
		-- Validar se não existe nenhum Cliente com o mesmo nome
	    -- Executar o comando
		-- Validar se houve algum erro
	END
GO
