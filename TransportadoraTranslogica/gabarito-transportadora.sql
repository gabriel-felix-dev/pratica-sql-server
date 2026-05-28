USE TransportadoraTransLogica;
GO

-- Q1
SELECT	ci.Nome as 'Cidade',
		COUNT(DISTINCT ve.Id) as 'Quantidade de veículos'
	FROM Viagem AS vi
		INNER JOIN Filial AS fi
			ON vi.IdFilialOrigem = fi.Id
		INNER JOIN Endereco AS en
			ON fi.IdEndereco = en.Id
		INNER JOIN Cidade AS ci
			ON en.IdCidade = ci.Id
		INNER JOIN Veiculo AS ve
			ON vi.IdVeiculo = ve.Id
	GROUP BY ci.Nome
	HAVING COUNT(DISTINCT ve.Id) > 2;
GO

-- Q2
SELECT	ca.Codigo as CodigoCarga,
		ca.Peso as Peso,
		cl.Nome as Cliente
	FROM Carga AS ca
		JOIN Cliente AS cl
			ON ca.IdCliente = cl.Id
	WHERE ca.ValorDeclarado > (SELECT AVG(cg.ValorDeclarado)
									FROM Carga AS cg
									WHERE cg.IdTipoCarga = ca.IdTipoCarga
							  )
		  AND ca.Peso > 100;
GO

-- Q3
SELECT  DISTINCT cl.Nome as 'Nome do Cliente',
        cl.Documento as 'CPF/CNPJ'
    FROM Carga AS cg
        INNER JOIN Cliente AS cl
            ON cl.Id = cg.IdCliente
        INNER JOIN Endereco AS ed1
            ON ed1.Id = cl.IdEndereco
    WHERE NOT EXISTS (SELECT  1
                        FROM Filial AS fl
                            INNER JOIN Endereco AS ed
                                ON ed.Id = fl.IdEndereco
                        WHERE ed.IdCidade = ed1.IdCidade);
GO

-- Q4
SELECT  DISTINCT mo.Nome as NomeMotorista,
        ve.Placa as PlacaVeiculo
    FROM Motorista AS mo
        INNER JOIN Viagem AS vg
            ON vg.IdMotorista = mo.Id
        INNER JOIN Veiculo AS ve
            ON ve.Id = vg.IdVeiculo
    WHERE (mo.CNH LIKE '9%' OR mo.CNH LIKE '%0')
        AND ve.CapacidadePeso > 10000;
GO

-- Q5
SELECT	ca.Codigo as Carga,
		cl.Nome as Cliente,
		ci.Nome as Cidade
	FROM Carga AS ca
		JOIN TipoCarga AS tc
			ON ca.IdTipoCarga = tc.Id
		JOIN Cliente AS cl
			ON cl.Id = ca.IdCliente
		JOIN Endereco AS en
			ON en.Id = cl.IdEndereco
		JOIN Cidade AS ci
			ON ci.Id = en.IdCidade
		JOIN Estado AS es
			ON es.Id = ci.IdEstado
	WHERE tc.Nome = 'Fragil' 
        AND es.UF = 'SP' 
        AND ca.MaterialEmbalagem IN ('Isopor', 'Plastico Bolha');
GO

-- Q6
SELECT  ca.Codigo as CodigoCarga,
        ca.Peso as Peso,
        ca.ValorDeclarado as ValorDeclarado
    FROM Carga AS ca
        INNER JOIN StatusEnvio AS st
            ON st.Id = ca.IdStatusEnvio
        INNER JOIN Cliente AS cl
            ON cl.Id = ca.IdCliente
        INNER JOIN Endereco AS ec
            ON ec.Id = cl.IdEndereco
        INNER JOIN Cidade AS cc  
            ON cc.Id = ec.IdCidade
        INNER JOIN Estado AS sc 
            ON sc.Id = cc.IdEstado
    WHERE st.Nome = 'Pendente'
      AND ca.IdParadaEntrega IS NULL
      AND sc.UF = (SELECT sf.UF
                       FROM Filial AS fi
						   INNER JOIN Endereco AS ef 
							  ON ef.Id = fi.IdEndereco
						   INNER JOIN Cidade AS cf 
							  ON cf.Id = ef.IdCidade
						   INNER JOIN Estado AS sf 
							  ON sf.Id = cf.IdEstado
					   WHERE fi.Nome = 'Filial Sao Paulo Centro'
                  );
GO

-- Q7
SELECT  DISTINCT en.Logradouro as Endereco,
        cd.Nome as Cidade,
        es.UF as Estado
    FROM Carga AS ca
        JOIN TipoCarga AS tc
            ON ca.IdTipoCarga = tc.Id
        JOIN Endereco AS en
            ON ca.IdEnderecoEntrega = en.Id
        JOIN Cidade AS cd
            ON en.IdCidade = cd.Id
        JOIN Estado es
            ON cd.IdEstado = es.Id
    WHERE es.UF = 'SP'
        AND en.Bairro IS NULL
        AND tc.Nome = 'Perigosa';
GO

-- Q8
SELECT  vi.Id as IdViagem,
        vi.DataSaida as DataSaida,
        vi.quilometragemInicial as QuilometragemInicial
    FROM Viagem AS vi
    WHERE vi.QuilometragemFinal IS NULL
        AND vi.DataChegada IS NOT NULL;
GO

-- Q9
SELECT  ca.Codigo as IdentificadorCarga
    FROM Carga AS ca
        JOIN TipoCarga AS ti
            ON ti.Id = ca.IdTipoCarga AND ti.Nome = 'Perigosa'
    WHERE ca.ValorDeclarado > 5000 AND (ca.NumeroONU IS NULL OR ca.ClasseRisco IS NULL);
GO

-- Q10
SELECT ci.Nome as Cidade,
       ROUND(AVG(ca.Peso), 2) as PesoMedio,
       ROUND(AVG(ca.ValorDeclarado), 2) as ValorDeclaradoMedio 
    FROM Carga AS ca
        INNER JOIN Cliente AS cl
            ON ca.IdCliente = cl.Id
        INNER JOIN Endereco AS en
            ON cl.IdEndereco = en.Id
        INNER JOIN Cidade AS ci
            ON en.IdCidade = ci.Id
    GROUP BY ci.Nome
    HAVING AVG(ca.Peso) > 150.00;
GO

-- Q11
SELECT  mo.Nome as NomeMotorista,
		ve.CapacidadePeso,
		COUNT(vg.Id) as TotalViagens
	FROM Motorista AS mo
		INNER JOIN Viagem AS vg
			ON vg.IdMotorista = mo.Id
		INNER JOIN Veiculo AS ve
			ON ve.Id = vg.IdVeiculo
	GROUP BY mo.Nome, mo.Id, ve.CapacidadePeso
	HAVING ve.CapacidadePeso > ( SELECT AVG(ve.CapacidadePeso) as MediaFrota
								   FROM Veiculo AS ve
							   );
GO

-- Q12
SELECT	COUNT(cl.Id) as NumeroDeClientes
		FROM Cliente AS cl
			JOIN Endereco AS en
				ON cl.IdEndereco = en.Id
			JOIN Cidade AS ci
				ON ci.Id = en.IdCidade
			JOIN Estado AS es
				ON es.Id = ci.IdEstado
		WHERE es.UF = 'RJ'
		AND EXISTS (SELECT 1
						FROM Carga AS ca2
							JOIN TipoCarga AS tc2
								ON tc2.Id = ca2.IdTipoCarga
						WHERE tc2.Nome = 'Perigosa' AND ca2.ValorDeclarado > 2000 AND cl.Id = ca2.IdCliente
				   );
GO

