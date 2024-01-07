# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# Called with the single operand for single byte parameter control codes, or
# second operand for two byte parameter control codes.
#
# Stores control char in [TVDATA] low byte, and updates current channel output
# routine to address passed in in x4.
#
# On entry:
#   w3 = control char (16/17/18/19/20/21/22/23)
#   x4 = function pointer for handling 1 or 2 control chars (po_cont or po_tv_2)
# On exit:
#   [TVDATA] = w3[0-7]
#   [[CURCHL]] = x4
#   x5 = [CURCHL]
po_tv_1:                                 // L0A7D
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  strb    w3, [x28, TVDATA-sysvars]               // Store control code character in TVDATA low byte
  bl      po_change                               // Set current channel output routine to passed in output routine.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
