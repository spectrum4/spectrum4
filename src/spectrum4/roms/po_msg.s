# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# ----------------
# Message printing
# ----------------
#
# Find message in table, print it, with possible leading space (no trailing
# space). This entry point is used to print tape, boot-up, scroll? and error
# messages.
#
# Prints leading space if bit 0 of FLAGS clear and w3 >= 32 and first char >= 'A'.
#
# On entry:
#   w3 = message table index
#   x4 = address of message table
#   x28 = sysvars
#   [[CURCHL]] = print routine to call
#   ... any settings that routine at [[CURCHL]] requires ...
# On exit:
#   x0 = 0
#   x1 = [[CURCHL]]
#   x4 = first address after found zero-byte terminated message
#   x5 = 0
#   x6 = last char of keyword (not including the trailing zero byte)
#   NZCV = 0b1000
po_msg:                                  // L0C0A
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     w5, #0                                  // Index first entry in table.
  bl      po_table                                // Could just call po_table_1 here (and only need part of it).
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