-- Q13
SELECT  MAX(vg.QuilometragemInicial) as MaiorQuilometragem,
        MIN(vg.QuilometragemInicial) as MenorQuilometragem
    FROM Viagem AS vg
        JOIN ParadaViagem AS pv
            ON vg.Id = pv.IdViagem
        JOIN Cidade AS cd
            ON pv.IdCidade = cd.Id
        JOIN Estado AS es
            ON cd.IdEstado = es.Id
    WHERE es.Nome = 'Parana';
GO

-- Q14
SELECT	ve.Modelo as ModeloVeiculo,
		SUM(ca.ValorDeclarado) as ValorTotalDeclarado
	FROM Veiculo AS ve
		JOIN Viagem AS va
			ON ve.Id = va.IdVeiculo
		JOIN ParadaViagem AS pv
			ON pv.IdViagem = va.Id
		JOIN Carga AS ca
			ON ca.IdParadaEntrega = pv.Id
		JOIN StatusEnvio AS se
			ON ca.IdStatusEnvio = se.Id AND se.Nome = 'Entregue'
	GROUP BY ve.Modelo
	HAVING SUM(ca.ValorDeclarado) > 50000;
GO

-- Q15
SELECT  ve.Placa as PlacaVeiculo,
        ISNULL(SUM(vi.QuilometragemFinal - vi.QuilometragemInicial), 0) as TotalQuilometrosAcumulados
    FROM Veiculo AS ve
        LEFT JOIN Viagem AS vi
            ON ve.Id = vi.IdVeiculo
                AND vi.DataChegada IS NOT NULL
    GROUP BY ve.Placa;
GO

-- Q16
SELECT  CAST(AVG(ca.Peso) AS DECIMAL(10,2)) as MediaPeso
    FROM Carga AS ca
        JOIN ParadaViagem AS pa
            ON pa.Id = ca.IdParadaEntrega
        JOIN Cidade AS ci
            ON ci.Id = pa.IdCidade
        JOIN Estado AS es
            ON es.Id = ci.IdEstado
        JOIN StatusEnvio AS st
            ON st.Id = ca.IdStatusEnvio
    WHERE es.UF = 'PR' AND st.Nome <> 'Cancelado';
GO

-- Q17
SELECT	COUNT(ca.Id) as 'Quantidade de Carga'
	FROM Carga AS ca
		INNER JOIN TipoCarga AS tc
            ON tc.Id = ca.IdTipoCarga
        INNER JOIN ParadaViagem pv
            ON pv.Id = ca.IdParadaEntrega
        INNER JOIN Viagem AS vi
            ON vi.Id = pv.IdViagem
	WHERE ca.MaterialEmbalagem IS NULL
        AND tc.Nome = 'Fragil'
        AND (SELECT  TOP 1 ci.IdEstado
                FROM ParadaViagem pv2
                    INNER JOIN Cidade ci
                        ON ci.Id = pv2.IdCidade
                WHERE pv2.IdViagem = vi.Id
                ORDER BY pv2.OrdemParada DESC
            ) = (SELECT Id FROM Estado WHERE Nome = 'Rio Grande do Sul');
GO

-- Q18
SELECT  vg.Id as 'Id da Viagem',
        vg.DataSaida as 'Data de Saida',
        COUNT(pv.Id) as 'Contagem de Paradas'
    FROM Viagem AS vg
        INNER JOIN ParadaViagem AS pv
            ON pv.IdViagem = vg.Id
    WHERE EXISTS (SELECT  1
                    FROM ParadaViagem AS pv2
                        INNER JOIN Cidade AS cd
                            ON cd.Id = pv2.IdCidade
                        INNER JOIN Estado AS et
                            ON et.Id = cd.IdEstado
                    WHERE pv2.IdViagem = vg.Id  AND et.Nome = 'Minas Gerais')
    GROUP BY vg.Id, vg.DataSaida;
GO

-- Q19
SELECT  es.Nome as Estado,
        COUNT(ca.Id) as TotalEntregas
    FROM Carga AS ca
        JOIN StatusEnvio AS se
            ON ca.IdStatusEnvio = se.Id
        JOIN Cliente AS cl
            ON ca.IdCliente = cl.Id
        JOIN Endereco AS en
            ON cl.IdEndereco = en.Id
        JOIN Cidade AS cd
            ON en.IdCidade = cd.Id
        JOIN Estado AS es
            ON cd.IdEstado = es.Id
    WHERE SE.Nome = 'Entregue'
    GROUP BY es.Nome
    HAVING COUNT(ca.Id) > 50
    ORDER BY TotalEntregas DESC;
GO

-- Q20
SELECT COUNT(DISTINCT mt.Id) as 'Quantidade de Motoristas'
    FROM Viagem AS vg
        INNER JOIN Motorista AS mt
            ON mt.Id = vg.IdMotorista
        INNER JOIN Veiculo AS vc
            ON vc.Id = vg.IdVeiculo
    WHERE (mt.CNH LIKE '%0' OR mt.CNH LIKE '%2' OR mt.CNH LIKE '%4' OR mt.CNH LIKE '%6' OR mt.CNH LIKE '%8')
      AND vc.Modelo LIKE '%Mercedes Benz%';
GO

-- Q21
SELECT  tc.Nome as TipoCarga,
        CAST(AVG(ca.Peso * 1.0) AS DECIMAL (5,2)) as MediaPesoCarga
	FROM Carga AS ca
        JOIN TipoCarga AS tc      
			ON tc.Id = ca.IdTipoCarga
        JOIN Cliente AS cl         
			ON cl.Id = ca.IdCliente
        JOIN Endereco AS enCli     
			ON enCli.Id = cl.IdEndereco
        JOIN Cidade AS ciCli       
			ON ciCli.Id = enCli.IdCidade
        JOIN Estado AS esCli       
			ON esCli.Id = ciCli.IdEstado
        JOIN ParadaViagem AS pv    
			ON pv.Id = ca.IdParadaEntrega
        JOIN Viagem AS vi          
			ON vi.Id = pv.IdViagem
        JOIN Filial AS fi          
			ON fi.Id = vi.IdFilialOrigem
        JOIN Endereco AS enFil     
			ON enFil.Id = fi.IdEndereco
        JOIN Cidade AS ciFil
		    ON ciFil.Id = enFil.IdCidade
		JOIN Estado AS esFil       
			ON esFil.Id = ciFil.IdEstado
	WHERE esCli.Id = esFil.Id
	GROUP BY tc.Nome, tc.Id;
GO

-- Q22
SELECT  ve.Modelo as 'Modelo',
        COUNT(DISTINCT ve.Id) as 'Total de Veiculos'
	FROM Veiculo AS ve
        INNER JOIN Viagem AS vi
			ON vi.IdVeiculo = ve.Id
        INNER JOIN ParadaViagem AS pv 
			ON pv.IdViagem  = vi.Id
	WHERE pv.IdCidade IN (SELECT  en.IdCidade
						      FROM Endereco AS en
							  GROUP BY en.IdCidade
							  HAVING  COUNT(*) > 5
					     )
	GROUP BY ve.Modelo;
GO

-- Q23
SELECT	es.Nome as Estado,
		COUNT(DISTINCT va.Id) as Quantidade
	FROM Viagem AS va
		JOIN Filial AS fi
			ON va.IdFilialOrigem = fi.Id
		JOIN Endereco AS en
			ON en.Id = fi.IdEndereco
		JOIN Cidade AS ci
			ON ci.Id = en.IdCidade
		JOIN Estado AS es
			ON es.Id = ci.IdEstado
	WHERE va.DataChegada IS NOT NULL
		AND (va.QuilometragemFinal - va.QuilometragemInicial) > 500
		AND es.Nome = 'Sao Paulo'
	GROUP BY es.Nome;
GO

-- Q24
SELECT  YEAR(vi.DataSaida) as Ano,
        MONTH(vi.DataSaida) as Mes,
        COUNT(vi.Id) as TotalViagens
    FROM Viagem AS vi
    GROUP BY YEAR(vi.DataSaida), MONTH(vi.DataSaida);
