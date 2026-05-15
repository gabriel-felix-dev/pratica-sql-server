# Tarefa – Modelagem e Banco de Dados: Sistema de Gestão Aeroportuária Céu Azul

## Regra de negócio: Aeroporto Internacional Céu Azul

O Aeroporto Internacional Céu Azul é um dos principais centros de conexão aérea do país, operando centenas de voos diariamente. Com o aumento do volume de operações, a administração do aeroporto decidiu desenvolver um sistema interno para organizar e consultar informações sobre voos, passageiros e companhias aéreas.

O aeroporto opera em parceria com diversas **companhias aéreas**. Cada companhia possui um código IATA único de dois caracteres — como "LA" ou "G3" —, um nome e o país de origem. Uma companhia aérea pode operar vários voos a partir do aeroporto.

Os **voos** são a entidade central do sistema. Cada voo possui um código único — por exemplo, "LA3042" —, um aeroporto de origem, um aeroporto de destino, uma data e hora de partida e uma duração estimada em minutos. Todo voo deve estar obrigatoriamente vinculado a uma companhia aérea, sem a qual ele não pode ser cadastrado no sistema. Além disso, cada voo possui um status operacional, que pode ser: **No Horário**, **Atrasado** ou **Cancelado**.

Os **passageiros** que utilizam o aeroporto são cadastrados com nome completo, data de nascimento, CPF único e número de passaporte, que também deve ser único no sistema. Um passageiro pode embarcar em vários voos ao longo do tempo.

A associação entre um passageiro e um voo é registrada como um **embarque**. Ao confirmar o embarque, o sistema registra a classe de viagem escolhida pelo passageiro — que pode ser **Econômica**, **Executiva** ou **Primeira Classe** —, o número da poltrona e a data de emissão do bilhete. Um passageiro não pode ter dois embarques no mesmo voo.
