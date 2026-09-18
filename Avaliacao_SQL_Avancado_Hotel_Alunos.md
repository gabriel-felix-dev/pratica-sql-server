# Avaliação Prática — SQL Avançado

**Sistema de Gestão de Hospedagem e Controle de Ocupação de Hotel**

IFTI • Banco de Dados Avançado • Avaliação Prática

---

## 1. Objetivo

Desenvolver uma solução em SQL para apoiar as operações de reserva e hospedagem de um hotel, aplicando recursos de SQL avançado, especialmente **Views**, **Functions** e **Procedures**.

---

## 2. Ambiente e arquivos disponibilizados

**SGBD: Microsoft SQL Server (T-SQL).** Toda a solução deve ser escrita em T-SQL e executada no SQL Server Management Studio (SSMS) ou no Azure Data Studio.

Serão disponibilizados dois scripts que devem ser executados antes do desenvolvimento da solução:

- `01_estrutura_hotel.sql` — cria o banco `hotel_avaliacao` e as tabelas `Hospede`, `Quarto`, `Reserva` e `Hospedagem`.
- `02_dados_iniciais_hotel.sql` — carrega a massa inicial de dados para utilização e testes.

> **Importante:** as estruturas e os dados fornecidos constituem a base da avaliação. A solução deve utilizar esse modelo como referência e não deve depender da criação de um banco diferente. Se necessário, vocês podem complementar as informações do banco de dados.

### 2.1 Modelo de dados

| Tabela | Colunas principais |
| --- | --- |
| `Hospede` | `Id`, `Nome`, `Cpf`, `Email`, `Telefone`, `DataNascimento` |
| `Quarto` | `Id`, `Numero`, `Tipo`, `Capacidade`, `ValorDiaria`, `Ativo` |
| `Reserva` | `Id`, `IdHospede`, `IdQuarto`, `DataReserva`, `DataEntrada`, `DataSaida`, `Situacao` |
| `Hospedagem` | `Id`, `IdReserva`, `DataCheckin`, `DataCheckout`, `Observacao` |

A coluna `Situacao` da tabela `Reserva` aceita apenas os valores `'RESERVADA'`, `'CANCELADA'`, `'CHECKIN'` e `'CHECKOUT'` (garantidos por constraint `CHECK`).

A massa de dados utiliza datas relativas a `GETDATE()`: as hospedagens em andamento sempre cobrem o dia da execução, independentemente de quando os scripts forem rodados.

---

## 3. Contexto do negócio

O hotel precisa controlar a disponibilidade dos quartos e o ciclo de atendimento de seus hóspedes. A solução deverá considerar o seguinte fluxo principal:

**Disponibilidade → Reserva → Check-in → Hospedagem → Check-out**

**Reserva → Cancelamento**

---

## 4. Regras de negócio

**RN01 — Reserva**
Uma reserva deve possuir hóspede, quarto, data prevista de entrada e data prevista de saída. A data de saída deve ser posterior à data de entrada.

**RN02 — Disponibilidade**
Um quarto não pode receber uma nova reserva quando existir outra reserva ativa com conflito no período solicitado. Reservas canceladas não devem bloquear o período.

**RN03 — Cancelamento**
Somente reservas que ainda não tenham realizado check-in podem ser canceladas. A situação da reserva deve ser atualizada para `CANCELADA`.

**RN04 — Check-in**
O check-in somente pode ocorrer para uma reserva válida, com situação `RESERVADA` e não cancelada. Após o check-in, a situação da reserva deve ser atualizada e a hospedagem deve ser registrada.

**RN05 — Check-out**
O check-out somente pode ocorrer após um check-in. A saída deve ser registrada e a situação da reserva deve ser atualizada para `CHECKOUT`.

**RN06 — Ocupação**
O sistema deve permitir consultar os quartos que se encontram ocupados, identificando também o hóspede e as informações da hospedagem.

**RN07 — Disponibilidade futura**
O sistema deve permitir verificar a disponibilidade de um quarto para um intervalo de datas informado.

**RN08 — Histórico**
Reservas canceladas e hospedagens concluídas devem permanecer registradas para consulta histórica. Não devem ser excluídas fisicamente apenas por terem sido canceladas ou concluídas.

---

## 5. Padrões de código obrigatórios

A solução deve seguir os mesmos padrões de programação adotados no módulo de SQL Programação:

1. **Nomenclatura dos objetos** — use os prefixos do módulo:
   - Views: `VW_NomeDoObjeto`
   - Functions: `FNC_NomeDoObjeto`
   - Stored Procedures: `SP_NomeDoObjeto`
2. **Criação dos objetos** — utilize `CREATE OR ALTER` e o schema explícito `[dbo].[NomeDoObjeto]`, encerrando cada objeto com `GO`. Isso torna o script reexecutável do início ao fim.
3. **Bloco de documentação** — todo objeto programável deve conter o cabeçalho padronizado logo após o `AS`, no formato utilizado nas aulas:

   ```sql
   /*
       Documentacao
       Arquivo Fonte............:	SP_RealizarReserva.sql
       Objetivo.................:	Registrar uma nova reserva validando disponibilidade
       Autor....................:	(Seu Nome)
       Data.....................:	(Data de Hoje)
       Ex.......................:	DECLARE @Retorno INT

                                   EXEC @Retorno = [dbo].[SP_RealizarReserva] @IdHospede = 1,
                                                                             @IdQuarto = 10,
                                                                             @DataEntrada = '20260901',
                                                                             @DataSaida = '20260905'

                                   SELECT @Retorno AS Retorno
       Retornos.................:	0 - Sucesso
                                   -1 - Erro: Hospede nao cadastrado
                                   -2 - Erro: Quarto nao cadastrado
                                   -3 - Erro: Periodo invalido
                                   -4 - Erro: Quarto indisponivel no periodo
   */
   ```

