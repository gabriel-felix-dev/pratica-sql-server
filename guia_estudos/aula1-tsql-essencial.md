# Semana 1: T-SQL Essencial e Tabelas Temporárias

Bem-vindo à primeira semana do módulo de SQL Programação! Nesta semana, aprenderemos sobre a lógica de programação dentro do SQL Server usando T-SQL (Transact-SQL). Vamos explorar variáveis, estruturas de controle de fluxo e o uso de tabelas temporárias, vendo como tudo isso se aplica ao nosso cenário da **WoodCraft (Fábrica de Móveis Customizados)**.

---

## 1. Conceitos Teóricos

### 1.1. Variáveis em T-SQL
No SQL Server, podemos declarar variáveis para armazenar valores temporários durante a execução de um script, procedure ou função. 
*   **Declaração:** Usamos a palavra-chave `DECLARE` acompanhada do caractere `@` antes do nome da variável.
*   **Atribuição:** Podemos atribuir valores usando `SET` ou diretamente em uma consulta `SELECT`.

```sql
-- Exemplo de Declaração e Atribuição
DECLARE @IdCliente INT;
DECLARE @NomeCliente VARCHAR(100);

-- Atribuição simples com SET
SET @IdCliente = 1;

-- Atribuição via SELECT (útil para trazer dados de tabelas)
SELECT	@NomeCliente = Nome 
	FROM [dbo].[Cliente] WITH(NOLOCK)
	WHERE Id = @IdCliente;

PRINT @NomeCliente; -- Exibe o valor na aba de mensagens
```

### 1.2. Controle de Fluxo

#### IF...ELSE
Utilizado para executar um bloco de código caso uma condição seja verdadeira. Se o bloco possuir mais de uma instrução, ele **deve** estar envolvido por `BEGIN` e `END`.

```sql
IF @IdCliente IS NOT NULL
	BEGIN
		PRINT 'O cliente foi informado.';
		-- Outras instruções SQL aqui...
	END
ELSE
	BEGIN
		PRINT 'O cliente não foi informado.';
	END
```

#### WHILE
O T-SQL não possui laços do tipo `FOR`. Toda a repetição (loops) é feita utilizando a estrutura `WHILE`.

```sql
DECLARE @Contador INT = 1;

WHILE @Contador <= 5
	BEGIN
		PRINT 'Iteração: ' + CAST(@Contador AS VARCHAR(2));
		SET @Contador = @Contador + 1;
	END
```

#### CASE WHEN
O `CASE` é uma expressão avaliada em tempo de execução que retorna um valor específico com base em condições. Pode ser usado em SELECTs ou em atribuições.

```sql
		SELECT	Id,
				Nome,
				CASE 
					WHEN Id <= 2 THEN 'Cliente Corporativo (VIP)'
					ELSE 'Cliente Físico (Regular)'
				END AS Categoria
			FROM [dbo].[Cliente] WITH(NOLOCK);
```

### 1.3. Tabelas Temporárias vs. Variáveis de Tabela

Quando precisamos manipular conjuntos de dados intermediários, temos duas opções principais:

| Característica | Tabela Temporária (`#Tabela`) | Variável de Tabela (`@Tabela`) |
| :--- | :--- | :--- |
| **Sintaxe de Criação** | `CREATE TABLE #NomeTabela (Colunas...)` | `DECLARE @NomeTabela TABLE (Colunas...)` |
| **Onde fica armazenada?** | No banco de dados do sistema `tempdb` (em disco/buffer). | Principalmente na memória (pode ir para o `tempdb` se os dados crescerem). |
| **Escopo** | Visível em todo o lote de execução e sub-procedimentos da sessão. | Restrita apenas ao lote local de execução (bloco de código atual). |
| **Performance e Índices** | Permite criação de índices não-clustered pós-criação e estatísticas completas. | Permite apenas restrições (ex: `PRIMARY KEY`) na própria declaração; sem estatísticas. |
| **Uso Recomendado** | Grandes volumes de dados (milhares ou milhões de linhas). | Pequenos conjuntos de dados (geralmente abaixo de 10.000 linhas). |

---

## 2. Estudo de Caso Prático: WoodCraft

Vamos ver como esses recursos são utilizados em rotinas reais de banco de dados do nosso cenário.

### Caso A: Controle de Fila e Processamento em Lote (Job de Entrega)
Imagine que a WoodCraft possua um Job que roda todas as noites para verificar quais pedidos prontos podem ser entregues de forma automática e dar baixa no estoque dos respectivos móveis.

O script a seguir implementa esse processamento sequencial de fila utilizando uma tabela temporária `#FilaFaturamento` e um laço `WHILE EXISTS`:

