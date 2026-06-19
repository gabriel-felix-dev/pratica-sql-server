SELECT * FROM Estado;

-- ## Bloco 1 (Q01–Q09)

-- 01. Identifique as consultas agendadas pelo Dr. Roberto Santos para pacientes residentes no estado de Sao Paulo (SP), 
-- exibindo o nome do paciente, o documento do paciente, a data/hora do agendamento e o nome do médico.

SELECT	pa.Nome as Paciente,
		pa.Documento as DocumentoPaciente,
		co.DataHora as DataHoraAgendamento,
		me.Nome as Medico
	FROM Medico AS me WITH(NOLOCK)
		INNER JOIN Consulta AS co WITH(NOLOCK)
			ON me.Id = co.IdMedico
		INNER JOIN Paciente AS pa WITH(NOLOCK)
			ON co.IdPaciente = pa.Id
		INNER JOIN Endereco AS en WITH(NOLOCK)
			ON en.Id = pa.IdEndereco
		INNER JOIN Cidade AS ci WITH(NOLOCK)
			ON ci.Id = en.IdCidade
	WHERE ci.IdEstado = 1
		AND me.Nome = 'Dr. Roberto Santos';

-- 02. Liste as clínicas localizadas no estado do Rio de Janeiro (RJ) que possuem médicos cadastrados na especialidade de Ortopedia, exibindo o nome da clínica, seu CNPJ, o nome do médico e a especialidade.
-- 03. Exiba o nome e o CPF/CNPJ dos pacientes que residem in cidades onde a operadora de saúde não possui nenhuma clínica credenciada.
-- 04. Liste as clínicas parceiras que possuem médicos cadastrados sem número de telefone informado e que possuem consultas agendadas, exibindo o nome do médico, seu CRM e o nome da clínica.
-- 05. Apresente o código da consulta, a data do agendamento, o nome do paciente, a UF do paciente e o nome do médico para consultas com valor base superior a R$ 300,00 realizadas por pacientes residentes no estado de Sao Paulo (SP) ou Minas Gerais (MG).
-- 06. Liste os médicos da especialidade de Dermatologia que realizaram ou agendaram consultas via telemedicina para pacientes residentes no estado de Sao Paulo (SP), exibindo o nome do médico, seu CRM, o nome do paciente atendido e o nome da clínica do médico.
-- 07. Apresente os nomes das clínicas que oferecem atendimento na especialidade de Ginecologia, incluindo o logradouro, o bairro e a cidade onde a clínica está instalada.
-- 08. Liste os pacientes sem telefone cadastrado que possuem consultas marcadas in Curitiba, trazendo o nome do paciente e a data do agendamento.
-- 09. Identifique os médicos que possuem consultas canceladas pertencentes a clínicas no estado de Sao Paulo (SP), exibindo o nome do médico, seu CRM, o nome de sua clínica e o código da consulta cancelada.

-- ---

-- ## Bloco 2 (Q10–Q18)

-- 10. Calcule a quantidade de pacientes cadastrados agrupada pelo tipo do plano de saúde e pelo estado (UF) de residência do paciente, exibindo a UF, o plano de saúde e o respectivo total.
-- 11. Apresente a média do valor base das consultas presenciais por médico e sua respectiva especialidade, exibindo o nome do médico, a especialidade e a média calculada, apenas para médicos vinculados a clínicas parceiras sediadas no estado de Sao Paulo (SP).
-- 12. Calcule o faturamento total em valores base de todas as consultas finalizadas agrupado pela cidade onde a clínica parceira está localizada.
-- 13. Apresente o número total de consultas agendadas por paciente residente no estado de Minas Gerais, exibindo o nome do paciente e a quantidade de consultas.
-- 14. Calcule o valor médio cobrado como taxa de consultório para consultas de caráter físico realizadas no estado de Sao Paulo.
-- 15. Calcule a quantidade de consultas virtuais realizadas agrupadas pela plataforma utilizada e pelo estado (UF) da clínica de origem do médico, exibindo o nome da plataforma, a UF da clínica e o total de consultas.
-- 16. Determine a soma total das taxas de anestesia cobradas em procedimentos complexos por médico cirurgião responsável, apenas para pacientes dos planos Prata ou Bronze, exibindo o nome do médico, o plano de saúde do paciente e a soma total.
-- 17. Calcule a quantidade de atendimentos realizados por especialidade médica no estado do Rio de Janeiro.
-- 18. Apresente a média de valor base das consultas agrupada pela categoria do plano de saúde e pelo status do atendimento, desconsiderando consultas canceladas, apenas para clínicas parceiras sediadas no estado do Rio de Janeiro (RJ), exibindo o plano de saúde, o status e a média calculada.

