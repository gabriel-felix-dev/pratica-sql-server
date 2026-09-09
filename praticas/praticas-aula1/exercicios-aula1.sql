USE WoodCraft;
GO

---------------------------------- Caso de estudo A

-- declara var para controle do while 

DECLARE @IdPedidoAtual INT;

-- cria tablea temp local p armazenar a fila do dia

CREATE TABLE #FilaFaturamento	(
                                    IdPedido INT
                                );

-- Inseria na tabela todos os ID's de pedidos não entregues
-- ordenados pela data de promessa mais urgente (FIFO)

INSERT INTO #FilaFaturamento (IdPedido)
    SELECT  Id  
        FROM [dbo].[Pedido] WITH(NOLOCK)
        WHERE DataEntrega IS NULL
        ORDER BY DataPromessa ASC;

-- Loop While que roda enquanto houver pedidos na table
-- temporária

WHILE EXISTS    (
                    SELECT TOP 1 1
                        FROM #FilaFaturamento
                )
    BEGIN
        -- Captura o ID do primeiro pedido da fila
        SELECT  TOP 1 @IdPedidoAtual = IdPedido 
            FROM #FilaFaturamento

        -- simula: imprime qual pedido está sendo processado
        PRINT 'Processando baixa de faturamento de estoque do Pedido Id: ' + CAST(@IdPedidoAtual AS VARCHAR);
    
        -- Deleta o pedido atual da fila temporária para avançar o laço
        DELETE TOP(1)
            FROM #FilaFaturamento;

        -- Limpa a variável
        SET @IdPedidoAtual = NULL
    END

DROP TABLE #FilaFaturamento;


---------------------------------------- Exercícios 01 e 02

-- Exercício 01

-- Objetivo verificcar a situação de entrega de im pedido especifico

-- declara var que terá o Id do pedido

DECLARE @IdPedido INT = 1,
        @DataPromessa DATE,
        @DataEntrega DATE;

-- Cria um tabela temp para armazenar as infos de um pedido

CREATE TABLE #InformacoesPedido  (
                                    IdPedido INT,
                                    DataPromessa DATE,
                                    DataEntrega DATE
                                 );

-- Insere na tabela temp as info do pedido
INSERT INTO #InformacoesPedido (IdPedido, DataPromessa, DataEntrega)
    SELECT  pe.Id,
            pe.DataPromessa,
            pe.DataEntrega
        FROM [dbo].[Pedido] AS pe WITH(NOLOCK)
        WHERE pe.Id = @IdPedido;

-- Valida se o pedido existe

IF NOT EXISTS  (
                  SELECT  TOP 1 1 
                      FROM #InformacoesPedido
               )
    BEGIN 
        PRINT 'Pedido de Id: ' + CAST(@IdPedido AS VARCHAR) + ' não encontrado no sistema'
    END

-- Faz consulta na tabela temp e armazenas as datas de promessa e entrega nas respectivas var's

SELECT  @DataPromessa = DataPromessa,
        @DataEntrega = DataEntrega
    FROM #InformacoesPedido;

-- Valida se o pedido ainda não foi entregue

IF EXISTS  (
              SELECT  1
                  FROM #InformacoesPedido
                  WHERE DataEntrega IS NULL
           )
    BEGIN
        PRINT 'Pedido ' + CAST(@IdPedido AS VARCHAR) + ' pendente de entrega. Prazo prometido: ' + CAST(@DataPromessa AS VARCHAR)
    END

-- Valida de o pedido já foi entregue

IF @DataEntrega <> NULL
    BEGIN
        PRINT 'Pedido ' + CAST(@IdPedido AS VARCHAR) + ' entregue com sucesso em: ' + CAST(@DataEntrega AS VARCHAR)
    END

DROP TABLE #InformacoesPedido;

------------------------------------------------------------------------------------------------------------------------------------------------------

-- Exercício 2

-- Objetivo: relatprio diario com a lista de pedidos com entregas atrasadas

-- Cria var tabela para receber os pedidos atrasados

DECLARE @PedidosAtrasados TABLE  (
                                    IdPedido INT,
                                    NomeCliente VARCHAR(100),
                                    DiasAtraso INT
                                 );

-- Declara var para armazenar o IdPedido, os dias em atraso, nome do cliente, quantidade de itens para o loop e contador loop

DECLARE @IdPedido2 INT,
        @DiasAtraso INT,
        @NomeCliente VARCHAR(100),
        @QuantidadePedidosAtrasados INT,
        @ContadorLoop INT = 0

-- Insere na tabela var os pedidos atrasados