GO

-- Q25
SELECT  tc.Nome as TipoCarga,
        se.Nome as StatusEnvio,
        SUM(ca.ValorDeclarado) as SomaValorDeclarado
    FROM Carga AS ca
        JOIN TipoCarga AS tc
            ON ca.IdTipoCarga = tc.Id
        JOIN StatusEnvio AS se
            ON ca.IdStatusEnvio = se.Id
    GROUP BY tc.Nome,
             se.Nome
    HAVING SUM(ca.ValorDeclarado) > 0;
GO

-- Q26
SELECT	en.Bairro as Bairro,
		COUNT(cl.Id) as QuantidadeCliente
	FROM Cliente AS cl
		INNER JOIN Endereco AS en
			ON en.Id = cl.IdEndereco
		INNER JOIN Carga AS ca
			ON cl.Id = ca.IdCliente
		INNER JOIN StatusEnvio AS st
			ON st.Id = ca.IdStatusEnvio
		INNER JOIN TipoCarga AS tc
			ON tc.Id = ca.IdTipoCarga
	WHERE tc.Nome = 'Perigosa'
		AND st.Nome = 'Pendente'
		AND en.Bairro IS NOT NULL
	GROUP BY en.Bairro;
GO

-- Q27
SELECT  SUM(ve.CapacidadePeso) as SomaCapacidadePeso,
		ve.Modelo as ModeloVeiculo
	FROM Veiculo AS ve
	GROUP BY ve.Modelo
	HAVING ve.Modelo IN ( SELECT  ve1.Modelo as ModeloVeiculo
						     FROM Veiculo AS ve1
								INNER JOIN Viagem AS vg1
									ON vg1.IdVeiculo = ve1.Id
								INNER JOIN Motorista AS mo1
									ON mo1.Id = vg1.IdMotorista
							 WHERE mo1.Telefone IS NOT NULL
							 GROUP BY ve1.Modelo
						);
GO

-- Q28
SELECT ci.Nome as NomeCidade
    FROM Cidade AS ci
        INNER JOIN Endereco AS en
            ON ci.Id = en.IdCidade
        INNER JOIN Cliente AS cl
            ON en.Id = cl.IdEndereco
        INNER JOIN Carga AS ca
            ON cl.Id = ca.IdCliente
        INNER JOIN TipoCarga AS tc
            ON ca.IdTipoCarga = tc.Id
    WHERE tc.Nome = 'Fragil'
    GROUP BY ci.Nome
    HAVING COUNT(DISTINCT en.Id) > 5;
GO

-- Q29
SELECT cl.Nome as Cliente,
        COUNT(ca.Id) as QuantidadeCargas
    FROM Cliente AS cl
        JOIN Carga AS ca
            ON cl.Id = ca.IdCliente
        JOIN StatusEnvio AS se
            ON ca.IdStatusEnvio = se.Id
    WHERE se.Nome = 'Pendente'
        AND ca.Peso > (
                        SELECT AVG(Peso)
                            FROM Carga
                      )
    GROUP BY cl.Id, cl.Nome
    HAVING COUNT(ca.Id) >= 2;
GO

-- Q30
SELECT	fi.Nome as Filial,
		AVG((va.QuilometragemFinal - va.QuilometragemInicial)) as MediaQuilometragemRodada
	FROM Viagem AS va
		JOIN Filial AS fi
			ON va.IdFilialOrigem = fi.Id
	GROUP BY fi.Nome
	HAVING AVG((va.QuilometragemFinal - va.QuilometragemInicial)) > 600;
GO

-- Q31
SELECT mo.Nome as Motorista,
          COUNT(vg.Id) as QuantidadeViagens
    FROM Motorista AS mo
        INNER JOIN Viagem AS vg
            ON vg.IdMotorista = mo.Id
        INNER JOIN Veiculo AS ve
            ON ve.Id = vg.IdVeiculo
    WHERE vg.DataChegada IS NOT NULL
        AND ve.CapacidadePeso > 15000
    GROUP BY mo.Nome,
             mo.Id
    HAVING COUNT(vg.Id) >= 3;
GO

-- Q32
SELECT	tc.Nome as 'Tipo de carga',
		AVG(ca.ValorDeclarado * 1.0) as 'Média de valor declarado'
	FROM Carga AS ca
		INNER JOIN TipoCarga AS tc
			ON ca.IdTipoCarga = tc.Id
		INNER JOIN StatusEnvio AS se
			ON ca.IdStatusEnvio = se.Id
		INNER JOIN Endereco AS en
			ON ca.IdEnderecoEntrega = en.Id
		INNER JOIN Cidade AS ci
			ON en.IdCidade = ci.Id
		INNER JOIN Estado AS es
			ON ci.IdEstado = es.Id
	WHERE se.Nome = 'Entregue' AND (es.Nome = 'Santa Catarina' OR es.Nome = 'Parana')
	GROUP BY tc.Nome
	HAVING AVG(ca.ValorDeclarado * 1.0) > 2000;
GO

-- Q33
SELECT	DISTINCT ci.Nome as CidadeDeParada
	FROM ParadaViagem AS pv
        JOIN Viagem AS vi        
			ON vi.Id = pv.IdViagem
        JOIN Carga AS ca        
			ON ca.IdParadaEntrega = pv.Id
        JOIN TipoCarga AS tc     
			ON tc.Id = ca.IdTipoCarga
        JOIN StatusEnvio AS se   
			ON se.Id = ca.IdStatusEnvio
        JOIN Cidade AS ci        
			ON ci.Id = pv.IdCidade
	WHERE tc.Nome = 'Perigosa' AND se.Nome = 'Em transito';
GO

-- Q34
SELECT  ve.Placa as PlacaVeiculo,
        ve.Modelo as ModeloVeiculo,
        AVG(vi.QuilometragemFinal - vi.QuilometragemInicial) as MediaQuilometrosPorViagem
    FROM Veiculo AS ve
        JOIN Viagem AS vi
            ON ve.Id = vi.IdVeiculo
    WHERE vi.DataChegada IS NOT NULL
    GROUP BY ve.Placa,
             ve.Modelo
    HAVING AVG(vi.QuilometragemFinal - vi.QuilometragemInicial) > 500;
GO

-- Q35
SELECT et.Nome as 'Estado'
    FROM Carga AS cg
        INNER JOIN Cliente AS cl
            ON cl.Id = cg.IdCliente
        INNER JOIN Endereco AS ed
            ON ed.Id = cl.IdEndereco
        INNER JOIN Cidade AS cd
            ON cd.Id = ed.IdCidade
        INNER JOIN Estado AS et
            ON et.Id = cd.IdEstado
        INNER JOIN TipoCarga AS tc
            ON tc.Id = cg.IdTipoCarga
        INNER JOIN StatusEnvio AS se
            ON se.Id = cg.IdStatusEnvio
    WHERE tc.Nome = 'Fragil' AND se.Nome = 'Entregue'
    GROUP BY et.Nome
    HAVING COUNT(DISTINCT cl.Id) > 15;
GO

-- Q36
SELECT  vi.Id as IdentificadorViagem
    FROM Viagem AS vi
        JOIN ParadaViagem AS pa
            ON pa.IdViagem = vi.Id
    GROUP BY vi.Id
    HAVING COUNT(pa.Id) > 2;
GO

-- Q37
SELECT cl.Nome as 'Cliente',
		ca.Codigo as 'CodigoCarga',
		ci.Nome as 'Cidade'
	FROM Carga AS ca
		INNER JOIN Cliente AS cl
			ON ca.IdCliente = cl.Id
		INNER JOIN TipoCarga AS tc
			ON ca.IdTipoCarga = tc.Id
		INNER JOIN Endereco AS en
			ON cl.IdEndereco = en.Id
		INNER JOIN Cidade AS ci
			ON en.IdCidade = ci.Id
	WHERE tc.Nome = 'Fragil'
		AND ca.MaterialEmbalagem = 'Caixa de Madeira';
