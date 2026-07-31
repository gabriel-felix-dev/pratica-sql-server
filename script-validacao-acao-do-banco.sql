IF EXISTS(-- é para se já aexiste alguma alguma coisa com o nome da SP, TRG, JOB e se tiver será dropada
              SELECT  *
                  FROM [dbo].[sysobject]
                  WHERE Id = OBJECT_ID(N'[dbo][RBSP_InsertCliente]') -- SP ou TRG depende da função
                    AND OBJECTPROPERTY (id, N'IsPROCEDURE') = 1
         )
    DROP PROCEDURE [dbo].[RBSP_InsertCliente];
    GO

    CREATE...
