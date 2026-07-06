USE WoodCraft;

-- Declaração de variáveis

DECLARE @IdCliente INT;
DECLARE @NomeCliente VARCHAR(100);

SET @IdCliente = 1;

SELECT  @NomeCliente = Nome
	FROM [dbo].[Cliente] WITH(NOLOCK)
	WHERE Id = @IdCliente;

PRINT @NomeCliente;

-- IF / ELSE

IF @IdCliente IS NOT NULL
	BEGIN 
		PRINT 'O cliente foi informado.';
	END
ELSE 
	BEGIN
		PRINT 'O cliente não foi informado.';
	END

-- WHILE

DECLARE @Contador INT = 1;

WHILE @Contador <= 5
	BEGIN
		PRINT 'Iteração: ' + CAST(@Contador AS VARCHAR(2));
		SET @Contador = @Contador + 1;
	END

-- CASE WHEN

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

-- Teste

-- Uma tabela temporária será criada com uma informação dentro. Um loop será rodado. Enquanto esse loop for menor que 5, a tabela temporária não poderá ser excluída.

DECLARE @Iterador INT = 0;

CREATE TABLE #TabelaTemporaria(
							     IdPedido INT
                              );

INSERT INTO #TabelaTemporaria (IdPedido)
	SELECT  pe.Id
		FROM Pedido AS pe WITH(NOLOCK);

WHILE @Iterador < 5
	BEGIN 
		PRINT 'Valor do contador: ' + CAST(@Iterador AS VARCHAR)
		SET @Iterador = @Iterador + 1;
	END;

IF @Iterador = 5
	BEGIN
		DROP TABLE #TabelaTemporaria;
		PRINT 'Tabela deletada'
	END;

-- Exercício 2

SELECT  *
	FROM Pedido AS pe WITH(NOLOCK)

SELECT  *
	FROM Cliente AS cl WITH(NOLOCK)

DECLARE @IdPedido2 INT; 
DECLARE @NomeCliente2 VARCHAR(100);
DECLARE @DiasAtraso INT;
DECLARE @ContadorLoop INT = 1;
DECLARE @TotalPedidos INT;

DECLARE @PedidosAtrasados TABLE (
								   IdPedido INT,
								   NomeCliente VARCHAR(100),
								   DiasAtraso INT
							    );

INSERT INTO @PedidosAtrasados (IdPedido, NomeCliente, DiasAtraso)
	SELECT  pe.Id as IdentificadorPedido,
			cl.Nome as Cliente,
			DATEDIFF(DAY, pe.DataPromessa, GETDATE()) as DiasEmAtraso
		FROM Pedido AS pe WITH(NOLOCK)
			INNER JOIN Cliente AS cl WITH(NOLOCK)
				ON cl.Id = pe.IdCliente
		WHERE pe.DataEntrega IS NULL
			AND pe.DataPromessa < GETDATE();

SELECT  @TotalPedidos = COUNT(*) 
	FROM @PedidosAtrasados;
	
WHILE @ContadorLoop <= @TotalPedidos
	BEGIN
		SELECT  TOP 1 @IdPedido2 = IdPedido,
				@NomeCliente2 = NomeCliente,
				@DiasAtraso = DiasAtraso
		FROM @PedidosAtrasados
		WHERE IdPedido = @ContadorLoop;

		IF @IdPedido2 IS NOT NULL
			BEGIN 
				PRINT'O Pedido ID ' + CAST(@IdPedido2 AS VARCHAR) + ' do cliente ' + CAST(@NomeCliente2 AS VARCHAR) + ' está atrasado em ' + CAST(@DiasAtraso AS VARCHAR) + ' dias.';
			END

		SET @ContadorLoop = @ContadorLoop + 1;
	END