INSERT INTO @PedidosAtrasados (IdPedido, NomeCliente, DiasAtraso)
    SELECT  pe.Id,
            cl.Nome,
            DATEDIFF(DAY, pe.DataPromessa, GETDATE())
        FROM [dbo].[Pedido] AS pe WITH(NOLOCK)
            INNER JOIN [dbo].[Cliente] AS cl WITH(NOLOCK)
                ON cl.Id = pe.IdCliente
        WHERE pe.DataEntrega IS NULL
            AND pe.DataPromessa < GETDATE();

-- Consulta para armazenar a quantidade de itens na tabela var

SELECT  @QuantidadePedidosAtrasados = COUNT(*)
    FROM @PedidosAtrasados;

-- Loop para impressão de pedidos atrasados

WHILE @ContadorLoop < @QuantidadePedidosAtrasados
    BEGIN
       -- Consulta para armazenar os dados na vars

       SELECT  TOP 1 @IdPedido2 = IdPedido,
                     @NomeCliente = NomeCliente,
                     @DiasAtraso = DiasAtraso
           FROM @PedidosAtrasados
        
        PRINT 'Pedido ID: ' + CAST(@IdPedido2 AS VARCHAR) + ' do cliente ' + CAST(@NomeCliente AS VARCHAR) + ' está atraso em ' + CAST(@DiasAtraso AS VARCHAR) + ' dias.'
        
        -- Adiciona incrementa a var do contador
        SET @ContadorLoop = @ContadorLoop + 1
        
        -- Apaga da tabela var o pedido já impresso
        DELETE FROM @PedidosAtrasados
            WHERE IdPedido = @IdPedido2
    END

-- Altera a tabela de Pedido para ver outros resultados

UPDATE Pedido   
    SET DataPromessa = '2026-07-01'
    WHERE Id IN (2, 4);

-- Visualização das alterações
SELECT  * 
    FROM Pedido

-- Volta a tabela aos dados anteriores
UPDATE Pedido   
    SET DataPromessa = '2026-07-14'
    WHERE Id = 2;

UPDATE Pedido
    SET DataPromessa = '2026-07-21'
    WHERE Id = 4;

-- Visualização das alterações
SELECT  * 
    FROM Pedido

------------------------------------------------------------------------------------------------------------------------------------------------------

-- Desafio 

-- Objetivo: Script de monitoramente de estoque de insumos (matéria-prima)

SELECT  *
    FROM MateriaPrima;

SELECT  *
    FROM EstoqueMateriaPrima;

-- Declara var

DECLARE @IdMateriaPrima INT = 1,
        @QuantidadeSolicitada INT = 20,
        @NomeMateriaPrima VARCHAR(100),
        @QuantidadeFisicaEstoqueMateriaPrima INT,
        @DiferencaMateriaSolitacao INT;

-- Verifica se a matéria-prima existe no sistema

IF NOT EXISTS  (
                  SELECT  1
                      FROM [dbo].[MateriaPrima] AS mp WITH(NOLOCK)
                      WHERE mp.Id = @IdMateriaPrima
               )
    BEGIN
        PRINT 'Erro: Matéria-Prima de ID ' + CAST(@IdMateriaPrima AS VARCHAR) + ' não está cadastrada no catálogo'    
    END

-- Consulta para armazenar nas vars de retorno: Nome da matéria-prima, quantidade física do estoque e a difenrença quando o for menor que a quantidade solicitada

SELECT  @NomeMateriaPrima = mp.Nome,
        @QuantidadeFisicaEstoqueMateriaPrima = ep.QuantidadeFisica,
        @DiferencaMateriaSolitacao = @QuantidadeSolicitada - @QuantidadeFisicaEstoqueMateriaPrima 
    FROM [dbo].[MateriaPrima] AS mp WITH(NOLOCK)
        INNER JOIN [dbo].[EstoqueMateriaPrima] AS ep WITH(NOLOCK)
            ON ep.IdMateriaPrima = mp.Id
    WHERE mp.Id = @IdMateriaPrima

-- Verifica quantidade física disponível é suficiente

IF @QuantidadeFisicaEstoqueMateriaPrima >= @QuantidadeSolicitada
    BEGIN
        PRINT 'Estoque OK para insumo ' + @NomeMateriaPrima + '. Disponível: ' + CAST(@QuantidadeFisicaEstoqueMateriaPrima AS VARCHAR) + ' | Solicitado: ' + CAST(@QuantidadeSolicitada AS VARCHAR) 
    END

-- Verifica se o estoque é insuficiente

IF @QuantidadeFisicaEstoqueMateriaPrima < @QuantidadeSolicitada
    BEGIN
        PRINT 'Alerta: Estoque insuficiente de ' + @NomeMateriaPrima + '. Faltam ' + CAST(@DiferencaMateriaSolitacao AS VARCHAR) + ' unidades para atender à solicitação'
    END
