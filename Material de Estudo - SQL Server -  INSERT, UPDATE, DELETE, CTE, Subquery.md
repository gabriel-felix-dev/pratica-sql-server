# Material de Estudo — SQL Server: INSERT, UPDATE, DELETE, CTE, Subquery

Baseado nas queries do projeto `query-banco-ricardo.sql`.

---

## O Modelo de Dados

Antes de qualquer query, você precisa entender o que existe no banco:

```
Usuario
  Id, Nome

Logon
  Id, IdUsuario (FK → Usuario), DataLogon (DATETIME), Sucesso (BIT/INT)

OpcaoAcionada
  Id, IdLogon (FK → Logon), IdOpcao (FK → Opcao), InstanteLogon (DATETIME)

Opcao
  Id, Nome
```

Regra de dependência: `OpcaoAcionada` depende de `Logon`, que depende de `Usuario`.
Isso importa na ordem de DELETE e INSERT.

---

## 1. DECLARE e Variáveis

```sql
DECLARE @hoje DATE = CAST(GETDATE() AS DATE);
```

- `DECLARE` cria uma variável local válida apenas no batch atual
- Serve para calcular um valor uma vez e reusar em múltiplos lugares
- Alternativa sem DECLARE: CTE ou subquery escalar inline

**Quando usar DECLARE vs CTE:**
- DECLARE → quando o valor precisa ser reusado em múltiplos statements separados (ex: dois UPDATEs)
- CTE → quando o valor é usado apenas dentro de um único statement

---

## 2. Sargability — Filtros que usam índice

**Errado (non-sargable):**
```sql
WHERE CAST(DataLogon AS DATE) = GETDATE()
-- aplica função na coluna → SQL Server não consegue usar o índice
```

**Certo (sargable):**
```sql
DECLARE @hoje DATE = CAST(GETDATE() AS DATE);
WHERE DataLogon >= @hoje
  AND DataLogon <  DATEADD(DAY, 1, @hoje)
-- compara a coluna diretamente → usa índice (index seek)
```

A regra é simples: **nunca aplique função na coluna do WHERE**. Aplique na constante.

---

## 3. Subquery

Uma subquery é uma query escrita dentro de outra query. O resultado da subquery é usado pela query externa como se fosse um valor, uma tabela ou uma condição.

Pode aparecer em quatro lugares: `WHERE`, `FROM`, `SELECT` e `HAVING`.

---

### 3a. Subquery no WHERE — filtro por valor calculado

Resolve um valor (ou lista de valores) e usa como condição de filtro.

**Retornando um único valor (escalar):**
```sql
-- Usuário que mais logou hoje
SELECT ua.Id, ua.Nome
    FROM Usuario AS ua
    WHERE ua.Id = (
        SELECT TOP 1 IdUsuario
            FROM Logon
            WHERE DataLogon >= CAST(GETDATE() AS DATE)
            GROUP BY IdUsuario
            ORDER BY COUNT(*) DESC
    );
```
Se a subquery retornar mais de 1 linha aqui, o SQL Server lança erro. Use `TOP 1` para garantir.

**Retornando uma lista — IN:**
```sql
-- Usuários que logaram hoje
SELECT Nome FROM Usuario
    WHERE Id IN (
        SELECT DISTINCT IdUsuario
            FROM Logon
            WHERE DataLogon >= CAST(GETDATE() AS DATE)
    );
```

**Retornando uma comparação — operadores > < >= <=:**
```sql
-- Cargas com peso acima da média geral
SELECT Id, Peso FROM Carga
    WHERE Peso > (SELECT AVG(Peso) FROM Carga);
```

**Subquery correlacionada — referencia a query externa:**
```sql
-- Cargas com peso acima da média do seu próprio tipo
SELECT Id, TipoCarga, Peso
    FROM Carga AS c
    WHERE c.Peso > (
        SELECT AVG(Peso)
            FROM Carga
            WHERE TipoCarga = c.TipoCarga  -- referencia c da query externa
    );
```
A subquery correlacionada roda uma vez **por linha** da query externa. Pode ser lenta em tabelas grandes.

---

### 3b. Subquery no FROM — tabela derivada

O resultado da subquery vira uma tabela temporária com alias. Obrigatório ter alias.

```sql
-- Isola o usuário campeão antes dos JOINs
SELECT us.Nome, op.Nome AS Opcao
    FROM (
        SELECT TOP 1 IdUsuario
            FROM Logon
            WHERE DataLogon >= CAST(GETDATE() AS DATE)
            GROUP BY IdUsuario
            ORDER BY COUNT(*) DESC
    ) AS top1                               -- alias obrigatório
        INNER JOIN Usuario       AS us ON us.Id       = top1.IdUsuario
        INNER JOIN Logon         AS lg ON lg.IdUsuario = us.Id
        INNER JOIN OpcaoAcionada AS oa ON oa.IdLogon   = lg.Id
        INNER JOIN Opcao         AS op ON op.Id        = oa.IdOpcao;
```

**Quando usar subquery no FROM em vez de CTE:**
- Query pontual que não precisa de legibilidade extra
- Quando CTEs estão proibidas (como nas questões da transportadora)
- Quando a derived table é usada em apenas um lugar

**Subquery no FROM com agregação — evitar re-escanear a tabela:**
```sql
-- Calcula ranking antes de filtrar
SELECT * FROM (
    SELECT IdUsuario, COUNT(*) AS Total,
           DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS Posicao
        FROM Logon
        GROUP BY IdUsuario
) AS ranqueado
WHERE ranqueado.Posicao = 2;
```

---

### 3c. Subquery no SELECT — coluna calculada

Retorna exatamente 1 valor por linha. Se retornar mais de 1 linha, erro imediato.

