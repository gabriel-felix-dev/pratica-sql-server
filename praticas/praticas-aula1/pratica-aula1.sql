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

-- Caso A: Controle de Fila e Processamento em Lote (Job de Entrega)

DECLARE @IdPedidoAtual INT;

CREATE TABLE #FilaFaturamento  (
									IdPedido INT 
							   );

INSERT INTO #FilaFaturamento (IdPedido)
	SELECT  Id
		FROM [dbo].[Pedido] WITH(NOLOCK)
		WHERE DataEntrega IS NULL
		ORDER BY DataPromessa ASC;

WHILE EXISTS  (
			     SELECT TOP 1 1
					FROM #FilaFaturamento
              )
	BEGIN
	
		SELECT  TOP 1 @IdPedidoAtual = IdPedido
			FROM #FilaFaturamento;

	PRINT 'Processando baixa de faturamento e estoque do Pedido ID: ' + CAST(@IdPedidoAtual AS VARCHAR(10));

	DELETE TOP (1)
		FROM #FilaFaturamento;

		SET @IdPedidoAtual = NULL;

	END

DROP TABLE #FilaFaturamento;

-- Exercício 1

DECLARE @IdPedido INT;
DECLARE @DataPromessaPedido DATE;
DECLARE @DataEntregaPedido DATE;

SET @IdPedido = 1;

CREATE TABLE #Pedido (
					    IdPedido INT,
						IdCliente INT,
						DataPedido DATE,
						DataPromessa DATE,
						DataEntrega DATE
					 )
INSERT INTO #Pedido (IdPedido, IdCliente, DataPedido, DataPromessa, DataEntrega)
 SELECT  TOP 1 *
	FROM [dbo].[Pedido] AS pe WITH(NOLOCK)
	WHERE pe.Id = @IdPedido;

IF NOT EXISTS (
				 SELECT  TOP 1 1
					 FROM #Pedido
			  )
	BEGIN
		PRINT 'Erro: Pedido de ID ' + CAST(@IdPedido AS VARCHAR(4)) + ' não encontrado no sistema.';
	END

SELECT @DataEntregaPedido = pe.DataEntrega,
	   @DataPromessaPedido = pe.DataPromessa
	FROM #Pedido AS pe;

IF EXISTS (
			 SELECT  TOP 1 1
			 	 FROM #Pedido
			 	 WHERE DataEntrega IS NULL  
		   )
	BEGIN
		PRINT 'Pedido ' + CAST(@IdPedido AS VARCHAR(4)) + ' pendente de entrega. Prazo prometido: ' + CAST(@DataPromessaPedido AS VARCHAR);
	END

--UPDATE #Pedido
--	SET DataEntrega = '2026-07-03'
--	WHERE IdPedido = @IdPedido;

--SELECT @DataEntregaPedido = pe.DataEntrega,
--	   @DataPromessaPedido = pe.DataPromessa
--	FROM #Pedido AS pe;

IF EXISTS (
             SELECT   TOP 1 1
				FROM #Pedido
				WHERE DataEntrega IS NOT NULL
		  )
	BEGIN
		PRINT 'Pedido ' + CAST(@IdPedido AS VARCHAR) + ' entregue com sucesso em: ' + CAST(@DataEntregaPedido AS VARCHAR);
	END

DROP TABLE #Pedido;