GO

-- Q38
SELECT  ve.Placa as Identificacao,
        ve.Modelo as Veiculo,
        mo.Nome as Motorista,
        COUNT(pv.Id) as TotalParadas
    FROM Viagem AS vg
        JOIN Veiculo AS ve
            ON vg.IdVeiculo = ve.Id
        JOIN Motorista AS mo
            ON vg.IdMotorista = mo.Id
        JOIN ParadaViagem AS pv
            ON vg.Id = pv.IdViagem
    WHERE vg.DataChegada IS NOT NULL
    GROUP BY ve.Placa, ve.Modelo, mo.Nome;
GO

-- Q39
SELECT  fi.Nome as NomeFilial,
		ci.Nome as NomeCidade,
		es.UF as UFEstado
	FROM Filial AS fi
		INNER JOIN Endereco AS en
			ON en.Id = fi.IdEndereco
		INNER JOIN Cidade AS ci
			ON ci.Id = en.IdCidade
		INNER JOIN Estado AS es
			ON es.Id = ci.IdEstado
	WHERE es.UF IN ( SELECT es1.UF
						FROM Estado AS es1
							INNER JOIN Cidade AS ci1
								ON ci1.IdEstado = es1.Id
							INNER JOIN Endereco AS en1
								ON en1.IdCidade = ci1.Id
							INNER JOIN Filial AS fi1
								ON fi1.IdEndereco = en1.Id
						WHERE fi1.Nome = 'Filial Sao Paulo Centro'
				   ) AND fi.Nome != 'Filial Sao Paulo Centro';
GO

-- Q40
SELECT ci.Nome as Cidade,
           es.UF as Estado,
           COUNT(ca.Id) as TotalCargasPerigosasEntregues
    FROM Carga AS ca
        INNER JOIN TipoCarga AS tc
            ON ca.IdTipoCarga = tc.Id
        INNER JOIN StatusEnvio AS se
            ON ca.IdStatusEnvio = se.Id
        INNER JOIN Cliente AS cl
            ON ca.IdCliente = cl.Id
        INNER JOIN Endereco AS en
            ON COALESCE(ca.IdEnderecoEntrega, cl.IdEndereco) = en.Id
        INNER JOIN Cidade AS ci
            ON en.IdCidade = ci.Id
        INNER JOIN Estado AS es
            ON ci.IdEstado = es.Id
    WHERE tc.Nome = 'Perigosa'
        AND se.Nome = 'Entregue'
    GROUP BY ci.Nome, es.UF
    ORDER BY TotalCargasPerigosasEntregues DESC;
GO

-- Q41
SELECT	vi.Id as Viagem,
		ve.Placa as PlacaVeiculo,
		mo.Nome as Motorista,
		vi.DataSaida as DataSaida,
		pv.OrdemParada as OrdemParada
	FROM Viagem AS vi
		JOIN ParadaViagem AS pv
			ON vi.Id = pv.IdViagem
		JOIN Cidade AS ci
			ON ci.Id = pv.IdCidade
		JOIN Veiculo AS ve
			ON ve.Id = vi.IdVeiculo
		JOIN Motorista AS mo
			ON mo.Id = vi.IdMotorista
	WHERE ci.Nome = 'Belo Horizonte' OR ci.Nome = 'Porto Alegre';
GO

-- Q42
SELECT	ca.Codigo as CodigoCarga,
		CAST(vi.DataSaida AS DATE) as DataSaida,
		ci.Nome as CidadeDestino
	FROM Carga AS ca
		JOIN ParadaViagem AS pv
			ON ca.IdParadaEntrega = pv.Id
		JOIN Viagem AS vi
			ON vi.Id = pv.IdViagem
		JOIN Cidade AS ci
			ON ci.Id = pv.IdCidade;
GO

-- Q43
SELECT  cl.Nome as 'Nome do Cliente',
        ed.Logradouro as 'Logradouro',
        ed.Numero as 'Numero',
        ed.Bairro as 'Bairro',
        ed.CEP as 'CEP',
        cd.Nome as 'Cidade',
        et.Nome as 'Estado'
    FROM Cliente AS cl
        LEFT JOIN Endereco AS ed
            ON ed.Id = cl.IdEndereco
        LEFT JOIN Cidade AS cd
            ON cd.Id = ed.IdCidade
        LEFT JOIN Estado AS et
            ON et.Id = cd.IdEstado;
GO

-- Q44
SELECT  ve.Placa as Placa,
        ve.Modelo as Modelo,
        ci.Nome as NomeCidade
    FROM Viagem AS vi
        JOIN Veiculo AS ve
            ON ve.Id = vi.IdVeiculo
        JOIN Filial AS fi
            ON fi.Id = vi.IdFilialOrigem
        JOIN Endereco AS en
            ON en.Id = fi.IdEndereco
        JOIN Cidade AS ci
            ON ci.Id = en.IdCidade
    WHERE vi.DataChegada IS NOT NULL AND (vi.QuilometragemFinal - vi.QuilometragemInicial) > 500;
GO

-- Q45
SELECT ca.Codigo as CodigoCarga,
        cl.Nome as NomeCliente,
        ce.Nome as CidadeEntrega    
    FROM Carga AS ca
        JOIN Cliente AS cl
            ON ca.IdCliente = cl.Id
        JOIN Endereco AS en_cli
            ON cl.IdEndereco = en_cli.Id
        JOIN Cidade AS ci_cli
            ON en_cli.IdCidade = ci_cli.Id
        JOIN Estado AS es_cli
            ON ci_cli.IdEstado = es_cli.Id
        JOIN Endereco AS en_ent
            ON ca.IdEnderecoEntrega = en_ent.Id
        JOIN Cidade AS ce
            ON en_ent.IdCidade = ce.Id
        JOIN StatusEnvio AS se
            ON ca.IdStatusEnvio = se.Id
    WHERE es_cli.Nome = 'Minas Gerais'
        AND ci_cli.Id <> ce.Id
        AND se.Nome = 'Entregue';
GO

-- Q46
SELECT ca.Codigo as CodigoCarga,
           cl.Nome as NomeCliente,
           ci.Nome as CidadeEntrega,
           es.UF as Estado
    FROM Carga AS ca
        INNER JOIN Cliente AS cl
            ON ca.IdCliente = cl.Id
        INNER JOIN Endereco AS en
            ON ca.IdEnderecoEntrega = en.Id
        INNER JOIN Cidade AS ci
            ON en.IdCidade = ci.Id
        INNER JOIN Estado AS es
            ON ci.IdEstado = es.Id
        INNER JOIN TipoCarga AS tc
            ON ca.IdTipoCarga = tc.Id
    WHERE (
        CASE 
            WHEN tc.Nome = 'Perigosa' THEN (ca.Peso * 5) + 150
            WHEN tc.Nome = 'Fragil' THEN (ca.Peso * 5) + (ca.ValorDeclarado * 0.15)
            ELSE ca.Peso * 5
        END
    ) > 300;
GO

-- Q47
SELECT  ve.Placa as PlacaVeiculo,
        mo.Nome as Motorista,
        fi.Nome as FilialOrigem,
        cf.Nome as CidadeFilial
    FROM Viagem AS vi
        INNER JOIN Veiculo AS ve
            ON ve.Id = vi.IdVeiculo
        INNER JOIN Motorista AS mo
            ON mo.Id = vi.IdMotorista
        INNER JOIN Filial AS fi
            ON fi.Id = vi.IdFilialOrigem
        INNER JOIN Endereco AS ef
            ON ef.Id = fi.IdEndereco
        INNER JOIN Cidade AS cf
            ON cf.Id = ef.IdCidade
    WHERE vi.DataChegada IS NOT NULL
      AND (SELECT COUNT(DISTINCT pv.IdCidade)
                FROM ParadaViagem AS pv
                WHERE pv.IdViagem = vi.Id
          ) > 2;
