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

# Segurança

Rodolfo Azevedo

MC404 - Organização Básica de Computadores e Linguagem de Montagem

http://www.ic.unicamp.br/~rodolfo/mc404

## Como posso atacar um programa ou me defender de ataques?

* As técnicas de ataque e defesa são similares
* Conhecer o funcionamento do programa é essencial para atacar ou se defender
* Existem múltiplos tipos de vulnerabilidades e elas se repetem em múltiplos programas ou bibliotecas
* Vamos falar sobre uma das mais comuns: **buffer overflow**

## Buffer overflow

* O que é um buffer?
  * Um buffer é uma região de memória alocada para armazenar dados
  * Exemplo: um array de caracteres para armazenar uma string
* O que é um buffer overflow?
  * Um buffer overflow ocorre quando um programa escreve mais dados em um buffer do que ele pode armazenar, sobrescrevendo dados adjacentes na memória

## Objetivos da aula

* Entender **como** ocorre buffer overflow na memória
* Classificar variações importantes de overflow
* Ver formas clássicas de ataque (pilha, heap, índices, inteiros)
* Relacionar C com assembly **RISC-V**
* Discutir defesas: compilador, SO e projeto de software

## Escopo e ética

* Foco: compreensão técnica para **prevenção e auditoria**
* Não vamos cobrir exploração real contra sistemas de terceiros
* Ambiente de laboratório controlado
* Objetivo: escrever código mais seguro

## Modelo mental: memória de processo

* Segmento de código (text)
* Dados globais (data/bss)
* Heap (alocação dinâmica)
* Pilha (frames de função)
* Em overflow, o erro vem de
  * **ausência de validação de limites**

## Exemplo mínimo em C (vulnerável)

```c
#include <stdio.h>

void login(void) {
    char nome[16];
    gets(nome); // insegura: nao checa tamanho
    printf("Ola, %s\n", nome);
}
```

* Se entrada > 15 caracteres (+ '\0'), há escrita fora do vetor
* Em stack frame, isso pode corromper variáveis locais e endereço de retorno

## Stack frame (visão didática)

| Ordem (memória)  | Conteúdo no frame          |
| ---------------- | -------------------------- |
| Endereços altos  | retorno (`ra` salvo)       |
|                  | `s0` salvo / frame pointer |
| Endereços baixos | `nome[16]`, ...            |

* Overflow em `nome` cresce e pode atingir `ra`

## C para RISC-V: prólogo/epílogo típico

```asm
login:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    addi s0, sp, 32

    # buffer nome em -20(s0) ... -5(s0)
    addi a0, s0, -20
    call gets

    lw   ra, 28(sp)
    lw   s0, 24(sp)
    addi sp, sp, 32
    ret
```

* `gets` escreve bytes sem limite no endereço em `a0`
* Se ultrapassar 16 bytes, pode atingir área de controle do frame

## Variação 1: Stack-based overflow

* Alvo: dados no frame atual (variáveis locais, `ra`, ponteiros)
* Efeito: crash, desvio de fluxo, comportamento indefinido
* Padrão comum:
  * API insegura (`gets`, `strcpy`, `sprintf`)
  * Tamanho de entrada não validado

## Variação 2: Heap overflow

* Overflow ocorre em bloco alocado por `malloc/new`
* Pode corromper:
  * objeto vizinho
  * metadados do alocador
  * ponteiros de função/estruturas
* Impacto: corrupção persistente no estado do programa

## Exemplo curto de heap overflow (C)

```c
char *a = malloc(16);
char *b = malloc(16);
strcpy(a, entrada); // entrada grande pode invadir b
```

* Em RISC-V, a escrita ainda é byte a byte (`sb`) sem checagem automática
* O problema é lógico, não da ISA

## Variação 3: Global/Static overflow

* Overflow em vetores globais (`.data/.bss`)
* Pode sobrescrever flags e ponteiros globais
* Exemplo didático:

```c
char nome[8];
int autenticado = 0;
strcpy(nome, entrada); // entrada longa pode alterar autenticado
```

## Variação 4: Integer overflow -> buffer overflow

* Erro no cálculo de tamanho antes da alocação/cópia
* Exemplo:

```c
size_t n = qtd * sizeof(int); // pode dar overflow aritmetico
int *v = malloc(n);
memcpy(v, origem, qtd * sizeof(int)); // copia maior que o alocado
```

* Ataque indireto: quebrar a premissa de tamanho correto
* Você pode receber dados via rede com um campo de tamanho malicioso

## Variação 5: Off-by-one

* Escreve exatamente 1 byte além do limite
* Parece pequeno, mas pode:
  * remover `\0` de terminação
  * alterar byte baixo de ponteiro/endereço
* Classe muito comum em loops com `<=` em vez de `<`

## Formas de ataque: visão por objetivo

* **Data-only attack**:
  * Altera variáveis críticas sem desviar a execução
* **Control-flow hijack**:
  * Altera retorno/ponteiro de função para redirecionar execução
* **Denial-of-service**:
  * Causa falha e indisponibilidade

