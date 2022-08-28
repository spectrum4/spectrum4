.text
.align 2
# On entry:
# On exit:
init_mode:                               // L2584
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      reset_cursor
  strh    wzr, [x28, FC9A-sysvars]
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
