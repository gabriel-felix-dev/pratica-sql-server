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
	FROM Passageiro AS pa
	WHERE pa.NomeCompleto LIKE 'Thia%';

SELECT	*
	FROM Embarque AS em;

SELECT	*
	FROM Voo AS vo;

SELECT	*
	FROM StatusOperacional AS so;

SELECT	pa.Id as Identificador,
		pa.NomeCompleto as Passageiro,
		vo.CodigoUnico as CodigoVoo,
		so.Nome as Status
	FROM Passageiro AS pa
		INNER JOIN Embarque AS em
			ON em.IdPassageiro = pa.Id
		INNER JOIN Voo AS vo
			ON vo.Id = em.IdVoo
		INNER JOIN StatusOperacional AS so
			ON so.Id = vo.IdStatusOperacional
	WHERE so.Nome = 'Concluido'
	GROUP BY pa.Id, pa.NomeCompleto, vo.CodigoUnico, so.Nome
	ORDER BY 1, 2, 3;
	GO

SELECT	pa.NomeCompleto as Passageiro, 
		COUNT(vo.Id) as QuantidadeVoosConcluidos
	FROM Passageiro AS pa
		INNER JOIN Embarque AS em
			ON em.IdPassageiro = pa.Id
		INNER JOIN Voo AS vo
			ON vo.Id = em.IdVoo
		INNER JOIN StatusOperacional AS so
			ON so.Id = vo.IdStatusOperacional
	WHERE so.Nome = 'Concluido'
	GROUP BY pa.NomeCompleto
	HAVING COUNT(vo.Id) > (SELECT	TOP 1 em.IdPassageiro as IdentificadorPassageiro,
									COUNT(em.Id) as TotalEmbarques
								FROM Embarque AS em
									INNER JOIN Voo AS vo
										ON vo.Id = em.IdVoo
									INNER JOIN StatusOperacional AS so
										ON so.Id = vo.IdStatusOperacional
								WHERE so.Nome = 'Concluido'
								GROUP BY em.IdPassageiro, so.Nome
								ORDER BY 2 DESC
							);

-- 1. Contagem dos embarques concluidos por passageiro:

SELECT	em.IdPassageiro as IdentificadorPassageiro,
		COUNT(em.Id) as TotalEmbarques
	FROM Embarque AS em
		INNER JOIN Voo AS vo
			ON vo.Id = em.IdVoo
		INNER JOIN StatusOperacional AS so
			ON so.Id = vo.IdStatusOperacional
	WHERE so.Nome = 'Concluido'
	GROUP BY em.IdPassageiro;

-- 2. Para cada passageiro, conte os embarques em cada outro status:

SELECT	em.IdPassageiro as IdentificadorPassageiro,
		COUNT(em.Id) as TotalEmbarques
	FROM Embarque AS em
		INNER JOIN Voo AS vo
			ON vo.Id = em.IdVoo
		INNER JOIN StatusOperacional AS so
			ON so.Id = vo.IdStatusOperacional
	WHERE so.Nome != 'Concluido'
	GROUP BY em.IdPassageiro, so.Nome -- Separa por Id de passageiro e nome de Status Operacional. Ficará:
									  --  IdPassageiro 1 - Cancelado 1
									  --  IdPassageiro 1 - Atrasado 2 

-- 3. Juntar as duas consultas como escalares no Having da busca por nome de passageiro

SELECT	pa.NomeCompleto as Passageiro
	FROM Passageiro AS pa
	WHERE EXISTS (SELECT  1
					  FROM Embarque AS em
						  INNER JOIN Voo AS vo
							  ON vo.Id = em.IdVoo
						  INNER JOIN StatusOperacional AS so
						      ON so.Id = vo.IdStatusOperacional
						  WHERE so.Nome = 'Concluido'
							AND em.IdPassageiro = pa.Id
				 )
		AND NOT EXISTS (SELECT  1
							FROM Embarque AS em2
								INNER JOIN Voo AS vo2
									ON vo2.Id = em2.IdVoo
								INNER JOIN StatusOperacional AS so2
									ON so2.Id = vo2.IdStatusOperacional
								WHERE so2.Nome != 'Concluido'
									AND em2.IdPassageiro = pa.Id
								GROUP BY so2.Nome
								HAVING COUNT(*) >= (SELECT  COUNT(*)
														FROM Embarque AS em3
															INNER JOIN Voo AS vo3
																ON vo3.Id = em3.IdVoo
															INNER JOIN StatusOperacional AS so3
																ON so3.Id = vo3.IdStatusOperacional
														WHERE so3.Nome = 'Concluido'
															AND em3.IdPassageiro = pa.Id
												   )
				       );

-- Implementando a contagem junto ao nome do passageiro

SELECT	pa.NomeCompleto as Passageiro,
		(SELECT  COUNT(vo4.Id)
			FROM Embarque AS em4
				INNER JOIN Voo AS vo4
					ON vo4.Id = em4.IdVoo
				INNER JOIN StatusOperacional AS so4
					ON so4.Id = vo4.IdStatusOperacional
			WHERE so4.nome = 'Concluido'
				AND em4.IdPassageiro = pa.Id) as QuantidadeVoosConcluidos
	FROM Passageiro AS pa
	WHERE EXISTS (SELECT  1
					  FROM Embarque AS em
						  INNER JOIN Voo AS vo
							  ON vo.Id = em.IdVoo
						  INNER JOIN StatusOperacional AS so
						      ON so.Id = vo.IdStatusOperacional
						  WHERE so.Nome = 'Concluido'
							AND em.IdPassageiro = pa.Id
				 )
		AND NOT EXISTS (SELECT  1
							FROM Embarque AS em2
								INNER JOIN Voo AS vo2
									ON vo2.Id = em2.IdVoo
								INNER JOIN StatusOperacional AS so2
									ON so2.Id = vo2.IdStatusOperacional
								WHERE so2.Nome != 'Concluido'
									AND em2.IdPassageiro = pa.Id
								GROUP BY so2.Nome
								HAVING COUNT(*) >= (SELECT  COUNT(*)
														FROM Embarque AS em3
															INNER JOIN Voo AS vo3
																ON vo3.Id = em3.IdVoo
															INNER JOIN StatusOperacional AS so3
																ON so3.Id = vo3.IdStatusOperacional
														WHERE so3.Nome = 'Concluido'
															AND em3.IdPassageiro = pa.Id
												   )
				       );
