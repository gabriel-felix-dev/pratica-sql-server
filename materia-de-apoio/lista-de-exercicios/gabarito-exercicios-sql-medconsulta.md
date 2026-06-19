# Gabarito — Lista de Exercícios SQL Server (MedConsulta)

> Soluções de referência. Em vários casos existe mais de uma forma correta de resolver — o importante é manter a lógica de range em datas, evitar função sobre coluna em filtro, e tratar `NULL` corretamente.

---

## Stored Procedures

**1.**
```sql
CREATE PROCEDURE ObterConsultasPorPaciente_V2
    @IdPaciente INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Consulta WHERE IdPaciente = @IdPaciente;
END;
```

**2.**
```sql
CREATE PROCEDURE ContarConsultasRealizadasPorMedico
    @IdMedico INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS QtdRealizadas
    FROM Consulta
    WHERE IdMedico = @IdMedico AND IdStatusConsulta = 3;
END;
```

**3.**
```sql
CREATE PROCEDURE ListarMedicosPorClinica
    @IdClinica TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, Nome, CRM FROM Medico WHERE IdClinica = @IdClinica;
END;
```

**4.**
```sql
CREATE PROCEDURE ObterFaturamentoPorPeriodo
    @DataInicio DATE,
    @DataFim DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SUM(ValorBase) AS FaturamentoTotal
    FROM Consulta
    WHERE IdStatusConsulta = 3
      AND DataHora >= @DataInicio
      AND DataHora < DATEADD(DAY, 1, @DataFim);
END;
```

**5.**
```sql
CREATE PROCEDURE CadastrarPaciente
    @IdEndereco INT = NULL,
    @Nome VARCHAR(150),
    @Documento VARCHAR(20),
    @Telefone VARCHAR(20) = NULL,
    @TipoPlano VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Paciente WHERE Documento = @Documento)
    BEGIN
        RAISERROR('Já existe paciente cadastrado com esse documento.', 16, 1);
        RETURN;
    END
    INSERT INTO Paciente (IdEndereco, Nome, Documento, Telefone, TipoPlano)
    VALUES (@IdEndereco, @Nome, @Documento, @Telefone, @TipoPlano);
END;
```

**6.**
```sql
CREATE PROCEDURE AtualizarStatusConsulta
    @IdConsulta INT,
    @NovoStatus TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM Consulta WHERE Id = @IdConsulta)
    BEGIN
        RAISERROR('Consulta inexistente.', 16, 1);
        RETURN;
    END
    UPDATE Consulta SET IdStatusConsulta = @NovoStatus WHERE Id = @IdConsulta;
END;
```

**7.**
```sql
CREATE PROCEDURE ResumoPaciente
    @IdPaciente INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.TipoPlano, COUNT(c.Id) AS QtdCanceladas
    FROM Paciente p
    LEFT JOIN Consulta c ON c.IdPaciente = p.Id AND c.IdStatusConsulta = 4
    WHERE p.Id = @IdPaciente
    GROUP BY p.TipoPlano;
END;
```

**8.**
```sql
CREATE PROCEDURE ListarMedicosPorEspecialidade
    @IdEspecialidade TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, Nome, CRM, IdEspecialidade
    FROM Medico
    WHERE @IdEspecialidade IS NULL OR IdEspecialidade = @IdEspecialidade;
END;
```

**9.**
```sql
CREATE PROCEDURE FaturamentoMedicoMes
    @IdMedico INT, @Ano INT, @Mes INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SUM(ValorBase) AS FaturamentoMes
    FROM Consulta
    WHERE IdMedico = @IdMedico
      AND IdStatusConsulta = 3
      AND DataHora >= DATEFROMPARTS(@Ano, @Mes, 1)
      AND DataHora < DATEADD(MONTH, 1, DATEFROMPARTS(@Ano, @Mes, 1));
END;
```

**10.**
```sql
CREATE PROCEDURE InserirConsulta
    @IdPaciente INT, @IdMedico INT, @IdTipoAtendimento TINYINT,
    @Codigo VARCHAR(50), @DataHora DATETIME, @ValorBase DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM Paciente WHERE Id = @IdPaciente)
    BEGIN RAISERROR('Paciente inexistente.', 16, 1); RETURN; END
    IF NOT EXISTS (SELECT 1 FROM Medico WHERE Id = @IdMedico)
    BEGIN RAISERROR('Médico inexistente.', 16, 1); RETURN; END

    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO Consulta (IdPaciente, IdMedico, IdTipoAtendimento, IdStatusConsulta, Codigo, DataHora, ValorBase)
        VALUES (@IdPaciente, @IdMedico, @IdTipoAtendimento, 1, @Codigo, @DataHora, @ValorBase);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
```

**11.**
```sql
CREATE PROCEDURE ContarPacientesPorUF
    @UF CHAR(2)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(DISTINCT p.Id) AS QtdPacientes
    FROM Paciente p
    INNER JOIN Endereco e ON e.Id = p.IdEndereco
    INNER JOIN Cidade ci ON ci.Id = e.IdCidade
    INNER JOIN Estado es ON es.Id = ci.IdEstado
    WHERE es.UF = @UF;
END;
```

**12.**
```sql
CREATE PROCEDURE RankingMedicosPorClinica
    @IdClinica TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.Nome, SUM(c.ValorBase) AS FaturamentoTotal,
           RANK() OVER (ORDER BY SUM(c.ValorBase) DESC) AS Ranking
    FROM Medico m
    LEFT JOIN Consulta c ON c.IdMedico = m.Id AND c.IdStatusConsulta = 3
    WHERE m.IdClinica = @IdClinica
    GROUP BY m.Id, m.Nome;
END;
```

**13.**
```sql
CREATE PROCEDURE DetalheConsultaPorCodigo
    @Codigo VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Nome AS Paciente, m.Nome AS Medico, cl.Nome AS Clinica, esp.Nome AS Especialidade
    FROM Consulta c
    INNER JOIN Paciente p ON p.Id = c.IdPaciente
    INNER JOIN Medico m ON m.Id = c.IdMedico
    INNER JOIN Clinica cl ON cl.Id = m.IdClinica
    INNER JOIN Especialidade esp ON esp.Id = m.IdEspecialidade
    WHERE c.Codigo = @Codigo;
END;
```

**14.**
```sql
CREATE PROCEDURE CancelarConsultasVencidas
    @DataLimite DATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Consulta SET IdStatusConsulta = 4
    WHERE IdStatusConsulta = 1 AND DataHora < @DataLimite;
    SELECT @@ROWCOUNT AS QtdCanceladas;
END;
```

**15.**
```sql
CREATE PROCEDURE ValorMedioPorPlano
    @TipoPlano VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT AVG(c.ValorBase) AS ValorMedio
    FROM Consulta c
    INNER JOIN Paciente p ON p.Id = c.IdPaciente
    WHERE p.TipoPlano = @TipoPlano AND c.IdStatusConsulta = 3;
END;
```

**16.**
```sql
CREATE PROCEDURE ContarConsultasPaciente
    @IdPaciente INT,
    @TotalConsultas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @TotalConsultas = COUNT(*) FROM Consulta WHERE IdPaciente = @IdPaciente;
END;
GO

DECLARE @Total INT;
EXEC ContarConsultasPaciente @IdPaciente = 1, @TotalConsultas = @Total OUTPUT;
SELECT @Total AS TotalConsultas;
```

**17.**
```sql
CREATE PROCEDURE ListarPacientesSemEndereco
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, Nome, Documento FROM Paciente WHERE IdEndereco IS NULL;
END;
```

