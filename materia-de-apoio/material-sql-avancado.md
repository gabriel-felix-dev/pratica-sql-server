### Material de Estudo — SQL Server (do básico ao avançado)

Conteúdo: Stored Procedures, Jobs, Functions, Triggers, CTE, Window Functions, Indexes, Dependency Injection.

Cada tópico começa com a forma mais simples possível e evolui em exemplos sucessivos até o nível usado em exercícios avançados. Todos os exemplos são em T-SQL (SQL Server).

---

## 1. Stored Procedures

Uma stored procedure é um bloco de T-SQL compilado e armazenado no banco, chamado por nome. Diferente de uma function, pode alterar dados e não precisa retornar valor.

### 1.1. Nível básico — sem parâmetro

A forma mais simples possível: encapsular uma consulta fixa.

```sql
CREATE OR ALTER PROCEDURE dbo.ListarClientesAtivos
AS
BEGIN
    SELECT Id, Nome, Cpf
    FROM Cliente
    WHERE Ativo = 1;
END;
```

```sql
EXEC dbo.ListarClientesAtivos;
```

Só isso já é uma procedure válida: ela existe para não precisar reescrever o `SELECT` toda vez.

### 1.2. Nível intermediário — parâmetros de entrada

Agora a procedure recebe argumentos, como uma função em qualquer linguagem:

```sql
CREATE OR ALTER PROCEDURE dbo.ListarVendasPorCliente
    @IdCliente INT
AS
BEGIN
    SELECT Id, DataHora, StatusVenda
    FROM Venda
    WHERE IdCliente = @IdCliente
    ORDER BY DataHora DESC;
END;
```

```sql
EXEC dbo.ListarVendasPorCliente @IdCliente = 7;
```

### 1.3. Nível intermediário — parâmetro de saída (`OUTPUT`)

Além de receber, a procedure pode devolver um valor sem precisar de result set:

```sql
CREATE OR ALTER PROCEDURE dbo.ContarVendasCliente
    @IdCliente INT,
    @Total     INT OUTPUT
AS
BEGIN
    SELECT @Total = COUNT(*)
    FROM Venda
    WHERE IdCliente = @IdCliente;
END;
```

```sql
DECLARE @QtdVendas INT;
EXEC dbo.ContarVendasCliente @IdCliente = 7, @Total = @QtdVendas OUTPUT;
SELECT @QtdVendas;
```

### 1.4. Nível avançado — transação, `TRY/CATCH` e múltiplas tabelas

Quando a procedure precisa alterar mais de uma tabela de forma atômica (tudo grava ou nada grava), entram transação e tratamento de erro:

```sql
CREATE OR ALTER PROCEDURE dbo.RegistrarVenda
    @IdCliente      INT,
    @IdFuncionario  INT,
    @Itens          NVARCHAR(MAX), -- JSON: [{"IdProduto":1,"Quantidade":2}]
    @IdVendaGerada  INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Venda (IdCliente, IdFuncionario, DataHora, StatusVenda)
        VALUES (@IdCliente, @IdFuncionario, GETDATE(), 'Pendente');

        SET @IdVendaGerada = SCOPE_IDENTITY();

        INSERT INTO VendaProduto (IdVenda, IdProduto, Quantidade, PrecoAplicado)
        SELECT @IdVendaGerada, j.IdProduto, j.Quantidade, p.PrecoVenda
        FROM OPENJSON(@Itens)
             WITH (IdProduto INT, Quantidade INT) AS j
        INNER JOIN Produto p ON p.Id = j.IdProduto;

        UPDATE p
        SET p.QuantidadeEstoque = p.QuantidadeEstoque - vp.Quantidade
        FROM Produto p
        INNER JOIN VendaProduto vp ON vp.IdProduto = p.Id
        WHERE vp.IdVenda = @IdVendaGerada;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
```

O que mudou do 1.3 para aqui: agora há mais de uma operação de escrita que precisa ser tudo-ou-nada (`BEGIN TRANSACTION` / `COMMIT` / `ROLLBACK`), e qualquer erro no meio do caminho precisa desfazer o que já tinha sido feito (`TRY/CATCH`).

