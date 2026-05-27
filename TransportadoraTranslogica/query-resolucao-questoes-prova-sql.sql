SELECT * FROM Cidade;
SELECT * FROM Filial;
SELECT * FROM Viagem;
SELECT * FROM Motorista;
SELECT * FROM Cliente;

--1. Liste as cidades que possuem filiais cadastradas e o número de veículos vinculados a viagens com origem nessas filiais,
--exibindo apenas as cidades que possuem mais de 2 veículos distintos associados.

SELECT	ci.Nome as Cidade, -- Puxa o nome da cidade
		COUNT(DISTINCT vi.IdVeiculo) as TotalVeiculos -- Conta de forma distinta a quantidade de veiculos por viagem
	FROM Cidade AS ci -- Filtra a cidade, o objtivo da questão 
		INNER JOIN Endereco AS en -- Juntos endereço para chegar na Filial
			ON en.IdCidade = ci.Id
		INNER JOIN Filial AS fi -- Usamos a filial para chegar na Viagem
			ON fi.IdEndereco = en.Id
		INNER JOIN Viagem AS vi -- Vamos usar a viagem para contar a quantidade de veiculos
			ON vi.IdFilialOrigem = fi.Id
	GROUP BY ci.Nome -- Agrupa por Cidade a contagem
	HAVING COUNT(DISTINCT vi.IdVeiculo) > 2; -- filtra a quantidade da contagem para os que forem maior que dois
GO

--2. Liste as cargas com peso superior a 100 kg cujo valor declarado seja maior do que a média de valor declarado das cargas do mesmo tipo, exibindo o código da carga, o peso e o nome do cliente destinatário.
--3. Exiba o nome e o documento (CPF/CNPJ) de todos os clientes destinatários que possuem endereço cadastrado em cidades que não possuem nenhuma filial física da transportadora.
--4. Encontre os motoristas cuja CNH comece com '9' ou termine com '0' e que já realizaram viagens utilizando veículos com capacidade de peso superior a 10 toneladas, mostrando o nome do motorista e a placa do veículo.
--5. Liste as cargas do tipo 'Fragil' embaladas com 'Isopor' ou 'Plastico Bolha' destinadas a clientes que moram no estado de Sao Paulo ('SP'), trazendo o código da carga, o nome do cliente e a cidade de residência.
--6. Liste o código, o peso e o valor declarado de todas as cargas que ainda não foram associadas a nenhuma viagem, cujo status seja 'Pendente' e que pertençam a clientes que residem no mesmo estado da filial 'Filial Sao Paulo Centro'.
--7. Exiba os endereços de entrega específicos das cargas localizados no estado de Sao Paulo (UF = 'SP') cujo bairro seja nulo e que receberam pelo menos uma entrega de carga do tipo 'Perigosa'.
--8. Liste as viagens (ID, data de saída e quilometragem inicial) em que a quilometragem final não foi preenchida, mas a data de chegada está registrada (inconsistência de dados).
--9. Mostre as cargas do tipo "Perigosa" que possuem valor declarado superior a R$ 5.000,00, mas estão sem número ONU ou sem classe de risco cadastrada.

--10. Calcule a média de peso e de valor declarado das cargas agrupada pelo nome da cidade do destinatário, exibindo apenas cidades com média de peso superior a 150 kg.
--11. Mostre a quantidade total de viagens realizadas por motorista em veículos cuja capacidade de peso seja maior do que a média geral de capacidade da frota, exibindo o nome do motorista e o total de viagens.
--12. Mostre o número de clientes que possuem endereço cadastrado no estado do Rio de Janeiro e que já receberam cargas do tipo 'Perigosa' com valor declarado superior a R$ 2.000,00.
--13. Qual a maior e a menor quilometragem inicial registrada entre os veículos que realizaram viagens que passaram por paradas no estado do Paraná?
--14. Exiba o valor total declarado em mercadorias para todas as cargas entregues agrupado pelo modelo do veículo utilizado na viagem, listando apenas os modelos que somaram mais de R$ 50.000,00 em entregas.
--15. Encontre o total de quilômetros rodados acumulados por veículo, somando a diferença entre `QuilometragemFinal` e `QuilometragemInicial` das viagens já concluídas.
--16. Calcule a média de peso das cargas entregues no estado do Parana, desconsiderando cargas canceladas.
--17. Conte a quantidade de cargas que possuem o material de embalagem nulo mesmo sendo do tipo 'Fragil' e que estão associadas a viagens com destino final ao estado do Rio Grande do Sul.
--18. Calcule a quantidade de paradas cadastradas por viagem que passou pelo estado de Minas Gerais, trazendo o ID da viagem, a data de saída e a contagem de paradas.

