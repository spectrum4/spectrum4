.text
.align 2
pout:                                    // L009F
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  // TODO
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
