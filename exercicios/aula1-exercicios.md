# Aula 1: T-SQL Essencial e Tabelas Temporárias

Nesta lista de exercícios, você colocará em prática os conceitos de variáveis, estruturas de controle (IF...ELSE, WHILE, CASE WHEN), variáveis de tabela e tabelas temporárias usando o banco de dados woodcraft.

---

## Exercício 1: Validador de Status de Pedido

### Cenário:
O setor de atendimento ao cliente da WoodCraft precisa de um script rápido para verificar a situação de entrega de um determinado pedido no banco de dados.

### Requisitos:
1. Declare uma variável chamada @IdPedido do tipo INT e atribua um valor a ela (ex: 1, 2 ou 99).
2. O script deve consultar a tabela Pedido para obter as informações do pedido associado a este ID.
3. Utilizando a estrutura IF...ELSE, implemente as seguintes validações:
   - Caso o pedido não exista: Exiba a mensagem: "Erro: Pedido de ID [X] não encontrado no sistema."
   - Caso o pedido exista e ainda não tenha sido entregue (DataEntrega é NULL): Exiba a mensagem: "Pedido [X] pendente de entrega. Prazo prometido: [DataPromessa]."
   - Caso o pedido já tenha sido entregue (DataEntrega não é NULL): Exiba a mensagem: "Pedido [X] entregue com sucesso em: [DataEntrega]."
4. Use a instrução PRINT para exibir as mensagens na aba de mensagens do SSMS.

---

## Exercício 2: Notificação de Pedidos Atrasados

### Cenário:
O setor de PCP (Planejamento e Controle de Produção) precisa de um relatório diário exibido no console com a lista de pedidos que estão com a entrega atrasada (ou seja, pedidos sem DataEntrega cuja DataPromessa seja anterior à data atual).

### Requisitos:
1. Declare uma variável de tabela (@PedidosAtrasados) que contenha as colunas: IdPedido INT, NomeCliente VARCHAR(100) e DiasAtraso INT.
2. Insira nessa variável de tabela todos os pedidos que atendam aos critérios de atraso (não entregues e com data de promessa menor que hoje). Calcule a quantidade de dias de atraso utilizando a função DATEDIFF(day, DataPromessa, GETDATE()).
3. Utilizando um laço de repetição WHILE (sem usar cursores tradicionais do SQL Server), percorra cada registro inserido na variável de tabela e exiba uma linha de texto no console no seguinte formato:
   "ALERTA: O Pedido ID [IdPedido] do cliente [NomeCliente] está atrasado em [DiasAtraso] dias."
4. Certifique-se de que a variável de controle do loop seja limpa corretamente a cada iteração para evitar loops infinitos.

---

## Exercício 3: Entrada de Insumos via JSON e Validação

### Cenário:
A WoodCraft recebe dados de reabastecimento de matéria-prima em lote através de mensagens JSON enviadas pelo sistema de compras da matriz. Você deve desenvolver um script capaz de validar e processar essas entradas de estoque com segurança.

### Requisitos:
1. Declare uma variável chamada @InsumosJSON do tipo NVARCHAR(MAX) e atribua a ela uma string contendo um JSON com o lote de reabastecimento. Exemplo para testes:
   ```sql
   DECLARE @InsumosJSON NVARCHAR(MAX) = N'[
       {"IdMateriaPrima": 1, "QuantidadeAdicional": 50},
       {"IdMateriaPrima": 2, "QuantidadeAdicional": 200},
       {"IdMateriaPrima": 3, "QuantidadeAdicional": 15}
   ]';
   ```
2. Crie uma tabela temporária local chamada #NovosInsumos para receber a decodificação dos dados.
3. Utilize a função OPENJSON para extrair os campos IdMateriaPrima e QuantidadeAdicional do JSON e inseri-los na tabela #NovosInsumos.
4. Validação Cruzada: Antes de aplicar qualquer atualização no estoque, verifique se existe algum IdMateriaPrima informado no JSON que não esteja cadastrado na tabela física MateriaPrima.
   - Se houver algum insumo inexistente, exiba a mensagem de erro: "Erro: O insumo de ID [X] não existe no catálogo do sistema. Operação cancelada." (mostre o ID do insumo inválido).
   - Se houver erro, limpe a tabela temporária e interrompa a execução do lote imediatamente com RETURN.
5. Processamento em Loop: Caso todos os insumos sejam válidos, utilize um laço WHILE EXISTS combinado com DELETE TOP (1) para percorrer os registros da tabela temporária #NovosInsumos linha a linha. Para cada item:
   - Atualize a tabela EstoqueMateriaPrima, somando a QuantidadeAdicional à quantidade física disponível (QuantidadeFisica).
   - Insira uma movimentação na tabela MovimentacaoEstoqueMateriaPrima com IdTipoMovimentacao = 1 (Entrada), DataMovimentacao = GETDATE() e a respectiva quantidade inserida.
   - Busque o nome do insumo e imprima a mensagem: "Estoque do insumo [NomeInsumo] atualizado. Quantidade adicionada: [QuantidadeAdicional]."
6. Garanta que a tabela temporária seja excluída (DROP TABLE) no final da rotina, mesmo se houver interrupções.