```sql
SELECT
    us.Nome,
    COUNT(DISTINCT CAST(lg.DataLogon AS DATE)) AS DiasAtivo,
    (SELECT DATEDIFF(DAY,
                MIN(CAST(DataLogon AS DATE)),
                MAX(CAST(DataLogon AS DATE))) + 1
         FROM Logon) AS TotalDiasPeriodo
    FROM Usuario AS us
        INNER JOIN Logon AS lg ON lg.IdUsuario = us.Id
    GROUP BY us.Nome;
```

**Quando usar subquery no SELECT em vez de CTE:**
- O valor escalar é simples e não se repete muito
- Quando CTEs estão proibidas

**Quando NÃO usar:**
- Quando o mesmo cálculo aparece 3+ vezes na query — prefira CTE
- Subquery correlacionada no SELECT roda por linha — pode impactar performance em tabelas grandes

---

### 3d. Subquery no HAVING — filtro de grupo por valor calculado

```sql
-- Tipos de carga com média de peso acima da média geral
SELECT TipoCarga, AVG(Peso) AS MediaPeso
    FROM Carga
    GROUP BY TipoCarga
    HAVING AVG(Peso) > (SELECT AVG(Peso) FROM Carga);
```

```sql
-- Cidades com mais clientes que a média de clientes por cidade
SELECT Cidade, COUNT(*) AS TotalClientes
    FROM Cliente
    GROUP BY Cidade
    HAVING COUNT(*) > (
        SELECT AVG(TotalPorCidade)
            FROM (
                SELECT COUNT(*) AS TotalPorCidade
                    FROM Cliente
                    GROUP BY Cidade
            ) AS sub
    );
```

---

### 3e. NOT IN — armadilha do NULL

```sql
-- Intenção: usuários que nunca logaram
SELECT Nome FROM Usuario
    WHERE Id NOT IN (SELECT IdUsuario FROM Logon);
```

**Problema:** se `Logon` tiver qualquer linha com `IdUsuario = NULL`, o `NOT IN` retorna zero resultados — sem erro, sem aviso.

**Solução segura:**
```sql
-- Opção 1: filtrar NULL na subquery
WHERE Id NOT IN (
    SELECT IdUsuario FROM Logon WHERE IdUsuario IS NOT NULL
)

-- Opção 2: usar NOT EXISTS (mais robusto)
WHERE NOT EXISTS (
    SELECT 1 FROM Logon WHERE Logon.IdUsuario = Usuario.Id
)
```

---

### 3f. EXISTS vs IN — quando usar cada um

| Situação | Preferir |
|---|---|
| Lista pequena de valores fixos | `IN` |
| Subquery que pode retornar NULL | `EXISTS` |
| Só precisa saber se existe (não importa o valor) | `EXISTS` |
| Subquery retorna muitas linhas | `EXISTS` (para assim que achar o primeiro) |

```sql
-- EXISTS: para quando só importa a existência
SELECT Nome FROM Usuario AS u
    WHERE EXISTS (
        SELECT 1 FROM Logon WHERE IdUsuario = u.Id
    );
```

O `SELECT 1` dentro do EXISTS é convencional — o valor retornado não importa, só se existe linha.

---

### 3g. Subquery vs CTE — quando escolher cada um

| Critério | Subquery | CTE |
|---|---|---|
| Usada uma vez | Subquery no FROM | Indiferente |
| Usada múltiplas vezes no mesmo statement | Ruim — repete código | CTE — define uma vez |
| Encadeamento de lógica complexa | Difícil de ler | CTE encadeada |
| CTEs proibidas (restrição do exercício) | Única opção | — |
| DELETE / UPDATE com lógica complexa | Limitado | CTE é mais expressivo |
| Performance | Igual na maioria dos casos | Igual na maioria dos casos |

---

### 3h. Resumo visual — onde subquery pode aparecer

```sql
SELECT
    coluna,
    (SELECT valor FROM ...) AS colunaCalculada   ← no SELECT (escalar)
FROM
    (SELECT ... FROM ...) AS derived             ← no FROM (tabela derivada)
WHERE
    coluna = (SELECT valor FROM ...)             ← no WHERE (escalar)
    coluna IN (SELECT valores FROM ...)          ← no WHERE (lista)
    EXISTS (SELECT 1 FROM ... WHERE ...)         ← no WHERE (existência)
HAVING
    COUNT(*) > (SELECT valor FROM ...)           ← no HAVING (escalar)
```

---

## 4. CTE — Common Table Expression

Uma CTE é um bloco nomeado que você define antes do statement principal. Pense nela como uma "tabela temporária com nome" que existe apenas durante aquela execução.

```sql
WITH NomeDoCTE AS (
    -- qualquer SELECT aqui
)
SELECT ... FROM NomeDoCTE;
```

---

### 4a. Por que usar CTE?

Três motivos principais:

**1. Legibilidade** — quebra uma query complexa em partes nomeadas e legíveis.

**2. Reutilização dentro do statement** — calcula um resultado uma vez e referencia várias vezes sem repetir código.

**3. Habilitar operações que subquery não permite diretamente** — como DELETE e UPDATE com lógica complexa.

---

### 4b. CTE simples — isolar um subconjunto

```sql
-- Sem CTE: difícil de ler
SELECT us.Nome
    FROM Usuario AS us
    WHERE us.Id IN (
        SELECT TOP 1 IdUsuario FROM Logon
            WHERE DataLogon >= CAST(GETDATE() AS DATE)
            GROUP BY IdUsuario
            ORDER BY COUNT(*) DESC
    );

-- Com CTE: intenção clara
WITH CampeaoHoje AS (
    SELECT TOP 1 IdUsuario
        FROM Logon
        WHERE DataLogon >= CAST(GETDATE() AS DATE)
        GROUP BY IdUsuario
        ORDER BY COUNT(*) DESC
)
SELECT us.Nome
    FROM Usuario AS us
        INNER JOIN CampeaoHoje AS ch ON ch.IdUsuario = us.Id;
```

---

### 4c. CTE encadeada — múltiplos blocos