GO

-- Q48
SELECT	ca.Codigo as Carga,
		mo.Nome as Motorista,
		ve.Placa as PlacaVeiculo,
		ci.Nome as CidadeEntrega
	FROM Carga AS ca
		JOIN ParadaViagem AS pv
			ON ca.IdParadaEntrega = pv.Id
		JOIN Viagem AS vi
			ON vi.Id = pv.IdViagem
		JOIN Motorista AS mo
			ON mo.Id = vi.IdMotorista
		JOIN Veiculo AS ve
			ON ve.Id = vi.IdVeiculo
		JOIN Cidade AS ci
			ON ci.Id = pv.IdCidade
		JOIN StatusEnvio AS se
			ON se.Id = ca.IdStatusEnvio
	WHERE se.Nome = 'Em transito';
GO

-- Q49
SELECT  ci.Nome as NomeCidade,
		es.Nome as NomeEstado,
		mo.Nome as NomeMotorista,
		ve.Modelo as ModeloVeiculo
	FROM ParadaViagem AS pv
		INNER JOIN Viagem AS vg
			ON vg.Id = pv.IdViagem
		INNER JOIN Cidade AS ci
			ON ci.Id = pv.IdCidade
		INNER JOIN Estado AS es
			ON es.Id = ci.IdEstado
		INNER JOIN Motorista AS mo
			ON mo.Id = vg.IdMotorista
		INNER JOIN Veiculo AS ve
			ON ve.Id = vg.IdVeiculo
	ORDER BY pv.IdViagem, pv.OrdemParada;
GO

-- Q50
SELECT  DISTINCT cl.Nome as Cliente,
        en.Logradouro as Endereco,
        ci.Nome as Cidade,
        es.UF
    FROM Cliente AS cl
        JOIN Endereco AS en
            ON cl.IdEndereco = en.Id
        JOIN Cidade AS ci
            ON en.IdCidade = ci.Id
        JOIN Estado AS es
            ON ci.IdEstado = es.Id
        JOIN Carga AS ca
            ON cl.Id = ca.IdCliente
        JOIN StatusEnvio AS se
            ON ca.IdStatusEnvio = se.Id
    WHERE se.Nome = 'Pendente'
        AND ca.ValorDeclarado > 5000;
GO

-- Q51
SELECT ca.Codigo as CodigoCarga,
           cl.Nome as NomeCliente,
           ci.Nome as CidadeParadaEntrega,
           es.UF as SiglaEstado
    FROM Carga AS ca
        INNER JOIN Cliente AS cl
            ON ca.IdCliente = cl.Id
        INNER JOIN TipoCarga AS tc
            ON ca.IdTipoCarga = tc.Id
        LEFT JOIN ParadaViagem AS pv
            ON ca.IdParadaEntrega = pv.Id
        LEFT JOIN Cidade AS ci
            ON pv.IdCidade = ci.Id
        LEFT JOIN Estado AS es
            ON ci.IdEstado = es.Id
    WHERE tc.Nome = 'Fragil'
        AND ca.Peso > (
            SELECT AVG(ca2.Peso)
                FROM Carga AS ca2
                    INNER JOIN TipoCarga AS tc2
                        ON ca2.IdTipoCarga = tc2.Id
                WHERE tc2.Nome = 'Fragil'
        );
GO

-- Q52
SELECT DISTINCT vg.Id as IdViagem,
                   mo.Nome as Motorista,
                   ci_or.Nome as CidadeOrigem,
                   es_or.UF as UFOrigem,
                   ci_par.Nome as CidadePrimeiraParada
    FROM Viagem AS vg
        INNER JOIN Motorista AS mo
            ON vg.IdMotorista = mo.Id
        INNER JOIN Filial AS fi
            ON vg.IdFilialOrigem = fi.Id
        INNER JOIN Endereco AS en_or
            ON fi.IdEndereco = en_or.Id
        INNER JOIN Cidade AS ci_or
            ON en_or.IdCidade = ci_or.Id
        INNER JOIN Estado AS es_or
            ON ci_or.IdEstado = es_or.Id
        INNER JOIN ParadaViagem AS pv
            ON vg.Id = pv.IdViagem AND pv.OrdemParada = 1
        INNER JOIN Cidade AS ci_par
            ON pv.IdCidade = ci_par.Id
    WHERE vg.Id IN (
        SELECT pv2.IdViagem
            FROM Carga AS ca
                INNER JOIN TipoCarga AS tc ON ca.IdTipoCarga = tc.Id
                INNER JOIN ParadaViagem AS pv2 ON ca.IdParadaEntrega = pv2.Id
            WHERE tc.Nome = 'Perigosa'
    );
GO

-- Q53
SELECT  ca.Codigo as IdentificadorCodigo,
        ve.Placa as PlacaVeiculo,
        fi.Nome as FilialOrigem,
        ci.Nome as CidadeDestino
    FROM Carga AS ca
        JOIN TipoCarga AS ti
            ON ti.Id = ca.IdTipoCarga
        JOIN StatusEnvio AS st
            ON st.Id = ca.IdStatusEnvio
        JOIN ParadaViagem AS pa
            ON pa.Id = ca.IdParadaEntrega
        JOIN Viagem AS vi
            ON vi.Id = pa.IdViagem
        JOIN Veiculo AS ve
            ON ve.Id = vi.IdVeiculo
        JOIN Filial AS fi
            ON fi.Id = vi.IdFilialOrigem
        JOIN (SELECT    pr.IdViagem,
                        MAX(pr.OrdemParada) as UltimaOrdem
                    FROM ParadaViagem AS pr
                    GROUP BY pr.IdViagem
             ) AS UltimaParada
            ON UltimaParada.IdViagem = vi.Id
        JOIN ParadaViagem AS pr
            ON pr.IdViagem = UltimaParada.IdViagem AND pr.OrdemParada = UltimaParada.UltimaOrdem
        JOIN Cidade AS ci
            ON ci.Id = pr.IdCidade
    WHERE ti.Nome = 'Perigosa' AND st.Nome = 'Em Transito';
GO

-- Q54
SELECT  fi.Nome as FilialOrigem,
        es.Nome as EstadoDestinoParada,
        SUM(ca.ValorDeclarado) as SomaValoresDeclarados
    FROM Carga AS ca
        JOIN ParadaViagem AS pv
            ON ca.IdParadaEntrega = pv.Id
        JOIN Viagem AS vi
            ON pv.IdViagem = vi.Id
        JOIN Filial AS fi
            ON vi.IdFilialOrigem = fi.Id
        JOIN Cidade AS ci
            ON pv.IdCidade = ci.Id
        JOIN Estado AS es
            ON ci.IdEstado = es.Id
    GROUP BY fi.Nome,
             es.Nome;
GO

-- Q55
SELECT  ca.Codigo as CodigoCarga,
        ca.Peso   as PesoCarga
    FROM Carga AS ca
        INNER JOIN Cliente AS cl
            ON cl.Id = ca.IdCliente
        INNER JOIN Endereco AS ec 
            ON ec.Id = cl.IdEndereco
        INNER JOIN Cidade AS cc 
            ON cc.Id = ec.IdCidade
        INNER JOIN Estado AS sc 
            ON sc.Id = cc.IdEstado
        INNER JOIN ParadaViagem AS pv
            ON pv.Id = ca.IdParadaEntrega
        INNER JOIN Viagem AS vi
            ON vi.Id = pv.IdViagem
        INNER JOIN Filial AS fi
            ON fi.Id = vi.IdFilialOrigem
        INNER JOIN Endereco AS ef 
            ON ef.Id = fi.IdEndereco
        INNER JOIN Cidade AS cf 
            ON cf.Id = ef.IdCidade
        INNER JOIN Estado AS sf 
            ON sf.Id = cf.IdEstado
    WHERE ca.Peso > (SELECT AVG(ca2.Peso) FROM Carga AS ca2)
      AND sc.Id <> sf.Id;