4. **Códigos de retorno nas procedures** — sinalize o resultado da operação com `RETURN`: `0` para sucesso e valores negativos para cada erro específico, documentando-os no bloco acima.
5. **`WITH(NOLOCK)` nas consultas** — todo `SELECT` de leitura deve utilizar a dica `WITH(NOLOCK)` nas tabelas consultadas.
6. **Indentação com TABs**, seguindo a hierarquia usada nos exemplos das aulas.
7. **Datas em formato ISO sem separador** (`'20260901'`). O formato com hífen depende do `DATEFORMAT`/`LANGUAGE` da sessão e inverte dia e mês em servidores configurados em português.
8. **Sem cursores** — caso precise iterar, utilize `WHILE` com tabela temporária.

---

## 6. Implementações obrigatórias

A partir da estrutura e dos dados disponibilizados, desenvolva os objetos e operações descritos a seguir.

### 6.1 Views

- **`VW_OcupacaoAtual`** — view de ocupação/hospedagens em andamento, apresentando informações suficientes para identificar o quarto, o hóspede, o período e a situação da hospedagem.
- **`VW_HistoricoReservas`** — view de histórico de reservas, permitindo consultar reservas concluídas, canceladas e demais situações registradas.

### 6.2 Functions

- **`FNC_VerificarDisponibilidadeQuarto`** — recebe um quarto e um período de entrada e saída e informa se o quarto está disponível para reserva nesse intervalo.
- **`FNC_ObterOcupacaoHotel`** — retorna uma informação de ocupação do hotel, como a quantidade ou o percentual de quartos ocupados em uma data ou momento de referência.

### 6.3 Procedures

- **`SP_RealizarReserva`** — recebe os dados necessários, valida o período e a disponibilidade do quarto e registra a reserva quando a operação for válida.
- **`SP_CancelarReserva`** — cancela uma reserva somente quando sua situação permitir a operação.
- **`SP_RealizarCheckin`** — valida a reserva, atualiza sua situação e registra o início da hospedagem.
- **`SP_RealizarCheckout`** — valida a existência de check-in, registra a saída e atualiza a situação da reserva.

> Os nomes acima são os sugeridos e seguem o padrão do módulo. Caso opte por outros nomes, mantenha obrigatoriamente os prefixos `VW_`, `FNC_` e `SP_` e garanta que a finalidade do objeto seja identificável no script.

---

## 7. Testes obrigatórios

Ao final do arquivo, inclua comandos SQL que demonstrem a execução da solução. Os testes devem contemplar, no mínimo, os seguintes cenários:

- Reserva válida.
- Tentativa de reserva com conflito de período.
- Cancelamento de reserva.
- Nova reserva em período anteriormente associado a uma reserva cancelada.
- Realização de check-in.
- Tentativa de check-in inválido.
- Realização de check-out.
- Consulta da ocupação e/ou histórico por meio das Views.
- Execução das Functions implementadas.

Nos testes de procedures, capture e exiba o código de retorno, como nos exemplos das aulas:

```sql
DECLARE @Retorno INT

EXEC @Retorno = [dbo].[SP_RealizarReserva] @IdHospede = 1,
                                           @IdQuarto = 10,
                                           @DataEntrada = '20260901',
                                           @DataSaida = '20260905'

SELECT @Retorno AS Retorno
GO
```

---

## 8. Arquivo a ser entregue

Entregue um único arquivo com extensão `.sql` contendo sua solução. O arquivo deve estar organizado e ser executável após a criação da estrutura e carga dos dados disponibilizados.

O nome do arquivo e as regras de entrega no repositório estão descritos no `README.md` do projeto.

```sql
/* =====================================================
   AVALIAÇÃO BANCO DE DADOS AVANÇADO
   Aluno:
   Matrícula:
   SGBD: Microsoft SQL Server (T-SQL)
   ===================================================== */

USE hotel_avaliacao;
GO

/* =====================================================
   1. VIEWS
   ===================================================== */
-- código
GO

/* =====================================================
   2. FUNCTIONS
   ===================================================== */
-- código
GO

/* =====================================================
   3. PROCEDURES
   ===================================================== */
-- código
GO

/* =====================================================
   4. TESTES
   ===================================================== */
-- código
GO
```

---

## 9. Orientações finais

- Utilize os dados fornecidos para analisar e validar o comportamento da solução.
- A solução deve preservar a integridade e o histórico dos dados.
- Não é necessário desenvolver interface gráfica ou aplicação externa; toda a atividade será realizada no banco de dados.
- Comentários no código podem ser utilizados para explicar decisões ou trechos relevantes da implementação.
- O arquivo entregue deve permitir identificar claramente cada View, Function, Procedure e cenário de teste.
