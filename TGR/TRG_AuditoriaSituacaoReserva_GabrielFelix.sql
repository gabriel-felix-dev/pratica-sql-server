USE hotel_avaliacao;
GO

IF EXISTS (
            SELECT  1
                FROM [dbo].[sysobjects]
                WHERE Id = OBJECT_ID(N'[dbo].[TRG_AuditoriaSituacaoReserva_GabrielFelix]')
                    AND TYPE = 'TR'
          )
    DROP TRIGGER [dbo].[TRG_AuditoriaSituacaoReserva_GabrielFelix]
GO

CREATE TRIGGER [dbo].[TRG_AuditoriaSituacaoReserva_GabrielFelix]
    ON [dbo].[Reserva]
    AFTER UPDATE
    AS
    /*
        Documentacao
        Arquivo Fonte............: [dbo].[TRG_AuditoriaSituacaoReserva_GabrielFelix].sql
        Objetivo.................: Registrar as alterações realizadas na tabela Reserva quando a mudança da coluna Situacao for 'CHECKOUT' ou 'CANCELADA'
        Autor....................: Gabriel Felix
        Data.....................: 28/09/2026
        Ex.......................: BEGIN TRANSACTION
                                   
                                       DBCC FREEPROCCACHE
                                       DBCC DROPCLEANBUFFERS

                                       DECLARE @DataInicio DATETIME = GETDATE(),
                                               @IdBaseReseed INT = (SELECT  TOP 1 Id FROM [dbo].[ReservaHistorico] ORDER BY Id DESC);
                                   
                                       IF @IdBaseReseed IS NULL
                                         SET @IdBaseReseed = 0;

                                       SELECT  TOP 1 *
                                           FROM [dbo].[Reserva]
                                           WHERE Id = 51;

                                       UPDATE [dbo].[Reserva]
                                         SET Situacao = 'CANCELADA'
                                         WHERE Id = 51;
                                   
                                       SELECT  *
                                           FROM [dbo].[Reserva]
                                           WHERE Id = 51;

                                       SELECT  TOP 5 * 
                                           FROM [dbo].[ReservaHistorico]
                                           ORDER BY Id DESC;

                                       SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) As TempoExecucao;
                                   
                                   ROLLBACK TRANSACTION

                                   DBCC CHECKIDENT('ReservaHistorico', RESEED, @IdBaseReseed)

        Retorno..................: -1 - Erro: 
    */
    BEGIN
        -- SET NOCOUNT ON;

        -- Validar se o update modifidificou a coluna Situacao
        IF NOT UPDATE(Situacao)
            RETURN;

        -- Validar se o update modifidificou a coluna Situacao para 'CHECKOUT' ou 'CANCELADA'
        IF NOT EXISTS (
                         SELECT  1
                             FROM INSERTED
                             WHERE Situacao IN ('CHECKOUT', 'CANCELADA')
                      )
            RETURN;

        -- Abrir transação para inserir os dados em ReservaHistorico
        BEGIN TRANSACTION
            INSERT INTO [dbo].[ReservaHistorico] (IdReserva, SituacaoAnterior, SituacaoNova, AlteradoPor, AlteradoEm)
                SELECT  it.Id,
                        de.Situacao,
                        it.Situacao,
                        SUSER_NAME(),
                        GETDATE()
                    FROM INSERTED AS it
                        INNER JOIN DELETED AS de
                            ON de.Id = it.Id
                    WHERE it.Situacao IN ('CHECKOUT', 'CANCELADA');

        -- Validar se houve algum erro na inserção de dados
            IF @@ERROR <> 0
                BEGIN
                    ROLLBACK TRANSACTION
                    RETURN
                END

        COMMIT TRANSACTION
    END
GO
