# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2

# ----------------------
# Menu Keys Action Table
# ----------------------
# Equivalent to rom0.s L2577.
# Parallel arrays to avoid alignment issues with mixed byte/quad data.
.align 0
menu_keys_codes:
  .byte 0x0b                                      // Cursor Up
  .byte 0x0a                                      // Cursor Down
  .byte 0x07                                      // Edit (= menu select)
  .byte 0x0d                                      // Enter (= menu select)
menu_keys_count = . - menu_keys_codes

.align 3
menu_keys_handlers:
  .quad menu_up
  .quad menu_down
  .quad menu_select
  .quad menu_select


# ---------------------------
# Menu Up Handler
# ---------------------------
# Move menu highlight up one item.
# Equivalent to rom0.s L272E.
#
# On entry:
#   x28 = sysvars base
# On exit:
#   returns to caller
menu_up:                                 // L272E
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  ldrb    w1, [x28, EC0C-sysvars]                 // w1 = current menu index
  cbz     w1, 1f                                  // already at top, do nothing
  bl      toggle_menu_highlight                   // unhighlight current item (w1 = current index)
  ldrb    w1, [x28, EC0C-sysvars]                 // re-read index
  sub     w1, w1, #1                              // w1 = new index
  strb    w1, [x28, EC0C-sysvars]                 // store new index
  bl      toggle_menu_highlight                   // highlight new item (w1 = new index)
1:
  ldp     x29, x30, [sp], #0x10
  ret


# ---------------------------
# Menu Down Handler
# ---------------------------
# Move menu highlight down one item.
# Equivalent to rom0.s L2731.
#
# On entry:
#   x28 = sysvars base
# On exit:
#   returns to caller
menu_down:                               // L2731
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  ldrb    w1, [x28, EC0C-sysvars]                 // w1 = current menu index
  adr     x2, main_menu_jump_table
  ldr     x3, [x2]                                // x3 = number of menu entries
  sub     w3, w3, #1                              // w3 = max index (entries - 1)
  cmp     w1, w3
  b.hs    1f                                      // already at bottom, do nothing
  bl      toggle_menu_highlight                   // unhighlight current item (w1 = current index)
  ldrb    w1, [x28, EC0C-sysvars]                 // re-read index
  add     w1, w1, #1                              // w1 = new index
  strb    w1, [x28, EC0C-sysvars]                 // store new index
  bl      toggle_menu_highlight                   // highlight new item (w1 = new index)
1:
  ldp     x29, x30, [sp], #0x10
  ret


# ---------------------------
# Menu Select Handler
# ---------------------------
# Execute the menu item at the current index.
# Equivalent to rom0.s L2717.
#
# On entry:
#   x28 = sysvars base
# On exit:
#   jumps to selected handler (does not return to caller)
menu_select:                             // L2717
  ldrb    w0, [x28, EC0C-sysvars]                 // w0 = current menu index
  adr     x2, main_menu_jump_table
  add     w0, w0, #1                              // skip count entry (first quad)
  ldr     x3, [x2, x0, lsl #3]                    // x3 = handler address
  br      x3                                      // jump to handler (does not return)