CTEs encadeadas são separadas por vírgula. Cada bloco pode referenciar os anteriores.

```sql
WITH
-- Bloco 1: calcula o período total
Periodo AS (
    SELECT DATEDIFF(DAY,
               MIN(CAST(DataLogon AS DATE)),
               MAX(CAST(DataLogon AS DATE))) + 1 AS TotalDias
        FROM Logon
),
-- Bloco 2: conta dias ativos por usuário (referencia nada, independente)
AtividadePorUsuario AS (
    SELECT IdUsuario,
           COUNT(DISTINCT CAST(DataLogon AS DATE)) AS DiasAtivo
        FROM Logon
        GROUP BY IdUsuario
),
-- Bloco 3: calcula frequência (referencia os dois anteriores)
Frequencia AS (
    SELECT ap.IdUsuario,
           ap.DiasAtivo,
           pr.TotalDias,
           CAST(ap.DiasAtivo * 100.0 / pr.TotalDias AS DECIMAL(5,2)) AS Pct
        FROM AtividadePorUsuario AS ap
            CROSS JOIN Periodo AS pr
)
SELECT us.Nome, fr.DiasAtivo, fr.TotalDias, fr.Pct
    FROM Frequencia AS fr
        INNER JOIN Usuario AS us ON us.Id = fr.IdUsuario
    ORDER BY fr.Pct DESC;
```

**Regra:** cada bloco só pode referenciar CTEs definidas **antes** dele. Nunca para frente.

---

### 4d. CTE + INSERT

O CTE prepara os dados, o INSERT consome.

```sql
WITH FonteDados AS (
    SELECT IdUsuario, DataLogon, Sucesso
        FROM Logon
        WHERE DataLogon >= CAST(GETDATE() AS DATE)
)
INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
    SELECT IdUsuario, DATEADD(DAY, -3, DataLogon), Sucesso
        FROM FonteDados;
```

---

### 4e. CTE + UPDATE

```sql
WITH SegundoColocado AS (
    SELECT IdUsuario,
           DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS Posicao
        FROM Logon
        GROUP BY IdUsuario
)
UPDATE lg
    SET lg.DataLogon = DATEADD(DAY, 3, lg.DataLogon)
    FROM Logon AS lg
        INNER JOIN SegundoColocado AS sc ON sc.IdUsuario = lg.IdUsuario
    WHERE sc.Posicao = 2;
```

O alias no `UPDATE` (`lg`) deve bater com o alias no `FROM`.

---

### 4f. CTE + DELETE

```sql
WITH Inconsistentes AS (
    SELECT oa.Id
        FROM OpcaoAcionada AS oa
            INNER JOIN Logon AS lg ON lg.Id = oa.IdLogon
        WHERE lg.Sucesso = 0
)
DELETE FROM Inconsistentes;
```

Isso funciona porque o CTE aponta diretamente para linhas de `OpcaoAcionada` — o SQL Server sabe qual tabela deletar.

---

### 4g. CTE para remapear IDs — o caso mais importante do projeto

Esse padrão resolve o problema de "preciso inserir na tabela filho mas os IDs do pai mudaram":

```sql
-- Situação: inserimos logons backdatados (-3 dias) para cada usuário.
-- Agora precisamos inserir as OpcaoAcionada vinculadas aos NOVOS IDs de logon,
-- não aos IDs originais de hoje.

WITH Remapeado AS (
    SELECT
        ln.Id        AS IdLogonNovo,   -- logon backdatado (destino)
        oa.IdOpcao,
        oa.InstanteLogon
        FROM OpcaoAcionada AS oa
            INNER JOIN Logon AS lv ON lv.Id = oa.IdLogon          -- logon de hoje (fonte)
            INNER JOIN Logon AS ln ON ln.IdUsuario = lv.IdUsuario  -- logon backdatado
                                  AND ln.DataLogon = DATEADD(DAY, -3, lv.DataLogon)
        WHERE lv.DataLogon >= CAST(GETDATE() AS DATE)
)
INSERT INTO OpcaoAcionada (IdLogon, IdOpcao, InstanteLogon)
    SELECT IdLogonNovo, IdOpcao, InstanteLogon
        FROM Remapeado;
```

Sem o CTE, esse remapeamento seria impossível de expressar de forma clara.

---

### 4h. CTE de valor escalar — alternativa ao DECLARE

Quando você precisa de um valor único disponível para toda a query:

```sql
-- Com DECLARE (precisa de statement separado)
DECLARE @media DECIMAL(10,2) = (SELECT AVG(Peso) FROM Carga);
SELECT * FROM Carga WHERE Peso > @media;

-- Com CTE (tudo em um statement)
WITH Media AS (
    SELECT AVG(Peso) AS Valor FROM Carga
)
SELECT c.*
    FROM Carga AS c
        CROSS JOIN Media AS m
    WHERE c.Peso > m.Valor;
```

---

### 4i. Limitações das CTEs

| Limitação | Detalhe |
|---|---|
| Escopo | Válida apenas para o statement imediatamente seguinte |
| Sem índice | Não é possível criar índice em CTE como em tabela temporária |
| Pode ser expandida | O optimizer pode "abrir" o CTE e reescrever — não é garantia de execução uma só vez |
| Não persiste | Diferente de `#TempTable` ou `@TabelaVariavel`, não sobrevive entre statements |

**Quando preferir tabela temporária ao invés de CTE:**
- Quando o mesmo resultado precisa ser usado em múltiplos statements separados → use `@TabelaVariavel` ou `#TempTable`
- Quando o CTE é referenciado muitas vezes e o optimizer o expande repetidamente → materialize em `#TempTable`

---

### 4j. Resumo visual — onde CTE pode aparecer

```
WITH MeuCTE AS ( SELECT ... )
         ↓
    SELECT  ← consulta
    INSERT  ← inserção com dados do CTE
    UPDATE  ← atualização via JOIN com CTE
    DELETE  ← deleção via CTE que aponta para a tabela alvo
```