Pontos que costumam pesar em prova/exercício avançado:

`SCOPE_IDENTITY()` é preferível a `@@IDENTITY` — pega o último identity gerado na mesma sessão/escopo, sem risco de capturar um identity de trigger disparado por outra tabela.

`THROW` (SQL Server 2012+) repropaga o erro original com stack trace; `RAISERROR` é a forma legada e perde parte do contexto.

`CREATE OR ALTER` evita o padrão antigo de `IF EXISTS ... DROP ... CREATE`, que tinha uma janela onde a procedure ficava temporariamente inexistente.

---

## 2. Jobs (SQL Server Agent)

Job é uma unidade de trabalho agendada no SQL Server Agent — um conjunto de *steps* executado conforme um *schedule*. Não é T-SQL puro; é configuração via `msdb`.

### 2.1. Nível básico — um job, um step, execução manual

A forma mais simples: um job que só roda um comando, sem agendamento ainda.

```sql
USE msdb;
GO

EXEC dbo.sp_add_job
    @job_name = N'Job_LimpezaLogsAntigos';

EXEC dbo.sp_add_jobstep
    @job_name  = N'Job_LimpezaLogsAntigos',
    @step_name = N'DeletarLogsMaisDe90Dias',
    @subsystem = N'TSQL',
    @command   = N'DELETE FROM dbo.LogAcesso WHERE DataAcesso < DATEADD(DAY, -90, GETDATE());',
    @database_name = N'PetShop';

EXEC dbo.sp_add_jobserver
    @job_name = N'Job_LimpezaLogsAntigos';
```

Nesse ponto, o job existe e pode ser executado manualmente (`EXEC dbo.sp_start_job @job_name = N'Job_LimpezaLogsAntigos';` ou pelo botão "Start Job" no SSMS), mas não dispara automaticamente em horário nenhum.

### 2.2. Nível intermediário — adicionando agendamento (`schedule`)

Agora o job passa a rodar sozinho, todo dia às 3h:

```sql
EXEC dbo.sp_add_schedule
    @schedule_name = N'Diario_03h',
    @freq_type     = 4,      -- diário
    @freq_interval = 1,
    @active_start_time = 030000;

EXEC dbo.sp_attach_schedule
    @job_name      = N'Job_LimpezaLogsAntigos',
    @schedule_name = N'Diario_03h';
```

### 2.3. Nível avançado — múltiplos steps com lógica condicional de falha

Jobs reais raramente têm um único step. Cada step pode decidir o que fazer em caso de sucesso ou falha — aqui um job de duas etapas, onde a segunda só roda se a primeira for bem-sucedida, e qualquer falha encerra o job já marcando-o como falho:

```sql
EXEC dbo.sp_add_jobstep
    @job_name        = N'Job_LimpezaLogsAntigos',
    @step_id         = 1,
    @step_name       = N'BackupTabelaLog',
    @subsystem       = N'TSQL',
    @command         = N'SELECT * INTO dbo.LogAcesso_Backup FROM dbo.LogAcesso WHERE DataAcesso < DATEADD(DAY, -90, GETDATE());',
    @database_name   = N'PetShop',
    @on_success_action = 3, -- 3 = ir para o próximo step
    @on_fail_action    = 2; -- 2 = encerrar o job reportando falha

EXEC dbo.sp_add_jobstep
    @job_name        = N'Job_LimpezaLogsAntigos',
    @step_id         = 2,
    @step_name       = N'DeletarLogsMaisDe90Dias',
    @subsystem       = N'TSQL',
    @command         = N'DELETE FROM dbo.LogAcesso WHERE DataAcesso < DATEADD(DAY, -90, GETDATE());',
    @database_name   = N'PetShop',
    @on_success_action = 1, -- 1 = encerrar o job reportando sucesso
    @on_fail_action    = 2;
```

O que mudou do 2.2 para aqui: o job deixou de ser "uma ação só" e passou a ser um fluxo — primeiro garante backup, só depois deleta, e qualquer falha no meio interrompe a cadeia.

Coisas que valem destacar:

Jobs vivem em `msdb`, não no banco de negócio — por isso `USE msdb` no início.

Diferença prática de uma procedure: a procedure só executa quando alguém (ou algo) chama; o job é o "algo" que chama automaticamente, no horário certo. É comum um job ter como step único `EXEC dbo.MinhaProcedure;`, reaproveitando o que já foi escrito na seção 1.

Monitoramento via `msdb.dbo.sysjobhistory` — toda execução, sucesso ou falha, fica registrada ali.

---

## 3. Functions

Functions em T-SQL retornam um valor (escalar) ou uma tabela (table-valued) e, diferente de procedures, não podem alterar estado do banco.

### 3.1. Nível básico — scalar function simples

A forma mais simples: receber um valor, devolver outro, sem lógica condicional.

```sql
CREATE OR ALTER FUNCTION dbo.ConverterParaMaiusculo(@Texto NVARCHAR(200))
RETURNS NVARCHAR(200)
AS
BEGIN
    RETURN UPPER(@Texto);
END;
```

```sql
SELECT dbo.ConverterParaMaiusculo('claudio') AS Resultado;
```

### 3.2. Nível intermediário — scalar function com lógica condicional

Agora a function tem `CASE`/cálculo, não só uma chamada direta de outra função:

```sql
CREATE OR ALTER FUNCTION dbo.CalcularIdade(@DataNascimento DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @DataNascimento, GETDATE())
           - CASE
                 WHEN (MONTH(@DataNascimento) > MONTH(GETDATE()))
                   OR (MONTH(@DataNascimento) = MONTH(GETDATE())
                       AND DAY(@DataNascimento) > DAY(GETDATE()))
                 THEN 1
                 ELSE 0
             END;
END;
```

```sql
SELECT Nome, dbo.CalcularIdade(DataNascimento) AS Idade
FROM Aluno;
```

### 3.3. Nível avançado — inline table-valued function (iTVF)

Quando o retorno precisa ser uma tabela (várias colunas, várias linhas), a forma recomendada é a inline TVF — um único `SELECT`, sem `BEGIN...END`:

```sql
CREATE OR ALTER FUNCTION dbo.HistoricoComprasCliente(@IdCliente INT)
RETURNS TABLE
AS
RETURN
(
    SELECT v.Id, v.DataHora, SUM(vp.Quantidade * vp.PrecoAplicado) AS Total
    FROM Venda v
    INNER JOIN VendaProduto vp ON vp.IdVenda = v.Id
    WHERE v.IdCliente = @IdCliente
    GROUP BY v.Id, v.DataHora
);
```

```sql
SELECT * FROM dbo.HistoricoComprasCliente(7);
```

O que mudou do 3.2 para aqui: a function deixou de devolver um único valor por chamada e passou a devolver um conjunto de linhas, podendo ser usada no `FROM` como se fosse uma tabela.

Ponto de prova clássico: **scalar function chamada linha a linha num `WHERE` ou `SELECT` é um dos piores hits de performance em SQL Server** — o otimizador não consegue paralelizar nem usar índice de forma eficaz (parcialmente mitigado a partir do SQL Server 2019 com *scalar UDF inlining*, mas não em todos os casos). Uma **multi-statement table-valued function** (com `BEGIN...END` e várias instruções) sofre do mesmo problema. Já a **inline TVF**, como a do 3.3, é expandida pelo otimizador como se fosse uma view/subconsulta — por isso é a forma preferida quando o cálculo pode ser escrito como uma única expressão `SELECT`.

---

## 4. Triggers

Trigger é um bloco de T-SQL disparado automaticamente em resposta a um evento — DML (`INSERT`/`UPDATE`/`DELETE`), DDL, ou logon.

### 4.1. Nível básico — log simples de `INSERT`

A forma mais simples: registrar que algo aconteceu, sem olhar valores antigos/novos.

```sql
CREATE OR ALTER TRIGGER trg_Cliente_LogCadastro
ON Cliente
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO LogAcesso (Descricao, DataAcesso)
    SELECT 'Novo cliente cadastrado: ' + i.Nome, GETDATE()
    FROM inserted i;
END;
```