```sql
-- Declarando variável para controle do loop
DECLARE @IdPedidoAtual INT;

-- Criando tabela temporária local para armazenar a fila do dia
CREATE TABLE #FilaFaturamento	(
									IdPedido INT
								)

-- Inserir na tabela todos os IDs de pedidos que ainda não foram entregues,
-- ordenados pela data de promessa mais urgente (FIFO)
INSERT INTO #FilaFaturamento (IdPedido)
	SELECT	Id
		FROM [dbo].[Pedido] WITH(NOLOCK)
		WHERE DataEntrega IS NULL
		ORDER BY DataPromessa ASC;

-- Loop WHILE que roda enquanto houver pedidos na tabela temporária
WHILE EXISTS	(
					SELECT TOP 1 1
						FROM #FilaFaturamento
				)
	BEGIN
		-- Captura o ID do primeiro pedido da fila
		SELECT TOP 1 @IdPedidoAtual = IdPedido
			FROM #FilaFaturamento;

		-- Simulação: Imprime qual pedido está sendo processado
		PRINT 'Processando baixa de faturamento e estoque do Pedido ID: ' + CAST(@IdPedidoAtual AS VARCHAR(10));

		-- [Aqui rodaria a Procedure de faturamento real de estoque do pedido]

		-- Deleta o pedido atual da fila temporária para avançar o laço
		DELETE TOP (1)
			FROM #FilaFaturamento;
		
		-- Limpa a variável de controle para a próxima iteração
		SET @IdPedidoAtual = NULL;
	END

-- Remove a tabela temporária do tempdb
DROP TABLE #FilaFaturamento;
```

**Vantagem desse padrão:** 
O uso de `#Tabela` com `WHILE EXISTS` + `DELETE TOP (1)` é o padrão corporativo preferido em relação a **Cursores** no SQL Server, pois evita travamentos prolongados (locks) e consumo exagerado de memória.

---

### Caso B: Validações e OPENJSON na Inserção de Itens
Quando uma API envia dados para o SQL Server cadastrar um novo pedido, geralmente os itens do pedido (móvel e quantidade) vêm agrupados em um formato JSON. 

Veja como usar tabelas temporárias para validar e decodificar dados em JSON:

```sql
DECLARE @IdCliente INT = 1,
		@DataPromessa DATE = '2026-07-15',
		-- JSON enviado pela aplicação com os itens
		@ItensJSON NVARCHAR(MAX) = N'[
			{"IdProduto": 1, "Quantidade": 5},
			{"IdProduto": 2, "Quantidade": 1}
		]';

-- 1. Validação simples de Fluxo
IF NOT EXISTS	(
					SELECT TOP 1 1
						FROM [dbo].[Cliente] WITH(NOLOCK)
						WHERE Id = @IdCliente
				)
	BEGIN
		PRINT 'Erro: Cliente inexistente!';
		RETURN;
	END

-- 2. Criação de tabela temporária para receber a decodificação do JSON
CREATE TABLE #ItensTemp	(
							IdProduto INT,
							Quantidade INT
						)

-- 3. Decodificar JSON usando OPENJSON e inserir na tabela temporária
INSERT INTO #ItensTemp (IdProduto, Quantidade)
	SELECT	IdProduto,
			Quantidade
		FROM OPENJSON(@ItensJSON)
			WITH (
				IdProduto INT '$.IdProduto',
				Quantidade INT '$.Quantidade'
			);

-- 4. Validação Cruzada: Verifica se algum produto inserido no JSON é inválido
IF EXISTS	(
				SELECT TOP 1 1 
					FROM #ItensTemp item
						LEFT JOIN [dbo].[Produto] prod WITH(NOLOCK)
							ON item.IdProduto = prod.Id
					WHERE prod.Id IS NULL
			)
	BEGIN
		PRINT 'Erro: Um ou mais produtos informados no JSON não existem no catálogo!';
		DROP TABLE #ItensTemp;
		RETURN;
	END

PRINT 'Validações com sucesso! Pronto para inserção na tabela final.';
DROP TABLE #ItensTemp;
```

---

## 3. Desafio da Semana 🚀

Sua tarefa nesta primeira semana é criar um script de monitoramento para a gerência de estoque de insumos (matéria-prima) da WoodCraft.

### Requisitos:
1.  Declare duas variáveis: `@IdMateriaPrima` (tipo `INT`) e `@QuantidadeSolicitada` (tipo `INT`).
2.  O script deve consultar as tabelas `MateriaPrima` e `EstoqueMateriaPrima` e realizar as seguintes checagens utilizando `IF...ELSE` e `PRINT`:
    *   **Cenário A (Matéria-prima Inexistente):** Se a matéria-prima com o ID informado não existir na tabela `MateriaPrima`, exiba a mensagem: `Erro: Matéria-prima de ID [X] não cadastrada no catálogo.`
    *   **Cenário B (Estoque Suficiente):** Se a quantidade física disponível (`QuantidadeFisica`) for igual ou superior à `@QuantidadeSolicitada`, exiba a mensagem: `Estoque OK para o insumo [Nome]. Disponível: [QtdFisica] | Solicitado: [QtdSolicitada].`
    *   **Cenário C (Estoque Insuficiente):** Se a quantidade física disponível for menor que a solicitada, exiba a mensagem: `Alerta: Estoque insuficiente de [Nome]. Faltam [Diferenca] unidades para atender à solicitação.`

### Estrutura para Desenvolvimento:
```sql
USE woodcraft;
GO

DECLARE @IdMateriaPrima INT = 1, -- Madeira de Carvalho
		@QuantidadeSolicitada INT = 200; -- Altere aqui para testar os cenários

-- Insira sua consulta e lógica IF...ELSE aqui!
```

---
*Dica: Teste alterando `@IdMateriaPrima` para 1, 3 ou um ID que não exista (ex: 99), e altere a `@QuantidadeSolicitada` para testar os alertas de falta de estoque.*
