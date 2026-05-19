SELECT	vo.Id as IdentificadorVoo
	FROM Voo AS vo
		INNER JOIN StatusOperacional AS so
			ON so.Id = vo.IdStatusOperacional
	WHERE so.Nome = 'Cancelado'

SELECT	*
	FROM Voo AS vo;

SELECT	*
	FROM Passageiro AS pa
		INNER JOIN Embarque AS em
			ON em.IdPassageiro = pa.Id
		INNER JOIN Voo AS vo
			ON vo.Id = em.IdVoo
		INNER JOIN StatusOperacional AS so
			ON so.Id = vo.IdStatusOperacional;

SELECT	*
	FROM Embarque AS em;
	
SELECT	*
	FROM Aeroporto AS ae;

SELECT	pa.NomeCompleto as Passageiro
	FROM Passageiro AS pa
	WHERE pa.Id IN (SELECT	em.IdPassageiro
						FROM Embarque AS em
							INNER JOIN Voo AS vo
								ON vo.Id = em.IdVoo
							INNER JOIN StatusOperacional AS so
								ON so.Id = vo.IdStatusOperacional
						WHERE so.Nome = 'Cancelado'
					);

SELECT	pa.NomeCompleto as Passageiro,
		vo.CodigoUnico as CodigoVoo,
		CAST(vo.DataHoraPartida AS DATE) as DataPartida
	FROM Passageiro AS pa
		INNER JOIN Embarque AS em
			ON em.IdPassageiro = pa.Id
		INNER JOIN Voo AS vo
			ON vo.Id = em.IdVoo
		INNER JOIN Aeroporto AS ae
			ON ae.Id = vo.IdAeroportoOrigem
	WHERE ae.Nome = 'Aeroporto Internacional Pinto Martins - Fortaleza (FOR)';			

--Questão 15 

SELECT	pa.NomeCompleto as Passageiro,
		vo.CodigoUnico as CodigoVoo,
		CAST(vo.DataHoraPartida AS DATE) as DataPartida
	FROM Passageiro AS pa
		INNER JOIN Embarque AS em
			ON em.IdPassageiro = pa.Id
		INNER JOIN Voo AS vo
			ON vo.Id = em.IdVoo
		INNER JOIN Aeroporto AS ae
			ON ae.Id = vo.IdAeroportoOrigem
	WHERE ae.Nome = 'Aeroporto Internacional Pinto Martins - Fortaleza (FOR)';

--Questão 35 - Classes de embarque cuja média do número da poltrona é inferior à média geral, com o número médio 
--             arredondado a 2 casas decimais.

SELECT	ce.Nome as ClasseEmbarque,
		CAST(ROUND(AVG(em.NumeroPoltrona), 2) AS DECIMAL (10,2))
	FROM Embarque AS em
		INNER JOIN ClasseEmbarque AS ce
			ON ce.Id = em.IdClasseEmbarque
	GROUP BY ce.Nome
	HAVING AVG(em.NumeroPoltrona) < (SELECT  AVG(em2.NumeroPoltrona) FROM Embarque AS em2);

--Questão 10 - Cidades que possuem mais de um aeroporto, exibindo cidade, país e quantidade.

SELECT	en.Cidade as Cidade,
		en.Pais as Pais,
		COUNT(ae.Id) as QuantidadeAeroporto
	FROM Aeroporto AS ae
		INNER JOIN Endereco AS en
			ON en.Id = ae.IdEndereco
	GROUP BY en.Cidade, en.Pais
	HAVING COUNT(ae.Nome) > 1;

--Questão 70 - Mostre os passageiros para os quais a quantidade de embarques em voos com status 
--             "Concluido" é maior que a quantidade em qualquer outro status individualmente.

SELECT	*
	FROM Passageiro AS pa;

SELECT	*
	FROM Embarque AS em;

SELECT	*
	FROM Voo AS vo;

SELECT	*
	FROM StatusOperacional AS so;

SELECT	*
	FROM Passageiro AS pa
		INNER JOIN Embarque AS em
			ON em.IdPassageiro = pa.Id
		INNER JOIN Voo AS vo
			ON vo.Id = em.IdVoo
		INNER JOIN StatusOperacional AS so
			ON so.Id = vo.IdStatusOperacional	;

SELECT	pa.NomeCompleto as Passageiro, 
		COUNT(vo.Id) as QuantidadeVoosConcluidos
	FROM Passageiro AS pa
		INNER JOIN Embarque AS em
			ON em.IdPassageiro = pa.Id
		INNER JOIN Voo AS vo
			ON vo.Id = em.IdVoo
		INNER JOIN StatusOperacional AS so
			ON so.Id = vo.IdStatusOperacional
	GROUP BY pa.NomeCompleto;

	-- Colocar o Having e fazer a subquery
