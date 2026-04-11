// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 2


// ------------------------------------------------------------------------------
// Menu Up Handler
// Move menu highlight up one item.
// Equivalent to rom0.s L272E.
// ------------------------------------------------------------------------------
// On entry:
//   x28 = sysvars base
// On exit:
//   returns to caller
menu_up:                                 // L272E
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  ldrb    w1, [x28, EC0C-sysvars]                 // w1 = current menu index
  bl      toggle_menu_highlight                   // unhighlight current item
  ldrb    w1, [x28, EC0C-sysvars]                 // re-read index
  subs    w1, w1, #1                              // w1 = new index; set flags
  b.pl    1f                                      // if >= 0, use new index
  adr     x2, main_menu_jump_table                // wrap to bottom
  ldr     x3, [x2]                                // x3 = number of menu entries
  sub     w1, w3, #1                              // w1 = last item index (entries - 1)
1:
  strb    w1, [x28, EC0C-sysvars]                 // store new index
  bl      toggle_menu_highlight                   // highlight new item
  ldp     x29, x30, [sp], #0x10
  ret
