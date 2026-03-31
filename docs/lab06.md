# Laboratório 6

No laboratório anterior, você aprendeu a usar o novo simulador para construir e testar programas em assembly.
Agora, o foco muda para organizar melhor o código com funções, entender como os parâmetros e retornos circulam entre chamadas e controlar a pilha com segurança.

Ao final deste roteiro, você terá implementado funções comuns (incluindo função folha), funções com variáveis locais, chamadas indiretas por ponteiro e uma versão recursiva de fatorial.


!!! tip "Dicas"
    * Você não precisa entregar nenhum código como resposta. Procure entender os conceitos e explorar as variações.
    * Você pode utilizar o [simulador RISC-V](https://ascslab.org/research/briscv/simulator/simulator.html) para testar os códigos que você desenvolver. Para isso, veja as dicas fornecidas logo abaixo.
    * Não deixe de colocar comentários nos seus códigos. Procure organizar o código de forma que ele fique mais fácil de entender.
    * As dicas desse laboratório estão colapsadas. Para expandi-las, clique na pequena seta do lado direito da caixa de texto.

## Funções

Funções são trechos de código que podem ser chamados por outros trechos de código. Elas podem receber parâmetros e retornar valores. As funções são fundamentais para organizar o código e evitar a repetição de código. Elas também permitem a reutilização de código e a modularização do programa.

Vamos começar esse laboratório com as funções mais simples, que não utilizam pilha. Isso significa que teremos algumas restrições nas funcionalidades delas, em especial, você não poderá chamar outras funções de dentro delas nesse primeiro momento. Essas funções são chamadas de **funções folha**. Depois, vamos aprender a utilizar a pilha para implementar funções mais complexas, que podem chamar outras funções e ter variáveis locais.

Como visto em sala de aula, você precisa seguir a convenção de registradores para passar os parâmetros e retornar os valores das funções. Os registradores `a0` a `a7` são utilizados para passar os parâmetros e retornar os valores das funções. Os registradores `s0` a `s11` são utilizados para guardar valores que precisam ser preservados entre chamadas de função. Os registradores `t0` a `t6` são utilizados para guardar valores temporários que não precisam ser preservados entre chamadas de função. O registrador `ra` é utilizado para guardar o endereço de retorno da função. Dessa forma, como não utilizaremos a pilha nesse primeiro momento, as funções folha devem se restringir a utilizar apenas os registradores `a` e `t`, pois eles não precisam ser preservados entre chamadas de função.

??? tip "Dica"
    A instrução `call` é utilizada para chamar uma função. Ela salva o endereço de retorno no registrador `ra` e pula para o endereço da função. A instrução `ret` é utilizada para retornar de uma função. Ela pula para o endereço salvo no registrador `ra`.

!!! note "Atividade 1"
    Implemente uma função `int SomaVetor(unsigned N, unsigned *v)` que receba o número N de elementos do vetor e o vetor como parâmetros e retorne a soma de todos os elementos do vetor. Essa função deve ser uma função folha, ou seja, não pode chamar nenhuma outra função e deve utilizar apenas os registradores `a` e `t`. Para testar seu código, declare um vetor de 5 posições e chame a função para somar os elementos do vetor. Utilize a instrução `ecall` número 1 para imprimir o resultado da soma.

!!! warning "Atenção com a ordem das funções"
    Seu simulador inicia a execução pela primeira instrução que ele encontra após `.text`. Dessa forma, você precisa colocar a função `main` antes das outras funções, para garantir que a execução do programa comece por ela.

!!! note "Atividade 2"
    Implemente uma função `void MultiplicaVetor(unsigned N, unsigned *v, unsigned fator)` que receba o número N de elementos do vetor, o vetor e um fator como parâmetros e multiplique todos os elementos do vetor pelo fator. Essa função deve ser uma função folha. Você pode utilizar a instrução `mul` para multiplicar dois números. Para testar seu código, declare um vetor de 5 posições, chame a função para multiplicar os elementos do vetor por 10 e imprima o resultado utilizando a instrução `ecall` número 1.

!!! note "Atividade 3"
    Implemente a função `void ImprimeVetor(unsigned N, unsigned *v)` que receba o número N de elementos do vetor e o vetor como parâmetros e imprima todos os elementos do vetor. Essa função deve ser uma função folha. Para imprimir um número, utilize a instrução `ecall` número 1. Separe os números com um espaço. Para imprimir caracter, utilize a instrução `ecall` número 11.

!!! note "Atividade 4"
    Implemente a função `void SomaVetores(unsigned N, unsigned *v1, unsigned *v2, unsigned *resultado)` que receba o número N de elementos dos vetores, os dois vetores e um vetor resultado como parâmetros e some os elementos dos dois vetores e armazene o resultado no vetor resultado. Essa função deve ser uma função folha. Para testar seu código, declare 3 vetores de 5 posições, chame a função para somar os elementos dos vetores e imprima o resultado utilizando a função `ImprimeVetor` da Atividade anterior. Para sua função `SomaVetores` continuar sendo folha, você deve chamar a `ImprimeVetor` de dentro do `main` e não de dentro da `SomaVetores`.

## Pilha

A pilha é uma estrutura de dados onde o próximo elemento é inserido no topo e sempre se retira elementos do topo da pilha. O seu processador não tem uma implementação de pilha, mas você deve garantir o comportamento de uma pilha para a correta execução do programa. Assim, dados que você quiser guardar temporariamente, podem ser colocados na pilha. Variáveis locais do seu programa também podem ser alocadas na pilha.

No modelo de memória do computador, a pilha sempre cresce em direção a endereços menores. Então, o registrador que aponta para o topo da pilha, o `sp`, começa com um valor alto e vai diminuindo conforme mais elementos são agregados à pilha. É sua responsabilidade fazer os ajustes necessários tanto no `sp` quando nas leituras e escritas na pilha. O `sp` aponta sempre para o último elemento que foi colocado na pilha. Veja uma implementaçãoda função `void MultiplicaVetor(unsigned N, unsigned *v, unsigned fator)`, que utiliza a função `Multiplica` para multiplicar dois números, no lugar da instrução `mul` que você utilizou anteriormente.

```mipsasm
MultiplicaVetor:
    # Movimenta o apontador da pilha 4 posicoes para baixo (16 bytes) e guarda 4 registradores na pilha
    addi sp, sp, -16
    sw   s0, 12 (sp)
    sw   s1, 8 (sp)
    sw   s2, 4 (sp)
    sw   ra, 0 (sp)

    mv   s0, a0
    mv   s1, a1
    mv   s2, a2

for:
    beq  s0, zero, fim
    lw   a0, 0 (s1)
    mv   a1, s2
    call Multiplica
    sw   a0, 0 (s1)
    addi s1, s1, 4
    addi s0, s0, -1
    j    for

fim:
    # Movimenta o apontador da pilha 4 posicoes para cima (16 bytes) e recupera 4 registradores da pilha
    lw   ra, 0 (sp)
    lw   s2, 4 (sp)
    lw   s1, 8 (sp)
    lw   s0, 12 (sp)
    addi sp, sp, 16
    ret
```

!!! info "Atenção com a ordem dos registradores na pilha"
    Cada registrador é salvo num endereço na pilha e esse mesmo endereço deve ser utilizado para restaura-lo, de forma a garantir a sequência correta do programa. Para facilitar a organização, é comum fazer o código dos `lw` na ordem inversa dos `sw`, ou seja, o primeiro registrador salvo é o último restaurado. Assim, o código fica mais fácil de entender e menos propenso a erros. Note que `sp` está sendo ajustado apenas no início e no final da função, garantindo que o espaço reservado para os registradores seja mantido durante toda a execução da função.

Como a função `Multiplica` está sendo chamada, é necessário preservar todos os registradores `a` além dos obrigatórios `s` que serão utilizados. 

??? tip "Dica"
    Você sempre deve pensar no pior caso, apesar da função `Multiplica` utilizar apenas os registradors `a0` e `a1`, você não tem certeza se ela não chama outra função que utilize o `a3` que você precisa. Portanto, todos os parâmetros precisam ser preservados para utilização no laço.


!!! note "Atividade 5"
    Agora que você já sabe implementar funções que utilizam a pilha, implemente novamente a função `void SomaVetores(unsigned N, unsigned *v1, unsigned *v2, unsigned *resultado)` mas inclua chamadas à função `void ImprimeVetor(unsigned N, unsigned *v)` para imprimir tanto os vetores de entrada (parâmetros) quanto o resultado, sendo todas as chamadas dentro da própria função.


## Desafio final

Agora que você já sabe como implementar funções, você pode implementar uma função recursiva para calcular o fatorial de um número. Para isso, você deve implementar uma função que receba um número e retorne o fatorial dele. Essa função deve chamar a si mesma para calcular o fatorial do número anterior.

!!! note "Atividade 6"
    Implemente uma função recursiva que calcule o fatorial de um número. Como você ainda não sabe como ler do teclado nesse simulador, declare uma variável global para armazenar o número de entrada. Altere a variável entre os testes para testar múltiplos números. Seu programa deve imprimir o número e o fatorial dele após chamar a função.

??? tip "Dica"
    Digite números pequenos pois a conta pode demorar um pouco.

!!! info "Funções recursivas não são tão diferentes assim!"
    Você notou que, se fizer todas as precauções necessárias para preservar os registradores e organizar a pilha, a implementação de uma função recursiva é muito similar à implementação de uma função não recursiva. A única diferença é que a função recursiva chama a si mesma, o que pode ser feito da mesma forma que chamamos outras funções. O importante é garantir que os valores necessários para a execução da função sejam preservados corretamente na pilha, para que a execução da função recursiva seja correta.

!!! warning "Erros comuns neste laboratório"
    * Esquecer de salvar e restaurar o registrador ra em funções que chamam outras funções.
    * Alterar o sp na entrada da função e não desfazer exatamente o mesmo ajuste na saída.
    * Usar offsets incorretos ao acessar valores salvos na pilha.
    * Misturar o papel dos registradores: a para parâmetros/retorno, `s` para valores preservados, `t` para temporários.
    * Assumir que valores em registradores a continuam intactos após uma chamada de função.
    * Em chamadas com jalr, carregar endereço errado da função ou usar base incorreta.
    * Em recursão, esquecer o caso base ou não preservar o valor necessário entre chamadas.
    * Em string local na pilha, esquecer espaço para o terminador nulo.

## Conclusões

Agora você já conseguiu reconstruir o conceito de funções como trechos de código com parâmetros e variáveis locais. Você também aprendeu a utilizar a pilha para armazenar os parâmetros e variáveis locais das funções. Por fim, você notou que funções recursivas são fáceis de implementar uma vez que você entenda como a pilha funciona.

!!! success "Resumo"
    Você aprendeu funções folhas e não folhas e também funções recursivas!