**18.**
```sql
CREATE PROCEDURE ContarClinicasPorEstado
    @IdEstado TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS QtdClinicas
    FROM Clinica cl
    INNER JOIN Endereco e ON e.Id = cl.IdEndereco
    INNER JOIN Cidade ci ON ci.Id = e.IdCidade
    WHERE ci.IdEstado = @IdEstado;
END;
```

**19.**
```sql
CREATE PROCEDURE ReajustarValorConsultasPendentes
    @IdMedico INT, @Percentual DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE Consulta
        SET ValorBase = ValorBase * (1 + @Percentual / 100)
        WHERE IdMedico = @IdMedico AND IdStatusConsulta = 1;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
```

**20.**
```sql
CREATE PROCEDURE ResumoPorTipoAtendimento
    @DataInicio DATE, @DataFim DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ta.Nome AS TipoAtendimento, COUNT(c.Id) AS QtdConsultas, SUM(c.ValorBase) AS FaturamentoTotal
    FROM Consulta c
    INNER JOIN TipoAtendimento ta ON ta.Id = c.IdTipoAtendimento
    WHERE c.DataHora >= @DataInicio AND c.DataHora < DATEADD(DAY, 1, @DataFim)
    GROUP BY ta.Nome;
END;
```

---

## Jobs

**1.**
```sql
UPDATE Consulta
SET IdStatusConsulta = 4
WHERE IdStatusConsulta = 1 AND DataHora < CAST(GETDATE() AS DATE);
```

**2.**
```sql
USE msdb;
GO
EXEC sp_add_job @job_name = N'Job_CancelarConsultasPendentesVencidas';

EXEC sp_add_jobstep
    @job_name = N'Job_CancelarConsultasPendentesVencidas',
    @step_name = N'CancelarVencidas',
    @subsystem = N'TSQL',
    @database_name = N'MedConsulta',
    @command = N'UPDATE Consulta SET IdStatusConsulta = 4
                 WHERE IdStatusConsulta = 1 AND DataHora < CAST(GETDATE() AS DATE);';

EXEC sp_add_schedule
    @schedule_name = N'Diario_02h', @freq_type = 4, @freq_interval = 1, @active_start_time = 020000;

EXEC sp_attach_schedule
    @job_name = N'Job_CancelarConsultasPendentesVencidas', @schedule_name = N'Diario_02h';

EXEC sp_add_jobserver @job_name = N'Job_CancelarConsultasPendentesVencidas';
```

**3.**
```sql
UPDATE Consulta
SET IdStatusConsulta = 4
WHERE IdStatusConsulta = 2
  AND DataHora < DATEADD(DAY, -1, CAST(GETDATE() AS DATE));
```

**4.**
```sql
USE msdb;
GO
EXEC sp_add_job @job_name = N'Job_RelatorioSemanal';

EXEC sp_add_jobstep
    @job_name = N'Job_RelatorioSemanal', @step_name = N'InserirRelatorio',
    @subsystem = N'TSQL', @database_name = N'MedConsulta',
    @command = N'INSERT INTO RelatorioSemanal (DataReferencia, FaturamentoTotal)
                 SELECT CAST(GETDATE() AS DATE), SUM(ValorBase)
                 FROM Consulta
                 WHERE IdStatusConsulta = 3
                   AND DataHora >= DATEADD(DAY, -7, CAST(GETDATE() AS DATE))
                   AND DataHora < CAST(GETDATE() AS DATE);';

EXEC sp_add_schedule
    @schedule_name = N'Semanal_Segunda_06h', @freq_type = 8, @freq_interval = 2,
    @freq_recurrence_factor = 1, @active_start_time = 060000;

EXEC sp_attach_schedule @job_name = N'Job_RelatorioSemanal', @schedule_name = N'Semanal_Segunda_06h';
EXEC sp_add_jobserver @job_name = N'Job_RelatorioSemanal';
```

**5.**
```sql
INSERT INTO ConsultaHistorico
SELECT *
FROM Consulta
WHERE IdStatusConsulta = 3
  AND DataHora >= DATEFROMPARTS(YEAR(DATEADD(MONTH,-1,GETDATE())), MONTH(DATEADD(MONTH,-1,GETDATE())), 1)
  AND DataHora < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
```

**6.**
```sql
USE msdb;
GO
EXEC sp_add_job @job_name = N'Job_FaturamentoPeriodico';

EXEC sp_add_jobstep
    @job_name = N'Job_FaturamentoPeriodico', @step_name = N'ExecutarFaturamento',
    @subsystem = N'TSQL', @database_name = N'MedConsulta',
    @command = N'INSERT INTO FaturamentoLog (DataExecucao, Total)
                 EXEC ObterFaturamentoPorPeriodo @DataInicio = ''2026-01-01'', @DataFim = ''2026-12-31'';';

EXEC sp_add_schedule
    @schedule_name = N'A_Cada_6_Horas', @freq_type = 4, @freq_interval = 1,
    @freq_subday_type = 8, @freq_subday_interval = 6, @active_start_time = 0;

EXEC sp_attach_schedule @job_name = N'Job_FaturamentoPeriodico', @schedule_name = N'A_Cada_6_Horas';
EXEC sp_add_jobserver @job_name = N'Job_FaturamentoPeriodico';
```

**7.**
```sql
USE msdb;
GO
SELECT j.name AS NomeJob, s.name AS NomeSchedule, s.freq_type, s.active_start_time
FROM sysjobs j
INNER JOIN sysjobschedules js ON js.job_id = j.job_id
INNER JOIN sysschedules s ON s.schedule_id = js.schedule_id;
```

**8.**
```sql
USE msdb;
GO
EXEC sp_update_job @job_name = N'Job_CancelarConsultasPendentesVencidas', @enabled = 0;
```

**9.**
```sql
USE msdb;
GO
EXEC sp_delete_job @job_name = N'Job_RelatorioSemanal';
```

**10.**
```sql
USE msdb;
GO
EXEC sp_add_job @job_name = N'Job_CancelamentoComLog';

EXEC sp_add_jobstep
    @job_name = N'Job_CancelamentoComLog', @step_name = N'CancelarVencidas',
    @subsystem = N'TSQL', @database_name = N'MedConsulta',
    @command = N'UPDATE Consulta SET IdStatusConsulta = 4
                 WHERE IdStatusConsulta = 1 AND DataHora < CAST(GETDATE() AS DATE);
                 INSERT INTO JobExecucaoLog (NomeJob, DataExecucao, LinhasAfetadas)
                 VALUES (''Job_CancelamentoComLog'', GETDATE(), @@ROWCOUNT);';
```

**11.**
```sql
INSERT INTO OverbookingAlertaLog (IdMedico, DataConsulta, QtdConsultas)
SELECT IdMedico, CAST(DataHora AS DATE), COUNT(*)
FROM Consulta
WHERE IdStatusConsulta = 2
GROUP BY IdMedico, CAST(DataHora AS DATE)
HAVING COUNT(*) > 15;
```

**12.**
```sql
INSERT INTO FaturamentoMensalClinica (IdClinica, Ano, Mes, FaturamentoTotal)
SELECT m.IdClinica,
       YEAR(DATEADD(MONTH,-1,GETDATE())), MONTH(DATEADD(MONTH,-1,GETDATE())),
       SUM(c.ValorBase)
FROM Consulta c
INNER JOIN Medico m ON m.Id = c.IdMedico
WHERE c.IdStatusConsulta = 3
  AND c.DataHora >= DATEFROMPARTS(YEAR(DATEADD(MONTH,-1,GETDATE())), MONTH(DATEADD(MONTH,-1,GETDATE())), 1)
  AND c.DataHora < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
GROUP BY m.IdClinica;
```

