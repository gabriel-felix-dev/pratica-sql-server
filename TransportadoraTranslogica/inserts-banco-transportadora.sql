
USE TransportadoraTransLogica;
GO

DELETE FROM Carga;
DELETE FROM ParadaViagem;
DELETE FROM Viagem;
DELETE FROM Veiculo;
DELETE FROM Motorista;
DELETE FROM Filial;
DELETE FROM Cliente;
DELETE FROM Endereco;
DELETE FROM Cidade;
DELETE FROM Estado;
GO

INSERT INTO Estado (Nome, UF)
VALUES  ('Sao Paulo', 'SP'),
        ('Rio de Janeiro', 'RJ'),
        ('Minas Gerais', 'MG'),
        ('Parana', 'PR'),
        ('Rio Grande do Sul', 'RS');
GO

INSERT INTO Cidade (IdEstado, Nome)
VALUES  (1, 'Sao Paulo'),
        (1, 'Campinas'),
        (1, 'Santos'),
        (2, 'Rio de Janeiro'),
        (2, 'Niteroi'),
        (3, 'Belo Horizonte'),
        (3, 'Uberlandia'),
        (4, 'Curitiba'),
        (4, 'Londrina'),
        (5, 'Porto Alegre');
GO

DECLARE @i INT = 1;
DECLARE @Logradouro VARCHAR(255);
DECLARE @Numero VARCHAR(20);
DECLARE @Bairro VARCHAR(100);
DECLARE @CEP VARCHAR(15);
DECLARE @IdCidade INT;

WHILE @i <= 500
BEGIN
    SET @Logradouro = CHOOSE(1 + (@i % 5), 'Avenida Paulista', 'Rua das Flores', 'Avenida Brasil', 'Rua Sete de Setembro', 'Rua Voluntarios da Patria') + ', ' + CAST(@i AS VARCHAR);

    SET @Numero = CASE WHEN @i % 10 = 0 THEN NULL ELSE CAST(10 + (@i * 3) AS VARCHAR) END;

    SET @Bairro = CASE WHEN @i % 20 = 0 THEN NULL ELSE CHOOSE(1 + (@i % 4), 'Centro', 'Jardins', 'Vila Nova', 'Copacabana') END;

    SET @CEP = CASE WHEN @i % 15 = 0 THEN '00000000' ELSE RIGHT('00000000' + CAST(@i * 12345 AS VARCHAR), 8) END;

    SET @IdCidade = 1 + (@i % 10);

    INSERT INTO Endereco (IdCidade, Logradouro, Numero, Bairro, CEP)
    VALUES (@IdCidade, @Logradouro, @Numero, @Bairro, @CEP);

    SET @i = @i + 1;
END;
GO

INSERT INTO Filial (IdEndereco, Nome)
VALUES  (10, 'Filial Sao Paulo Centro'),
        (11, 'Filial Campinas Norte'),
        (20, 'Filial Santos Porto'),
        (13, 'Filial Rio de Janeiro Zona Sul'),
        (23, 'Filial Niteroi Express'),
        (15, 'Filial Belo Horizonte Central'),
        (25, 'Filial Uberlandia Cargas'),
        (10, 'Filial Curitiba Portao'),
        (20, 'Filial Londrina Industrial'),
        (19, 'Filial Porto Alegre Sul'),
        (20, 'Filial Sao Paulo Leste'),
        (23, 'Filial Rio de Janeiro Caju'),
        (25, 'Filial Belo Horizonte Contagem'),
        (15, 'Filial Curitiba CIC'),
        (29, 'Filial Porto Alegre Aeroporto');
GO

DECLARE @j INT = 1;
DECLARE @NomeMotorista VARCHAR(150);
DECLARE @CNH VARCHAR(20);
DECLARE @TelefoneMotorista VARCHAR(20);

WHILE @j <= 50
BEGIN
    SET @NomeMotorista = CHOOSE(1 + (@j % 6), 'Marcos', 'Lucas', 'Roberto', 'Carlos', 'Julio', 'Antonio') + ' ' + CHOOSE(1 + (@j % 5), 'Silva', 'Santos', 'Oliveira', 'Pereira', 'Almeida') + ' ' + CAST(@j AS VARCHAR);
    SET @CNH = '987654' + RIGHT('00000' + CAST(@j AS VARCHAR), 5);
    SET @TelefoneMotorista = CASE WHEN @j % 8 = 0 THEN NULL ELSE '(11) 9' + RIGHT('00000000' + CAST(@j * 11111111 AS VARCHAR), 8) END;

    INSERT INTO Motorista (Nome, CNH, Telefone) VALUES (@NomeMotorista, @CNH, @TelefoneMotorista);
    SET @j = @j + 1;
END;
GO

DECLARE @k INT = 1;
DECLARE @Placa CHAR(7);
DECLARE @Modelo VARCHAR(100);
DECLARE @Capacidade DECIMAL(10,2);

