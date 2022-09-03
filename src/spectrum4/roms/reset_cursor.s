.text
.align 2

# ---------------------
# Reset Cursor Position
# ---------------------
#
# On entry:
# On exit:
reset_cursor:                            // L28BE
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      reset_main_screen
  bl      init_cursor
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret