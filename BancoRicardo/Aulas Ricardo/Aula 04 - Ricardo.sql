/* Aula 04 Ricardo:

80% do tempo planejando 
20% do tempo codando 

*/

USE BancoRicardo;

-- Excluir da base todos os registros inconsistentes q tenham o status do logon falhou. O delete não pode ser em cascata.

WITH IdLogonSemSucesso AS (
						   SELECT	lo.Id
						       FROM Logon AS lo WITH(NOLOCK)
							       INNER JOIN OpcaoAcionada AS oa WITH(NOLOCK)
								       ON oa.IdLogon = lo.Id
							   WHERE lo.Sucesso = 0
						  )
DELETE OpcaoAcionada 
WHERE IdLogon IN (SELECT  Id
				      FROM IdLogonSemSucesso);

WITH IdLogonSemSucesso AS (
						   SELECT	lo.IdUsuario
							   FROM Logon AS lo WITH(NOLOCK)
							   WHERE lo.Sucesso = 0
						  )
DELETE Logon 
WHERE IdUsuario IN (SELECT  IdUsuario
				      FROM IdLogonSemSucesso);

DELETE oa
	FROM OpcaoAcionada AS oa WITH(NOLOCK)
		INNER JOIN Logon AS lo WITH(NOLOCK)
			ON lo.Id = oa.IdLogon

-- Vamos um exercicio para popular a base com um comando que popule automaticamente 1000 registros de Logon que 
-- randomicamente seja Sucesso e Fracasso 100 em cada data

/*

-> Limpar base
-> Popular Logon com 1000 dados
	-> 100 por dia
	-> Variar Sucesso e Fracasso
	-> Variar Usuario

No mesmo comando que ele deve executar a limpa e criar os dados

*/

BEGIN TRANSACTION

BEGIN TRY
    DECLARE @Dia INT = 0
    DECLARE @Registro INT = 0
    DECLARE @IdLogonGerado INT
    DECLARE @QtdOpcoes INT
    DECLARE @OpcaoAtual INT

    WHILE @Dia < 10
    BEGIN
        SET @Registro = 0

        WHILE @Registro < 100
        BEGIN
            INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
            VALUES (
                (SELECT TOP 1 Id FROM Usuario ORDER BY NEWID()),
                DATEADD(HOUR, @Registro % 24, DATEADD(DAY, -@Dia, CAST(GETDATE() AS DATETIME))),
                CASE WHEN @Registro % 2 = 0 THEN 1 ELSE 0 END
            )

            SET @IdLogonGerado = SCOPE_IDENTITY()

            SET @QtdOpcoes = (@Registro % 5) + 1
            SET @OpcaoAtual = 1

            WHILE @OpcaoAtual <= @QtdOpcoes
            BEGIN
                INSERT INTO OpcaoAcionada (IdLogon, IdOpcao, InstanteLogon)
                VALUES (
                    @IdLogonGerado,
                    (@OpcaoAtual % 10) + 1,
                    DATEADD(MINUTE, @OpcaoAtual, DATEADD(HOUR, @Registro % 24, DATEADD(DAY, -@Dia, CAST(GETDATE() AS DATETIME))))
                )

                SET @OpcaoAtual = @OpcaoAtual + 1
            END

            SET @Registro = @Registro + 1
        END

        SET @Dia = @Dia + 1
    END

    COMMIT
END TRY
BEGIN CATCH
    ROLLBACK
    PRINT 'Erro: ' + ERROR_MESSAGE()
END CATCH
