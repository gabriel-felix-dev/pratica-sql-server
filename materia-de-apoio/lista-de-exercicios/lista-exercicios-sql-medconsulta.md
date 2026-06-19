# Lista de Exercícios — SQL Server (Banco MedConsulta)

> 140 exercícios práticos, todos baseados no schema e nos dados do banco `MedConsulta`. Gabarito em arquivo separado (`gabarito-exercicios-sql-medconsulta.md`).

**Status:** Pendente(1), Confirmada(2), Realizada(3), Cancelada(4)
**TipoAtendimento:** Presencial(1), Telemedicina(2), ProcedimentoComplexo(3)

---

## Stored Procedures (20)

1. Crie uma procedure que recebe `@IdPaciente INT` e retorna todas as colunas de `Consulta` para esse paciente, sem filtro de período.
2. Crie uma procedure que recebe `@IdMedico INT` e retorna a quantidade de consultas com status Realizada feitas por esse médico.
3. Crie uma procedure que recebe `@IdClinica TINYINT` e lista `Id`, `Nome` e `CRM` de todos os médicos dessa clínica.
4. Crie uma procedure que recebe `@DataInicio DATE` e `@DataFim DATE` e retorna o faturamento total (soma de `ValorBase`) das consultas Realizadas nesse período.
5. Crie uma procedure de cadastro de paciente que usa `RAISERROR` para impedir o cadastro se já existir um paciente com o mesmo `Documento`.
6. Crie uma procedure que recebe `@IdConsulta INT` e `@NovoStatus TINYINT`, valida que a consulta existe e atualiza `IdStatusConsulta`.
7. Crie uma procedure que recebe `@IdPaciente INT` e retorna, em uma linha, o `TipoPlano` do paciente e a quantidade de consultas Canceladas.
8. Crie uma procedure que recebe `@IdEspecialidade TINYINT = NULL` e lista médicos filtrando pela especialidade quando informada, ou todos quando NULL.
9. Crie uma procedure que recebe `@IdMedico INT`, `@Ano INT` e `@Mes INT` e retorna o faturamento desse médico no mês/ano informado.
10. Crie uma procedure que insere uma nova consulta, validando com `IF NOT EXISTS` se paciente e médico existem, usando `TRY/CATCH` e transação.
11. Crie uma procedure que recebe `@UF CHAR(2)` e retorna a quantidade de pacientes cujo endereço está nesse estado.
12. Crie uma procedure que recebe `@IdClinica TINYINT` e retorna os médicos dessa clínica ranqueados por faturamento total.
13. Crie uma procedure que recebe `@Codigo VARCHAR(50)` de uma consulta e retorna, em uma linha, nome do paciente, médico, clínica e especialidade.
14. Crie uma procedure que recebe `@DataLimite DATE`, cancela todas as Pendentes com `DataHora` anterior a essa data e retorna a quantidade afetada.
15. Crie uma procedure que recebe `@TipoPlano VARCHAR(20)` e retorna o valor médio das consultas Realizadas de pacientes desse plano.
16. Crie uma procedure que recebe `@IdPaciente INT` e devolve, via parâmetro `OUTPUT`, a contagem total de consultas desse paciente.
17. Crie uma procedure que lista todos os pacientes sem endereço cadastrado.
18. Crie uma procedure que recebe `@IdEstado TINYINT` e retorna a quantidade de clínicas localizadas nesse estado.
19. Crie uma procedure que recebe `@IdMedico INT` e `@Percentual DECIMAL(5,2)` e aplica o reajuste no `ValorBase` de todas as consultas Pendentes desse médico, dentro de uma transação.
20. Crie uma procedure que recebe um período e retorna, agrupado por `IdTipoAtendimento`, a quantidade de consultas e o faturamento total.

## Jobs (20)

