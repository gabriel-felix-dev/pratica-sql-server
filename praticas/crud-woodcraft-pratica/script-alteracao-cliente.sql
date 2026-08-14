USE WoodCraftPratica;
GO

-- 1. Analisar da tabela Cliente e alteração da tabela

SELECT * FROM Cliente;

ALTER TABLE Cliente
 ADD Documento VARCHAR(14), 
     Telefone VARCHAR (11);

SELECT * FROM Cliente;


-- 2. Criar da tabela DocumentoTelefoneCliente 

CREATE TABLE DocumentoTelefoneCliente (

    Id INT IDENTITY,
    Documento VARCHAR(14),
    Telefone VARCHAR (11)

    CONSTRAINT PK_Id PRIMARY KEY (Id)
);

-- 3. Inserir informações na tabela DocumentoTelefoneCliente 

INSERT INTO DocumentotelefoneCliente (Documento, Telefone)
VALUES
    ('12345678000195', '11987654321'),
    ('23456789000106', '21987654321'),
    ('34567890000117', '31987654321'),
    ('45678901000128', '41987654321'),
    ('56789012000139', '85987654321');

SELECT * FROM DocumentotelefoneCliente;

-- 4. Inserir os dados de documentos em Cliente

BEGIN TRAN

    UPDATE cl
        SET cl.Documento = Documento.Documento
            FROM Cliente AS cl WITH(NOLOCK)
                CROSS JOIN (
                                SELECT  Id,
                                        Documento
                                    FROM DocumentoTelefoneCliente AS dt WITH(NOLOCK)
                           ) AS Documento
        WHERE cl.Id = Documento.Id;

    IF @@ERROR <> 0 OR @@ROWCOUNT = 0
      ROLLBACK TRAN

COMMIT TRAN

-- Verificar alteracoes 

SELECT  * FROM Cliente;

-- 5. Inserir dados de Telefone em Cliente

BEGIN TRAN

    UPDATE cl
     SET cl.Telefone = Telefone.Telefone
        FROM Cliente AS cl
            CROSS JOIN (
                           SELECT  Id,
                                   Telefone
                               FROM DocumentoTelefoneCliente
                       ) AS Telefone
        WHERE cl.Id = Telefone.Id

IF @@ERROR <> 0 
    ROLLBACK TRAN

COMMIT TRAN

-- Verificar alteracoes
SELECT  * FROM Cliente;

-- 6. Alterar colunas para não permitirem informações nulas

ALTER TABLE Cliente
    ALTER COLUMN Telefone VARCHAR(11) NOT NULL;

ALTER TABLE Cliente
    ALTER COLUMN Documento VARCHAR(14) NOT NULL;

-- 7. Adicionar Constraint em documento do Cliente

ALTER TABLE Cliente
 ADD CONSTRAINT UQ_Documento UNIQUE (Documento); 