WHILE @k <= 40
BEGIN
    SET @Placa = CHOOSE(1 + (@k % 5), 'ABC', 'DEF', 'GHI', 'JKL', 'MNO') + RIGHT('0000' + CAST(@k * 123 AS VARCHAR), 4);
    SET @Modelo = CHOOSE(1 + (@k % 4), 'Mercedes Benz Axor', 'Scania R450', 'Volvo FH 540', 'VW Delivery');
    SET @Capacidade = CHOOSE(1 + (@k % 4), 3500.00, 8000.00, 15000.00, 25000.00);

    INSERT INTO Veiculo (Placa, Modelo, CapacidadePeso) VALUES (@Placa, @Modelo, @Capacidade);
    SET @k = @k + 1;
END;
GO

DECLARE @l INT = 1;
DECLARE @IdVeiculo INT;
DECLARE @IdMotorista INT;
DECLARE @IdFilial TINYINT;
DECLARE @DataSaida DATETIME;
DECLARE @DataChegada DATETIME;
DECLARE @KmInicial INT;
DECLARE @KmFinal INT;
DECLARE @d1 INT, @d2 INT, @d3 INT, @dMax INT;
DECLARE @HasStop2 BIT, @HasStop3 BIT;
DECLARE @ViagemId INT;

WHILE @l <= 250
BEGIN
    SET @IdVeiculo = 1 + (@l % 40);
    SET @IdMotorista = 1 + (@l % 50);
    SET @IdFilial = 1 + (@l % 15);
    SET @DataSaida = DATEADD(DAY, -@l, GETDATE());
    SET @KmInicial = @l * 120;

    SET @DataChegada = CASE WHEN @l % 7 = 0 THEN NULL ELSE DATEADD(HOUR, 12 + (@l % 36), @DataSaida) END;

    SET @d1 = 150 + (@l % 100);
    SET @HasStop2 = CASE WHEN @l % 3 != 0 THEN 1 ELSE 0 END;
    SET @d2 = @d1 + CASE WHEN @HasStop2 = 1 THEN 200 + (@l % 150) ELSE 0 END;
    SET @HasStop3 = CASE WHEN @HasStop2 = 1 AND @l % 5 != 0 THEN 1 ELSE 0 END;
    SET @d3 = @d2 + CASE WHEN @HasStop3 = 1 THEN 180 + (@l % 100) ELSE 0 END;

    SET @dMax = CASE WHEN @HasStop3 = 1 THEN @d3 WHEN @HasStop2 = 1 THEN @d2 ELSE @d1 END;

    SET @KmFinal = CASE WHEN @l % 15 = 0 THEN NULL WHEN @DataChegada IS NULL THEN NULL ELSE @KmInicial + @dMax END;

    INSERT INTO Viagem (IdVeiculo, IdMotorista, IdFilialOrigem, DataSaida, DataChegada, QuilometragemInicial, QuilometragemFinal)
    VALUES (@IdVeiculo, @IdMotorista, @IdFilial, @DataSaida, @DataChegada, @KmInicial, @KmFinal);

    SET @ViagemId = SCOPE_IDENTITY();

    INSERT INTO ParadaViagem (IdViagem, IdCidade, OrdemParada, QuilometragemParcial, DataChegadaParada)
    VALUES (@ViagemId, 1 + ((@l + 1) % 10), 1, @d1, DATEADD(HOUR, 3 + (@l % 5), @DataSaida));

    IF @HasStop2 = 1
    BEGIN
        INSERT INTO ParadaViagem (IdViagem, IdCidade, OrdemParada, QuilometragemParcial, DataChegadaParada)
        VALUES (@ViagemId, 1 + ((@l + 2) % 10), 2, @d2, DATEADD(HOUR, 8 + (@l % 5), @DataSaida));
    END

    IF @HasStop3 = 1
    BEGIN
        INSERT INTO ParadaViagem (IdViagem, IdCidade, OrdemParada, QuilometragemParcial, DataChegadaParada)
        VALUES (@ViagemId, 1 + ((@l + 3) % 10), 3, @d3, DATEADD(HOUR, 14 + (@l % 5), @DataSaida));
    END

    SET @l = @l + 1;
END;
GO

DECLARE @c INT = 1;
DECLARE @NomeCliente VARCHAR(150);
DECLARE @DocCliente VARCHAR(20);
DECLARE @TelCliente VARCHAR(20);
DECLARE @IdEndCliente INT;

