USE WoodCraft;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_CadastrarNovoPedidoComItens]
	@IdCliente INT,
	@IdProduto INT,
	@Quantidade INT,
	@PrazoDias INT,
	@IdPedidoGerado INT OUTPUT
	AS
	/*
		Documentacao
		Arquivo Fonte............: SP_CadastrarNovoPedidoComItens.sql
		Objetivo.................: Realizar a criação de um pedido e retornar o Id gerado para esse novo pedido
		Autor....................: Gabriel Felix
		Data.....................: 21/07/2026
		Ex.......................: DBCC FREEPROCACHE
								   DBCC DROPCLEANBUFFERS

								   DECLARE @DataInicio DATETIME = GETDATE(),
										   @Retorno INT,
										   @IdPedidoNovo INT;

								   SELECT  TOP 5 *
								       FROM [dbo].[Cliente] WITH(NOLOCK);

								   SELECT  TOP 5 *
									   FROM [dbo].[Produto] WITH(NOLOCK);

								   EXEC @Retorno = [dbo].[SP_CadastrarNovoPedidoComItens] @IdCliente = 1, @IdProduto = 1, @Quantidade = 10, @IdPedidoGerado = @IdPedidoNovo;
								   
								   PRINT 'O Id do novo Pedido é: ' + CAST(@IdPedidoNovo AS VARCHAR);

		Retorno..................: 0 - Sucesso
								   1 - Erro: Cliente não cadastrado
								   2 - Erro: Produto não cadastrado
								   3 - Erro: A quantidade informada deve ser maior que 0 (zero)
	*/
	BEGIN
		-- Validacao do Cliente
		IF NOT EXISTS (
						 SELECT  TOP 1 1
							FROM [dbo].[Cliente] WITH(NOLOCK)
							WHERE Id = @IdCliente
					  )
			BEGIN
				RETURN 1
			END

		-- Validacao do Produto
		IF NOT EXISTS (
						 SELECT  TOP 1 1
							FROM [dbo].[Produto] WITH(NOLOCK)
							WHERE Id = @IdProduto
					  )
			BEGIN
				RETURN 2
			END

		-- Validacao da Quantidade
		IF @Quantidade < 0 
			BEGIN
				RETURN 3
			END

		-- Inserir na tabela as informações do novo Pedido
		INSERT INTO Pedido (IdCliente, DataPedido, DataPromessa) VALUES	
			(@IdCliente, CAST(GETDATE() AS DATE), DATEADD(DAY, @PrazoDias, CAST(GETDATE() AS DATE)));

	END
GO

SELECT  TOP 10 *
	FROM Pedido WITH(NOLOCK);

SELECT  TOP 10 *
	FROM ItemPedido WITH(NOLOCK);
