USE RicBankTeste;
GO

/*
A TRG não precisa de exemplo na documentação

A TRG deve ter o minimo de comando possivel

Padrão com disparo de Erro com o RAISERROR 

Praticar a linha de IF p/ validacao de se existe a TRG/SP.

Não tem necessicade de 'SET NOCOUNT ON;' - É uma instrucao a mais para a TRG

Na documentacao da TRG, na parte de ALTERADO EM: XX/XX/XXXX - Colocar a descricao do que foi alterado

Qualquer comentário vale por mais simples que seja

Após a tabela alvo, colocar uma que poderá não ter valor nenhum para evitar que um "giro" desnecessario antes de um erro

Entender o que tem que ser feito no sistema

Não pode ter WITH(NOLOCK) em Saldo. 

Qualquer ALIAS pode usar bit de memoria. Usar somente quando necessario

SELECT  TOP 1 1 FROM [dbo].[...] -> E a forma mais rapida de execucao

SET XACT_ABORT ON; -> Verificar o que é 

-> criar uma job que sera agendada para rodar a meia e criar o saldo do dia seguinte
*/