-- ---

-- ## Bloco 3 (Q19–Q27)

-- 19. Mostre o nome dos médicos que possuem um valor base médio de consultas superior a R$ 200,00, desconsiderando atendimentos cancelados.
-- 20. Exiba o nome e o documento dos pacientes que realizaram mais de 3 consultas na modalidade presencial, listando o nome do paciente, seu documento e a quantidade total de consultas presenciais.
-- 21. Apresente as cidades que possuem mais de 2 clínicas credenciadas cadastradas no sistema.
-- 22. Liste as especialidades médicas que registraram mais de 5 consultas no mês de maio de 2026, exibindo o nome da especialidade e a quantidade total de consultas.
-- 23. Identifique as clínicas que tiveram mais de 4 consultas concluídas e cuja soma do valor base das consultas supere R$ 1.000,00, exibindo o nome da clínica, a quantidade de consultas realizadas e o faturamento total acumulado.
-- 24. Apresente os pacientes que gastaram um montante superior a R$ 500,00 somando o valor base de todas as suas consultas realizadas, exibindo o nome do paciente e o valor total acumulado.
-- 25. Liste as cidades que possuem mais de 3 pacientes beneficiários com plano de saúde da categoria Ouro, exibindo o nome da cidade e a quantidade total desses pacientes.
-- 26. Identifique os médicos que possuem mais de 2 consultas em estado pendente aguardando atendimento, exibindo o nome do médico e a quantidade total de agendamentos pendentes.
-- 27. Mostre as siglas dos estados que possuem mais de 5 pacientes cadastrados, exibindo a sigla do estado e a quantidade total de pacientes residentes.

-- ---

-- ## Bloco 4 (Q28–Q36)

-- 28. Liste os pacientes que realizaram consultas com qualquer médico da especialidade de Ortopedia, trazendo nome e documento do paciente.
-- 29. Liste as clínicas que possuem atendimentos finalizados na modalidade de procedimento complexo, exibindo o nome da clínica, o CNPJ e a cidade onde está localizada.
-- 30. Identifique os médicos cadastrados que nunca realizaram nenhuma consulta por via online de telemedicina, mostrando o nome do médico, o CRM e o telefone de contato.
-- 31. Apresente os pacientes que nunca tiveram nenhuma de suas consultas canceladas, exibindo o nome do paciente e o documento cadastrado.
-- 32. Liste os médicos que atendem em clínicas localizadas na cidade de Rio de Janeiro, exibindo o nome do médico, seu CRM e o telefone de contato.
-- 33. Exiba o código, o paciente e o valor base de todas as consultas que possuem um valor base estritamente maior do que a média geral de valor base de todas as consultas do sistema.
-- 34. Identifique os médicos cujos números de CRM não contêm a sigla do estado onde a sua clínica está localizada, mostrando o nome do médico, o CRM e o telefone de contato.
-- 35. Apresente os pacientes que residem no mesmo estado que a clínica da consulta identificada pelo código 'CS1001', mostrando o nome do paciente, seu documento e o tipo do plano de saúde.
-- 36. Liste as clínicas parceiras sediadas no estado do Rio de Janeiro (RJ) que possuem médicos cadastrados sem número de telefone celular informado, exibindo o nome da clínica, o CNPJ e a UF correspondente.