WHILE @c <= 996
BEGIN

    SET @NomeCliente =
        CHOOSE(1 + (@c % 35),
            'João', 'Maria', 'Ana', 'Pedro', 'José', 'Paulo', 'Fernanda', 'Carlos', 'Lucas', 'Gabriel',
            'Bruno', 'Camila', 'Amanda', 'Juliana', 'Leticia', 'Mariana', 'Rodrigo', 'Rafael', 'Marcos', 'André',
            'Gustavo', 'Fernando', 'Patricia', 'Aline', 'Beatriz', 'Sofia', 'Daniel', 'Felipe', 'Leonardo', 'Thiago',
            'Ricardo', 'Eduardo', 'Julia', 'Bianca', 'Isabela'
        )
        + ' ' +
        CHOOSE(1 + ((@c / 35) % 35),
            'Silva', 'Santos', 'Oliveira', 'Souza', 'Rodrigues', 'Ferreira', 'Alves', 'Pereira', 'Lima', 'Gomes',
            'Costa', 'Ribeiro', 'Martins', 'Carvalho', 'Almeida', 'Lopes', 'Soares', 'Fernandes', 'Vieira', 'Barbosa',
            'Rocha', 'Dias', 'Nascimento', 'Andrade', 'Moreira', 'Nunes', 'Marques', 'Machado', 'Mendes', 'Freitas',
            'Cardoso', 'Ramos', 'Gonçalves', 'Santana', 'Teixeira'
        );

    SET @DocCliente = CASE WHEN @c % 3 = 0
        THEN RIGHT('00000000000000' + CAST(CAST(@c AS BIGINT) * 12345678901234 AS VARCHAR(30)), 14)
        ELSE RIGHT('00000000000' + CAST(CAST(@c AS BIGINT) * 98765432101 AS VARCHAR(30)), 11)
    END;

    SET @TelCliente = CASE WHEN @c % 12 = 0 THEN NULL ELSE '(11) 9' + RIGHT('00000000' + CAST(CAST(@c AS BIGINT) * 22222222 AS VARCHAR(30)), 8) END;

    SET @IdEndCliente = CASE WHEN @c % 20 = 0 THEN NULL ELSE 1 + (@c % 500) END;

    INSERT INTO Cliente (IdEndereco, Nome, Documento, Telefone)
    VALUES (@IdEndCliente, @NomeCliente, @DocCliente, @TelCliente);

    SET @c = @c + 1;
END;
GO

DECLARE @cg INT = 1;
DECLARE @IdCli INT;
DECLARE @IdTipo TINYINT;
DECLARE @IdStatus TINYINT;
DECLARE @IdParada INT;
DECLARE @IdEndEnt INT;
DECLARE @Cod VARCHAR(50);
DECLARE @Peso DECIMAL(10,2);
DECLARE @Valor DECIMAL(12,2);
DECLARE @MatEmb VARCHAR(100);
DECLARE @RiskCl VARCHAR(50);
DECLARE @ONU INT;
DECLARE @MaxParadas INT;

SELECT @MaxParadas = MAX(Id) FROM ParadaViagem;

WHILE @cg <= 2891
BEGIN
    SET @IdCli = 1 + (@cg % 996);
    SET @IdTipo = 1 + (@cg % 3);
    SET @IdStatus = 1 + (@cg % 4);

    SET @IdParada = CASE WHEN @cg % 3 = 0 THEN NULL ELSE 1 + (@cg % @MaxParadas) END;

    SET @IdEndEnt = CASE WHEN @cg % 10 < 4 THEN NULL ELSE 1 + (@cg % 500) END;

    SET @Cod = 'CG' + RIGHT('00000' + CAST(@cg AS VARCHAR), 5);
    SET @Peso = 0.50 + (@cg % 1000) * 0.75;
    SET @Valor = 10.00 + (@cg % 5000) * 2.50;

    IF @IdTipo = 1
    BEGIN
        SET @MatEmb = NULL;
        SET @RiskCl = NULL;
        SET @ONU = NULL;
    END
    ELSE IF @IdTipo = 2
    BEGIN

        SET @MatEmb = CASE WHEN @cg % 10 = 0 THEN NULL ELSE CHOOSE(1 + (@cg % 4), 'Isopor', 'Plastico Bolha', 'Caixa de Madeira', 'Papelao Ondulado') END;
        SET @RiskCl = NULL;
        SET @ONU = NULL;
    END
    ELSE IF @IdTipo = 3
    BEGIN
        SET @MatEmb = NULL;

        SET @RiskCl = CASE WHEN @cg % 10 = 0 THEN NULL ELSE CHOOSE(1 + (@cg % 4), 'Inflamavel', 'Corrosivo', 'Toxico', 'Radioativo') END;
        SET @ONU = CASE WHEN @cg % 10 = 0 THEN NULL ELSE 1000 + (@cg % 8999) END;
    END

    INSERT INTO Carga (IdCliente, IdTipoCarga, IdStatusEnvio, IdParadaEntrega, IdEnderecoEntrega, Codigo, Peso, ValorDeclarado, MaterialEmbalagem, ClasseRisco, NumeroONU)
    VALUES (@IdCli, @IdTipo, @IdStatus, @IdParada, @IdEndEnt, @Cod, @Peso, @Valor, @MatEmb, @RiskCl, @ONU);

    SET @cg = @cg + 1;
END;
GO
