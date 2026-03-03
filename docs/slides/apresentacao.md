---
marp: true
paginate: true
_paginate: false
footer: 'MC404 - Organização Básica de Computadores e Linguagem de Montagem - Rodolfo Azevedo - CC BY-SA 4.0'
headingDivider: 2
---

# MC404 - Organização Básica de Computadores e Linguagem de Montagem

Rodolfo Azevedo - rodolfo.azevedo@unicamp.br

http://www.ic.unicamp.br/~rodolfo/mc404

Você também já deve estar no Google Classroom

## O que esperar dessa disciplina?

* Entender os componentes básicos de um computador
* Entender e representar informações na memória de um computador
* Entender as instruções típicas de processadores modernos e utilizá-las para criar programas pequenos e médios
* Entender como o processador se comunica com a memória e periféricos
* Programar dispositivos de entrada e saída
* Noções de segurança de software
* Tratar interrupções

## Eu me comprometo a ...

* preparar todo o material com a devida antecedência
* acompanhar seu aprendizado
* prestar atendimento quando solicitado e necessário
* corrigir as avaliações e divulgar os gabaritos rapidamente

## Você se compromete a ...

* dedicar seu tempo a esta disciplina
* não deixar dúvidas nem conteúdo acumularem
* não colar nem oferecer cola
* avisar sempre que tiver algum contratempo para que possamos encontrar uma solução juntos

## Avaliação

| Atividade           | Peso | Quando  | Regras                                 |
| ------------------- | ---- | ------- | -------------------------------------- |
| Testes e atividades | 40%  | semanal | Individual, sem consulta, sem conversa |
| Prova 1             | 30%  | 22/04   | Individual, sem consulta, sem conversa |
| Prova 2             | 30%  | 17/06   | Individual, sem consulta, sem conversa |

  * Exame
    * Média aritmética entre as notas do semestre e a do exame
    * Nota mínima de 2,5 no semestre para realizar exame
    * Data: 15/07.

## Dinâmica da Disciplina

  * Aulas teóricas todas as quartas às 17h no CB02
  * Aulas práticas segundas às 21h (CC00) e sexta às 21h (CC04)
  * Presença obrigatória nas aulas teóricas e práticas
  * Atendimento síncrono e assíncrono
    * Horário de atendimento: segundas e quartas às 18h na sala 3 do IC1
    * Caso precise de horário alternativo, envie um email solicitando
    * Podemos trocar esse horário caso a turma tenha interesse
  * Avisos e atualizações publicados no Google Classroom
  * Pretendo gravar todas as aulas teóricas

## Algumas ações práticas

* Já existem atividades de laboratório na página da disciplina
* A ordem dos temas das aulas não será a mais tradicional nesse primeiro mês pois vamos avançar sobre conteúdos para fundamentar os laboratórios
* Por isso, alguns conceitos serão apresentados apenas mais para a frente na disciplina
* Mas, se a curiosidade não deixar, você pode perguntar/consultar material suplementar antes

## Contingência

* Caso algum evento demande ação de contingência, o professor irá informar a turma por meio do Google Classroom.

* Caso você tenha algum evento de contingência, por favor, avise o professor o quanto antes.

* Caso você tenha alguma necessidade especial, por favor, avise o professor o quanto antes.

* [Playlist](https://www.youtube.com/watch?v=ELbnZzxeec4&list=PLEUHFTHcrJmswfeq7QEHskgkT6HER3gK6) com vídeos de semestres anteriores (:warning: foque apenas na parte de RISC-V)


## Por que o melhor jogador de futebol do mundo em 2025 faz musculação?

![bg left:50%](OusmaneDembele-musculacao.jpg)

Ousmane Dembélé na academia do Paris Saint Germain, em 2025.

## IA e Programação em Assembly

* Os modelos de IA são razoavelmente bons para gerar código em assembly, embora sejam melhores para gerar código em linguagens de alto nível como C ou Python
* Existe uma forma muito mais fácil de gerar código assembly:
  * Escreva o código em C e utilize um compilador para gerar o código assembly correspondente
  
```bash
$ riscv64-unknown-elf-gcc -S -o output.s input.c
```
* Vocês estão se desenvolvendo para serem profissionais de computação. Precisam tanto aprender as técnicas quanto aprender a utilizar IA.
* A analogia mais próxima que vejo é a da calculadora. Apesar de saberem que ela faz contas, em diversas disciplinas você precisa fazer as contas diretamente.
* 