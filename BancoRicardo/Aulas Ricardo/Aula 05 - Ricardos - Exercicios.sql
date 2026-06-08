-- Com base no Logon, monte um relatório de frequência do usuário

SELECT	us.Nome as Usuario,
		us.Email as Email,
		COUNT(lo.IdUsuario) as QuantidadesAcesso
	FROM Usuario AS us WITH(NOLOCK)
		INNER JOIN Logon AS lo WITH(NOLOCK)
			ON lo.IdUsuario = us.Id
	GROUP BY us.Id, us.Nome, us.Email;

-- Crie uma listagem das opções menos utilizadas historicamente

;WITH OpcaoMaisUtilizada AS (
							 SELECT  TOP 1 op.Id as IdentificadorOpcao,
									       COUNT(oa.IdOpcao) as MaisUtilizada
								FROM OpcaoAcionada AS oa WITH(NOLOCK)
									INNER JOIN Opcao AS op WITH(NOLOCK)
										ON op.Id = oa.IdOpcao
								GROUP BY op.Id, op.Nome
								ORDER BY MaisUtilizada DESC
                            )
SELECT	op.Nome as Opcao,
		COUNT(oa.IdOpcao) as TotalUtilizada
	FROM OpcaoAcionada AS oa WITH(NOLOCK)
		INNER JOIN Opcao AS op WITH(NOLOCK)
			ON op.Id = oa.IdOpcao
		INNER JOIN OpcaoMaisUtilizada AS om WITH(NOLOCK)
			ON om.IdentificadorOpcao = op.Id
	GROUP BY op.Id, op.Nome, om.MaisUtilizada
	HAVING COUNT(oa.IdOpcao) < om.MaisUtilizada;
--------------------------------------------------------------------------------------------------
SELECT	op.Nome as Opcao,
		COUNT(oa.IdOpcao) as TotalUtilizada
	FROM OpcaoAcionada AS oa WITH(NOLOCK)
		INNER JOIN Opcao AS op WITH(NOLOCK)
			ON op.Id = oa.IdOpcao
	GROUP BY op.Id, op.Nome
	HAVING COUNT(oa.IdOpcao) < (SELECT  TOP 1 COUNT(oa.IdOpcao) as MaisUtilizada
									FROM OpcaoAcionada AS oa WITH(NOLOCK)
										INNER JOIN Opcao AS op WITH(NOLOCK)
											ON op.Id = oa.IdOpcao
									GROUP BY op.Id, op.Nome
									ORDER BY MaisUtilizada DESC);

-- Crie um movimento de Logon de todos os usuários com as 5 opções mais acionadas -> data 10/06

WITH Miau AS (
			SELECT  TOP 5 op.Id as IdentificadorOpcao,
						  op.Nome as Opcao,
						  COUNT(oa.IdOpcao) as QuantidadeAcionada
				FROM OpcaoAcionada AS oa WITH(NOLOCK)
					INNER JOIN Opcao AS op WITH(NOLOCK)
						ON op.Id = oa.IdOpcao
				GROUP BY op.Nome, op.Id
				ORDER BY QuantidadeAcionada DESC
			 )
INSERT INTO Logon(IdUsuario, DataLogon, Sucesso)
SELECT lo.IdUsuario,
	   2026-06-10,
	   lo.Sucesso
	FROM Logon AS lo WITH(NOLOCK)
		INNER JOIN OpcaoAcionada AS op WITH(NOLOCK)
			ON op.IdLogon = lo.Id
		INNER JOIN Miau AS mi
			ON mi.IdentificadorOpcao = op.IdOpcao
	WHERE op.IdOpcao = mi.IdentificadorOpcao;

-- Crie um movimento de Logon de todos os usuarios com as 3 opções menos acionadas -> Data 11/06

WITH Miau2 AS (
			   SELECT  TOP 3 op.Id as IdentificadorOpcao,
							 op.Nome as Opcao,
							 COUNT(oa.IdOpcao) as QuantidadeAcionada
					FROM OpcaoAcionada AS oa WITH(NOLOCK)
						INNER JOIN Opcao AS op WITH(NOLOCK)
							ON op.Id = oa.IdOpcao
					GROUP BY op.Nome, op.Id
					ORDER BY QuantidadeAcionada ASC
              )
INSERT INTO Logon(IdUsuario, DataLogon, Sucesso)
SELECT  lo.IdUsuario,
		2026-06-11,
		lo.Sucesso
	FROM Logon AS lo WITH (NOLOCK)
		INNER JOIN OpcaoAcionada AS oa WITH(NOLOCK)
			ON oa.IdLogon = lo.Id
		INNER JOIN Miau2 AS mi
			ON mi.IdentificadorOpcao = oa.IdOpcao
	WHERE oa.IdOpcao = mi.IdentificadorOpcao;