---

## 5. INSERT

### INSERT simples com SELECT
```sql
INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
    SELECT us.Id, GETDATE(), 1
        FROM Usuario AS us;
```
Insere uma linha por usuário.

### INSERT com subquery para replicar dados
```sql
INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
    SELECT IdUsuario, DATEADD(DAY, -3, DataLogon), Sucesso
        FROM Logon
        WHERE DataLogon >= @hoje
          AND DataLogon <  DATEADD(DAY, 1, @hoje);
```

### INSERT com OUTPUT — capturando IDs gerados
```sql
DECLARE @Capturados TABLE (Id INT, IdUsuario INT);

INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
    OUTPUT inserted.Id, inserted.IdUsuario INTO @Capturados
    SELECT us.Id, GETDATE(), 1
        FROM Usuario AS us;
```
`OUTPUT inserted.*` devolve os valores das linhas recém-inseridas, incluindo o Id autoincremental.
Essencial quando você precisa do Id gerado para inserir em outra tabela logo em seguida.

### Gerador de linhas sem WHILE
```sql
WITH Numeros AS (
    SELECT TOP 1000
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
        FROM sys.all_objects
)
INSERT INTO Tabela ...
SELECT ... FROM Numeros;
```
`sys.all_objects` sempre tem mais de 1000 linhas. O `ROW_NUMBER()` gera números sequenciais. Evita loop `WHILE`.

---

## 6. UPDATE

### UPDATE com JOIN
```sql
UPDATE lg
    SET lg.DataLogon = DATEADD(DAY, 3, lg.DataLogon)
    FROM Logon AS lg
        INNER JOIN OutraTabela AS ot ON ot.IdUsuario = lg.IdUsuario;
```
No SQL Server, o `UPDATE` pode receber `FROM` com JOINs. O alias antes do `SET` deve ser o mesmo do `FROM`.

### UPDATE com DATEADD e DATEDIFF
```sql
-- Avança todas as datas do usuário para exatamente 3 dias a partir de hoje
SET DataLogon = DATEADD(DAY,
                    DATEDIFF(DAY, DataLogon, DATEADD(DAY, 3, GETDATE())),
                    DataLogon)
```
`DATEDIFF` calcula a diferença. `DATEADD` aplica. Preserva hora/min/ms.

---

## 7. DELETE

### Ordem importa — respeite a FK
```sql
-- 1. Primeiro filhos (OpcaoAcionada)
DELETE oa
    FROM OpcaoAcionada AS oa
        INNER JOIN Logon AS lg ON lg.Id = oa.IdLogon
    WHERE lg.Sucesso = 0;

-- 2. Depois pais (Logon)
DELETE FROM Logon
    WHERE Sucesso = 0;
```

### DELETE com CTE
```sql
WITH Alvo AS (
    SELECT oa.Id
        FROM OpcaoAcionada AS oa
            INNER JOIN Logon AS lg ON lg.Id = oa.IdLogon
        WHERE lg.Sucesso = 0
)
DELETE FROM Alvo;
```

---

## 8. Window Functions — DENSE_RANK e ROW_NUMBER

```sql
SELECT IdUsuario,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS Posicao
    FROM Logon
    GROUP BY IdUsuario
```

| Função | Comportamento em empate |
|---|---|
| `ROW_NUMBER()` | Numera sem repetir — empate recebe números diferentes |
| `DENSE_RANK()` | Repete o número em empate — sem pular posições |
| `RANK()` | Repete o número em empate — pula posições |

Use `DENSE_RANK() = 2` quando quiser todos os que estão tecnicamente em segundo lugar.

---

## 9. CROSS JOIN — Produto Cartesiano

O `CROSS JOIN` combina **cada linha de A com cada linha de B**. Não tem condição de ligação — o resultado é `linhas_A × linhas_B`.

```sql
FROM TabelaA CROSS JOIN TabelaB
```

**Exemplo concreto do projeto:**
Temos 10 usuários e queremos inserir um logon para cada um cruzado com as 5 opções mais acionadas.
Resultado esperado: 10 × 5 = 50 linhas em `OpcaoAcionada`.

```sql
WITH Top5 AS (
    SELECT TOP 5 IdOpcao
        FROM OpcaoAcionada
        GROUP BY IdOpcao
        ORDER BY COUNT(*) DESC
)
INSERT INTO OpcaoAcionada (IdLogon, IdOpcao, InstanteLogon)
    SELECT li.Id, t5.IdOpcao, GETDATE()
        FROM @LogonsInseridos AS li
            CROSS JOIN Top5 AS t5;
```

**Equivalente com ON 1=1:**
```sql
FROM @LogonsInseridos AS li
    INNER JOIN Top5 AS t5 ON 1 = 1
```
Mesmo resultado. `ON 1=1` sempre é verdadeiro, então age como CROSS JOIN. A versão com `CROSS JOIN` é mais clara sobre a intenção.

**Quando usar CROSS JOIN:**
- Distribuir um conjunto fixo de valores para todas as linhas de outra tabela
- Gerar combinações (ex: todos os usuários × todas as opções)
- Propagar um valor escalar calculado em CTE para todas as linhas do SELECT (alternativa ao subquery escalar)

**Quando NÃO usar:**
- Quando as tabelas têm relação — use `INNER JOIN` com condição real
- Tabelas grandes sem filtro — o produto explode em volume (1000 × 1000 = 1.000.000 linhas)

**CROSS JOIN com CTE de valor único (alternativa ao DECLARE):**
```sql
WITH Periodo AS (
    SELECT DATEDIFF(DAY, MIN(CAST(DataLogon AS DATE)),
                         MAX(CAST(DataLogon AS DATE))) + 1 AS TotalDias
        FROM Logon
)
SELECT us.Nome,
       pr.TotalDias
    FROM Usuario AS us
        CROSS JOIN Periodo AS pr;
-- Periodo tem 1 linha → CROSS JOIN distribui TotalDias para cada usuário
```

