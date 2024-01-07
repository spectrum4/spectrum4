# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# -------------------------------
# Handle display with line number
# -------------------------------
# This subroutine is called from four places to calculate the address
# of the start of a screen character line.
#
# On entry:
#   x0 = 60 - screen line
# On exit:
#   x1 = screen line
#   x2 = address of top left pixel of line to clear inside display file
#   x3 = screen line / 20
#   x4 = screen line % 20
#   x5 = 216
#   x6 = 69120 (0x10e00)
cl_addr:                                 // L0E9B
  mov     x1, #60
  sub     x1, x1, x0
  adrp    x2, display_file
  add     x2, x2, :lo12:display_file
  mov     x3, #0xcccccccccccccccc
  add     x3, x3, #1                              // x3 = 0x0xcccccccccccccccd
  umulh   x3, x3, x1                              // x3 = 14757395258967641293 * x1 / 2^64 = int(0.8*x1)
  lsr     x3, x3, #4                              // x3 = int(x1/20)
  add     x4, x3, x3, lsl #2                      // x4 = 5 * int(x1/20)
  sub     x4, x1, x4, lsl #2                      // x4 = x1 - 20 * int(x1/20) = x1%20
  mov     x5, #216
  umaddl  x2, w4, w5, x2                          // x2 = display_file + (x1%20)*216
  mov     x6, 0x00010000
  movk    x6, 0xe00
  umaddl  x2, w6, w3, x2                          // x2 = display_file + (x1%20)*216 + (x1/20)*69120
  ret
