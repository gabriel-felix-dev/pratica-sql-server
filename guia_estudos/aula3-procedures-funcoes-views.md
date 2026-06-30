# Aula3: Stored Procedures, Funções (Escalares e Table-Valued) e Views

Nesta semana, vamos estudar a modularização de código no SQL Server. Vamos aprender a encapsular regras de negócio complexas em **Stored Procedures**, criar blocos reutilizáveis de cálculo com **User Defined Functions (UDFs)** e simplificar o acesso a relatórios longos através de **Views**.

---

## 1. Conceitos Teóricos

### 1.1. Stored Procedures (Procedimentos Armazenados)

Uma Stored Procedure é um lote de comandos SQL compilados e salvos no banco de dados. Elas servem para encapsular lógicas transacionais inteiras (como vendas, baixas de estoque ou cadastros de novos registros).

- **Características:**
  - Podem receber parâmetros de entrada e retornar parâmetros de saída (`OUTPUT`).
  - Podem executar operações de modificação de dados (`INSERT`, `UPDATE`, `DELETE`).
  - Podem conter lógica de transações e tratamento de erros.
  - Retornam códigos de status através da instrução `RETURN` (por convenção, retornar `0` indica sucesso, e valores maiores que `0` indicam erros específicos).

---

### 1.2. User-Defined Functions (Funções)

As funções servem para realizar cálculos e retornar um valor ou uma tabela. Elas são mais restritas que as procedures.

> [!IMPORTANT]
> **A regra de ouro das funções:** Elas são estritamente de **somente leitura** em relação ao estado do banco. Você **não pode** executar comandos DML (`INSERT`, `UPDATE`, `DELETE`) em tabelas físicas dentro de uma função.

#### Diferenças entre Stored Procedures e Funções:

- Procedures são executadas com a instrução `EXEC`. Funções são chamadas dentro de expressões SQL (ex: `SELECT dbo.MinhaFuncao(Id)`).
- Procedures podem alterar o estado do banco. Funções não.

#### Tipos de Funções:

1.  **Funções Escalares:** Retornam um único valor (ex: `INT`, `VARCHAR`, `BIT`, `DATE`).
2.  **Table-Valued Functions (TVFs):** Retornam um conjunto de dados estruturado como uma tabela.
    - **Inline TVF:** Contém apenas um comando `SELECT` e funciona como uma View parametrizada. É extremamente eficiente e recomendada por performance.
    - **Multi-Statement TVF:** Contém um corpo com `BEGIN...END` onde você cria uma tabela temporária de retorno, popula com `INSERT`s usando lógica complexa e depois a retorna. É menos performática que a Inline.

---

### 1.3. Views (Visões)

Uma View é uma tabela virtual baseada no conjunto de resultados de uma consulta SQL pré-definida. Ela não armazena dados físicos próprios; ela simplesmente repassa a consulta para as tabelas de origem em tempo real.

- **Vantagens:** Simplifica queries complexas para o usuário final, centraliza fórmulas de relatórios comuns e serve como uma camada de segurança (ocultando colunas sensíveis).

---

## 2. Estudo de Caso Prático: WoodCraft

### Caso A: Stored Procedure com SQL Dinâmico Seguro

Imagine que no sistema da WoodCraft, o usuário possa listar os móveis (produtos) filtrando pelo nome de forma opcional. Para isso, criamos uma procedure com SQL dinâmico e parametrização segura (`sp_executesql`):

