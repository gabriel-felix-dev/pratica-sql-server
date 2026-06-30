# Aula 2: CTEs (Common Table Expressions) e Window Functions

Nesta lista de exercícios, você praticará a estruturação de consultas complexas e análises avançadas usando CTEs simples e funções de janela de classificação, valor e agregação acumulada.

---

## Exercício 1: Classificação de Etapas de Fabricação

### Cenário:
O setor de engenharia de processos da WoodCraft quer gerar um relatório que liste a sequência de etapas de fabricação de cada móvel e destaque apenas a etapa final de cada um deles.

### Requisitos:
1. Escreva uma consulta SQL que utilize uma CTE chamada EtapasPorProduto.
2. A CTE deve retornar as colunas: NomeProduto (da tabela Produto), Descricao (da etapa de fabricação) e NumeroEtapa (da tabela EtapaFabricacao).
3. Na CTE, crie uma coluna chamada SequenciaEtapaDecrescente utilizando a função de janela ROW_NUMBER(). Essa numeração deve ser sequencial por produto (PARTITION BY IdProduto) e ordenada pelo NumeroEtapa de forma decrescente (para que a última etapa de fabricação de cada produto sempre receba o número 1).
4. Na consulta principal (fora da CTE), filtre o resultado final para trazer apenas os registros onde SequenciaEtapaDecrescente = 1.
5. Ordene o resultado final pelo Nome do Produto de forma ascendente.

---

## Exercício 2: Tempo de Espera (Ociosidade) entre Etapas

### Cenário:
Para otimizar os gargalos na oficina, o PCP quer mapear o tempo que um lote de móveis de um pedido fica "parado" esperando o início de uma nova etapa após a conclusão da etapa anterior.

### Requisitos:
1. Escreva uma consulta SQL que acesse a tabela HistoricoProducao e traga dados das etapas de produção de cada item de pedido (IdItemPedido).
2. Utilize a função de janela LAG() para recuperar a DataTermino da etapa imediatamente anterior para o mesmo item de pedido (PARTITION BY IdItemPedido ordenado por DataInicio).
3. Calcule a diferença em minutos entre a DataInicio da etapa atual e a DataTermino da etapa anterior (use a função DATEDIFF(minute, ..., ...)). Nomeie essa coluna calculada como MinutosEmEspera.
4. A consulta deve retornar: IdItemPedido, IdEtapaFabricacao, a DataInicio da etapa atual, a DataTermino da etapa anterior e a quantidade de MinutosEmEspera.
5. Ordene o resultado final por IdItemPedido e DataInicio de forma ascendente.
*Nota: Para a primeira etapa de cada item, a coluna MinutosEmEspera e a data de término anterior serão exibidas como NULL, o que é o comportamento esperado.*

---

## Exercício 3: Fluxo Acumulado de Produção e Dependência

### Cenário:
O gerente de produção da WoodCraft solicitou um relatório analítico para apresentar aos novos marceneiros. Ele deseja ver a rota de fabricação de todos os móveis do catálogo, exibindo a duração de cada etapa, a duração total acumulada até o final daquela etapa e a etapa predecessora de cada uma.

### Requisitos:
1. Crie uma consulta SQL estruturada com uma CTE que liste todos os produtos e suas etapas de fabricação (use Joins entre Produto e EtapaFabricacao).
2. Utilizando funções de janela na CTE, gere as seguintes colunas:
   - **DuracaoAcumuladaMinutos:** Use a função agregada SUM(DuracaoMinutos) combinada com a cláusula OVER para calcular a soma acumulada de tempo de fabricação do produto à medida que as etapas avançam. A janela deve ser particionada por produto e ordenada pelo NumeroEtapa de forma ascendente.
   - **EtapaAnteriorDescricao:** Use a função LAG() na descrição da etapa para retornar o nome do processo anterior daquele produto.
3. No resultado final do seu SELECT (que consome a CTE), utilize a função ISNULL() para que, quando a EtapaAnteriorDescricao for nula (primeira etapa), exiba a string '[Início da Fabricação]'.
4. O resultado final deve conter as colunas: NomeProduto, NumeroEtapa, Descricao (etapa atual), DuracaoMinutos (etapa atual), DuracaoAcumuladaMinutos e EtapaAnteriorDescricao.
5. Ordene o relatório final por Nome do Produto e pelo NumeroEtapa de forma ascendente.
