# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# -------------------
# Print question mark
# -------------------
# This routine prints a question mark which is used to print an unassigned
# control character in range 0 to 31.
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer(?)
#   w3 = unassigned char (0/1/2/3/4/5/7/10/11/12/14/15/24/25/26/27/28/29/30/31)
po_quest:                                // L0A69
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     w3, #0x3f                               // Char '?'.
  bl      po_able                                 // Print it.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
