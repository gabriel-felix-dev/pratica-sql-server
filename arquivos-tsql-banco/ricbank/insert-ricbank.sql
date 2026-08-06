USE RicBank;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO

-- Sem GO entre BEGIN TRANSACTION e BEGIN TRY: GO separa batches, e a transacao
-- ficaria num batch e o TRY/CATCH em outro - o ROLLBACK nunca rodaria e a
-- transacao ficaria orfa segurando locks. Mesmo defeito B2 corrigido no DDL.
BEGIN TRANSACTION;

BEGIN TRY

    -- =========================================================================
    -- LIMPEZA - ordem inversa de dependencia (TRUNCATE nao serve: FKs bloqueiam)
    -- =========================================================================
    DELETE FROM [dbo].[TaxaFatura];
    DELETE FROM [dbo].[Parcela];
    DELETE FROM [dbo].[TaxaChequeEspecial];
    DELETE FROM [dbo].[ParcelaEmprestimo];
    DELETE FROM [dbo].[ParcelaConsorcio];
    DELETE FROM [dbo].[Lance];
    DELETE FROM [dbo].[Fatura];
    DELETE FROM [dbo].[ChequeEspecial];
    DELETE FROM [dbo].[Movimentacao];
    DELETE FROM [dbo].[LimiteDependente];
    DELETE FROM [dbo].[LimiteConta];
    DELETE FROM [dbo].[Investimento];
    DELETE FROM [dbo].[Emprestimo];
    DELETE FROM [dbo].[ContaDependente];
    DELETE FROM [dbo].[ContaChavePix];
    DELETE FROM [dbo].[Consorcio];
    DELETE FROM [dbo].[Cartao];
    DELETE FROM [dbo].[ContaPoupanca];
    DELETE FROM [dbo].[ContaCorrente];
    DELETE FROM [dbo].[Cliente];
    DELETE FROM [dbo].[Agencia];
    DELETE FROM [dbo].[TipoTaxaChequeEspecial];
    DELETE FROM [dbo].[TaxaRendimento];
    DELETE FROM [dbo].[StatusChequeEspecial];
    DELETE FROM [dbo].[TipoSituacaoInvestimento];
    DELETE FROM [dbo].[TipoPagamento];
    DELETE FROM [dbo].[TipoMovimentacao];
    DELETE FROM [dbo].[TipoLimite];
    DELETE FROM [dbo].[TipoInvestimento];
    DELETE FROM [dbo].[TipoEmprestimo];
    DELETE FROM [dbo].[TipoChavePix];
    DELETE FROM [dbo].[SituacaoEmprestimo];
    DELETE FROM [dbo].[SituacaoConta];
    DELETE FROM [dbo].[SituacaoConsorcio];
    DELETE FROM [dbo].[SituacaoCartao];
    DELETE FROM [dbo].[Saldo];
    DELETE FROM [dbo].[Taxa];
    DELETE FROM [dbo].[FormaDePagamentoEmprestimo];
    DELETE FROM [dbo].[Dependente];
    DELETE FROM [dbo].[Compra];

    -- =========================================================================
    -- NIVEL 0 - Lookups SEM IDENTITY (Id obrigatorio e explicito)
    -- =========================================================================

    INSERT INTO [dbo].[FormaDePagamentoEmprestimo] (Id, Nome) VALUES
        (1, 'Debito em Conta'),
        (2, 'Boleto Bancario'),
        (3, 'Consignado em Folha'),
        (4, 'PIX');

    INSERT INTO [dbo].[SituacaoConsorcio] (Id, Nome) VALUES
        (1, 'Em Andamento'),
        (2, 'Contemplado'),
        (3, 'Encerrado'),
        (4, 'Cancelado');

    INSERT INTO [dbo].[SituacaoConta] (Id, Nome) VALUES
        (1, 'Ativa'),
        (2, 'Inativa'),
        (3, 'Bloqueada'),
        (4, 'Encerrada');

    INSERT INTO [dbo].[SituacaoEmprestimo] (Id, Nome) VALUES
        (1, 'Em Analise'),
        (2, 'Aprovado'),
        (3, 'Quitado'),
        (4, 'Inadimplente'),
        (5, 'Recusado');

    INSERT INTO [dbo].[TipoChavePix] (Id, Nome) VALUES
        (1, 'CPF'),
        (2, 'CNPJ'),
        (3, 'E-mail'),
        (4, 'Telefone'),
        (5, 'Chave Aleatoria');

    INSERT INTO [dbo].[TipoEmprestimo] (Id, Nome) VALUES
        (1, 'Pessoal'),
        (2, 'Consignado'),
        (3, 'Financiamento Imobiliario'),
        (4, 'Financiamento Veicular');

    -- UQ_TipoLimite_Nome: nomes precisam ser distintos
    INSERT INTO [dbo].[TipoLimite] (Id, Nome) VALUES
        (1, 'Limite PIX Diurno'),
        (2, 'Limite PIX Noturno'),
        (3, 'Limite TED'),
        (4, 'Limite Saque'),
        (5, 'Limite Cartao de Credito');

    INSERT INTO [dbo].[TipoMovimentacao] (Id, Nome) VALUES
        (1, 'Deposito'),
        (2, 'Saque'),
        (3, 'Transferencia PIX'),
        (4, 'TED'),
        (5, 'Pagamento de Boleto'),
        (6, 'Estorno');


    INSERT INTO [dbo].[TipoTaxaChequeEspecial] (Id, Nome, Porcentagem, CriadoPor) VALUES
        (1, 'Juros Rotativo Mensal', 12.50, 'carga-inicial'),
        (2, 'IOF Diario', 0.01, 'carga-inicial'),
        (3, 'Multa por Atraso', 2.00, 'carga-inicial');

    -- =========================================================================
    -- NIVEL 0 - Lookups COM IDENTITY (IDENTITY_INSERT para Ids deterministicos)
    -- =========================================================================

    SET IDENTITY_INSERT [dbo].[SituacaoCartao] ON;
    INSERT INTO [dbo].[SituacaoCartao] (Id, Nome) VALUES
        (1, 'Ativo'),
        (2, 'Bloqueado'),
        (3, 'Cancelado'),
        (4, 'Aguardando Desbloqueio');
    SET IDENTITY_INSERT [dbo].[SituacaoCartao] OFF;

    SET IDENTITY_INSERT [dbo].[TipoInvestimento] ON;
    INSERT INTO [dbo].[TipoInvestimento] (Id, Nome) VALUES
        (1, 'CDB'),
        (2, 'Tesouro Direto'),
        (3, 'LCI'),
        (4, 'Fundo Multimercado');
    SET IDENTITY_INSERT [dbo].[TipoInvestimento] OFF;

    SET IDENTITY_INSERT [dbo].[TipoSituacaoInvestimento] ON;
    INSERT INTO [dbo].[TipoSituacaoInvestimento] (Id, Nome) VALUES
        (1, 'Ativo'),
        (2, 'Resgatado'),
        (3, 'Vencido');
    SET IDENTITY_INSERT [dbo].[TipoSituacaoInvestimento] OFF;

    -- UQ_TipoPagamento_Nome: nomes precisam ser distintos
    SET IDENTITY_INSERT [dbo].[TipoPagamento] ON;
    INSERT INTO [dbo].[TipoPagamento] (Id, Nome) VALUES
        (1, 'Boleto'),
        (2, 'Debito Automatico'),
        (3, 'PIX'),
        (4, 'Transferencia');
    SET IDENTITY_INSERT [dbo].[TipoPagamento] OFF;

    SET IDENTITY_INSERT [dbo].[StatusChequeEspecial] ON;
    INSERT INTO [dbo].[StatusChequeEspecial] (Id, Nome) VALUES
        (1, 'Contratado'),
        (2, 'Em Uso'),
        (3, 'Suspenso'),
        (4, 'Cancelado');
    SET IDENTITY_INSERT [dbo].[StatusChequeEspecial] OFF;

    SET IDENTITY_INSERT [dbo].[TaxaRendimento] ON;
    INSERT INTO [dbo].[TaxaRendimento] (Id, Valor, CriadoPor) VALUES
        (1, 0.50, 'carga-inicial'),
        (2, 0.65, 'carga-inicial'),
        (3, 0.72, 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[TaxaRendimento] OFF;

    SET IDENTITY_INSERT [dbo].[Taxa] ON;
    INSERT INTO [dbo].[Taxa] (Id, NomeTaxa, Porcentagem, CriadoPor) VALUES
        (1, 'Juros Rotativo', 14.90, 'carga-inicial'),
        (2, 'Multa por Atraso', 2.00, 'carga-inicial'),
        (3, 'IOF', 0.38, 'carga-inicial'),
        (4, 'Anuidade Diluida', 1.25, 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[Taxa] OFF;

    -- =========================================================================
    -- NIVEL 0 - Entidades independentes
    -- =========================================================================

    -- Um Saldo por conta - nunca compartilhado.
    -- Id 4 cobre saldo negativo (conta usando cheque especial).
    SET IDENTITY_INSERT [dbo].[Saldo] ON;
    INSERT INTO [dbo].[Saldo] (Id, SaldoInicial, Credito, Debito) VALUES
        (1, 5000.00,  12500.00, 8300.50),   -- ContaCorrente 1
        (2, 1200.00,  3400.00,  2900.75),   -- ContaCorrente 2
        (3, 0.00,     780.00,   1250.00),   -- ContaCorrente 3 (negativa)
        (4, 15000.00, 42000.00, 38750.20),  -- ContaCorrente 4
        (5, 2000.00,  500.00,   0.00),      -- ContaPoupanca 1
        (6, 800.00,   1600.00,  300.00);    -- ContaPoupanca 2
    SET IDENTITY_INSERT [dbo].[Saldo] OFF;

    -- NULO #1: Compra.Descricao
    --   Ids 1, 3, 5 -> COM descricao
    --   Ids 2, 4     -> SEM descricao => NULL
    -- QuantidadeParcelas = 1 significa compra a vista.
    SET IDENTITY_INSERT [dbo].[Compra] ON;
    INSERT INTO [dbo].[Compra] (Id, QuantidadeParcelas, EstabelecimentoDestino, Descricao, CriadoPor) VALUES
        (1, 3,  'MAGAZINE LUIZA',        'Geladeira Brastemp Frost Free', 'carga-inicial'),
        (2, 1,  'POSTO IPIRANGA 4021',   NULL, 'carga-inicial'),
        (3, 10, 'FAST SHOP SP',          'Notebook Dell Inspiron 15', 'carga-inicial'),
        (4, 1,  'PADARIA SAO JORGE',     NULL, 'carga-inicial'),
        (5, 6,  'DECATHLON MORUMBI',     'Bicicleta aro 29 + capacete', 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[Compra] OFF;

    -- CPF CHAR(11): 11 digitos exatos, sem pontos ou traco. UQ_Dependente_CPF.
    -- Situacao BIT: 1 = ativo, 0 = inativo.
    SET IDENTITY_INSERT [dbo].[Dependente] ON;
    INSERT INTO [dbo].[Dependente] (Id, CPF, Nome, Situacao, CriadoPor) VALUES
        (1, '52998224725', 'Marina Alves Ribeiro',  1, 'carga-inicial'),
        (2, '11144477735', 'Tiago Alves Ribeiro',   1, 'carga-inicial'),
        (3, '39053344705', 'Helena Costa Martins',  0, 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[Dependente] OFF;

    -- =========================================================================
    -- NIVEL 1 - Agencia, Cliente
    -- =========================================================================

    -- UQ_Agencia_Codigo. Ativo BIT: agencia 3 desativada.
    -- NULO #2: Agencia.Complemento
    --   Ids 1, 2 -> COM complemento (sala comercial)
    --   Id 3     -> SEM complemento (predio proprio) => NULL
    -- Cep CHAR(8) e Uf CHAR(2): sem mascara, tamanho exato.
    SET IDENTITY_INSERT [dbo].[Agencia] ON;
    INSERT INTO [dbo].[Agencia] (Id, Codigo, Nome, TelefoneFixo, Ativo, Logradouro, Numero, Complemento, Bairro, Cidade, Uf, Cep, CriadoPor) VALUES
        (1, '0001',   'Agencia Paulista', '1140028922', 1, 'Avenida Paulista',    '1578', 'Conjunto 121', 'Bela Vista', 'Sao Paulo',      'SP', '01310200', 'carga-inicial'),
        (2, '0002',   'Agencia Savassi',  '3133445566', 1, 'Avenida Afonso Pena', '900',  'Sala 1204', 'Centro',     'Belo Horizonte', 'MG', '30130002', 'carga-inicial'),
        (3, '0003-9', 'Agencia Curitiba', NULL,         0, 'Rua XV de Novembro',  '1300', NULL,        'Centro',     'Curitiba',       'PR', '80060000', 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[Agencia] OFF;

    -- UQ_Cliente_Documento e UQ_Cliente_Email.
    -- Documento VARCHAR(14) aceita CPF (11) e CNPJ (14) - cliente 4 e PJ.
    -- NULO #3: Cliente.Complemento
    --   Ids 1, 4 -> COM complemento (apartamento/sala)
    --   Ids 2, 3 -> SEM complemento (casa) => NULL
    -- Cliente 1 mora no mesmo endereco da Agencia 1; apos o achatamento sao
    -- copias independentes - alterar um NAO altera o outro.
    SET IDENTITY_INSERT [dbo].[Cliente] ON;
    INSERT INTO [dbo].[Cliente] (Id, Documento, NomeCompleto, TelefoneMovel, TelefoneFixo, DataNascimento, Email, Logradouro, Numero, Complemento, Bairro, Cidade, Uf, Cep, CriadoPor) VALUES
        (1, '52998224725',    'Carlos Eduardo Ribeiro',      '11987654321', '1133445566', '1985-03-12', 'carlos.ribeiro@email.com',      'Avenida Paulista',        '1578', 'Apto 121', 'Bela Vista',  'Sao Paulo',      'SP', '01310200', 'carga-inicial'),
        (2, '39053344705',    'Ana Paula Souza Lima',        '21996385274', NULL,         '1992-11-27', 'ana.lima@email.com',            'Rua das Laranjeiras',     '245',  NULL,       'Laranjeiras', 'Rio de Janeiro', 'RJ', '22240003', 'carga-inicial'),
        (3, '11144477735',    'Roberto Nunes Machado',       '51981234567', NULL,         '1978-06-05', 'roberto.machado@email.com',     'Rua Padre Chagas',        '78',   NULL,       'Moinhos',     'Porto Alegre',   'RS', '90570080', 'carga-inicial'),
        (4, '19131243000197', 'Tech Solucoes Digitais LTDA', NULL,          '1140028922', '2015-01-20', 'financeiro@techsolucoes.com.br', 'Setor Comercial Sul Q 2', '15',   'Bloco B',  'Asa Sul',     'Brasilia',       'DF', '70302000', 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[Cliente] OFF;


    -- =========================================================================
    -- NIVEL 2 - Contas
    -- =========================================================================

    -- UQ_ContaCorrente_Numero. Conta 4 = Encerrada (SituacaoConta 4),
    -- exercitando estado terminal. Cada conta com seu proprio IdSaldo.
    SET IDENTITY_INSERT [dbo].[ContaCorrente] ON;
    INSERT INTO [dbo].[ContaCorrente] (Id, IdCliente, IdAgencia, IdSituacaoConta, IdSaldo, Numero, DataCriacao, CriadoPor) VALUES
        (1, 1, 1, 1, 1, '00012345-6', '2020-05-14T09:30:00', 'carga-inicial'),
        (2, 2, 1, 1, 2, '00023456-7', '2021-08-03T14:15:00', 'carga-inicial'),
        (3, 3, 2, 3, 3, '00034567-8', '2019-02-28T10:00:00', 'carga-inicial'),  -- Bloqueada
        (4, 4, 2, 4, 4, '00045678-9', '2018-11-11T16:45:00', 'carga-inicial');  -- Encerrada
    SET IDENTITY_INSERT [dbo].[ContaCorrente] OFF;

    SET IDENTITY_INSERT [dbo].[ContaPoupanca] ON;
    INSERT INTO [dbo].[ContaPoupanca] (Id, IdSituacaoConta, IdTaxaRendimento, IdSaldo, IdCliente, IdAgencia, Codigo, DataCriacao, DiaRendimento, CriadoPor) VALUES
        (1, 1, 1, 5, 1, 1, 'POUP-00012345-6', '2020-05-14T09:35:00', 14, 'carga-inicial'),
        (2, 2, 2, 6, 2, 1, 'POUP-00023456-7', '2021-09-01T11:20:00', 1, 'carga-inicial');  -- Inativa
    SET IDENTITY_INSERT [dbo].[ContaPoupanca] OFF;


    -- =========================================================================
    -- NIVEL 3 - Produtos vinculados a conta corrente
    -- =========================================================================

    -- NULO #4: Cartao.DiaFechamento
    --   Cartoes de credito (1, 2, 4) -> COM dia de fechamento
    --   Cartao de debito (3)         -> SEM fechamento => NULL
    -- CK_Cartao_MesValidade (1-12) e CK_Cartao_AnoValidade (2020-2100) respeitados.
    SET IDENTITY_INSERT [dbo].[Cartao] ON;
    INSERT INTO [dbo].[Cartao] (Id, IdContaCorrente, IdSituacaoCartao, NumeroMascarado, MesValidade, AnoValidade, DiaVencimento, DiaFechamento, CriadoPor) VALUES
        (1, 1, 1, '4111 **** **** 1234', 12, 2028, 10, 3, 'carga-inicial'),
        (2, 1, 2, '5555 **** **** 4444',  1, 2027, 15, 8, 'carga-inicial'),     -- Bloqueado
        (3, 2, 1, '4222 **** **** 7788',  6, 2029, 20, NULL, 'carga-inicial'),  -- Debito: sem fechamento
        (4, 3, 3, '4333 **** **** 9012',  9, 2026,  5, 28, 'carga-inicial');    -- Cancelado
    SET IDENTITY_INSERT [dbo].[Cartao] OFF;

    -- NULO #5: Consorcio.DataContemplacao
    --   Id 1 -> Contemplado (situacao 2) => data PREENCHIDA
    --   Id 2 -> Em Andamento (situacao 1) => NULL  [correlacao respeitada]
    --   Id 3 -> Cancelado (situacao 4) => NULL, nunca foi contemplado
    -- UQ_Consorcio_NumeroDeContrato.
    SET IDENTITY_INSERT [dbo].[Consorcio] ON;
    INSERT INTO [dbo].[Consorcio] (Id, IdContaCorrente, IdSituacaoConsorcio, NumeroGrupo, NumeroDeContrato, DataInicio, DataContemplacao, ValorCredito, DataFim, CriadoPor) VALUES
        (1, 1, 2, 'GRP-1045', 'CTR-2022-000145', '2022-03-10', '2024-07-18', 120000.00, '2032-03-10', 'carga-inicial'),
        (2, 2, 1, 'GRP-1046', 'CTR-2023-000287', '2023-06-01', NULL,          80000.00, '2033-06-01', 'carga-inicial'),
        (3, 4, 4, 'GRP-1047', 'CTR-2021-000099', '2021-01-15', NULL,          60000.00, '2031-01-15', 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[Consorcio] OFF;

    -- UQ_ContaChavePix_ChavePix. Cobre os 5 tipos de chave.
    SET IDENTITY_INSERT [dbo].[ContaChavePix] ON;
    INSERT INTO [dbo].[ContaChavePix] (Id, IdContaCorrente, IdTipoChavePix, ChavePix, CriadoPor) VALUES
        (1, 1, 1, '52998224725', 'carga-inicial'),
        (2, 1, 3, 'carlos.ribeiro@email.com', 'carga-inicial'),
        (3, 2, 4, '+5521996385274', 'carga-inicial'),
        (4, 3, 5, '7f3d9a12-5c8b-4e21-9f44-2ab7c1e60d83', 'carga-inicial'),
        (5, 4, 2, '19131243000197', 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[ContaChavePix] OFF;

    INSERT INTO [dbo].[ContaDependente] (IdDependente, IdContaCorrente, CriadoPor) VALUES
        (1, 1, 'carga-inicial'),
        (2, 1, 'carga-inicial'),
        (3, 2, 'carga-inicial');

    -- UQ_Emprestimo_NumeroDeContrato. Cobre quitado, inadimplente e em analise.
    SET IDENTITY_INSERT [dbo].[Emprestimo] ON;
    INSERT INTO [dbo].[Emprestimo] (Id, IdContaCorrente, IdTipoEmprestimo, IdSituacaoEmprestimo, IdFormaDePagamento, NumeroDeContrato, Valor, TaxaJuros, QuantidadeParcelas, CriadoPor) VALUES
        (1, 1, 1, 2, 1, 'EMP-2024-0001', 15000.00, 2.45, 24, 'carga-inicial'),  -- Aprovado
        (2, 2, 2, 3, 3, 'EMP-2023-0087', 8000.00,  1.80, 12, 'carga-inicial'),  -- Quitado
        (3, 3, 4, 4, 2, 'EMP-2022-0154', 45000.00, 1.99, 48, 'carga-inicial'),  -- Inadimplente
        (4, 1, 3, 1, 1, 'EMP-2026-0210', 250000.00, 0.95, 360, 'carga-inicial'); -- Em Analise
    SET IDENTITY_INSERT [dbo].[Emprestimo] OFF;

    -- ValorInvestido e DECIMAL(11,2); ValorLiquido/Bruto sao DECIMAL(10,2).
    -- Investimento 3 = Resgatado, 4 = Vencido.
    SET IDENTITY_INSERT [dbo].[Investimento] ON;
    INSERT INTO [dbo].[Investimento] (Id, IdContaCorrente, IdTipoInvestimento, IdSituacaoInvestimento, ValorInvestido, ValorLiquido, ValorBruto, CriadoPor) VALUES
        (1, 1, 1, 1, 10000.00, 10850.40, 11200.00, 'carga-inicial'),
        (2, 1, 2, 1, 25000.00, 26300.75, 27100.00, 'carga-inicial'),
        (3, 2, 3, 2, 5000.00,  5420.00,  5420.00, 'carga-inicial'),
        (4, 4, 4, 3, 50000.00, 48200.10, 49500.00, 'carga-inicial');  -- Vencido com perda
    SET IDENTITY_INSERT [dbo].[Investimento] OFF;

    SET IDENTITY_INSERT [dbo].[LimiteConta] ON;
    INSERT INTO [dbo].[LimiteConta] (Id, IdContaCorrente, IdTipoLimite, Valor, CriadoPor) VALUES
        (1, 1, 1, 5000.00, 'carga-inicial'),
        (2, 1, 2, 1000.00, 'carga-inicial'),
        (3, 1, 5, 12000.00, 'carga-inicial'),
        (4, 2, 1, 2000.00, 'carga-inicial'),
        (5, 2, 4, 800.00, 'carga-inicial'),
        (6, 3, 3, 10000.00, 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[LimiteConta] OFF;

    -- ValorDisponivel = 0 no Id 3: limite totalmente consumido.
    SET IDENTITY_INSERT [dbo].[LimiteDependente] ON;
    INSERT INTO [dbo].[LimiteDependente] (Id, IdTipoLimite, IdDependente, IdContaCorrente, ValorMaximo, ValorDisponivel, CriadoPor) VALUES
        (1, 1, 1, 1, 1000.00, 750.00, 'carga-inicial'),
        (2, 5, 2, 1, 500.00,  120.50, 'carga-inicial'),
        (3, 4, 3, 2, 300.00,  0.00, 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[LimiteDependente] OFF;

    -- Cobre os 6 tipos de movimentacao, incluindo estorno.
    SET IDENTITY_INSERT [dbo].[Movimentacao] ON;
    INSERT INTO [dbo].[Movimentacao] (Id, IdContaCorrente, IdTipoMovimentacao, Valor, DataHora, Descricao, Destino, Origem) VALUES
        (1, 1, 1, 3500.00, '2026-07-05T08:12:00', 'Deposito de salario',            'Conta 00012345-6', 'Empregador'),
        (2, 1, 3, 250.00,  '2026-07-06T19:44:00', 'PIX para Ana Paula',             'ana.lima@email.com', 'Conta 00012345-6'),
        (3, 1, 5, 189.90,  '2026-07-10T11:03:00', 'Pagamento conta de energia',     'Concessionaria',   'Conta 00012345-6'),
        (4, 2, 2, 400.00,  '2026-07-12T15:27:00', 'Saque em caixa eletronico',      'Terminal 0451',    'Conta 00023456-7'),
        (5, 2, 4, 1200.00, '2026-07-15T10:05:00', 'TED para conta externa',         'Banco 341',        'Conta 00023456-7'),
        (6, 3, 6, 189.90,  '2026-07-18T09:00:00', 'Estorno de cobranca indevida',   'Conta 00034567-8', 'RicBank');
    SET IDENTITY_INSERT [dbo].[Movimentacao] OFF;

    -- UQ_ChequeEspecial_IdContaCorrente: no maximo UM por conta corrente.
    -- CK_ChequeEspecial_ValorUtilizado (>= 0): Id 2 usa o valor de fronteira 0.
    SET IDENTITY_INSERT [dbo].[ChequeEspecial] ON;
    INSERT INTO [dbo].[ChequeEspecial] (Id, IdContaCorrente, IdStatusChequeEspecial, ValorLimite, ValorUtilizado, InicioVigencia, FimVigencia, CriadoPor) VALUES
        (1, 1, 2, 3000.00, 1250.75, '2026-01-01', '2026-12-31', 'carga-inicial'),  -- Em Uso
        (2, 2, 1, 1500.00, 0.00,    '2026-01-01', '2026-12-31', 'carga-inicial'),  -- Contratado, nao usado
        (3, 3, 3, 5000.00, 470.00,  '2025-06-01', '2026-05-31', 'carga-inicial');  -- Suspenso
    -- ValorUtilizado do CE 3 = 470.00 espelha o saldo negativo da conta 3
    -- (Saldo 3: 0 + 780 - 1250 = -470). Consistencia mantida a mao: o schema
    -- nao liga Saldo a ChequeEspecial.ValorUtilizado.
    SET IDENTITY_INSERT [dbo].[ChequeEspecial] OFF;

    -- =========================================================================
    -- NIVEL 4 - Faturas e parcelas
    -- =========================================================================

    -- NULOS #5, #6, #7: Fatura.DataPagamento / ValorPago / ValorMinimo
    -- CORRELACAO: fatura em aberto => DataPagamento E ValorPago ambos NULL.
    --             fatura paga      => ambos preenchidos.
    -- Nunca gerar um NULL e outro preenchido - e legal no schema, mas e lixo.
    --   Id 1 -> paga integral   (todos preenchidos)
    --   Id 2 -> em aberto       (DataPagamento + ValorPago NULL, tem minimo)
    --   Id 3 -> paga so o minimo(ValorPago < Valor, todos preenchidos)
    --   Id 4 -> em aberto SEM minimo (os 3 nulos simultaneos - pior caso)
    --   Id 5 -> paga, sem minimo definido (ValorMinimo NULL isolado)
    SET IDENTITY_INSERT [dbo].[Fatura] ON;
    INSERT INTO [dbo].[Fatura] (Id, IdCartao, IdTipoPagamento, NumeroParcela, Valor, DataVencimento, DataPagamento, DataFechamento, ValorPago, ValorMinimo, CriadoPor) VALUES
        (1, 1, 2, 1, 1850.40, '2026-06-10', '2026-06-08', '2026-06-03T23:59:00', 1850.40, 277.56, 'carga-inicial'),
        (2, 1, 1, 2, 2340.90, '2026-07-10', NULL,         '2026-07-03T23:59:00', NULL,    351.14, 'carga-inicial'),
        (3, 2, 3, 1, 980.00,  '2026-05-15', '2026-05-15', '2026-05-08T23:59:00', 147.00,  147.00, 'carga-inicial'),
        (4, 3, 1, 1, 420.75,  '2026-08-20', NULL,         '2026-08-13T23:59:00', NULL,    NULL, 'carga-inicial'),
        (5, 4, 4, 1, 1200.00, '2026-04-05', '2026-04-04', '2026-03-28T23:59:00', 1200.00, NULL, 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[Fatura] OFF;

    -- Lances so existem para consorcios; o consorcio 1 foi contemplado via lance.
    SET IDENTITY_INSERT [dbo].[Lance] ON;
    INSERT INTO [dbo].[Lance] (Id, IdConsorcio, Valor, Data, CriadoPor) VALUES
        (1, 1, 25000.00, '2024-07-15', 'carga-inicial'),
        (2, 1, 30000.00, '2024-06-20', 'carga-inicial'),
        (3, 2, 12000.00, '2026-02-14', 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[Lance] OFF;

    -- NULOS #8, #9: ParcelaConsorcio.IdTipoPagamento / DataPagamento
    -- CORRELACAO: DataPagamento NULL <=> IdTipoPagamento NULL.
    --   Ids 1, 2, 4 -> pagas    (ambos preenchidos)
    --   Ids 3, 5    -> em aberto (ambos NULL)
    SET IDENTITY_INSERT [dbo].[ParcelaConsorcio] ON;
    INSERT INTO [dbo].[ParcelaConsorcio] (Id, IdConsorcio, IdTipoPagamento, NumeroParcela, Valor, DataVencimento, DataPagamento) VALUES
        (1, 1, 2,    1, 1000.00, '2022-04-10', '2022-04-09'),
        (2, 1, 2,    2, 1000.00, '2022-05-10', '2022-05-10'),
        (3, 1, NULL, 3, 1000.00, '2026-09-10', NULL),
        (4, 2, 1,    1, 666.67,  '2023-07-01', '2023-07-03'),
        (5, 2, NULL, 2, 666.67,  '2026-08-01', NULL);
    SET IDENTITY_INSERT [dbo].[ParcelaConsorcio] OFF;

    -- NULOS #10, #11: ParcelaEmprestimo.DataPagamento / IdTipoPagamento
    -- No DDL ORIGINAL as duas eram NOT NULL, tornando impossivel representar
    -- parcela de emprestimo em aberto. Corrigido em script-ricbank.corrigido.sql
    -- (G1), entao o cenario agora existe e e coberto aqui.
    -- CORRELACAO: DataPagamento NULL <=> IdTipoPagamento NULL (mesma regra da
    -- ParcelaConsorcio).
    --   Ids 1, 2, 3, 4, 5 -> pagas     (ambos preenchidos)
    --   Ids 6, 7          -> em aberto (ambos NULL) no emprestimo 3, que esta
    --                        Inadimplente - agora o status tem a parcela
    --                        vencida que o justifica.
    SET IDENTITY_INSERT [dbo].[ParcelaEmprestimo] ON;
    INSERT INTO [dbo].[ParcelaEmprestimo] (Id, IdEmprestimo, NumeroParcela, Valor, DataVencimento, DataPagamento, IdTipoPagamento) VALUES
        (1, 1, 1, 712.50, '2024-02-15', '2024-02-14', 2),
        (2, 1, 2, 712.50, '2024-03-15', '2024-03-15', 2),
        (3, 2, 1, 733.33, '2023-09-10', '2023-09-08', 3),
        (4, 2, 2, 733.33, '2023-10-10', '2023-10-11', 3),
        (5, 3, 1, 1180.20,'2022-08-05', '2022-08-05', 1),
        (6, 3, 2, 1180.20,'2022-09-05', NULL,         NULL),
        (7, 3, 3, 1180.20,'2022-10-05', NULL,         NULL);
    SET IDENTITY_INSERT [dbo].[ParcelaEmprestimo] OFF;

    -- =========================================================================
    -- NIVEL 5 - Tabelas folha
    -- =========================================================================

    -- IdFatura tem FK para Fatura desde a correcao G2 (FK_IdFatura_TaxaChequeEspecial).
    --
    -- O que a FK NAO cobre: nada obriga que a conta do IdChequeEspecial seja a
    -- mesma conta do IdFatura (via Cartao) - a FK garante que a fatura existe,
    -- nao que ela pertenca ao mesmo cliente. Aqui a coerencia foi mantida a mao:
    -- CE 1 e Fatura 1 sao da conta 1; CE 3 e Fatura 5 sao da conta 3.
    -- A query de verificacao no fim do arquivo confere.
    SET IDENTITY_INSERT [dbo].[TaxaChequeEspecial] ON;
    INSERT INTO [dbo].[TaxaChequeEspecial] (Id, IdChequeEspecial, IdTaxaChequeEspecial, IdFatura, DataReferencia, Porcentagem, CriadoPor) VALUES
        (1, 1, 1, 1, '2026-06-01T00:00:00', 12.50, 'carga-inicial'),
        (2, 1, 2, 1, '2026-06-01T00:00:00', 0.01, 'carga-inicial'),
        (3, 3, 1, 5, '2026-05-01T00:00:00', 12.50, 'carga-inicial'),
        (4, 3, 3, 5, '2026-05-16T00:00:00', 2.00, 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[TaxaChequeEspecial] OFF;

    -- Ligacao Compra <-> Fatura. Compra 1 (3x) parcelada entre faturas 1 e 2;
    -- compras a vista (2 e 4) entram com parcela unica.
    --
    -- NOTA: este fixture carrega um SUBCONJUNTO representativo das parcelas, nao
    -- a serie completa. Compra 1 declara 3 parcelas e tem 2 aqui; Compra 3
    -- declara 10 e tem 1; Compra 5 declara 6 e tem 1. Nada no schema liga
    -- Compra.QuantidadeParcelas a contagem de linhas em Parcela - se essa regra
    -- importa, falta uma constraint/trigger. Nao e bug do carregamento.
    SET IDENTITY_INSERT [dbo].[Parcela] ON;
    INSERT INTO [dbo].[Parcela] (Id, IdCompra, IdFatura, NumeroParcela, Valor, CriadoPor) VALUES
        (1, 1, 1, 1, 950.00, 'carga-inicial'),
        (2, 1, 2, 2, 950.00, 'carga-inicial'),
        (3, 2, 1, 1, 210.40, 'carga-inicial'),
        (4, 3, 2, 1, 480.00, 'carga-inicial'),
        (5, 4, 3, 1, 38.50, 'carga-inicial'),
        (6, 5, 4, 1, 420.75, 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[Parcela] OFF;

    SET IDENTITY_INSERT [dbo].[TaxaFatura] ON;
    INSERT INTO [dbo].[TaxaFatura] (Id, IdTaxa, IdFatura, Porcentagem, CriadoPor) VALUES
        (1, 1, 2, 14.90, 'carga-inicial'),
        (2, 2, 2, 2.00, 'carga-inicial'),
        (3, 3, 3, 0.38, 'carga-inicial'),
        (4, 4, 1, 1.25, 'carga-inicial'),
        (5, 1, 4, 14.90, 'carga-inicial');
    SET IDENTITY_INSERT [dbo].[TaxaFatura] OFF;

    COMMIT TRANSACTION;
    PRINT 'Carga de dados concluida com sucesso.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Erro na carga de dados. Rollback executado.';
    THROW;
END CATCH
GO

-- =============================================================================
-- VERIFICACAO - confere se os 12 cenarios de nulo foram gravados
-- =============================================================================
SELECT 'Compra.Descricao'              AS Coluna, SUM(CASE WHEN Descricao        IS NULL THEN 1 ELSE 0 END) AS Nulos, SUM(CASE WHEN Descricao        IS NOT NULL THEN 1 ELSE 0 END) AS Preenchidos FROM [dbo].[Compra]
UNION ALL SELECT 'Agencia.Complemento',         SUM(CASE WHEN Complemento        IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN Complemento        IS NOT NULL THEN 1 ELSE 0 END) FROM [dbo].[Agencia]
UNION ALL SELECT 'Cliente.Complemento',         SUM(CASE WHEN Complemento        IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN Complemento        IS NOT NULL THEN 1 ELSE 0 END) FROM [dbo].[Cliente]
UNION ALL SELECT 'Cartao.DiaFechamento',        SUM(CASE WHEN DiaFechamento      IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN DiaFechamento      IS NOT NULL THEN 1 ELSE 0 END) FROM [dbo].[Cartao]
UNION ALL SELECT 'Consorcio.DataContemplacao',  SUM(CASE WHEN DataContemplacao   IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN DataContemplacao   IS NOT NULL THEN 1 ELSE 0 END) FROM [dbo].[Consorcio]
UNION ALL SELECT 'Fatura.DataPagamento',        SUM(CASE WHEN DataPagamento      IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN DataPagamento      IS NOT NULL THEN 1 ELSE 0 END) FROM [dbo].[Fatura]
UNION ALL SELECT 'Fatura.ValorPago',            SUM(CASE WHEN ValorPago          IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN ValorPago          IS NOT NULL THEN 1 ELSE 0 END) FROM [dbo].[Fatura]
UNION ALL SELECT 'Fatura.ValorMinimo',          SUM(CASE WHEN ValorMinimo        IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN ValorMinimo        IS NOT NULL THEN 1 ELSE 0 END) FROM [dbo].[Fatura]
UNION ALL SELECT 'ParcelaCons.IdTipoPagamento', SUM(CASE WHEN IdTipoPagamento    IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN IdTipoPagamento    IS NOT NULL THEN 1 ELSE 0 END) FROM [dbo].[ParcelaConsorcio]
UNION ALL SELECT 'ParcelaCons.DataPagamento',   SUM(CASE WHEN DataPagamento      IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN DataPagamento      IS NOT NULL THEN 1 ELSE 0 END) FROM [dbo].[ParcelaConsorcio]
UNION ALL SELECT 'ParcelaEmpr.IdTipoPagamento', SUM(CASE WHEN IdTipoPagamento    IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN IdTipoPagamento    IS NOT NULL THEN 1 ELSE 0 END) FROM [dbo].[ParcelaEmprestimo]
UNION ALL SELECT 'ParcelaEmpr.DataPagamento',   SUM(CASE WHEN DataPagamento      IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN DataPagamento      IS NOT NULL THEN 1 ELSE 0 END) FROM [dbo].[ParcelaEmprestimo];
GO

-- Coerencia das correlacoes: as queries abaixo devem retornar ZERO linhas.
-- (T-SQL nao permite comparar dois predicados com <>; o XOR e escrito explicito.)
SELECT 'Fatura com DataPagamento/ValorPago inconsistentes' AS Violacao, Id
  FROM [dbo].[Fatura]
 WHERE (DataPagamento IS NULL     AND ValorPago IS NOT NULL)
    OR (DataPagamento IS NOT NULL AND ValorPago IS NULL);

SELECT 'ParcelaConsorcio com pagamento inconsistente' AS Violacao, Id
  FROM [dbo].[ParcelaConsorcio]
 WHERE (DataPagamento IS NULL     AND IdTipoPagamento IS NOT NULL)
    OR (DataPagamento IS NOT NULL AND IdTipoPagamento IS NULL);

SELECT 'ParcelaEmprestimo com pagamento inconsistente' AS Violacao, Id
  FROM [dbo].[ParcelaEmprestimo]
 WHERE (DataPagamento IS NULL     AND IdTipoPagamento IS NOT NULL)
    OR (DataPagamento IS NOT NULL AND IdTipoPagamento IS NULL);

SELECT 'Consorcio contemplado sem data (ou vice-versa)' AS Violacao, Id
  FROM [dbo].[Consorcio]
 WHERE (IdSituacaoConsorcio =  2 AND DataContemplacao IS NULL)
    OR (IdSituacaoConsorcio <> 2 AND DataContemplacao IS NOT NULL);

-- TaxaChequeEspecial nao pode cruzar contas. A FK G2 garante que a fatura
-- existe, mas nao que ela seja da mesma conta do cheque especial - isso
-- continua sendo responsabilidade do carregamento.
SELECT 'TaxaChequeEspecial cruzando contas' AS Violacao, tce.Id
  FROM [dbo].[TaxaChequeEspecial] tce
  JOIN [dbo].[ChequeEspecial] ce ON ce.Id  = tce.IdChequeEspecial
  JOIN [dbo].[Fatura]          f ON f.Id   = tce.IdFatura
  JOIN [dbo].[Cartao]          c ON c.Id   = f.IdCartao
 WHERE ce.IdContaCorrente <> c.IdContaCorrente;
GO
