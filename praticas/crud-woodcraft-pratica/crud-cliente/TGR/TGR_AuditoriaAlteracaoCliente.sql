USE WoodCraftPratica;
GO

CREATE OR ALTER TRIGGER [dbo].[TGR_AuditoriaAlteracaoCliente]
	ON [dbo].[Cliente]
	AFTER UPDATE
	AS
	/*	
		Documentacao
		Arquivo Fonte............: TGR_AuditoriaAlteracaoCliente.sql
		Objetivo.................: Registrar na tabela AuditoriaAlteracaoCliente as alteracoes apos um Update na tabela Cliente
		Autor....................: Gabriel Felix
		Data.....................: 18/08/2026
		Ex.......................: BEGIN TRANSACTION
								     
									 DBCC FREEPROCCACHE
									 DBCC DROPCLEANBUFFERS

									 -- Declarar variaveis para tempo de execucao, Id para Reseed da tabela de auditoria
									 DECLARE @DataInicio DATETIME = GETDATE(),
											 @IdReseedAuditoria INT;

									 -- Pegar Id para Reseed
									 SELECT  TOP 1 @IdReseedAuditoria = Id
										 FROM [dbo].[AuditoriaAlteracaoCliente] WITH (NOLOCK)
										 ORDER BY Id DESC;

									 -- Validar se ele não nulo
									 IF @IdReseedAuditoria IS NULL
										BEGIN
											SET @IdReseedAuditoria = 0
										END

									 -- Realizar consulta em Cliente
									 SELECT  Id,
									         Nome,
											 Documento,
											 Telefone,
											 TipoCliente
										 FROM [dbo].[Cliente] WITH (NOLOCK)
										 WHERE Id = 5

									 -- Exemplo de Update
									 UPDATE Cliente
										SET Nome = 'Gabriel',
											TipoCliente = 0
										WHERE = 5;

									 -- Realizar nova consulta em Cliente
									 SELECT  Id,
									         Nome,
											 Documento,
											 Telefone,
											 TipoCliente
										 FROM [dbo].[Cliente] WITH (NOLOCK)
										 WHERE Id = 5

									 -- Realizar consulta em AuditoriaAlteracaoCliente
									 SELECT  Id,
											 IdCliente,
											 NomeAnterior,
											 NomeNovo,
											 DocumentoAnterior,
											 DocumentoNovo,
											 TelefoneAnterior,
											 TelefoneNovo,
											 TipoClienteAntigo,
											 TipoClienteNovo,
											 AlteradoPor,
											 AlteradoEm
										 FROM [dbo].[AuditoriaAlteracaoCliente] WITH (NOLOCK)
										 WHERE IdCliente = 5;

									 -- Mostrar tempo de execucao
									 SELECT  DATEDIFF(MILLISECOND, @Datainicio, GETDATE()) As TempoExecucao

								   ROLLBACK TRANSACTION
								   
								   DBCC CHECKIDENT('AuditoriaAlteracaoCliente', RESEED, @IdReseedAuditoria)

		Retornos.................: 1 - TipoCliente invaliado
		                           2 - Documento inserido fora do padrão
								   3 - Telefone inserido fora do padrão
	*/
	BEGIN
		-- Declarar variaveis
		DECLARE @TipoClienteInserido BIT,
		        @DocumentoClienteInserido VARCHAR(14),
				@TelefoneInserido VARCHAR(11);
		
		-- Inserir dados nas variaveis
		SELECT  @TipoClienteInserido = TipoCliente,
				@DocumentoClienteInserido = Documento,
				@TelefoneInserido = Telefone
			FROM INSERTED;

		-- Validar TipoCliente
		IF @TipoClienteInserido > 1 OR @TipoClienteInserido < 0
			BEGIN
				RAISERROR('TipoCliente invaliado', 16, 1)
				RETURN
			END

	    -- Validar Documento inserido possuI apenas letras e o numero de caracteres correto
		IF @DocumentoClienteInserido LIKE '%[^0-9]%'
			OR @DocumentoClienteInserido NOT IN (11, 14)
			BEGIN
				RAISERROR('Documento inserido fora do padrão', 16, 2)
				RETURN
			END

		-- Validar Telefone inserido possuI apenas letras e o numero de caracteres correto
		IF @TelefoneInserido LIKE '%[^0-9]%'
			OR LEN(@TelefoneInserido) <> 11 
			BEGIN
				RAISERROR('Telefon inserido fora do padrão', 16, 3)
				RETURN
			END

		-- Realizar insercao em auditoria
		BEGIN TRANSACTION
			UPDATE [dbo].[AuditoriaAlteracaoCliente] WITH (NOLOCK)
				

		-- Validar se não houve nenhum erro
		RETURN
	END
GO
