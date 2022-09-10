.text
.align 2

# ------------------------
# Display Menu
# ------------------------
#
# On entry:
#   x1 = jump table
#   x2 = menu text
# On exit:
display_menu:                            // L36A8
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      store_menu_screen_area
  ldrb    w0, [x28, TV_FLAG-sysvars]
  and     w0, w0, #0xfe
  strb    w0, [x28, TV_FLAG-sysvars]              // Clear bit 0 of TV_FLAG: main screen in use
  ldrb    w0, [x1], #8                            // w0 = number of entries
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
