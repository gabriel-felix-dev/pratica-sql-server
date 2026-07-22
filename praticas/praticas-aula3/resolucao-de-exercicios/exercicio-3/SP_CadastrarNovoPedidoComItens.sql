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
		Ex.......................: DBCC FREEPROCCACHE
								   DBCC DROPCLEANBUFFERS

								   DECLARE @DataInicio DATETIME = GETDATE(),
										   @Retorno INT,
										   @IdPedidoNovo INT;

								   SELECT  TOP 5 *
								       FROM [dbo].[Cliente] WITH(NOLOCK);

								   SELECT  TOP 5 *
									   FROM [dbo].[Produto] WITH(NOLOCK);
                                   
								   SELECT  TOP 5 *
									   FROM [dbo].[Pedido] WITH(NOLOCK)
									   ORDER BY Id DESC;

								   SELECT  TOP 5 *
									   FROM [dbo].[ItemPedido] WITH(NOLOCK)
									   ORDER BY Id DESC;

								   EXEC @Retorno = [dbo].[SP_CadastrarNovoPedidoComItens] @IdCliente = 2, @IdProduto = 2, @Quantidade = 10, @PrazoDias = 10, @IdPedidoGerado = @IdPedidoNovo OUTPUT;
								   
								   SELECT  @Retorno as RetornoDeExecucao,
										   @IdPedidoNovo as NovoId;

								   SELECT  TOP 5 *
									   FROM [dbo].[Pedido] WITH(NOLOCK)
									   ORDER BY Id DESC;

								   SELECT  TOP 5 *
									   FROM [dbo].[ItemPedido] WITH(NOLOCK)
									   ORDER BY Id DESC;

								   SELECT  DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) as TempoExecucao

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
		IF @Quantidade <= 0 
			BEGIN
				RETURN 3
			END

		-- Inserir na tabela as informações do novo Pedido
		INSERT INTO Pedido (IdCliente, DataPedido, DataPromessa) VALUES	
			(@IdCliente, CAST(GETDATE() AS DATE), DATEADD(DAY, @PrazoDias, CAST(GETDATE() AS DATE)));

		-- Captura o último Id em Pedido criado
		SET @IdPedidoGerado = SCOPE_IDENTITY();

		-- Insere o Pedido gerado na tabela de ItemPedido
		INSERT INTO ItemPedido (IdPedido, IdProduto, Quantidade) VALUES
			(@IdPedidoGerado, @IdProduto, @Quantidade);

		-- Confirmação de sucesso
		RETURN 0
	END
GO

DECLARE @NovoId INT,
		@Retorno INT;

EXEC @Retorno  = SP_CadastrarNovoPedidoComItens @IdCliente = 1, @IdProduto = 2, @Quantidade = 10, @PrazoDias = -5, @IdPedidoGerado = @NovoId OUTPUT;

SELECT  @NovoId as IdNovoPedido,
		@Retorno as RetornoExecucao;