---

## 10. Funções de Data Úteis

| Função | O que faz |
|---|---|
| `GETDATE()` | Data e hora atual |
| `CAST(GETDATE() AS DATE)` | Só a data, sem hora |
| `DATEADD(DAY, 3, data)` | Soma 3 dias |
| `DATEADD(DAY, -3, data)` | Subtrai 3 dias |
| `DATEDIFF(DAY, dataA, dataB)` | Diferença em dias entre A e B |
| `DATEPART(HOUR, data)` | Extrai apenas a hora |

---

## 11. NULLIF

```sql
NULLIF(valor, comparador)
```
Retorna `NULL` se `valor = comparador`, senão retorna `valor`.

Uso principal: evitar divisão por zero.
```sql
100.0 / NULLIF(COUNT(*), 0)
-- se COUNT = 0, vira NULL em vez de erro
```

---

## 12. LEFT JOIN vs INNER JOIN

| JOIN | Resultado |
|---|---|
| `INNER JOIN` | Só linhas que têm par nas duas tabelas |
| `LEFT JOIN` | Todas as linhas da esquerda, `NULL` onde não há par |

Use `LEFT JOIN` quando quiser incluir registros sem correspondência (ex: opções nunca acionadas, usuários sem logon).

---

## 13. CASE WHEN — Lógica Condicional

Permite criar colunas calculadas com base em condições, como um "se/senão" dentro do SQL.

```sql
SELECT Peso,
       CASE
           WHEN Peso < 50  THEN 'Leve'
           WHEN Peso < 200 THEN 'Média'
           ELSE                 'Pesada'
       END AS FaixaDePeso
    FROM Carga;
```

**CASE dentro de SUM — soma condicional:**
```sql
SELECT
    SUM(CASE WHEN TipoCarga = 'Fragil'   THEN ValorDeclarado ELSE 0 END) AS TotalFragil,
    SUM(CASE WHEN TipoCarga = 'Perigosa' THEN ValorDeclarado ELSE 0 END) AS TotalPerigosa
    FROM Carga;
```
Útil para "pivotar" dados sem precisar de múltiplas queries.

**CASE para classificar NULL:**
```sql
SELECT Nome,
       CASE WHEN Telefone IS NULL THEN 'Sem Contato' ELSE Telefone END AS Contato
    FROM Motorista;
```

**Regras:**
- As condições são avaliadas em ordem — a primeira verdadeira vence
- `ELSE` é opcional; sem ele, retorna `NULL` quando nenhuma condição bate
- Pode ser usado em `SELECT`, `ORDER BY`, `WHERE` e dentro de funções de agregação

---

## 14. HAVING — Filtro sobre Agregações

`WHERE` filtra linhas antes de agrupar. `HAVING` filtra **grupos** depois de agregar.

```sql
SELECT IdUsuario, COUNT(*) AS Total
    FROM Logon
    GROUP BY IdUsuario
    HAVING COUNT(*) > 5;  -- só grupos com mais de 5 logons
```

**WHERE vs HAVING:**
```sql
-- WHERE: filtra antes do GROUP BY (linha a linha)
WHERE DataLogon >= @hoje

-- HAVING: filtra depois do GROUP BY (grupo a grupo)
HAVING COUNT(*) > 10
```

Podem ser usados juntos:
```sql
SELECT TipoCarga, AVG(Peso) AS MediaPeso
    FROM Carga
    WHERE Status <> 'Cancelada'        -- exclui canceladas antes de agrupar
    GROUP BY TipoCarga
    HAVING AVG(Peso) > 150;            -- só tipos com média acima de 150kg
```

---

## 15. IS NULL / IS NOT NULL

`NULL` não é um valor — é ausência de valor. Por isso `= NULL` nunca funciona.

```sql
-- ERRADO
WHERE Telefone = NULL

-- CERTO
WHERE Telefone IS NULL
WHERE Telefone IS NOT NULL
```

**Verificar NULL em JOIN:**
Quando um `LEFT JOIN` não encontra par, todas as colunas da tabela direita ficam `NULL`. Isso pode ser usado para encontrar registros sem correspondência:

```sql
-- Opções que nunca foram acionadas
SELECT op.Id, op.Nome
    FROM Opcao AS op
        LEFT JOIN OpcaoAcionada AS oa ON oa.IdOpcao = op.Id
    WHERE oa.Id IS NULL;
```

**ISNULL() — substituir NULL por um valor padrão:**
```sql
ISNULL(Telefone, 'Não informado')
-- se Telefone for NULL, retorna 'Não informado'
```

---

## 16. LIKE — Busca por Padrão em Texto

```sql
WHERE CNH LIKE '9%'    -- começa com 9
WHERE CNH LIKE '%0'    -- termina com 0
WHERE Nome LIKE '%Silva%'  -- contém Silva em qualquer posição
WHERE CEP  LIKE '0____-___' -- padrão exato com caractere coringa
```

| Curinga | Significado |
|---|---|
| `%` | Qualquer sequência de caracteres (inclusive vazia) |
| `_` | Exatamente um caractere qualquer |

**Combinando com lógica:**
```sql
WHERE CNH LIKE '9%' OR CNH LIKE '%0'
```

---

## 17. GROUP BY e Funções de Agregação

Agrupa linhas com valores iguais e calcula uma função sobre cada grupo.

```sql
SELECT TipoCarga,
       COUNT(*)        AS Total,
       AVG(Peso)       AS MediaPeso,
       SUM(ValorDeclarado) AS ValorTotal,
       MAX(Peso)       AS MaiorPeso,
       MIN(Peso)       AS MenorPeso
    FROM Carga
    GROUP BY TipoCarga;
```

**Regra obrigatória:** toda coluna no `SELECT` que não for função de agregação **deve estar no `GROUP BY`**.