-- ---

-- ## Bloco 5 (Q37–Q45)

-- 37. Mostre o nome do paciente, a cidade onde ele reside, o nome do médico e a especialidade para todas as consultas físicas realizadas.
-- 38. Apresente o nome do paciente, o nome da clínica, a cidade da clínica e a especialidade médica para todos os procedimentos complexos.
-- 39. Exiba o nome da clínica, o nome da cidade, a sigla do estado e a quantidade total de médicos vinculados a cada uma delas.
-- 40. Identifique as consultas em que o paciente precisou se deslocar para realizar o atendimento em uma clínica localizada em outro estado (UF diferente da residência do paciente), mostrando o código da consulta, o nome do paciente, o nome do médico e o nome da clínica.
-- 41. Liste o nome do médico, a especialidade, o nome do paciente e o tipo de plano de saúde para todos os atendimentos realizados por via de telemedicina.
-- 42. Mostre o nome do paciente, a categoria do seu plano, a clínica de atendimento e o valor base para todas as consultas realizadas na cidade de Campinas.
-- 43. Apresente o nome do médico, o CNPJ da clínica, o CPF/CNPJ do paciente e a data do agendamento para todas as consultas que ainda estão com atendimento pendente.
-- 44. Liste a especialidade médica, o nome do paciente, a cidade onde ele reside e o status das consultas para todos os pacientes que possuem o plano Bronze.
-- 45. Exiba o nome do paciente, o nome do médico, a clínica credenciada e a especialidade médica para todas as consultas marcadas na cidade de Curitiba.

-- ---

-- ## Bloco 6 (Q46–Q54)

-- 46. Apresente o nome de cada paciente e a quantidade total de consultas que ele realizou com status finalizado.
-- 47. Para cada médico credenciado, exiba o nome do profissional e o maior valor base registrado entre suas consultas.
-- 48. Mostre o nome de cada clínica credenciada e o valor base médio das consultas que ocorreram em suas instalações.
-- 49. Para cada especialidade médica, exiba o nome da especialidade e a soma total de valores base pagos por pacientes do plano de saúde Ouro.
-- 50. Apresente a lista de pacientes que possuem consultas registradas, exibindo nome, plano e o percentual de consultas canceladas em relação ao total de agendamentos de cada um.
-- 51. Exiba o nome do médico, a especialidade e a quantidade de pacientes distintos atendidos por ele.
-- 52. Liste o nome das cidades cadastradas no sistema e a quantidade total de pacientes que residem em cada uma delas.
-- 53. Mostre o código da consulta, o nome do paciente e a diferença entre o valor base desta consulta e a média de valor base das consultas do mesmo plano de saúde do paciente.
-- 54. Para cada estado, exiba a UF e a quantidade total de médicos cadastrados que atendem em clínicas localizadas nele.

-- ---

-- ## Bloco 7 (Q55–Q63)

-- 55. Liste as consultas marcadas para o mês de maio de 2026, exibindo o código da consulta e o nome do mês por extenso em português.
-- 56. Identifique os pacientes cujo CPF/CNPJ inicia com o dígito '1' ou termina com o número '4' que tenham pelo menos uma consulta realizada, exibindo o nome do paciente, o documento e a cidade de residência.
-- 57. Liste os médicos cujos nomes contenham 'Roberto' ou 'Julia', exibindo o nome do médico, o CRM, a especialidade, o nome da clínica e a cidade da clínica onde atuam.
-- 58. Apresente as consultas presenciais agendadas no mês de maio de 2026 com valor base superior a R$ 300,00, exibindo o código da consulta, a data e o valor base.
-- 59. Liste os pacientes e os telefones de contato, substituindo campos vazios por 'Nao Informado', exibindo também o nome do médico que realizou seu último atendimento.
-- 60. Identifique as consultas agendadas no primeiro semestre de 2026 (de janeiro a junho) com cobrança de taxa de insumos, exibindo o código da consulta, a data de agendamento, o médico responsável, sua especialidade e o valor da taxa de insumos.
-- 61. Liste os médicos cujos números de CRM terminam com os dígitos '5' ou '9', exibindo o nome do médico, o CRM, a especialidade e o nome da clínica onde atuam.
-- 62. Liste os pacientes do plano Ouro com seus respectivos endereços completos, exibindo o nome do paciente, o logradouro, o número, a cidade e a sigla do estado (UF).
-- 63. Liste as consultas presenciais que tiveram valor base entre R$ 200,00 e R$ 400,00, exibindo o código da consulta, o nome do paciente, a data de agendamento e o valor base.