1. Escreva o comando T-SQL que cancelaria consultas Pendentes com `DataHora` menor que a data atual.
2. Usando o comando anterior, escreva o script completo de um Job diário às 02:00 (job, step, schedule, attach, jobserver).
3. Escreva o step de um Job que marca como Cancelada consultas Confirmadas cuja `DataHora` já passou há mais de 1 dia (no-show).
4. Crie um Job semanal (segunda-feira, 06:00) cujo step grava em `RelatorioSemanal` o faturamento da semana anterior.
5. Escreva o step de um Job que copia para `ConsultaHistorico` as consultas Realizadas do mês anterior.
6. Crie um Job que roda a cada 6 horas reexecutando a procedure de faturamento por período e grava o resultado em log.
7. Escreva a consulta (em `msdb`) que lista todos os Jobs cadastrados com seus respectivos schedules.
8. Escreva o comando para desabilitar um Job chamado `Job_CancelarConsultasPendentesVencidas`.
9. Escreva o comando para excluir um Job chamado `Job_RelatorioSemanal`.
10. Crie um Job com dois steps: o primeiro cancela consultas vencidas; o segundo grava em log a quantidade de linhas afetadas.
11. Escreva o step de um Job que insere em uma tabela de alerta os médicos com mais de 15 consultas Confirmadas no mesmo dia.
12. Crie um Job mensal (dia 1, 00:30) que grava o faturamento de cada clínica do mês anterior.
13. Escreva o step de um Job que identifica consultas de Telemedicina sem `PlataformaTelemedicina` informada e grava em log de inconsistência.
14. Escreva a consulta em `sysjobhistory` que retorna apenas as execuções que falharam de um Job específico.
15. Crie um Job diário (23:55) que confirma automaticamente consultas Pendentes de pacientes com `TipoPlano = 'Ouro'`.
16. Escreva o step de um Job que identifica consultas duplicadas (mesmo paciente, médico e horário) e grava em log.
17. Escreva o comando para alterar o agendamento de um Job, de diário para apenas dias úteis.
18. Escreva o step de um Job que calcula a receita acumulada do mês corrente e grava o valor mais recente em uma tabela.
19. Crie um Job de manutenção que reconstrói os índices da tabela `Consulta`, agendado para domingo às 03:00.
20. Escreva o comando para consultar o status da última execução de todos os Jobs ativos do servidor.

## Functions (20)

1. Crie uma scalar function que recebe `@IdConsulta INT` e retorna `ValorBase` somado a todas as taxas não nulas.
2. Crie uma scalar function que recebe `@IdMedico INT` e retorna o nome da especialidade desse médico.
3. Crie uma scalar function que recebe `@IdPaciente INT` e retorna o total já gasto em consultas Realizadas.
4. Crie uma scalar function que recebe `@Documento VARCHAR(20)` e retorna `1` se o paciente existe e `0` caso contrário.
5. Crie uma inline table-valued function que recebe `@IdMedico INT` e retorna as consultas dele com nome do paciente.
6. Crie uma inline table-valued function que recebe `@TipoPlano VARCHAR(20)` e retorna os pacientes desse plano com a cidade do endereço.
7. Crie uma multi-statement table-valued function que recebe `@IdClinica TINYINT` e retorna, por médico, quantidade de consultas e faturamento total.
8. Crie uma scalar function que recebe `@IdConsulta INT` e retorna a `DataHora` formatada como `DD/MM/YYYY HH:MM` usando `CONVERT`.
9. Crie uma scalar function que recebe duas datas e retorna a quantidade de dias entre elas.
10. Crie uma inline table-valued function que recebe `@IdEstado TINYINT` e retorna as clínicas localizadas nesse estado.
11. Crie uma scalar function que recebe `@IdMedico INT` e retorna o ticket médio das consultas Realizadas desse médico.
12. Crie uma scalar function que recebe `@IdPaciente INT` e retorna o nome da clínica da consulta mais recente desse paciente.
13. Crie uma inline table-valued function que recebe um período e retorna as consultas Canceladas nesse intervalo.
14. Crie uma scalar function "pura" (sem acessar tabela) que recebe o valor base e as quatro taxas e retorna a soma.
15. Crie uma inline table-valued function que recebe `@IdPaciente INT` e retorna as 3 consultas mais recentes. Explique a limitação de `TOP` com variável dentro de uma iTVF.
16. Crie uma scalar function que recebe `@IdEspecialidade TINYINT` e retorna a quantidade de médicos distintos dessa especialidade.
17. Crie uma multi-statement table-valued function que recebe `@IdClinica TINYINT` e retorna os médicos com uma coluna calculada indicando se estão sobrecarregados (mais de 5 consultas Pendentes).
18. Crie uma scalar function que recebe `@Codigo VARCHAR(50)` de uma consulta e retorna o nome do paciente correspondente.
19. Crie uma inline table-valued function que recebe ano e mês e retorna o faturamento agrupado por `IdTipoAtendimento`.
20. Crie uma scalar function que recebe `@IdMedico INT` e retorna o percentual de consultas Canceladas em relação ao total de consultas desse médico.

## Triggers (20)

