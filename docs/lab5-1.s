.data
  s: .string "Hello, World!\n"
  s1: 
    .space 20
.text
main:
    addi a0, zero, 1  # Seletor da ecall (1) para imprimir um número 
    addi a1, zero, 10  # Parâmetro da ecall (a1) com o número a ser impresso
    ecall
    addi a0, zero, 10
    ecall   # Encerra a execução do programa