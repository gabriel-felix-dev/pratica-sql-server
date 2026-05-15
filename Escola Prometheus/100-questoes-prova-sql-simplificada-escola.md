# Prova de SQL Server — Enunciados Simplificados

> **Instruções Gerais:** Baseie-se no modelo do Sistema Acadêmico Prometheus para resolver as questões a seguir.
> - É permitido usar apenas `SELECT` com `JOINs`, `GROUP BY`, `HAVING`, subconsultas e agregações.
> - É estritamente proibido utilizar tabelas temporárias, CTEs, Window Functions, Funções, Procedures ou Triggers.

---

### Questão 01
Liste o nome do aluno, a data da matrícula e a descrição da avaliação para os casos em que o aluno obteve nota 10 em alguma avaliação cujo tipo tem peso maior que 0.5.

---

### Questão 02
Liste o nome e a data de nascimento dos professores que lecionam disciplinas com carga horária igual ou superior a 80 horas e que tiveram alguma avaliação aplicada em 2024.

---

### Questão 03
Liste o nome das disciplinas e seus respectivos professores para os casos em que **nenhuma aprovação** foi registrada até o momento.

---

### Questão 04
Liste as especializações que possuem mais de 3 professores cadastrados, junto com a soma total da carga horária de todas as disciplinas ensinadas por esses professores.

---

### Questão 05
Entre os alunos que têm médias finais registradas no histórico, encontre aquele(s) com a **maior média geral** (média aritmética das médias finais).

---

### Questão 06
Informe a quantidade de alunos que foram reprovados em alguma disciplina lecionada pelo professor de registro funcional **1004**.

---

### Questão 07
Liste o nome e CPF dos alunos que possuem notas em mais de 5 trabalhos de uma mesma disciplina, exibindo também o nome da disciplina.

---

### Questão 08
Liste as disciplinas em que a soma dos pesos de todos os tipos de avaliação cadastrados **não ultrapassa 1.0**.

---

### Questão 09
Liste os alunos que estão com status **"Cursando"** em alguma disciplina, mas não possuem **nenhuma nota** lançada no sistema.

---

### Questão 10
Liste os títulos das avaliações cuja média de notas da turma ficou **abaixo de 5.0**, ignorando alunos sem nota registrada (NULL).

---

### Questão 11
Liste as disciplinas cujo professor também leciona outras disciplinas, exibindo quantas outras disciplinas esse professor assume (total − 1).

---

### Questão 12
Liste os alunos cujo **ano de nascimento** é igual ao do professor com registro funcional **1020**.

---

### Questão 13
Conte as matrículas formalizadas em meses que também tiveram alguma avaliação com a palavra **"Final"** no título.

---

### Questão 14
Liste os tipos de avaliação que **nunca foram aplicados** em disciplinas da área de **"Matematica"**.

---

### Questão 15
Liste os professores cujos alunos possuem pelo menos um status **"Cancelado"** em suas disciplinas, informando o número de cancelamentos.

---

### Questão 16
Informe o nome do aluno **mais jovem** no momento em que efetuou sua matrícula na instituição.

---

### Questão 17
Informe o(s) mês(es) do ano com o **maior número de matrículas** realizadas na instituição.

---

### Questão 18
Para cada professor da área de **"Linguagens"**, calcule a média da carga horária total das disciplinas que ele leciona, agrupando por CPF.

---

### Questão 19
Liste as disciplinas em que a diferença entre a **maior e a menor nota** em avaliações do tipo "Prova" é superior a 5 pontos.

---

### Questão 20
Liste o nome e o número de matrícula dos alunos que foram **aprovados em todas** as disciplinas de 40 horas.

---

### Questão 21
Informe a **média final mais frequente** (moda, excluindo nulos) entre as disciplinas lecionadas por professores nascidos antes de 1970.

---

### Questão 22
Conte as matrículas em disciplinas realizadas após abril de 2024 que **não resultaram em cancelamento**.