```sql
-- ERRADO: Nome não está no GROUP BY nem é agregado
SELECT TipoCarga, Nome, COUNT(*)
    FROM Carga
    GROUP BY TipoCarga;

-- CERTO
SELECT TipoCarga, COUNT(*)
    FROM Carga
    GROUP BY TipoCarga;
```

**GROUP BY com múltiplas colunas:**
```sql
SELECT TipoCarga, Status, COUNT(*) AS Total
    FROM Carga
    GROUP BY TipoCarga, Status;
-- cria um grupo para cada combinação única de (TipoCarga, Status)
```

**COUNT(*) vs COUNT(coluna):**
- `COUNT(*)` — conta todas as linhas do grupo, incluindo NULLs
- `COUNT(coluna)` — conta apenas linhas onde a coluna não é NULL

---

## 18. Subquery com IN e EXISTS

### IN com subquery
```sql
-- Clientes que têm pelo menos uma carga perigosa
SELECT Nome FROM Cliente
    WHERE Id IN (
        SELECT IdCliente FROM Carga WHERE TipoCarga = 'Perigosa'
    );
```

### NOT IN — cuidado com NULL
Se a subquery retornar qualquer `NULL`, o `NOT IN` retorna zero linhas (armadilha clássica).
Prefira `NOT EXISTS` quando houver risco de NULL:

```sql
-- Veículos que NUNCA iniciaram viagens em MG
SELECT Placa FROM Veiculo
    WHERE Id NOT IN (
        SELECT IdVeiculo FROM Viagem
            INNER JOIN Filial ON Filial.Id = Viagem.IdFilialOrigem
            INNER JOIN Cidade ON Cidade.Id = Filial.IdCidade
            WHERE Cidade.UF = 'MG'
    );
```

### EXISTS / NOT EXISTS
```sql
-- Mais seguro que NOT IN quando há NULLs
SELECT Placa FROM Veiculo AS v
    WHERE NOT EXISTS (
        SELECT 1 FROM Viagem AS vi
            INNER JOIN Filial AS f ON f.Id = vi.IdFilialOrigem
            INNER JOIN Cidade AS c ON c.Id = f.IdCidade
        WHERE vi.IdVeiculo = v.Id AND c.UF = 'MG'
    );
```

---

## 19. DATEPART e Filtros de Período

```sql
-- Agrupar por mês e ano
SELECT YEAR(DataSaida)  AS Ano,
       MONTH(DataSaida) AS Mes,
       COUNT(*)         AS TotalViagens
    FROM Viagem
    GROUP BY YEAR(DataSaida), MONTH(DataSaida)
    ORDER BY Ano, Mes;

-- Filtrar hora par
WHERE DATEPART(HOUR, DataLogon) % 2 = 0

-- Diferença em horas entre duas datas
DATEDIFF(HOUR, DataSaida, DataChegada)

-- Viagens ativas há mais de 5 dias
WHERE DataSaida <= DATEADD(DAY, -5, GETDATE())
    AND DataChegada IS NULL
```

---

## 20. Cálculo Dinâmico de Frete com CASE

Quando o valor depende de regra de negócio por tipo:

```sql
SELECT CodigoCarga,
       CASE TipoCarga
           WHEN 'Padrao'   THEN Peso * 1.5
           WHEN 'Fragil'   THEN Peso * 2.0
           WHEN 'Perigosa' THEN Peso * 3.0
           ELSE                 Peso * 1.5
       END AS ValorFrete
    FROM Carga;
```

Para usar o valor calculado em um filtro, coloque em subquery (não pode referenciar alias do SELECT no WHERE):
```sql
SELECT * FROM (
    SELECT CodigoCarga,
           CASE TipoCarga
               WHEN 'Padrao'   THEN Peso * 1.5
               WHEN 'Fragil'   THEN Peso * 2.0
               WHEN 'Perigosa' THEN Peso * 3.0
           END AS ValorFrete
        FROM Carga
) AS sub
WHERE sub.ValorFrete > 300;
```

---

---

# EXERCÍCIOS — Refaça sem consultar o gabarito

Cada exercício indica a seção do material que ele cobre.

---

## BLOCO 1 — DECLARE e Sargability (Seções 1 e 2)

### EX-01
Declare uma variável `@hoje` do tipo `DATE` com o valor de hoje.
Usando essa variável, retorne todos os logons de hoje de forma sargable (sem aplicar função na coluna).
Retorne: `Id`, `IdUsuario`, `DataLogon`, `Sucesso`.

### EX-02
Declare uma variável `@tresAtras` com a data de 3 dias atrás.
Liste todos os usuários que logaram nesse dia, contando quantos logons cada um fez.
Retorne: `IdUsuario`, `TotalLogons`. Ordene do maior para o menor.

---

## BLOCO 2 — Subquery no WHERE (Seção 3a)

### EX-03
Retorne `IdUsuario`, `NomeUsuario`, `IdOpcao`, `NomeOpcao` do usuário que mais logou hoje.
Técnica: resolva o usuário campeão com subquery escalar no `WHERE`.

### EX-04
Liste todos os usuários cujo total histórico de logons está acima da média geral de logons por usuário.
Retorne: `Nome`, `TotalLogons`.
Técnica: subquery escalar no `WHERE` calculando `AVG`.

### EX-05
Liste os usuários que nunca tiveram nenhum logon com `Sucesso = 1`.
Técnica: `NOT IN` com subquery. Depois refaça com `NOT EXISTS`.

---

## BLOCO 3 — Subquery no FROM e no SELECT (Seções 3b e 3c)

### EX-06
Retorne `IdUsuario`, `NomeUsuario`, `IdOpcao`, `NomeOpcao` do usuário que mais logou hoje.
Técnica: resolva o usuário campeão com subquery no `FROM` (derived table). Não use CTE nem subquery no WHERE.