--19. Mostre a quantidade total de cargas com status de envio 'Entregue' agrupada pelo estado da cidade do endereço do cliente, exibindo apenas estados com mais de 50 entregas, ordenados do maior para o menor.
--20. Liste a quantidade de motoristas cadastrados cuja CNH possui final par (último dígito) e que já realizaram viagens com veículos Mercedes Benz.
--21. Exiba a média de peso das cargas agrupada pelo seu tipo de carga, considerando apenas cargas cujos destinatários residem no mesmo estado da filial de origem da viagem.
--22. Liste os modelos de veículos cadastrados e a quantidade de veículos de cada modelo que realizaram viagens que passaram por cidades com mais de 5 endereços cadastrados.
--23. Mostre o total de viagens concluídas que iniciaram a partir de filiais localizadas no estado de São Paulo e que tiveram mais de 500 km rodados.
--24. Agrupe as viagens por mês e ano da data de saída, mostrando o total de viagens realizadas em cada período.
--25. Apresente a soma do valor declarado das cargas agrupada por tipo de carga e status de envio, filtrando apenas valores totais maiores que zero.
--26. Liste os bairros e a quantidade de clientes que moram neles, trazendo apenas os bairros que possuem clientes com cargas perigosas pendentes de envio.
--27. Mostre a soma das capacidades de peso dos veículos agrupada pelo modelo do veículo, listando apenas os modelos que participaram de viagens com motoristas que têm telefone cadastrado.

--28. Liste as cidades que possuem mais de 5 endereços cadastrados que serviram como destino de entregas de cargas do tipo 'Fragil'.
--29. Exiba os clientes que possuem mais de 3 cargas associadas no status 'Pendente' com peso individual acima da média geral de peso de todas as cargas.
--30. Liste as filiais que figuram como origem em viagens cuja quilometragem média rodada é superior a 600 km, exibindo o nome da filial e a quilometragem média.
--31. Encontre os motoristas que possuem mais de 5 viagens concluídas conduzindo veículos de capacidade de carga superior a 15 toneladas.
--32. Liste os tipos de carga que possuem média de valor declarado superior a R$ 2.000,00 considerando apenas entregas concluídas no estado de Santa Catarina ou Parana.
--33. Liste as cidades de parada que foram visitadas em viagens em andamento que transportam cargas do tipo 'Perigosa'.
--34. Apresente os veículos que possuem média de quilômetros rodados por viagem superior a 500 km, considerando apenas viagens concluídas.
--35. Identifique os estados que possuem mais de 15 clientes associados a endereços localizados neles e que já receberam pelo menos uma carga do tipo 'Fragil'.
--36. Liste as viagens que possuem mais de 2 paradas intermediárias registradas na tabela `ParadaViagem`.

--37. Mostre o nome dos clientes destinatários que receberam cargas do tipo 'Fragil' contendo 'Caixa de Madeira' como material de embalagem, exibindo o nome do cliente, o código da carga e o nome da cidade do endereço do cliente.
--38. Exiba a placa do veículo, o modelo, o nome do motorista e a quantidade total de paradas intermediárias que cada veículo realizou em viagens concluídas.
--39. Liste as filiais que possuem filiais no mesmo estado que a filial 'Filial Sao Paulo Centro' (excluindo ela própria), exibindo o nome da filial, a cidade correspondente e a UF.
--40. Mostre as cidades que receberam entregas de cargas perigosas, trazendo o nome da cidade, o estado (UF) e o número total de cargas perigosas entregues nelas, ordenado pelo total do maior para o menor.
--41. Exiba as viagens que possuem paradas na cidade de 'Belo Horizonte' ou 'Porto Alegre', mostrando a placa do veículo, o nome do motorista, a data de saída da viagem e a ordem que aquela parada ocupava na rota.
--42. Mostre as cargas que foram associadas a uma parada de viagem, exibindo o código da carga, a data de saída da viagem e o nome da cidade de entrega.
--43. Liste os clientes e os detalhes do seu endereço residencial, trazendo inclusive clientes que não possuem endereço associado.
--44. Apresente a placa do veículo, o modelo e o nome da cidade da filial de origem para as viagens concluídas que rodaram mais de 500 km (calculados como a diferença de quilometragem final e inicial).
--45. Mostre as cargas destinadas a clientes residentes no estado de 'Minas Gerais' que foram entregues em uma cidade diferente da residência do cliente, trazendo o código da carga, o nome do cliente e a cidade real de entrega.