```sql
CREATE OR ALTER PROCEDURE [dbo].[SP_ConsultarMovelFiltros]
	@NomeFiltro VARCHAR(100) = NULL
	AS
	/*
		Documentacao
		Arquivo Fonte............:	SP_ConsultarMovelFiltros.sql
		Objetivo.................:	Listar móveis filtrando pelo nome de forma opcional
		Autor....................:	Instrutor WoodCraft
		Data.....................:	01/01/2024
		Ex.......................:	DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @Retorno INT,
											@DataInicio DATETIME = GETDATE()

									EXEC @Retorno = [dbo].[SP_ConsultarMovelFiltros] @NomeFiltro = '%Carvalho%'

									SELECT	@Retorno AS Retorno,
											DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo
		Retornos.................:	0 - Sucesso
									1 - Erro: Filtro vazio
	*/
	BEGIN
		-- Declarar variaveis
		DECLARE @Comando NVARCHAR(MAX),
				@Parametros NVARCHAR(1000),
				@Where BIT

		-- Montar comando base
		SET @Comando = N'
						SELECT	Id,
								Nome
							FROM [dbo].[Produto] WITH(NOLOCK)
							WHERE '
		SET @Where = 0

		-- Adicionar filtro caso o parametro seja informado
		IF @NomeFiltro IS NOT NULL
			BEGIN
				SET @Comando = @Comando + N'Nome LIKE @pNomeFiltro'
				SET @Where = 1
			END

		-- Definicao do tipo do parametro interno do sp_executesql
		SET @Parametros = N'@pNomeFiltro VARCHAR(100)'

		-- Verificar se ha parametros (exemplo de validacao)
		IF RIGHT(@Comando, 1) = ' '
			BEGIN
				RETURN 1
			END

		-- Executar comando
		EXEC sp_executesql @Comando,
						   @Parametros,
						   @pNomeFiltro = @NomeFiltro

		RETURN 0
	END
GO
```

Podemos executá-la de duas formas:

```sql
EXEC [dbo].[SP_ConsultarMovelFiltros]; -- Traz todos
EXEC [dbo].[SP_ConsultarMovelFiltros] @NomeFiltro = '%Carvalho%'; -- Filtra
```

---

### Caso B: Função Escalar e Inline Table-Valued Function (TVF)

#### 1. Função Escalar para Calcular Saldo de Insumo

Esta função recebe o ID de uma matéria-prima e calcula a quantidade física líquida disponível em estoque:

```sql
CREATE OR ALTER FUNCTION [dbo].[FNC_ObterEstoqueDisponivelMateriaPrima] (@IdMateriaPrima INT)
	RETURNS INT
	AS
	/*
		Documentacao
		Arquivo Fonte............:	FNC_ObterEstoqueDisponivelMateriaPrima.sql
		Objetivo.................:	Calcular a quantidade fisica liquida disponivel em estoque
		Autor....................:	Instrutor WoodCraft
		Data.....................:	01/01/2024
		Ex.......................:
									DBCC FREEPROCCACHE
									DBCC DROPCLEANBUFFERS

									DECLARE @DataInicio DATETIME = GETDATE();

									SELECT [dbo].[FNC_ObterEstoqueDisponivelMateriaPrima](1) AS Resultado;

									SELECT DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS TempoExecucao;
	*/
	BEGIN
		-- Declarar variavel
		DECLARE @Quantidade INT = 0;

		-- Obter quantidade fisica
		SELECT	@Quantidade = QuantidadeFisica
			FROM [dbo].[EstoqueMateriaPrima] WITH(NOLOCK)
			WHERE IdMateriaPrima = @IdMateriaPrima;

		-- Retornar valor
		RETURN ISNULL(@Quantidade, 0);
	END
GO
```

#### 2. Inline Table-Valued Function (TVF) para Composição de um Móvel

Esta função funciona como uma "view parametrizada". Ao passar o ID de um móvel, ela retorna todos os insumos necessários e suas quantidades:

```sql
CREATE OR ALTER FUNCTION [dbo].[FNC_ListarInsumosMovel] (@IdProduto INT)
	RETURNS TABLE
	AS
	/*
		Documentacao
		Arquivo Fonte............:	FNC_ListarInsumosMovel.sql
		Objetivo.................:	Retorna insumos necessarios e quantidades para o movel
		Autor....................:	Instrutor WoodCraft
		Data.....................:	01/01/2024
		Ex.......................:
									SELECT * FROM [dbo].[FNC_ListarInsumosMovel](1);
	*/
	RETURN (
		SELECT	c.IdProduto,
				p.Nome AS NomeMovel,
				c.IdMateriaPrima,
				mp.Nome AS NomeMateriaPrima,
				c.Quantidade AS QuantidadeNecessaria
			FROM [dbo].[Composicao] c WITH(NOLOCK)
				INNER JOIN [dbo].[Produto] p WITH(NOLOCK)
					ON c.IdProduto = p.Id
				INNER JOIN [dbo].[MateriaPrima] mp WITH(NOLOCK)
					ON c.IdMateriaPrima = mp.Id
			WHERE c.IdProduto = @IdProduto
	);
GO
```

**Como consultar a TVF:**

