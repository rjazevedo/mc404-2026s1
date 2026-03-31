main:

  addi t0, zero, 1        # t0 = 0 + 1
  addi t1, zero, 2        # t1 = 0 + 2
  add  t2, t1, t0         # t2 = t1 + t0 
  addi a0, zero, 1
  add  a1, t2, zero
  ecall  
  ret