1. Crie um trigger `AFTER INSERT` em `Consulta` que grava em log o `Id` da consulta e a data/hora da inserção.
2. Crie um trigger `AFTER UPDATE` em `Consulta` que impede a alteração de `ValorBase` quando o status já é Realizada.
3. Crie um trigger `AFTER DELETE` em `Consulta` que grava as linhas excluídas em uma tabela de auditoria.
4. Crie um trigger `INSTEAD OF DELETE` em `Consulta` que, em vez de excluir, atualiza o status para Cancelada.
5. Crie um trigger `AFTER UPDATE` em `Paciente` que grava em log quando a coluna `TipoPlano` muda.
6. Crie um trigger `AFTER INSERT` em `Paciente` que usa `RAISERROR` se já existir paciente com o mesmo `Documento`.
7. Crie um trigger `AFTER UPDATE` em `Medico` que impede a troca de especialidade quando o médico tiver consultas Pendentes.
8. Crie um trigger `AFTER INSERT` em `Consulta` que bloqueia a inserção quando for Telemedicina e `PlataformaTelemedicina` estiver NULL.
9. Crie um trigger `AFTER UPDATE` em `Consulta` que, ao mudar o status para Realizada, grava o valor total em uma tabela de faturamento.
10. Crie um trigger de DDL (`ON DATABASE FOR DROP_TABLE`) que impede a exclusão de qualquer tabela do `MedConsulta`.
11. Crie um trigger `AFTER INSERT` em `Clinica` que insere automaticamente uma linha em uma tabela de resumo, zerando os contadores.
12. Crie um trigger `AFTER UPDATE` em `Consulta` que incrementa um contador de alterações de status a cada mudança.
13. Crie um trigger `AFTER INSERT, UPDATE` em `Consulta` que bloqueia `DataHora` anterior a 2020.
14. Crie um trigger `AFTER INSERT, UPDATE` em `Consulta` que bloqueia `DataHora` mais de 2 anos no futuro.
15. Crie um trigger `AFTER DELETE` em `Medico` que impede a exclusão (com mensagem customizada) se o médico tiver consultas vinculadas.
16. Crie um trigger `AFTER UPDATE` em `Consulta` que, quando `IdMedico` muda, grava o histórico de reagendamento.
17. Crie um trigger `AFTER INSERT` em `Consulta` que atualiza um contador de total de consultas em uma tabela de resumo do médico.
18. Crie um trigger `AFTER UPDATE` em `Endereco` que grava em log quando o `CEP` é alterado.
19. Crie um trigger `AFTER INSERT` em `Consulta` que bloqueia a inserção se já existir outra consulta para o mesmo médico no mesmo horário exato.
20. Crie um trigger `AFTER UPDATE` em `Consulta` que impede que o status volte de Cancelada para qualquer outro valor.

## CTE (20)

1. Crie uma CTE que lista pacientes com `TipoPlano = 'Ouro'` e, no `SELECT` externo, junte com `Consulta`.
2. Crie uma CTE que calcula o faturamento total por médico e filtre, no `SELECT` externo, só os acima de R$ 5.000.
3. Crie uma CTE recursiva que gera os 12 meses de um ano e faça `LEFT JOIN` com `Consulta` para mostrar faturamento mês a mês, incluindo meses sem consulta.
4. Crie duas CTEs encadeadas: faturamento por clínica e média geral; compare cada clínica com a média no `SELECT` final.
5. Crie uma CTE que identifica pacientes sem nenhuma consulta com status Realizada.
6. Crie uma CTE recursiva que gera números de 1 a 20 e faça `JOIN` com as 20 consultas mais antigas para simular paginação.
7. Crie uma CTE que calcula, por `TipoPlano`, a quantidade de pacientes e o faturamento médio.
8. Crie uma CTE que combina (`UNION ALL`) consultas Realizadas e Canceladas de um médico, identificando a origem de cada linha.
9. Crie uma CTE que usa `ROW_NUMBER()` para identificar a primeira consulta de cada paciente.
10. Crie uma CTE que calcula o total de consultas por especialidade, ordenado da maior para a menor.
11. Crie uma CTE recursiva parametrizável que gera uma tabela calendário entre duas datas informadas.
12. Crie uma CTE que identifica consultas com taxas inconsistentes (ex: `TaxaAnestesia` preenchida fora de `ProcedimentoComplexo`).
13. Crie três CTEs encadeadas para montar um relatório de ranking de clínicas por faturamento.
14. Usando uma CTE, tente identificar médicos com mais de uma especialidade. Se não for possível com o modelo atual, explique por quê.
15. Crie uma CTE que retorna os pacientes cujo endereço está em uma cidade específica.
16. Crie uma CTE recursiva que soma o faturamento acumulado dia a dia dentro de um mês, sem usar window function.
17. Crie uma CTE que classifica cada consulta em uma faixa de valor (Baixo/Médio/Alto) e conte quantas existem em cada faixa.
18. Use uma CTE em conjunto com `DELETE` para remover as consultas com datas sentinela (`1900-01-01` ou `2050-12-31`).
19. Use uma CTE em conjunto com `UPDATE` para preencher `PlataformaTelemedicina` em consultas de Telemedicina que estão NULL.
20. Crie uma CTE que identifica a clínica com maior faturamento de cada estado.

