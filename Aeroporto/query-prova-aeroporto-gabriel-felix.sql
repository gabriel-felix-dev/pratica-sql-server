USE AeroportoCeuAzul;
GO

-- 10. Liste as cidades que possuem mais de um aeroporto cadastrado, exibindo a cidade, o país e a quantidade de aeroportos.

SELECT	en.Cidade as 'Cidade',
		en.Pais as 'País',
		COUNT(ae.Id) as 'Quantidade de Aeroportos'
	FROM Aeroporto AS ae
		INNER JOIN Endereco AS en
			ON en.Id = ae.IdEndereco
	GROUP BY en.Cidade, en.Pais
	HAVING COUNT(ae.Id) > 1;

/* A consulta realizará a junção das tabelas Aeroporto e Endereco para que possa ter a quantidade de Aeroportos por cada Cidade e Pais. 
   O sistema agrupará por Cidade e Pais os Aeroportos que, contando por seus id's, tiverem uma quantidade maior que um*/


-- 15. Liste o nome dos passageiros que embarcaram em voos partindo do aeroporto Pinto Martins (Fortaleza), 
--     juntamente com o código do voo e a data de partida.

SELECT	pa.NomeCompleto as 'Passageiros',
		vo.CodigoUnico as 'Código de Voo',
		CAST(vo.DataHoraPartida AS DATE) as 'Data de Partida'
	FROM Passageiro AS pa
		INNER JOIN Embarque AS em
			ON em.IdPassageiro = pa.Id
		INNER JOIN Voo AS vo
			ON vo.Id = em.IdVoo
		INNER JOIN Aeroporto AS ae
			ON ae.Id = vo.IdAeroportoOrigem
	WHERE ae.Nome = 'Aeroporto Internacional Pinto Martins - Fortaleza (FOR)';

/* A consulta fará a junção das tableas Passaegiro, Embarque, Voo e Aeroporto para que possamos tanto realizar o filtro pelo nome do Aeroporto
   como imprimir os dados solicitados. */


-- 26. Para cada status operacional, exiba o nome do status e a duração média estimada dos voos com aquele 
--     status (ignorando status sem voos).

SELECT	so.Nome	as 'Status Operacional',
		AVG(vo.DuracaoEstimada) as 'Duração Média'
	FROM StatusOperacional AS so
		LEFT JOIN Voo AS vo
			ON vo.IdStatusOperacional = so.Id
	WHERE vo.Id IS NOT NULL
	GROUP BY so.Nome;

/* A consulta retornará todos os dados da tabela StatusOperacinal, mas não imprimirá os Status que tiverem algum Voo nulo. A consulta 
   realiza a média da duração dos voos e agrupa pelo nome dos Status*/

-- 35. Mostre as classes de embarque cuja média do número da poltrona é inferior a 30, com o número médio 
--     arredondado a 2 casas decimais. 

SELECT	ce.Nome	as 'Classe de Embarque',
		ROUND(AVG(em.NumeroPoltrona), 2) as 'Média do Número da Poltrona'
	FROM ClasseEmbarque AS ce
		INNER JOIN Embarque AS em
			ON em.IdClasseEmbarque = ce.Id
	GROUP BY ce.Nome
	HAVING AVG(em.NumeroPoltrona) < 30;

/* A consulta faz a junção das tabelas ClasseEmbarque e Embarque para poder Agrupar pelo no Classe de Embarque os valores médios dos números
   das poltronas. Ademais, ela realiza um filtro para trazer os valores médios abaixo de 30*/

-- 46. Mostre o ano e o mês em que mais voos foram registrados no sistema.

--SELECT	ConsultaAno.Ano as 'Ano com maior Registro',
--		ConsultaMes.Mês as 'Mês com maior Registro'
--	FROM (SELECT  TOP 1
--			      YEAR(vo.DataHoraPartida) as 'Ano',
--		          COUNT(YEAR(vo.DataHoraPartida)) as 'Quantidade de Registros'
--			FROM Voo AS vo
--			GROUP BY YEAR(vo.DataHoraPartida)
--			ORDER BY COUNT(YEAR(vo.DataHoraPartida)) DESC) AS ConsultaAno,	
--	(SELECT  TOP 1
--			 MONTH(vo.DataHoraPartida) as 'Mês',
--			 COUNT(MONTH(vo.DataHoraPartida)) as 'Quantidade de Registros' 
--		FROM Voo AS vo
--		GROUP BY  MONTH(vo.DataHoraPartida)
--		ORDER BY COUNT(MONTH(vo.DataHoraPartida)) DESC) as ConsultaMes;

SELECT	TOP 1 YEAR(vo.DataHoraPartida) as Ano,
		MONTH(vo.DataHoraPartida) as Mes,
		COUNT(vo.Id) as QuantidadeVoos
	FROM Voo AS vo
	GROUP BY YEAR(vo.DataHoraPartida), MONTH(vo.DataHoraPartida)
	ORDER BY COUNT(vo.Id) DESC;

/* A consulta possuí duas subconsultas. Uma realiza a filtragem de quantos Voos existem por ano e a outra quantos Voos existem por casa mês. 
   Ambas ordenam da maior para a menor e retornam apenas um valor. A consulta principal informa o ano e o mês com maior voos. */

-- 60. Para cada país, calcule a porcentagem dos voos do sistema que partem dele em relação ao total geral de voos.

