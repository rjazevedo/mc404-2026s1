# Laboratório 7

Vamos falar mais sobre funções e pilha!

!!! tip "Dicas"
    * Você não precisa entregar nenhum código como resposta. Procure entender os conceitos e explorar as variações.
    * Você vai utilizar um novo simulador, chamado Venus, que pode ser executado online ou como plugin dentro do Visual Studio Code. Vamos utilizar preferencialmente a versão do VSCode pois tem mais componentes para praticarmos.
    * Não deixe de colocar comentários nos seus códigos. Procure organizar o código de forma que ele fique mais fácil de entender.
    * As dicas desse laboratório estão colapsadas. Para expandi-las, clique na pequena seta do lado direito da caixa de texto.

## Vamos revisar a pilha

A pilha é uma estrutura de dados onde o próximo elemento é inserido no topo e sempre se retira elementos do topo da pilha. O seu processador não tem uma implementação de pilha, mas você deve garantir o comportamento de uma pilha para a correta execução do programa. Assim, dados que você quiser guardar temporariamente, podem ser colocados na pilha. Variáveis locais do seu programa também podem ser alocadas na pilha.

No modelo de memória do computador, a pilha sempre cresce em direção a endereços menores. Então, o registrador que aponta para o topo da pilha, o `sp`, começa com um valor alto e vai diminuindo conforme mais elementos são agregados à pilha. É sua responsabilidade fazer os ajustes necessários tanto no `sp` quando nas leituras e escritas na pilha. O `sp` aponta sempre para o último elemento que foi colocado na pilha. 

!!! note "Atividade 1"
    Implemente um programa que declare 3 vetores globais de 5 posições. Crie uma função chamada `void MenorVetor(unsigned N, unsigned *a, unsigned *b, unsigned *c)` que recebe o número N de elementos dos vetores e os três vetores como parâmetros. A função deve comparar os elementos dos vetores `a` e `b` e colocar o menor elemento de cada posição no vetor `c`.

## Variáveis locais também são armazenadas na pilha

Quando você precisa de variávies locais no seu programa, ou você coloca em registradores (se couber) ou você deve alocar na pilha. Para isso, você precisa atualizar o `sp` corretamente para reservar espaço suficiente para sua variável. Isso significa:

1. Reservar o espaço para os registradores que quiser salvar
1. Salvar os registradores nos seus lugares
1. Reservar outro espaço para as variáveis locais

O procedimento reverso deve ser utilizado no encerramento da função. Você também precisará utilizar o `sp` para calcular o endereço das suas variáveis locais corretamente.

??? tip "Dica"
    É por estarem na pilha que as variáveis locais das funções das linguagens de alto nível não pode ser retornadas por elas. Ao final da função você restaura o `sp` ao valor inicial e aquela posição de memória fica disponível para outros acessos.

!!! note "Atividade 2"
    Altere sua função `MenorVetor` para:

    1. Declarar uma variável local para guardar o menor vetor
    2. Chamar a função `SomaVetor` do laboratório passado para somar todos os elementos do menor vetor
    3. Imprima o resultado final utilizando a instrução `ecall`.

??? tip "Dica"
    Lembre-se que, para uma função chamar a outra, ela deixa de ser uma função folha e precisa utilizar os registradores `s` e `ra`para os valores que quiser preservar.

## Funções são chamadas por meio de instruções

Como visto em sala de aula, a pseudo-instrução `call` é uma implementação da instrução `jal` (especificamente, `jal ra, funcao`). Mas você também pode utilizar a instrução `jalr` que utiliza também um registrador como parâmetro. Assim, você pode passar o endereço de uma função por um registrador. Por exemplo, se você tem o endereço de uma função no registrador `s0`, você pode utilizar `jalr ra, s0, 0` para chamar a função. 

??? tip "Dica"
    Você já sabe utilizar a pseudo-instrução `la` para carregar o endereço de uma variável em um registrador, mas você também pode utilizá-la para carregar o endereço de uma função.