### EX-07
Retorne o nome de cada usuário, o total de logons dele e o total geral de logons da base lado a lado.
Retorne: `NomeUsuario`, `TotalDoUsuario`, `TotalGeral`.
Técnica: subquery escalar no `SELECT` para o total geral.

### EX-08
Liste as opções com quantidade de usos acima da média de uso por opção.
Retorne: `IdOpcao`, `NomeOpcao`, `TotalUsos`.
Técnica: subquery no `FROM` calculando os totais, depois filtre com `WHERE` comparando à média via subquery no `WHERE`.

---

## BLOCO 4 — Subquery no HAVING (Seção 3d)

### EX-09
Liste os usuários que têm mais logons do que a média de logons por usuário.
Técnica: `GROUP BY` + `HAVING COUNT(*) > (subquery com AVG)`.

### EX-10
Liste as opções cujo total de uso é maior que a média de uso de todas as opções.
Retorne: `IdOpcao`, `NomeOpcao`, `TotalUsos`.
Técnica: `HAVING COUNT(*) > (subquery)`.

---

## BLOCO 5 — CTE (Seção 4)

### EX-11
Retorne `IdUsuario`, `NomeUsuario`, `IdOpcao`, `NomeOpcao` do usuário que mais logou hoje.
Técnica: CTE chamada `Chato` isolando o campeão. Sem subquery no WHERE ou FROM.

### EX-12
Usuário que mais logou há 3 dias com suas opções.
Técnica: CTE com filtro de data para 3 dias atrás.

### EX-13 — CTE encadeada
Monte um relatório de frequência completo em um único statement usando três CTEs encadeadas:
- `Periodo` → total de dias no banco
- `AtividadePorUsuario` → dias distintos ativos por usuário
- `Frequencia` → cruza os dois e calcula o percentual

Retorne: `NomeUsuario`, `DiasAtivo`, `TotalDias`, `FrequenciaPct`.

### EX-14 — CTE + INSERT
Copie todos os logons de hoje e insira-os com data -3 dias usando CTE como fonte.

### EX-15 — CTE para remapear IDs + INSERT
Após o EX-14, insira as `OpcaoAcionada` vinculadas aos logons backdatados.
Use CTE que faz JOIN entre o logon de hoje (fonte das opções) e o logon backdatado (destino), ligando pelo mesmo `IdUsuario`.

### EX-16 — CTE + UPDATE
Avance +3 dias em `Logon.DataLogon` do segundo colocado histórico.
Técnica: CTE com `DENSE_RANK()` + UPDATE via JOIN.

### EX-17 — CTE + DELETE
Delete de `OpcaoAcionada` todos os registros vinculados a logons com `Sucesso = 0`.
Técnica: CTE que seleciona os IDs alvo + `DELETE FROM CTE`.

---

## BLOCO 6 — INSERT (Seção 5)

### EX-18 — INSERT com OUTPUT
Insira um logon para cada usuário na data `2026-06-10` com `Sucesso = 1`.
Capture os IDs gerados em uma `@TabelaVariavel`.
Em seguida, insira em `OpcaoAcionada` as 5 opções mais acionadas para cada logon inserido, usando `CROSS JOIN`.

### EX-19 — Gerador de linhas sem WHILE
Limpe `OpcaoAcionada` e `Logon`.
Insira 1000 logons: 100 por dia por 10 dias, `IdUsuario` e `Sucesso` aleatórios, horário variado.
Técnica: `ROW_NUMBER()` sobre `sys.all_objects`.

---

## BLOCO 7 — UPDATE (Seção 6)

### EX-20
Avance +5 dias em `Logon.DataLogon` de todos os usuários que logaram somente em hora par.
Técnica: UPDATE com JOIN + `DATEPART(HOUR) % 2 = 0`.

### EX-21
Avance +3 dias em `OpcaoAcionada.InstanteLogon` do segundo colocado histórico.
Técnica: CTE com `DENSE_RANK()` + UPDATE com JOIN em `OpcaoAcionada` via `Logon`.

---

## BLOCO 8 — DELETE (Seção 7)

### EX-22
Delete todos os registros de `OpcaoAcionada` e depois `Logon` onde `Sucesso = 0`.
Faça na ordem correta respeitando a FK.
Confirme com `SELECT COUNT(*)` que não sobrou nada.

### EX-23
Refaça o DELETE de `OpcaoAcionada` do EX-22 usando CTE + DELETE em vez de JOIN direto.

---

## BLOCO 9 — Window Functions (Seção 8)

### EX-24
Ranqueie todos os usuários pelo total histórico de logons usando `DENSE_RANK()`.
Retorne: `IdUsuario`, `TotalLogons`, `Posicao`.
Mostre apenas os que estão na posição 1 e 2.

### EX-25
Explique com uma query a diferença entre `ROW_NUMBER()`, `RANK()` e `DENSE_RANK()`.
Monte um SELECT que mostre as três colunas lado a lado para os mesmos dados.
Retorne: `IdUsuario`, `TotalLogons`, `RowNum`, `Rank`, `DenseRank`.

---

## BLOCO 10 — CROSS JOIN (Seção 9)

### EX-26
Insira em `OpcaoAcionada` as 3 opções menos acionadas para cada logon do dia `2026-06-11`.
Técnica: `CROSS JOIN` entre os logons inseridos e um CTE `Bottom3`.

### EX-27
Calcule a frequência percentual de cada usuário usando CTE de valor escalar + `CROSS JOIN` para propagar o total de dias.
Não use subquery escalar no SELECT — apenas CROSS JOIN.

---

## BLOCO 11 — Funções de Data (Seção 10)

### EX-28
Retorne todos os logons agrupados por dia, mostrando quantos ocorreram em cada data.
Retorne: `Data`, `TotalLogons`. Ordene por data crescente.

### EX-29
Liste os usuários que logaram nos últimos 7 dias mas não logaram hoje.
Use `DATEADD` e `CAST` para montar os ranges de data de forma sargable.