---

### Questão 23
Liste os tipos de avaliação que **nunca geraram nota zero**.

---

### Questão 24
Informe a **maior nota** obtida por alunos cujo número de matrícula termina em "00", em avaliações com o maior peso registrado no sistema.

---

### Questão 25
Liste os alunos que possuem pelo menos **3 disciplinas com reprovação ou média abaixo de 5**, mas que **não têm nenhum cancelamento** registrado.

---

### Questão 26
Liste as especializações cujos professores, em conjunto, têm uma quantidade de alunos matriculados **acima da média geral da escola** por especialização.

---

### Questão 27
Liste o nome dos alunos e das disciplinas em que a **média final é inferior a 4.0**, mas o aluno obteve **nota 10** em pelo menos uma avaliação dessa mesma disciplina.

---

### Questão 28
Liste as disciplinas em que o professor é **mais velho do que todos os alunos** vinculados a ela.

---

### Questão 29
Liste os títulos de avaliações aplicadas em disciplinas com carga horária superior a 60 horas, cuja data de realização ocorreu em um **mês sem nenhuma matrícula nova** registrada.

---

### Questão 30
Informe a quantidade de alunos que estão matriculados simultaneamente em disciplinas de **"Linguagens"** e de **"Matematica"**.

---

### Questão 31
Liste os professores que lecionam em pelo menos 2 disciplinas diferentes e que **nunca tiveram nenhuma nota** lançada por seus alunos em nenhuma avaliação.

---

### Questão 32
Liste o nome dos alunos com **menos de 18 anos em 2026** que obtiveram nota acima de 8 em avaliações com peso **0.4**.

---

### Questão 33
Liste os tipos de avaliação usados em disciplinas cuja **carga horária média** é inferior à carga horária média geral de todas as disciplinas da escola.

---

### Questão 34
Liste os professores cujas disciplinas têm matrículas de alunos com status **exclusivamente "Cursando" ou "Cancelado"** (sem nenhum resultado definitivo).

---

### Questão 35
Informe a especialização cuja **soma total de notas** de todas as avaliações das suas disciplinas é a **menor** entre todas as especializações.

---

### Questão 36
Liste o nome e CPF dos alunos que estão matriculados mas **não têm nenhuma média final registrada** em nenhuma disciplina.

---

### Questão 37
Liste o nome do professor e da disciplina para os casos em que a **menor nota registrada** por qualquer aluno dessa turma seja **superior a 7.5**.

---

### Questão 38
Informe o ano em que houve o **maior número de matrículas** em disciplinas da área de **"Linguagens"**.

---

### Questão 39
Informe a quantidade de professores cujos alunos **nunca receberam nota zero** em nenhuma avaliação.

---

### Questão 40
Liste os alunos que obtiveram **exatamente a mesma média final** em duas disciplinas diferentes, exibindo o nome e a nota.

---

### Questão 41
Liste os números de matrícula dos alunos **aniversariantes de março** cujo professor da disciplina tem um ano de nascimento diferente do seu.

---

### Questão 42
Liste as avaliações e seus pesos nos casos em que algum aluno tirou a **menor nota geral** do sistema nessa categoria de avaliação.

---

### Questão 43
Para cada aluno que **nunca teve matrícula cancelada**, informe a soma total da carga horária das disciplinas cursadas (ignorando alunos sem disciplinas).

---

### Questão 44
Liste o nome das disciplinas que tiveram avaliações realizadas **após a data de matrícula** de pelo menos um aluno.

---

### Questão 45
Liste os títulos de avaliações em que **nenhum aluno tirou zero** e a **nota mínima** obtida foi superior a 5.0.

---

### Questão 46
Liste o nome do aluno e do professor para os casos em que a **diferença de idade** entre eles é **inferior a 15 anos**.

---

