USE WoodCraftPratica;
GO

CREATE OR ALTER TRIGGER [dbo].[TGR_AuditoriaInsercaoCliente]
	ON [dbo].[Cliente]
	AFTER INSERT
	AS
	/*
		Documentacao
		Arquivo Fonte............: TGR_AuditoriaCliente.sql
		Obejtivo.................: Preencher a tabela AuditoriaCliente com as informações do Cliente que foi inserido e as informações de quem inseriu
		Autor....................: Gabriel Felix
		Data.....................: 18/08/2026
		Ex.......................: BEGIN TRANSACTION

								     DBCC FREEPROCCACHE
									 DBCC DROPCLEANBUFFERS

									 DECLARE @DataInicio DATETIME = GETDATE(),
											 @IdReferenciaReseedCliente INT,
											 @IdReferenciaReseedAuditoriaCliente INT;
									 
									 -- Armazena o ultimo Id da tabela Cliente
									 SELECT  TOP 1 @IdReferenciaReseedCliente = Id
										 FROM [dbo].[Cliente] WITH(NOLOCK)
										 ORDER BY Id DESC;
									 
									 -- Armazena o ultimo Id da tabela AuditoriaCliente
									 SELECT  TOP 1 @IdReferenciaReseedAuditoriaCliente = Id
										 FROM [dbo].[AuditoriaCliente] WITH(NOLOCK)
										 ORDER BY Id DESC;
									 
									 -- Valida se o Id armazenado de AuditoriaCliente é nulo
									 IF @IdReferenciaReseedAuditoriaCliente IS NULL
										BEGIN
											SET @IdReferenciaReseedAuditoriaCliente = 0
										END
									 
									 -- Valida se o Id armazenado de Cliente é nulo
									 IF @IdReferenciaReseedCliente IS NULL
										BEGIN
											SET @IdReferenciaReseedCliente = 0
										END
									 
									 SELECT  TOP 3 Id,
											       Nome, 
											       Documento,
												   Telefone,
												   TipoCliente
									     FROM [dbo].[Cliente] WITH(NOLOCK)
										 ORDER BY Id DESC;

									 INSERT INTO Cliente (Nome, Documento, Telefone, TipoCliente)
										VALUES ('Gabriel Felix', '10679691448', '84992268147', 1);

									 SELECT  TOP 3 Id,
											       Nome, 
											       Documento,
												   Telefone,
												   TipoCliente
									     FROM [dbo].[Cliente] WITH(NOLOCK)
										 ORDER BY Id DESC;

									  SELECT  TOP 3 Id,
													IdCliente,
											        NomeCliente, 
											        TipoOperacaoRealizada,
												    OperacaoRealizadaPor,
												    DataOperacao
									     FROM [dbo].[AuditoriaCliente] WITH(NOLOCK)
										 ORDER BY Id DESC;
										 
									  SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao
								    
								   ROLLBACK TRANSACTION

								   DBCC CHECKIDENT ('Cliente', RESEED, @IdReferenciaReseedCliente);
								   DBCC CHECKIDENT ('AuditoriaCliente', RESEED, @IdReferenciaReseedAuditoriaCliente);	
		
		Retornos.................: 1 - Erro ao registrar informacoes na tabela AuditoriaCliente
	*/
	BEGIN
		-- Declarar variavel para definir o nome da operacao
		DECLARE @Operacao VARCHAR(100) = 'INSERT';

		-- Realizar insercao na tabela AuditoriaCliente
		BEGIN TRANSACTION
			INSERT INTO [dbo].[AuditoriaCliente] (IdCliente, NomeCliente, TipoOperacaoRealizada, OperacaoRealizadaPor, DataOperacao)
				SELECT  Id,
						Nome,
						@Operacao,
						SUSER_SNAME(),
						GETDATE()
					FROM INSERTED;
			
			-- Validar se existe algum erro
			IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION
					RAISERROR('Erro ao registrar informacoes na tabela AuditoriaCliente', 16, 1)
					RETURN
				END

		COMMIT TRANSACTION
	END
GO
