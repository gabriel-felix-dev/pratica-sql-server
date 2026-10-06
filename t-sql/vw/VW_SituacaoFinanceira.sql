USE Turismo;
GO	

IF EXISTS (
               SELECT  1
				   FROM [dbo].[sysobjects]
				   WHERE Id = OBJECT_ID(N'[dbo].[VW_SituacaoFinanceira]')
					   AND TYPE = 'V'
		  )
	DROP VIEW [dbo].[VW_SituacaoFinanceira];
GO

CREATE VIEW [dbo].[VW_SituacaoFinanceira]
	AS
	/*
		Documentacao
		Arquivo Fonte............: VW_SituacaoFinanceira.sql
		Objetivo.................: Retornar a situação financeira dos clientes
		Autor....................: Gabriel Felix
		Data.....................: 06/10/2026
		Ex.......................: SELECT  *
									   FROM [dbo].[VW_SituacaoFinanceira];
	*/
	SELECT  cl.Nome As Cliente,
			ex.Codigo As CodigoExcursao,
			ic.QuantidadeParcelas,
			COUNT(CASE WHEN pa.IdSituacaoParcela = 3 THEN 1 
				  END) As QuantidadeParcelasPagas,
			COUNT(CASE WHEN pa.IdSituacaoParcela = 4 THEN 1
				  END) As QuantidadeParcelasCanceladas,
			COUNT(CASE WHEN pa.IdSituacaoParcela = 1 THEN 1
				  END) As QuantidadeParcelasPendentes
			--Quantidade de parcelas vencidas - RN07 A situação gravada na parcela pode estar desatualizada. Em consultas e cálculos, uma
			--	                                     parcela ABERTA com vencimento anterior à data de referência deve ser tratada como
			--	                                     vencida, mesmo que continue gravada como ABERTA.
			
			--	                                     Data de referência é a data para a qual a consulta ou o cálculo é feito (por exemplo, a
			--	                                     data do pagamento ou a data atual).

			-- O valor original ainda pendente,
			-- O valor atualizado ainda pendente - RN06 Sem atraso (pagamento até o dia do vencimento, inclusive), o valor atualizado é igual ao
			--                                          valor original.
			
			--                                          Com qualquer atraso, aplicam-se multa fixa de 2% sobre o valor original, cobrada uma
			--                                          única vez, e juros simples de 1% sobre o valor original para cada mês de atraso.
			
			--                                          Cada período mensal iniciado após o vencimento conta como um mês inteiro: 1 dia após
			--                                          o vencimento já conta 1 mês; 1 mês e 1 dia após, 2 meses; e assim por diante.
			--                                          O valor atualizado é arredondado para duas casas decimais.

			--                                          Exemplo: parcela de R$ 500,00 com vencimento em 05/03. Paga em 05/03, vale R$
			--                                          500,00; em 06/03 ou em 05/04, vale R$ 515,00 (500 + 10 de multa + 5 de juros); em
			--                                          06/04, vale R$ 520,00.
		FROM [dbo].[Inscricao] AS ic WITH(NOLOCK)
			INNER JOIN [dbo].[Cliente] AS cl WITH(NOLOCK)
				ON cl.Id = ic.IdCliente AND cl.Ativo = 1
			INNER JOIN [dbo].[Excursao] AS ex WITH(NOLOCK)
				ON ex.Id = ic.IdExcursao AND ex.Ativo = 1
			INNER JOIN [dbo].[Parcela] AS pa WITH(NOLOCK)
				ON pa.IdInscricao = ic.Id
			GROUP BY cl.Nome, ex.Codigo, ic.QuantidadeParcelas;
GO