### 4.2. Nível intermediário — comparando antes/depois em `UPDATE`

Agora a trigger usa as duas tabelas virtuais (`inserted` = depois, `deleted` = antes) para saber o que mudou:

```sql
CREATE OR ALTER TRIGGER trg_Produto_LogAlteracaoPreco
ON Produto
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO HistoricoPreco (IdProduto, PrecoAnterior, PrecoNovo, DataAlteracao)
    SELECT d.Id, d.PrecoVenda, i.PrecoVenda, GETDATE()
    FROM inserted i
    INNER JOIN deleted d ON d.Id = i.Id
    WHERE i.PrecoVenda <> d.PrecoVenda;
END;
```

### 4.3. Nível avançado — disparo condicional (`UPDATE()`) evitando trabalho desnecessário

Quando a tabela tem várias colunas que podem ser atualizadas, mas a trigger só se importa com uma delas, vale checar isso antes de fazer qualquer trabalho:

```sql
CREATE OR ALTER TRIGGER trg_Produto_LogAlteracaoPreco
ON Produto
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(PrecoVenda) RETURN;

    INSERT INTO HistoricoPreco (IdProduto, PrecoAnterior, PrecoNovo, DataAlteracao)
    SELECT d.Id, d.PrecoVenda, i.PrecoVenda, GETDATE()
    FROM inserted i
    INNER JOIN deleted d ON d.Id = i.Id
    WHERE i.PrecoVenda <> d.PrecoVenda;
END;
```

O que mudou do 4.2 para aqui: antes a trigger rodava (e fazia o `JOIN`/`INSERT`) em **todo** `UPDATE` da tabela `Produto`, mesmo um que só mudasse `Nome` ou `QuantidadeEstoque`. O `IF NOT UPDATE(PrecoVenda) RETURN;` corta esse trabalho de saída, rodando a lógica cara só quando a coluna de interesse de fato foi referenciada no `SET`.

Pontos que costumam cair em exercício/prova avançado:

Trigger dispara **uma vez por instrução**, não uma vez por linha. Se um `UPDATE` afetar 500 linhas, `inserted`/`deleted` terão 500 linhas cada — a trigger roda uma única vez, operando em conjunto (set-based).

Trigger é invisível para quem só lê o `UPDATE`/`INSERT` na aplicação — é o efeito colateral "escondido" mais citado como problema de manutenção/debug em produção. Use com critério: auditoria, validação cross-table que `CHECK CONSTRAINT` não cobre, ou sincronização denormalizada.

---

## 5. CTE (Common Table Expression)

CTE é um result set nomeado e temporário, declarado com `WITH`, visível apenas dentro da instrução que o segue.

### 5.1. Nível básico — substituindo uma subconsulta simples

```sql
WITH ClientesAtivos AS (
    SELECT Id, Nome
    FROM Cliente
    WHERE Ativo = 1
)
SELECT * FROM ClientesAtivos;
```

Sozinho isso não ganha muita coisa de uma subconsulta direta — mas já mostra a sintaxe base: `WITH nome AS (SELECT...)` seguido da consulta principal.

### 5.2. Nível intermediário — CTE com agregação, reaproveitada no `JOIN`

```sql
WITH TotalPorCliente AS (
    SELECT IdCliente, COUNT(*) AS QuantidadeVendas
    FROM Venda
    GROUP BY IdCliente
)
SELECT c.Nome, t.QuantidadeVendas
FROM Cliente c
INNER JOIN TotalPorCliente t ON t.IdCliente = c.Id
WHERE t.QuantidadeVendas > 3;
```

Aqui a CTE já resolve um problema real: em vez de uma subconsulta aninhada dentro do `FROM` ou do `WHERE`, o cálculo fica nomeado e legível antes da query principal.

### 5.3. Nível avançado — CTE recursiva (hierarquia)

