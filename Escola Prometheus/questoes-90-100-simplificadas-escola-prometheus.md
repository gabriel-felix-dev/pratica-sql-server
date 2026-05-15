# Questões Simplificadas — Escola Prometheus

---

### Questão 90
Liste os CPFs dos alunos que realizaram matrícula duplicada no mesmo ano — ou seja, duas matrículas cadastradas em meses diferentes, mas com o mesmo ano, independentemente de cancelamentos.

---

### Questão 91
Liste o nome do aluno, a disciplina, a média final armazenada e a média ponderada calculada pelas notas brutas (Trabalho × 0,4 + Prova × 0,6), exibindo apenas os casos em que os dois valores **divergem**.

---

### Questão 92
Liste o nome do aluno, o nome da disciplina e o código de status de reprovação para todos os registros do histórico acadêmico que estão com status **"Reprovado"** e, ao mesmo tempo, possuem **média final nula**.

---

### Questão 93
Liste o nome do aluno, o nome da disciplina e o número da matrícula para os alunos que têm pelo menos uma disciplina com status **"Cursando"**, mas para os quais **nenhuma nota** foi lançada nessa matrícula.

---

### Questão 94
Liste o nome do professor, sua área de formação e a disciplina que leciona nos casos em que há **incompatibilidade** entre a formação e a disciplina — ou seja, quando o nome da área de formação não contém nenhuma palavra-chave relacionada ao nome da disciplina (use LIKE).

---

### Questão 95
Liste o nome do aluno, o título do exame, a data de realização do exame e a data de matrícula do aluno para todos os casos em que o exame foi realizado **antes** da data de ingresso do aluno na instituição.

---

### Questão 96
Liste o nome do aluno, o nome da disciplina, a média final e o código de status de cancelamento para os registros do histórico que estão com status de **cancelamento** mas, paradoxalmente, possuem uma **média final preenchida**.

---

### Questão 97
Liste o nome das disciplinas que **não possuem nenhum aluno matriculado**, exibindo também o nome do professor responsável e a carga horária da disciplina.

---

### Questão 98
Liste as disciplinas que possuem **menos de 2 modalidades de avaliação cadastradas** (Trabalho e/ou Prova), exibindo o nome da disciplina, a quantidade atual de modalidades e quais modalidades estão **faltando**.

---

### Questão 99
Considerando que cada aluno deveria ter apenas uma matrícula vinculada ao seu número sequencial, escreva uma consulta que identifique alunos com **exatamente uma matrícula**, demonstrando como a unicidade da chave se sustenta na base.

---

### Questão 100
Liste o nome do aluno, a disciplina, a média final e o status de conclusão para os casos em que há **inconsistência entre nota e resultado**:

- Status **"Aprovado"** com média **menor que 5**, ou
- Status **"Reprovado"** com média **maior ou igual a 5**.

Ordene o resultado em ordem alfabética pelo nome do aluno.