```sql
SELECT * FROM [dbo].[FNC_ListarInsumosMovel](1); -- Insumos da Cadeira Office
```

---

### Caso C: View para Painel de Produção Ativa

Para ajudar os gerentes da WoodCraft a monitorarem o andamento da fabricação nas oficinas em tempo real, criamos a view consolidada abaixo:

```sql
CREATE OR ALTER VIEW [dbo].[VW_PainelProducaoAtiva]
AS
SELECT hp.Id AS IdOrdemProducao,
       c.Nome AS NomeCliente,
       prod.Nome AS NomeMovel,
       ef.Descricao AS EtapaProcesso,
       ef.NumeroEtapa,
       hp.Quantidade,
       hp.DataInicio,
       hp.DataTermino,
       CASE
           WHEN hp.DataTermino IS NOT NULL THEN 'Concluído'
           ELSE 'Em Fabricação'
       END AS StatusFabricacao
FROM [dbo].[HistoricoProducao] hp WITH(NOLOCK)
INNER JOIN [dbo].[EtapaFabricacao] ef WITH(NOLOCK) ON hp.IdEtapaFabricacao = ef.Id
INNER JOIN [dbo].[ItemPedido] ip WITH(NOLOCK) ON hp.IdItemPedido = ip.Id
INNER JOIN [dbo].[Pedido] ped WITH(NOLOCK) ON ip.IdPedido = ped.Id
INNER JOIN [dbo].[Cliente] c WITH(NOLOCK) ON ped.IdCliente = c.Id
INNER JOIN [dbo].[Produto] prod WITH(NOLOCK) ON ip.IdProduto = prod.Id;
GO
```

---

## 3. Desafio da Aula🚀

Sua missão nesta Aula é criar uma **Inline Table-Valued Function (TVF)** chamada `FNC_ConsultarEtapasPendentesPedido` para que o time da marcenaria possa consultar a fila de produção ativa de um pedido.

### Requisitos:

1.  A função deve receber um parâmetro de entrada: `@IdPedido INT`.
2.  A função deve retornar uma tabela contendo os seguintes campos:
    - `IdPedido` (ID do pedido pesquisado)
    - `NomeCliente` (Nome do cliente que fez o pedido)
    - `NomeProduto` (Nome do móvel contido no pedido)
    - `NumeroEtapa` (O número da etapa de fabricação do móvel)
    - `DescricaoEtapa` (A descrição do processo de fabricação, ex: Lixamento)
    - `DuracaoMinutos` (A duração estimada em minutos)
    - `StatusEtapa` (O status da etapa com base nas condições abaixo):
      - Se houver um registro correspondente na tabela `HistoricoProducao` e a `DataTermino` **não for nula**, exiba: `'Concluído'`.
      - Se houver o registro mas a `DataTermino` **for nula**, exiba: `'Em Andamento'`.
      - Se não houver nenhum registro correspondente em `HistoricoProducao`, exiba: `'Não Iniciado'`.

### Estrutura Base para Desenvolvimento:

```sql
CREATE OR ALTER FUNCTION [dbo].[FNC_ConsultarEtapasPendentesPedido] (@IdPedido INT)
	RETURNS TABLE
	AS
	/*
		Documentacao
		Arquivo Fonte............:	FNC_ConsultarEtapasPendentesPedido.sql
		Objetivo.................:	Consultar a fila de producao ativa de um pedido
		Autor....................:	(Seu Nome)
		Data.....................:	(Data de Hoje)
		Ex.......................:
									SELECT * FROM [dbo].[FNC_ConsultarEtapasPendentesPedido](1);
	*/
	RETURN (
		-- Escreva seu SELECT relacionando Cliente, Pedido, ItemPedido, EtapaFabricacao
		-- e use LEFT JOIN com HistoricoProducao.
		-- Lembre-se de indentar corretamente com TABs!
	);
GO
```

### Como testar seu código:

Após criar a função no banco `woodcraft`, execute a consulta abaixo:

```sql
SELECT * FROM [dbo].[FNC_ConsultarEtapasPendentesPedido](1); -- Testa com o Pedido ID 1
```

---

_Dica: Lembre-se de usar LEFT JOIN para a tabela `HistoricoProducao` e para `EtapaFabricacao`, pois o pedido pode ter etapas que ainda não foram sequer iniciadas (portanto, não têm registro em `HistoricoProducao`)._
