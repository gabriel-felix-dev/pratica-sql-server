# Gabarito — BancoRicardo

# DQL — Consultas (10)

## DQL-01
Liste o nome de todos os usuários que **nunca** registraram um logon bem-sucedido — incluindo os que jamais tentaram logar.

```sql
SELECT  us.Nome as NomeUsuario
    FROM Usuario AS us WITH (NOLOCK)
    WHERE NOT EXISTS (SELECT  1
                          FROM Logon AS lo WITH (NOLOCK)
                          WHERE lo.IdUsuario = us.Id
                              AND lo.Sucesso = 1
                     );
```

## DQL-02
Para cada mês, mostre quantos logons ocorreram. Como a base abrange vários anos, garanta que meses de anos diferentes **não** sejam somados juntos.

```sql
SELECT  YEAR(lo.DataLogon) as Ano,
        MONTH(lo.DataLogon) as Mes,
        COUNT(lo.Id) as TotalLogons
    FROM Logon AS lo WITH (NOLOCK)
    GROUP BY YEAR(lo.DataLogon), MONTH(lo.DataLogon)
    ORDER BY Ano, Mes;
```

## DQL-03
Liste as opções que estão entre as **3 mais acionadas** do histórico. Se houver empate na 3ª posição, **todas** as empatadas devem aparecer (pode retornar mais de 3 linhas).

```sql
SELECT  RankOpcoes.NomeOpcao as NomeOpcao,
        RankOpcoes.TotalUsos as TotalUsos
    FROM (SELECT  op.Nome as NomeOpcao,
                  COUNT(oa.Id) as TotalUsos,
                  DENSE_RANK() OVER (ORDER BY COUNT(oa.Id) DESC) as Posicao
              FROM Opcao AS op WITH (NOLOCK)
                  LEFT JOIN OpcaoAcionada AS oa WITH (NOLOCK)
                      ON oa.IdOpcao = op.Id
              GROUP BY op.Id, op.Nome
         ) AS RankOpcoes
    WHERE RankOpcoes.Posicao <= 3
    ORDER BY RankOpcoes.TotalUsos DESC;
```

## DQL-04
Liste os usuários cujo total de logons é **estritamente maior** que a média de logons por usuário — e essa média deve considerar **também** os usuários que nunca logaram.

```sql
SELECT  us.Nome as NomeUsuario,
        COUNT(lo.Id) as TotalLogons
    FROM Usuario AS us WITH (NOLOCK)
        LEFT JOIN Logon AS lo WITH (NOLOCK)
            ON lo.IdUsuario = us.Id
    GROUP BY us.Id, us.Nome
    HAVING COUNT(lo.Id) > (SELECT  COUNT(lg.Id) * 1.0 / COUNT(DISTINCT us2.Id)
                               FROM Usuario AS us2 WITH (NOLOCK)
                                   LEFT JOIN Logon AS lg WITH (NOLOCK)
                                       ON lg.IdUsuario = us2.Id
                          );
```

## DQL-05
Para cada usuário que já logou, mostre o total de logons dele e o **percentual** que representa sobre o total geral de logons. **Proibido** subquery escalar na lista de colunas.

```sql
SELECT  us.Nome as NomeUsuario,
        COUNT(lo.Id) as TotalLogons,
        COUNT(lo.Id) * 100.0 / Tot.TotalGeral as PercentualDoTotal
    FROM Usuario AS us WITH (NOLOCK)
        JOIN Logon AS lo WITH (NOLOCK)
            ON lo.IdUsuario = us.Id
        CROSS JOIN (SELECT  COUNT(lg.Id) as TotalGeral
                        FROM Logon AS lg WITH (NOLOCK)
                   ) AS Tot
    GROUP BY us.Id, us.Nome, Tot.TotalGeral
    ORDER BY TotalLogons DESC;
```

## DQL-06
Liste **todas** as opções do cadastro com o total de vezes que cada uma foi acionada (zero para as nunca usadas). Ordene da menos para a mais acionada.

```sql
SELECT  op.Nome as NomeOpcao,
        COUNT(oa.Id) as TotalUsos
    FROM Opcao AS op WITH (NOLOCK)
        LEFT JOIN OpcaoAcionada AS oa WITH (NOLOCK)
            ON oa.IdOpcao = op.Id
    GROUP BY op.Id, op.Nome
    ORDER BY TotalUsos ASC;
```

