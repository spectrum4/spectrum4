// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 2


// ------------------------------------------------------------------------------
// Menu Select Handler
// Execute the menu item at the current index.
// ------------------------------------------------------------------------------
// On entry:
//   x28 = sysvars base
// On exit:
//   jumps to selected handler (does not return to caller)
menu_select:                             // L2717
  ldrb    w0, [x28, EC0C-sysvars]                 // w0 = current menu index
  adr     x2, main_menu_jump_table
  add     w0, w0, #1                              // skip count entry (first quad)
  ldr     x3, [x2, x0, lsl #3]                    // x3 = handler address
  br      x3                                      // jump to handler (does not return)
