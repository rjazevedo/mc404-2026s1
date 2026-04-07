---
marp: true
paginate: true
_paginate: false
footer: 'MC404 - Organização Básica de Computadores e Linguagem de Montagem - Rodolfo Azevedo - CC BY-SA 4.0'
headingDivider: 2
---
# Funções

Rodolfo Azevedo

MC404 - Organização Básica de Computadores e Linguagem de Montagem

http://www.ic.unicamp.br/~rodolfo/mc404

## O que é uma função?

Função é uma abstração para um conjunto de instruções que possui:

* Um ponto único de entrada
* Um ou mais pontos de saída
* Zero ou mais parâmetros de entrada
* Zero ou mais valores de saída
* Um nome (opcional para o processador)

## Instruções relevantes para construir uma função

* `CALL`: chama uma função
* `RET`: retorna de uma função

Ambas são pseudo-instruções relacionadas com instruções de salto.

* `CALL` é equivalente à `JAL ra, destino`, onde `ra` terá o endereço de retorno da função
* `RET` é equivalente à `JALR zero, ra, 0`, onde `ra` é o endereço para onde a função vai retornar, gravado anteriormente pela instrução `CALL`

## Exemplo de função

```mipsasm
# Função que recebe um valor em a0 e retorna o dobro em a0
# O nome da função é "dobro"
dobro:
    add a0, a0, a0
    ret

main:
    li a0, 10
    call dobro  # a0 = 20
    li a0, 5
    call dobro  # a0 = 10
    li a0, 1
    call dobro  # a0 = 2
    ret         # e agora? para onde volta?
```

## E como ficam os registradores?

Imagine que cada uma das funções abaixo foi implementada por um programador diferente. Que registradores cada um poderá alterar (`t`, `s` e `a`)?

![](funcoes-multiplas-chamadas.png)

## Convenções de registradores

* Agora que estamos organizando o código em funções, é importante definir a responsabilidade pelos valores de cada registrador
* Já temos que os registradores `t` são considerados como temporários e os `s` são considerados salvos. Mas o que significa isso?
  * Por convenção, os registradores `t` são **temporários** e podem ser alterados por qualquer função, enquanto os registradores `s` são **salvos** e devem ser preservados por qualquer função
* Os registradores `a` são usados para passar parâmetros para funções e receber valores de retorno

## Relembrando os registradores

| Registrador | Descrição                                     |
| ----------- | --------------------------------------------- |
| zero        | Valor fixo em zero (0)                        |
| ra          | Endereço de retorno de chamada de função      |
| sp, gp, tp  | Apontador de pilha, dados globais e de thread |
| t0-t6       | Valores temporários                           |
| s0-s11      | Valores salvos                                |
| a0-a7       | Argumentos para função e valores de retorno   |
| pc          | Contador de programa                          |

## Convenções de registradores

| Registrador | O que pode ser feito?                                                         |
| ----------- | ----------------------------------------------------------------------------- |
| t0-t6       | Qualquer função pode alterar, não é garantida a preservação por outra função  |
| s0-s11      | A função pode alterar mas precisa restaurar o valor anterior antes do retorno |
| a0-a7       | Funções podem alterar, não é garantida a preservação por outra função         |

## Layout da memória do programa

![bg right h:600](layout-memoria.png)

* O programa é carregado na memória 
* Os dados são carregados a seguir
* Depois existem dois espaços vazios que são reservados:
  * Heap para variáveis dinâmicas
  * Stack (pilha) para valores temporários e endereços de retorno

## Pilha

* É um espaço de memória onde seu programa deve tratar como uma pilha de dados
* A pilha cresce para baixo: começa de endereços grandes e é decrementada
* A convenção de registradores reserva o registrador `sp` para apontar para o topo da pilha
* **`sp` indica o endereço do último elemento guardado na pilha**
* Utilize o `sp` nas instruções de `lw` e `sw` para acessar a pilha
* Não deixe de decrementar o `sp` antes de escrever um valor na pilha e incrementar depois de ler um valor
* Você realizar todos os decrementos de uma vez, bem como os incrementos

