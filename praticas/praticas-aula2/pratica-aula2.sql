USE WoodCraft;

-- CTEs


-- Window Functions

-- Prática com o banco LocadoraVeiculos

USE LocadoraVeiculos;

-- Todos campos e informação de tabela locação

SELECT  *
	FROM Locacao;

-- Soma de todos os valores da coluna ValorTotal (935874.35)

SELECT  SUM(ValorTotal) as ValorTotal 
	FROM Locacao; 

-- Window Function somente com o OVER():

-- Faz a soma de todos os valores da coluna ValorTotal e repete o valor em todas as linhas

SELECT  Id as IdLocacao,
		IdVeiculo,
		ValorTotal,
		SUM(ValorTotal) OVER() as ValorTotal 
	FROM Locacao;

-- Window Funciotion com o ORDER BY dentro do OVER ():

-- Organiza a coluna IdVeiculo de forma ascendente - Ou descendente - e, a cada IdVeiculo, a Window Function cria uma janela com o valor
-- da soma referente a um IdVeiculo especifíco e o resultado da soma dos valores referente àquele Id será apresentado em cada linha que
-- referente àquele Id. Em sequência, ocorrerá um efeito de bola de neve. O sistema somará ao resultado da soma anterior o valor 
-- referente ao próximo Id acumulando o resultado anterior a soma dos valores referente ao novo Id. Com isso, em todas as linhas do novo
-- Id, será apresentado o valor acumulado.

SELECT  Id as IdLocacao,
		IdVeiculo,
		ValorTotal,
		SUM(ValorTotal) OVER(ORDER BY IdVeiculo ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as WF 
	FROM Locacao;

-- As 5 primeiras locações ordendas de forma ascendente pela coluna IdVeiculo

SELECT  TOP 5 Id as IdLocacao,
			  IdVeiculo,
		      ValorTotal
	FROM Locacao
	ORDER BY 2;

-- Window Function com PARTITON BY dentro do OVER():

-- O PARTITION BY funciona como o GROUP BY, mas sem suprimir informações. O PARTITION BY cria um particionamento de informações
-- dentro da tabela com base em uma coluna específica, no caso IdVeiculo. A função usada, no caso a SUM(), fará a soma de 
-- todas os valores referentes a um IdVeiculo e apresentará o valor final em todas as linhas referentes àquele IdVeiculo.
-- Diferente do ORDER BY, o PARTITION BY não acumula por linha e sim separa por grupos da coluna específicada. 

SELECT  TOP 5
		Id as IdLocacao,
		IdVeiculo,
		ValorTotal,
		SUM(ValorTotal) OVER(PARTITION BY IdVeiculo) as WF 
	FROM Locacao;

-- Window Function com PARTITON BY e ORDER BY dentro do OVER():

-- O PARTITION BY continua funcionando como o GROUP BY, particionando em grupos os IdVeiculos,
-- somando todos os valores daquele IdVeiculo específico e repetindo o valor final da soma em todas as linhas do IdVeiculo. 
-- O ORDER BY entra para organizar a sequência do particionamento de forma ascendente ou descendente.

SELECT  Id as IdLocacao,
		IdVeiculo,
		ValorTotal,
		SUM(ValorTotal) OVER(
			PARTITION BY IdVeiculo 
			ORDER BY Id DESC
			) as WF 
	FROM Locacao;

-- Window Function com PARTITON BY e ORDER BY dentro do OVER() e ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW:

-- O uso do ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW serve para mostrar detalhadamente a progressão da soma dos valores
-- da partição especificada (IdVeiculo). Ao invés da função realizar a soma e retornar o valor final para todas as linhas do
-- campo específico, ela colocará valor por valor mostrando a progressão da soma da partição específica.

SELECT  Id as IdLocacao,
		IdVeiculo,
		ValorTotal,
		SUM(ValorTotal) OVER(
			PARTITION BY IdVeiculo 
			ORDER BY Id DESC
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
			) as WF 
	FROM Locacao;

--------------------------------------------------------------------------------------------------------------------------------------------