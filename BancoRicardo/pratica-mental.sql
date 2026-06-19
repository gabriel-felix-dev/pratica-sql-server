--Inserir na tabela OpcaoAcionada o registro de acionamento da Opcao "Relatório" relativo aos Usuários que estão com a opção mais acionada. 
--Ademias, os usuários não podem ter acionar uma opção sem realizar logon.

WITH OpcaoMaisAcionada AS (
                           SELECT	TOP 1 op.Id as IdOpcao,
										  op.Nome as NomeOpcao,
									      COUNT(oa.IdOpcao) as QuantidadeAcionamentos 
								FROM OpcaoAcionada AS oa WITH(NOLOCK)
									INNER JOIN Opcao AS op WITH(NOLOCK)
										ON op.Id = oa.IdOpcao
								GROUP BY op.Id, op.Nome
								ORDER BY QuantidadeAcionamentos DESC
						  ),
ListaUsuarioComOpcaoMaisAcionada AS (
                                     SELECT	 us.Id as IdentificadorUsuario,
											 lo.Sucesso as StatusLogon
										 FROM Usuario AS us WITH(NOLOCK)
											 INNER JOIN Logon AS lo WITH(NOLOCK)
												 ON lo.IdUsuario = us.Id
											 INNER JOIN OpcaoAcionada AS oa WITH(NOLOCK)
												 ON oa.IdLogon = lo.Id
											 INNER JOIN Opcao AS op WITH(NOLOCK)
												 ON op.Id = oa.IdOpcao
											 INNER JOIN OpcaoMaisAcionada AS om
												 ON om.IdOpcao = op.Id
										 WHERE op.Id = om.IdOpcao
									)
INSERT INTO Logon (IdUsuario, DataLogon, Sucesso)
	SELECT  lu.IdentificadorUsuario,
			GETDATE(),
			lu.StatusLogon
		FROM ListaUsuarioComOpcaoMaisAcionada AS lu;


INSERT INTO OpcaoAcionada (IdLogon, IdOpcao, InstanteLogon)
	SELECT	lo.Id,
			2,
			lo.Sucesso
		FROM Logon AS lo WITH(NOLOCK)
		WHERE CAST(DataLogon AS DATE) = CAST(Getdate() AS DATE);
