# Guia de Estudos: Módulo SQL Programação (Cenário WoodCraft)

Bem-vindo ao material de estudo do módulo **M5 · SQL Programação** (4 semanas).
Este guia foi preparado especialmente para estagiários que desejam aprofundar seus conhecimentos em programação de banco de dados SQL (especificamente T-SQL/SQL Server).

Como base prática para todo o nosso aprendizado, utilizaremos o projeto **WoodCraft (Fábrica de Móveis Customizados)**, um sistema fictício que gerencia pedidos de clientes, estoque de móveis prontos, matérias-primas e o fluxo de produção de uma fábrica de móveis sob medida.

---

## 🛠️ O Caso de Estudo: Sistema WoodCraft

O sistema WoodCraft é composto por tabelas que simulam um ambiente real de manufatura de móveis. A seguir, apresentamos o diagrama de banco de dados e as regras de negócio essenciais.

### Diagrama Entidade-Relacionamento (ERD)

```mermaid
erGuide
erDiagram
    Cliente ||--o{ Pedido : "faz"
    Produto ||--o{ ItemPedido : "contém"
    Pedido ||--o{ ItemPedido : "inclui"
    Produto ||--|| EstoqueProduto : "possui"
    MateriaPrima ||--|| EstoqueMateriaPrima : "possui"
    Produto ||--o{ Composicao : "usa"
    MateriaPrima ||--o{ Composicao : "composta_por"
    Produto ||--o{ EtapaFabricacao : "tem"
    ItemPedido ||--o{ HistoricoProducao : "gera"
    EtapaFabricacao ||--o{ HistoricoProducao : "executa"

    TipoMovimentacao ||--o{ MovimentacaoEstoqueProduto : "classifica"
    EstoqueProduto ||--o{ MovimentacaoEstoqueProduto : "movimenta"

    TipoMovimentacao ||--o{ MovimentacaoEstoqueMateriaPrima : "classifica"
    EstoqueMateriaPrima ||--o{ MovimentacaoEstoqueMateriaPrima : "movimenta"

    Pedido ||--o{ AuditoriaSaidaEstoqueProduto : "audita_saida"
    MovimentacaoEstoqueProduto ||--|| AuditoriaSaidaEstoqueProduto : "registra_saida"

    HistoricoProducao ||--o{ AuditoriaEntradaEstoqueProduto : "audita_entrada"
    MovimentacaoEstoqueProduto ||--|| AuditoriaEntradaEstoqueProduto : "registra_entrada"

    Pedido ||--o{ AuditoriaEstoqueMateriaPrima : "audita_mp"
    MovimentacaoEstoqueMateriaPrima ||--|| AuditoriaEstoqueMateriaPrima : "registra_mp"
```

### Regras de Negócio do Fluxo WoodCraft

1.  **Gestão de Pedidos:** Um cliente realiza um `Pedido` contendo vários itens (`ItemPedido`). Cada pedido possui uma `DataPromessa` (prazo acordado com o cliente) e uma `DataEntrega` (preenchida quando o pedido for despachado).
2.  **Estoque de Produtos:** A tabela `EstoqueProduto` controla a `QuantidadeFisica` de móveis finalizados disponíveis e a `QuantidadeMinima` de segurança.
3.  **Composição e Insumos:** Cada móvel (`Produto`) possui uma receita de fabricação descrita na tabela `Composicao`, indicando a quantidade necessária de cada `MateriaPrima` (ex: madeira, parafusos, verniz).
4.  **Fluxo de Produção:** Se um móvel pedido não tiver saldo suficiente no `EstoqueProduto`, ele entra na fila de `HistoricoProducao`. A fabricação passa por uma sequência ordenada de fases (`EtapaFabricacao`), cada uma com uma `DuracaoMinutos` estimada.
5.  **Movimentação e Auditoria:** Toda entrada e saída de estoque (de matérias-primas ou produtos finais) gera um log correspondente. As tabelas de `Auditoria` associam essas movimentações aos pedidos ou às ordens de produção correspondentes.

---

## 📅 Cronograma de Estudos (4 Semanas)

Abaixo está o conteúdo dividido Aulaa semana. Cada arquivo contém **teoria**, **estudo de código aplicado ao WoodCraft** e **desafios práticos** para você resolver:

1.  **[Aula1: T-SQL Essencial e Tabelas Temporárias](file:///c:/git/instrutores/modulo-sql-programacao/guia_estudos/semana1_tsql_essencial.md)**
    - Variáveis e Fluxo de Controle (`IF`, `WHILE`, `CASE`).
    - Tabelas Temporárias (`#Tabela`) vs Variáveis de Tabela (`@Tabela`).
    - _Estudo de Caso:_ Fila de processamento em loop e validação condicional.
2.  **[Aula2: CTEs e Window Functions](file:///c:/git/instrutores/modulo-sql-programacao/guia_estudos/semana2_ctes_window_functions.md)**
    - Common Table Expressions (CTEs) simples e recursivas.
    - Window Functions (`ROW_NUMBER()`, `DENSE_RANK()`, `LEAD()`, `LAG()`, `SUM() OVER()`).
    - _Estudo de Caso:_ Relatório de saldo acumulado histórico e classificação de pedidos prioritários.
3.  **[Aula3: Procedures, Funções e Views](file:///c:/git/instrutores/modulo-sql-programacao/guia_estudos/semana3_procedures_funcoes_views.md)**
    - Criação e parametrização de Stored Procedures (com leitura de JSON via `OPENJSON`).
    - Funções Escalares (UDFs) e Funções de Tabela (TVFs).
    - Simplificação de relatórios complexos com Views.
    - _Estudo de Caso:_ Funções de cálculo de insumos de móveis e procedures cadastrais parametrizadas.
4.  **[Aula4: Triggers, Jobs, Transações, Erros e Segurança](file:///c:/git/instrutores/modulo-sql-programacao/guia_estudos/semana4_triggers_jobs_transacoes.md)**
    - Triggers de validação set-based (tabelas `Inserted` e `Deleted`).
    - SQL Server Agent Jobs para automação em segundo plano.
    - Controle transacional (`BEGIN TRAN`, `COMMIT`, `ROLLBACK`), tratamento de erros (`TRY-CATCH`, `THROW`) e prevenção contra SQL Injection.
    - _Estudo de Caso:_ Trigger de consumo automático de insumos no início da fabricação.

---

## 🚀 Como Inicializar o Banco de Dados de Estudos?

1.  Certifique-se de ter um banco de dados SQL Server local ativo.
2.  Abra o arquivo **[criar_banco.sql](file:///c:/git/instrutores/modulo-sql-programacao/guia_estudos/database/criar_banco.sql)** no seu SQL Server Management Studio (SSMS) ou VS Code e execute-o por completo. Ele criará o banco de dados `woodcraft` e todas as tabelas necessárias.
3.  Abra o arquivo **[popular_banco.sql](file:///c:/git/instrutores/modulo-sql-programacao/guia_estudos/database/popular_banco.sql)** e execute-o. Ele populará o banco com clientes, insumos, móveis, etapas de fabricação e pedidos simulados.
4.  Inicie a leitura do material pela **[Aula1](file:///c:/git/instrutores/modulo-sql-programacao/guia_estudos/semana1_tsql_essencial.md)**!