## Controle de fluxo: retorno sobrescrito (conceito)

* Se o endereço de retorno (`ra` salvo) for corrompido:
  * `ret` carrega PC com valor inválido ou malicioso
* Sem mitigação, isso abre caminho para redirecionamento
* Com mitigação, geralmente vira aborto/control trap

## Exemplo C: cópia segura vs insegura

```c
// insegura
strcpy(dst, src);

// mais segura
snprintf(dst, sizeof(dst), "%s", src);
```

* A versão segura mantém limite explícito do buffer

## Exemplo RISC-V: laço de cópia inseguro

```asm
# a0 = dst, a1 = src
copy_unsafe:
1:
    lbu t0, 0(a1)
    sb  t0, 0(a0)
    beq t0, zero, 2f
    addi a0, a0, 1
    addi a1, a1, 1
    j    1b
2:
    ret
```

* Não recebe tamanho máximo de `dst`

## Exemplo RISC-V: cópia com limite

```asm
# a0 = dst, a1 = src, a2 = n (capacidade de dst)
copy_bounded:
    beq a2, zero, done
loop:
    addi a2, a2, -1
    lbu  t0, 0(a1)
    sb   t0, 0(a0)
    beq  t0, zero, done
    beq  a2, zero, force_nul
    addi a0, a0, 1
    addi a1, a1, 1
    j    loop
force_nul:
    sb   zero, 0(a0)
done:
    ret
```

* Regra de ouro: sempre propagar tamanho junto com ponteiro

## O que se faz quando tem acesso a uma escrita arbitrária?

* Você pode escrever quantos bytes quiser, inclusive rotinas inteiras e saltar para ela
* As vezes você não sabe o endereço exato mas pode fazer uma escrita muito grande cheia de NOPs, seguida da sua rotina. Ao alterar o `ra` para qualquer lugar no meio dos NOPs, você garantidamente chegará na sua rotina (técnica de NOP sled)
* Você pode ajustar os valores de registradores e de pilha e trocar o `ra` para o início de uma função, passando os dados como parâmetros. Isso é conhecido como return-to-libc, onde você reutiliza código já presente no programa (ex: `system("/bin/sh")`)
* Com técnicas mais avançadas, você pode montar uma cadeia de gadgets (pequenas sequências de instruções terminando em `ret`) para construir uma rotina arbitrária sem precisar injetar código, apenas reutilizando o que já existe. Isso é conhecido como ROP (Return-Oriented Programming).

## Técnicas históricas de exploração (alto nível)

* Injeção de código na pilha (mais antiga)
* Return-to-libc (reuso de código já existente)
* ROP (cadeias de gadgets)
* Hoje dependem de mitigações presentes/ausentes

## Mitigações no compilador

* Stack canary (`-fstack-protector-strong`)
* Fortify de biblioteca (`-D_FORTIFY_SOURCE=2`)
* Sanitizers em teste (`-fsanitize=address,undefined`)
* Avisos rigorosos (`-Wall -Wextra -Werror`)

## Mitigações no sistema

* ASLR (aleatorização de endereços)
* NX/DEP (região de dados não executável)
* CFI/PAC (dependendo da arquitetura/plataforma)
* Privilégios mínimos e sandboxing

## Mitigações no código

* Evitar APIs inseguras (`gets`, `strcpy`, `strcat`, `sprintf`)
* Validar tamanho de toda entrada externa
* Encapsular cópias em funções com limite
* Preferir linguagens/abstrações com segurança de memória quando possível

## Checklist para revisão de código

* Há vetor local com entrada externa sem limite?
* Há cálculo de tamanho com risco de overflow aritmético?
* Há ponteiro + tamanho sendo propagados juntos?
* Em assembly, o frame preserva corretamente `ra/s0`?
* Casos limite (`0`, `N`, `N+1`) foram testados?

## Exercício 1 (rápido)

Dado o código:

```c
char senha[8];
scanf("%s", senha);
```

1. Qual o risco principal?
2. Como reescrever de forma segura?
3. Que testes de fronteira você faria?

## Exercício 2 (RISC-V)

Implemente em assembly uma função:

```c
// copia no maximo n-1 bytes e garante '\0'
void strlcpy_like(char *dst, const char *src, int n);
```

1. Quais registradores usar para argumentos?
2. Onde colocar condição de parada?
3. Como garantir terminação nula?

## Resumo

* Buffer overflow = escrita fora dos limites de memória
* Variações: stack, heap, global, integer->buffer, off-by-one
* Em RISC-V, ISA não impede erro lógico de limites
* Defesa eficaz = combinação de práticas de código + compilador + SO

## Referências

* Aleph One, *Smashing The Stack For Fun And Profit* (histórico)
* CERT C Secure Coding Standard
* OWASP: Buffer Overflow
* Documentação GCC/Clang para hardening e sanitizers
* [Playlist sobre segurança Hardware e Software](https://youtube.com/playlist?list=PLPokM2qEmTDClgPTX_GOLeMZkuf7o38yS&si=6CpjAlqxjWnYyKbT) (link clicável no PDF da aula)
