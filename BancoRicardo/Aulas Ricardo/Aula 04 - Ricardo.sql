/* Aula 04 Ricardo:

80% do tempo planejando 
20% do tempo codando 

*/

USE BancoRicardo;

-- Excluir da base todos os registros inconsistentes q tenham o status do logon falhou. O delete não pode ser em cascata.

WITH IdLogonSemSucesso AS (
						   SELECT	lo.Id
						       FROM Logon AS lo WITH(NOLOCK)
							       INNER JOIN OpcaoAcionada AS oa WITH(NOLOCK)
								       ON oa.IdLogon = lo.Id
							   WHERE lo.Sucesso = 0
						  )
DELETE OpcaoAcionada 
WHERE IdLogon IN (SELECT  Id
				      FROM IdLogonSemSucesso);

WITH IdLogonSemSucesso AS (
						   SELECT	lo.IdUsuario
							   FROM Logon AS lo WITH(NOLOCK)
							   WHERE lo.Sucesso = 0
						  )
DELETE Logon 
WHERE IdUsuario IN (SELECT  IdUsuario
				      FROM IdLogonSemSucesso);

DELETE oa
	FROM OpcaoAcionada AS oa WITH(NOLOCK)
		INNER JOIN Logon AS lo WITH(NOLOCK)
			ON lo.Id = oa.IdLogon

-- Vamos um exercicio para popular a base com um comando que popule automaticamente 1000 registros de Logon que 
-- randomicamente seja Sucesso e Fracasso 100 em cada data

/*

-> Limpar base
-> Popular Logon com 1000 dados
	-> 100 por dia
	-> Variar Sucesso e Fracasso
	-> Variar Usuario

No mesmo comando que ele deve executar a limpa e criar os dados

*/

-- 3 CTE's: Nomes do Usuários, Datas e Sucesso / Fracasso
