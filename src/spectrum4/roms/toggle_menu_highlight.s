.text

# ------------------------
# Display Menu
# ------------------------
#
# On entry:
#   w1 = menu row number (0 based, 0 = top row)
# On exit:
.align 2
toggle_menu_highlight:                   // L37CA
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adrp    x19, attributes_file+0x1a*108+0x2f      // address of first attribute of first menu item
  add     x19, x19, :lo12:(attributes_file+0x1a*108+0x2f)
  add     w20, w1, w1, lsl #3                     // w20 = 9 * menu row number
  add     w20, w20, w20, lsl #1                   // w20 = 3 * 9 * menu row number = 27 * menu row number
  add     x19, x19, x20, lsl #2                   // x19 = address of first attribute of first menu item + 108 * menu row number
                                                  //     = first attribute of selected menu item
  ldrb    w20, [x19]
  eor     w20, w20, #0x10
  mov     w21, #0x0e
  1:
    mov     x0, x19
    mov     w1, w20
    bl      poke_address
    add     x19, x19, #1
    subs    w21, w21, #1
    b.ne    1b
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