--46. Mostre o código da carga, o nome do cliente destinatário, a cidade de entrega e a sigla do estado correspondente, apenas para cargas cujo valor do frete calculado dinamicamente seja maior que R$ 300,00.
--47. Liste as viagens concluídas indicando a placa do veículo, o nome do motorista, a filial de origem e a cidade dessa filial, filtrando por viagens que passaram por mais de 2 cidades distintas.
--48. Exiba as cargas que estão em trânsito, mostrando o código da carga, o nome do motorista da viagem, a placa do veículo utilizado e a cidade onde ocorrerá a entrega.
--49. Liste as paradas de viagem indicando o nome da cidade, o nome do estado, o nome do motorista e o modelo do veículo usado na viagem, ordenado pela ordem da parada dentro de cada viagem.
--50. Exiba os clientes mostrando o nome, o logradouro, a cidade e a sigla do estado em que residem, trazendo apenas aqueles que possuem cargas pendentes com valor declarado acima de R$ 5.000,00.
--51. Liste as cargas frágeis mostrando o código, o nome do cliente destinatário, a cidade da parada de entrega e a sigla do estado correspondente, filtrando por cargas cujo peso esteja acima da média geral das cargas frágeis (do tipo 'Fragil').
--52. Apresente as viagens indicando o nome do motorista, a cidade da filial de origem, a UF do estado de origem e a cidade da primeira parada da viagem para manifestos que transportaram cargas perigosas.
--53. Exiba as cargas perigosas que estão em trânsito indicando o código da carga, a placa do veículo, a filial de origem da viagem e a cidade de destino final da viagem.
--54. Mostre a soma dos valores declarados das cargas agrupada pelo nome da filial de origem da viagem e o estado da cidade de destino da parada.

--55. Liste as cargas que possuem peso superior ao peso médio de todas as cargas da base e cujo cliente destinatário resida em um estado diferente do estado da filial de origem do transporte.
--56. Encontre as cargas do tipo 'Fragil' cujo valor declarado seja menor que a média de valor declarado de todas as cargas padrão (do tipo 'Padrao') que possuem o mesmo status de envio.
--57. Encontre os clientes que residem no mesmo estado que o cliente de ID = 1 e que já receberam cargas perigosas com certificado ONU preenchido.
--58. Liste os veículos que nunca iniciaram viagens a partir de filiais localizadas no estado de Minas Gerais ('MG').
--59. Encontre os motoristas que participaram de viagens que iniciaram na filial de ID = 1 e que conduziram veículos cuja capacidade de carga seja a maior entre os veículos daquela filial.
--60. Liste as viagens concluídas que tiveram uma quilometragem total rodada superior à média de quilômetros rodados de todas as viagens concluídas.
--61. Encontre o cliente com a carga de maior valor declarado cadastrada no sistema.
--62. Liste as paradas de viagem da viagem que registrou a maior quilometragem final acumulada entre todas as viagens concluídas.
--63. Identifique os motoristas que conduziram viagens cujo veículo utilizado possui a menor capacidade de peso da frota e que transportaram cargas frágeis com embalagem de 'Caixa de Madeira'.