## DQL-07
Para **cada** usuário, exiba o nome e um status: `'Sem logon'` se nunca logou, ou a data do seu último logon. Inclua todos os usuários.

```sql
SELECT  us.Nome as NomeUsuario,
        CASE
            WHEN MAX(lo.DataLogon) IS NULL THEN 'Sem logon'
            ELSE CONVERT(VARCHAR(10), MAX(lo.DataLogon), 120)
        END as StatusUltimoLogon
    FROM Usuario AS us WITH (NOLOCK)
        LEFT JOIN Logon AS lo WITH (NOLOCK)
            ON lo.IdUsuario = us.Id
    GROUP BY us.Id, us.Nome;
```

## DQL-08
Liste os usuários que registraram logons em **mais de um ano-calendário** distinto.

```sql
SELECT  us.Nome as NomeUsuario,
        COUNT(DISTINCT YEAR(lo.DataLogon)) as AnosDistintos
    FROM Usuario AS us WITH (NOLOCK)
        JOIN Logon AS lo WITH (NOLOCK)
            ON lo.IdUsuario = us.Id
    GROUP BY us.Id, us.Nome
    HAVING COUNT(DISTINCT YEAR(lo.DataLogon)) > 1;
```

## DQL-09
Em um **único** SELECT, sem subconsultas, mostre para cada usuário quantos logons tiveram sucesso e quantos falharam. Inclua usuários sem nenhum logon (0 e 0).

```sql
SELECT  us.Nome as NomeUsuario,
        SUM(CASE WHEN lo.Sucesso = 1 THEN 1 ELSE 0 END) as TotalSucesso,
        SUM(CASE WHEN lo.Sucesso = 0 THEN 1 ELSE 0 END) as TotalFalha
    FROM Usuario AS us WITH (NOLOCK)
        LEFT JOIN Logon AS lo WITH (NOLOCK)
            ON lo.IdUsuario = us.Id
    GROUP BY us.Id, us.Nome;
```

## DQL-10
Liste os **5 usuários** com mais logons bem-sucedidos. Em caso de empate na 5ª posição, todos os empatados devem aparecer.

```sql
SELECT  TopUsuarios.NomeUsuario as NomeUsuario,
        TopUsuarios.TotalSucesso as TotalSucesso
    FROM (SELECT  us.Nome as NomeUsuario,
                  COUNT(lo.Id) as TotalSucesso,
                  DENSE_RANK() OVER (ORDER BY COUNT(lo.Id) DESC) as Posicao
              FROM Usuario AS us WITH (NOLOCK)
                  JOIN Logon AS lo WITH (NOLOCK)
                      ON lo.IdUsuario = us.Id
              WHERE lo.Sucesso = 1
              GROUP BY us.Id, us.Nome
         ) AS TopUsuarios
    WHERE TopUsuarios.Posicao <= 5
    ORDER BY TopUsuarios.TotalSucesso DESC;
```

---

# INSERT (5)

## INSERT-01
Registre um logon bem-sucedido em `2026-06-10` para **cada usuário que ainda não possui nenhum logon**.

```sql
DECLARE @DataLogon DATE = '2026-06-10';

INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
SELECT  us.Id,
        @DataLogon,
        1
    FROM Usuario AS us WITH (NOLOCK)
    WHERE NOT EXISTS (SELECT  1
                          FROM Logon AS lo WITH (NOLOCK)
                          WHERE lo.IdUsuario = us.Id
                     );
```

## INSERT-02
Para **cada logon de hoje bem-sucedido**, registre o acionamento das **5 opções mais acionadas** do histórico, no mesmo instante do logon.

```sql
DECLARE @hoje DATE = '2026-06-08';

INSERT INTO OpcaoAcionada (IdLogon, IdOpcao, InstanteLogon)
SELECT  lo.Id,
        Top5Opcoes.IdOpcao,
        lo.DataLogon
    FROM Logon AS lo WITH (NOLOCK)
        CROSS JOIN (SELECT  TOP 5 oa.IdOpcao as IdOpcao
                        FROM OpcaoAcionada AS oa WITH (NOLOCK)
                        GROUP BY oa.IdOpcao
                        ORDER BY COUNT(oa.Id) DESC, oa.IdOpcao ASC
                   ) AS Top5Opcoes
    WHERE lo.Sucesso = 1
        AND lo.DataLogon >= @hoje
        AND lo.DataLogon < DATEADD(DAY, 1, @hoje);
```

