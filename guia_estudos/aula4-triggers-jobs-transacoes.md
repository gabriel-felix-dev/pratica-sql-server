# Aula4: Triggers, Jobs, Transações, Tratamento de Erro e Segurança

Na nossa última semana, abordaremos tópicos cruciais para a estabilidade, automação e segurança do banco de dados em ambientes corporativos de alta concorrência. Vamos entender como os gatilhos (**Triggers**) reagem a eventos em tempo real, como agendar tarefas automatizadas com **SQL Server Agent Jobs**, como garantir a integridade dos dados usando **Transações** e **TRY-CATCH**, e como proteger nosso banco de dados contra ataques de **SQL Injection**.

---

## 1. Conceitos Teóricos

### 1.1. Triggers (Gatilhos)

Um Trigger é um tipo especial de stored procedure que é executado automaticamente em resposta a um evento de manipulação de dados (DML: `INSERT`, `UPDATE` ou `DELETE`) em uma tabela.

#### As Tabelas Virtuais `Inserted` e `Deleted`

Dentro de um trigger, o SQL Server disponibiliza duas tabelas virtuais em memória para consulta dos dados que sofreram alteração:

- `Inserted`: Contém as linhas que foram inseridas (no caso de um `INSERT`) ou os novos valores das linhas alteradas (no caso de um `UPDATE`).
- `Deleted`: Contém as linhas que foram apagadas (no caso de um `DELETE`) ou os valores antigos das linhas antes da alteração (no caso de um `UPDATE`).

> [!WARNING]
> **A Natureza Set-Based (Baseada em Conjuntos):**
> No SQL Server, um trigger é disparado **uma única vez** por instrução, e não por linha afetada. Se um comando `UPDATE` alterar 5.000 linhas de uma vez, o trigger rodará **apenas uma vez**, e a tabela virtual `Inserted` conterá 5.000 registros.
> **Regra de ouro:** Nunca escreva um trigger assumindo que ele processará apenas uma linha. Sempre escreva lógicas preparadas para múltiplos registros (lógica set-based).

---

### 1.2. SQL Server Agent Jobs

O **SQL Server Agent** é um serviço do Windows que executa tarefas administrativas ou rotinas agendadas (Jobs).

- Um **Job** pode ser agendado para rodar de forma recorrente (a cada hora, diariamente às 23h, aos domingos, etc.).
- Em sistemas como o da WoodCraft, são usados para tarefas em segundo plano que não devem bloquear o usuário no sistema comercial (ex: fechar ordens de produção antigas, atualizar metas de expedição ou auditar estoques críticos de madeira à meia-noite).

---

### 1.3. Transações, Concorrência e Tratamento de Erros

#### Transações (ACID)

Uma transação é uma unidade lógica de trabalho que deve ser executada por completo ou não ser executada sob hipótese alguma.

- `BEGIN TRANSACTION`: Marca o início de uma transação.
- `COMMIT TRANSACTION`: Grava permanentemente todas as alterações no banco de dados.
- `ROLLBACK TRANSACTION`: Cancela todas as alterações feitas desde o `BEGIN TRANSACTION`, restaurando o estado original das tabelas.

#### Concorrência e a dica `WITH(NOLOCK)`

No SQL Server, ler dados enquanto outros usuários estão gravando pode gerar bloqueios de leitura (locks). No projeto WoodCraft, é comum ver a diretiva `WITH(NOLOCK)` em consultas `SELECT`.

- **O que faz:** Lê registros ignorando travas de exclusão (equivalente ao nível de isolamento `READ UNCOMMITTED`).
- **Prós:** Alta velocidade de leitura e evita bloqueios mútuos (deadlocks).
- **Contras:** Risco de "Leitura Suja" (Dirty Read) — você pode ler dados que outra transação inseriu mas que podem sofrer `ROLLBACK` e deixar de existir logo em seguida.

