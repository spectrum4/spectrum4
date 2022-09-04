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
  mov     w0, 0x04000000
                                                  // [F6EE] = Cursor position = row 0
                                                  // [F6EF] = Cursor position = column 0
                                                  // [F6F0] = Preferred cursor position = column 0
                                                  // [F6F1] = Top row before scrolling up = 4
  str     w0, [x28, F6EE-sysvars]
  mov     w1, 0x00001410
                                                  // [F6F2] = Bottom row before scrolling down = 0x10
                                                  // [F6F3] = Number of rows in the editing area = 0x14
  strh    w1, [x28, F6F2-sysvars]
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
