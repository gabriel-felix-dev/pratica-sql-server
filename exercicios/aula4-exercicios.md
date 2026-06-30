# Aula 4: Triggers, Jobs, Transações, Tratamento de Erro e Segurança

Nesta lista de exercícios final, você colocará em prática a segurança, integridade dos dados e automação no SQL Server. Você trabalhará com controle de transações explícitas, tratamento de erros via TRY-CATCH, disparadores automáticos (Triggers) com lógica baseada em conjuntos (set-based) e procedures transacionais complexas.

---

## Exercício 1: Transação Segura com Deleção de Clientes

### Cenário:
Se tentarmos apagar um cliente que já possui pedidos vinculados na marcenaria, o banco de dados disparará um erro de restrição de chave estrangeira (Foreign Key). Você deve encapsular essa exclusão em uma transação segura com tratamento de erros.

### Requisitos:
1. Declare uma variável chamada @IdCliente do tipo INT e atribua o valor 1.
2. Escreva uma estrutura de tratamento de erro usando BEGIN TRY ... END TRY e BEGIN CATCH ... END CATCH.
3. No bloco **TRY**:
   - Inicie uma transação explícita com BEGIN TRANSACTION.
   - Execute um comando DELETE na tabela Cliente para o @IdCliente informado.
   - Finalize e grave a transação permanentemente com COMMIT TRANSACTION.
   - Exiba a mensagem: "Cliente deletado com sucesso!"
4. No bloco **CATCH**:
   - Verifique se existe alguma transação aberta (dica: use IF @@TRANCOUNT > 0). Se houver, realize o ROLLBACK TRANSACTION.
   - Capture o número do erro com ERROR_NUMBER() e a mensagem de erro do sistema com ERROR_MESSAGE().
   - Exiba uma mensagem amigável no console contendo as informações obtidas. Exemplo:
     "Erro ao tentar excluir cliente de ID [X]: [Mensagem do Erro] (Código do Erro: [Código]). A transação foi desfeita."

---

## Exercício 2: Trigger de Auditoria de Prazo de Entrega

### Cenário:
A diretoria da WoodCraft deseja auditar todas as alterações de prazo de entrega prometidas aos clientes para analisar possíveis multas e gargalos logísticos.

### Requisitos:
1. Crie a tabela física no banco chamada LogAuditoriaPrazoPedido com as seguintes colunas:
   - Id INT IDENTITY(1,1) PRIMARY KEY
   - IdPedido INT NOT NULL
   - DataPromessaAntiga DATE NOT NULL
   - DataPromessaNova DATE NOT NULL
   - DataAlteracao DATETIME NOT NULL DEFAULT GETDATE()
   - Usuario VARCHAR(100) NOT NULL DEFAULT SYSTEM_USER
2. Crie um Trigger chamado TRG_AuditarPrazoPedido na tabela Pedido para o evento AFTER UPDATE.
3. O trigger deve ser estritamente **set-based** (preparado para lidar com atualizações de múltiplas linhas em um único comando).
4. O trigger deve comparar a coluna DataPromessa da tabela virtual Inserted (novo valor) e Deleted (valor antigo) para as linhas correspondentes.
5. Se a data de promessa tiver sido alterada, o trigger deve inserir um registro na tabela LogAuditoriaPrazoPedido registrando o ID do pedido, o prazo antigo e o novo prazo.
6. Escreva um script de teste realizando uma alteração na data de promessa de um pedido e consulte a tabela de logs para provar o funcionamento.

---

## Exercício 3: Procedure Transacional de Encerramento de Etapa e Atualização de Estoque Físico

### Cenário:
Quando um marceneiro termina uma etapa de fabricação de um móvel, ele registra a conclusão. Se a etapa finalizada for a **última** etapa de fabricação daquele móvel, significa que o produto foi finalizado e o estoque físico do produto acabado deve ser atualizado de forma automática e integrada.

### Requisitos:
1. Crie a Stored Procedure chamada SP_FinalizarEtapaFabricacao contendo o parâmetro de entrada:
   - @IdHistoricoProducao INT
2. Implemente o código dentro de um bloco TRY-CATCH e execute todas as operações DML dentro de uma transação explícita (BEGIN TRAN / COMMIT).
3. **Validações (dentro do bloco TRY):**
   - Verifique se o registro informado em @IdHistoricoProducao existe na tabela HistoricoProducao. Se não existir, aborte a transação disparando um erro manual:
     `THROW 60001, 'Erro: Registro de histórico de produção não encontrado.', 16;`
   - Verifique se a etapa já está concluída (ou seja, se DataTermino na tabela HistoricoProducao não é NULL). Se já estiver encerrada, dispare o erro manual:
     `THROW 60002, 'Erro: Esta etapa de fabricação já foi encerrada anteriormente.', 16;`
4. **Atualização da Etapa:** Atualize a coluna DataTermino para a data/hora atual (GETDATE()) para o registro em HistoricoProducao.
5. **Verificação de Conclusão do Móvel:** 
   - Busque a qual produto (IdProduto) a etapa pertence e qual o NumeroEtapa desta etapa concluída.
   - Verifique se o número da etapa concluída é igual ao **maior** número de etapa cadastrado para aquele produto na tabela EtapaFabricacao (o que indica que o móvel está 100% finalizado).
6. **Ação de Finalização do Produto (se for a última etapa):**
   - Atualize a tabela EstoqueProduto adicionando a quantidade produzida (campo Quantidade da tabela HistoricoProducao) ao saldo físico disponível (QuantidadeFisica).
   - Insira uma movimentação de entrada na tabela MovimentacaoEstoqueProduto (IdTipoMovimentacao = 1 (Entrada), DataMovimentacao = GETDATE(), e a respectiva quantidade).
   - Capture o ID gerado da movimentação de produto (via SCOPE_IDENTITY()).
   - Insira o registro na tabela de auditoria AuditoriaEntradaEstoqueProduto relacionando o @IdHistoricoProducao e a movimentação gerada.
   - Exiba a mensagem formatada informando a finalização com sucesso e a quantidade adicionada ao estoque físico.
7. No bloco **CATCH**, desfaça qualquer transação pendente com ROLLBACK TRAN e relance o erro original com THROW.
8. Escreva um script completo de teste que demonstre o comportamento da procedure ao finalizar uma etapa intermediária e a etapa final de um móvel.