```sql
WITH Hierarquia AS (
    -- âncora: nível raiz
    SELECT Id, Nome, IdCategoriaPai, 0 AS Nivel
    FROM CategoriaProduto
    WHERE IdCategoriaPai IS NULL

    UNION ALL

    -- recursão: junta o próximo nível
    SELECT c.Id, c.Nome, c.IdCategoriaPai, h.Nivel + 1
    FROM CategoriaProduto c
    INNER JOIN Hierarquia h ON c.IdCategoriaPai = h.Id
)
SELECT * FROM Hierarquia
ORDER BY Nivel, Nome
OPTION (MAXRECURSION 100);
```

O que mudou do 5.2 para aqui: a CTE deixou de ser uma única consulta e passou a ter duas partes unidas por `UNION ALL` — uma âncora (ponto de partida) e uma parte recursiva que referencia a própria CTE, repetindo até não haver mais filhos.

Pontos importantes:

CTE não é "materializada" como tabela temporária — na maioria dos casos o otimizador a expande no plano de execução como se fosse a subconsulta equivalente. O ganho é de legibilidade, não necessariamente de performance.

CTE recursiva tem limite padrão de 100 níveis (`MAXRECURSION`), ajustável com `OPTION (MAXRECURSION n)` (0 = ilimitado, com risco de loop infinito se a hierarquia tiver ciclo).

---

## 6. Window Functions

Window functions calculam um valor por linha "olhando" para um conjunto de linhas relacionadas (a *window*, definida por `OVER (...)`), sem colapsar o resultado como `GROUP BY` faz.

### 6.1. Nível básico — `ROW_NUMBER()` sem partição

A forma mais simples: numerar todas as linhas em uma ordem.

```sql
SELECT
    Id,
    Nome,
    PrecoVenda,
    ROW_NUMBER() OVER (ORDER BY PrecoVenda DESC) AS Posicao
FROM Produto;
```

### 6.2. Nível intermediário — `PARTITION BY` e diferença entre `ROW_NUMBER`/`RANK`/`DENSE_RANK`

Agora a numeração reinicia por grupo (cada categoria tem seu próprio ranking):

```sql
SELECT
    p.Id,
    p.Nome,
    cp.Nome AS Categoria,
    p.PrecoVenda,
    ROW_NUMBER() OVER (PARTITION BY p.IdCategoriaProduto ORDER BY p.PrecoVenda DESC) AS PosicaoRowNumber,
    RANK()       OVER (PARTITION BY p.IdCategoriaProduto ORDER BY p.PrecoVenda DESC) AS PosicaoRank,
    DENSE_RANK() OVER (PARTITION BY p.IdCategoriaProduto ORDER BY p.PrecoVenda DESC) AS PosicaoDenseRank
FROM Produto p
INNER JOIN CategoriaProduto cp ON cp.Id = p.IdCategoriaProduto;
```

Diferença entre as três, com valores [10, 10, 8] dentro da mesma partição: `ROW_NUMBER` → 1, 2, 3 (nunca empata); `RANK` → 1, 1, 3 (empata e deixa buraco); `DENSE_RANK` → 1, 1, 2 (empata sem deixar buraco).

### 6.3. Nível avançado — agregado acumulado (frame) e comparação com linha anterior (`LAG`)

```sql
SELECT
    v.Id,
    v.IdCliente,
    v.DataHora,
    SUM(vp.Quantidade * vp.PrecoAplicado) AS TotalVenda,
    SUM(SUM(vp.Quantidade * vp.PrecoAplicado))
        OVER (PARTITION BY v.IdCliente ORDER BY v.DataHora
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado,
    LAG(SUM(vp.Quantidade * vp.PrecoAplicado))
        OVER (PARTITION BY v.IdCliente ORDER BY v.DataHora) AS ValorVendaAnterior
FROM Venda v
INNER JOIN VendaProduto vp ON vp.IdVenda = v.Id
GROUP BY v.Id, v.IdCliente, v.DataHora;
```

O que mudou do 6.2 para aqui: além de ranquear, a window function agora soma valores acumulados dentro de um *frame* explícito (`ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`) e compara cada linha com a anterior do mesmo cliente via `LAG`.

Pontos que costumam ser cobrados:

`PARTITION BY` é o "GROUP BY da window" — reinicia o cálculo a cada novo grupo, mas sem reduzir o número de linhas do resultado.

A cláusula de frame controla exatamente quais linhas entram no cálculo de cada janela. Sem ela, o padrão para funções agregadas com `ORDER BY` é `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` — o que já entrega o "acumulado até a linha atual" mesmo sem especificar nada, mas com sutilezas em caso de valores empatados no `ORDER BY` (por isso muita gente prefere `ROWS` explícito, que é determinístico linha a linha).

Window function é avaliada **depois** do `GROUP BY`/agregação (por isso o `SUM(SUM(...))` aninhado) e **antes** do `ORDER BY` final — não pode ser usada direto no `WHERE`; para filtrar pelo resultado de uma window function, é necessário envolver em subconsulta/CTE e filtrar na consulta externa.

---

## 7. Indexes

Index é uma estrutura adicional (geralmente B-tree) que o SQL Server mantém para acelerar busca, ordenação e join — ao custo de espaço em disco e de mais trabalho em cada `INSERT`/`UPDATE`/`DELETE`.

### 7.1. Nível básico — índice de coluna única

```sql
CREATE NONCLUSTERED INDEX IX_Venda_IdCliente ON Venda(IdCliente);
```

Com esse índice, `WHERE IdCliente = 7` deixa de varrer a tabela inteira e passa a buscar direto na estrutura do índice.

### 7.2. Nível intermediário — índice composto e a regra do prefixo

```sql
CREATE NONCLUSTERED INDEX IX_Venda_Cliente_Data ON Venda(IdCliente, DataHora);
```

Esse índice serve para filtros por `IdCliente` isolado (usa o prefixo mais à esquerda) e também para `IdCliente` + `DataHora` juntos. Não serve, sozinho, para um filtro só por `DataHora` — a coluna não está na posição mais à esquerda do índice.

### 7.3. Nível avançado — covering index (`INCLUDE`) e índice filtrado

```sql
-- Covering: evita "key lookup" extra ao já guardar as colunas pedidas no SELECT
CREATE NONCLUSTERED INDEX IX_Venda_Cliente_Covering
ON Venda(IdCliente)
INCLUDE (DataHora, StatusVenda);

-- Filtrado: índice menor, só sobre o subconjunto relevante
CREATE NONCLUSTERED INDEX IX_Produto_EstoqueBaixo
ON Produto(QuantidadeEstoque)
WHERE QuantidadeEstoque < 20;
```

O que mudou do 7.2 para aqui: o índice de 7.2 já acelera o `WHERE`/`JOIN`, mas se a query também pedir `StatusVenda` no `SELECT`, o motor ainda precisa voltar à tabela base para buscar essa coluna (*key lookup*). O `INCLUDE` resolve isso guardando a coluna extra dentro do próprio índice. Já o índice filtrado nem cobre a tabela inteira — só o pedaço (estoque baixo) que de fato interessa, ficando mais compacto e mais rápido de manter.

Pontos centrais para nível avançado:

Cada tabela tem **no máximo um** índice clustered (define a ordem física dos dados) e pode ter **vários** nonclustered.

Uma query é dita **sargable** (*Search ARGument ABLE*) quando o predicado permite usar índice diretamente sobre a coluna, sem calcular uma função em cada linha antes de comparar. `WHERE YEAR(DataHora) = 2025` não é sargable; `WHERE DataHora >= '2025-01-01' AND DataHora < '2026-01-01'` é sargable — mesma lógica vista nas questões 14 e 60 do exercício Pet Shop.

Cada índice extra tem custo de escrita — não se cria índice "por garantia"; é um trade-off leitura vs. escrita avaliado caso a caso.

---

## 8. Dependency Injection — contextualizando

Esse item não é nativo de SQL/T-SQL. Como você não tinha certeza do que o material pedia, seguem os dois sentidos mais plausíveis num contexto que mistura banco de dados com desenvolvimento, cada um também do básico ao avançado.

### 8.1. Sentido A — Dependências entre objetos do banco (nativo do SQL Server)

**Básico** — ver dependências pela interface de metadados clássica:

```sql
EXEC sp_depends 'dbo.RegistrarVenda';
```

`sp_depends` é a forma mais simples e antiga de perguntar "o que esse objeto usa, e quem usa ele" — mas está marcada como obsoleta e pode não capturar tudo (ex.: SQL dinâmico).

**Avançado** — a forma recomendada hoje, via DMVs, que é mais precisa:

```sql
-- O que depende do objeto X (quem quebraria se X mudasse)
SELECT referencing_schema_name, referencing_entity_name, referencing_class_desc
FROM sys.dm_sql_referencing_entities('dbo.RegistrarVenda', 'OBJECT');

-- De que objetos X depende (o que X usa por dentro)
SELECT referenced_schema_name, referenced_entity_name
FROM sys.dm_sql_referenced_entities('dbo.RegistrarVenda', 'OBJECT');
```

Uso prático: antes de alterar/remover uma tabela, view ou procedure em produção, rodar essa checagem evita quebrar dependências escondidas.

### 8.2. Sentido B — Dependency Injection como padrão de arquitetura (camada de aplicação)

**Básico** — sem DI, a classe cria sua própria dependência internamente (acoplamento direto, difícil de testar):

```csharp
public class VendaService
{
    public int Concluir(int idCliente, int idFuncionario, List<ItemVenda> itens)
    {
        var repository = new VendaRepository("connection-string-fixa-aqui"); // <- criado dentro da classe
        return repository.RegistrarVenda(idCliente, idFuncionario, itens);
    }
}
```

O problema aqui: `VendaService` está "casado" com `VendaRepository` e com a connection string. Para testar `VendaService` sem banco real, não tem como.

**Avançado** — com DI, a dependência é recebida via construtor, por interface, e quem decide a implementação real é o código externo (container de injeção):

```csharp
public interface IVendaRepository
{
    int RegistrarVenda(int idCliente, int idFuncionario, List<ItemVenda> itens);
}

public class VendaRepository : IVendaRepository
{
    private readonly string _connectionString;
    public VendaRepository(string connectionString) => _connectionString = connectionString;

    public int RegistrarVenda(int idCliente, int idFuncionario, List<ItemVenda> itens)
    {
        using var conn = new SqlConnection(_connectionString);
        using var cmd = new SqlCommand("dbo.RegistrarVenda", conn) { CommandType = CommandType.StoredProcedure };
        cmd.Parameters.AddWithValue("@IdCliente", idCliente);
        cmd.Parameters.AddWithValue("@IdFuncionario", idFuncionario);
        cmd.Parameters.AddWithValue("@Itens", JsonSerializer.Serialize(itens));
        var outputParam = new SqlParameter("@IdVendaGerada", SqlDbType.Int) { Direction = ParameterDirection.Output };
        cmd.Parameters.Add(outputParam);

        conn.Open();
        cmd.ExecuteNonQuery();
        return (int)outputParam.Value;
    }
}

public class VendaService
{
    private readonly IVendaRepository _repository;
    public VendaService(IVendaRepository repository) => _repository = repository; // <- injetado, não criado

    public int Concluir(int idCliente, int idFuncionario, List<ItemVenda> itens)
        => _repository.RegistrarVenda(idCliente, idFuncionario, itens);
}
```

O que mudou do básico para aqui: `VendaService` não sabe mais como o repositório é construído — ele só conhece a interface `IVendaRepository`. Isso permite passar um repositório falso em teste, ou trocar a implementação real (ex.: outro provedor de banco) sem alterar `VendaService`. A `RegistrarVenda` chamada por dentro é exatamente a procedure da seção 1.4.

**Se o material em que você viu "Dependency Injection" for de uma disciplina separada de arquitetura/.NET (não de SQL puro), o item 8.2 é o que provavelmente importa. Se for um tópico dentro da própria ementa de banco de dados, o item 8.1 é o que se encaixa.** Vale confirmar com o enunciado original ou professor qual dos dois é o esperado.