**13.**
```sql
INSERT INTO InconsistenciaLog (IdConsulta, Motivo, DataDeteccao)
SELECT Id, 'Telemedicina sem plataforma informada', GETDATE()
FROM Consulta
WHERE IdTipoAtendimento = 2 AND PlataformaTelemedicina IS NULL;
```

**14.**
```sql
USE msdb;
GO
SELECT j.name AS NomeJob, h.run_date, h.run_time, h.message
FROM sysjobs j
INNER JOIN sysjobhistory h ON h.job_id = j.job_id
WHERE j.name = 'Job_CancelarConsultasPendentesVencidas'
  AND h.run_status = 0;
```

**15.**
```sql
UPDATE c
SET c.IdStatusConsulta = 2
FROM Consulta c
INNER JOIN Paciente p ON p.Id = c.IdPaciente
WHERE c.IdStatusConsulta = 1 AND p.TipoPlano = 'Ouro';
```

**16.**
```sql
INSERT INTO ConsultaDuplicadaLog (IdConsulta, IdPaciente, IdMedico, DataHora)
SELECT Id, IdPaciente, IdMedico, DataHora
FROM (
    SELECT Id, IdPaciente, IdMedico, DataHora,
           ROW_NUMBER() OVER (PARTITION BY IdPaciente, IdMedico, DataHora ORDER BY Id) AS rn
    FROM Consulta
) dup
WHERE rn > 1;
```

**17.**
```sql
USE msdb;
GO
EXEC sp_update_schedule
    @name = N'Diario_02h', @freq_type = 8,
    @freq_interval = 62, -- seg(2)+ter(4)+qua(8)+qui(16)+sex(32)
    @freq_recurrence_factor = 1;
```

**18.**
```sql
INSERT INTO ReceitaAcumuladaDiaria (Data, ReceitaAcumulada)
SELECT TOP 1 CAST(DataHora AS DATE),
       SUM(SUM(ValorBase)) OVER (ORDER BY CAST(DataHora AS DATE) ROWS UNBOUNDED PRECEDING)
FROM Consulta
WHERE IdStatusConsulta = 3
  AND DataHora >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
GROUP BY CAST(DataHora AS DATE)
ORDER BY 1 DESC;
```

**19.**
```sql
USE msdb;
GO
EXEC sp_add_job @job_name = N'Job_ManutencaoIndicesConsulta';

EXEC sp_add_jobstep
    @job_name = N'Job_ManutencaoIndicesConsulta', @step_name = N'RebuildIndices',
    @subsystem = N'TSQL', @database_name = N'MedConsulta',
    @command = N'ALTER INDEX ALL ON Consulta REBUILD;';

EXEC sp_add_schedule
    @schedule_name = N'Domingo_03h', @freq_type = 8, @freq_interval = 1, @active_start_time = 030000;

EXEC sp_attach_schedule @job_name = N'Job_ManutencaoIndicesConsulta', @schedule_name = N'Domingo_03h';
EXEC sp_add_jobserver @job_name = N'Job_ManutencaoIndicesConsulta';
```

**20.**
```sql
USE msdb;
GO
SELECT j.name AS NomeJob, h.run_date, h.run_time,
       CASE h.run_status WHEN 0 THEN 'Falhou' WHEN 1 THEN 'Sucesso' WHEN 3 THEN 'Cancelado' ELSE 'Outro' END AS Status
FROM sysjobs j
INNER JOIN sysjobhistory h ON h.job_id = j.job_id
WHERE h.step_id = 0 AND j.enabled = 1
ORDER BY h.run_date DESC, h.run_time DESC;
```

---

## Functions

**1.**
```sql
CREATE FUNCTION fn_ValorTotalConsulta (@IdConsulta INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2);
    SELECT @Total = ValorBase + ISNULL(TaxaConsultorio,0) + ISNULL(TaxaPlataforma,0)
                   + ISNULL(TaxaInsumos,0) + ISNULL(TaxaAnestesia,0)
    FROM Consulta WHERE Id = @IdConsulta;
    RETURN @Total;
END;
```

**2.**
```sql
CREATE FUNCTION fn_EspecialidadeDoMedico (@IdMedico INT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @Nome VARCHAR(50);
    SELECT @Nome = esp.Nome
    FROM Medico m INNER JOIN Especialidade esp ON esp.Id = m.IdEspecialidade
    WHERE m.Id = @IdMedico;
    RETURN @Nome;
END;
```

**3.**
```sql
CREATE FUNCTION fn_TotalGastoPaciente (@IdPaciente INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2);
    SELECT @Total = SUM(ValorBase + ISNULL(TaxaConsultorio,0) + ISNULL(TaxaPlataforma,0)
                       + ISNULL(TaxaInsumos,0) + ISNULL(TaxaAnestesia,0))
    FROM Consulta WHERE IdPaciente = @IdPaciente AND IdStatusConsulta = 3;
    RETURN ISNULL(@Total, 0);
END;
```

**4.**
```sql
CREATE FUNCTION fn_PacienteExiste (@Documento VARCHAR(20))
RETURNS BIT
AS
BEGIN
    RETURN (SELECT CASE WHEN EXISTS (SELECT 1 FROM Paciente WHERE Documento = @Documento) THEN 1 ELSE 0 END);
END;
```

**5.**
```sql
CREATE FUNCTION fn_ConsultasDoMedico (@IdMedico INT)
RETURNS TABLE
AS
RETURN
(
    SELECT c.Id, c.Codigo, c.DataHora, c.ValorBase, p.Nome AS Paciente
    FROM Consulta c INNER JOIN Paciente p ON p.Id = c.IdPaciente
    WHERE c.IdMedico = @IdMedico
);
```

**6.**
```sql
CREATE FUNCTION fn_PacientesPorPlano (@TipoPlano VARCHAR(20))
RETURNS TABLE
AS
RETURN
(
    SELECT p.Id, p.Nome, ci.Nome AS Cidade
    FROM Paciente p
    LEFT JOIN Endereco e ON e.Id = p.IdEndereco
    LEFT JOIN Cidade ci ON ci.Id = e.IdCidade
    WHERE p.TipoPlano = @TipoPlano
);
```

**7.**
```sql
CREATE FUNCTION fn_ResumoMedicosClinica (@IdClinica TINYINT)
RETURNS @Resultado TABLE (IdMedico INT, Nome VARCHAR(150), QtdConsultas INT, FaturamentoTotal DECIMAL(12,2))
AS
BEGIN
    INSERT INTO @Resultado
    SELECT m.Id, m.Nome, COUNT(c.Id), SUM(ISNULL(c.ValorBase,0))
    FROM Medico m
    LEFT JOIN Consulta c ON c.IdMedico = m.Id AND c.IdStatusConsulta = 3
    WHERE m.IdClinica = @IdClinica
    GROUP BY m.Id, m.Nome;
    RETURN;
END;
```

**8.**
```sql
CREATE FUNCTION fn_DataHoraFormatada (@IdConsulta INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Resultado VARCHAR(20);
    SELECT @Resultado = CONVERT(VARCHAR(10), DataHora, 103) + ' ' + CONVERT(VARCHAR(5), DataHora, 108)
    FROM Consulta WHERE Id = @IdConsulta;
    RETURN @Resultado;
END;
```

**9.**
```sql
CREATE FUNCTION fn_DiasEntre (@Data1 DATE, @Data2 DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(DAY, @Data1, @Data2);
END;
```

