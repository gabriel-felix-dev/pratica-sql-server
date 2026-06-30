# Aula2: CTEs (Common Table Expressions) e Window Functions

Nesta semana, vamos elevar o nível das nossas consultas SQL. Vamos aprender a estruturar consultas complexas e legíveis usando **CTEs** e realizar análises avançadas de dados em linha (sem agrupar e perder o detalhe das linhas) usando as **Window Functions**. Ambas as ferramentas são extremamente poderosas e amplamente utilizadas em relatórios de controle de produção e logística na WoodCraft.

---

## 1. Conceitos Teóricos

### 1.1. Common Table Expressions (CTEs)

Uma CTE é um conjunto de resultados temporário nomeado que você pode referenciar dentro de uma única instrução `SELECT`, `INSERT`, `UPDATE` ou `DELETE`. Pense nela como uma "view temporária" que existe apenas durante a execução daquela query.

- **Vantagem:** Melhora significativamente a legibilidade do código, substituindo subconsultas (subqueries) aninhadas difíceis de ler.
- **Sintaxe Básica:**

```sql
WITH NomeDaCTE AS (
    SELECT Coluna1, Coluna2
    FROM Tabela
    WHERE Condicao
)
SELECT *
FROM NomeDaCTE;
```

#### CTEs Recursivas

Uma CTE recursiva é aquela que faz referência a si mesma. Ela é ideal para navegar em estruturas hierárquicas (como organogramas ou árvores de dependência de montagem de produtos). Ela requer:

1.  **Membro Âncora:** A consulta inicial (caso base).
2.  **UNION ALL:** Operador que une a âncora à parte recursiva.
3.  **Membro Recursivo:** A consulta que referencia a própria CTE, adicionando uma condição de parada para evitar loops infinitos.

---

### 1.2. Window Functions (Funções de Janela)

As Window Functions executam cálculos em um conjunto de linhas que estão relacionadas com a linha atual (a "janela"). Ao contrário do `GROUP BY`, elas **não** colapsam (agrupam) as linhas do resultado; cada linha mantém sua identidade individual no relatório.

- **Sintaxe Geral:**

```sql
FUNCAO() OVER (
    [PARTITION BY ColunaGrupo]
    [ORDER BY ColunaOrdenacao]
)
```

- `PARTITION BY`: Divide o conjunto de resultados em partições (grupos). Opcional.
- `ORDER BY`: Define a ordem dos dados dentro de cada partição.

#### Principais Funções de Ranking

- `ROW_NUMBER()`: Atribui um número inteiro sequencial e exclusivo para cada linha, iniciando em 1. Em caso de empate na ordenação, ele ainda assim gera números diferentes.
- `RANK()`: Atribui uma classificação. Em caso de empate, as linhas empatadas recebem a mesma classificação, mas há um **salto** na numeração seguinte (ex: 1, 2, 2, 4).
- `DENSE_RANK()`: Semelhante ao `RANK()`, porém **não há saltos** na numeração após os empates (ex: 1, 2, 2, 3).

#### Funções de Valor (Navegação)

- `LAG(Coluna, Deslocamento)`: Acessa um valor de uma linha anterior na janela.
- `LEAD(Coluna, Deslocamento)`: Acessa um valor de uma linha posterior na janela.

#### Funções Agregadas Acumuladas (Soma Acumulada)

Ao usar funções como `SUM()` ou `AVG()` com um `ORDER BY` na cláusula `OVER`, o SQL Server calcula a agregação acumulada (Running Total) linha a linha.

---

## 2. Estudo de Caso Prático: WoodCraft

### Caso A: Soma Acumulada para Saldo de Estoque Histórico

Imagine que precisamos gerar um relatório de estoque para entender como a quantidade física de um determinado insumo (ex: `Madeira de Carvalho`) variou ao longo do tempo com base no histórico de movimentações.

A consulta abaixo usa uma CTE para normalizar as movimentações e uma **Window Function** com soma acumulada para calcular o saldo corrente histórico:

