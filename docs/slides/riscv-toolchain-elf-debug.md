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

# Toolchain RISC-V, ELF e Debug de Baixo Nível

Rodolfo Azevedo

MC404 - Organização Básica de Computadores e Linguagem de Montagem

http://www.ic.unicamp.br/~rodolfo/mc404

## Objetivos da aula

* Entender pipeline de build para RISC-V
* Ler estrutura de um executável ELF
* Conectar C, assembly, objeto e binário final
* Usar ferramentas de inspeção de baixo nível
* Melhorar depuração e análise de desempenho/corretude

## Fluxo geral

1. Código fonte C/assembly
2. Compilação para assembly
3. Montagem para objeto
4. Ligação para executável ELF
5. Carregamento e execução

## Etapa 1: compilar para assembly

```bash
riscv64-unknown-elf-gcc -S programa.c -o programa.s
```

* Ajuda a estudar como o compilador mapeia C para RISC-V

## Etapa 2: gerar objeto

```bash
riscv64-unknown-elf-gcc -c programa.s -o programa.o
```

* Arquivo objeto ainda não é executável final
* Contém seções, símbolos e relocações

## Etapa 3: linkar

```bash
riscv64-unknown-elf-gcc programa.o -o programa.elf
```

* Resolve referências entre objetos
* Define layout final de seções no executável

## O que é ELF?

* Executable and Linkable Format
* Formato padrão em muitos sistemas Unix-like
* Usado para executáveis, objetos e bibliotecas
* Estruturas principais:
  * cabeçalho
  * seções
  * tabela de símbolos
  * informações de relocação

## Seções comuns do ELF

| Seção                 | Conteúdo                |
| --------------------- | ----------------------- |
| .text                 | Código executável       |
| .rodata               | Dados somente leitura   |
| .data                 | Dados inicializados     |
| .bss                  | Dados não inicializados |
| .symtab               | Símbolos                |
| .rela.text ou similar | Relocações              |

## Ferramenta: readelf

```bash
readelf -h programa.elf
readelf -S programa.elf
readelf -s programa.elf
```

* h: cabeçalho
* S: seções
* s: símbolos

## Ferramenta: objdump

```bash
riscv64-unknown-elf-objdump -d programa.elf
riscv64-unknown-elf-objdump -d -M no-aliases programa.elf
```

* d: disassembly
* no-aliases: mostra instruções mais próximas da codificação real

## Relacionando C e assembly

* Compile com informação de debug
* Disassemble e compare com código-fonte
* Observe:
  * prólogo/epílogo
  * uso de registradores a, t, s
  * chamadas de função e convenções

## Símbolos e ligação

* Símbolos globais podem ser resolvidos no link
* Símbolos locais afetam escopo interno
* Falha de símbolo indefinido ocorre em etapa de link

## Relocação: por que existe?

* Durante compilação, endereço final ainda não é conhecido
* Montador deixa referência para ajuste posterior
* Linker aplica correções ao gerar o executável final

## Exemplo de erro comum de link

* Declarou função **extern**, mas não linkou arquivo correspondente
* Resultado: **undefined reference**

Diagnóstico:
1. Verificar lista de objetos no comando de link
2. Inspecionar símbolos com readelf ou nm

## ABI e calling convention no binário real

* Argumentos em a0 a a7
* Retorno em a0 e a1
* Registradores s preservados pela função chamada
* Conferir isso no disassembly é excelente exercício prático

## Debug com gdb (visão geral)

```bash
riscv64-unknown-elf-gdb programa.elf
```

Comandos úteis:
* break main
* run
* stepi
* info registers
* x/16wx endereço

## Diagnóstico de bug de pilha

Sinais comuns:
* retorno para endereço inválido
* registrador ra corrompido
* desalinhamento de sp

Abordagem:
1. inspecionar prólogo/epílogo
2. validar offsets de load/store
3. rastrear onde ra foi salvo/restaurado

## Flags de compilação úteis para estudo

```bash
-O0 -g
-O2
-fno-omit-frame-pointer
-Wall -Wextra
```

* O0 facilita leitura didática
* O2 mostra otimizações reais do compilador

## Exercício 1

Pegue um programa C simples e:
1. gere .s
2. gere .o
3. gere .elf
4. use objdump para identificar prólogo e epílogo da main

## Exercício 2

Em um binário com duas funções:
1. localize simbolo de cada funcao
2. encontre instrução de chamada
3. explique como endereço foi resolvido no link

## Boas práticas para laboratório

* Versionar arquivos fonte e scripts de build
* Separar código, objetos e artefatos
* Documentar comandos de compilação
* Manter uma configuração de debug reproduzível

## Resumo

* Toolchain transforma fonte em executável ELF
* ELF organiza código, dados e metadados de ligação
* readelf e objdump tornam o binário transparente
* Entender ABI no disassembly melhora muito o domínio de assembly
* Debug de baixo nível reduz tempo de diagnóstico

## Referências

* GCC e Binutils para RISC-V
* Especificação ELF
* RISC-V ABI e Calling Convention
* Guias de GDB para arquitetura RISC-V