**10.**
```sql
CREATE FUNCTION fn_ClinicasPorEstado (@IdEstado TINYINT)
RETURNS TABLE
AS
RETURN
(
    SELECT cl.Id, cl.Nome, cl.CNPJ
    FROM Clinica cl
    INNER JOIN Endereco e ON e.Id = cl.IdEndereco
    INNER JOIN Cidade ci ON ci.Id = e.IdCidade
    WHERE ci.IdEstado = @IdEstado
);
```

**11.**
```sql
CREATE FUNCTION fn_TicketMedioMedico (@IdMedico INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Media DECIMAL(10,2);
    SELECT @Media = AVG(ValorBase + ISNULL(TaxaConsultorio,0) + ISNULL(TaxaPlataforma,0)
                       + ISNULL(TaxaInsumos,0) + ISNULL(TaxaAnestesia,0))
    FROM Consulta WHERE IdMedico = @IdMedico AND IdStatusConsulta = 3;
    RETURN @Media;
END;
```
> Aqui `AVG` não precisa de `CAST` porque as colunas já são `DECIMAL(10,2)` — a regra de estourar `INT` (vista no material de conceitos) só vale para colunas inteiras.

**12.**
```sql
CREATE FUNCTION fn_ClinicaUltimaConsulta (@IdPaciente INT)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @NomeClinica VARCHAR(100);
    SELECT TOP 1 @NomeClinica = cl.Nome
    FROM Consulta c
    INNER JOIN Medico m ON m.Id = c.IdMedico
    INNER JOIN Clinica cl ON cl.Id = m.IdClinica
    WHERE c.IdPaciente = @IdPaciente
    ORDER BY c.DataHora DESC;
    RETURN @NomeClinica;
END;
```

**13.**
```sql
CREATE FUNCTION fn_ConsultasCanceladasPeriodo (@DataInicio DATE, @DataFim DATE)
RETURNS TABLE
AS
RETURN
(
    SELECT Id, Codigo, DataHora, ValorBase, IdPaciente, IdMedico
    FROM Consulta
    WHERE IdStatusConsulta = 4
      AND DataHora >= @DataInicio AND DataHora < DATEADD(DAY, 1, @DataFim)
);
```

**14.**
```sql
CREATE FUNCTION fn_CalcularTotal (
    @ValorBase DECIMAL(10,2),
    @TaxaConsultorio DECIMAL(10,2) = NULL,
    @TaxaPlataforma DECIMAL(10,2) = NULL,
    @TaxaInsumos DECIMAL(10,2) = NULL,
    @TaxaAnestesia DECIMAL(10,2) = NULL
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @ValorBase + ISNULL(@TaxaConsultorio,0) + ISNULL(@TaxaPlataforma,0)
                       + ISNULL(@TaxaInsumos,0) + ISNULL(@TaxaAnestesia,0);
END;
```

**15.**
```sql
CREATE FUNCTION fn_UltimasTresConsultas (@IdPaciente INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 3 Id, Codigo, DataHora, ValorBase
    FROM Consulta
    WHERE IdPaciente = @IdPaciente
    ORDER BY DataHora DESC
);
```
> Limitação: `TOP` dentro de uma inline TVF precisa de um valor literal/constante. Para tornar a quantidade configurável por parâmetro (`TOP (@N)`), é preciso reescrever como multi-statement function ou usar `OFFSET/FETCH` em uma consulta normal.

**16.**
```sql
CREATE FUNCTION fn_QtdMedicosPorEspecialidade (@IdEspecialidade TINYINT)
RETURNS INT
AS
BEGIN
    DECLARE @Qtd INT;
    SELECT @Qtd = COUNT(DISTINCT Id) FROM Medico WHERE IdEspecialidade = @IdEspecialidade;
    RETURN @Qtd;
END;
```

**17.**
```sql
CREATE FUNCTION fn_MedicosComCargaClinica (@IdClinica TINYINT)
RETURNS @Resultado TABLE (IdMedico INT, Nome VARCHAR(150), Sobrecarregado BIT)
AS
BEGIN
    INSERT INTO @Resultado
    SELECT m.Id, m.Nome, CASE WHEN COUNT(c.Id) > 5 THEN 1 ELSE 0 END
    FROM Medico m
    LEFT JOIN Consulta c ON c.IdMedico = m.Id AND c.IdStatusConsulta = 1
    WHERE m.IdClinica = @IdClinica
    GROUP BY m.Id, m.Nome;
    RETURN;
END;
```

**18.**
```sql
CREATE FUNCTION fn_PacientePorCodigoConsulta (@Codigo VARCHAR(50))
RETURNS VARCHAR(150)
AS
BEGIN
    DECLARE @Nome VARCHAR(150);
    SELECT @Nome = p.Nome
    FROM Consulta c INNER JOIN Paciente p ON p.Id = c.IdPaciente
    WHERE c.Codigo = @Codigo;
    RETURN @Nome;
END;
```

**19.**
```sql
CREATE FUNCTION fn_FaturamentoPorTipoAtendimento (@Ano INT, @Mes INT)
RETURNS TABLE
AS
RETURN
(
    SELECT ta.Nome AS TipoAtendimento, SUM(c.ValorBase) AS FaturamentoTotal
    FROM Consulta c INNER JOIN TipoAtendimento ta ON ta.Id = c.IdTipoAtendimento
    WHERE c.IdStatusConsulta = 3
      AND c.DataHora >= DATEFROMPARTS(@Ano, @Mes, 1)
      AND c.DataHora < DATEADD(MONTH, 1, DATEFROMPARTS(@Ano, @Mes, 1))
    GROUP BY ta.Nome
);
```

**20.**
```sql
CREATE FUNCTION fn_PercentualCanceladas (@IdMedico INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Total INT, @Canceladas INT;
    SELECT @Total = COUNT(*) FROM Consulta WHERE IdMedico = @IdMedico;
    SELECT @Canceladas = COUNT(*) FROM Consulta WHERE IdMedico = @IdMedico AND IdStatusConsulta = 4;
    IF @Total = 0 RETURN 0;
    RETURN CAST(@Canceladas AS DECIMAL(10,2)) / @Total * 100;
END;
```

---

## Triggers

**1.**
```sql
CREATE TABLE ConsultaInsercaoLog (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdConsulta INT NOT NULL,
    DataInsercao DATETIME NOT NULL DEFAULT GETDATE()
);
GO
CREATE TRIGGER trg_Consulta_LogInsercao
ON Consulta AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ConsultaInsercaoLog (IdConsulta) SELECT Id FROM inserted;
END;
```

**2.**
```sql
CREATE TRIGGER trg_Consulta_BloquearAlteracaoValorRealizada
ON Consulta AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(ValorBase)
    BEGIN
        IF EXISTS (
            SELECT 1 FROM inserted i INNER JOIN deleted d ON d.Id = i.Id
            WHERE d.IdStatusConsulta = 3 AND i.ValorBase <> d.ValorBase
        )
        BEGIN
            RAISERROR('Não é permitido alterar o valor de uma consulta já Realizada.', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
END;
```

**3.**
```sql
CREATE TABLE ConsultaExcluidaLog (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdConsulta INT NOT NULL, Codigo VARCHAR(50), DataHora DATETIME, ValorBase DECIMAL(10,2),
    DataExclusao DATETIME NOT NULL DEFAULT GETDATE()
);
GO
CREATE TRIGGER trg_Consulta_LogExclusao
ON Consulta AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ConsultaExcluidaLog (IdConsulta, Codigo, DataHora, ValorBase)
    SELECT Id, Codigo, DataHora, ValorBase FROM deleted;
END;
```

