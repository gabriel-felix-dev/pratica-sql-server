-- =========================================================================
-- Script de População do Banco de Dados Hotel
-- Objetivo: Inserir dados de teste para simulações e exercícios
-- =========================================================================
-- Datas relativas a GETDATE() para que a massa continue coerente em qualquer
-- data de execução: hospedagens em andamento sempre cobrem o dia atual.
-- Literais de data no formato ISO sem separador (YYYYMMDD): a variante com
-- hífen depende do DATEFORMAT/LANGUAGE da sessão e inverte dia/mês em pt-BR.
-- =========================================================================

USE hotel_avaliacao;
GO

-- 1. Inserir Hóspedes - 100 registros
INSERT INTO [dbo].[Hospede] (Nome, Cpf, Email, Telefone, DataNascimento)
    VALUES  ('Pedro Fernando Almeida', '312.457.890-11', 'pedro.almeida@gmail.com', '(11) 98472-3310', '19850314'),
            ('Mariana Souza Ribeiro', '104.882.376-45', 'mariana.ribeiro@hotmail.com', '(21) 99136-4472', '19900722'),
            ('Carlos Eduardo Nogueira', '227.913.604-08', 'carlos.nogueira@outlook.com', '(31) 98821-5590', '19780205'),
            ('Ana Beatriz Carvalho', '458.220.117-63', 'ana.carvalho@gmail.com', '(41) 99654-1238', '19930918'),
            ('Rafael Augusto Lima', '631.045.298-22', 'rafael.lima@yahoo.com.br', '(51) 98330-7745', '19821130'),
            ('Juliana Martins Pires', '750.318.462-97', 'juliana.pires@gmail.com', '(61) 99277-8814', '19951203'),
            ('Bruno Henrique Castro', '018.674.523-30', 'bruno.castro@uol.com.br', '(71) 98145-2236', '19870426'),
            ('Camila Andrade Rocha', '596.782.140-54', 'camila.rocha@gmail.com', '(81) 99562-3391', '19910617'),
            ('Thiago Moreira Barros', '843.159.027-16', 'thiago.barros@hotmail.com', '(85) 98874-6620', '19800809'),
            ('Larissa Gomes Teixeira', '269.531.874-70', 'larissa.teixeira@gmail.com', '(47) 99423-1187', '19970124'),
            ('Felipe Antunes Cardoso', '371.208.965-83', 'felipe.cardoso@outlook.com', '(48) 98712-4405', '19860311'),
            ('Patrícia Oliveira Ramos', '482.617.039-25', 'patricia.ramos@gmail.com', '(19) 99358-7762', '19890528'),
            ('Gustavo Henrique Farias', '905.473.128-61', 'gustavo.farias@terra.com.br', '(16) 98267-3318', '19750914'),
            ('Fernanda Lopes Siqueira', '156.938.704-49', 'fernanda.siqueira@gmail.com', '(27) 99681-5524', '19920207'),
            ('Ricardo Mendes Vieira', '634.827.591-02', 'ricardo.vieira@hotmail.com', '(62) 98539-2276', '19831022'),
            ('Aline Cristina Duarte', '718.294.365-57', 'aline.duarte@gmail.com', '(34) 99147-8830', '19960713'),
            ('Marcelo Tavares Pinto', '023.751.689-94', 'marcelo.pinto@bol.com.br', '(13) 98462-9915', '19790419'),
            ('Vanessa Ribeiro Correia', '540.176.283-38', 'vanessa.correia@gmail.com', '(91) 99805-3367', '19940830'),
            ('Leonardo Braga Fonseca', '867.402.951-13', 'leonardo.fonseca@icloud.com', '(65) 98371-4482', '19881205'),
            ('Isabela Nunes Cavalcanti', '394.658.720-86', 'isabela.cavalcanti@gmail.com', '(98) 99524-6673', '19990316'),
            ('Rodrigo Peixoto Macedo', '205.839.417-62', 'rodrigo.macedo@gmail.com', '(11) 97688-2214', '19810708'),
            ('Beatriz Amaral Freitas', '471.902.638-05', 'beatriz.freitas@hotmail.com', '(21) 98456-7731', '19930422'),
            ('André Luiz Batista', '689.315.204-71', 'andre.batista@outlook.com', '(31) 99213-5548', '19770129'),
            ('Carolina Dias Monteiro', '132.746.859-40', 'carolina.monteiro@gmail.com', '(41) 98774-3362', '19900611'),
            ('Vinícius Rocha Sampaio', '806.237.415-29', 'vinicius.sampaio@yahoo.com.br', '(51) 99862-1195', '19850925'),
            ('Letícia Barbosa Moura', '517.680.293-64', 'leticia.moura@gmail.com', '(61) 98341-7726', '19981107'),
            ('Diego Ferreira Coelho', '748.129.503-17', 'diego.coelho@uol.com.br', '(71) 99275-4483', '19840216'),
            ('Priscila Nunes Aguiar', '260.457.938-82', 'priscila.aguiar@gmail.com', '(81) 98693-2250', '19911024'),
            ('Eduardo Santos Bezerra', '935.814.270-56', 'eduardo.bezerra@hotmail.com', '(85) 99518-6637', '19760503'),
            ('Natália Prado Xavier', '083.592.647-31', 'natalia.xavier@gmail.com', '(47) 98247-9914', '19950819'),
            ('Gabriel Moura Rezende', '619.374.852-08', 'gabriel.rezende@outlook.com', '(48) 99630-2278', '19890127'),
            ('Amanda Figueiredo Pinheiro', '427.065.913-75', 'amanda.pinheiro@gmail.com', '(19) 98156-4463', '19930705'),
            ('Lucas Almeida Guimarães', '350.918.276-49', 'lucas.guimaraes@hotmail.com', '(16) 99784-3325', '19801219'),
            ('Renata Cunha Medeiros', '862.501.437-93', 'renata.medeiros@gmail.com', '(27) 98429-6671', '19870908'),
            ('Fábio Junqueira Neves', '174.639.028-50', 'fabio.neves@terra.com.br', '(62) 99361-2284', '19741111'),
            ('Bianca Rezende Campos', '508.246.791-36', 'bianca.campos@gmail.com', '(34) 98573-4419', '19960402'),
            ('Otávio Cardoso Brandão', '693.157.480-27', 'otavio.brandao@outlook.com', '(13) 99208-5537', '19830623'),
            ('Tatiane Souza Miranda', '245.870.163-84', 'tatiane.miranda@gmail.com', '(91) 98614-7792', '19920315'),
            ('Henrique Lacerda Pontes', '916.482.357-10', 'henrique.pontes@hotmail.com', '(65) 99457-3368', '19790226'),
            ('Jéssica Moraes Antunes', '037.625.948-71', 'jessica.antunes@gmail.com', '(98) 98392-6614', '19971030'),
            ('Murilo Pacheco Fontes', '581.204.736-95', 'murilo.fontes@uol.com.br', '(11) 99743-8825', '19860517'),
            ('Débora Carvalho Bastos', '764.318.502-46', 'debora.bastos@gmail.com', '(21) 98267-4413', '19900204'),
            ('Alexandre Vieira Quintana', '129.546.873-62', 'alexandre.quintana@outlook.com', '(31) 99825-7736', '19771208'),
            ('Sabrina Teixeira Lobo', '470.983.215-07', 'sabrina.lobo@gmail.com', '(41) 98351-2249', '19941121'),
            ('Caio Bernardes Sales', '852.607.391-58', 'caio.sales@hotmail.com', '(51) 99174-6682', '19881003'),
            ('Michele Arruda Padilha', '306.795.124-83', 'michele.padilha@gmail.com', '(61) 98628-3357', '19930709'),
            ('Rogério Tavares Bonfim', '647.130.859-24', 'rogerio.bonfim@bol.com.br', '(71) 99483-1170', '19810414'),
            ('Elaine Cristina Nogueira', '218.964.507-39', 'elaine.nogueira@gmail.com', '(81) 98745-9926', '19960826'),
            ('Wesley Ramos Cordeiro', '593.481.026-75', 'wesley.cordeiro@outlook.com', '(85) 99316-4483', '19850131'),
            ('Simone Barreto Aguiar', '760.259.384-16', 'simone.aguiar@gmail.com', '(47) 98592-7714', '19900618'),
            ('Marcos Vinícius Leal', '435.816.972-60', 'marcos.leal@gmail.com', '(48) 99267-3348', '19831205'),
            ('Daniela Prado Machado', '128.703.465-92', 'daniela.machado@hotmail.com', '(19) 98431-6675', '19911102'),
            ('Igor Fontenele Barbosa', '906.542.178-34', 'igor.barbosa@gmail.com', '(16) 99628-4417', '19870320'),
            ('Raquel Moreira Vasques', '274.619.503-88', 'raquel.vasques@outlook.com', '(27) 98157-2263', '19940913'),
            ('Sérgio Luiz Pimentel', '651.037.924-15', 'sergio.pimentel@terra.com.br', '(62) 99742-8836', '19720507'),
            ('Verônica Sales Dantas', '389.125.670-43', 'veronica.dantas@gmail.com', '(34) 98364-5529', '19980224'),
            ('Anderson Melo Cruz', '542.918.306-77', 'anderson.cruz@hotmail.com', '(13) 99856-1142', '19841016'),
            ('Cristina Maia Vasconcelos', '017.463.298-51', 'cristina.vasconcelos@gmail.com', '(91) 98273-6694', '19891207'),
            ('Paulo Roberto Esteves', '835.172.649-20', 'paulo.esteves@uol.com.br', '(65) 99418-3327', '19750629'),
            ('Tainá Ferreira Lustosa', '460.859.731-06', 'taina.lustosa@gmail.com', '(98) 98736-2218', '19970805'),
            ('Douglas Nascimento Reis', '193.624.058-72', 'douglas.reis@outlook.com', '(11) 99582-4471', '19860112'),
            ('Mônica Alves Pedrosa', '728.315.904-63', 'monica.pedrosa@gmail.com', '(21) 98149-7735', '19920428'),
            ('Everton Pires Salgado', '061.437.892-15', 'everton.salgado@hotmail.com', '(31) 99763-2286', '19800917'),
            ('Adriana Cordeiro Tavares', '574.902.163-49', 'adriana.tavares@gmail.com', '(41) 98518-3364', '19951206'),
            ('Leandro Bittencourt Rosa', '829.356.017-84', 'leandro.rosa@outlook.com', '(51) 99234-6618', '19831029'),
            ('Kelly Cristina Amorim', '346.781.209-57', 'kelly.amorim@gmail.com', '(61) 98675-4492', '19910714'),
            ('Rafael Siqueira Menezes', '902.168.354-71', 'rafael.menezes@bol.com.br', '(71) 99347-8823', '19770323'),
            ('Milena Torres Bastos', '215.879.046-38', 'milena.bastos@gmail.com', '(81) 98462-1159', '19960501'),
            ('Fernando Abreu Paiva', '683.024.517-96', 'fernando.paiva@hotmail.com', '(85) 99715-3342', '19820208'),
            ('Elisa Marques Pontual', '457.293.680-24', 'elisa.pontual@gmail.com', '(47) 98836-5571', '19931119'),
            ('Guilherme Nunes Sarmento', '730.615.428-09', 'guilherme.sarmento@outlook.com', '(48) 99182-4436', '19880605'),
            ('Bruna Carvalho Lisboa', '064.938.271-53', 'bruna.lisboa@gmail.com', '(19) 98524-7718', '19990227'),
            ('Tiago Ramires Falcão', '591.746.230-85', 'tiago.falcao@gmail.com', '(16) 99361-2247', '19851008'),
            ('Luciana Beserra Quirino', '248.507.913-67', 'luciana.quirino@hotmail.com', '(27) 98247-6693', '19900424'),
            ('Nelson Batista Ximenes', '815.362.074-51', 'nelson.ximenes@terra.com.br', '(62) 99534-8827', '19690712'),
            ('Roberta Lins Cavalcante', '372.148.596-03', 'roberta.cavalcante@gmail.com', '(34) 98671-2234', '19940316'),
            ('Sandro Luiz Bezerra', '609.253.817-46', 'sandro.bezerra@outlook.com', '(13) 99425-6673', '19781129'),
            ('Aline Maranhão Veloso', '154.867.320-92', 'aline.veloso@gmail.com', '(91) 98352-4418', '19920803'),
            ('Cláudio Roberto Pessoa', '726.091.483-57', 'claudio.pessoa@hotmail.com', '(65) 99618-2245', '19731005'),
            ('Karina Duarte Fontenele', '483.720.169-34', 'karina.fontenele@gmail.com', '(98) 98137-5562', '19970619'),
            ('Emerson Vilela Antunes', '038.914.652-70', 'emerson.antunes@uol.com.br', '(11) 99856-3317', '19840222'),
            ('Paula Regina Sobral', '795.231.048-16', 'paula.sobral@gmail.com', '(21) 98743-6629', '19910130'),
            ('Hugo Leonardo Passos', '260.578.913-45', 'hugo.passos@outlook.com', '(31) 99264-8871', '19871117'),
            ('Sheila Moraes Guedes', '517.842.396-02', 'sheila.guedes@gmail.com', '(41) 98615-2247', '19950708'),
            ('Ronaldo Tavares Lemos', '984.135.760-28', 'ronaldo.lemos@hotmail.com', '(51) 99372-4483', '19800426'),
            ('Jaqueline Souto Maior', '341.269.857-61', 'jaqueline.maior@gmail.com', '(61) 98428-7715', '19931002'),
            ('Wagner Ribeiro Peixoto', '675.910.234-83', 'wagner.peixoto@bol.com.br', '(71) 99586-1134', '19760914'),
            ('Viviane Castro Nobre', '128.453.697-20', 'viviane.nobre@gmail.com', '(81) 98269-3358', '19980311'),
            ('Sidney Alves Monteiro', '452.706.831-97', 'sidney.monteiro@outlook.com', '(85) 99147-5526', '19831223'),
            ('Marcela Vidal Aragão', '807.319.542-64', 'marcela.aragao@gmail.com', '(47) 98734-6612', '19900527'),
            ('Ítalo Ferreira Gondim', '263.581.074-39', 'italo.gondim@gmail.com', '(48) 99425-3387', '19860709'),
            ('Danilo Moreira Fontes', '590.628.317-45', 'danilo.fontes@hotmail.com', '(19) 98362-7741', '19921208'),
            ('Cíntia Rabelo Gusmão', '146.973.208-56', 'cintia.gusmao@gmail.com', '(16) 99518-2263', '19970415'),
            ('Alexandre Porto Seixas', '703.264.819-72', 'alexandre.seixas@outlook.com', '(27) 98146-5539', '19811106'),
            ('Nádia Cristina Belmonte', '358.027.146-83', 'nadia.belmonte@gmail.com', '(62) 99634-8817', '19940621'),
            ('Rafael Correia Bandeira', '619.850.472-31', 'rafael.bandeira@gmail.com', '(34) 98275-6648', '19871029'),
            ('Silvia Helena Marinho', '074.316.985-27', 'silvia.marinho@hotmail.com', '(13) 99683-4415', '19790812'),
            ('Joana Darc Rodrigues', '526.408.173-90', 'joana.rodrigues@gmail.com', '(91) 98527-3364', '19960205'),
            ('Marcio Antonio Lustosa', '381.759.026-48', 'marcio.lustosa@outlook.com', '(65) 99342-8876', '19741218'),
            ('Tereza Cristina Albuquerque', '940.183.657-25', 'tereza.albuquerque@gmail.com', '(98) 98456-1193', '19890923');
