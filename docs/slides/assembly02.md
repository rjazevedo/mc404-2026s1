---
marp: true
paginate: true
_paginate: false
footer: 'MC404 - Organização Básica de Computadores e Linguagem de Montagem - Rodolfo Azevedo - CC BY-SA 4.0'
headingDivider: 2
---

<style>
@import "./h3-duas-colunas.css";
</style>

# Instruções RISC-V

Rodolfo Azevedo

MC404 - Organização Básica de Computadores e Linguagem de Montagem

http://www.ic.unicamp.br/~rodolfo/mc404

## Contexto

* Nos slides anteriores, vimos algumas das instruções e registradors do RISC-V
* Agora vamos avançar ampliando o conjunto de instruções e também trazendo novos registradores

## Instruções utilizadas no laboratório

| Instrução | Funcionalidade                              |
| --------- | ------------------------------------------- |
| add       | Soma dois registradores                     |
| sub       | Subtrai dois registradores                  |
| and       | Faz a operação lógica E                     |
| or        | Faz a operação lógica OU                    |
| xor       | Faz a operação lógica OU exclusivo          |
| sll       | Faz um deslocamento de bits para a esquerda |
| srl       | Faz um deslocamento de bits para a direita  |

Inclusive as versões com imediato dessas instruções: addi, andi, ori, xori, slli e srli.

## Meta da aula de hoje

Ser capaz de entender e implementar em assembly códigos que contenham as seguintes estruturas:

  * if
  * if-else
  * while
  * for

## if then else

> Se uma dada condição for verdadeira (if), então execute um trecho de código. Caso contrário (else), execute outro trecho de código.

```c
if (x == 5)
  a += 7;
else
  a += 15;
```

## while

> Enquanto uma dada condição for verdadeira, execute um trecho de código.

```c
x = 20;
y = 10;
while (x != y)
{
  x += 2;
  y += 3;
}
```

## for

> Execute um trecho de código um número fixo de vezes.

```c
  a = 0;
  for (i = 0; i < 100; i ++)
    a += i;
```


## Complementando os Registradores

| Registrador | Descrição                                     |
| ----------- | --------------------------------------------- |
| zero        | Valor fixo em zero (0)                        |
| ra          | Endereço de retorno de chamada de função      |
| sp, gp, tp  | Apontador de pilha, dados globais e de thread |
| t0-t6       | Valores temporários                           |
| s0-s11      | Valores salvos                                |
| a0-a7       | Argumentos para função e valores de retorno   |
| pc          | Contador de programa                          |

## Instruções de comparação

| Instrução                        | Formato | Uso                |
| -------------------------------- | ------- | ------------------ |
| Set less than                    | R       | SLT rd, rs1, rs2   |
| Set less than immediate          | I       | SLTI rd, rs1, imm  |
| Set less than unsigned           | R       | SLTU rd, rs1, rs2  |
| Set less than unsigned immediate | I       | SLTIU rd, rs1, imm |

## Exemplo

* Como saber se i < j? 

  ```mipsasm
  slt t0, t1, t2   # onde t1 deve ter o valor de i, t2 de j e t0 terá o resultado
  ```

* Se i < j
  * t0 = 1
* Caso contrário
  * t0 = 0


## Instruções de salto

> São instruções que desviam a execução do programa para um endereço diferente da próxima instrução

| Instrução              | Formato | Uso               |
| ---------------------- | :-----: | ----------------- |
| Jump and link          |    J    | JAL rd, label     |
| Jump and link register |    J    | JALR rd, rs1, imm |


## Instruções de saltos condicionais

| Instrução             | Formato | Uso                  |
| --------------------- | :-----: | -------------------- |
| Branch if ==          |    B    | BEQ rs1, rs2, label  |
| Branch if !=          |    B    | BNE rs1, rs2, label  |
| Branch if <           |    B    | BLT rs1, rs2, label  |
| Branch if >=          |    B    | BGE rs1, rs2, label  |
| Branch if < unsigned  |    B    | BLTU rs1, rs2, label |
| Branch if >= unsigned |    B    | BGEU rs1, rs2, label |

:warning: Você pode inverter a ordem dos operandos se necessário!

## Exemplo

