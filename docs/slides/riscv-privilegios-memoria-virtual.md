---
marp: true
paginate: true
_paginate: false
footer: 'MC404 - Organizacao Basica de Computadores e Linguagem de Montagem - Rodolfo Azevedo - CC BY-SA 4.0'
headingDivider: 2
---

<style>
@import "./h3-duas-colunas.css";
</style>

# RISC-V Privilegiado e Memoria Virtual

Rodolfo Azevedo

MC404 - Organizacao Basica de Computadores e Linguagem de Montagem

http://www.ic.unicamp.br/~rodolfo/mc404

## Objetivos da aula

* Entender os niveis de privilegio no RISC-V
* Conectar excecoes/interrupcoes com o fluxo de trap
* Entender memoria virtual e paginacao
* Relacionar TLB, tabela de paginas e page fault
* Discutir impacto em desempenho e seguranca

## Revisao rapida: o que ja vimos

* Excecoes e interrupcoes
* Registradores de estado (CSR)
* Rotina de tratamento de interrupcao
* Chamadas de servico via ecall

## Por que niveis de privilegio?

* Isolar aplicacoes do nucleo do sistema operacional
* Impedir acesso direto a recursos criticos
* Permitir virtualizacao e supervisao
* Reduzir impacto de falhas e ataques

## Modos de execucao no RISC-V

* M-mode (Machine): mais privilegiado, firmware e controle global
* S-mode (Supervisor): sistema operacional
* U-mode (User): aplicacoes
* H-mode: extensao para virtualizacao (quando presente)

## Modo U, S e M na pratica

| Modo | Quem roda | Pode executar tudo? |
| --- | --- | --- |
| U | Programa do usuario | Nao |
| S | Kernel do SO | Quase tudo do SO |
| M | Firmware/monitor | Sim, controle total da maquina |

## Fluxo de trap (visao geral)

1. Programa em U-mode executa uma acao
2. Ocorre excecao, interrupcao ou ecall
3. Hardware salva contexto minimo em CSRs
4. PC vai para endereco de trap handler
5. Tratador resolve e retorna com instrucao de retorno apropriada

## CSRs importantes para trap

* mtvec: endereco do tratador em M-mode
* mepc: PC interrompido
* mcause: causa do trap
* mtval: valor adicional (depende da causa)
* mstatus: estado global de execucao

## Exemplo conceitual de leitura de CSRs

```asm
# exemplo didatico
csrr t0, mepc
csrr t1, mcause
csrr t2, mtval
```

* Esses valores ajudam a decidir como tratar o evento

## Delegacao de traps

* Nem todo trap precisa ir para M-mode
* medeleg e mideleg permitem delegar para S-mode
* Ideia: deixar o kernel tratar o que e responsabilidade dele
* Reduz overhead e simplifica arquitetura do sistema

## ecall e fronteira de privilegio

* ecall em U-mode pede servico ao SO
* Nao ha acesso direto do usuario a periferico protegido
* O SO valida parametros e executa operacao em S-mode/M-mode
* Retorno volta ao contexto de usuario

## Memoria virtual: motivacao

* Isolamento entre processos
* Espaco de enderecamento privado por processo
* Compartilhamento controlado de paginas
* Uso eficiente da RAM e paginacao sob demanda

## Endereco virtual vs fisico

* CPU gera endereco virtual
* MMU traduz para endereco fisico
* Traducao usa tabela de paginas
* Falha de traducao gera page fault

## Paginacao em alto nivel

* Memoria virtual dividida em paginas
* Memoria fisica dividida em quadros
* Tabela mapeia pagina virtual para quadro fisico
* Permissoes por pagina: leitura, escrita, execucao

## satp e selecao da tabela de paginas

* satp aponta para a raiz da tabela de paginas
* Troca de processo implica troca de satp
* Apos trocar mapeamento, normalmente ocorre limpeza de TLB

## TLB

* Cache de traducoes virtual -> fisico
* Evita caminhada na tabela de paginas a cada acesso
* Hit no TLB: acesso rapido
* Miss no TLB: mais lento, pode exigir page walk

## Page fault

* Causas comuns:
  * Pagina nao mapeada
  * Permissao insuficiente (por exemplo, escrita em pagina somente leitura)
  * Execucao em pagina nao executavel
* Tratador decide:
  * Carregar pagina
  * Ajustar mapeamento
  * Encerrar processo

## Seguranca e memoria virtual

* Isolamento de processos
* Base para ASLR
* Apoio a politica NX (pagina de dados sem execucao)
* Reduz impacto de bugs de memoria

## Custo de memoria virtual

* TLB miss aumenta latencia
* Troca de contexto envolve metadados de traducao
* Page fault e caro
* Projeto de SO e microarquitetura influencia muito desempenho

## Estudo de caso didatico

Situacao:
* Processo tenta escrever em endereco sem permissao de escrita
Perguntas:
1. Que trap ocorre?
2. Qual CSR ajuda a localizar o endereco?
3. Quem decide matar processo ou ajustar mapeamento?

## Exercicio 1

Explique o caminho completo de uma ecall:
* ponto de vista do programa usuario
* ponto de vista do kernel
* quais CSRs mudam

## Exercicio 2

Compare:
* acesso com TLB hit
* acesso com TLB miss
* acesso com page fault

Qual cenario e mais caro e por que?

## Resumo

* Modos de privilegio separam responsabilidades
* Traps conectam eventos ao tratador correto
* Memoria virtual fornece isolamento e flexibilidade
* TLB acelera traducao
* Page fault e mecanismo funcional e de protecao

## Referencias

* RISC-V Privileged Architecture Specification
* Material de sistemas operacionais sobre memoria virtual
* Documentacao de simuladores RISC-V com suporte a CSRs e traps