### Questão 47
Liste os professores responsáveis por disciplinas com **carga horária superior a 120 horas** e cuja **menor nota** já registrada no histórico é inferior a 1.0.

---

### Questão 48
Liste as disciplinas que **nunca aplicaram avaliações** do tipo com o **menor peso** registrado no sistema.

---

### Questão 49
Liste as especializações que já têm pelo menos uma disciplina ativa, mas que **não possuem nenhuma disciplina com carga horária inferior a 60 horas**.

---

### Questão 50
Conte as matrículas **sem média final registrada** (média nula) pertencentes a alunos de professores nascidos no mês de **junho**.

---

### Questão 51
Liste o nome dos alunos matriculados em **2024** que obtiveram nota **exatamente 5.0** em avaliações com peso **0.6**.

---

### Questão 52
Liste as disciplinas cuja **média final dos alunos aprovados** é superior à média geral de aprovados da área de **"Ciencias da Natureza"**.

---

### Questão 53
Liste os tipos de avaliação usados **exclusivamente** em disciplinas de professores da área de **"Linguagens"**.

---

### Questão 54
Liste os alunos matriculados em **anos ímpares** que foram **reprovados**.

---

### Questão 55
Liste as disciplinas que tiveram **apenas uma avaliação** em todo o histórico, e cuja carga horária é **superior a 99 horas**.

---

### Questão 56
Informe a **maior quantidade de disciplinas canceladas** registradas em um único CPF de aluno.

---

### Questão 57
Para alunos nascidos **antes de 1996**, informe a soma total das notas **iguais a 10** registradas no histórico.

---

### Questão 58
Liste os tipos de avaliação com o **maior peso total** aplicado, desconsiderando tipos sem nenhuma aplicação.

---

### Questão 59
Liste os alunos e professores cuja **data de nascimento e data de matrícula** caem no **dia 15** de algum mês.

---

### Questão 60
Liste os professores cuja **média de idade dos seus alunos** é inferior à média geral de tempo de conclusão (em anos) de todas as matrículas com médias finais registradas.

---

### Questão 61
Liste os status de encerramento registrados em disciplinas cujos alunos **não possuem nenhuma nota nula** nas avaliações.

---

### Questão 62
Liste as disciplinas cuja **média aritmética de todas as notas** de avaliações registradas é **inferior a 3.0**.

---

### Questão 63
Liste os alunos que realizaram avaliações **apenas de tipos com peso inferior a 0.5** (ou seja, nunca fizeram avaliações de peso maior ou igual a 0.5).

---

### Questão 64
Liste os títulos das avaliações cuja **data de realização** coincide com o **mesmo mês e dia** (sem considerar o ano) da matrícula do aluno que a realizou.

---

### Questão 65
Liste os professores cujas disciplinas tiveram **apenas uma avaliação no ano** e nenhum aluno foi reprovado ou cancelado.

---

### Questão 66
Informe a quantidade de disciplinas com **carga horária superior a 120 horas** cujos professores têm datas de nascimento sem correlação linear com as datas das disciplinas.

---

### Questão 67
Liste as especializações em que mais de **30% das matrículas** das suas disciplinas resultaram em **aprovação**.

---

### Questão 68
Informe a **maior quantidade de disciplinas com a mesma carga horária** lecionadas por um mesmo professor na instituição.

---

### Questão 69
Informe a **soma dos pesos** de todas as avaliações realizadas por alunos cujo nome começa com a letra **"A"**.

---

### Questão 70
Liste as especializações cujas disciplinas tiveram **no máximo 2 notas zero** registradas no total do histórico.

---

### Questão 71
Informe a **diferença em dias** entre a primeira matrícula da história da instituição e a primeira avaliação registrada na disciplina de **"Biologia"**.

---

### Questão 72
Liste os professores cuja **média geral das notas** dos seus alunos é **inferior a 6.0** e possuem **mais de 3 matrículas** associadas às suas disciplinas.

