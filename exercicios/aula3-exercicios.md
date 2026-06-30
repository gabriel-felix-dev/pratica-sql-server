# Aula 3: Stored Procedures, Funções (Escalares e Table-Valued) e Views

Nesta lista de exercícios, você colocará em prática a modularização do banco de dados, criando views para simplificar relatórios, funções escalares para cálculos isolados de negócio e stored procedures parametrizadas para gravação de dados.

---

## Exercício 1: View de Painel Financeiro e de Expedição

### Cenário:
O departamento comercial e de faturamento da WoodCraft precisa de uma visualização consolidada e sempre atualizada do andamento dos pedidos para monitorar faturamentos e entregas atrasadas.

### Requisitos:
1. Crie uma View chamada VW_ResumoPedidosClientes.
2. A view deve retornar as seguintes colunas de dados das tabelas Pedido, Cliente e ItemPedido:
   - **IdPedido:** O identificador exclusivo do pedido.
   - **NomeCliente:** O nome do cliente associado ao pedido.
   - **DataPedido:** A data de emissão do pedido.
   - **QuantidadeItens:** A quantidade total acumulada de produtos solicitados naquele pedido (ou seja, a soma de Quantidade de todos os itens do pedido).
   - **StatusPedido:** Uma coluna calculada via CASE WHEN com as seguintes regras de negócio:
     - Se o pedido já possui DataEntrega preenchida, exibir: 'Entregue'.
     - Se DataEntrega está vazia (NULL) e a DataPromessa é anterior à data atual (GETDATE()), exibir: 'Atrasado'.
     - Se DataEntrega está vazia (NULL) e a DataPromessa é maior ou igual à data atual, exibir: 'Em Andamento'.
3. Garanta que a view execute o agrupamento necessário (GROUP BY) para obter a soma das quantidades dos itens de forma correta.

---

## Exercício 2: Função Escalar (UDF) de Estimativa de Tempo de Produção

### Cenário:
O gerente de vendas precisa simular o tempo de fabricação estimado de um móvel antes de fechar um contrato. Para isso, ele quer uma função rápida que some a duração estimada de todas as etapas de fabricação de um móvel.

### Requisitos:
1. Crie uma função escalar chamada FNC_CalcularTempoTotalFabricacaoMovel.
2. A função deve receber um único parâmetro de entrada: @IdProduto INT.
3. O retorno da função deve ser do tipo INT, representando a duração total em minutos.
4. A função deve calcular a soma de DuracaoMinutos de todas as etapas de fabricação (tabela EtapaFabricacao) associadas ao produto.
5. Utilize a função ISNULL() para garantir que, caso o produto informado não exista ou não tenha etapas de fabricação cadastradas, o retorno seja 0 (e não nulo).
6. Escreva um script de teste que consulte a tabela Produto e utilize a função criada para exibir o nome do produto e a duração de fabricação de cada um no catálogo.

---

## Exercício 3: Stored Procedure de Cadastro Unificado de Pedidos

### Cenário:
Para otimizar o fluxo de vendas do aplicativo WoodCraft, você deve criar uma stored procedure que realize a abertura de um pedido e a inserção de seu primeiro item de forma unificada e segura, validando as informações fornecidas.

### Requisitos:
1. Crie a Stored Procedure chamada SP_CadastrarNovoPedidoComItens com os seguintes parâmetros:
   - @IdCliente INT (entrada)
   - @IdProduto INT (entrada)
   - @Quantidade INT (entrada)
   - @PrazoDias INT (entrada - quantidade de dias a partir de hoje que representa a data prometida)
   - @IdPedidoGerado INT OUTPUT (parâmetro de saída que retornará o ID do novo pedido criado)
2. Implemente as seguintes validações e regras dentro do corpo da procedure:
   - **Validação de Cliente:** Verifique se o @IdCliente existe na tabela Cliente. Caso não exista, exiba a mensagem "Erro: Cliente não cadastrado." e encerre com RETURN -1.
   - **Validação de Produto:** Verifique se o @IdProduto existe na tabela Produto. Caso não exista, exiba a mensagem "Erro: Produto não cadastrado." e encerre com RETURN -2.
   - **Validação de Quantidade:** Verifique se a @Quantidade informada é maior do que zero. Caso não seja, exiba a mensagem "Erro: A quantidade informada deve ser maior que zero." e encerre com RETURN -3.
3. Se todas as validações forem bem-sucedidas, a procedure deve:
   - Inserir um registro na tabela Pedido, definindo a DataPedido como a data/hora atual e a DataPromessa como a data/hora atual acrescida dos dias de prazo (dica: utilize DATEADD(day, @PrazoDias, GETDATE())).
   - Recuperar o ID gerado para esse novo pedido usando a função SCOPE_IDENTITY() e atribuir esse valor ao parâmetro @IdPedidoGerado.
   - Inserir o item do pedido correspondente na tabela ItemPedido, relacionando o ID do pedido gerado, o @IdProduto e a @Quantidade informados.
   - Retornar o código 0 (RETURN 0) para indicar sucesso.
4. Escreva um script SQL mostrando como declarar a variável de retorno, executar a procedure e testar os cenários de erro e de sucesso.
