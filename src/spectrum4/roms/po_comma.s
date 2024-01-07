# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# -----------
# Print comma
# -----------
# The comma control character. The 108 column screen has six 18 character
# tabstops. The routine is only reached via the control character table.
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer
#   w3 = 0x06 (chr 6)
po_comma:                                // L0A5F
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  add     w1, w1, #16                             // w1 = 125 - column (125 to 18 on screen, 17 for trailing)
  mov     w3, #0xe38f                             // w3 = 58255
  umull   x4, w1, w3                              // x4 = w1 * 58255
  lsr     x4, x4, #20                             // x4 = w1 * 58255 / 1048576 = w1/18
  mov     w5, #18
  mov     x3, #126
  umsubl  x4, w5, w4, x3                          // x4 = x3 - w4*w5 = 126-18*((125-col)/18)
  bl      po_fill                                 // Print spaces until x pos (126-18*(125-col)/18)%108)
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
