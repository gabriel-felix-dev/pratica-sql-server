# Questões de Estudo — BancoRicardo

# DQL — Consultas (10)

## DQL-01
Liste o nome de todos os usuários que **nunca** registraram um logon bem-sucedido — incluindo os que jamais tentaram logar.

## DQL-02
Para cada mês, mostre quantos logons ocorreram. Como a base abrange vários anos, garanta que meses de anos diferentes **não** sejam somados juntos.

## DQL-03
Liste as opções que estão entre as **3 mais acionadas** do histórico. Se houver empate na 3ª posição, **todas** as empatadas devem aparecer (pode retornar mais de 3 linhas).

## DQL-04
Liste os usuários cujo total de logons é **estritamente maior** que a média de logons por usuário — e essa média deve considerar **também** os usuários que nunca logaram.

## DQL-05
Para cada usuário que já logou, mostre o total de logons dele e o **percentual** que representa sobre o total geral de logons. **Proibido** subquery escalar na lista de colunas.

## DQL-06
Liste **todas** as opções do cadastro com o total de vezes que cada uma foi acionada (zero para as nunca usadas). Ordene da menos para a mais acionada.

## DQL-07
Para **cada** usuário, exiba o nome e um status: `'Sem logon'` se nunca logou, ou a data do seu último logon. Inclua todos os usuários.

## DQL-08
Liste os usuários que registraram logons em **mais de um ano-calendário** distinto.


## DQL-09
Em um **único** SELECT, sem subconsultas, mostre para cada usuário quantos logons tiveram sucesso e quantos falharam. Inclua usuários sem nenhum logon (0 e 0).

## DQL-10
Liste os **5 usuários** com mais logons bem-sucedidos. Em caso de empate na 5ª posição, todos os empatados devem aparecer.


# INSERT (5)

## INSERT-01
Registre um logon bem-sucedido em `2026-06-10` para **cada usuário que ainda não possui nenhum logon**.

## INSERT-02
Para **cada logon de hoje bem-sucedido**, registre o acionamento das **5 opções mais acionadas** do histórico, no mesmo instante do logon.

## INSERT-03
Crie uma cópia retroativa de todos os logons de hoje, inserindo-os novamente com a data deslocada em **-7 dias**, preservando usuário e status.

## INSERT-04
Insira um logon bem-sucedido com data/hora atual para **cada usuário sem e-mail**; capture os Ids gerados em uma variável de tabela e registre para cada logon o acionamento da opção **'Dashboard'**.

## INSERT-05
Gere **30 logons** de teste para o usuário de **menor Id**: um por dia nos últimos 30 dias, todos bem-sucedidos, **sem usar laço (`WHILE`)**.

# UPDATE (5)

## UPDATE-01
Marque como falha (`Sucesso = 0`) todos os logons ocorridos em **horário par** (hora 0, 2, 4, …).

## UPDATE-02
Avance em **+3 dias** a `DataLogon` de todos os logons do **usuário que mais logou** no histórico.

## UPDATE-03
Para os usuários criados em **2024**, onde o e-mail for nulo, defina-o como `'sem-email-<Id>@empresa.com.br'`.

## UPDATE-04
Avance em **+2 dias** o `InstanteLogon` das opções acionadas que pertencem a **logons mal-sucedidos**.

## UPDATE-05
Para o(s) usuário(s) na **2ª posição** do ranking por total de logons, ajuste a `DataLogon` de todos os seus logons para exatamente **3 dias após hoje**, **preservando a hora original**.

# DELETE (5)

## DELETE-01
Remova os logons mal-sucedidos (`Sucesso = 0`), respeitando as dependências de chave estrangeira.

## DELETE-02
Apague todos os logons (e suas dependências) dos usuários que **nunca** tiveram um logon bem-sucedido.


## DELETE-03
**Usando uma CTE**, remova de `OpcaoAcionada` todos os registros vinculados a logons mal-sucedidos.

## DELETE-04
Remova **apenas** os logons de hoje, com suas dependências.

## DELETE-05
Mantenha na base apenas os logons dos **100 usuários com mais logons**; remova os logons (e dependências) de **todos os demais**.