### EX-30
Agrupe os logons por mês e ano, mostrando o total de logons em cada período.
Retorne: `Ano`, `Mes`, `TotalLogons`. Use `YEAR()` e `MONTH()`.

---

## BLOCO 12 — NULLIF e ISNULL (Seção 11)

### EX-31
Monte o relatório de frequência do EX-13, mas proteja a divisão com `NULLIF` para o caso de `TotalDias = 0`.

### EX-32
Liste todos os usuários mostrando o nome e uma coluna `Status` que exibe `'Sem logon'` se o usuário não tiver nenhum logon, ou a data do último logon caso contrário.
Técnica: `LEFT JOIN` + `ISNULL` ou `CASE WHEN ... IS NULL`.

---

## BLOCO 13 — LEFT JOIN vs INNER JOIN (Seção 12)

### EX-33
Liste todas as opções do cadastro, incluindo as que nunca foram acionadas, com o total de usos de cada uma.
Retorne: `IdOpcao`, `NomeOpcao`, `TotalUsos` (zero para as nunca usadas).
Técnica: `LEFT JOIN`.

### EX-34
Liste todos os usuários, incluindo os que nunca logaram.
Para os que nunca logaram, mostre `TotalLogons = 0`.
Técnica: `LEFT JOIN` + `ISNULL(COUNT(...), 0)` ou `COUNT` com LEFT JOIN.

---

## BLOCO 14 — CASE WHEN (Seção 13)

### EX-35
Liste todos os logons com uma coluna `Resultado` que exibe `'Sucesso'` ou `'Falha'` com base na coluna `Sucesso`.
Retorne: `Id`, `IdUsuario`, `DataLogon`, `Resultado`.

### EX-36
Classifique cada usuário por faixa de atividade com base no total de logons:
- Até 50 logons → `'Baixa'`
- 51 a 150 → `'Média'`
- Acima de 150 → `'Alta'`

Retorne: `NomeUsuario`, `TotalLogons`, `FaixaAtividade`.

### EX-37 — CASE dentro de SUM
Em um único SELECT, mostre para cada usuário:
- Total de logons com sucesso
- Total de logons com falha

Técnica: `SUM(CASE WHEN Sucesso = 1 THEN 1 ELSE 0 END)`. Sem subquery ou CTE.

---

## BLOCO 15 — HAVING (Seção 14)

### EX-38
Liste os usuários que têm mais de 80 logons no total.
Técnica: `GROUP BY` + `HAVING COUNT(*) > 80`.

### EX-39
Liste os usuários que têm mais logons com falha do que com sucesso.
Técnica: `GROUP BY` + `HAVING` comparando dois `SUM(CASE...)`.

### EX-40
Liste as opções que foram acionadas em mais de 5 dias distintos.
Técnica: `HAVING COUNT(DISTINCT CAST(InstanteLogon AS DATE)) > 5`.

---

## BLOCO 16 — IS NULL / IS NOT NULL (Seção 15)

### EX-41
Liste todas as opções que nunca foram acionadas.
Técnica: `LEFT JOIN` + `WHERE oa.Id IS NULL`.

### EX-42
Liste os logons onde `Sucesso` está nulo (não preenchido).
Mostre quantos existem com `COUNT(*)`.

---

## BLOCO 17 — LIKE (Seção 16)

### EX-43
Liste todos os usuários cujo nome começa com a letra `'A'`.
Técnica: `LIKE 'A%'`.

### EX-44
Liste todos os usuários cujo nome contém `'silva'` em qualquer posição (case insensitive no SQL Server padrão).
Técnica: `LIKE '%silva%'`.

---

## BLOCO 18 — GROUP BY e Agregações (Seção 17)

### EX-45
Agrupe os logons por usuário e por dia, mostrando quantos logons cada usuário fez em cada data.
Retorne: `IdUsuario`, `Data`, `TotalLogons`. Ordene por usuário e data.

### EX-46
Para cada usuário, mostre o total de logons, o maior intervalo entre logons consecutivos não é necessário — apenas: primeiro logon, último logon e total de dias entre eles.
Retorne: `IdUsuario`, `PrimeiroLogon`, `UltimoLogon`, `DiasDeAtividade`.

---

## BLOCO 19 — IN, NOT IN, EXISTS (Seção 18)

### EX-47
Liste os usuários que logaram pelo menos uma vez com `Sucesso = 1` usando `IN`.
Depois refaça com `EXISTS`.

### EX-48
Liste os usuários que NUNCA logaram com sucesso.
Técnica: `NOT IN` (com proteção de NULL) e depois refaça com `NOT EXISTS`.

---

## BLOCO 20 — DATEPART e Filtros de Período (Seção 19)

### EX-49
Liste os logons que ocorreram em hora par (0h, 2h, 4h...).
Técnica: `DATEPART(HOUR, DataLogon) % 2 = 0`.

### EX-50
Agrupe os logons por mês e ano, mostrando o total em cada período.
Retorne: `Ano`, `Mes`, `TotalLogons`. Ordene cronologicamente.

### EX-51
Liste os usuários que logaram há mais de 5 dias e não logaram hoje.
Use `DATEADD` para construir os filtros de forma sargable.

---

## BLOCO 21 — Cálculo com CASE e Subquery no FROM (Seção 20)

### EX-52
Calcule um "peso de importância" para cada logon:
- `Sucesso = 1` → peso 2
- `Sucesso = 0` → peso 1

Some o peso total por usuário e retorne apenas usuários com peso total acima de 100.
Técnica: `SUM(CASE...)` + `HAVING`.

### EX-53
Monte uma query que retorne o nome do usuário e sua "pontuação" calculada como:
`(logons com sucesso * 2) - (logons com falha * 1)`
Filtre apenas usuários com pontuação positiva.
Técnica: subquery no FROM calculando os valores, filtro no WHERE externo.