**4.**
```sql
CREATE TRIGGER trg_Consulta_SoftDelete
ON Consulta INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE c SET c.IdStatusConsulta = 4
    FROM Consulta c INNER JOIN deleted d ON d.Id = c.Id;
END;
```

**5.**
```sql
CREATE TABLE PacienteAlteracaoLog (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdPaciente INT NOT NULL, PlanoAnterior VARCHAR(20), PlanoNovo VARCHAR(20),
    DataAlteracao DATETIME NOT NULL DEFAULT GETDATE()
);
GO
CREATE TRIGGER trg_Paciente_AuditoriaPlano
ON Paciente AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(TipoPlano) RETURN;
    INSERT INTO PacienteAlteracaoLog (IdPaciente, PlanoAnterior, PlanoNovo)
    SELECT i.Id, d.TipoPlano, i.TipoPlano
    FROM inserted i INNER JOIN deleted d ON d.Id = i.Id
    WHERE i.TipoPlano <> d.TipoPlano;
END;
```

**6.**
```sql
CREATE TRIGGER trg_Paciente_ValidarDocumentoDuplicado
ON Paciente AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted i INNER JOIN Paciente p ON p.Documento = i.Documento AND p.Id <> i.Id)
    BEGIN
        RAISERROR('Documento já cadastrado para outro paciente.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
```

**7.**
```sql
CREATE TRIGGER trg_Medico_BloquearTrocaEspecialidade
ON Medico AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(IdEspecialidade)
    BEGIN
        IF EXISTS (SELECT 1 FROM inserted i INNER JOIN Consulta c ON c.IdMedico = i.Id AND c.IdStatusConsulta = 1)
        BEGIN
            RAISERROR('Não é possível trocar a especialidade: médico tem consultas Pendentes.', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
END;
```

**8.**
```sql
CREATE TRIGGER trg_Consulta_ValidarPlataformaTelemedicina
ON Consulta AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE IdTipoAtendimento = 2 AND PlataformaTelemedicina IS NULL)
    BEGIN
        RAISERROR('Consultas de Telemedicina precisam informar a plataforma utilizada.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
```

**9.**
```sql
CREATE TABLE ConsultaFaturada (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdConsulta INT NOT NULL, ValorTotal DECIMAL(10,2) NOT NULL,
    DataFaturamento DATETIME NOT NULL DEFAULT GETDATE()
);
GO
CREATE TRIGGER trg_Consulta_RegistrarFaturamento
ON Consulta AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(IdStatusConsulta) RETURN;
    INSERT INTO ConsultaFaturada (IdConsulta, ValorTotal)
    SELECT i.Id, i.ValorBase + ISNULL(i.TaxaConsultorio,0) + ISNULL(i.TaxaPlataforma,0)
                            + ISNULL(i.TaxaInsumos,0) + ISNULL(i.TaxaAnestesia,0)
    FROM inserted i INNER JOIN deleted d ON d.Id = i.Id
    WHERE i.IdStatusConsulta = 3 AND d.IdStatusConsulta <> 3;
END;
```

**10.**
```sql
CREATE TRIGGER trg_Database_ImpedirDropTable
ON DATABASE FOR DROP_TABLE
AS
BEGIN
    RAISERROR('Exclusão de tabelas não é permitida neste banco.', 16, 1);
    ROLLBACK;
END;
```

**11.**
```sql
CREATE TRIGGER trg_Clinica_CriarResumo
ON Clinica AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ClinicaResumo (IdClinica, FaturamentoTotal, QtdConsultas)
    SELECT Id, 0, 0 FROM inserted;
END;
```

**12.**
```sql
CREATE TRIGGER trg_Consulta_ContarAlteracoesStatus
ON Consulta AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(IdStatusConsulta) RETURN;
    UPDATE c SET c.QtdAlteracoesStatus = ISNULL(c.QtdAlteracoesStatus, 0) + 1
    FROM Consulta c
    INNER JOIN inserted i ON i.Id = c.Id
    INNER JOIN deleted d ON d.Id = c.Id
    WHERE i.IdStatusConsulta <> d.IdStatusConsulta;
END;
```
> Pressupõe coluna `QtdAlteracoesStatus INT NULL` adicionada via `ALTER TABLE Consulta ADD QtdAlteracoesStatus INT NULL;`.

**13.**
```sql
CREATE TRIGGER trg_Consulta_BloquearDataPassadoDistante
ON Consulta AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE DataHora < '2020-01-01')
    BEGIN
        RAISERROR('DataHora não pode ser anterior a 2020.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
```

**14.**
```sql
CREATE TRIGGER trg_Consulta_BloquearDataFuturoDistante
ON Consulta AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE DataHora > DATEADD(YEAR, 2, GETDATE()))
    BEGIN
        RAISERROR('DataHora não pode ser mais de 2 anos no futuro.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
```

**15.**
```sql
CREATE TRIGGER trg_Medico_ImpedirExclusaoComConsultas
ON Medico AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM deleted d INNER JOIN Consulta c ON c.IdMedico = d.Id)
    BEGIN
        RAISERROR('Não é possível excluir médico com consultas vinculadas.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
```
> A FK `FK_IdMedico_Consulta` já impede isso com erro genérico — o trigger só personaliza a mensagem.

**16.**
```sql
CREATE TABLE ConsultaReagendamentoLog (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdConsulta INT NOT NULL, MedicoAnterior INT NOT NULL, MedicoNovo INT NOT NULL,
    DataAlteracao DATETIME NOT NULL DEFAULT GETDATE()
);
GO
CREATE TRIGGER trg_Consulta_LogReagendamento
ON Consulta AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(IdMedico) RETURN;
    INSERT INTO ConsultaReagendamentoLog (IdConsulta, MedicoAnterior, MedicoNovo)
    SELECT i.Id, d.IdMedico, i.IdMedico
    FROM inserted i INNER JOIN deleted d ON d.Id = i.Id
    WHERE i.IdMedico <> d.IdMedico;
END;
```

**17.**
```sql
CREATE TRIGGER trg_Consulta_AtualizarResumoMedico
ON Consulta AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE mr SET mr.TotalConsultas = mr.TotalConsultas + qtd.Qtd
    FROM MedicoResumo mr
    INNER JOIN (SELECT IdMedico, COUNT(*) AS Qtd FROM inserted GROUP BY IdMedico) qtd
        ON qtd.IdMedico = mr.IdMedico;

    INSERT INTO MedicoResumo (IdMedico, TotalConsultas)
    SELECT i.IdMedico, COUNT(*)
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM MedicoResumo mr WHERE mr.IdMedico = i.IdMedico)
    GROUP BY i.IdMedico;
END;
```

**18.**
```sql
CREATE TABLE EnderecoAlteracaoLog (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IdEndereco INT NOT NULL, CEPAnterior VARCHAR(15), CEPNovo VARCHAR(15),
    DataAlteracao DATETIME NOT NULL DEFAULT GETDATE()
);
GO
CREATE TRIGGER trg_Endereco_LogCEP
ON Endereco AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(CEP) RETURN;
    INSERT INTO EnderecoAlteracaoLog (IdEndereco, CEPAnterior, CEPNovo)
    SELECT i.Id, d.CEP, i.CEP
    FROM inserted i INNER JOIN deleted d ON d.Id = i.Id
    WHERE ISNULL(i.CEP,'') <> ISNULL(d.CEP,'');
END;
```

**19.**
```sql
CREATE TRIGGER trg_Consulta_BloquearConflitoAgenda
ON Consulta AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted i
        INNER JOIN Consulta c ON c.IdMedico = i.IdMedico AND c.DataHora = i.DataHora AND c.Id <> i.Id
    )
    BEGIN
        RAISERROR('Já existe uma consulta marcada para esse médico nesse horário.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
```

