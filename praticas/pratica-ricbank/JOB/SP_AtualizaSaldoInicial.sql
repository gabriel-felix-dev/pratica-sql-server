USE RicBankTeste;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_AtualizaSaldoInicial_Gabriel] 
	AS
	/*
		Documentacao
		Arquivo Fonte............: SP_AtualizaSaldoInicial_Gabriel.sql
		Objetivo.................: Realiza a atualização do SaldoInicial calculando o SaldoIncial + MovimentacaoCredio - MovimentacaoDebito
		Autor....................: Gabriel Felix
		Data.....................: 20/08/
		Ex.......................: BEGIN TRANSACTION
									 DBCC FREEPROCCACHE
									 DBCC DROPCLEANBUFFERS

									 DECLARE @Ontem DATE = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE),
											 @Retorno INT,
											 @DataInicio DATETIME = GETDATE(),
											 @IdBaseReseed INT
									 
									 -- Pega o ultimo Id para Reseed
									 SELECT  TOP 1 @IdBaseReseed = Id
										 FROM [dbo].[Saldo] 
										 ORDER BY Id DESC
									 
									 -- Valida se o Id de Reseed é nulo
									 IF @IdBaseReseed IS NULL
										SET @IdBaseReseed = 0
									 
									 INSERT INTO [dbo].[Saldo] (IdConta, DataSaldo, SaldoInicial, MovimentacaoCredito, MovimentacaoDebito, DataHoraJob)
									   SELECT  sa.IdConta,
											   CAST(SYSDATETIME() AS DATE),
											   sa.SaldoInicial + sa.MovimentacaoCredito - sa.MovimentacaoDebito,
											   0,
											   0,
											   SYSDATETIME()							
										   FROM [dbo].[Saldo] AS sa WITH(NOLOCK)
										   WHERE sa.DataSaldo = @Ontem

								   ROLLBACK TRANSACTION

								   DBCC CHECKIDENT ('Saldo', RESEED, @IdBaseReseed)
		
		Retorno..................: -1 - Erro de atualizacao
	*/
		BEGIN
			-- Declara variavel para armazenar o dia de ontem
			DECLARE @Ontem DATE = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE);

			BEGIN TRANSACTION

				-- Insere dados atualizados ao saldo inicial
				INSERT INTO [dbo].[Saldo] (IdConta, DataSaldo, SaldoInicial, MovimentacaoCredito, MovimentacaoDebito, DataHoraJob)
					SELECT  sa.IdConta,
							CAST(SYSDATETIME() AS DATE),
							sa.MovimentacaoCredito,
							sa.MovimentacaoDebito,
							sa.SaldoInicial + sa.MovimentacaoCredito - sa.MovimentacaoDebito,
							0,
							0,
							SYSDATETIME()							
						FROM [dbo].[Saldo] AS sa WITH(NOLOCK)
						WHERE sa.DataSaldo = @Ontem	
				 
				 -- Valida se não houve nenhum erro, se houver, a atualização não acontece
				 IF @@ERROR <> 0
					BEGIN
						RETURN -1 
						ROLLBACK TRANSACTION
					END

			COMMIT TRANSACTION
		END
GO