--64. Exiba o nome dos clientes e, ao lado, o total de cargas que eles possuem cadastradas, trazendo apenas clientes com mais de 2 cargas e cujas cargas tenham peso médio acima de 200 kg.
--65. Liste as cidades cadastradas e a quantidade de filiais que existem em cada uma delas, trazendo também a quantidade total de viagens que se iniciaram nessas filiais.
--66. Mostre os motoristas e a quantidade de viagens em andamento que cada um possui atualmente, exibindo apenas motoristas com viagens ativas que já duram mais de 3 dias.
--67. Exiba a placa dos veículos e a quantidade total de paradas realizadas por viagens desse veículo em cidades do estado de São Paulo.
--68. Liste os estados e o número total de clientes residindo em cada um deles, ordenando do estado com mais clientes para o com menos, excluindo estados sem clientes.
--69. Liste a placa dos veículos e o percentual de capacidade que as cargas de sua viagem ativa ocupam.
--70. Exiba a quantidade total de viagens concluídas e a média de paradas por viagem.
--71. Exiba o código das cargas e a diferença entre o seu peso e o peso médio do seu respectivo tipo de carga, filtrando por cargas que estão acima da média de sua categoria.
--72. Mostre cada cidade e o valor total acumulado de frete das cargas destinadas a ela.

--73. Exiba o código da carga, seu peso e uma coluna chamada 'Faixa de Peso' (Leve, Média, Pesada) baseada no peso da carga, trazendo apenas as cargas que estão associadas a viagens ativas.
--74. Exiba o ID da viagem, a data de saída e a situação da viagem: 'Concluida' ou 'Em Andamento', exibindo apenas viagens que utilizaram veículos com capacidade acima de 10 toneladas.
--75. Liste o nome dos motoristas, a CNH e a situação do telefone: 'Sem Contato' ou o próprio telefone, exibindo apenas motoristas que possuem CNH com final '0'.
--76. Exiba o código da carga, o tipo e a classificação de risco: se for do tipo 'Perigosa' exiba a classe de risco, caso contrário, exiba 'Risco Inexistente', limitando a cargas entregues.
--77. Liste os clientes e classifique o documento como 'CNPJ' ou 'CPF', trazendo apenas clientes residentes no estado do Rio de Janeiro ('RJ') que não possuem telefone cadastrado.
--78. Liste todas as cargas exibindo o código, o peso, o valor declarado e o valor do frete calculado dinamicamente de acordo com a regra de negócio (Padrao, Fragil, Perigosa).
--79. Calcule o valor total de frete acumulado que a transportadora faturou por estado de destino, utilizando o cálculo de frete baseado no tipo de carga dentro de uma soma condicional.
--80. Mostre as viagens indicando a placa do veículo e a classificação de aproveitamento da capacidade do veículo: 'Subutilizado' (se a soma dos pesos das cargas da viagem for inferior a 30% da capacidade do veículo), 'Adequado' (30% a 80%) ou 'Alerta de Sobrecarga' (mais de 80%).
--81. Apresente as paradas de viagem indicando a classificação de tempo gasto na rota: se a data de chegada da parada estiver preenchida, calcule a diferença de horas e classifique como 'Rapido' (até 6h), 'Normal' (6 a 12h) ou 'Atrasado' (mais de 12h).

--82. Liste todos os veículos que realizaram viagens que passaram por cidades do estado do Rio Grande do Sul ('RS') transportando cargas de valor declarado superior a R$ 5.000,00.
--83. Exiba as cidades visitadas por viagens que iniciaram na filial de Sao Paulo Centro ('Filial Sao Paulo Centro') e que transportaram cargas do tipo 'Perigosa' com classe de risco 'Inflamavel'.
--84. Liste as cargas destinadas a clientes que moram no estado de São Paulo cujo endereço de entrega esteja localizado no estado do Paraná e que pesem mais de 200 kg.
--85. Liste os motoristas que conduziram viagens que tiveram mais de 700 km de distância total percorrida e que conduziram veículos do modelo 'Scania R450'.
--86. Exiba as filiais que enviaram cargas do tipo 'Perigosa' com número ONU cadastrado e que estão com status 'Pendente'.
--87. Identifique auditoria de segurança: liste as viagens que transportaram cargas do tipo 'Perigosa' e cargas do tipo 'Fragil' no mesmo manifesto/caminhão (viagem).
--88. Identifique as viagens que passaram pela cidade de 'Curitiba' em sua rota antes de descarregar uma carga na cidade de 'Porto Alegre'.
--89. Liste os motoristas que estão atualmente conduzindo viagens ativas iniciadas há mais de 5 dias em relação à data atual e que possuem telefone cadastrado.
--90. Liste as cidades que figuram como paradas em rotas de viagem, mas que não possuem nenhuma filial física da transportadora instalada nelas, exibindo apenas as cidades que receberam entregas concluídas.
