--01. Identifique as consultas agendadas pelo Dr. Roberto Santos para pacientes residentes no estado de Sao Paulo (SP), 
--exibindo o nome do paciente, o documento do paciente, a data/hora do agendamento e o nome do médico.

SELECT	pa.Nome as Paciente, 
		pa.Documento as DocumentoPaciente, 
		CAST(co.DataHora AS DATE) as DataAgendamento, 
		me.Nome as Medico
	FROM Consulta AS co WITH(NOLOCK)
		INNER JOIN Medico AS me WITH(NOLOCK)
			ON me.Id = co.IdMedico
		INNER JOIN Paciente AS pa WITH(NOLOCK)
			ON pa.Id = co.IdPaciente
		INNER JOIN Endereco AS en WITH(NOLOCK)
			ON en.Id = pa.IdEndereco
		INNER JOIN Cidade AS ci WITH(NOLOCK)
			ON ci.Id = en.IdCidade
	WHERE me.Nome = 'Dr. Roberto Santos'
		AND ci.IdEstado = 1;

--18. Apresente a média de valor base das consultas agrupada pela categoria do plano de saúde e pelo status do atendimento, 
--desconsiderando consultas canceladas, apenas para clínicas parceiras sediadas no estado do Rio de Janeiro (RJ), 
--exibindo o plano de saúde, o status e a média calculada.

SELECT	pa.TipoPlano as Plano,
		sc.Nome as StatusAtendimento,
		CAST(ROUND(AVG(co.ValorBase),2) AS DECIMAL(10,2)) as MediaValorBaseConsulta		 
	FROM Consulta AS co WITH(NOLOCK)
		INNER JOIN StatusConsulta AS sc WITH(NOLOCK)
			ON sc.Id = co.IdStatusConsulta
		INNER JOIN Medico AS me WITH(NOLOCK)
			ON me.Id = co.IdMedico
		INNER JOIN Clinica AS cl WITH(NOLOCK)
			ON cl.Id = me.IdClinica
		INNER JOIN Endereco AS en WITH(NOLOCK)
			ON en.Id = cl.IdEndereco
		INNER JOIN Cidade AS ci WITH(NOLOCK)
			ON ci.Id = en.IdCidade
		INNER JOIN Paciente AS pa WITH(NOLOCK)
			ON pa.Id = co.IdPaciente
	WHERE sc.Nome <> 'Cancelada'
		AND ci.IdEstado = 2
	GROUP BY pa.TipoPlano, sc.Nome;

--20. Exiba o nome e o documento dos pacientes que realizaram mais de 3 consultas na modalidade presencial, 
--listando o nome do paciente, seu documento e a quantidade total de consultas presenciais.

SELECT  pa.Nome as Paciente,
		pa.Documento as DocumentoPaciente,
		COUNT(co.Id) as QuantidadeConsultasPresenciais
	FROM Paciente AS pa WITH(NOLOCK)
		INNER JOIN Consulta AS co WITH(NOLOCK)
			ON co.IdPaciente = pa.Id
	WHERE co.IdTipoAtendimento = 1
		AND co.IdStatusConsulta =3
	GROUP BY pa.Nome, pa.Id, pa.Documento
	HAVING COUNT(co.Id) > 3;

--35. Apresente os pacientes que residem no mesmo estado que a clínica da consulta identificada pelo código 'CS1001', 
--mostrando o nome do paciente, seu documento e o tipo do plano de saúde.

;WITH EstadoClinicaCS1001 AS (
							  SELECT ci.IdEstado as IdentificadorEstado
							      FROM Consulta AS co WITH(NOLOCK) 
								      INNER JOIN Medico AS me WITH(NOLOCK)
									      ON me.Id = co.IdMedico
									  INNER JOIN Clinica AS cl WITH(NOLOCK)
										  ON cl.Id = me.IdClinica
									  INNER JOIN Endereco AS en WITH(NOLOCK)
										  ON en.Id = cl.IdEndereco
									  INNER JOIN Cidade AS ci WITH(NOLOCK)
										  ON ci.Id = en.IdCidade
							      WHERE co.Codigo = 'CS1001'
                             )
