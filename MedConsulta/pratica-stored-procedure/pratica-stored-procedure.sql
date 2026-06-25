USE MedConsulta;
GO

-- Criação de uma Procedure.
CREATE PROCEDURE sp_primeira_procedure AS
	SELECT 'Hello, World';

-- Execução de uma Procedure.
EXEC sp_primeira_procedure;

-- Alteração de uma Procedure já existente.
ALTER PROCEDURE sp_primeira_procedure AS
	SELECT 'Hello, World' as Cumprimento;

-- É possível definir tanto o comando de criação como o comando de alteração de Procedure.
	-- Caso a Procedure exista, ela será alterada, caso ela não exista, ela será criada.
-- Procedure com uma query armazenada.
CREATE OR ALTER PROCEDURE sp_consulta AS
	BEGIN
		 SELECT  pa.Nome as Paciente,
				 pa.Telefone as Contato
		     FROM Paciente AS pa WITH(NOLOCK);
	END
GO

EXEC sp_consulta;

-- Procedure com uma query filtrada armazenada.
CREATE OR ALTER PROCEDURE sp_consulta AS
	BEGIN
		 SELECT  pa.Nome as Paciente,
				 pa.Telefone as Contato
		     FROM Paciente AS pa WITH(NOLOCK)
			 WHERE pa.Nome LIKE 'B%';
	END
GO

EXEC sp_consulta;

-- Procedure com um parâmetro de entrada.
CREATE OR ALTER PROCEDURE sp_Idade
(
 @idade INT
) AS
	SELECT CONCAT('Sua idade é: ', @idade) as Idade;
GO

EXEC sp_Idade 25;

-- Procedure com mais de um parâmetro e de tipos diferentes:
CREATE OR ALTER PROCEDURE sp_IdadeNome
(
	@Idade INT,
	@Nome VARCHAR(100)
) AS
	SELECT CONCAT('Olá, ', @Nome, '! Você tem ', @Idade, ' anos.') as NomeIdade;
GO

-- Execução padrão, parâmetros com tipos e ordens corretas.
EXEC sp_IdadeNome 25, 'Gabriel';

-- Outra forma de execução: parâmetros em ordem diferentes, mas com o nome dos parâmetros definidos.
EXEC sp_IdadeNome @Nome = 'Gabriel', @Idade = 25;

-- Procedure que busca Pacientes com DDD iniciado com 11 e com do plano 'Ouro'.
CREATE OR ALTER PROCEDURE sp_buscaContatoPaciente
(
	@Plano VARCHAR(4),
	@Ddd VARCHAR(2)
) AS
	BEGIN
		SELECT  pa.Nome as Paciente,
				pa.Telefone as Contato,
				pa.TipoPlano as Plano
			FROM Paciente AS pa WITH(NOLOCK)
			WHERE pa.Telefone LIKE '11%'
				AND pa.TipoPlano = 'Ouro';
	END
GO

EXEC sp_buscaContatoPaciente @Ddd = '11', @Plano = 'Ouro';
