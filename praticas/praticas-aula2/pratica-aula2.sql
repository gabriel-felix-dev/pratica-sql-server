USE WoodCraft;

-- CTEs


-- Window Functions

USE PetShop;

SELECT  IdVenda,
		Valor,
		SUM(Valor) OVER () as Miau
	FROM Pagamento;

SELECT  IdVenda,
		Valor,
		SUM(Valor) OVER (ORDER BY Valor DESC) as Miau
	FROM Pagamento;

SELECT * FROM Pagamento WHERE IdVenda = 113;

SELECT  IdVenda,
		Valor,
		SUM(Valor) OVER (PARTITION BY IdVenda) as Miau
	FROM Pagamento;

USE LocadoraVeiculos;

SELECT  *
	FROM Locacao;

SELECT  TOP 5 Id as IdLocacao,
			  IdVeiculo,
		      ValorTotal
	FROM Locacao
	ORDER BY 2;

SELECT SUM(ValorTotal) FROM Locacao;

SELECT  Id as IdLocacao,
		IdVeiculo,
		ValorTotal,
		SUM(ValorTotal) OVER() as WF 
	FROM Locacao;
	
SELECT  Id as IdLocacao,
		IdVeiculo,
		ValorTotal,
		SUM(ValorTotal) OVER(ORDER BY IdVeiculo ASC) as WF 
	FROM Locacao;

SELECT  TOP 5
		Id as IdLocacao,
		IdVeiculo,
		ValorTotal,
		SUM(ValorTotal) OVER(PARTITION BY IdVeiculo) as WF 
	FROM Locacao;

SELECT  Id as IdLocacao,
		IdVeiculo,
		ValorTotal,
		SUM(ValorTotal) OVER(PARTITION BY IdVeiculo ORDER BY IdVeiculo ASC) as WF 
	FROM Locacao;