SELECT  pa.Nome as Paciente,
        pa.Documento as PacienteDocumento,
        pa.TipoPlano as TipoPlanoDeSaude
    FROM Paciente AS pa WITH(NOLOCK)
        INNER JOIN Endereco AS pe WITH(NOLOCK)
            ON pe.Id = pa.IdEndereco
        INNER JOIN Cidade AS pc WITH(NOLOCK)
            ON pc.Id = pe.IdCidade
		CROSS JOIN (
					SELECT  sc.IdentificadorEstado 
					    FROM EstadoClinicaCS1001 AS sc
				   ) AS Temporaria
    WHERE pc.IdEstado = Temporaria.IdentificadorEstado;

--41. Liste o nome do médico, a especialidade, o nome do paciente e o tipo de plano de saúde para todos os atendimentos 
--realizados por via de telemedicina.

SELECT	me.Nome as Medico,
		es.Nome as Especialidade,
		pa.Nome as Paciente,
		pa.TipoPlano as TipoPlanoPaciente
	FROM Consulta AS co WITH(NOLOCK)
		INNER JOIN Medico AS me WITH(NOLOCK)
			ON me.Id = co.IdMedico
		INNER JOIN Especialidade AS es WITH(NOLOCK)
			ON es.Id = me.IdEspecialidade
		INNER JOIN Paciente AS pa WITH(NOLOCK)
			ON pa.Id = co.IdPaciente
	WHERE co.IdTipoAtendimento = 2;

--54. Para cada estado, exiba a UF e a quantidade total de médicos cadastrados que atendem em clínicas localizadas nele.

SELECT	es.UF as Estado,
		COUNT(me.IdClinica) as QuantidadeMedicos
	FROM Clinica AS cl WITH(NOLOCK)
		INNER JOIN Medico AS me WITH(NOLOCK)
			ON me.IdClinica = cl.Id
		INNER JOIN Endereco AS en WITH(NOLOCK)
			ON en.Id = cl.IdEndereco
		INNER JOIN Cidade AS ci WITH(NOLOCK)
			ON ci.Id = en.IdCidade
		INNER JOIN Estado AS es WITH(NOLOCK)
			ON es.Id = ci.IdEstado
	GROUP BY es.UF, es.Id;

--57. Liste os médicos cujos nomes contenham 'Roberto' ou 'Julia', exibindo o nome do médico, o CRM, a especialidade, 
--o nome da clínica e a cidade da clínica onde atuam.

SELECT	me.Nome as Medico,
		me.CRM as CRM,
		es.Nome as Especialidade,
		cl.Nome as Clinica,
		ci.Nome as Cidade
	FROM Clinica AS cl WITH(NOLOCK)
		INNER JOIN Medico AS me WITH(NOLOCK)
			ON me.IdClinica = cl.Id
		INNER JOIN Especialidade AS es WITH(NOLOCK)
			ON es.Id = me.IdEspecialidade
		INNER JOIN Endereco AS en WITH(NOLOCK)
			ON en.Id = cl.IdEndereco
		INNER JOIN Cidade AS ci WITH(NOLOCK)
			ON ci.Id = en.IdCidade
	WHERE me.Nome LIKE '%Roberto%' 
		OR me.Nome LIKE '%Julia%';

--65. Apresente o nome do paciente, a descrição de coparticipação ('Isento de Mensalidade' para Ouro, 
--'Desconto Parcial' para Prata, 'Sem Desconto' para Bronze) e a UF do estado de residência do paciente.

SELECT  pa.Nome as Paciente,
		pa.TipoPlano,
		CASE
			WHEN pa.TipoPlano = 'Ouro' THEN 'Isento de Mensalidade'
			WHEN pa.TipoPlano = 'Prata' THEN 'Desconto Parcial'
			ELSE 'Sem Desconto'
		END as DescricaoCoparticipacao,
		es.UF as EstadoResidencia
	FROM Paciente AS pa WITH(NOLOCK)
		LEFT JOIN Endereco AS en WITH(NOLOCK)
			ON en.Id = pa.IdEndereco
		LEFT JOIN Cidade AS ci WITH(NOLOCK)
			ON ci.Id = en.IdCidade
		LEFT JOIN Estado AS es WITH(NOLOCK)
			ON es.Id = ci.IdEstado;

--75. Liste os pacientes que realizaram pelo menos duas consultas consecutivas com médicos diferentes, 
--mas da mesma especialida.

SELECT  DISTINCT pa.Nome as Paciente
    FROM Paciente AS pa WITH(NOLOCK)
        INNER JOIN Consulta AS co1 WITH(NOLOCK)
            ON co1.IdPaciente = pa.Id
        INNER JOIN Medico AS me1 WITH(NOLOCK)
            ON me1.Id = co1.IdMedico
        INNER JOIN Consulta AS co2 WITH(NOLOCK)
            ON co2.IdPaciente = pa.Id
        INNER JOIN Medico AS me2 WITH(NOLOCK)
            ON me2.Id = co2.IdMedico
    WHERE me1.IdEspecialidade = me2.IdEspecialidade
        AND me1.Id <> me2.Id
        AND co2.DataHora > co1.DataHora
        AND NOT EXISTS (
						SELECT 1
							FROM Consulta AS co3 WITH(NOLOCK)
							WHERE co3.IdPaciente = pa.Id
								AND co3.DataHora > co1.DataHora
								AND co3.DataHora < co2.DataHora
                        );

--84. **(Gabriel Felix)** Crie uma estrutura temporária para consolidar os atendimentos da especialidade Ortopedia. 
--Popule a estrutura trazendo todas as consultas dessa especialidade. Atualize o status para 'Revisar' 
--apenas para consultas que foram canceladas. Exclua do relatório consolidado os atendimentos de médicos que não 
--possuem telefone cadastrado e apague a estrutura.

CREATE TABLE Relatorio(
	Id INT IDENTITY,
	IdConsulta INT NOT NULL,
	Medico VARCHAR(255) NOT NULL,
	Especialidade VARCHAR(255) NOT NULL,
	StatusConsulta VARCHAR(255) NOT NULL,
	CodigoConsulta VARCHAR(255) NOT NULL,
	DataHoraConsulta DATETIME NOT NULL

	CONSTRAINT PK_IdRelatorio PRIMARY KEY (Id)
);
GO

INSERT INTO Relatorio(IdConsulta, Medico, Especialidade, StatusConsulta, CodigoConsulta, DataHoraConsulta)
	SELECT  co.Id as IdConsulta,
			me.Nome as Medico,
			es.Nome as Especialidade,
			sc.Nome as StatusConsulta,
			co.Codigo as CodigoConsulta,
			co.DataHora as DataHoraConsulta
		FROM Consulta AS co WITH(NOLOCK)
			INNER JOIN StatusConsulta AS sc WITH(NOLOCK)
				ON sc.Id = co.IdStatusConsulta
			INNER JOIN Medico AS me WITH(NOLOCK)
				ON me.Id = co.IdMedico
			INNER JOIN Especialidade AS es
				ON es.Id = me.IdEspecialidade
		WHERE es.Nome = 'Ortopedia';
GO

UPDATE Relatorio
	SET StatusConsulta = 'Revisar'
	WHERE StatusConsulta = 'Cancelada';
GO

DELETE FROM re
	FROM Relatorio AS re WITH(NOLOCK)
	CROSS JOIN	(
				 SELECT  me.Nome as MedicosSemTelefone
					 FROM Medico AS me WITH(NOLOCK)
					 WHERE me.Telefone IS NULL
				) as Temporaria
	WHERE re.Medico IN (Temporaria.MedicosSemTelefone);
GO

DROP TABLE Relatorio;
GO