Você pode, então, implementar funções distintas, guardar o endereço delas em um registrador e, com isso, gerar um código que chame de acordo com a condição que for realizar. Que tal fazer uma calculadora com 2 operações: Soma e Subtração. Você pode implementar duas funções, cada uma capaz de receber 2 registradores e retornando o resultado da operação. Como próximo passo, você pode criar um vetor de 2 posições com a estrutura abaixo:

```c
typedef struct {
    char caracter;
    int (*op)(int, int);
} Operacao;
```

Você pode preencher essa estrutura com o caracter + e o endereço da função de soma e o caracter - e o endereço da função de subtração. Agora, você pode interpretar um caracter e chamar a função correspondente. Considere que a `struct` tenha 8 bytes e deixe 4 reservados para o caracter e 4 para a operação.

!!! note "Atividade 3"
    Implemente uma calculadora com 2 operações: Soma e Subtração. Declare 2 números em memória e um caracter, que deve ser a operação. Seu programa deve passar essas informações como parâmetros para uma função que deve utilizar a estrutura `Operacao` para armazenar as funções, conforme acima.

!!! note "Atividade 4"
    Agora que você tem mais facilidade para digitar strings, coloque mensagens no seu código para indicar a operação que está realizando! A `ecall` de print_string é a 4.

??? tip "Dica"
    Você sabia que ponteiros para funções são utilizados em linguagens orientada a objetos para permitir que você sobrescreva o comportamento de uma função em uma classe filha? O conceito é o mesmo, mas a implementação é mais complexa. Você pode pesquisar sobre tabelas virtuais (vtable) para entender melhor como isso funciona.

## Utilizando a matriz de pontos do simulador

Seu simulador tem uma matriz de pontos, por padrão 10 x 10 pontos que pode ser visualizada utilizando a opção **Views > Led Matrix** do canto esquerdo da tela quando ele estiver ativo.

Para escrever um ponto na tela, você deve utilizar a **ecall 0x100**, que recebe como parâmetros o **x** (16 bits mais significativos) e o **y** (16 bits menos significativos) do ponto e a cor em RGB. Por exemplo, para escrever um ponto vermelho na posição (2,4), você deve utilizar a seguinte instrução:

```mipsasm
li a0, 0x100       # syscall de escrever ponto
li a1, 0x00020004  # x = 2 (0x0002) e y = 4 (0x0004)
li a2, 0x00FF0000  # cor vermelha em RGB (=0x00RRGGBB)
ecall
```

O simulador também fornece a **ecall 0x101** para trocar a cor de todos os pontos da tela (o que equivale a limpar a tela se escolher branco ou preto). A chamada dessa syscall só precisa da cor em RGB. Por exemplo, para pintar a tela de branco, você deve utilizar o seguinte código:

```mipsasm
li a0, 0x101       # syscall de trocar cor de todos os pontos
li a1, 0x00FFFFFF  # cor branca em RGB (=0x00RRGGBB)
ecall
```

!!! note "Atividade 5"
    Experimente desenhar com múltiplas cores no painel. Faça um programa que pinte a tela de branco e depois desenhe um quadrado deixando uma borda de dois pontos brancos em todos os lados. Faça esse quadrado trocar de cor múltiplas vezes (você pode adicionar valores nas cores ou armazenar um conjunto de cores num vetor e troca-las). Veja quanto tempo seu simulador gasta para pintar um quadrado e procure ajustar a velocidade do seu programa para que as trocas sejam visíveis.

## Desafio final

O desafio de hoje é simples e nada polêmico. Faça um programa que desenhe a bandeira do seu time preferido de futebol!

!!! note "Atividade 6"
    Faça um programa que pinte a bandeira do seu time preferido de futebol no display. Ou outro símbolo do seu agrado!

## Conclusões

Você revisou funções, aprendeu a utilizar ponteiros para funções e também desenhou a bandeira do seu time de futebol! Parabéns!

!!! success "Resumo"
    Você desenhou a bandeira do seu time de futebol!