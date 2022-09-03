.text
.align 2

# ---------------------
# ---------------------
#
# On entry:
# On exit:
reset_main_screen:                       // L2E1F
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret