-- Aula 03 - Ricardo

--Atualizar as datas de Logon e as datas de Acionamento da Opcao mantendo a hora, minuto, 
--segundo e milissegundo para três dias para frente em relação a hoje dos usuários que ficaram em
--segundo colocado em quantidade de logon historicamente

-- Filtro: O usuário que ficou em segundo colocado na quantidade total de Logon

--WITH SegundoMaiorLogon AS(
--						  SELECT  us.Id as IdUsuario,
--								  us.Nome as NomeUsuario,
--								  COUNT(lo.IdUsuario) as QuantidadeLogons,
--								  ROW_NUMBER() OVER (ORDER BY COUNT(lo.IdUsuario) DESC) as NumeroLinha
--							 FROM Usuario AS us
--								 INNER JOIN Logon AS lo
--									 ON lo.IdUsuario = us.Id
--							 GROUP BY us.Nome, us.Id
--)
--UPDATE Logon
--SET DataLogon = DATEADD(DAY, 3, GETDATE())
--WHERE IdUsuario = (SELECT IdUsuario FROM SegundoMaiorLogon WHERE NumeroLinha = 2); 

--UPDATE OpcaoAcionada 
--SET IdLogon = DATEADD(DAY, 3, GETDATE());

--> Resolução Ricardo

 WITH Campeos AS (
				  SELECT  TOP 2 IdUsuario,
				                COUNT(*) as Quantidade
					  FROM Logon WITH(NOLOCK)
					  GROUP BY IdUsuario
					  ORDER BY Quantidade DESC
				 ),
Segundo AS (
            SELECT  TOP 1 IdUsuario,
			              Quantidade
			   FROM Campeos
			   ORDER BY Quantidade ASC
		   )
UPDATE lg
SET lg.DataLogon = DATEADD(DAY, DATEDIFF(DAY, lg.DataLogon, DATEADD(DAY, 3, GETDATE())), lg.DataLogon)
	FROM Logon AS lg
		INNER JOIN Segundo AS sg
			ON lg.IdUsuario = sg.IdUsuario
	WHERE lg.IdUsuario = sg.IdUsuario;

UPDATE oa
SET oa.InstanteLogon = DATEADD(DAY, DATEDIFF(DAY, oa.InstanteLogon, DATEADD(DAY, 3, GETDATE())), oa.InstanteLogon)
	FROM OpcaoAcionada AS oa
		INNER JOIN Logon AS lo WITH(NOLOCK)
			ON lo.Id = oa.IdLogon
	WHERE oa.InstanteLogon > GETDATE();

--> Atualizar as data de Logon e OpcaoAcionada para 5 dias para frente de hoje somente 
--para usuario que logaram em hora par;

WITH UsuarioAcessadoHoraPar AS (
							    SELECT  lo.IdUsuario
									FROM Logon AS lo
									WHERE DATEPART(HOUR, lo.DataLogon) % 2 = 0
							   )
UPDATE lo
SET lo.DataLogon = DATEADD(DAY, DATEDIFF(DAY, lo.DataLogon, DATEADD(DAY, 5, GETDATE())),lo.DataLogon)
FROM Logon AS lo
	INNER JOIN UsuarioAcessadoHoraPar AS up
		ON up.IdUsuario = lo.IdUsuario
WHERE lo.IdUsuario = up.IdUsuario

UPDATE oa
SET InstanteLogon = DATEADD(DAY, DATEDIFF(DAY, oa.InstanteLogon, DATEADD(DAY, 5, GETDATE())),oa.InstanteLogon)
FROM OpcaoAcionada AS oa
	INNER JOIN Logon AS lo
		ON lo.Id = oa.IdLogon
WHERE lo.DataLogon = CAST(DATEADD(DAY, 5, GETDATE()) AS DATE);