## INSERT-03
Crie uma cópia retroativa de todos os logons de hoje, inserindo-os novamente com a data deslocada em **-7 dias**, preservando usuário e status.

```sql
DECLARE @hoje DATE = '2026-06-08';

INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
SELECT  lo.IdUsuario,
        DATEADD(DAY, -7, lo.DataLogon),
        lo.Sucesso
    FROM Logon AS lo WITH (NOLOCK)
    WHERE lo.DataLogon >= @hoje
        AND lo.DataLogon < DATEADD(DAY, 1, @hoje);
```

## INSERT-04
Insira um logon bem-sucedido com data/hora atual para **cada usuário sem e-mail**; capture os Ids gerados em uma variável de tabela e registre para cada logon o acionamento da opção **'Dashboard'**.

```sql
DECLARE @hoje DATETIME = '2026-06-08';
DECLARE @LogonsCriados TABLE (IdLogon INT);

INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
OUTPUT inserted.Id INTO @LogonsCriados (IdLogon)
SELECT  us.Id,
        @hoje,
        1
    FROM Usuario AS us WITH (NOLOCK)
    WHERE us.Email IS NULL;

INSERT INTO OpcaoAcionada (IdLogon, IdOpcao, InstanteLogon)
SELECT  lc.IdLogon,
        OpcaoDashboard.IdOpcao,
        @hoje
    FROM @LogonsCriados AS lc
        CROSS JOIN (SELECT  op.Id as IdOpcao
                        FROM Opcao AS op WITH (NOLOCK)
                        WHERE op.Nome = 'Dashboard'
                   ) AS OpcaoDashboard;
```

## INSERT-05
Gere **30 logons** de teste para o usuário de **menor Id**: um por dia nos últimos 30 dias, todos bem-sucedidos, **sem usar laço (`WHILE`)**.

```sql
DECLARE @hoje DATE = '2026-06-08';

INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
SELECT  UsuarioMin.IdUsuario,
        DATEADD(DAY, -Numeros.N, @hoje),
        1
    FROM (SELECT  TOP (30) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 as N
              FROM sys.all_objects AS so WITH (NOLOCK)
         ) AS Numeros
        CROSS JOIN (SELECT  MIN(us.Id) as IdUsuario
                        FROM Usuario AS us WITH (NOLOCK)
                   ) AS UsuarioMin;
```

---

# UPDATE (5)

## UPDATE-01
Marque como falha (`Sucesso = 0`) todos os logons ocorridos em **horário par** (hora 0, 2, 4, …).

```sql
UPDATE lo
    SET lo.Sucesso = 0
    FROM Logon AS lo
    WHERE DATEPART(HOUR, lo.DataLogon) % 2 = 0;
```

## UPDATE-02
Avance em **+3 dias** a `DataLogon` de todos os logons do **usuário que mais logou** no histórico.

```sql
UPDATE lo
    SET lo.DataLogon = DATEADD(DAY, 3, lo.DataLogon)
    FROM Logon AS lo
        JOIN (SELECT  TOP 1 lg.IdUsuario as IdUsuario
                  FROM Logon AS lg WITH (NOLOCK)
                  GROUP BY lg.IdUsuario
                  ORDER BY COUNT(lg.Id) DESC
             ) AS Campeao
            ON Campeao.IdUsuario = lo.IdUsuario;
```

## UPDATE-03
Para os usuários criados em **2024**, onde o e-mail for nulo, defina-o como `'sem-email-<Id>@empresa.com.br'`.

```sql
UPDATE us
    SET us.Email = CONCAT('sem-email-', us.Id, '@empresa.com.br')
    FROM Usuario AS us
    WHERE us.Email IS NULL
        AND YEAR(us.DataCriacao) = 2024;
```

## UPDATE-04
Avance em **+2 dias** o `InstanteLogon` das opções acionadas que pertencem a **logons mal-sucedidos**.

```sql
UPDATE oa
    SET oa.InstanteLogon = DATEADD(DAY, 2, oa.InstanteLogon)
    FROM OpcaoAcionada AS oa
        JOIN Logon AS lo WITH (NOLOCK)
            ON lo.Id = oa.IdLogon
    WHERE lo.Sucesso = 0;
```

## UPDATE-05
Para o(s) usuário(s) na **2ª posição** do ranking por total de logons, ajuste a `DataLogon` de todos os seus logons para exatamente **3 dias após hoje**, **preservando a hora original**.

