# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# This initial entry point deals with two operands - AT (0x16) or TAB (0x17).
#
# On entry:
#   w3 = control char (0x16/0x17)
#
# On exit:
#   [TVDATA] = w3[0-7]
#   [[CURCHL]] = po_tv_2
po_2_oper:                               // L0A75
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x4, po_tv_2
  bl      po_tv_1                                 // Store control character in TVDATA low byte and set
                                                  // current channel output routine to po_tv_2.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