GO

-- 2. Inserir Quartos - 100 registros
-- 1º ao 2º andar (101-125): STANDARD | 2º andar (201-225): SUPERIOR
-- 3º andar (301-325): LUXO       | 4º andar (401-425): SUITE
-- Quartos 118, 224 e 317 estão inativos (em manutenção)
INSERT INTO [dbo].[Quarto] (Numero, Tipo, Capacidade, ValorDiaria, Ativo)
    VALUES  ('101', 'STANDARD', 2, 180.00, 1),
            ('102', 'STANDARD', 2, 180.00, 1),
            ('103', 'STANDARD', 2, 180.00, 1),
            ('104', 'STANDARD', 2, 195.00, 1),
            ('105', 'STANDARD', 2, 195.00, 1),
            ('106', 'STANDARD', 2, 180.00, 1),
            ('107', 'STANDARD', 2, 180.00, 1),
            ('108', 'STANDARD', 2, 180.00, 1),
            ('109', 'STANDARD', 2, 195.00, 1),
            ('110', 'STANDARD', 2, 195.00, 1),
            ('111', 'STANDARD', 2, 180.00, 1),
            ('112', 'STANDARD', 2, 180.00, 1),
            ('113', 'STANDARD', 2, 180.00, 1),
            ('114', 'STANDARD', 2, 195.00, 1),
            ('115', 'STANDARD', 2, 195.00, 1),
            ('116', 'STANDARD', 2, 180.00, 1),
            ('117', 'STANDARD', 2, 180.00, 1),
            ('118', 'STANDARD', 2, 180.00, 0),
            ('119', 'STANDARD', 2, 195.00, 1),
            ('120', 'STANDARD', 2, 195.00, 1),
            ('121', 'STANDARD', 3, 210.00, 1),
            ('122', 'STANDARD', 3, 210.00, 1),
            ('123', 'STANDARD', 3, 210.00, 1),
            ('124', 'STANDARD', 3, 210.00, 1),
            ('125', 'STANDARD', 3, 210.00, 1),
            ('201', 'SUPERIOR', 3, 250.00, 1),
            ('202', 'SUPERIOR', 3, 250.00, 1),
            ('203', 'SUPERIOR', 3, 250.00, 1),
            ('204', 'SUPERIOR', 3, 265.00, 1),
            ('205', 'SUPERIOR', 3, 265.00, 1),
            ('206', 'SUPERIOR', 3, 250.00, 1),
            ('207', 'SUPERIOR', 3, 250.00, 1),
            ('208', 'SUPERIOR', 3, 250.00, 1),
            ('209', 'SUPERIOR', 3, 265.00, 1),
            ('210', 'SUPERIOR', 3, 265.00, 1),
            ('211', 'SUPERIOR', 3, 250.00, 1),
            ('212', 'SUPERIOR', 3, 250.00, 1),
            ('213', 'SUPERIOR', 3, 250.00, 1),
            ('214', 'SUPERIOR', 3, 265.00, 1),
            ('215', 'SUPERIOR', 3, 265.00, 1),
            ('216', 'SUPERIOR', 3, 250.00, 1),
            ('217', 'SUPERIOR', 3, 250.00, 1),
            ('218', 'SUPERIOR', 3, 250.00, 1),
            ('219', 'SUPERIOR', 3, 265.00, 1),
            ('220', 'SUPERIOR', 3, 265.00, 1),
            ('221', 'SUPERIOR', 4, 280.00, 1),
            ('222', 'SUPERIOR', 4, 280.00, 1),
            ('223', 'SUPERIOR', 4, 280.00, 1),
            ('224', 'SUPERIOR', 4, 280.00, 0),
            ('225', 'SUPERIOR', 4, 280.00, 1),
            ('301', 'LUXO', 4, 350.00, 1),
            ('302', 'LUXO', 4, 350.00, 1),
            ('303', 'LUXO', 4, 350.00, 1),
            ('304', 'LUXO', 4, 370.00, 1),
            ('305', 'LUXO', 4, 370.00, 1),
            ('306', 'LUXO', 4, 350.00, 1),
            ('307', 'LUXO', 4, 350.00, 1),
            ('308', 'LUXO', 4, 350.00, 1),
            ('309', 'LUXO', 4, 370.00, 1),
            ('310', 'LUXO', 4, 370.00, 1),
            ('311', 'LUXO', 4, 350.00, 1),
            ('312', 'LUXO', 4, 350.00, 1),
            ('313', 'LUXO', 4, 350.00, 1),
            ('314', 'LUXO', 4, 370.00, 1),
            ('315', 'LUXO', 4, 370.00, 1),
            ('316', 'LUXO', 4, 350.00, 1),
            ('317', 'LUXO', 4, 350.00, 0),
            ('318', 'LUXO', 4, 350.00, 1),
            ('319', 'LUXO', 4, 370.00, 1),
            ('320', 'LUXO', 4, 370.00, 1),
            ('321', 'LUXO', 5, 390.00, 1),
            ('322', 'LUXO', 5, 390.00, 1),
            ('323', 'LUXO', 5, 390.00, 1),
            ('324', 'LUXO', 5, 390.00, 1),
            ('325', 'LUXO', 5, 390.00, 1),
            ('401', 'SUITE', 4, 500.00, 1),
            ('402', 'SUITE', 4, 500.00, 1),
            ('403', 'SUITE', 4, 500.00, 1),
            ('404', 'SUITE', 4, 560.00, 1),
            ('405', 'SUITE', 4, 560.00, 1),
            ('406', 'SUITE', 4, 500.00, 1),
            ('407', 'SUITE', 4, 500.00, 1),
            ('408', 'SUITE', 4, 500.00, 1),
            ('409', 'SUITE', 4, 560.00, 1),
            ('410', 'SUITE', 4, 560.00, 1),
            ('411', 'SUITE', 4, 500.00, 1),
            ('412', 'SUITE', 4, 500.00, 1),
            ('413', 'SUITE', 4, 500.00, 1),
            ('414', 'SUITE', 4, 560.00, 1),
            ('415', 'SUITE', 4, 560.00, 1),
            ('416', 'SUITE', 5, 620.00, 1),
            ('417', 'SUITE', 5, 620.00, 1),
            ('418', 'SUITE', 5, 620.00, 1),
            ('419', 'SUITE', 5, 620.00, 1),
            ('420', 'SUITE', 5, 620.00, 1),
            ('421', 'SUITE', 6, 780.00, 1),
            ('422', 'SUITE', 6, 780.00, 1),
            ('423', 'SUITE', 6, 780.00, 1),
            ('424', 'SUITE', 6, 780.00, 1),
            ('425', 'SUITE', 6, 780.00, 1);