## Exemplo
  
### Inserindo 2 elementos na pilha

```mipsasm
addi sp, sp, -8
sw   ra, 0(sp)
sw   s0, 4(sp)
``` 

### Removendo 2 elementos da pilha

```mipsasm
lw   s0, 4(sp)
lw   ra, 0(sp)
addi sp, sp, 8
```

*Note a ordem invertida das instruções!*

## Exercício

Suponha a existência das funções ```scanf``` e ```printf``` da linguagem C para ler e escrever dados. Implemente um código que leia um número inteiro N, limitado a 20, em seguida ele deve ler N números inteiros sinalizados, guardando cada um num vetor e imprimir a soma desses números. Para a realizar a soma deles, você deve implementar uma função à parte que recebe um vetor e o seu tamanho, retornando a soma que, posteriormente, será impressa. Seu código deve começar na função ```main```.

## Implementação

```mipsasm
.data
vetor: .space 80 # 20 números inteiros de 4 bytes cada
.text
main:
    # Ler N
    # Verificar se N é menor ou igual a 20
    # Ler N números inteiros e armazenar no vetor
    # Chamar a função somaVetor passando o vetor e N
    # Imprimir o resultado da soma

somaVetor:
    # Recebe o vetor e o tamanho N
    # Inicia um acumulador com zero
    # Loop para somar os elementos do vetor
    # Retorna a soma
```

## somaVetor

```mipsasm
somaVetor: # função folha
    # a0: endereço do vetor
    # a1: tamanho N do vetor
    li   t0, 0          # acumulador para a soma
    li   t1, 0          # índice do vetor
loop:
    beq  t1, a1, end    # se índice == N, termina o loop
    lw   t2, 0(a0)      # carrega o elemento do vetor
    add  t0, t0, t2     # acumula a soma
    addi a0, a0, 4      # move para o próximo elemento do
    addi t1, t1, 1      # incrementa o índice
    j    loop           # repete o loop
end:
    mv a0, t0           # move a soma para a0 para retorno
    ret
```

## leVetor

```mipsasm
.data
  formato: .asciiz "%d"
.text
leVetor:
    # a0: endereço do vetor
    # a1: tamanho N do vetor
    addi sp, sp, -8        # salvar s0 e s1 na pilha
    sw   s0, 0(sp)
    sw   s1, 4(sp)
    mv   s0, a0
    mv   s1, a1
loop:
    beq  s1, zero, end     # se índice == 0, termina o loop
    la   a0, formato       # endereço do formato para leitura
    mv   a1, s0            # endereço do próximo elemento do vetor
    call scanf             # chama scanf para ler um número
    addi s0, s0, 4         # move para o próximo elemento do vetor
    addi s1, s1, -1        # decrementa o índice
    j    loop              # repete o loop
end:
    lw   s0, 0(sp)         # restaurar s0 e s1 da pilha
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret

```

## main

```mipsasm
main:
    addi sp, sp, -8
    sw   s0, 0(sp)
    sw   s1, 4(sp)
leN:
    la   a0, formato       # endereço do formato para leitura
    call scanf             # chama scanf para ler N
    # Verificar se N é menor ou igual a 20
    li   t0, 20
    bgt  a0, t0, leN       # se N > 20, volta para leN
    la   s0, vetor         # endereço do vetor
    mv   s1, a0            # guarda N em s1
    mv   a0, s0            # endereço do vetor para leVetor
    mv   a1, s1            # tamanho N para leVetor
    call leVetor           # chama leVetor para ler os números
    mv   a0, s0            # endereço do vetor para somaVetor
    mv   a1, s1            # tamanho N para somaVetor
    call somaVetor         # chama somaVetor para calcular a soma
    # Imprimir o resultado da soma
    mv   a1, a0            # resultado da soma em a1 para printf
    la   a0, formato       # endereço do formato para impressão
    call printf            # chama printf para imprimir a soma
    lw   s0, 0(sp)         # restaurar s0 e s1 da pilha
    lw   s1, 4(sp)
    addi sp, sp, 8
    ret

```