GO

-- Q56
SELECT	ca.Codigo as Carga,
		tc.Nome as TipoCarga,
		ca.ValorDeclarado as ValorCarga
	FROM Carga AS ca
		JOIN TipoCarga AS tc
			ON ca.IdTipoCarga = tc.Id
		JOIN StatusEnvio AS se
			ON se.Id = ca.IdStatusEnvio
	WHERE tc.Nome = 'Fragil'
	AND ca.ValorDeclarado < (SELECT AVG(ca2.ValorDeclarado * 1.0)
                                 FROM Carga AS ca2
								     JOIN TipoCarga AS tc2  
									     ON tc2.Id = ca2.IdTipoCarga
									 JOIN StatusEnvio AS se2 
									     ON se2.Id = ca2.IdStatusEnvio
								 WHERE  tc2.Nome = 'Padrao' AND se2.Id = se.Id
                            );
GO

-- Q57
SELECT cl.Nome as Cliente,
           cl.Documento,
           cl.Telefone
    FROM Cliente AS cl
        JOIN Endereco AS en ON cl.IdEndereco = en.Id
        JOIN Cidade AS ci ON en.IdCidade = ci.Id
        JOIN Estado AS es ON ci.IdEstado = es.Id
    WHERE es.Id = (
        SELECT et.Id
            FROM Estado AS et
                JOIN Cidade AS cd ON et.Id = cd.IdEstado
                JOIN Endereco AS ed ON cd.Id = ed.IdCidade
                JOIN Cliente AS ct ON ed.Id = ct.IdEndereco
            WHERE ct.Id = 1
    )
    AND EXISTS (
        SELECT 1
            FROM Carga AS ca
                JOIN TipoCarga AS tc ON ca.IdTipoCarga = tc.Id
                JOIN StatusEnvio AS se ON ca.IdStatusEnvio = se.Id
            WHERE ca.IdCliente = cl.Id
                AND tc.Nome = 'Perigosa'
                AND ca.NumeroONU IS NOT NULL
                AND se.Nome = 'Entregue'
    );
GO

-- Q58
SELECT  ve.Placa as Identificacao,
        ve.Modelo as Veiculo
    FROM Veiculo AS ve
    WHERE ve.Id NOT IN (
                        SELECT  vi.IdVeiculo as Identificador
                           FROM Viagem AS vi
                                JOIN Filial AS fi
                                    ON VI.IdFilialOrigem = fi.Id
                                JOIN Endereco AS en
                                    ON fi.IdEndereco = en.Id
                                JOIN Cidade AS cd
                                    ON en.IdCidade = cd.Id
                                JOIN Estado AS es
                                    ON cd.IdEstado = es.Id
                            WHERE es.UF = 'MG'
                      );
GO

-- Q59
SELECT  mo.Nome as NomeMotorista,
        ve.CapacidadePeso,
        vg.IdFilialOrigem
    FROM Viagem AS vg
        INNER JOIN Motorista AS mo 
            ON vg.IdMotorista = mo.Id
        INNER JOIN Veiculo AS ve 
            ON vg.IdVeiculo = ve.Id
    WHERE vg.IdFilialOrigem = 1
        AND ve.CapacidadePeso = (SELECT MAX(ve2.CapacidadePeso)
                                    FROM Veiculo AS ve2
                                        INNER JOIN Viagem AS vg2 
                                            ON vg2.IdVeiculo = ve2.Id
                                    WHERE vg2.IdFilialOrigem = 1
                                );
GO

-- Q60
SELECT  vi.Id as IdViagem,
        (vi.QuilometragemFinal - vi.QuilometragemInicial) as DistanciaRodada
     FROM Viagem AS vi
     WHERE vi.DataChegada IS NOT NULL
        AND (vi.QuilometragemFinal - vi.QuilometragemInicial) > (
          SELECT AVG(QuilometragemFinal - QuilometragemInicial)
              FROM Viagem
              WHERE DataChegada IS NOT NULL
      );
GO

-- Q61
SELECT  TOP 1 cl.Nome as NomeCliente
    FROM Cliente AS cl
        JOIN Carga AS ca
            ON ca.IdCliente = cl.Id
    ORDER BY ca.ValorDeclarado DESC;
GO

-- Q62
SELECT	pv.Id as 'Id Parada viagem'
	FROM ParadaViagem AS pv
	WHERE pv.IdViagem = (SELECT  TOP 1 vi.Id
						     FROM Viagem AS vi
					         WHERE vi.QuilometragemFinal IS NOT NULL
							     AND vi.DataSaida IS NOT NULL
					         ORDER BY vi.QuilometragemFinal DESC
				        );
GO

-- Q63
SELECT  mt.Nome as 'Motorista',
        MIN(vc.CapacidadePeso) as 'Capacidade de Peso'
    FROM Carga AS cg
        INNER JOIN TipoCarga AS tc 
            ON tc.Id = cg.IdTipoCarga
        INNER JOIN ParadaViagem AS pv
            ON pv.Id = cg.IdParadaEntrega
        INNER JOIN Viagem AS vg
            ON vg.Id = pv.IdViagem
        INNER JOIN Motorista AS mt
            ON mt.Id = vg.IdMotorista
        INNER JOIN Veiculo AS vc
            ON vc.Id = vg.IdVeiculo
    WHERE cg.MaterialEmbalagem = 'Caixa de Madeira' AND tc.Nome = 'Fragil'
    GROUP BY mt.Id, mt.Nome
    HAVING MIN(vc.CapacidadePeso) = (SELECT MIN(CapacidadePeso) 
                                        FROM Veiculo);
GO

-- Q64
SELECT  cl.Nome as NomeCliente,
		COUNT(ca.Id) as TotalCargas,
		AVG(ca.Peso) as PesoMedio
	FROM Cliente AS cl
		INNER JOIN Carga AS ca
			ON ca.IdCliente = cl.Id
	GROUP BY cl.Nome, cl.Id
	HAVING COUNT(ca.Id) > 2 AND AVG(ca.Peso) > 200;
GO

-- Q65
SELECT cd.Nome as Cidade,
           COUNT(DISTINCT fi.Id) as QuantidadeFiliais,
           COUNT(vg.Id) as TotalViagens
    FROM Cidade AS cd
        INNER JOIN Endereco AS en
            ON cd.Id = en.IdCidade
        INNER JOIN Filial AS fi
            ON en.Id = fi.IdEndereco
        LEFT JOIN Viagem AS vg
            ON fi.Id = vg.IdFilialOrigem
    GROUP BY cd.Nome;
GO

-- Q66
SELECT	mo.Nome as Motorista,
		COUNT(va.Id) as Quantidade
	FROM Motorista AS mo
		JOIN Viagem AS va
			ON va.IdMotorista = mo.Id
	WHERE va.DataChegada IS NULL
		  AND va.DataSaida < DATEADD(DAY, -3, GETDATE())
	GROUP BY mo.Id, mo.Nome;
GO

-- Q67
SELECT  vc.Placa as 'Placa do Veiculo',
        COUNT(pv.Id) as 'Total de Paradas'
    FROM Viagem AS vg
        INNER JOIN ParadaViagem AS pv
            ON pv.IdViagem = vg.Id
        INNER JOIN Veiculo AS vc
            ON vc.Id = vg.IdVeiculo
        INNER JOIN Cidade AS cd
            ON cd.Id = pv.IdCidade
        INNER JOIN Estado AS et
            ON et.Id = cd.IdEstado
    WHERE et.Nome = 'Sao Paulo'
    GROUP BY vc.Placa, vc.Id;
