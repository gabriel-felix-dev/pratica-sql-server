# Módulo SQL Programação 🗄️

Bem-vindo ao repositório oficial do **Módulo de SQL e Programação de Banco de Dados**. 

Este material foi elaborado com o objetivo de capacitar desenvolvedores nas melhores práticas corporativas de manipulação de dados, criação de objetos programáveis e rotinas automatizadas no **Microsoft SQL Server**. Todo o conteúdo prático é baseado no cenário da **WoodCraft**, uma fábrica de móveis customizados, aproximando a teoria dos desafios reais do dia a dia.

## 📚 Estrutura do Curso

O conteúdo está organizado por semanas de estudo, com guias teóricos, exemplos de código e desafios práticos. 

1. **Aula 1: T-SQL Essencial e Tabelas Temporárias**
   - Declaração de Variáveis, `IF...ELSE`, `WHILE` e `CASE WHEN`.
   - Uso intensivo de Tabelas Temporárias (`#Tabela`).
   - Leitura e processamento de dados JSON (`OPENJSON`).

2. **Aula 2: CTEs e Window Functions**
   - Criação e uso de Common Table Expressions (CTEs).
   - Análise de dados não-agrupados com Funções de Janela (`ROW_NUMBER`, `RANK`, `DENSE_RANK`).
   - Navegação temporal com `LAG` e `LEAD` e soma acumulada (Running Totals).

3. **Aula 3: Stored Procedures, Functions e Views**
   - Encapsulamento de lógicas complexas de negócio em Procedures.
   - Construção de queries dinâmicas de forma segura (`sp_executesql`).
   - Criação de Funções Escalares e *Inline Table-Valued Functions (TVFs)*.

4. **Aula 4: Triggers, Jobs e Tratamento de Erros**
   - Gatilhos automáticos baseados em conjuntos (*set-based*) usando `Inserted` e `Deleted`.
   - Automação de processos com SQL Server Agent Jobs.
   - Padrões rigorosos de tratamento de erro com `@@ERROR` e `@@ROWCOUNT` (sem `TRY...CATCH`).

## 🛠️ Padrões de Código (Guidelines)

Este repositório segue regras **rígidas** de padronização corporativa (Programmability Standards). Alguns de nossos princípios fundamentais incluem:
- Indentação estritamente baseada em **TABs** (com hierarquia definida).
- Documentação em cabeçalho padronizado (Bloco `/* Documentacao ... */`).
- Uso obrigatório de `WITH(NOLOCK)` em consultas `SELECT`.
- Tratamento de erro nativo com `@@ERROR` e retorno de códigos numéricos (0 = Sucesso).
- Uso de `WHILE` com Tabela Temporária no lugar de Cursores.

## 📂 Organização do Repositório

- `/guia_estudos`: Contém as apostilas e desafios semanais em formato Markdown.
- `/exercicios`: Exercícios práticos e scripts de setup (WoodCraft DB).

## 🚀 Como Começar

1. Clone este repositório.
2. Acesse a pasta `/exercicios` (ou base de dados) e execute o script de criação do banco de dados `woodcraft`.
3. Siga a trilha de leitura a partir da pasta `/guia_estudos`.

---
*Desenvolvido para o Instituto Futuro.*
