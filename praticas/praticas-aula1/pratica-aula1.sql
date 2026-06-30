USE WoodCraft;

DECLARE @IdCliente INT;
DECLARE @NomeCliente VARCHAR(100);

SET @IdCliente = 1;

SELECT  @NomeCliente = Nome
	FROM [dbo].[Cliente] WITH(NOLOCK)
	WHERE Id = @IdCliente;

PRINT @NomeCliente;

IF @IdCliente IS NOT NULL
	BEGIN 
		PRINT 'O cliente foi informado.';
	END
ELSE 
	BEGIN
		PRINT 'O cliente não foi informado.';
	END

DECLARE @Contador INT = 1;

WHILE @Contador <= 5
	BEGIN
		PRINT 'Iteração: ' + CAST(@Contador AS VARCHAR(2));
		SET @Contador = @Contador + 1;
	END

SELECT  ca.Id as Identificador,
		ca.Nome as Nome,
		CASE	
			WHEN ca.Id <= 2 THEN 'Cliente Corporativo (VIP)'
			ELSE 'Cliente Físico (Regular)'
		END as Categoria
	FROM [dbo].[Cliente] AS ca WITH(NOLOCK);
