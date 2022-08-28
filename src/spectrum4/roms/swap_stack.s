.text
.align 2
# Swaps sp and [OLDSP]. Stores x0 in [TARGET].
# On entry:
#   x0 = new address to store in [TARGET]
# On exit:
#   x1 = entry [OLDSP]
#   x2 = entry sp
#   sp = entry [OLDSP]
#   [OLDSP] = entry sp
#   [TARGET] = entry x0
swap_stack:                              // L1F45
  str     x0, [x28, TARGET-sysvars]
  ldr     x1, [x28, OLDSP-sysvars]
  mov     x2, sp
  str     x2, [x28, OLDSP-sysvars]
  mov     sp, x1
  ret
