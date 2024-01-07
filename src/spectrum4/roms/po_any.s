# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# -------------------
# Print any character
# -------------------
# This routine is used to print any character in range 32 - 255.
# It is only called from po_able which then calls po_store.
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer(?)
#   w3 = char (32-255)
po_any:                                  // L0B24
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  cmp     w3, #0x80                               // Check if printable chars 32-127.
  b.lo    1f                                      // If so, jump forward to 1:.
  cmp     w3, #0x90                               // Test if a UDG or keyword token.
  b.hs    2f                                      // If so, jump forward to 2:.
  // Mosaic character 128-143.
  add     x6, x28, MEMBOT-sysvars                 // x6 = temporary location to write bit pattern to
  bl      po_mosaic_half                          // Generate top half (first 8 pixel rows) of mosaic character.
  bl      po_mosaic_half                          // Generate bottom half (last 8 pixel rows) of mosaic character.
  add     x4, x28, MEMBOT-sysvars                 // x4 = address of character bit pattern
  // TODO: check registers are set correctly for this call
  bl      pr_all                                  // Print mosaic character 128-143.
  b       3f                                      // Exit routine.
1:
  // Printable char 32-127.
  bl      po_char                                 // Print printable char 32-127.
  b       3f                                      // Exit routine.
2:
  // UDG or keyword token 144-255.
  bl      po_t_udg                                // Print UDG or keyword token 144-255.
3:
  // Exit routine.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
