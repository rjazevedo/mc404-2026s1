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

# Interação com programas em alto nível

Rodolfo Azevedo

MC404 - Organização Básica de Computadores e Linguagem de Montagem

http://www.ic.unicamp.br/~rodolfo/mc404

## Contexto

* Nas aulas anteriores, seus programas sempre foram escritos diretamente em linguagem de montagem e rodados diretamente no simulador.
* Você tem, também, a opção de utilizar outros códigos já desenvolvidos para complementar o seu programa, chamando rotinas que foram escritas em outras linguagens.
* Da mesma forma, você também pode escrever rotinas em linguagem de montagem e chamá-las a partir de um programa escrito em uma linguagem de alto nível, como C.

## Como isso funciona?

* Para que isso seja possível, é necessário que haja um acordo entre o código em linguagem de montagem e o código em linguagem de alto nível sobre como os dados serão passados entre eles.
* Esse acordo é chamado de **convenção de chamada** (calling convention) e define como os parâmetros são passados, como os valores de retorno são passados, quais registradores devem ser preservados, etc.
  * Você já sabe disso, não é? Já tem utilizado todas as convenções de registradores até o momento.

## Duas formas de interligar código em linguagem de montagem e código em linguagem de alto nível

1. Código em linguagem de alto nível chamando código em linguagem de montagem
   * Basta seguir as convenções de chamada
2. Código em linguagem de montagem chamando código em linguagem de alto nível
   * Basta seguir as convenções de chamada

> Em ambos os casos, as convenções de chamada devem ser respeitadas para que a comunicação entre os códigos funcione corretamente.

## Código assembly gerado a partir de código C

Considere o programa abaixo escrito em C:

```c
#include <stdio.h>

int main()
{
  printf("Hello World!\n");
}
```

que será compilado com o comando:

```bash
$ riscv64-unknown-elf-gcc hello.c -S
```

## Código assembly gerado

```mipsasm
	.file	"hello.c"
	.option nopic
	.attribute arch, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.rodata
	.align	3
.LC0:
	.string	"Hello World!"
	.text
	.align	1
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sd	ra,8(sp)
	sd	s0,0(sp)
	addi	s0,sp,16
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	puts
	li	a5,0
	mv	a0,a5
	ld	ra,8(sp)
	ld	s0,0(sp)
	addi	sp,sp,16
	jr	ra
	.size	main, .-main
	.ident	"GCC: (g04696df09) 14.2.0"
	.section	.note.GNU-stack,"",@progbits

```

## Decifrando parte a parte: cabeçalho

```mipsasm
.file	"hello.c"
.option nopic
.attribute arch, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0"
.attribute unaligned_access, 0
.attribute stack_align, 16
```

* Arquivo **hello.c**
* Opção **nopic**: código não é independente de posição
* Atributos de arquitetura: indica as instruções que o processador deve suportar para ser capaz de executar esse programa
* Atributo de acesso desalinhado indicando que não deve ser tentado acesso desalinhado por perda de desempenho
* Atributo de alinhamento da pilha indicando que a pilha deve ser alinhada a 16 bytes

## Decifrando parte a parte: seção de dados

```mipsasm
	.text
	.section	.rodata
	.align	3
.LC0:
	.string	"Hello World!"
```

* Cria a seção **.rodata** para armazenar dados somente leitura
* Alinha o endereço do próximo dado a um múltiplo de 8 bytes (2^3)
* Define um label **.LC0** para o endereço onde a string "Hello World!" está armazenada


## Decifrando parte a parte: seção de código
```mipsasm
.text
.align	1
.globl	main
.type	main, @function
```

* Cria a seção **.text** para armazenar o código
* Alinha o endereço do próximo código a um múltiplo de 2 bytes (2^1)
* Declara o label **main** como global, ou seja, ele pode ser acessado por outros arquivos
* Declara o tipo de **main** como função

## Decifrando parte a parte: código da função main

* Esse código foi gerado com compilador de **64 bits**

```mipsasm
main:
	addi	sp,sp,-16   # Espaço para 2 elementos na pilha
	sd	ra,8(sp)      # SD é o store de 64 bits
	sd	s0,0(sp)
	addi	s0,sp,16    # s0 é o ponteiro para o frame pointer
	lui	a5,%hi(.LC0)  # Carrega LC0
	addi	a0,a5,%lo(.LC0) # Completa a carga de LC0
	call	puts        # Compilador trocou printf por puts
	li	a5,0
	mv	a0,a5
	ld	ra,8(sp)
	ld	s0,0(sp)
	addi	sp,sp,16
	jr	ra            # ret
```

## Último bloco de código

```mipsasm
	.size	main, .-main
	.ident	"GCC: (g04696df09) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
```

* Define o tamanho da função main (. é o endereço atual)
* Identifica o compilador utilizado para gerar o código
* Cria uma seção para indicar que o programa não precisa de uma pilha executável

## Código otimizado

Adicionando a opção **-O3** ao comando de compilação

```bash
riscv64-unknown-elf-gcc hello.c -O3 -S
```
## Novo código assembly gerado

```mipsasm
	.file	"hello.c"
	.option nopic
	.attribute arch, "rv64i2p1_m2p0_a2p1_f2p2_d2p2_c2p0_zicsr2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC0:
	.string	"Hello World!"
	.section	.text.startup,"ax",@progbits
	.align	1
	.globl	main
	.type	main, @function
main:
	lui	a0,%hi(.LC0)
	addi	sp,sp,-16
	addi	a0,a0,%lo(.LC0)
	sd	ra,8(sp)
	call	puts
	ld	ra,8(sp)
	li	a0,0
	addi	sp,sp,16
	jr	ra
	.size	main, .-main
	.ident	"GCC: (g04696df09) 14.2.0"
	.section	.note.GNU-stack,"",@progbits

```

## Assembly inline

* Você pode incluir pequenos trechos de código assembly dentro de um programa escrito em C, utilizando a funcionalidade de **assembly inline**

## Exemplo de código C com assembly inline

### Código em C
```c
#include <stdio.h>

int main()
{
  int a = 5, b = 10, c;

  __asm__(
      "add %[out], %[in_a], %[in_b]"
      : [out] "=r"(c)
      : [in_a] "r"(a), [in_b] "r"(b));

  printf("Resultado: %d\n", c);
  return 0;
}
```

### O que significa?

* O código dentro de `__asm__` é o código assembly que será executado
* O que está entre colchetes logo a seguir **[out]**, **[in_a]** e **[in_b]** são os nomes para os operandos
* Logo a seguir vem uma linha para saídas e outra para entradas que fazem o mapeamento de nomes para variáveis em C

## Explicando o código assembly inline

```C
__asm__(
    "add %[out], %[in_a], %[in_b]"
    : [out] "=r"(c)
    : [in_a] "r"(a), [in_b] "r"(b));
```

* Essa linha é o código assembly que será executado
* O `add` é a instrução de soma
* O `%[out]` é o operando de saída, que será mapeado para a variável `c` em C
* O `%[in_a]` e o `%[in_b]` são os operandos de entrada
* O `=r` indica que o operando de saída deve ser armazenado em um registrador, e o `r` indica que os operandos de entrada devem ser armazenados em registradores

## Quando utilizar assembly inline?

* Quando você precisa utilizar instruções que não são totalmente suportadas pelo compilador
* Quando você precisa de um controle mais preciso sobre o código gerado
* Quando você quer otimizar um trecho específico de código que o compilador não consegue otimizar
* 