GO

-- Q68
SELECT	es.Nome as 'Estado',
		COUNT(cl.Id) as 'Total de clientes'
	FROM Cliente AS cl
		INNER JOIN Endereco AS en
			ON cl.IdEndereco = en.Id
		INNER JOIN Cidade AS ci
			ON en.IdCidade = ci.Id
		INNER JOIN Estado AS es
			ON ci.IdEstado = es.Id
	GROUP BY es.Id, es.Nome
	HAVING COUNT(cl.Id) > 0
	ORDER BY COUNT(cl.Id) DESC;
GO

-- Q69
SELECT ve.Placa as PlacaVeiculo,
           (SUM(ca.Peso) * 100.0 / ve.CapacidadePeso) as PercentualCapacidadeOcupada
    FROM Veiculo AS ve
        INNER JOIN Viagem AS vi
            ON ve.Id = vi.IdVeiculo
        INNER JOIN ParadaViagem AS pv
            ON vi.Id = pv.IdViagem
        INNER JOIN Carga AS ca
            ON pv.Id = ca.IdParadaEntrega
    WHERE vi.DataChegada IS NULL
    GROUP BY ve.Placa,
             ve.CapacidadePeso;
GO

-- Q70
SELECT	COUNT(vi.Id) as QuantidadeViagens,
		AVG(ContaParadas * 1.0) as MediaParadas
	FROM (SELECT vg.Id,
				 COUNT(pv.Id) as ContaParadas
			FROM Viagem AS vg
				INNER JOIN ParadaViagem AS pv
					ON pv.IdViagem = vg.Id
			WHERE vg.DataChegada IS NOT NULL
			GROUP BY vg.Id
		 ) AS vi;
GO

-- Q71
SELECT	ca.Codigo as CodigoCarga,
		(SELECT  AVG(ca2.Peso) - ca.Peso
			FROM Carga AS ca2
				INNER JOIN TipoCarga AS tc2
					ON tc2.Id = ca2.IdTipoCarga
			WHERE tc.Nome = tc2.Nome) as DiferencaEntrePesoCargaEPesoMedioCarga
	FROM Carga AS ca
		INNER JOIN TipoCarga AS tc
			ON tc.Id = ca.IdTipoCarga
	WHERE ca.Peso > (SELECT  AVG(ca3.Peso)
						 FROM Carga AS ca3
							 INNER JOIN TipoCarga AS tc3
								 ON tc3.Id = ca3.IdTipoCarga
						 WHERE tc.Nome = tc3.Nome);
GO

-- Q72
SELECT ci.Nome as Cidade,
           SUM(
               CASE 
                   WHEN tc.Nome = 'Perigosa' THEN (ca.Peso * 5) + 150
                   WHEN tc.Nome = 'Fragil' THEN (ca.Peso * 5) + (ca.ValorDeclarado * 0.15)
                   ELSE ca.Peso * 5
               END
           ) as ValorTotalFrete
    FROM Carga AS ca
        INNER JOIN TipoCarga AS tc ON ca.IdTipoCarga = tc.Id
        INNER JOIN Cliente AS cl ON ca.IdCliente = cl.Id
        INNER JOIN Endereco AS en ON COALESCE(ca.IdEnderecoEntrega, cl.IdEndereco) = en.Id
        INNER JOIN Cidade AS ci ON en.IdCidade = ci.Id
    GROUP BY ci.Nome;
GO

-- Q73
SELECT ca.Codigo as CodigoCarga,
           ca.Peso,
           CASE 
               WHEN ca.Peso < 100 THEN 'Leve'
               WHEN ca.Peso <= 500 THEN 'Media'
               ELSE 'Pesada'
           END as FaixaPeso
    FROM Carga AS ca
        INNER JOIN ParadaViagem AS pv ON ca.IdParadaEntrega = pv.Id
        INNER JOIN Viagem AS vi ON pv.IdViagem = vi.Id
    WHERE vi.DataChegada IS NULL;
GO

-- Q74
SELECT vg.Id as Identificacao,
        vg.DataSaida as DataHora,
        CASE
        WHEN vg.DataChegada IS NOT NULL THEN 'Concluida'
        ELSE 'Em Andamento'
        END as Situacao
    FROM Viagem AS vg
        JOIN Veiculo AS ve
            ON vg.IdVeiculo = ve.Id
    WHERE ve.CapacidadePeso > 10000;
GO

-- Q75
SELECT	mo.Nome as NomeMotorista,
		mo.CNH as CNH,
		CASE
			WHEN mo.Telefone IS NULL THEN 'Sem Contato'
			ELSE mo.Telefone
		END as Telefone 
	FROM Motorista AS mo
	WHERE mo.CNH LIKE '%0';
GO

-- Q76
SELECT  ca.Codigo as CodigoCarga,
		tp.Nome as TipoClassificacao,
		CASE
			WHEN tp.Nome = 'Perigosa' AND ca.ClasseRisco IS NULL THEN 'Risco Desconhecido'
			WHEN tp.Nome = 'Perigosa' THEN ca.ClasseRisco
			ELSE 'Risco Inexistente'
		END as ClassificacaoRisco
	FROM Carga AS ca
		INNER JOIN TipoCarga AS tp
			ON tp.Id = ca.IdTipoCarga
		INNER JOIN StatusEnvio AS st
			ON st.Id = ca.IdStatusEnvio
	WHERE st.Nome = 'Entregue';
GO

-- Q77
SELECT	cl.Nome 'Cliente',
		CASE
			WHEN LEN(cl.Documento) = 14 THEN 'CNPJ'
			ELSE 'CPF'
		END as 'Tipo documento'
	FROM Cliente AS cl
		INNER JOIN Endereco AS en
			ON cl.IdEndereco = en.Id
		INNER JOIN Cidade AS ci
			ON en.IdCidade = ci.Id
		INNER JOIN Estado AS es
			ON ci.IdEstado = es.Id
	WHERE es.UF = 'RJ'
		AND cl.Telefone IS NULL
GO

-- Q78
SELECT	ca.Codigo as Codigo,
		ca.Peso as Peso,
		ca.ValorDeclarado as ValorDeclarado,
		tc.Nome as TipoCarga,
		CASE
			WHEN tc.Nome = 'Padrao' THEN ca.Peso * 5
			WHEN tc.Nome = 'Fragil' THEN (ca.Peso * 5) * 1.15
			WHEn tc.Nome = 'Perigosa' THEN (ca.Peso * 5) + 150.00
		END as ValorFrete
	FROM Carga AS ca
		INNER JOIN TipoCarga AS tc
			ON tc.Id = ca.IdTipoCarga;
GO

-- Q79
SELECT es.Nome as EstadoDestino,
        SUM(
            CASE 
                WHEN tc.Nome = 'Perigosa' THEN (ca.Peso * 5) + 150
                WHEN tc.Nome = 'Fragil' THEN (ca.Peso * 5) + (ca.ValorDeclarado * 0.15)
                ELSE ca.Peso * 5
            END
        ) as ValorTotalFrete
    FROM Carga AS ca
        INNER JOIN Cliente AS cl ON ca.IdCliente = cl.Id
        INNER JOIN Endereco AS en ON cl.IdEndereco = en.Id
        INNER JOIN Cidade AS ci ON en.IdCidade = ci.Id
        INNER JOIN Estado AS es ON ci.IdEstado = es.Id
        INNER JOIN TipoCarga AS tc ON ca.IdTipoCarga = tc.Id
    GROUP BY es.Nome;
GO

