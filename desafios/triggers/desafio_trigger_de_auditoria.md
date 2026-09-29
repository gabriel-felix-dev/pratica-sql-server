# Trigger de Auditoria em Reserva

Captura toda mudança de `Situacao` num histórico separado. É o único tópico do seu currículo (triggers) que ainda não apareceu em nenhuma dessas correntes, e ele ataca direto o ponto fraco que descobrimos: sem histórico, você não sabe quando ou por que uma reserva virou `CANCELADA` ou `CHECKOUT`, apenas conhece o estado atual.

## O que construir

* **Tabela de Histórico:** Crie uma tabela `ReservaHistorico` com as seguintes colunas:
  * `Id`
  * `IdReserva`
  * `SituacaoAnterior`
  * `SituacaoNova`
  * `DataAlteracao`
  * `UsuarioAlteracao` *(opcional, se você tiver contexto de sessão pra capturar)*.
* **Criação do Trigger:** Crie um trigger `AFTER UPDATE` na tabela `Reserva` que dispara **apenas** quando a coluna `Situacao` muda de fato (não em qualquer `UPDATE` da linha — é necessário checar `IF UPDATE(Situacao)` e comparar `inserted` com `deleted`).
* **Tratamento de Múltiplas Linhas:** O trigger precisa lidar com múltiplas linhas de uma vez. Lembre-se que um trigger em SQL Server roda uma vez por *statement* (instrução), não por linha. Se houver um `UPDATE` em massa (tipo um *job* noturno cancelando reservas vencidas), seu trigger tem que capturar todas as linhas afetadas via `JOIN` entre `inserted` e `deleted`, sem assumir que só uma reserva mudou.

## O que isso testa de verdade (além da sintaxe de trigger)

* **Comportamento Statement vs. Linha:** A diferença entre trigger por linha (que não existe nativamente no SQL Server) e por *statement*. É fácil escrever um trigger que só funciona para uma linha e quebra silenciosamente (ou pior, só captura uma linha) num `UPDATE` em lote.
* **Pseudo-tabelas:** O uso de `inserted` e `deleted` como as duas pseudo-tabelas que só existem dentro do contexto do trigger.
* **Prevenção de Loops Infinitos:** Evitar loop infinito caso o trigger em algum momento faça um `UPDATE` na própria tabela `Reserva` (não é o caso desta tarefa em específico, mas é o tipo de armadilha clássica de trigger).

## Teste de estresse

Depois de ter a estrutura base funcionando, realize um teste de estresse natural:

1. Dispare um `UPDATE` que afeta várias reservas ao mesmo tempo. 
   * *Exemplo:* `UPDATE Reserva SET Situacao = 'CHECKOUT' WHERE DataSaida < GETDATE() AND Situacao = 'CHECKIN'`
2. Consulte a tabela `ReservaHistorico` e confirme que o histórico registrou cada uma das alterações individualmente, e não apenas uma linha genérica.