## Window Functions (20)

1. Use `ROW_NUMBER()` particionado por paciente para retornar as 3 consultas mais recentes de cada um.
2. Use `RANK()` para ranquear todos os médicos pelo faturamento total.
3. Use `DENSE_RANK()` para ranquear os pacientes pelo total gasto.
4. Use `SUM() OVER (PARTITION BY IdPaciente)` para mostrar, ao lado de cada consulta, o total gasto pelo paciente.
5. Use `AVG() OVER (PARTITION BY IdMedico)` para mostrar a média de valor das consultas de cada médico.
6. Use `LAG()` para mostrar a data da consulta anterior de cada paciente.
7. Use `LEAD()` para mostrar a data da próxima consulta de cada paciente.
8. Use `NTILE(4)` para dividir os pacientes em quartis pelo total gasto.
9. Use `FIRST_VALUE()` para mostrar a primeira consulta registrada de cada médico.
10. Use `LAST_VALUE()` (com frame adequado) para mostrar a última consulta registrada de cada médico.
11. Use `SUM() OVER` com `ROWS BETWEEN` para calcular uma soma móvel das últimas 3 consultas.
12. Use `COUNT() OVER (PARTITION BY IdStatusConsulta)` para mostrar quantas consultas existem em cada status.
13. Use `PERCENT_RANK()` para posicionar cada consulta pelo `ValorBase`.
14. Use `CUME_DIST()` para o faturamento de cada médico.
15. Combine `RANK()` com `PARTITION BY` especialidade para ranquear médicos dentro da própria especialidade.
16. Use `ROW_NUMBER()` para identificar e retornar apenas consultas duplicadas (mesmo paciente, médico e horário).
17. Use `SUM() OVER (ORDER BY ... ROWS UNBOUNDED PRECEDING)` para a receita acumulada de uma clínica ao longo do tempo.
18. Use `MIN()`/`MAX() OVER` para mostrar a primeira e a última data de consulta de cada paciente.
19. Use `ROW_NUMBER()` para paginar os resultados de `Consulta`, retornando apenas a página 3 (registros 21 a 30).
20. Combine CTE + `RANK()` para retornar apenas o médico de maior faturamento de cada clínica.

## Indexes (20)

1. Crie um índice nonclustered simples em `Consulta.IdPaciente`.
2. Crie um índice composto em `Consulta (IdMedico, DataHora)`.
3. Crie um índice em `Medico.IdClinica`.
4. Crie um índice em `Paciente.IdEndereco` e explique como um índice se comporta em coluna que aceita NULL.
5. Crie um índice covering em `Consulta` para faturamento por status, incluindo `ValorBase` e `DataHora`.
6. Escreva a consulta para verificar se um índice está sendo utilizado.
7. Crie um índice filtrado apenas para consultas Pendentes.
8. Discuta e demonstre a viabilidade de um índice único em `Consulta.CodigoAutorizacao`, mesmo aceitando NULL.
9. Escreva os comandos com `SET STATISTICS IO ON` para comparar custo de leitura antes/depois de um índice.
10. Crie um índice em `Cidade.IdEstado`.
11. Escreva o comando para reconstruir (`REBUILD`) um índice fragmentado.
12. Escreva o comando para reorganizar (`REORGANIZE`) um índice e explique quando usar cada abordagem.
13. Crie um índice composto em `Consulta (IdStatusConsulta, IdTipoAtendimento)`.
14. Escreva a consulta que lista todos os índices existentes na tabela `Consulta`.
15. Explique por que não é necessário criar manualmente um índice para buscas por `Paciente.Documento`.
16. Explique por que não é necessário criar manualmente um índice para buscas por `Medico.CRM`.
17. Explique se já existe índice automático em `Consulta.Codigo` e, se não existisse, qual índice você criaria.
18. Escreva a consulta para identificar índices não utilizados, candidatos à remoção.
19. Crie um índice columnstore em `Consulta` e explique em que cenário esse tipo de índice faz sentido.
20. Crie um índice em `Endereco.IdCidade` e explique o impacto na cadeia de joins até `Estado`.