#### Tratamento de Erro Tradicional com @@ERROR e @@ROWCOUNT

Para evitar que o banco fique em estado inconsistente em caso de erro, os padrões deste sistema definem o uso das variáveis de sistema `@@ERROR` e `@@ROWCOUNT` no lugar de `TRY...CATCH` ou transações explícitas no corpo das procedures.

- `@@ERROR`: Retorna 0 se o último comando executado teve sucesso, ou o código do erro se falhou.
- `@@ROWCOUNT`: Retorna o número de linhas afetadas pelo último comando.

```sql
		-- Executa uma operação DML
		UPDATE [dbo].[Tabela]
			SET Coluna = @Valor
			WHERE Id = @Id;

		-- Verifica imediatamente se houve erro ou se nenhuma linha foi afetada
		IF @@ERROR <> 0 OR @@ROWCOUNT = 0
			RETURN 1; -- Código de erro padrão do sistema
```

As procedures são encadeadas e a própria aplicação gerencia a transação ou a confirmação das alterações com base no código numérico retornado.

---

### 1.4. Segurança: Prevenção contra SQL Injection

O **SQL Injection** ocorre quando um atacante insere comandos SQL maliciosos em um campo de entrada de dados e o sistema concatena essa string diretamente na query de execução.

- **Vulnerável (NÃO FAÇA ISSO):**
  ```sql
  -- Se o usuário digitar "1; DROP TABLE Cliente;"
  SET @Query = 'SELECT * FROM Cliente WHERE Id = ' + @InputUsuario;
  EXEC (@Query); -- A tabela cliente será destruída!
  ```
- **Seguro (Parametrizado com sp_executesql):**
  ```sql
  -- O SQL Server tratará a entrada estritamente como um valor de parâmetro tipado
  EXEC sp_executesql N'SELECT * FROM Cliente WHERE Id = @Id',
                     N'@Id INT',
                     @Id = @InputUsuario;
  ```

---

## 2. Estudo de Caso Prático: WoodCraft

### Caso A: Trigger Set-Based de Consumo Automático de Matéria-Prima

Na fábrica WoodCraft, sempre que uma ordem de produção inicia sua primeira etapa (`NumeroEtapa = 1`), o sistema deve debitar automaticamente do estoque as matérias-primas correspondentes para fabricação do móvel.

O trigger abaixo realiza essa operação de forma otimizada para múltiplos registros (set-based):

```sql
CREATE OR ALTER TRIGGER [dbo].[TRG_ConsumirInsumosInicioProducao]
	ON [dbo].[HistoricoProducao]
	FOR INSERT
	AS
	/*
		Documentacao
		Arquivo Fonte............:	TRG_ConsumirInsumosInicioProducao.sql
		Objetivo.................:	Debitar insumos do estoque no inicio da producao
		Autor....................:	Instrutor WoodCraft
		Data.....................:	01/01/2024
		Exemplo..................:	BEGIN TRAN
										INSERT INTO [dbo].[HistoricoProducao] (...)
											VALUES (...)
									ROLLBACK TRAN
	*/
	BEGIN
		-- 1. Verifica se alguma das linhas inseridas corresponde ao início do processo (Etapa 1)
		IF NOT EXISTS	(
							SELECT TOP 1 1
								FROM Inserted i
									INNER JOIN [dbo].[EtapaFabricacao] ef WITH(NOLOCK)
										ON i.IdEtapaFabricacao = ef.Id
								WHERE ef.NumeroEtapa = 1
						)
			BEGIN
				RETURN;
			END

		-- 2. Tabela temporária para consolidar a lista de insumos necessários
		CREATE TABLE #InsumosNecessarios	(
												IdMateriaPrima INT,
												QuantidadeTotal INT
											)

		-- 3. Agrupa e calcula as matérias-primas totais das linhas inseridas (Inserted)
		INSERT INTO #InsumosNecessarios (IdMateriaPrima, QuantidadeTotal)
			SELECT	c.IdMateriaPrima,
					SUM(i.Quantidade * c.Quantidade) AS QuantidadeTotal
				FROM Inserted i
					INNER JOIN [dbo].[EtapaFabricacao] ef WITH(NOLOCK)
						ON i.IdEtapaFabricacao = ef.Id
					INNER JOIN [dbo].[Composicao] c WITH(NOLOCK)
						ON ef.IdProduto = c.IdProduto
				WHERE ef.NumeroEtapa = 1
				GROUP BY c.IdMateriaPrima;

		-- 4. Atualiza o estoque físico de insumos debitando o consumo total
		UPDATE emp
			SET emp.QuantidadeFisica = emp.QuantidadeFisica - ins.QuantidadeTotal
			FROM [dbo].[EstoqueMateriaPrima] emp
				INNER JOIN #InsumosNecessarios ins
					ON emp.IdMateriaPrima = ins.IdMateriaPrima;

		IF @@ERROR <> 0
			BEGIN
				RAISERROR('Erro ao atualizar estoque fisico.', 16, 1);
				RETURN;
			END

		-- 5. Limpeza da tabela temporária
		DROP TABLE #InsumosNecessarios;
	END
GO
```