**20.**
```sql
CREATE TRIGGER trg_Consulta_ImpedirReabrirCancelada
ON Consulta AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(IdStatusConsulta)
    BEGIN
        IF EXISTS (
            SELECT 1 FROM inserted i INNER JOIN deleted d ON d.Id = i.Id
            WHERE d.IdStatusConsulta = 4 AND i.IdStatusConsulta <> 4
        )
        BEGIN
            RAISERROR('Uma consulta Cancelada não pode mudar de status.', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
END;
```

---

## CTE

**1.**
```sql
;WITH PacientesOuro AS (
    SELECT Id, Nome FROM Paciente WHERE TipoPlano = 'Ouro'
)
SELECT po.Nome, c.Codigo, c.DataHora, c.ValorBase
FROM PacientesOuro po INNER JOIN Consulta c ON c.IdPaciente = po.Id;
```

**2.**
```sql
;WITH FaturamentoMedico AS (
    SELECT IdMedico, SUM(ValorBase) AS Total
    FROM Consulta WHERE IdStatusConsulta = 3
    GROUP BY IdMedico
)
SELECT m.Nome, fm.Total
FROM FaturamentoMedico fm INNER JOIN Medico m ON m.Id = fm.IdMedico
WHERE fm.Total > 5000;
```

**3.**
```sql
;WITH Meses AS (
    SELECT 1 AS Mes
    UNION ALL
    SELECT Mes + 1 FROM Meses WHERE Mes < 12
)
SELECT me.Mes, SUM(c.ValorBase) AS FaturamentoMes
FROM Meses me
LEFT JOIN Consulta c ON MONTH(c.DataHora) = me.Mes AND YEAR(c.DataHora) = 2026 AND c.IdStatusConsulta = 3
GROUP BY me.Mes
ORDER BY me.Mes
OPTION (MAXRECURSION 12);
```

**4.**
```sql
;WITH FaturamentoClinica AS (
    SELECT m.IdClinica, SUM(c.ValorBase) AS Total
    FROM Consulta c INNER JOIN Medico m ON m.Id = c.IdMedico
    WHERE c.IdStatusConsulta = 3
    GROUP BY m.IdClinica
),
MediaGeral AS (
    SELECT AVG(Total) AS Media FROM FaturamentoClinica
)
SELECT cl.Nome, fc.Total, mg.Media,
       CASE WHEN fc.Total > mg.Media THEN 'Acima da média' ELSE 'Abaixo da média' END AS Comparativo
FROM FaturamentoClinica fc
CROSS JOIN MediaGeral mg
INNER JOIN Clinica cl ON cl.Id = fc.IdClinica;
```

**5.**
```sql
;WITH PacientesComRealizada AS (
    SELECT DISTINCT IdPaciente FROM Consulta WHERE IdStatusConsulta = 3
)
SELECT p.Id, p.Nome
FROM Paciente p
LEFT JOIN PacientesComRealizada pcr ON pcr.IdPaciente = p.Id
WHERE pcr.IdPaciente IS NULL;
```

**6.**
```sql
;WITH Numeros AS (
    SELECT 1 AS N
    UNION ALL
    SELECT N + 1 FROM Numeros WHERE N < 20
),
ConsultasOrdenadas AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY DataHora) AS rn FROM Consulta
)
SELECT n.N, co.Codigo, co.DataHora
FROM Numeros n INNER JOIN ConsultasOrdenadas co ON co.rn = n.N
OPTION (MAXRECURSION 20);
```

**7.**
```sql
;WITH ResumoPlano AS (
    SELECT p.TipoPlano, COUNT(DISTINCT p.Id) AS QtdPacientes, AVG(c.ValorBase) AS FaturamentoMedio
    FROM Paciente p
    LEFT JOIN Consulta c ON c.IdPaciente = p.Id AND c.IdStatusConsulta = 3
    GROUP BY p.TipoPlano
)
SELECT * FROM ResumoPlano ORDER BY FaturamentoMedio DESC;
```

**8.**
```sql
;WITH ConsultasMedico AS (
    SELECT *, 'Realizada' AS Origem FROM Consulta WHERE IdMedico = 1 AND IdStatusConsulta = 3
    UNION ALL
    SELECT *, 'Cancelada' AS Origem FROM Consulta WHERE IdMedico = 1 AND IdStatusConsulta = 4
)
SELECT Codigo, DataHora, ValorBase, Origem FROM ConsultasMedico;
```

**9.**
```sql
;WITH PrimeiraConsulta AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY IdPaciente ORDER BY DataHora ASC) AS rn
    FROM Consulta
)
SELECT IdPaciente, Codigo, DataHora FROM PrimeiraConsulta WHERE rn = 1;
```

**10.**
```sql
;WITH ConsultasPorEspecialidade AS (
    SELECT esp.Nome AS Especialidade, COUNT(c.Id) AS QtdConsultas
    FROM Consulta c
    INNER JOIN Medico m ON m.Id = c.IdMedico
    INNER JOIN Especialidade esp ON esp.Id = m.IdEspecialidade
    GROUP BY esp.Nome
)
SELECT * FROM ConsultasPorEspecialidade ORDER BY QtdConsultas DESC;
```

**11.**
```sql
DECLARE @DataInicio DATE = '2026-05-01', @DataFim DATE = '2026-05-10';

;WITH Calendario AS (
    SELECT @DataInicio AS Dia
    UNION ALL
    SELECT DATEADD(DAY, 1, Dia) FROM Calendario WHERE Dia < @DataFim
)
SELECT Dia FROM Calendario
OPTION (MAXRECURSION 0);
```

**12.**
```sql
;WITH TaxasInconsistentes AS (
    SELECT * FROM Consulta WHERE TaxaAnestesia IS NOT NULL AND IdTipoAtendimento <> 3
)
SELECT Id, Codigo, IdTipoAtendimento, TaxaAnestesia FROM TaxasInconsistentes;
```

**13.**
```sql
;WITH ConsultasRealizadas AS (
    SELECT * FROM Consulta WHERE IdStatusConsulta = 3
),
FaturamentoClinica AS (
    SELECT m.IdClinica, SUM(cr.ValorBase) AS Total
    FROM ConsultasRealizadas cr INNER JOIN Medico m ON m.Id = cr.IdMedico
    GROUP BY m.IdClinica
),
RankingClinica AS (
    SELECT IdClinica, Total, RANK() OVER (ORDER BY Total DESC) AS Posicao
    FROM FaturamentoClinica
)
SELECT cl.Nome, rc.Total, rc.Posicao
FROM RankingClinica rc INNER JOIN Clinica cl ON cl.Id = rc.IdClinica
ORDER BY rc.Posicao;
```

**14.**
```sql
-- Não é possível com o modelo atual: Medico tem uma única coluna IdEspecialidade
-- (relação 1:N). Cada médico só pode ter UMA especialidade. Para suportar
-- múltiplas especialidades por médico seria necessário criar uma tabela
-- associativa MedicoEspecialidade (IdMedico, IdEspecialidade), mudando para N:N.
```

**15.**
```sql
;WITH PacientesPorCidade AS (
    SELECT p.Id, p.Nome, ci.Nome AS Cidade
    FROM Paciente p
    INNER JOIN Endereco e ON e.Id = p.IdEndereco
    INNER JOIN Cidade ci ON ci.Id = e.IdCidade
)
SELECT * FROM PacientesPorCidade WHERE Cidade = 'Sao Paulo';
```

**16.**
```sql
DECLARE @Ano INT = 2026, @Mes INT = 5;

;WITH FaturamentoDiario AS (
    SELECT CAST(DataHora AS DATE) AS Dia, SUM(ValorBase) AS Total
    FROM Consulta
    WHERE IdStatusConsulta = 3 AND YEAR(DataHora) = @Ano AND MONTH(DataHora) = @Mes
    GROUP BY CAST(DataHora AS DATE)
),
ComOrdem AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY Dia) AS rn FROM FaturamentoDiario
),
Acumulado AS (
    SELECT Dia, Total, Total AS Acumulado, rn FROM ComOrdem WHERE rn = 1
    UNION ALL
    SELECT co.Dia, co.Total, a.Acumulado + co.Total, co.rn
    FROM Acumulado a INNER JOIN ComOrdem co ON co.rn = a.rn + 1
)
SELECT Dia, Total, Acumulado FROM Acumulado
OPTION (MAXRECURSION 31);
```
> Bem mais trabalhoso que a versão com `SUM() OVER` da seção de Window Functions — é o próprio contraste que o exercício ilustra.

**17.**
```sql
;WITH FaixaValor AS (
    SELECT Id,
        CASE WHEN ValorBase < 200 THEN 'Baixo'
             WHEN ValorBase BETWEEN 200 AND 500 THEN 'Médio'
             ELSE 'Alto' END AS Faixa
    FROM Consulta
)
SELECT Faixa, COUNT(*) AS Qtd FROM FaixaValor GROUP BY Faixa;
```

**18.**
```sql
;WITH ConsultasSentinela AS (
    SELECT Id FROM Consulta WHERE DataHora IN ('1900-01-01', '2050-12-31')
)
DELETE c
FROM Consulta c
INNER JOIN ConsultasSentinela cs ON cs.Id = c.Id;
```

**19.**
```sql
;WITH TelemedicinaSemPlataforma AS (
    SELECT Id FROM Consulta WHERE IdTipoAtendimento = 2 AND PlataformaTelemedicina IS NULL
)
UPDATE c
SET c.PlataformaTelemedicina = 'Não informado'
FROM Consulta c
INNER JOIN TelemedicinaSemPlataforma t ON t.Id = c.Id;
```

**20.**
```sql
;WITH FaturamentoClinica AS (
    SELECT cl.Id AS IdClinica, ci.IdEstado, SUM(c.ValorBase) AS Total
    FROM Consulta c
    INNER JOIN Medico m ON m.Id = c.IdMedico
    INNER JOIN Clinica cl ON cl.Id = m.IdClinica
    INNER JOIN Endereco e ON e.Id = cl.IdEndereco
    INNER JOIN Cidade ci ON ci.Id = e.IdCidade
    WHERE c.IdStatusConsulta = 3
    GROUP BY cl.Id, ci.IdEstado
),
RankingPorEstado AS (
    SELECT *, RANK() OVER (PARTITION BY IdEstado ORDER BY Total DESC) AS Posicao
    FROM FaturamentoClinica
)
SELECT es.Nome AS Estado, cl.Nome AS Clinica, r.Total
FROM RankingPorEstado r
INNER JOIN Clinica cl ON cl.Id = r.IdClinica
INNER JOIN Estado es ON es.Id = r.IdEstado
WHERE r.Posicao = 1;
```

---

## Window Functions

**1.**
```sql
;WITH UltimasConsultas AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY IdPaciente ORDER BY DataHora DESC) AS rn
    FROM Consulta
)
SELECT * FROM UltimasConsultas WHERE rn <= 3;
```

**2.**
```sql
SELECT m.Nome, SUM(c.ValorBase) AS FaturamentoTotal,
       RANK() OVER (ORDER BY SUM(c.ValorBase) DESC) AS Ranking
FROM Medico m
LEFT JOIN Consulta c ON c.IdMedico = m.Id AND c.IdStatusConsulta = 3
GROUP BY m.Id, m.Nome;
```

**3.**
```sql
SELECT p.Nome, SUM(c.ValorBase) AS TotalGasto,
       DENSE_RANK() OVER (ORDER BY SUM(c.ValorBase) DESC) AS Posicao
FROM Paciente p
INNER JOIN Consulta c ON c.IdPaciente = p.Id AND c.IdStatusConsulta = 3
GROUP BY p.Id, p.Nome;
```

**4.**
```sql
SELECT Id, Codigo, DataHora, ValorBase,
       SUM(ValorBase) OVER (PARTITION BY IdPaciente) AS TotalGastoPaciente
FROM Consulta;
```

**5.**
```sql
SELECT Id, Codigo, IdMedico, ValorBase,
       AVG(ValorBase) OVER (PARTITION BY IdMedico) AS MediaDoMedico
FROM Consulta;
```

**6.**
```sql
SELECT IdPaciente, Codigo, DataHora,
       LAG(DataHora) OVER (PARTITION BY IdPaciente ORDER BY DataHora) AS ConsultaAnterior
FROM Consulta;
```

**7.**
```sql
SELECT IdPaciente, Codigo, DataHora,
       LEAD(DataHora) OVER (PARTITION BY IdPaciente ORDER BY DataHora) AS ProximaConsulta
FROM Consulta;
```

**8.**
```sql
;WITH TotalPorPaciente AS (
    SELECT IdPaciente, SUM(ValorBase) AS Total
    FROM Consulta WHERE IdStatusConsulta = 3
    GROUP BY IdPaciente
)
SELECT IdPaciente, Total, NTILE(4) OVER (ORDER BY Total DESC) AS Quartil
FROM TotalPorPaciente;
```

**9.**
```sql
SELECT IdMedico, Codigo, DataHora,
       FIRST_VALUE(Codigo) OVER (PARTITION BY IdMedico ORDER BY DataHora) AS PrimeiraConsulta
FROM Consulta;
```

**10.**
```sql
SELECT IdMedico, Codigo, DataHora,
       LAST_VALUE(Codigo) OVER (
           PARTITION BY IdMedico ORDER BY DataHora
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS UltimaConsulta
FROM Consulta;
```

**11.**
```sql
SELECT DataHora, ValorBase,
       SUM(ValorBase) OVER (ORDER BY DataHora ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS SomaMovel3Consultas
FROM Consulta
ORDER BY DataHora;
```

**12.**
```sql
SELECT Id, Codigo, IdStatusConsulta,
       COUNT(*) OVER (PARTITION BY IdStatusConsulta) AS QtdNoMesmoStatus
FROM Consulta;
```

**13.**
```sql
SELECT Id, Codigo, ValorBase,
       PERCENT_RANK() OVER (ORDER BY ValorBase) AS PosicaoPercentual
FROM Consulta;
```

**14.**
```sql
;WITH FaturamentoMedico AS (
    SELECT IdMedico, SUM(ValorBase) AS Total
    FROM Consulta WHERE IdStatusConsulta = 3
    GROUP BY IdMedico
)
SELECT IdMedico, Total, CUME_DIST() OVER (ORDER BY Total) AS DistribuicaoAcumulada
FROM FaturamentoMedico;
```

**15.**
```sql
SELECT m.Nome AS Medico, esp.Nome AS Especialidade, SUM(c.ValorBase) AS FaturamentoTotal,
       RANK() OVER (PARTITION BY esp.Id ORDER BY SUM(c.ValorBase) DESC) AS RankingNaEspecialidade
FROM Medico m
INNER JOIN Especialidade esp ON esp.Id = m.IdEspecialidade
LEFT JOIN Consulta c ON c.IdMedico = m.Id AND c.IdStatusConsulta = 3
GROUP BY m.Id, m.Nome, esp.Id, esp.Nome;
```

**16.**
```sql
;WITH ConsultasNumeradas AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY IdPaciente, IdMedico, DataHora ORDER BY Id) AS rn
    FROM Consulta
)
SELECT * FROM ConsultasNumeradas WHERE rn > 1;
```

**17.**
```sql
;WITH ConsultasClinica AS (
    SELECT c.DataHora, c.ValorBase
    FROM Consulta c INNER JOIN Medico m ON m.Id = c.IdMedico
    WHERE m.IdClinica = 1 AND c.IdStatusConsulta = 3
)
SELECT DataHora, ValorBase,
       SUM(ValorBase) OVER (ORDER BY DataHora ROWS UNBOUNDED PRECEDING) AS ReceitaAcumulada
FROM ConsultasClinica
ORDER BY DataHora;
```

**18.**
```sql
SELECT IdPaciente, Codigo, DataHora,
       MIN(DataHora) OVER (PARTITION BY IdPaciente) AS PrimeiraConsulta,
       MAX(DataHora) OVER (PARTITION BY IdPaciente) AS UltimaConsulta
FROM Consulta;
```

**19.**
```sql
;WITH ConsultasPaginadas AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY DataHora) AS rn FROM Consulta
)
SELECT * FROM ConsultasPaginadas WHERE rn BETWEEN 21 AND 30;
```

**20.**
```sql
;WITH FaturamentoMedico AS (
    SELECT m.IdClinica, m.Id AS IdMedico, m.Nome, SUM(c.ValorBase) AS Total
    FROM Medico m
    INNER JOIN Consulta c ON c.IdMedico = m.Id AND c.IdStatusConsulta = 3
    GROUP BY m.IdClinica, m.Id, m.Nome
),
Ranking AS (
    SELECT *, RANK() OVER (PARTITION BY IdClinica ORDER BY Total DESC) AS Posicao
    FROM FaturamentoMedico
)
SELECT cl.Nome AS Clinica, r.Nome AS Medico, r.Total
FROM Ranking r INNER JOIN Clinica cl ON cl.Id = r.IdClinica
WHERE r.Posicao = 1;
```

---

## Indexes

**1.**
```sql
CREATE NONCLUSTERED INDEX IX_Consulta_IdPaciente ON Consulta (IdPaciente);
```

**2.**
```sql
CREATE NONCLUSTERED INDEX IX_Consulta_IdMedico_DataHora ON Consulta (IdMedico, DataHora);
```

**3.**
```sql
CREATE NONCLUSTERED INDEX IX_Medico_IdClinica ON Medico (IdClinica);
```

**4.**
```sql
CREATE NONCLUSTERED INDEX IX_Paciente_IdEndereco ON Paciente (IdEndereco);
```
> Linhas com `IdEndereco NULL` ainda fazem parte da estrutura física do índice, mas `NULL` não é igual a `NULL` em comparação padrão — não há "seek por igualdade" eficiente para localizá-las, apenas scan ou uso de `IS NULL` (que o otimizador trata de forma específica).

**5.**
```sql
CREATE NONCLUSTERED INDEX IX_Consulta_Status_Covering
ON Consulta (IdStatusConsulta)
INCLUDE (ValorBase, DataHora);
```

**6.**
```sql
SELECT OBJECT_NAME(s.object_id) AS Tabela, i.name AS Indice,
       s.user_seeks, s.user_scans, s.user_lookups, s.user_updates
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE OBJECT_NAME(s.object_id) = 'Consulta' AND i.name = 'IX_Consulta_IdPaciente';
```

**7.**
```sql
CREATE NONCLUSTERED INDEX IX_Consulta_Pendentes
ON Consulta (DataHora)
WHERE IdStatusConsulta = 1;
```

**8.**
```sql
CREATE UNIQUE NONCLUSTERED INDEX UQ_Consulta_CodigoAutorizacao
ON Consulta (CodigoAutorizacao)
WHERE CodigoAutorizacao IS NOT NULL;
```
> Um índice único "tradicional" permitiria múltiplos `NULL` (o SQL Server trata cada `NULL` como distinto em índice único comum). O índice **filtrado** acima é a forma correta de garantir unicidade apenas onde o valor realmente existe.

**9.**
```sql
SET STATISTICS IO ON;
SELECT * FROM Consulta WHERE IdPaciente = 1; -- rodar antes do índice

-- CREATE NONCLUSTERED INDEX IX_Consulta_IdPaciente ON Consulta (IdPaciente);

SELECT * FROM Consulta WHERE IdPaciente = 1; -- rodar depois do índice, comparar logical reads
SET STATISTICS IO OFF;
```

**10.**
```sql
CREATE NONCLUSTERED INDEX IX_Cidade_IdEstado ON Cidade (IdEstado);
```

**11.**
```sql
ALTER INDEX IX_Consulta_IdPaciente ON Consulta REBUILD;
```

**12.**
```sql
ALTER INDEX IX_Consulta_IdPaciente ON Consulta REORGANIZE;
```
> `REORGANIZE`: operação online e mais leve, indicada para fragmentação entre ~10% e 30%. `REBUILD`: reconstrói o índice do zero, mais pesado, indicado acima de ~30%.

**13.**
```sql
CREATE NONCLUSTERED INDEX IX_Consulta_Status_Tipo ON Consulta (IdStatusConsulta, IdTipoAtendimento);
```

**14.**
```sql
SELECT i.name AS NomeIndice, i.type_desc AS Tipo, i.is_unique
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID('Consulta') AND i.name IS NOT NULL;
```

**15.**
```sql
-- Não é necessário: a constraint UQ_Paciente_Documento já cria automaticamente
-- um índice nonclustered único sobre Documento. Um índice manual seria redundante.
```

**16.**
```sql
-- Mesma lógica: UQ_Medico_CRM já gera um índice único automaticamente sobre CRM.
```

**17.**
```sql
-- Já existe: a constraint UQ_Consulta_Codigo cria um índice único automaticamente.
-- Caso não existisse, o equivalente manual seria:
CREATE UNIQUE NONCLUSTERED INDEX UQ_Consulta_Codigo_Manual ON Consulta (Codigo);
```

**18.**
```sql
SELECT OBJECT_NAME(i.object_id) AS Tabela, i.name AS Indice
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats s ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE OBJECT_NAME(i.object_id) = 'Consulta'
  AND i.name IS NOT NULL
  AND (s.user_seeks IS NULL OR (s.user_seeks = 0 AND s.user_scans = 0 AND s.user_lookups = 0));
```

**19.**
```sql
CREATE NONCLUSTERED COLUMNSTORE INDEX IX_Consulta_Columnstore
ON Consulta (IdPaciente, IdMedico, IdStatusConsulta, IdTipoAtendimento, DataHora, ValorBase);
```
> Faz sentido em cenários analíticos (BI/relatórios) com agregações sobre grande volume de `Consulta`. Não é indicado para a carga transacional do dia a dia (INSERT/UPDATE linha a linha feitos pela aplicação e pelos Jobs), pois columnstore tem custo de manutenção mais alto em updates frequentes.

**20.**
```sql
CREATE NONCLUSTERED INDEX IX_Endereco_IdCidade ON Endereco (IdCidade);
```
> Sem esse índice, qualquer query que percorra `Paciente → Endereco → Cidade → Estado` faz table scan em `Endereco` para resolver o `JOIN` com `Cidade`, mesmo que os índices de `Cidade.IdEstado` e `Paciente.IdEndereco` já existam.