```sql
		WITH HistoricoMovimentacoes AS (
			-- Normaliza as movimentações: Entradas somam (+), Saídas subtraem (-)
			-- TipoMovimentacao: 1 = Entrada, 2 = Saída
			SELECT	IdEstoqueMateriaPrima AS IdMateriaPrima,
					DataMovimentacao,
					Quantidade,
					CASE
						WHEN IdTipoMovimentacao = 1 THEN Quantidade
						WHEN IdTipoMovimentacao = 2 THEN -Quantidade
						ELSE 0
					END AS Variacao
				FROM [dbo].[MovimentacaoEstoqueMateriaPrima] WITH(NOLOCK)
		)
		SELECT	IdMateriaPrima,
				DataMovimentacao,
				Variacao,
				-- Soma acumulada ordenada por data
				SUM(Variacao) OVER (
					PARTITION BY IdMateriaPrima
					ORDER BY DataMovimentacao
					ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
				) AS SaldoEstoqueAcumulado
			FROM HistoricoMovimentacoes
			ORDER BY IdMateriaPrima, DataMovimentacao;
```

**Por que isso é incrível?**
Sem a Window Function `SUM() OVER()`, calcular esse saldo acumulado exigiria joins complexos ou um loop lento. A Window Function resolve isso de forma direta e otimizada pelo motor do SQL Server.

---

### Caso B: Classificação de Prioridade de Pedidos

No planejamento da fábrica (WoodCraft), precisamos saber quais pedidos estão mais próximos do vencimento para priorizar a linha de fabricação dos marceneiros.

A query abaixo usa `DENSE_RANK()` para classificar os pedidos pendentes por data de entrega prometida:

```sql
		SELECT	p.Id AS IdPedido,
				c.Nome AS NomeCliente,
				p.DataPedido,
				p.DataPromessa,
				-- Classifica os pedidos por proximidade do prazo
				DENSE_RANK() OVER (ORDER BY p.DataPromessa ASC) AS PrioridadeEntrega
			FROM [dbo].[Pedido] p WITH(NOLOCK)
				INNER JOIN [dbo].[Cliente] c WITH(NOLOCK)
					ON p.IdCliente = c.Id
			WHERE p.DataEntrega IS NULL;
```

Se houver múltiplos pedidos prometidos para o mesmo dia, todos receberão o mesmo número de prioridade `1`. O próximo pedido com data posterior receberá prioridade `2` (graças ao `DENSE_RANK()`), sem pular números.

---

## 3. Desafio da Aula🚀

Para este desafio, você ajudará o setor financeiro e logístico da WoodCraft a analisar a recorrência de compras de cada cliente.

### Requisitos:

Escreva uma consulta SQL baseada no banco de dados `woodcraft` que atenda aos seguintes pontos:

1.  **Estrutura com CTE:** Crie uma CTE chamada `FilaDePedidos` que retorne:
    - O ID do Pedido (`Id`).
    - O ID do Cliente (`IdCliente`) e o Nome do Cliente (`Nome`).
    - A `DataPedido` e a `DataPromessa`.
2.  **Window Function ROW_NUMBER:** Na CTE, gere uma coluna chamada `NumeroSequencialPedido` utilizando `ROW_NUMBER()`. Essa numeração deve ser sequencial por cliente (particionada por cliente) e ordenada pela `DataPedido` de forma ascendente.
3.  **Window Function LAG:** Na mesma CTE, crie uma coluna chamada `DataPedidoAnterior` utilizando a função `LAG()` para trazer a data do pedido anterior do mesmo cliente.
4.  **Consulta Final:** No `SELECT` principal que consulta a CTE:
    - Traga todos os campos da CTE.
    - Calcule a diferença em dias entre a `DataPedido` atual e a `DataPedidoAnterior` (dica: utilize a função `DATEDIFF(day, ...)`). Nomeie essa coluna como `DiasDesdeOPedidoAnterior`.
    - Ordene o resultado por Nome do Cliente e pelo número sequencial do pedido.

### Retorno Esperado:

O resultado deve listar os pedidos agrupados por cliente, mostrando qual o 1º pedido, 2º pedido, etc. daquele cliente, a data do pedido anterior e quantos dias se passaram de uma compra para a outra. Se for o primeiro pedido daquele cliente no histórico, os campos `DataPedidoAnterior` e `DiasDesdeOPedidoAnterior` virão como `NULL`.

---

_Dica: Teste seu script rodando no banco `woodcraft`. O resultado te ajudará a entender a frequência média de compra de cada cliente da marcenaria!_