-- Q80
SELECT  vi.Id as IdentificadorViagem,
        ve.Placa as PlacaVeiculo,
        CASE
            WHEN SUM(ca.Peso) / ve.CapacidadePeso < 0.30 THEN 'Subutilizado'
            WHEN SUM(ca.Peso) / ve.CapacidadePeso <= 0.80 THEN 'Adequado'
            ELSE 'Alerta de Sobrecarga'
        END as Aproveitamento
    FROM Viagem AS vi
        JOIN Veiculo AS ve
            ON ve.Id = vi.IdVeiculo
        JOIN ParadaViagem AS pa
            ON pa.IdViagem = vi.Id
        JOIN Carga AS ca
            ON ca.IdParadaEntrega = pa.Id
    GROUP BY vi.Id, ve.Placa, ve.CapacidadePeso;
GO

-- Q81
SELECT	pv.Id as Parada,
		DATEDIFF(HOUR, vi.DataSaida, pv.DataChegadaParada) as DiferencaHoras,
		CASE 
			WHEN DATEDIFF(HOUR, vi.DataSaida, pv.DataChegadaParada) > 12 THEN 'Atrasado'
			WHEN DATEDIFF(HOUR, vi.DataSaida, pv.DataChegadaParada) >= 6 THEN 'Normal'
			ELSE 'Rápido'
		END as ClassificacaoTempoEntrega
	FROM ParadaViagem AS pv
		JOIN Viagem AS vi
			ON pv.IdViagem = vi.Id;
GO

-- Q82
SELECT DISTINCT ve.Placa as PlacaVeiculo,
       ve.Modelo as ModeloVeiculo
    FROM Veiculo AS ve
        INNER JOIN Viagem AS vg 
            ON ve.Id = vg.IdVeiculo
        INNER JOIN ParadaViagem AS pv 
            ON vg.Id = pv.IdViagem
        INNER JOIN Cidade AS ci 
            ON pv.IdCidade = ci.Id
        INNER JOIN Estado AS es 
            ON ci.IdEstado = es.Id
        INNER JOIN Carga AS ca 
            ON ca.IdParadaEntrega = pv.Id
    WHERE es.UF = 'RS'
        AND ca.ValorDeclarado > 5000;
GO

-- Q83
SELECT DISTINCT ci.Nome AS NomeCidade
	FROM Viagem AS vg
		INNER JOIN Filial AS fi
			ON fi.Id = vg.IdFilialOrigem
		INNER JOIN ParadaViagem AS pv
			ON pv.IdViagem = vg.Id
		INNER JOIN Cidade AS ci
			ON ci.Id = pv.IdCidade
	WHERE fi.Nome = 'Filial Sao Paulo Centro'
		AND vg.Id IN (
			SELECT pv2.IdViagem
				FROM ParadaViagem AS pv2
					INNER JOIN Carga AS ca
						ON ca.IdParadaEntrega = pv2.Id
					INNER JOIN TipoCarga AS tp
						ON tp.Id = ca.IdTipoCarga
				WHERE tp.Nome = 'Perigosa'
					AND ca.ClasseRisco = 'Inflamavel'
		);
GO

-- Q84
SELECT	ca.Codigo as Carga
	FROM Carga AS ca
		JOIN TipoCarga AS tc
			ON ca.IdTipoCarga = tc.Id
		JOIN Cliente AS cl         
			ON cl.Id = ca.IdCliente
        JOIN Endereco AS enCli     
			ON enCli.Id = cl.IdEndereco
        JOIN Cidade AS ciCli       
			ON ciCli.Id = enCli.IdCidade
        JOIN Estado AS esCli       
			ON esCli.Id = ciCli.IdEstado
		JOIN Endereco AS eent
			ON eent.Id = ca.IdEnderecoEntrega
		JOIN Cidade AS cient
			ON cient.Id = eent.IdCidade
		JOIN Estado AS esent
			ON esent.Id = cient.IdEstado
	WHERE esCli.UF = 'SP' AND esent.UF = 'PR' AND ca.Peso > 200;
GO

-- Q85
SELECT DISTINCT mt.Nome as Motorista
    FROM Viagem AS vg
        JOIN Motorista AS mt
            ON vg.IdMotorista = mt.Id
        JOIN Veiculo AS VE
            ON vg.IdVeiculo = ve.Id
    WHERE ve.Modelo = 'Scania R450'
        AND (vg.QuilometragemFinal - vg.QuilometragemInicial) > 700;
GO

-- Q86
SELECT DISTINCT fl.Nome as 'Nome Filial'
    FROM Carga AS cg
        INNER JOIN StatusEnvio AS se
            ON se.Id = cg.IdStatusEnvio
        INNER JOIN ParadaViagem AS pv
            ON pv.Id = cg.IdParadaEntrega
        INNER JOIN Viagem AS vg
            ON vg.Id = pv.IdViagem
        INNER JOIN Filial AS fl
            ON fl.Id = vg.IdFilialOrigem
        INNER JOIN TipoCarga AS tc
            ON tc.Id = cg.IdTipoCarga
    WHERE se.Nome = 'Pendente' AND tc.Nome = 'Perigosa' AND cg.NumeroONU IS NOT NULL;
GO

-- Q87
SELECT  vi.Id as IdViagem
    FROM Viagem AS vi
        JOIN ParadaViagem AS pv
            ON vi.Id = pv.IdViagem
        JOIN Carga AS ca
            ON pv.Id = ca.IdParadaEntrega
        JOIN TipoCarga AS tc
            ON ca.IdTipoCarga = tc.Id
    WHERE tc.Nome IN ('Perigosa', 'Fragil')
    GROUP BY vi.Id
    HAVING COUNT(DISTINCT CASE WHEN tc.Nome = 'Perigosa' THEN 1 END) > 0
       AND COUNT(DISTINCT CASE WHEN tc.Nome = 'Fragil' THEN 1 END) > 0;
GO

-- Q88
SELECT  DISTINCT vi.Id as IdentificadorViagem
    FROM Viagem AS vi
        JOIN ParadaViagem AS pa
            ON pa.IdViagem = vi.Id
        JOIN Cidade AS ci
            ON ci.Id = pa.IdCidade
        JOIN ParadaViagem AS pr
            ON pr.IdViagem = vi.Id AND pr.OrdemParada > pa.OrdemParada
        JOIN Cidade AS cd
            ON cd.Id = pr.IdCidade
        JOIN Carga AS ca
            ON ca.IdParadaEntrega = pr.Id
    WHERE ci.Nome = 'Curitiba' AND cd.Nome = 'Porto Alegre';
GO

-- Q89
SELECT  mo.Nome as NomeMotorista,
		mo.CNH as CNH,
		mo.Telefone as Telefone
	FROM Motorista AS mo
		JOIN Viagem AS va 
			ON va.IdMotorista = mo.Id
	WHERE va.DataChegada IS NULL
		  AND va.DataSaida < DATEADD(DAY, -5, GETDATE())
		  AND mo.Telefone IS NOT NULL;
GO

-- Q90
SELECT	DISTINCT ci.Nome as 'Cidade'
	FROM Cidade AS ci
		INNER JOIN Estado AS es
			ON ci.IdEstado = es.Id
		INNER JOIN ParadaViagem AS pv
			ON ci.Id = pv.IdCidade
	WHERE ci.Id NOT IN (SELECT	en2.IdCidade
							FROM Filial AS fi
								INNER JOIN Endereco AS en2
									ON fi.IdEndereco = en2.Id
					   )
		AND ci.Id IN (SELECT  pv2.IdCidade
					      FROM ParadaViagem AS pv2
					          INNER JOIN Carga AS ca2
							      ON ca2.IdParadaEntrega = pv2.Id
							  INNER JOIN StatusEnvio AS se
								  ON ca2.IdStatusEnvio = se.Id
						  WHERE se.Nome = 'Entregue'
					 );
GO

