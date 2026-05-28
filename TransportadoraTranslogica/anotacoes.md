# Anotações durante a revisão para de MS SQL Serve

-> Todo filtro que precise ser feito usando um campo que seja uma FK é melhor que se use o valor `INT` dela do que fazer um `INNER JOIN`. 

-> Colocar filtro no `INNER JOIN`

## Formatação para estrutura da query: 0, 4, 8, 12

```
SELECT  mo.Nome as Morador 
    FROM Morador AS mo 
        INNER JOIN Bairro AS ba 
            ON ba.IdMorador = mo.Id; 
```

- 0 espaços no `SELECT` e 2 espaços entre o `SELECT` e o `mo.Nome`
- 4 espaços no `FROM` 
- 8 espaços no `INNER JOIN`
- 12 espaços no `ON`
- O `Alias` deve ser escrito apenas em duas letras. Nos campos do `SELECT` deve-se colocar `as` e nos campos do `FROM` /` INNER` / `LEFT` / `RIGTH JOIN` deve-se ser `AS`.

## Forma de leitura de questões em SQL:

Deve ser feito 4 perguntas:

| Enunciado         | O que usar            |
| ----------------- |:---------------------:|
| O que exibir?     | SELECT                |
| De onde vem?      | FROM + JOINS          |
| Qual a condição?  | WHERE                 |
| Com agrupamento?  | GROUP BY + HAVING     |

### Formas que aparecem:

- `COUNT()` / `SUM()`: "Número de", "total de", "quantidade"
- `WHERE` / `HAVING`: "apenas", "somente", "que possuem"
- `IS NULL` / `NOT EXISTS`: "não possui", "nunca", "ainda não", "sem vínculo"

##
