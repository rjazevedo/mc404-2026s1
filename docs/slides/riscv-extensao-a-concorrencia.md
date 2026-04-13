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

# RISC-V Extensão A e Concorrência

Rodolfo Azevedo

MC404 - Organização Básica de Computadores e Linguagem de Montagem

http://www.ic.unicamp.br/~rodolfo/mc404

## Objetivos da aula

* Entender problemas clássicos de concorrência
* Ver por que instruções comuns não bastam para sincronização
* Introduzir extensão A do RISC-V
* Entender LR/SC e AMO em alto nível
* Discutir fence e ordenação de memória

## Motivação

* Em multicore, múltiplos núcleos acessam memória compartilhada
* Operações aparentemente simples podem sofrer corrida de dados (*data race*)
* Sem sincronização, resultados podem ser incorretos e não determinísticos

## Exemplo de corrida de dados

```c
// duas threads executam isso ao mesmo tempo
contador = contador + 1;
```

* Essa operação não é atômica
* Pode ocorrer perda de incremento

## O que significa atômico?

* Uma operação atômica ocorre como se fosse indivisível
* Nenhum outro componente observa estado intermediário
* Base para locks, semáforos e algoritmos lock-free

## RISC-V extensão A

* A = Atomic extension
* Adiciona instruções para sincronização e memória compartilhada
* Duas famílias principais:
  * LR/SC (load-reserved / store-conditional)
  * AMO (atomic memory operations)

## LR/SC: ideia intuitiva

1. LR lê valor e marca reserva sobre endereço
2. Código prepara novo valor
3. SC tenta gravar
4. Se ninguém interferiu no endereço, grava com sucesso
5. Se houve interferência, falha e precisa tentar novamente

## Pseudocódigo LR/SC

```text
do {
  velho = LR(endereco)
  novo = f(velho)
  ok = SC(endereco, novo)
} while (ok == falha)
```

## Exemplo didático: incremento atômico

```asm
# a0 = endereço do contador
retry:
    lr.w  t0, (a0)
    addi  t1, t0, 1
    sc.w  t2, t1, (a0)   # t2=0 sucesso, !=0 falha
    bne   t2, zero, retry
    ret
```

## AMO: operações atômicas prontas

* amoadd: soma atômica
* amoswap: troca atômica
* amoand, amoor, amoxor, amomin, amomax
* Em geral simplificam padrões comuns

## Exemplo conceitual com AMO

```asm
# soma 1 atômico em memória
li    t0, 1
amoadd.w t1, t0, (a0)   # t1 recebe valor antigo
```

## Construindo spinlock (alto nível)

* Lock simples:
  * Tenta adquirir lock em loop
  * Se ocupado, espera
* Pode ser feito com amoswap ou LR/SC
* Fácil de entender, mas pode desperdiçar CPU

## Cuidado com espera ocupada

* Spinlock em seção longa é ruim
* Em sistemas reais, estratégia híbrida pode ser melhor
* Conceitos de fairness e starvation aparecem aqui

## Ordenação de memória

* Processadores e compiladores podem reordenar operações
* Sem cuidados, outro núcleo pode observar ordem inesperada
* Sincronização precisa garantir ordem quando necessário

## fence no RISC-V

* fence impõe restrições de ordenação
* Usado para garantir visibilidade correta entre núcleos/dispositivos
* Muito importante em drivers e estruturas concorrentes

## Concorrência e caches

* Cada núcleo pode ter cache privada
* Coerência de cache garante visão consistente eventual
* Atômicas + protocolo de coerência trabalham juntos

## Padrões clássicos com atômicas

* Contador global de eventos
* Flag de inicialização única
* Fila lock-free simplificada
* Referência compartilhada com controle de estado

## Relação com linguagem C

* Operações atomics em C podem compilar para LR/SC ou AMO
* Compilador escolhe sequência conforme alvo e modelo de memória
* Assembly gerado é ótima ferramenta de estudo

## Erros comuns de aluno

* Achar que leitura+escrita comum já é atômica
* Esquecer de tratar falha no SC
* Ignorar ordenação de memória
* Fazer lock sem pensar em progresso

## Exercício 1

Dois núcleos atualizam o mesmo contador:
1. versão sem atômica
2. versão com LR/SC
3. versão com AMO

Compare corretude e custo.

## Exercício 2

Descreva um cenário onde fence é necessário:
* qual dado é produzido
* qual flag sinaliza disponibilidade
* que erro pode surgir sem barreira

## Resumo

* Concorrência exige sincronização explícita
* Extensão A fornece primitivas atômicas
* LR/SC e AMO resolvem atualizações críticas
* fence ajuda a garantir ordem visível correta
* Correção e desempenho andam juntos

## Referências

* RISC-V Unprivileged Spec (extensão A)
* Material de sistemas concorrentes
* Documentação de compiladores sobre atomics e memory model
