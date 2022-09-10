.text
.align 2

# ------------------------
# Display Menu
# ------------------------
#
# On entry:
#   x1 = jump table
#   x7 = menu text
# On exit:
display_menu:                            // L36A8
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      store_menu_screen_area
  ldrb    w0, [x28, TV_FLAG-sysvars]
  and     w0, w0, #0xfe
  strb    w0, [x28, TV_FLAG-sysvars]              // Clear bit 0 of TV_FLAG: main screen in use
  ldrb    w0, [x1], #8                            // w0 = number of entries
  adr     x4, menu_title_colours
  bl      print_str_ff                            // Print title colours and position
  mov     x2, x7
  bl      print_message
1:
  b       1b
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


menu_title_colours:                      // L37EC
  .byte 0x16, 0x07, 0x07                          // AT 7,7;
# .byte 0x15, 0x00                                // OVER 0;
# .byte 0x14, 0x00                                // INVERSE 0;
# .byte 0x10, 0x07                                // INK 7;
# .byte 0x11, 0x00                                // PAPER 0;
  .byte 0x13, 0x01                                // BRIGHT 1;
  .byte 0xff                                      // end marker
