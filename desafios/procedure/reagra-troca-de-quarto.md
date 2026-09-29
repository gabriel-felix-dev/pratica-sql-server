-Um hóspede já com check-in realizado pode pedir para trocar de quarto no meio da estadia (ex.: quarto com problema, upgrade, preferência). A operação deve:

--Só ser permitida para uma reserva que esteja atualmente em CHECKIN (hospedagem em andamento, sem check-out).
--Validar que o quarto novo está disponível para o período que falta da estadia (da data de hoje até a DataSaida já prevista da reserva)
--Não permitir transferir para o mesmo quarto que já está ocupando.
--Encerrar a ocupação do quarto antigo e abrir a ocupação do quarto novo atomicamente — se qualquer validação falhar, nada muda.
--Preservar o histórico: a reserva original não pode ser apagada nem "sumir" — o sistema tem que continuar sabendo que aquele hóspede ficou no quarto antigo até a hora da troca, 
--e no quarto novo depois.

/*
Transferência válida (quarto novo livre).
Tentativa de transferência para quarto que já está ocupado no período.
Tentativa de transferência para o mesmo quarto.
Tentativa de transferência numa reserva que ainda não fez check-in.
Tentativa de transferência numa reserva já com check-out.
Consulta que mostre o "caminho" do hóspede (quarto antigo → quarto novo) depois da troca.
*/