USE BancoRicardo
GO

SELECT    ml.Usuario as IdUsuario,
        us.Nome as Usuario,
        oa.IdOpcao as IdOpcao,
        op.Nome as Opcap
    FROM (SELECT    TOP 1 lo.IdUsuario as Usuario,
                          COUNT(lo.Id) as QuantidadeLogons 
                FROM Logon AS lo WITH(NOLOCK)
                WHERE CAST(lo.DataLogon AS DATE) = CAST(GETDATE() AS DATE)
                GROUP BY lo.IdUsuario
                ORDER BY COUNT(lo.Id) DESC
         ) AS ml 
            JOIN Usuario AS us WITH(NOLOCK)
                ON us.Id = ml.Usuario
            JOIN Logon AS lo WITH(NOLOCK)
                ON lo.IdUsuario = us.Id
            JOIN OpcaoAcionada AS oa WITH(NOLOCK)
                ON oa.IdLogon = lo.Id
            JOIN Opcao AS op WITH(NOLOCK)
                ON op.Id = oa.IdOpcao
    WHERE CAST(lo.DataLogon AS DATE) = CAST(GETDATE() AS DATE)

USE master;

ALTER DATABASE BancoRicardo
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;

DROP DATABASE BancoRicardo;
