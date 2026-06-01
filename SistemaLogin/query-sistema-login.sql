SELECT	us.Id as IdentificadorUsuario,
		us.Nome as Usuario,
		COUNT(lo.IdUsuario) as QuantidadeAcessado,
		op.Id as IdentificadorOpcao,
		op.Nome as Opcao,
		COUNT(oa.IdOpcao) as QuantidadeAcionado
	FROM Usuario AS us
		INNER JOIN Logon AS lo
			ON lo.IdUsuario = us.Id
		INNER JOIN OpcaoAcionada AS oa
			ON oa.IdLogon = lo.Id
		INNER JOIN Opcao AS op	
			ON op.Id = oa.IdOpcao
	WHERE lo.DataLogon = GETDATE()
	GROUP BY us.Id, us.Nome, op.Id, op.Nome; --> Corrigir os get date, remover os count e adicionar o having

-- Usuario que mais acessou
SELECT	TOP 1 us.Id as IdentificadorUsuario,
				  COUNT(*) as QuantidadeLogon
		FROM Usuario AS us
			INNER JOIN Logon AS lo
				ON lo.IdUsuario = us.Id
		WHERE CAST(lo.DataLogon AS DATE) = CAST(GETDATE() AS DATE)
		GROUP BY us.Id;

-- CTE
WITH MaisLogou AS (
	SELECT	TOP 1 us.Id as IdentificadorUsuario,
				  COUNT(*) as QuantidadeLogon
		FROM Usuario AS us
			INNER JOIN Logon AS lo
				ON lo.IdUsuario = us.Id
		WHERE CAST(lo.DataLogon AS DATE) = CAST(GETDATE() AS DATE)
		GROUP BY us.Id
);