```sql
DECLARE @hoje DATE = '2026-06-08';

UPDATE lo
    SET lo.DataLogon = DATEADD(DAY, DATEDIFF(DAY, lo.DataLogon, DATEADD(DAY, 3, @hoje)), lo.DataLogon)
    FROM Logon AS lo
        JOIN (SELECT  RankUsuarios.IdUsuario as IdUsuario
                  FROM (SELECT  lg.IdUsuario as IdUsuario,
                                DENSE_RANK() OVER (ORDER BY COUNT(lg.Id) DESC) as Posicao
                            FROM Logon AS lg WITH (NOLOCK)
                            GROUP BY lg.IdUsuario
                       ) AS RankUsuarios
                  WHERE RankUsuarios.Posicao = 2
             ) AS SegundoLugar
            ON SegundoLugar.IdUsuario = lo.IdUsuario;
```

---

# DELETE (5)

## DELETE-01
Remova os logons mal-sucedidos (`Sucesso = 0`), respeitando as dependências de chave estrangeira.

```sql
DELETE oa
    FROM OpcaoAcionada AS oa
        JOIN Logon AS lo WITH (NOLOCK)
            ON lo.Id = oa.IdLogon
    WHERE lo.Sucesso = 0;

DELETE lo
    FROM Logon AS lo
    WHERE lo.Sucesso = 0;
```

## DELETE-02
Apague todos os logons (e suas dependências) dos usuários que **nunca** tiveram um logon bem-sucedido.

```sql
DELETE oa
    FROM OpcaoAcionada AS oa
        JOIN Logon AS lo WITH (NOLOCK)
            ON lo.Id = oa.IdLogon
    WHERE NOT EXISTS (SELECT  1
                          FROM Logon AS lg WITH (NOLOCK)
                          WHERE lg.IdUsuario = lo.IdUsuario
                              AND lg.Sucesso = 1
                     );

DELETE lo
    FROM Logon AS lo
    WHERE NOT EXISTS (SELECT  1
                          FROM Logon AS lg WITH (NOLOCK)
                          WHERE lg.IdUsuario = lo.IdUsuario
                              AND lg.Sucesso = 1
                     );
```

## DELETE-03
**Usando uma CTE**, remova de `OpcaoAcionada` todos os registros vinculados a logons mal-sucedidos.

```sql
WITH Inconsistentes AS (
    SELECT  oa.Id as Id
        FROM OpcaoAcionada AS oa
            JOIN Logon AS lo WITH (NOLOCK)
                ON lo.Id = oa.IdLogon
        WHERE lo.Sucesso = 0
)
DELETE FROM Inconsistentes;
```

## DELETE-04
Remova **apenas** os logons de hoje, com suas dependências.

```sql
DECLARE @hoje DATE = '2026-06-08';

DELETE oa
    FROM OpcaoAcionada AS oa
        JOIN Logon AS lo WITH (NOLOCK)
            ON lo.Id = oa.IdLogon
    WHERE lo.DataLogon >= @hoje
        AND lo.DataLogon < DATEADD(DAY, 1, @hoje);

DELETE lo
    FROM Logon AS lo
    WHERE lo.DataLogon >= @hoje
        AND lo.DataLogon < DATEADD(DAY, 1, @hoje);
```

## DELETE-05
Mantenha na base apenas os logons dos **100 usuários com mais logons**; remova os logons (e dependências) de **todos os demais**.

```sql
DELETE oa
    FROM OpcaoAcionada AS oa
        JOIN Logon AS lo WITH (NOLOCK)
            ON lo.Id = oa.IdLogon
    WHERE lo.IdUsuario NOT IN (SELECT  TopUsuarios.IdUsuario
                                   FROM (SELECT  TOP 100 lg.IdUsuario as IdUsuario
                                             FROM Logon AS lg WITH (NOLOCK)
                                             GROUP BY lg.IdUsuario
                                             ORDER BY COUNT(lg.Id) DESC
                                        ) AS TopUsuarios
                              );

DELETE lo
    FROM Logon AS lo
    WHERE lo.IdUsuario NOT IN (SELECT  TopUsuarios.IdUsuario
                                   FROM (SELECT  TOP 100 lg.IdUsuario as IdUsuario
                                             FROM Logon AS lg WITH (NOLOCK)
                                             GROUP BY lg.IdUsuario
                                             ORDER BY COUNT(lg.Id) DESC
                                        ) AS TopUsuarios
                              );
```
