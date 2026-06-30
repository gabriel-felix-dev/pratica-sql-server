-- =========================================================================
-- Script de Criação do Banco de Dados WoodCraft
-- Objetivo: DDL completo das tabelas da Fábrica de Móveis Customizados
-- =========================================================================

CREATE DATABASE woodcraft;
GO

USE woodcraft;
GO

-- 1. Tabela de Clientes
CREATE TABLE [dbo].[Cliente] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nome VARCHAR(100) NOT NULL
);
GO

-- 2. Tabela de Catálogo de Móveis (Produtos)
CREATE TABLE [dbo].[Produto] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nome VARCHAR(100) NOT NULL UNIQUE
);
GO

-- 3. Tabela de Pedidos
CREATE TABLE [dbo].[Pedido] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdCliente INT NOT NULL,
    DataPedido DATE NOT NULL,
    DataPromessa DATE NOT NULL,
    DataEntrega DATE NULL,
    CONSTRAINT fk_IdCliente_Pedido FOREIGN KEY (IdCliente) REFERENCES [dbo].[Cliente] (Id)
);
GO

-- 4. Tabela de Itens de Pedido
CREATE TABLE [dbo].[ItemPedido] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdPedido INT NOT NULL,
    IdProduto INT NOT NULL,
    Quantidade INT NOT NULL,
    CONSTRAINT fk_IdPedido_ItemPedido FOREIGN KEY (IdPedido) REFERENCES [dbo].[Pedido] (Id),
    CONSTRAINT fk_IdProduto_ItemPedido FOREIGN KEY (IdProduto) REFERENCES [dbo].[Produto] (Id)
);
GO

-- 5. Tabela de Estoque de Móveis Acabados
CREATE TABLE [dbo].[EstoqueProduto] (
    IdProduto INT PRIMARY KEY,
    QuantidadeFisica INT NOT NULL,
    QuantidadeMinima INT NOT NULL,
    CONSTRAINT fk_IdProduto_EstoqueProduto FOREIGN KEY (IdProduto) REFERENCES [dbo].[Produto] (Id)
);
GO

-- 6. Tabela de Cadastro de Matéria-Prima (Insumos)
CREATE TABLE [dbo].[MateriaPrima] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Nome VARCHAR(100) NOT NULL UNIQUE
);
GO

-- 7. Tabela de Estoque de Matéria-Prima
CREATE TABLE [dbo].[EstoqueMateriaPrima] (
    IdMateriaPrima INT PRIMARY KEY,
    QuantidadeFisica INT NOT NULL,
    QuantidadeMinima INT NOT NULL,
    CONSTRAINT fk_IdMateriaPrima_EstoqueMateriaPrima FOREIGN KEY (IdMateriaPrima) REFERENCES [dbo].[MateriaPrima] (Id)
);
GO

-- 8. Tabela de Composição (Receita do Móvel)
CREATE TABLE [dbo].[Composicao] (
    IdProduto INT NOT NULL,
    IdMateriaPrima INT NOT NULL,
    Quantidade INT NOT NULL,
    PRIMARY KEY (IdProduto, IdMateriaPrima),
    CONSTRAINT fk_IdProduto_Composicao FOREIGN KEY (IdProduto) REFERENCES [dbo].[Produto] (Id),
    CONSTRAINT fk_IdMateriaPrima_Composicao FOREIGN KEY (IdMateriaPrima) REFERENCES [dbo].[MateriaPrima] (Id)
);
GO

-- 9. Tabela de Etapas de Fabricação
CREATE TABLE [dbo].[EtapaFabricacao] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdProduto INT NOT NULL,
    Descricao VARCHAR(150) NOT NULL,
    DuracaoMinutos SMALLINT NOT NULL,
    NumeroEtapa TINYINT NOT NULL,
    CONSTRAINT fk_IdProduto_EtapaFabricacao FOREIGN KEY (IdProduto) REFERENCES [dbo].[Produto] (Id)
);
GO

-- 10. Tabela de Histórico/Acompanhamento de Produção
CREATE TABLE [dbo].[HistoricoProducao] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdEtapaFabricacao INT NOT NULL,
    IdItemPedido INT NOT NULL,
    DataInicio DATETIME NOT NULL,
    DataTermino DATETIME NULL,
    Quantidade INT NOT NULL,
    CONSTRAINT fk_IdEtapaFabricacao_HistoricoProducao FOREIGN KEY (IdEtapaFabricacao) REFERENCES [dbo].[EtapaFabricacao] (Id),
    CONSTRAINT fk_IdItemPedido_HistoricoProducao FOREIGN KEY (IdItemPedido) REFERENCES [dbo].[ItemPedido] (Id)
);
GO

-- 11. Tabela de Tipo de Movimentação (1 = Entrada, 2 = Saída)
CREATE TABLE [dbo].[TipoMovimentacao] (
    Id TINYINT PRIMARY KEY,
    Nome VARCHAR(50) NOT NULL UNIQUE
);
GO

-- 12. Tabela de Movimentação de Estoque de Produtos
CREATE TABLE [dbo].[MovimentacaoEstoqueProduto] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdTipoMovimentacao TINYINT NOT NULL,
    IdEstoqueProduto INT NOT NULL,
    DataMovimentacao DATETIME NOT NULL,
    Quantidade INT NOT NULL,
    CONSTRAINT fk_IdTipoMovimentacao_MovEstoqueProd FOREIGN KEY (IdTipoMovimentacao) REFERENCES [dbo].[TipoMovimentacao] (Id),
    CONSTRAINT fk_IdEstoqueProduto_MovEstoqueProd FOREIGN KEY (IdEstoqueProduto) REFERENCES [dbo].[EstoqueProduto] (IdProduto)
);
GO

-- 13. Tabela de Movimentação de Estoque de Matéria-Prima
CREATE TABLE [dbo].[MovimentacaoEstoqueMateriaPrima] (
    Id INT PRIMARY KEY IDENTITY(1,1),
    IdTipoMovimentacao TINYINT NOT NULL,
    IdEstoqueMateriaPrima INT NOT NULL,
    DataMovimentacao DATETIME NOT NULL,
    Quantidade INT NOT NULL,
    CONSTRAINT fk_IdTipoMovimentacao_MovEstoqueMP FOREIGN KEY (IdTipoMovimentacao) REFERENCES [dbo].[TipoMovimentacao] (Id),
    CONSTRAINT fk_IdEstoqueMateriaPrima_MovEstoqueMP FOREIGN KEY (IdEstoqueMateriaPrima) REFERENCES [dbo].[EstoqueMateriaPrima] (IdMateriaPrima)
);
GO

-- 14. Tabela de Auditoria de Saídas de Produtos (Ligada a Pedidos)
CREATE TABLE [dbo].[AuditoriaSaidaEstoqueProduto] (
    IdPedido INT NOT NULL,
    IdMovimentacaoEstoqueProduto INT NOT NULL UNIQUE,
    CONSTRAINT fk_IdPedido_AuditoriaSaida FOREIGN KEY (IdPedido) REFERENCES [dbo].[Pedido] (Id),
    CONSTRAINT fk_IdMovProd_AuditoriaSaida FOREIGN KEY (IdMovimentacaoEstoqueProduto) REFERENCES [dbo].[MovimentacaoEstoqueProduto] (Id)
);
GO

-- 15. Tabela de Auditoria de Entradas de Produtos (Ligada a Terminos de Produção)
CREATE TABLE [dbo].[AuditoriaEntradaEstoqueProduto] (
    IdHistoricoProducao INT NOT NULL,
    IdMovimentacaoEstoqueProduto INT NOT NULL UNIQUE,
    CONSTRAINT fk_IdHistProducao_AuditoriaEntrada FOREIGN KEY (IdHistoricoProducao) REFERENCES [dbo].[HistoricoProducao] (Id),
    CONSTRAINT fk_IdMovProd_AuditoriaEntrada FOREIGN KEY (IdMovimentacaoEstoqueProduto) REFERENCES [dbo].[MovimentacaoEstoqueProduto] (Id)
);
GO

-- 16. Tabela de Auditoria de Saídas de Matéria-Prima (Ligada a Pedidos/Produção)
CREATE TABLE [dbo].[AuditoriaEstoqueMateriaPrima] (
    IdPedido INT NOT NULL,
    IdMovimentacaoEstoqueMateriaPrima INT NOT NULL UNIQUE,
    CONSTRAINT fk_IdPedido_AuditoriaMP FOREIGN KEY (IdPedido) REFERENCES [dbo].[Pedido] (Id),
    CONSTRAINT fk_IdMovMP_AuditoriaMP FOREIGN KEY (IdMovimentacaoEstoqueMateriaPrima) REFERENCES [dbo].[MovimentacaoEstoqueMateriaPrima] (Id)
);
GO