-- ---

-- ## Bloco 8 (Q64–Q72)

-- 64. Classifique as consultas com base no valor base ('Alto' para >= R$ 500,00, 'Medio' para >= R$ 150,00 e < 500,00, 'Baixo' para < R$ 150,00), exibindo a classificação calculada, o código da consulta, o nome do paciente e a cidade onde o paciente reside.
-- 65. Apresente o nome do paciente, a descrição de coparticipação ('Isento de Mensalidade' para Ouro, 'Desconto Parcial' para Prata, 'Sem Desconto' para Bronze) e a UF do estado de residência do paciente.
-- 66. Exiba o nome dos médicos, a classificação de contato ('Sem Telefone Cadastrado' para nulo, 'Contato Ativo' para preenchido) e o nome da clínica onde o médico atende.
-- 67. Liste as consultas exibindo o código da consulta, o status e a tradução do status para o português: 'Pendente', 'Confirmada', 'Realizada' ou 'Cancelada'.
-- 68. Classifique as clínicas por porte com base no número de médicos vinculados a elas: 'Grande' se possuir 3 ou mais médicos, 'Media' se possuir de 1 a 2 médicos, e 'Pequena' se não houver médicos.
-- 69. Classifique os pacientes de acordo com o DDD de seu número de telefone: exiba 'Capital SP' para telefones iniciados com '(11)', 'Interior SP' para telefones iniciados com '(19)', ou 'Outra Regiao' para outros DDDs ou caso o telefone não esteja cadastrado.
-- 70. Apresente as consultas exibindo o código, o meio de atendimento (nome da plataforma de telemedicina se for online, ou 'Atendimento Presencial' se for física) e a cidade de residência do paciente.
-- 71. Identifique o estado de origem do CRM do médico com base na sigla estadual contida no próprio texto do CRM (ex: 'SP', 'RJ', 'PR').
-- 72. Exiba as consultas e indique a situação temporal ('Passado' ou 'Futuro') tendo como base o dia 1 de junho de 2026, mostrando o código da consulta, a situação temporal, a especialidade médica e a UF da clínica parceira.

-- ---

-- ## Bloco 9 (Q73–Q81)

-- 73. Encontre os pacientes que já realizaram consultas com todos os médicos da clínica localizada na cidade de Sao Paulo.
-- 74. Identifique os médicos cuja média de valor base de suas consultas é superior à média de valor base de todas as consultas daquela mesma especialidade.
-- 75. Liste os pacientes que realizaram pelo menos duas consultas consecutivas com médicos diferentes, mas da mesma especialidade.
-- 76. Apresente as clínicas cuja soma dos valores base das consultas concluídas em suas instalações seja maior do que a média de faturamento geral de todas as clínicas credenciadas.
-- 77. Mostre os pacientes cujo valor final de coparticipação total acumulada é maior que a média de coparticipação dos pacientes residentes no seu mesmo estado.
-- 78. Identifique os médicos que possuem o maior volume de consultas finalizadas dentro da clínica onde atuam.
-- 79. Liste as especialidades médicas onde o maior valor base registrado entre suas consultas seja menor do que R$ 500,00.
-- 80. Encontre os pacientes que realizaram consultas apenas com médicos cujas clínicas associadas ficam no mesmo estado onde o paciente reside.
-- 81. Mostre os médicos que já atenderam a pelo menos um paciente de cada categoria de plano de saúde (Bronze, Prata e Ouro).

