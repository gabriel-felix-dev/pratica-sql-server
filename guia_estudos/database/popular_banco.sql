-- =========================================================================
-- Script de População do Banco de Dados WoodCraft
-- Objetivo: Inserir dados de teste para simulações e exercícios
-- =========================================================================

USE woodcraft;
GO

-- 1. Inserir Tipos de Movimentação
INSERT INTO [dbo].[TipoMovimentacao] (Id, Nome)
    VALUES  (1, 'Entrada'),
            (2, 'Saída');
GO

-- 2. Inserir Clientes
INSERT INTO [dbo].[Cliente] (Nome)
    VALUES  ('Mobiliária Central Ltda'),
            ('Design & Sofisticação Móveis'),
            ('Ana Julia Souza'),
            ('Carlos Alberto Silva'),
            ('Construtora Novo Lar');
GO

-- 3. Inserir Catálogo de Móveis (Produtos)
INSERT INTO [dbo].[Produto] (Nome)
    VALUES  ('Cadeira Office Ergonômica'),
            ('Mesa de Jantar Carvalho'),
            ('Armário de Cozinha Planejado');
GO

-- 4. Inserir Estoque Inicial de Móveis Acabados
INSERT INTO [dbo].[EstoqueProduto] (IdProduto, QuantidadeFisica, QuantidadeMinima)
    VALUES  (1, 15, 5),  -- Cadeira Office
            (2, 3, 2),   -- Mesa de Jantar
            (3, 1, 2);   -- Armário de Cozinha
GO

-- 5. Inserir Catálogo de Matéria-Prima
INSERT INTO [dbo].[MateriaPrima] (Nome)
    VALUES  ('Madeira de Carvalho (m²)'),          -- Id 1
            ('Parafuso Philips 4x16 (unidade)'),   -- Id 2
            ('Puxador de Alumínio (unidade)'),     -- Id 3
            ('Verniz Acrílico Secagem Rápida (L)'),-- Id 4
            ('Espuma de Alta Densidade (m²)'),      -- Id 5
            ('Tecido Poliéster Preto (m²)');       -- Id 6
GO

-- 6. Inserir Estoque Inicial de Matéria-Prima
INSERT INTO [dbo].[EstoqueMateriaPrima] (IdMateriaPrima, QuantidadeFisica, QuantidadeMinima)
    VALUES  (1, 120, 30),   -- Madeira de Carvalho
            (2, 1500, 300), -- Parafuso
            (3, 100, 20),   -- Puxador
            (4, 50, 15),    -- Verniz
            (5, 40, 10),    -- Espuma
            (6, 80, 20);    -- Tecido
GO

-- 7. Inserir Composição dos Móveis (Receitas)
-- Cadeira Office Ergonômica (Id 1) consome: 12 parafusos, 2 puxadores, 1 espuma, 2 tecido
INSERT INTO [dbo].[Composicao] (IdProduto, IdMateriaPrima, Quantidade)
    VALUES  (1, 2, 12),
            (1, 3, 2),
            (1, 5, 1),
            (1, 6, 2);

-- Mesa de Jantar Carvalho (Id 2) consome: 4 m² madeira, 24 parafusos, 2 litros verniz
INSERT INTO [dbo].[Composicao] (IdProduto, IdMateriaPrima, Quantidade)
    VALUES  (2, 1, 4),
            (2, 2, 24),
            (2, 4, 2);

-- Armário de Cozinha Planejado (Id 3) consome: 8 m² madeira, 48 parafusos, 10 puxadores, 3 litros verniz
INSERT INTO [dbo].[Composicao] (IdProduto, IdMateriaPrima, Quantidade)
    VALUES  (3, 1, 8),
            (3, 2, 48),
            (3, 3, 10),
            (3, 4, 3);
GO

-- 8. Inserir Etapas de Fabricação dos Móveis
-- Cadeira Office Ergonômica (Id 1)
INSERT INTO [dbo].[EtapaFabricacao] (IdProduto, Descricao, DuracaoMinutos, NumeroEtapa)
    VALUES  (1, 'Corte da Estrutura Metálica', 30, 1),
            (1, 'Estofamento do Assento/Encosto', 45, 2),
            (1, 'Montagem dos Rodízios e Pistão', 20, 3),
            (1, 'Controle de Qualidade e Limpeza', 15, 4);