SELECT	en.Pais as 'País',
		COUNT(vo.Id) as 'Total de Voos',
		CAST(COUNT(vo.Id) * 100.0 / (SELECT  COUNT(*)
							            FROM Voo AS vo) AS DECIMAL (10,2)) as 'Porcentagem de Voos que Saíram do País (%)'
	FROM Endereco AS en
		INNER JOIN Aeroporto AS ae
			ON ae.IdEndereco = en.Id
		INNER JOIN Voo AS vo
			ON vo.IdAeroportoOrigem = ae.Id
	GROUP BY en.Pais;

/* A consulta possuí faz a junção de três tabelas, Aeroporto e Voo. Com a junção, podemos imprimir o País junto da quantidade de total de 
   voo e realizar a um calculo para retornar a porcentagem de voos que sairam daquele pais. Foi utilizado o CAST para formatar a casas
   decimais após a virgula.*/

-- 70. Mostre os passageiros para os quais a quantidade de embarques em voos com status "Concluido" é maior 
--     que a quantidade em qualquer outro status individualmente.

SELECT	pa.NomeCompleto as Passageiro
	FROM Passageiro AS pa
	WHERE EXISTS (SELECT  1
					  FROM Embarque AS em2
						  INNER JOIN Voo AS vo2
							  ON em2.IdVoo = vo2.Id
						  INNER JOIN StatusOperacional AS so2
							  ON vo2.IdStatusOperacional = so2.Id
					  WHERE so2.Nome = 'Concluido'
						AND em2.IdPassageiro = pa.Id
					  GROUP BY so2.Nome, em2.IdPassageiro
				 )
		AND NOT EXISTS (SELECT  1
							FROM Embarque AS em3
								INNER JOIN Voo AS vo3
									ON em3.IdVoo = vo3.Id
								INNER JOIN StatusOperacional AS so3
									ON vo3.IdStatusOperacional = so3.Id
								WHERE so3.Nome != 'Concluido'
									AND em3.IdPassageiro = pa.id
								GROUP BY so3.Nome, em3.IdPassageiro
								HAVING COUNT(*) >= (SELECT	COUNT(*)
														FROM Embarque AS em4
															INNER JOIN Voo AS vo4
																ON em4.IdVoo = vo4.Id
															INNER JOIN StatusOperacional AS so4
																ON vo4.IdStatusOperacional = so4.Id
														WHERE so4.Nome = 'Concluido'
															AND em4.IdPassageiro = pa.Id)
					   );


SELECT	pa.NomeCompleto as 'Passageiro'
	FROM Passageiro AS pa
		INNER JOIN Embarque AS em
			ON em.IdPassageiro = pa.Id
		INNER JOIN Voo AS vo
			ON vo.Id = em.IdVoo
		INNER JOIN StatusOperacional AS so
			ON so.Id = vo.IdStatusOperacional
	GROUP BY pa.Id, pa.NomeCompleto
	HAVING SUM(CASE 
				   WHEN so.Nome = 'Concluido' THEN 1
			   END) > (SELECT  MAX(SubConsultaStatus.[Quantidade Por Status])
			               FROM (SELECT  COUNT(*) as 'Quantidade Por Status'
						             FROM Embarque AS em2
										INNER JOIN Voo AS vo2
											ON vo2.Id = em2.IdVoo
										INNER JOIN StatusOperacional AS so2
											ON so2.Id = vo2.IdStatusOperacional
									  WHERE em2.IdPassageiro = pa.Id AND so2.Nome != 'Concluido'
									  GROUP BY so2.Nome) AS SubConsultaStatus);

/* A consulta possuí duas subconsultas no HAVING para poder realizar a comparação entre a quantidade de total de Status Concluido
   e os demais Status. A consulta mais interna verifica a quantidade total por Status desconsiderando o status Concluido, o valor total
   dela é armazenada em uma outra subconsulta. O resultado da segunda subconsulta é compara no valor resultante do CASE que realiza a
   soma de quantos status Concluido cada passageiro tem. */

-- 75. Mostre os 5 voos com mais bilhetes emitidos.

SELECT	TOP 5
		vo.CodigoUnico as 'Código do Voo',
		COUNT(em.DataEmissaoBilhete) as 'Quantidade de Bilhetes Emitidos'
	FROM Embarque AS em
		INNER JOIN Voo AS vo
			ON vo.Id = em.IdVoo
	GROUP BY vo.CodigoUnico
	ORDER BY COUNT(em.DataEmissaoBilhete) DESC;

/* A consulta retornará os 5 códigdos de voo principais. 
   Ela será organizada do maior para o menor com base na quantidade de emissão de bilhetes agrupado pelo código de cada
   voo. */

-- 90. Apresente o intervalo médio (em horas) entre a emissão do bilhete e o horário de partida, agrupado 
--     por classe de embarque.

SELECT	ce.Nome as ClasseEmbarque,
		(SELECT  ROUND(AVG(DATEDIFF(MINUTE, em2.DataEmissaoBilhete, vo2.DataHoraPartida) / 60.0), 2) as DiferencaEntreEmissaVoo
			FROM Embarque AS em2
				INNER JOIN Voo AS vo2
					ON em2.IdVoo = vo2.Id
				INNER JOIN ClasseEmbarque AS ce2
					ON em2.IdClasseEmbarque = ce2.Id
			WHERE ce2.Id = ce.Id
		) as Media
	FROM Embarque AS em
		INNER JOIN VOO as vo
			ON em.IdVoo = vo.Id
		INNER JOIN ClasseEmbarque AS ce
			ON em.IdClasseEmbarque = ce.Id
	GROUP BY ce.Nome, ce.Id;


-- 100. Liste os voos que possuem escala (conexão) e mostre o aeroporto intermediário utilizado.

/* 

A query solicitada não possível ser executada porque não há nas tabelas do banco o registro de escalas dos voos.

*/