GO

-- 3.1 Reservas já encerradas - 25 registros (situação CHECKOUT)
-- Estadias passadas, todas entre 80 e 20 dias atrás
INSERT INTO [dbo].[Reserva] (IdHospede, IdQuarto, DataReserva, DataEntrada, DataSaida, Situacao)
    VALUES  (1, 2, DATEADD(DAY, -92, GETDATE()), DATEADD(DAY, -76, CAST(GETDATE() AS DATE)), DATEADD(DAY, -73, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (7, 5, DATEADD(DAY, -88, GETDATE()), DATEADD(DAY, -74, CAST(GETDATE() AS DATE)), DATEADD(DAY, -72, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (12, 9, DATEADD(DAY, -95, GETDATE()), DATEADD(DAY, -72, CAST(GETDATE() AS DATE)), DATEADD(DAY, -67, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (18, 13, DATEADD(DAY, -84, GETDATE()), DATEADD(DAY, -70, CAST(GETDATE() AS DATE)), DATEADD(DAY, -66, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (23, 17, DATEADD(DAY, -80, GETDATE()), DATEADD(DAY, -68, CAST(GETDATE() AS DATE)), DATEADD(DAY, -65, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (29, 21, DATEADD(DAY, -79, GETDATE()), DATEADD(DAY, -66, CAST(GETDATE() AS DATE)), DATEADD(DAY, -64, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (34, 24, DATEADD(DAY, -77, GETDATE()), DATEADD(DAY, -64, CAST(GETDATE() AS DATE)), DATEADD(DAY, -59, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (41, 27, DATEADD(DAY, -75, GETDATE()), DATEADD(DAY, -62, CAST(GETDATE() AS DATE)), DATEADD(DAY, -58, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (46, 30, DATEADD(DAY, -73, GETDATE()), DATEADD(DAY, -60, CAST(GETDATE() AS DATE)), DATEADD(DAY, -57, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (52, 33, DATEADD(DAY, -70, GETDATE()), DATEADD(DAY, -58, CAST(GETDATE() AS DATE)), DATEADD(DAY, -56, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (57, 37, DATEADD(DAY, -68, GETDATE()), DATEADD(DAY, -56, CAST(GETDATE() AS DATE)), DATEADD(DAY, -51, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (63, 41, DATEADD(DAY, -66, GETDATE()), DATEADD(DAY, -54, CAST(GETDATE() AS DATE)), DATEADD(DAY, -50, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (68, 44, DATEADD(DAY, -64, GETDATE()), DATEADD(DAY, -52, CAST(GETDATE() AS DATE)), DATEADD(DAY, -49, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (74, 47, DATEADD(DAY, -62, GETDATE()), DATEADD(DAY, -50, CAST(GETDATE() AS DATE)), DATEADD(DAY, -48, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (79, 52, DATEADD(DAY, -60, GETDATE()), DATEADD(DAY, -48, CAST(GETDATE() AS DATE)), DATEADD(DAY, -43, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (85, 55, DATEADD(DAY, -58, GETDATE()), DATEADD(DAY, -46, CAST(GETDATE() AS DATE)), DATEADD(DAY, -42, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (90, 58, DATEADD(DAY, -55, GETDATE()), DATEADD(DAY, -44, CAST(GETDATE() AS DATE)), DATEADD(DAY, -41, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (96, 61, DATEADD(DAY, -53, GETDATE()), DATEADD(DAY, -42, CAST(GETDATE() AS DATE)), DATEADD(DAY, -40, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (3, 64, DATEADD(DAY, -51, GETDATE()), DATEADD(DAY, -40, CAST(GETDATE() AS DATE)), DATEADD(DAY, -35, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (15, 69, DATEADD(DAY, -48, GETDATE()), DATEADD(DAY, -38, CAST(GETDATE() AS DATE)), DATEADD(DAY, -34, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (27, 72, DATEADD(DAY, -46, GETDATE()), DATEADD(DAY, -36, CAST(GETDATE() AS DATE)), DATEADD(DAY, -33, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (39, 77, DATEADD(DAY, -44, GETDATE()), DATEADD(DAY, -34, CAST(GETDATE() AS DATE)), DATEADD(DAY, -31, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (50, 81, DATEADD(DAY, -42, GETDATE()), DATEADD(DAY, -32, CAST(GETDATE() AS DATE)), DATEADD(DAY, -27, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (62, 86, DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -30, CAST(GETDATE() AS DATE)), DATEADD(DAY, -26, CAST(GETDATE() AS DATE)), 'CHECKOUT'),
            (71, 92, DATEADD(DAY, -38, GETDATE()), DATEADD(DAY, -28, CAST(GETDATE() AS DATE)), DATEADD(DAY, -25, CAST(GETDATE() AS DATE)), 'CHECKOUT');
GO

-- 3.2 Reservas canceladas - 25 registros (situação CANCELADA)
-- Não bloqueiam o período: servem para testar nova reserva sobre período cancelado
INSERT INTO [dbo].[Reserva] (IdHospede, IdQuarto, DataReserva, DataEntrada, DataSaida, Situacao)
    VALUES  (2, 3, DATEADD(DAY, -65, GETDATE()), DATEADD(DAY, -50, CAST(GETDATE() AS DATE)), DATEADD(DAY, -47, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (9, 6, DATEADD(DAY, -60, GETDATE()), DATEADD(DAY, -45, CAST(GETDATE() AS DATE)), DATEADD(DAY, -42, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (14, 10, DATEADD(DAY, -55, GETDATE()), DATEADD(DAY, -40, CAST(GETDATE() AS DATE)), DATEADD(DAY, -36, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (20, 14, DATEADD(DAY, -50, GETDATE()), DATEADD(DAY, -35, CAST(GETDATE() AS DATE)), DATEADD(DAY, -32, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (25, 19, DATEADD(DAY, -45, GETDATE()), DATEADD(DAY, -30, CAST(GETDATE() AS DATE)), DATEADD(DAY, -26, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (31, 22, DATEADD(DAY, -40, GETDATE()), DATEADD(DAY, -25, CAST(GETDATE() AS DATE)), DATEADD(DAY, -21, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (36, 25, DATEADD(DAY, -35, GETDATE()), DATEADD(DAY, -20, CAST(GETDATE() AS DATE)), DATEADD(DAY, -17, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (43, 28, DATEADD(DAY, -30, GETDATE()), DATEADD(DAY, -15, CAST(GETDATE() AS DATE)), DATEADD(DAY, -12, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (48, 31, DATEADD(DAY, -28, GETDATE()), DATEADD(DAY, -10, CAST(GETDATE() AS DATE)), DATEADD(DAY, -6, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (54, 35, DATEADD(DAY, -25, GETDATE()), DATEADD(DAY, -5, CAST(GETDATE() AS DATE)), DATEADD(DAY, -2, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (59, 39, DATEADD(DAY, -22, GETDATE()), DATEADD(DAY, -3, CAST(GETDATE() AS DATE)), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (65, 43, DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), DATEADD(DAY, 6, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (70, 46, DATEADD(DAY, -18, GETDATE()), DATEADD(DAY, 5, CAST(GETDATE() AS DATE)), DATEADD(DAY, 9, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (76, 50, DATEADD(DAY, -15, GETDATE()), DATEADD(DAY, 8, CAST(GETDATE() AS DATE)), DATEADD(DAY, 12, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (81, 53, DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, 12, CAST(GETDATE() AS DATE)), DATEADD(DAY, 15, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (87, 56, DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, 15, CAST(GETDATE() AS DATE)), DATEADD(DAY, 19, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (92, 59, DATEADD(DAY, -9, GETDATE()), DATEADD(DAY, 18, CAST(GETDATE() AS DATE)), DATEADD(DAY, 22, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (98, 62, DATEADD(DAY, -8, GETDATE()), DATEADD(DAY, 22, CAST(GETDATE() AS DATE)), DATEADD(DAY, 25, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (5, 65, DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, 25, CAST(GETDATE() AS DATE)), DATEADD(DAY, 30, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (17, 70, DATEADD(DAY, -6, GETDATE()), DATEADD(DAY, 28, CAST(GETDATE() AS DATE)), DATEADD(DAY, 32, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (28, 74, DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, 32, CAST(GETDATE() AS DATE)), DATEADD(DAY, 35, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (40, 79, DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, 35, CAST(GETDATE() AS DATE)), DATEADD(DAY, 40, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (51, 83, DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, 40, CAST(GETDATE() AS DATE)), DATEADD(DAY, 44, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (66, 88, DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, 45, CAST(GETDATE() AS DATE)), DATEADD(DAY, 48, CAST(GETDATE() AS DATE)), 'CANCELADA'),
            (73, 94, DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, 50, CAST(GETDATE() AS DATE)), DATEADD(DAY, 54, CAST(GETDATE() AS DATE)), 'CANCELADA');
GO

-- 3.3 Reservas em andamento - 25 registros (situação CHECKIN)
-- Hóspedes atualmente no hotel: entrada já ocorreu e saída ainda não chegou
INSERT INTO [dbo].[Reserva] (IdHospede, IdQuarto, DataReserva, DataEntrada, DataSaida, Situacao)
    VALUES  (4, 1, DATEADD(DAY, -30, GETDATE()), DATEADD(DAY, -6, CAST(GETDATE() AS DATE)), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (8, 4, DATEADD(DAY, -28, GETDATE()), DATEADD(DAY, -5, CAST(GETDATE() AS DATE)), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (13, 8, DATEADD(DAY, -27, GETDATE()), DATEADD(DAY, -5, CAST(GETDATE() AS DATE)), DATEADD(DAY, 3, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (19, 12, DATEADD(DAY, -26, GETDATE()), DATEADD(DAY, -4, CAST(GETDATE() AS DATE)), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (24, 16, DATEADD(DAY, -25, GETDATE()), DATEADD(DAY, -4, CAST(GETDATE() AS DATE)), DATEADD(DAY, 4, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (30, 20, DATEADD(DAY, -24, GETDATE()), DATEADD(DAY, -3, CAST(GETDATE() AS DATE)), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (35, 23, DATEADD(DAY, -23, GETDATE()), DATEADD(DAY, -3, CAST(GETDATE() AS DATE)), DATEADD(DAY, 5, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (42, 26, DATEADD(DAY, -22, GETDATE()), DATEADD(DAY, -3, CAST(GETDATE() AS DATE)), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (47, 29, DATEADD(DAY, -21, GETDATE()), DATEADD(DAY, -2, CAST(GETDATE() AS DATE)), DATEADD(DAY, 3, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (53, 34, DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, -2, CAST(GETDATE() AS DATE)), DATEADD(DAY, 6, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (58, 38, DATEADD(DAY, -19, GETDATE()), DATEADD(DAY, -2, CAST(GETDATE() AS DATE)), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (64, 42, DATEADD(DAY, -18, GETDATE()), DATEADD(DAY, -1, CAST(GETDATE() AS DATE)), DATEADD(DAY, 4, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (69, 45, DATEADD(DAY, -17, GETDATE()), DATEADD(DAY, -1, CAST(GETDATE() AS DATE)), DATEADD(DAY, 7, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (75, 48, DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, -1, CAST(GETDATE() AS DATE)), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (80, 51, DATEADD(DAY, -15, GETDATE()), DATEADD(DAY, -1, CAST(GETDATE() AS DATE)), DATEADD(DAY, 5, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (86, 54, DATEADD(DAY, -14, GETDATE()), CAST(GETDATE() AS DATE), DATEADD(DAY, 3, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (91, 57, DATEADD(DAY, -13, GETDATE()), CAST(GETDATE() AS DATE), DATEADD(DAY, 5, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (97, 60, DATEADD(DAY, -12, GETDATE()), CAST(GETDATE() AS DATE), DATEADD(DAY, 8, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (6, 63, DATEADD(DAY, -11, GETDATE()), DATEADD(DAY, -5, CAST(GETDATE() AS DATE)), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (16, 68, DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, -4, CAST(GETDATE() AS DATE)), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (26, 73, DATEADD(DAY, -9, GETDATE()), DATEADD(DAY, -3, CAST(GETDATE() AS DATE)), DATEADD(DAY, 4, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (38, 78, DATEADD(DAY, -8, GETDATE()), DATEADD(DAY, -2, CAST(GETDATE() AS DATE)), DATEADD(DAY, 6, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (49, 82, DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, -1, CAST(GETDATE() AS DATE)), DATEADD(DAY, 3, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (61, 87, DATEADD(DAY, -6, GETDATE()), DATEADD(DAY, -6, CAST(GETDATE() AS DATE)), DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), 'CHECKIN'),
            (72, 93, DATEADD(DAY, -5, GETDATE()), CAST(GETDATE() AS DATE), DATEADD(DAY, 7, CAST(GETDATE() AS DATE)), 'CHECKIN');
GO

-- 3.4 Reservas futuras confirmadas - 25 registros (situação RESERVADA)
-- Aguardando check-in: base para os testes de cancelamento e de check-in
INSERT INTO [dbo].[Reserva] (IdHospede, IdQuarto, DataReserva, DataEntrada, DataSaida, Situacao)
    VALUES  (10, 7, DATEADD(DAY, -20, GETDATE()), DATEADD(DAY, 10, CAST(GETDATE() AS DATE)), DATEADD(DAY, 13, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (11, 11, DATEADD(DAY, -19, GETDATE()), DATEADD(DAY, 12, CAST(GETDATE() AS DATE)), DATEADD(DAY, 16, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (21, 15, DATEADD(DAY, -18, GETDATE()), DATEADD(DAY, 14, CAST(GETDATE() AS DATE)), DATEADD(DAY, 17, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (22, 32, DATEADD(DAY, -17, GETDATE()), DATEADD(DAY, 16, CAST(GETDATE() AS DATE)), DATEADD(DAY, 21, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (32, 36, DATEADD(DAY, -16, GETDATE()), DATEADD(DAY, 18, CAST(GETDATE() AS DATE)), DATEADD(DAY, 22, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (33, 40, DATEADD(DAY, -15, GETDATE()), DATEADD(DAY, 20, CAST(GETDATE() AS DATE)), DATEADD(DAY, 23, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (37, 66, DATEADD(DAY, -14, GETDATE()), DATEADD(DAY, 22, CAST(GETDATE() AS DATE)), DATEADD(DAY, 27, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (44, 71, DATEADD(DAY, -13, GETDATE()), DATEADD(DAY, 24, CAST(GETDATE() AS DATE)), DATEADD(DAY, 28, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (45, 75, DATEADD(DAY, -12, GETDATE()), DATEADD(DAY, 26, CAST(GETDATE() AS DATE)), DATEADD(DAY, 29, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (55, 76, DATEADD(DAY, -11, GETDATE()), DATEADD(DAY, 28, CAST(GETDATE() AS DATE)), DATEADD(DAY, 33, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (56, 80, DATEADD(DAY, -10, GETDATE()), DATEADD(DAY, 30, CAST(GETDATE() AS DATE)), DATEADD(DAY, 34, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (60, 84, DATEADD(DAY, -9, GETDATE()), DATEADD(DAY, 32, CAST(GETDATE() AS DATE)), DATEADD(DAY, 35, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (67, 85, DATEADD(DAY, -8, GETDATE()), DATEADD(DAY, 34, CAST(GETDATE() AS DATE)), DATEADD(DAY, 39, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (77, 89, DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, 36, CAST(GETDATE() AS DATE)), DATEADD(DAY, 40, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (78, 90, DATEADD(DAY, -7, GETDATE()), DATEADD(DAY, 38, CAST(GETDATE() AS DATE)), DATEADD(DAY, 41, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (82, 91, DATEADD(DAY, -6, GETDATE()), DATEADD(DAY, 40, CAST(GETDATE() AS DATE)), DATEADD(DAY, 45, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (83, 95, DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, 42, CAST(GETDATE() AS DATE)), DATEADD(DAY, 46, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (84, 96, DATEADD(DAY, -5, GETDATE()), DATEADD(DAY, 44, CAST(GETDATE() AS DATE)), DATEADD(DAY, 47, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (88, 97, DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, 46, CAST(GETDATE() AS DATE)), DATEADD(DAY, 51, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (89, 98, DATEADD(DAY, -4, GETDATE()), DATEADD(DAY, 48, CAST(GETDATE() AS DATE)), DATEADD(DAY, 52, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (93, 99, DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, 50, CAST(GETDATE() AS DATE)), DATEADD(DAY, 53, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (94, 100, DATEADD(DAY, -3, GETDATE()), DATEADD(DAY, 52, CAST(GETDATE() AS DATE)), DATEADD(DAY, 57, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (95, 2, DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, 54, CAST(GETDATE() AS DATE)), DATEADD(DAY, 58, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (99, 5, DATEADD(DAY, -2, GETDATE()), DATEADD(DAY, 56, CAST(GETDATE() AS DATE)), DATEADD(DAY, 59, CAST(GETDATE() AS DATE)), 'RESERVADA'),
            (100, 9, DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, 58, CAST(GETDATE() AS DATE)), DATEADD(DAY, 63, CAST(GETDATE() AS DATE)), 'RESERVADA');
GO

-- 4.1 Hospedagens concluídas - 25 registros
-- Check-in às 14h da data de entrada e check-out às 11h da data de saída
INSERT INTO [dbo].[Hospedagem] (IdReserva, DataCheckin, DataCheckout, Observacao)
SELECT
    Id,
    DATEADD(HOUR, 14, CAST(DataEntrada AS DATETIME)),
    DATEADD(HOUR, 11, CAST(DataSaida AS DATETIME)),
    CASE Id % 5
        WHEN 0 THEN 'Check-out realizado no horario previsto'
        WHEN 1 THEN 'Consumo de frigobar lancado na conta'
        WHEN 2 THEN 'Hospede solicitou late check-out ate as 13h'
        WHEN 3 THEN 'Estacionamento utilizado durante a estadia'
        ELSE 'Sem ocorrencias registradas'
    END
FROM [dbo].[Reserva]
WHERE Situacao = 'CHECKOUT';
GO

-- 4.2 Hospedagens em andamento - 25 registros
-- Hóspedes ainda no hotel, portanto sem data de check-out
INSERT INTO [dbo].[Hospedagem] (IdReserva, DataCheckin, DataCheckout, Observacao)
SELECT
    Id,
    DATEADD(HOUR, 14, CAST(DataEntrada AS DATETIME)),
    NULL,
    CASE Id % 4
        WHEN 0 THEN 'Solicitou berco no quarto'
        WHEN 1 THEN 'Cafe da manha incluso na diaria'
        WHEN 2 THEN 'Hospede em viagem a negocios'
        ELSE 'Chegada antecipada autorizada pela recepcao'
    END
FROM [dbo].[Reserva]
WHERE Situacao = 'CHECKIN';
GO

-- =========================================================================
-- Conferência da carga
-- =========================================================================

SELECT 'Hospede' AS Tabela, COUNT(*) AS Quantidade FROM [dbo].[Hospede]
UNION ALL
SELECT 'Quarto', COUNT(*) FROM [dbo].[Quarto]
UNION ALL
SELECT 'Reserva', COUNT(*) FROM [dbo].[Reserva]
UNION ALL
SELECT 'Hospedagem', COUNT(*) FROM [dbo].[Hospedagem];
GO