---

### Questão 73
Liste os alunos que **nunca tiveram duas notas iguais** em nenhuma avaliação do seu histórico (excluindo nulos).

---

### Questão 74
Liste as disciplinas que tiveram **alguma nota registrada no dia 1º de maio de 2024** (feriado nacional).

---

### Questão 75
Liste o aluno com o **maior número de cancelamentos e reprovações combinados** em um único ano letivo.

---

### Questão 76
Liste as disciplinas em que o número de **aprovações é exatamente igual** ao número de **reprovações**.

---

### Questão 77
Liste os títulos das avaliações aplicadas em disciplinas com **carga horária superior a 100 horas**.

---

### Questão 78
Liste as disciplinas que não têm **nenhuma média final registrada** (todas nulas), mas possuem **mais de 10 notas de avaliação** lançadas no histórico.

---

### Questão 79
Liste as disciplinas dos professores cujo **mês de nascimento** é anterior ao **mês de matrícula** dos seus alunos nessas disciplinas.

---

### Questão 80
Liste o nome e o número de matrícula dos alunos matriculados em **2024** cuja **média de notas em trabalhos** é igual ou superior a **9.0**.

---

### Questão 81
Liste o registro funcional e o nome dos professores que **nunca tiveram nenhum aluno com nota 10** como média final em nenhuma disciplina.

---

### Questão 82
Liste as especializações com a **maior proporção de cancelamentos** em relação ao total de matrículas com status definitivo (excluindo "Cursando").

---

### Questão 83
Liste o nome do status de encerramento com a **maior média de tempo** (em anos) entre a data de nascimento do aluno e a data de fechamento da média na matrícula.

---

### Questão 84
Informe a quantidade de disciplinas em que **todos os alunos com média registrada** foram reprovados com **média abaixo de 6.0**.

---

### Questão 85
Liste os tipos de avaliação cuja **média geral de notas** é inferior à média geral de todas as avaliações da instituição.

---

### Questão 86
Conte as matrículas realizadas **fora do primeiro quadrimestre** (ou seja, de maio a dezembro) que resultaram em **média final igual ou superior a 5.0**.

---

### Questão 87
Liste as disciplinas em que há a **maior diferença de ano de matrícula** entre os alunos matriculados.

---

### Questão 88
Liste o nome da disciplina e do professor para os casos em que a **média das notas de trabalhos** dos alunos ficou **abaixo do mínimo** esperado na maioria das avaliações registradas.

---

### Questão 89
Liste a **maior média final** registrada por especialização, considerando apenas alunos com status de encerramento definitivo.

---

### Questão 90
Liste os CPFs dos alunos que realizaram **matrícula duplicada no mesmo ano** — ou seja, duas matrículas em meses diferentes com o mesmo ano, independentemente de cancelamentos.

---

### Questão 91
Liste o nome do aluno, a disciplina, a média final armazenada e a média ponderada calculada pelas notas brutas (Trabalho × 0,4 + Prova × 0,6), exibindo apenas os casos em que os dois valores **divergem**.

---

### Questão 92
Liste o nome do aluno, o nome da disciplina e o código de status de reprovação para todos os registros do histórico com status **"Reprovado"** e **média final nula**.

---

### Questão 93
Liste o nome do aluno, o nome da disciplina e o número da matrícula para os alunos com pelo menos uma disciplina **"Cursando"** mas **sem nenhuma nota lançada** nessa matrícula.

---

### Questão 94
Liste o nome do professor, sua área de formação e a disciplina que leciona nos casos em que há **incompatibilidade** entre a formação e a disciplina (use LIKE para verificar se o nome da área não contém nenhuma palavra-chave do nome da disciplina).

---

### Questão 95
Liste o nome do aluno, o título do exame, a data de realização e a data de matrícula para os casos em que o exame foi realizado **antes da data de ingresso** do aluno na instituição.

---

