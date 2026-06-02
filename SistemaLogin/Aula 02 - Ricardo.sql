-- Aula 02 Ricardo - 02/06/2026

USE BancoRicardo;
GO

WITH Chato AS(
			  SELECT  TOP 1 lo.IdUsuario as IdentificadorUsuario,
							COUNT(*) as Quantidade
				FROM Logon AS lo WITH(NOLOCK)
				WHERE CAST(lo.DataLogon AS DATE) = CAST(GETDATE() AS DATE)
				GROUP BY lo.IdUsuario
				ORDER BY Quantidade DESC
			 )
SELECT	us.Id as IdentificadorUsuario,
		us.Nome as Usuario,
		op.Id as IdentificadorOpcao,
		op.Nome as Opcao
	FROM Chato AS ch	
		INNER JOIN Usuario AS us
			ON us.Id = ch.IdentificadorUsuario
		INNER JOIN Logon AS lo WITH(NOLOCK)
			ON lo.IdUsuario = us.Id 
				AND lo.IdUsuario = ch.IdentificadorUsuario
		INNER JOIN OpcaoAcionada AS oa
			ON oa.IdLogon = lo.Id
		INNER JOIN Opcao AS op
			ON op.Id = oa.IdOpcao;

-- Replicar movimento de Hoje para dia 30/05 -> Colocar as informações da tabela Logon e OpcaoAcionada registradas no dia 02/06/2026 no dia 30/05/2026

-- INSERT LOGON 

INSERT INTO Logon (IdUsuario, DataLogon, Sucesso) 
	SELECT  sub.IdUsuario,
		    CAST('2026-05-30' AS DATE), --> Outra forma DATEADD(DAY, -3, DATALOGON)
			sub.Sucesso
		FROM (
			  SELECT	IdUsuario,
					    Sucesso
				FROM Logon
				WHERE CAST(DataLogon AS DATE) = CAST(GETDATE() AS DATE)	
			 ) AS sub

-- INSERT OpcaoAcionada

INSERT INTO OpcaoAcionada (IdLogon, IdOpcao, InstanteLogon) 
	SELECT  sub.IdLogon,
			sub.IdOpcao,
		    CAST('2026-05-30' AS DATE)
		FROM (
			  SELECT	IdLogon,
						IdOpcao,
						InstanteLogon
				FROM OpcaoAcionada
				WHERE CAST(InstanteLogon AS DATE) = CAST(GETDATE() AS DATE)
			 ) AS sub

-- INSERT anterior com CTE

WITH Acionada AS (
				  SELECT  ln.Id,
						  oa.IdOpcao,
						  oa.InstanteLogon
					 FROM OpcaoAcionada AS oa WITH(NOLOCK)
						INNER JOIN Logon AS lv WITH(NOLOCK)
							ON lv.Id = oa.IdLogon
								AND CAST(lv.DataLogon AS DATE) = CAST(GETDATE() AS DATE)
						INNER JOIN Logon AS ln WITH(NOLOCK)
							ON ln.IdUsuario = lv.IdUsuario
								AND ln.DataLogon =  DATEADD(DAY, -3, lv.DataLogon)
				 )
INSERT INTO OpcaoAcionada (IdLogon, IdOpcao, InstanteLogon)
	SELECT  Id,
			IdOpcao,
			InstanteLogon
		FROM Acionada WITH(NOLOCK);
