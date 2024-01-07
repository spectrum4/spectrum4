# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# ------------------------------------------------------------------------
# Find message in table, print it, with possible leading/trailing space(s)
# ------------------------------------------------------------------------
#
# The original Spectrum ROM 1 routine received the token number in register A,
# and popped a value off the stack to check whether trailing spaces should be
# printed. This number on the stack was also the token number when called from
# PO-TABLE routine, but had the explicit value of 4 when called from the
# TOKEN/UDG routine at L3BC3 (to include a trailing space) and 0 when called from
# PO-MSG routine (to not include a trailing space). Since the value on the stack
# was therefore not always the same as the value in register A, this ported
# routine takes two different input values in w3 and w5. w3 represents the value
# in Z80 register A, and w5 represents the value that was popped off the stack.
#
# Prints leading space if bit 0 of FLAGS clear and w3 >= 32 and first char >= 'A'.
# Prints trailing space if w5 >= 0x03 and (last char >= 'A' or last char == '$').
#
# On entry:
#   w3 = message table index
#   x4 = address of message table
#   w5 = trailing space indicator:
#     w5 < 03 => suppress trailing space
#     w5 >= 03 => don't suppress trailing space
#   x28 = sysvars
#   [[CURCHL]] = print routine to call
#   ... any settings that routine at [[CURCHL]] requires ...
# On exit:
#   x0 =
#     if w5 >= 3 and (last char >= 'A' or last char == '$')
#       ' '
#     else:
#       0x0
#   x1 = [[CURCHL]]
#   x4 = first address after found zero-byte terminated message
#   x6 = last char of keyword (not including the trailing zero byte)
#   NZCV =
#     if w5 > 3 and (last char >= 'A' or last char == '$'):
#       0b0010
#     for w5 == 0x03 and (last char >= 'A' or last char == '$'):
#       0b0110
#     else:
#       0b1000
po_table:                                // L0C14
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      po_search                               // Routine po_search will set carry for all messages and
                                                  // function words.
  bl      po_table_1
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