### Questão 96
Liste o nome do aluno, o nome da disciplina, a média final e o código de status para os registros com status de **cancelamento** que, paradoxalmente, possuem **média final preenchida**.

---

### Questão 97
Liste as disciplinas que **não possuem nenhum aluno matriculado**, exibindo também o nome do professor responsável e a carga horária.

---

### Questão 98
Liste as disciplinas com **menos de 2 modalidades de avaliação cadastradas** (Trabalho e/ou Prova), informando o nome, a quantidade atual e quais modalidades estão **faltando**.

---

### Questão 99
Identifique os alunos com **exatamente uma matrícula** vinculada ao seu número sequencial, demonstrando como a unicidade da chave se sustenta na base.

---

### Questão 100
Liste o nome do aluno, a disciplina, a média final e o status de conclusão para os casos com **inconsistência entre nota e resultado**:

- Status **"Aprovado"** com média **menor que 5**, ou
- Status **"Reprovado"** com média **maior ou igual a 5**.

Ordene em ordem alfabética pelo nome do aluno.

---

## Distribuição das Questões por Estagiário

**bruna-oliveira:**
- 1–10: questão 9
- 11–20: questão 17
- 21–30: questão 21
- 31–40: questão 39
- 41–50: questão 50
- 51–60: questão 54
- 61–70: questão 67
- 71–80: questão 73
- 81–90: questão 86

**carlos-saldanha:**
- 1–10: questão 10
- 11–20: questão 20
- 21–30: questão 24
- 31–40: questão 35
- 41–50: questão 46
- 51–60: questão 58
- 61–70: questão 63
- 71–80: questão 78
- 81–90: questão 84

**emmanuel-uchoa:**
- 1–10: questão 2
- 11–20: questão 13
- 21–30: questão 26
- 31–40: questão 37
- 41–50: questão 45
- 51–60: questão 52
- 61–70: questão 64
- 71–80: questão 80
- 81–90: questão 81

**gabriel-felix:**
- 1–10: questão 1
- 11–20: questão 16
- 21–30: questão 27
- 31–40: questão 36
- 41–50: questão 47
- 51–60: questão 55
- 61–70: questão 70
- 71–80: questão 76
- 81–90: questão 89

**gabriel-merces:**
- 1–10: questão 7
- 11–20: questão 15
- 21–30: questão 25
- 31–40: questão 31
- 41–50: questão 48
- 51–60: questão 60
- 61–70: questão 68
- 71–80: questão 77
- 81–90: questão 88

**marcelo-jacinto:**
- 1–10: questão 6
- 11–20: questão 12
- 21–30: questão 30
- 31–40: questão 34
- 41–50: questão 41
- 51–60: questão 59
- 61–70: questão 66
- 71–80: questão 71
- 81–90: questão 90

**nilvan-silvano:**
- 1–10: questão 4
- 11–20: questão 18
- 21–30: questão 22
- 31–40: questão 33
- 41–50: questão 49
- 51–60: questão 56
- 61–70: questão 61
- 71–80: questão 75
- 81–90: questão 83

**rodrigo-diniz:**
- 1–10: questão 5
- 11–20: questão 11
- 21–30: questão 28
- 31–40: questão 40
- 41–50: questão 44
- 51–60: questão 53
- 61–70: questão 62
- 71–80: questão 72
- 81–90: questão 85

**victor-leite:**
- 1–10: questão 8
- 11–20: questão 19
- 21–30: questão 23
- 31–40: questão 38
- 41–50: questão 43
- 51–60: questão 57
- 61–70: questão 65
- 71–80: questão 74
- 81–90: questão 87

**vinicius-souza:**
- 1–10: questão 3
- 11–20: questão 14
- 21–30: questão 29
- 31–40: questão 32
- 41–50: questão 42
- 51–60: questão 51
- 61–70: questão 69
- 71–80: questão 79
- 81–90: questão 82
