.text
.align 2

# ------------------------
# Display Menu
# ------------------------
#
# On entry:
# On exit:
display_menu:                            // L36A8
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
