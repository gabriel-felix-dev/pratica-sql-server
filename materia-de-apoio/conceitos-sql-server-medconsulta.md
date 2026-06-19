# Conceitos de SQL Server — Banco MedConsulta

> Material de referência baseado no schema e nos dados do banco `MedConsulta`. Tópico de Dependency Injection removido por não ser um conceito de banco de dados.

## Índice
1. [Stored Procedures](#1-stored-procedures)
2. [Jobs (SQL Server Agent)](#2-jobs-sql-server-agent)
3. [Functions](#3-functions)
4. [Triggers](#4-triggers)
5. [CTE](#5-cte)
6. [Window Functions](#6-window-functions)
7. [Indexes](#7-indexes)

---

## 1. Stored Procedures

### Conceito
Bloco de T-SQL pré-compilado e armazenado no servidor, executado por nome com parâmetros. Duas vantagens reais sobre mandar a query crua pela aplicação:

- **Plano de execução cacheado** — a primeira execução compila e guarda o plano; chamadas seguintes reaproveitam, economizando CPU.
- **Menos tráfego de rede** — a aplicação manda `EXEC nome @param = valor`, não o texto inteiro da query.

Efeito colateral útil: centraliza a lógica de acesso a dados em um lugar só, então uma trava de segurança pode liberar permissão só na procedure, sem dar acesso direto às tabelas.

### Exemplo — consulta parametrizada (range, não função sobre coluna)

```sql
CREATE PROCEDURE dbo.ObterConsultasPorPaciente
    @IdPaciente INT,
    @DataInicio DATE,
    @DataFim DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.Id,
        c.Codigo,
        c.DataHora,
        c.ValorBase,
        m.Nome AS Medico,
        sc.Nome AS Status
    FROM Consulta c
    INNER JOIN Medico m ON m.Id = c.IdMedico
    INNER JOIN StatusConsulta sc ON sc.Id = c.IdStatusConsulta
    WHERE c.IdPaciente = @IdPaciente
      AND c.DataHora >= @DataInicio
      AND c.DataHora < DATEADD(DAY, 1, @DataFim);
END;
GO

EXEC dbo.ObterConsultasPorPaciente 
    @IdPaciente = 1, @DataInicio = '2026-05-01', @DataFim = '2026-05-31';
```

`SET NOCOUNT ON` evita que o SQL Server mande de volta a mensagem "(N linha(s) afetada(s))" a cada comando — reduz round-trip de rede. Vale colocar em toda procedure.

### Exemplo — escrita com validação e transação

```sql
CREATE PROCEDURE dbo.CadastrarConsulta
    @IdPaciente INT,
    @IdMedico INT,
    @IdTipoAtendimento TINYINT,
    @Codigo VARCHAR(50),
    @DataHora DATETIME,
    @ValorBase DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Id = @IdPaciente)
    BEGIN
        RAISERROR('Paciente inexistente.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Consulta (IdPaciente, IdMedico, IdTipoAtendimento, IdStatusConsulta, Codigo, DataHora, ValorBase)
        VALUES (@IdPaciente, @IdMedico, @IdTipoAtendimento, 1, @Codigo, @DataHora, @ValorBase); -- 1 = Pendente

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
```

**Atenção:** evite prefixar procedures de usuário com `sp_`. Esse prefixo é convenção reservada para procedures de sistema — quando o SQL Server encontra um nome `sp_*`, ele primeiro procura no banco `master` antes do banco atual, gerando overhead de busca desnecessário a cada chamada. Por isso os exemplos acima usam `ObterConsultasPorPaciente`, não `sp_ObterConsultasPorPaciente`.

---

## 2. Jobs (SQL Server Agent)

### Conceito
Job não é T-SQL puro — é uma tarefa agendada gerenciada pelo **SQL Server Agent**, um serviço separado do motor do banco. Cada Job tem:
- **Steps**: um ou mais comandos (T-SQL, PowerShell, SSIS...) executados em sequência.
- **Schedule**: frequência (diário, semanal, ao iniciar o serviço, etc.).

**Atenção de escopo:** SQL Server Agent existe em instalação on-premises, VM ou Managed Instance. **Não existe** em Azure SQL Database (modelo PaaS serverless) — lá o equivalente é Elastic Jobs ou Azure Automation. Antes de desenhar um Job, confirme em qual ambiente o MedConsulta vai rodar.

### Exemplo — cancelar automaticamente consultas pendentes vencidas

```sql
USE msdb;
GO

EXEC sp_add_job
    @job_name = N'Job_CancelarConsultasPendentesVencidas';

EXEC sp_add_jobstep
    @job_name = N'Job_CancelarConsultasPendentesVencidas',
    @step_name = N'CancelarVencidas',
    @subsystem = N'TSQL',
    @database_name = N'MedConsulta',
    @command = N'
        UPDATE Consulta
        SET IdStatusConsulta = 4 -- Cancelada
        WHERE IdStatusConsulta = 1 -- Pendente
          AND DataHora < CAST(GETDATE() AS DATE);
    ';

EXEC sp_add_schedule
    @schedule_name = N'Diario_01h',
    @freq_type = 4,         -- diário
    @freq_interval = 1,
    @active_start_time = 010000;

EXEC sp_attach_schedule
    @job_name = N'Job_CancelarConsultasPendentesVencidas',
    @schedule_name = N'Diario_01h';

EXEC sp_add_jobserver
    @job_name = N'Job_CancelarConsultasPendentesVencidas';
```

**Atenção real de performance:** esse `UPDATE` roda todo dia varrendo `IdStatusConsulta` e `DataHora`. Sem índice nessas colunas, cada execução do job vira um table scan completo na tabela `Consulta` — que só tende a crescer. Ver seção [Indexes](#7-indexes) para o índice que resolve isso.

---

## 3. Functions

### Conceito
Duas categorias relevantes:
- **Scalar Function**: recebe parâmetros, devolve um único valor.
- **Table-Valued Function (TVF)**: devolve uma tabela — pode ser *inline* (uma única instrução `RETURN (SELECT ...)`) ou *multi-statement* (corpo com várias instruções e uma tabela declarada).

### Exemplo — scalar function

```sql
CREATE FUNCTION dbo.ValorTotalConsulta (@IdConsulta INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2);

    SELECT @Total = ValorBase 
                   + ISNULL(TaxaConsultorio, 0)
                   + ISNULL(TaxaPlataforma, 0)
                   + ISNULL(TaxaInsumos, 0)
                   + ISNULL(TaxaAnestesia, 0)
    FROM Consulta
    WHERE Id = @IdConsulta;

    RETURN @Total;
END;
GO

SELECT Id, Codigo, dbo.ValorTotalConsulta(Id) AS ValorTotal
FROM Consulta;
```

**Atenção — o ponto fraco dessa abordagem:** scalar function chamada dentro de um `SELECT` roda **linha a linha** (RBAR — row by agonizing row), sem paralelismo, mesmo em versões mais antigas do SQL Server. Em uma tabela com 2000 linhas como a `Consulta` do exemplo isso ainda passa despercebido, mas em produção com volume real vira gargalo. O mesmo cálculo direto no `SELECT` é praticamente gratuito:

```sql
SELECT Id, Codigo,
    ValorBase + ISNULL(TaxaConsultorio,0) + ISNULL(TaxaPlataforma,0) 
              + ISNULL(TaxaInsumos,0) + ISNULL(TaxaAnestesia,0) AS ValorTotal
FROM Consulta;
```

Regra prática: scalar function é conveniente para reuso de lógica em poucos lugares e baixo volume; para relatórios sobre tabela grande, inline o cálculo.

### Exemplo — inline table-valued function (mais barata)

```sql
CREATE FUNCTION dbo.ConsultasPorClinica (@IdClinica TINYINT)
RETURNS TABLE
AS
RETURN
(
    SELECT c.Id, c.Codigo, c.DataHora, c.ValorBase, p.Nome AS Paciente
    FROM Consulta c
    INNER JOIN Medico m ON m.Id = c.IdMedico
    INNER JOIN Paciente p ON p.Id = c.IdPaciente
    WHERE m.IdClinica = @IdClinica
);
GO

SELECT * FROM dbo.ConsultasPorClinica(1);
```

Diferente da scalar function, a iTVF é "desmontada" pelo otimizador como se fosse uma view parametrizada — o plano de execução enxerga a query inteira, não chamada por chamada. Prefira essa forma sempre que possível.

---

## 4. Triggers

### Conceito
Bloco disparado automaticamente em resposta a um evento `INSERT`, `UPDATE` ou `DELETE` (ou evento DDL). Duas variantes:
- **AFTER**: roda depois que a operação já aconteceu — uso típico é auditoria.
- **INSTEAD OF**: substitui a operação — uso típico é em views que não são atualizáveis diretamente.

Ponto que costuma confundir: o trigger dispara **uma vez por instrução**, não uma vez por linha. As tabelas virtuais `inserted` e `deleted` trazem o conjunto inteiro de linhas afetadas — a lógica precisa ser set-based, não um loop linha a linha.

### Exemplo — auditoria de mudança de status

```sql
CREATE TABLE ConsultaStatusAuditoria (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdConsulta INT NOT NULL,
    StatusAnterior TINYINT NOT NULL,
    StatusNovo TINYINT NOT NULL,
    DataAlteracao DATETIME NOT NULL DEFAULT GETDATE()
);
GO

CREATE TRIGGER trg_Consulta_AuditoriaStatus
ON Consulta
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(IdStatusConsulta) RETURN; -- só processa se a coluna realmente mudou

    INSERT INTO ConsultaStatusAuditoria (IdConsulta, StatusAnterior, StatusNovo)
    SELECT i.Id, d.IdStatusConsulta, i.IdStatusConsulta
    FROM inserted i
    INNER JOIN deleted d ON d.Id = i.Id
    WHERE i.IdStatusConsulta <> d.IdStatusConsulta;
END;
GO
```

`IF NOT UPDATE(coluna) RETURN` evita rodar a lógica de auditoria em updates que não mexeram em `IdStatusConsulta` — sem essa checagem, todo `UPDATE` na tabela (mesmo de outra coluna) dispararia o INSERT na tabela de auditoria.

**Risco real para esse banco especificamente:** o Job da seção 2 faz `UPDATE` em massa em `Consulta` todo dia. Com esse trigger ativo, cada linha cancelada gera uma linha de auditoria — comportamento esperado, mas é exatamente esse tipo de interação escondida (trigger reagindo a um job, que por sua vez foi disparado por agendamento) que dificulta debugar "por que essa tabela de auditoria cresceu tanto" se ninguém documentar a cadeia.

---

## 5. CTE

Conceito básico (tabela temporária nomeada via `WITH`) já foi coberto antes. Aqui, o caso que ainda não vimos: **CTE recursiva**.

### Exemplo — gerar calendário de dias para relatório

```sql
;WITH Calendario AS (
    SELECT CAST('2026-05-01' AS DATE) AS Dia
    UNION ALL
    SELECT DATEADD(DAY, 1, Dia)
    FROM Calendario
    WHERE Dia < '2026-05-31'
)
SELECT 
    cal.Dia,
    COUNT(c.Id) AS QtdConsultas
FROM Calendario cal
LEFT JOIN Consulta c ON CAST(c.DataHora AS DATE) = cal.Dia
GROUP BY cal.Dia
ORDER BY cal.Dia
OPTION (MAXRECURSION 100);
```

Estrutura de uma CTE recursiva: âncora (`SELECT` inicial) + `UNION ALL` + referência a ela mesma + condição de parada. O limite padrão é 100 níveis de recursão; `OPTION (MAXRECURSION 100)` aqui é redundante (é o próprio padrão), mas fica explícito — se o intervalo de datas for maior que 100 dias, precisa aumentar esse valor ou a query falha.

**Atenção:** `CAST(c.DataHora AS DATE)` do lado da coluna no `JOIN` tem o mesmo problema que função sobre coluna no `WHERE` — quebra uso de índice em `DataHora` se a tabela `Consulta` crescer. Para um relatório esporádico em tabela pequena não importa; para relatório diário em tabela com milhões de linhas, vale ter uma coluna persistida (`DataSomenteData AS CAST(DataHora AS DATE) PERSISTED`) com índice próprio.

---

## 6. Window Functions

### Conceito
Calculam um valor por linha **olhando para um conjunto de linhas relacionado** (definido por `PARTITION BY`), sem colapsar o resultado como um `GROUP BY` faria. Diferença chave: `GROUP BY` reduz N linhas a 1 por grupo; window function mantém as N linhas e adiciona uma coluna calculada.

### Exemplo — ranking de médicos por faturamento, dentro de cada clínica

```sql
SELECT 
    m.Nome AS Medico,
    cl.Nome AS Clinica,
    SUM(c.ValorBase) AS FaturamentoTotal,
    RANK() OVER (PARTITION BY cl.Id ORDER BY SUM(c.ValorBase) DESC) AS Ranking
FROM Consulta c
INNER JOIN Medico m ON m.Id = c.IdMedico
INNER JOIN Clinica cl ON cl.Id = m.IdClinica
WHERE c.IdStatusConsulta = 3 -- Realizada
GROUP BY m.Id, m.Nome, cl.Id, cl.Nome;
```

`RANK()` deixa empate com o mesmo número e pula o próximo (1, 1, 3...). Se quiser sequência sem pular, troque por `DENSE_RANK()`. Se quiser só numerar sem empate (cada linha um número único), use `ROW_NUMBER()`.

### Exemplo — receita acumulada por mês (running total)

```sql
SELECT
    DATEPART(YEAR, DataHora) AS Ano,
    DATEPART(MONTH, DataHora) AS Mes,
    SUM(ValorBase) AS ReceitaMes,
    SUM(SUM(ValorBase)) OVER (
        ORDER BY DATEPART(YEAR, DataHora), DATEPART(MONTH, DataHora) 
        ROWS UNBOUNDED PRECEDING
    ) AS ReceitaAcumulada
FROM Consulta
WHERE IdStatusConsulta = 3
GROUP BY DATEPART(YEAR, DataHora), DATEPART(MONTH, DataHora)
ORDER BY Ano, Mes;
```

Reparem: `DATEPART` foi usado em vez de `FORMAT(DataHora, 'yyyy-MM')` — `FORMAT` converte pra string e é mais lento, exatamente a regra já vista na seção de funções de data/hora do material anterior.

### Exemplo — última consulta de cada paciente (CTE + window function)

```sql
;WITH UltimaConsultaPaciente AS (
    SELECT 
        c.*,
        ROW_NUMBER() OVER (PARTITION BY c.IdPaciente ORDER BY c.DataHora DESC) AS rn
    FROM Consulta c
)
SELECT * FROM UltimaConsultaPaciente WHERE rn = 1;
```

Padrão clássico "pegar o N mais recente por grupo": `ROW_NUMBER()` particionado pela chave do grupo, filtrando `rn = 1` na CTE de fora — não dá pra filtrar `WHERE rn = 1` direto, porque window function não pode ser referenciada no `WHERE` da mesma query onde foi calculada (por isso precisa da CTE como camada intermediária).

---

## 7. Indexes

### Conceito
Estrutura que evita varrer a tabela inteira para encontrar linhas. Dois tipos principais:
- **Clustered**: define a ordem física das linhas na tabela — só pode existir um por tabela. No MedConsulta, toda `PRIMARY KEY` criada sem especificar `NONCLUSTERED` já virou um índice clustered automaticamente (é o comportamento padrão do SQL Server).
- **Nonclustered**: estrutura separada, com ponteiro de volta pra linha — pode ter vários por tabela.

### O ponto que costuma passar despercebido neste schema
**Foreign Key não ganha índice automático.** O SQL Server cria índice sozinho só para `PRIMARY KEY` e colunas `UNIQUE`. Todas as colunas `IdPaciente`, `IdMedico`, `IdTipoAtendimento`, `IdStatusConsulta` em `Consulta` são FKs **sem índice** até alguém criar manualmente — o que significa que todo `JOIN` ou `WHERE` usando essas colunas faz table scan por padrão.

### Exemplo — índice para a procedure da seção 1

```sql
CREATE NONCLUSTERED INDEX IX_Consulta_IdPaciente_DataHora
ON Consulta (IdPaciente, DataHora);
```

Ordem das colunas importa: `IdPaciente` primeiro porque é filtro de igualdade (`= @IdPaciente`), `DataHora` depois porque é filtro de range (`>= ... AND < ...`). Índice composto na ordem errada (DataHora primeiro) não seria usado da mesma forma eficiente.

### Exemplo — índice cobrindo para o ranking da seção 6

```sql
CREATE NONCLUSTERED INDEX IX_Consulta_IdMedico_Status
ON Consulta (IdMedico, IdStatusConsulta)
INCLUDE (ValorBase);
```

`INCLUDE (ValorBase)` guarda esse valor direto na folha do índice — a query de ranking não precisa voltar na tabela base (*key lookup*) para buscar `ValorBase`, já encontra tudo que precisa no próprio índice.

### Exemplo — índice para o Job da seção 2

```sql
CREATE NONCLUSTERED INDEX IX_Consulta_Status_DataHora
ON Consulta (IdStatusConsulta, DataHora);
```

Resolve diretamente o table scan diário mencionado na seção 2: o `UPDATE` filtra por `IdStatusConsulta = 1 AND DataHora < ...`, e esse índice atende exatamente esse padrão.

**Contrapeso real — não existe índice de graça:** toda `INSERT`/`UPDATE`/`DELETE` em `Consulta` agora precisa atualizar 3 índices nonclustered além do clustered. Com o Job rodando `UPDATE` em massa todo dia e o trigger de auditoria também ativo na mesma tabela, cada índice adicionado é custo de escrita a mais. Antes de criar um índice, vale confirmar que a query que ele otimiza roda com frequência suficiente para compensar esse custo — índice criado para uma consulta ocasional de relatório raramente vale a pena.

---

## Resumo — quando usar o quê

| Tópico | Usar quando |
|---|---|
| Stored Procedure | Lógica de acesso a dados reutilizada pela aplicação, precisa de plano cacheado e parâmetros |
| Job | Tarefa recorrente sem intervenção manual (manutenção, limpeza, processos em lote) |
| Scalar Function | Cálculo reutilizado em poucos lugares, baixo volume de linhas |
| Inline TVF | Lógica de tabela reutilizável, volume maior — otimizador trata como view |
| Trigger | Reação automática e obrigatória a uma mudança de dado (auditoria, integridade que `CHECK`/FK não cobrem) |
| CTE | Organizar subquery repetida ou lógica recursiva (hierarquia, séries) |
| Window Function | Cálculo por linha que depende de um grupo, sem perder o detalhe da linha (ranking, acumulado, "último de cada") |
| Index | Qualquer coluna usada com frequência em `WHERE`, `JOIN` ou `ORDER BY` — balanceado contra custo de escrita |