**Por que esse código é robusto?**
Se a aplicação iniciar a fabricação de 10 cadeiras e 2 mesas de jantar em um único comando de inserção em lote, o trigger agrupará toda a madeira e parafusos de ambos os móveis na tabela `#InsumosNecessarios` e fará apenas um comando de `UPDATE` no estoque, garantindo excelente performance.

---

### Caso B: Transação com Tratamento de Erro na Expedição do Pedido

Ao finalizar e realizar a entrega de um pedido para o cliente, precisamos atualizar a `DataEntrega` no pedido e dar saída dos móveis prontos do estoque. Veja a implementação segura desse fluxo:

```sql
CREATE OR ALTER PROCEDURE [dbo].[SP_RealizarExpedicaoPedido]
	@IdPedido INT
	AS
	/*
		Documentacao
		Arquivo Fonte............:	SP_RealizarExpedicaoPedido.sql
		Objetivo.................:	Atualizar status do pedido e descontar produtos finalizados
		Autor....................:	Instrutor WoodCraft
		Data.....................:	01/01/2024
		Ex.......................:	BEGIN TRAN
										DBCC DROPCLEANBUFFERS
										DBCC FREEPROCCACHE

										DECLARE @Retorno INT,
												@DataInicio DATETIME = GETDATE()

										EXEC @Retorno = [dbo].[SP_RealizarExpedicaoPedido] @IdPedido = 1

										SELECT	@Retorno AS Retorno,
												DATEDIFF(MILLISECOND, @DataInicio, GETDATE()) AS Tempo
									ROLLBACK TRAN
		Retornos.................:	0 - Sucesso
									1 - Erro: Pedido nao encontrado
									2 - Erro: Pedido ja entregue anteriormente
									3 - Erro: Estoque insuficiente de moveis acabados para faturamento
									4 - Erro na alteracao do banco de dados
	*/
	BEGIN
		-- Validação A: Pedido existe?
		IF NOT EXISTS	(
							SELECT TOP 1 1
								FROM [dbo].[Pedido] WITH(NOLOCK)
								WHERE Id = @IdPedido
						)
			RETURN 1;

		-- Validação B: Já foi entregue?
		IF EXISTS	(
						SELECT TOP 1 1
							FROM [dbo].[Pedido] WITH(NOLOCK)
							WHERE Id = @IdPedido
								AND DataEntrega IS NOT NULL
					)
			RETURN 2;

		-- 1. Validar se algum saldo de produto ficará negativo (Estoque estourado)
		IF EXISTS	(
						SELECT TOP 1 1
							FROM [dbo].[EstoqueProduto] ep WITH(NOLOCK)
								INNER JOIN [dbo].[ItemPedido] ip WITH(NOLOCK)
									ON ep.IdProduto = ip.IdProduto
							WHERE ip.IdPedido = @IdPedido
								AND ep.QuantidadeFisica < ip.Quantidade
					)
			RETURN 3;

		-- 2. Atualizar data de entrega do pedido para hoje
		UPDATE [dbo].[Pedido]
			SET DataEntrega = GETDATE()
			WHERE Id = @IdPedido;

		IF @@ERROR <> 0 OR @@ROWCOUNT = 0
			RETURN 4;

		-- 3. Registrar saída de estoque de cada móvel do pedido
		INSERT INTO [dbo].[MovimentacaoEstoqueProduto] (IdTipoMovimentacao, IdEstoqueProduto, DataMovimentacao, Quantidade)
			SELECT	2,
					ip.IdProduto,
					GETDATE(),
					ip.Quantidade
				FROM [dbo].[ItemPedido] ip WITH(NOLOCK)
				WHERE ip.IdPedido = @IdPedido;

		IF @@ERROR <> 0
			RETURN 4;

		-- 4. Atualizar saldo físico da tabela EstoqueProduto
		UPDATE ep
			SET ep.QuantidadeFisica = ep.QuantidadeFisica - ip.Quantidade
			FROM [dbo].[EstoqueProduto] ep
				INNER JOIN [dbo].[ItemPedido] ip
					ON ep.IdProduto = ip.IdProduto
			WHERE ip.IdPedido = @IdPedido;

		IF @@ERROR <> 0
			RETURN 4;

		RETURN 0;
	END
GO
```

