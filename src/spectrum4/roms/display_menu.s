.text

# ------------------------
# Display Menu
# ------------------------
#
# On entry:
#   x19 = jump table
#   x20 = menu text
# On exit:
.align 2
display_menu:                            // L36A8
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      store_menu_screen_area
  ldrb    w0, [x28, TV_FLAG-sysvars]
  and     w0, w0, #0xfe
  strb    w0, [x28, TV_FLAG-sysvars]              // Clear bit 0 of TV_FLAG: main screen in use
  ldrb    w23, [x19], #8                          // w23 = number of entries
  lsl     w25, w23, #4                            // w25 = number of entries * 16
  adr     x4, menu_title_colours
  bl      print_str_ff                            // Print title colours and position
  mov     x2, x20
  bl      print_message
  mov     x20, x2
  bl      print_sinclair_stripes
  adr     x4, menu_title_space
  bl      print_str_ff                            // Print remainder of menu title
  mov     w8, 0x1a
  1:
    mov     w9, 0x2f
    mov     w22, w8
    bl      print_at
    mov     w0, ' '
    bl      print_w0
    mov     w21, 0x0d                             // Number of chars to print (including space padding)
  2:
    ldrb    w0, [x20], #1
    cbz     w0, 3f
    bl      print_w0
    sub     w21, w21, #1
    b       2b
  3:
    4:
      mov     w0, ' '
      bl      print_w0
      subs    w21, w21, #1
      b.ne    4b
    add     w8, w22, #1
    subs    w23, w23, #1
    b.hs    1b
  mov     w19, #0x01ff
  mov     w20, #0x02f0
  mov     w21, #0xffffffff
  mov     w22, #0x00
  add     w23, w25, #15                           // 16 * (number of menu entries + 1) - 1
  bl      plot_line
  mov     w21, #0x00
  mov     w22, #0x01
  mov     w23, #0xdf
  bl      plot_line
  mov     w21, #0x01
  mov     w22, #0x00
  add     w23, w25, #16                           // 16 * (number of menu entries + 1)
  bl      plot_line
  mov     w1, #0
  bl      toggle_menu_highlight
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# ------------------------
# Menu Title Colours Table
# ------------------------
.align 0
menu_title_colours:                      // L37EC
  .byte 0x16, 0x19, 0x2f                          // AT 25, 47;
  .byte 0x15, 0x00                                // OVER 0;
  .byte 0x14, 0x00                                // INVERSE 0;
  .byte 0x10, 0x07                                // INK 7;
  .byte 0x11, 0x00                                // PAPER 0;
  .byte 0x13, 0x01                                // BRIGHT 1;
  .byte 0xff                                      // end marker


# ----------------------
# Menu Title Space Table
# ----------------------
.align 0
menu_title_space:                        // L37FA
  .byte 0x11, 0x00                                // PAPER 0
  .byte ' '
  .byte 0x11, 0x07                                // PAPER 7
  .byte 0x10, 0x00                                // INK 0
  .byte 0xff                                      // end marker