-- ---

-- ## Bloco 10 (Q82–Q90)

-- 82. **(Carlos Saldanha)** Crie uma estrutura para armazenar temporariamente um relatório de atendimentos de alto custo do plano Ouro. Popule essa estrutura com as consultas concluídas de pacientes com esse plano cujo valor base seja igual ou maior a R$ 500,00. Em seguida, atualize a situação dessas consultas na estrutura para 'Auditado'. Delete da estrutura os registros de pacientes que residam na cidade de Sao Paulo e, por fim, descarte a estrutura do relatório.
-- 83. **(Emmanuel Uchoa)** Crie uma estrutura para armazenar o log de consultas por telemedicina de pacientes com o plano Bronze. Inicialize a estrutura inserindo todas as consultas online desses pacientes. Ajuste os dados aumentando a taxa de plataforma em 10% para todas as consultas do mês de maio de 2026. Exclua da estrutura os registros vinculados a clínicas localizadas no Rio de Janeiro e remova a estrutura do banco.
-- 84. **(Gabriel Felix)** Crie uma estrutura temporária para consolidar os atendimentos da especialidade Ortopedia. Popule a estrutura trazendo todas as consultas dessa especialidade. Atualize o status para 'Revisar' apenas para consultas que foram canceladas. Exclua do relatório consolidado os atendimentos de médicos que não possuem telefone cadastrado e apague a estrutura.
-- 85. **(Gabriel Mercês)** Crie uma estrutura para listar as clínicas localizadas no estado de Sao Paulo. Insira todas as clínicas desse estado na estrutura. Atualize a coluna de situação das clínicas na estrutura para 'Vistoriada' para aquelas instaladas na cidade de Sao Paulo. Remova da lista as clínicas cujos endereços não possuem CEP informado e, ao final, descarte a estrutura.
-- 86. **(Marcelo Jacinto)** Crie uma estrutura para gerenciar os médicos que possuem consultas em situação pendente. Popule a estrutura com esses profissionais. Atualize a informação de telefone dos médicos para 'Verificar' apenas para aqueles que estão com o campo em branco. Exclua da estrutura os médicos que não pertencem à especialidade de Clínica Geral e descarte a estrutura.
-- 87. **(Nilvan Silvano)** Crie uma estrutura para listar os pacientes de plano Prata residentes no Rio de Janeiro. Insira todos os pacientes com esse plano que moram nesse estado. Atualize o telefone desses pacientes inserindo o prefixo '9' no início do número na estrutura. Remova da estrutura os pacientes que não possuem nenhuma consulta agendada e limpe a estrutura do banco.
-- 88. **(Rodrigo Diniz)** Crie uma estrutura temporária para armazenar os procedimentos complexos da especialidade Ginecologia. Inicialize a estrutura com os agendamentos desse tipo. Atualize as taxas de anestesia reduzindo-as em 5% para procedimentos realizados em maio de 2026. Delete da estrutura os procedimentos cujos pacientes possuem nomes iniciados com a letra 'A' e elimine a estrutura.
-- 89. **(Victor Leite)** Crie uma estrutura para acompanhar os atendimentos agendados com o Dr. Roberto Santos. Insira na estrutura todas as consultas sob responsabilidade deste médico. Atualize os valores base dessas consultas aumentando-os em 15% na estrutura apenas para agendamentos com status pendente. Remova os registros de pacientes que possuem plano de saúde Bronze e exclua a estrutura.
-- 90. **(Vinicius Souza)** Crie uma estrutura para auditar procedimentos complexos que foram cancelados. Inicialize a estrutura trazendo todos os atendimentos desse tipo e status. Atualize o valor da taxa de anestesia para zero para todos os registros da estrutura. Exclua do relatório os procedimentos cujo valor base original seja menor que R$ 500,00 e remova a estrutura do banco.