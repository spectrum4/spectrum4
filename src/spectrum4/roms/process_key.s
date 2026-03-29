# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2

# -------------------
# Process Key Press
# -------------------
# Handle key presses for menus and the Editor.
# Equivalent to rom0.s L2669.
#
# On entry:
#   w0 = key code
#   x28 = sysvars base
# On exit:
#   returns to caller (wait_key_press loops)
process_key:                             // L2669
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp

  // Check if menu is displayed
  ldrb    w1, [x28, EC0D-sysvars]
  tbz     w1, #1, 1f                              // bit 1 clear = no menu, editor path (not yet implemented)

  // Menu is displayed, search menu keys table
  adr     x1, menu_keys_codes
  mov     w2, #(menu_keys_count)                  // w2 = number of entries
  mov     w3, #0                                  // w3 = index
2:
  cbz     w2, 1f                                  // no more entries, no match
  ldrb    w4, [x1, x3]                            // w4 = key code from table
  cmp     w0, w4
  b.eq    3f                                      // match found
  add     w3, w3, #1
  sub     w2, w2, #1
  b       2b
3:
  // Match found, call handler at menu_keys_handlers[w3]
  adr     x1, menu_keys_handlers
  ldr     x4, [x1, x3, lsl #3]                    // x4 = handler address
  blr     x4

1:
  ldp     x29, x30, [sp], #0x10
  ret