---

## 3. Desafio da Aula🚀

Sua missão de encerramento do módulo é desenvolver uma **Stored Procedure** chamada `SP_IniciarEtapaFabricacao`, seguindo estritamente os padrões de codificação do projeto (Sem TRY/CATCH, validações retornando códigos).

### Requisitos:

1.  **Parâmetros de Entrada:** `@IdEtapaFabricacao INT`, `@IdItemPedido INT` e `@Quantidade INT`.
2.  **Validações (Retornando Erro):**
    - Verifique se a Etapa de Fabricação existe na tabela `EtapaFabricacao`. Se não existir, retorne `1`.
    - Verifique se a Quantidade informada é maior que zero. Se for menor ou igual a zero, retorne `2`.
3.  **Ação Principal:**
    - Insira o registro correspondente na tabela `HistoricoProducao`, informando:
      - `IdEtapaFabricacao`
      - `IdItemPedido`
      - `Quantidade`
      - `DataInicio` (data e hora atuais - `GETDATE()`)
      - `DataTermino` (deve ser inserida como `NULL`, pois a etapa está iniciando)
4.  **Tratamento de Erros de SQL:**
    - Imediatamente após o `INSERT`, verifique se houve erro no banco de dados (`IF @@ERROR <> 0 OR @@ROWCOUNT = 0`). Caso haja erro, retorne `3`.
5.  **Sucesso:** Se o código chegar ao final sem incidentes, retorne `0`.

### Estrutura Sugerida para Codificação:

```sql
CREATE OR ALTER PROCEDURE [dbo].[SP_IniciarEtapaFabricacao]
	@IdEtapaFabricacao INT,
	@IdItemPedido INT,
	@Quantidade INT
	AS
	/*
		Documentacao
		... (Não esqueça de documentar os retornos 0, 1, 2 e 3)
	*/
	BEGIN
		-- 1. Validações com EXISTS
		IF NOT EXISTS ...
			RETURN 1;

		-- 2. Inserção na tabela HistoricoProducao
		INSERT INTO ...

		-- 3. Verificação de erro no SQL
		IF @@ERROR <> 0 ...
			RETURN 3;

		-- 4. Sucesso
		RETURN 0;
	END
GO
```