* Se x == 0, some z = y + 5, caso contrário z = y + 7

  ```mipsasm
  # supondo que t0 tenha o valor de x, t1 de y e t2 de z
      bne t0, zero, else
      addi t2, t1, 5
      j fim
  else: 
      addi t2, t1, 7
  fim:
  ```

* Você consegue melhorar esse código?

## Posso melhorar?

* Se x == 0, some z = y + 5, caso contrário z = y + 7

  ```mipsasm
  # supondo que t0 tenha o valor de x, t1 de y e t2 de z
      addi t2, t1, 5
      beq t0, zero, fim
      addi t2, t1, 2
  fim:
  ```


## Pseudo-instruções

> *Pseudo-instruções não são instruções reais, mas são úteis para escrever código mais legível. O montador converteem uma ou mais instruções reais*

| Instrução        | Descrição                                         | Conversão                                  |
| ---------------- | ------------------------------------------------- | ------------------------------------------ |
| li a0, constante | Carrega uma constante em um registrador           | Utiliza lui + addi para compor a constante |
| la a0, label     | Carrega o endereço de uma label em um registrador | Utiliza auipc, mv e ld se necessário       |
| mv a0, a1        | Move o valor de um registrador para outro         | Utiliza addi                               |

## Outros exemplos de pseudo-instruções

| Instrução  | Descrição                         | Conversão                  |
| ---------- | --------------------------------- | -------------------------- |
| call label | Chama uma função                  | Utiliza jal ou jalr        |
| nop        | Nenhuma operação                  | Utiliza addi zero, zero, 0 |
| j destino  | Salta para um destino             | Utiliza jalr zero, destino |
| ret        | Retorna de uma função             | Utiliza jalr zero, ra 0    |
| not rd, rs | Inverte os bits de um registrador | xori rd, rs, -1            |

## Exemplos de código em alto nível  vs Assembly

Para cada código em C, faça uma implementação em assembly para o RISC-V

## if then else

### Código em C

- Suponha que **x** e **a** estão em **s0** e **s1**, respectivamente

```c
if (x == 5)
  a += 7;
else:
  a += 15;
```

## if then else

### Código em C

- Suponha que **x** e **a** estão em **s0** e **s1**, respectivamente

```c
if (x == 5)
  a += 7;
else:
  a += 15;
```

### Código em Assembly
```mipsasm
main:
  addi s0, zero, 9 # Valor inicial de x
  addi s1, zero, 0 # Valor inicial de a
  ...
  addi t0, zero, 5 # Valor a comparar

  bne s0, t0, else # Se x != 5, vá para o else
  addi s1, s1, 7
  j fim            # Vá para o fim do if-else

else:
  addi s1, s1, 15

fim:
  ret
```

## while

### Código em C

- Suponha que **x** e **y** estão em **s0** e **s1**, respectivamente

```c
x = 20;
y = 10;
while x != y
{
  x += 2;
  y += 3;
}
```

## Resolução

### Código em C

- Suponha que **x** e **y** estão em **s0** e **s1**, respectivamente

```c
x = 20;
y = 10;
while x != y
{
  x += 2;
  y += 3;
}
```

### Código em Assembly

```mipsasm
main:
  addi s0, zero, 20   # x
  addi s1, zero, 10   # y

while:
  beq s0, s1, fim     # x == y ? vá para o fim
  addi s0, s0, 2
  addi s1, s1, 3
  j while             # vá para o início do loop

fim:
  ret               # retorne
```

## for

### Código em C

- Suponha que **a** e **i** estão em **s0** e **s1**, respectivamente

```c
  a = 0;
  for (i = 0; i < 100; i ++)
    a += i;
```

## Resolução

### Código em C

- Suponha que **a** e **i** estão em **s0** e **s1**, respectivamente

```c
  a = 0;
  for (i = 0; i < 100; i ++)
    a += i;
```

### Código em Assembly

```mipsasm
main:
  addi s0, zero, 0    # a
  addi s1, zero, 0    # i
  addi t0, zero, 100  # constante 100 para limite do for

for:
  bge s1, t0, fim     # i >= 100 ? vá para o fim
  add s0, s0, s1      # a += i
  addi s1, s1, 1      # i++
  j for               # vá para o início do loop

fim:
  ret                 # retorne
```
