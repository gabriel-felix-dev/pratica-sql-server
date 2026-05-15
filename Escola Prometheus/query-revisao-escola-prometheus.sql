USE EscolaPrometheus;
GO

--01. Liste o nome do aluno, a data da matrícula e a descrição da avaliação para os casos em que o aluno obteve nota 
--    10 em alguma avaliação cujo tipo tem peso maior que 0.5.

SELECT	al.Nome as Aluno,
		ma.DataMatricula as DataMatriculaAluno,
		av.TituloDescritivo as DescricaoAvaliacao
	FROM Aluno AS al
		INNER JOIN Matricula AS ma
			ON ma.IdAluno = al.Id
		INNER JOIN MatriculaAvaliacao AS mv
			ON mv.IdMatricula = ma.Id
		INNER JOIN Avaliacao AS av
			ON av.Id = mv.IdAvaliacao
		INNER JOIN TipoAvaliacao AS ta
			ON ta.Id = av.IdTipoAvaliacao
	WHERE mv.Nota = 10 AND ta.Peso > 0.5;
			
--02. Liste o nome e a data de nascimento dos professores que lecionam disciplinas com carga horária 
--    igual ou superior a 80 horas e que tiveram alguma avaliação aplicada em 2024.

SELECT	DISTINCT
		pr.Nome as Professor,
		CAST(pr.DataNascimento AS DATE) as DataNascimentoProfessor
	FROM Professor AS pr
		INNER JOIN Disciplina AS di
			ON di.IdProfessor = pr.Id
		INNER JOIN Avaliacao AS av
			ON av.IdDisciplina = di.Id
	WHERE di.CargaHoraria >= 80 
		AND EXISTS (SELECT	1 FROM Professor AS pr2
								  INNER JOIN Disciplina AS di2
									  ON di2.IdProfessor = pr2.Id
								  INNER JOIN Avaliacao AS av2
									  ON av2.IdDisciplina = di2.Id
							   WHERE pr2.Id = pr.Id
								   AND YEAR(av.DataRealizacao) = 2024
				   );

--03. Liste o nome das disciplinas e seus respectivos professores para os casos em que 
--    nenhuma aprovação foi registrada até o momento.

SELECT	DISTINCT
		di.Nome as Disciplina,
		pr.Nome as ProfessorDisciplina
	FROM Disciplina AS di
		INNER JOIN Professor AS pr
			ON di.IdProfessor = pr.Id
		INNER JOIN MatriculaDisciplina AS md
			ON md.IdDisciplina = di.Id
		INNER JOIN StatusMatricula AS sm
			ON sm.Id = md.IdStatusMatricula
	WHERE NOT EXISTS (SELECT  1 FROM Disciplina AS di2				
									INNER JOIN MatriculaDisciplina AS md2
										ON md2.IdDisciplina = di2.Id
									INNER JOIN StatusMatricula AS sm2
										ON sm2.Id = md2.IdStatusMatricula
								WHERE di.Id = di2.Id
									AND sm2.Nome = 'Aprovação'
					 );