-- Mesa de Jantar Carvalho (Id 2)
INSERT INTO [dbo].[EtapaFabricacao] (IdProduto, Descricao, DuracaoMinutos, NumeroEtapa)
    VALUES  (2, 'Corte e Desengrosso da Madeira', 60, 1),
            (2, 'Lixamento e Calibração', 45, 2),
            (2, 'Aplicação de Seladora e Verniz', 90, 3),
            (2, 'Montagem dos Pés e Travas', 30, 4);

-- Armário de Cozinha Planejado (Id 3)
INSERT INTO [dbo].[EtapaFabricacao] (IdProduto, Descricao, DuracaoMinutos, NumeroEtapa)
    VALUES  (3, 'Corte de Chapas (MDF/Carvalho)', 90, 1),
            (3, 'Furação e Bordas', 60, 2),
            (3, 'Montagem de Gavetas e Prateleiras', 45, 3),
            (3, 'Embalagem e Kit de Ferragens', 30, 4);
GO

-- 9. Inserir Pedidos Históricos e Ativos
-- Pedido 1: Mobiliária Central (Cliente 1), Feito há 10 dias, data promessa há 2 dias. Ainda não entregue (Atrasado).
INSERT INTO [dbo].[Pedido] (IdCliente, DataPedido, DataPromessa, DataEntrega)
    VALUES  (1, DATEADD(day, -10, GETDATE()), DATEADD(day, -2, GETDATE()), NULL);

-- Pedido 2: Design & Sofisticação (Cliente 2), Feito há 5 dias, data promessa em 5 dias. Ainda não entregue.
INSERT INTO [dbo].[Pedido] (IdCliente, DataPedido, DataPromessa, DataEntrega)
    VALUES  (2, DATEADD(day, -5, GETDATE()), DATEADD(day, 5, GETDATE()), NULL);

-- Pedido 3: Ana Julia (Cliente 3), Feito há 20 dias, data promessa há 10 dias. Entregue há 10 dias (Entregue no prazo).
INSERT INTO [dbo].[Pedido] (IdCliente, DataPedido, DataPromessa, DataEntrega)
    VALUES  (3, DATEADD(day, -20, GETDATE()), DATEADD(day, -10, GETDATE()), DATEADD(day, -10, GETDATE()));

-- Pedido 4: Carlos Alberto (Cliente 4), Feito hoje, data promessa em 12 dias. Ainda não entregue.
INSERT INTO [dbo].[Pedido] (IdCliente, DataPedido, DataPromessa, DataEntrega)
    VALUES  (4, GETDATE(), DATEADD(day, 12, GETDATE()), NULL);
            GO

-- 10. Inserir Itens dos Pedidos
-- Pedido 1 (Mobiliária Central): 8 Cadeiras e 2 Mesas
INSERT INTO [dbo].[ItemPedido] (IdPedido, IdProduto, Quantidade)
    VALUES  (1, 1, 8),
            (1, 2, 2);

-- Pedido 2 (Design & Sofisticação): 1 Mesa e 1 Armário
INSERT INTO [dbo].[ItemPedido] (IdPedido, IdProduto, Quantidade)
    VALUES  (2, 2, 1),
            (2, 3, 1);

-- Pedido 3 (Ana Julia): 4 Cadeiras
INSERT INTO [dbo].[ItemPedido] (IdPedido, IdProduto, Quantidade)
    VALUES  (3, 1, 4);

-- Pedido 4 (Carlos Alberto): 2 Armários
INSERT INTO [dbo].[ItemPedido] (IdPedido, IdProduto, Quantidade)
    VALUES  (4, 3, 2);
            GO

-- 11. Inserir Movimentações Históricas de Estoque de Produtos para simular a saída do Pedido 3
-- Entrada em Estoque das 4 Cadeiras fabricadas
INSERT INTO [dbo].[MovimentacaoEstoqueProduto] (IdTipoMovimentacao, IdEstoqueProduto, DataMovimentacao, Quantidade)
    VALUES  (1, 1, DATEADD(day, -11, GETDATE()), 4);

-- Saída do estoque para entrega do Pedido 3
INSERT INTO [dbo].[MovimentacaoEstoqueProduto] (IdTipoMovimentacao, IdEstoqueProduto, DataMovimentacao, Quantidade)
    VALUES  (2, 1, DATEADD(day, -10, GETDATE()), 4);

-- Vincular a saída na auditoria
INSERT INTO [dbo].[AuditoriaSaidaEstoqueProduto] (IdPedido, IdMovimentacaoEstoqueProduto)
    VALUES  (3, 2);
            GO
