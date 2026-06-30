# Guia de Exercícios: Módulo SQL Programação (WoodCraft)

Bem-vindo ao repositório de exercícios práticos do módulo M5 - SQL Programação.

Este guia foi elaborado para consolidar o conhecimento prático adquirido ao longo das 4 semanas de estudo, utilizando como base o banco de dados woodcraft, cujos scripts de criação e população estão localizados na pasta guia_estudos/database. O foco é aplicar a lógica de programação SQL em problemas práticos do negócio, como gerenciamento de estoque, acompanhamento de produção, controle de faturamento e auditoria de movimentações.

---

## Estrutura dos Exercícios

Os exercícios estão divididos por tópicos semanais. Cada aula possui 3 exercícios organizados de forma incremental:

*   **[Aula 1: T-SQL Essencial e Tabelas Temporárias](file:///C:/git/instrutores/modulo-sql-programacao/exercicios/aula1-exercicios.md)**
    *   Variáveis, IF...ELSE, WHILE e CASE WHEN.
    *   Tabelas temporárias (#Tabela) e variáveis de tabela (@Tabela).
*   **[Aula 2: CTEs e Window Functions](file:///C:/git/instrutores/modulo-sql-programacao/exercicios/aula2-exercicios.md)**
    *   Common Table Expressions (CTEs) simples e recursivas.
    *   Window Functions: ROW_NUMBER(), LAG(), LEAD(), DENSE_RANK(), SUM() OVER().
*   **[Aula 3: Procedures, Funções e Views](file:///C:/git/instrutores/modulo-sql-programacao/exercicios/aula3-exercicios.md)**
    *   Views de relatórios consolidados.
    *   User-Defined Functions (UDFs) escalares e Table-Valued (TVF).
    *   Stored Procedures transacionais parametrizadas.
*   **[Aula 4: Triggers, Jobs, Transações, Erros e Segurança](file:///C:/git/instrutores/modulo-sql-programacao/exercicios/aula4-exercicios.md)**
    *   Triggers DML set-based (tabelas Inserted e Deleted).
    *   Transações (BEGIN TRAN, COMMIT, ROLLBACK) e blocos TRY-CATCH.
    *   Parametrização segura (prevenção contra SQL Injection).

---

## Como Resolver os Exercícios

1.  **Ambiente SQL:** Certifique-se de que o banco de dados woodcraft está criado e populado em seu servidor SQL local (utilize os scripts em [guia_estudos/database](file:///C:/git/instrutores/modulo-sql-programacao/guia_estudos/database)).
2.  **Arquivos de Resposta:** Crie scripts SQL ou execute os comandos diretamente no SQL Server Management Studio (SSMS) ou no Azure Data Studio para validar as consultas.
3.  **Gabarito:** Após tentar resolver cada exercício, você pode consultar as soluções sugeridas na pasta [gabarito/](file:///C:/git/instrutores/modulo-sql-programacao/exercicios/gabarito/) para comparar com a sua lógica e aprender abordagens alternativas de otimização de performance.

Atenção: Tente resolver todos os exercícios por conta própria antes de olhar o gabarito. O objetivo principal é desenvolver seu raciocínio lógico e habilidades de depuração no SQL Server.
