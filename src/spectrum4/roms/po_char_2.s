# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2

# This routine is used to print ASCII characters  32d - 127d.
#
# Bit 0 of [FLAGS] updated to 1 if w3=' ' (=> suppress leading space), otherwise 0 (=>
# allow leading space).
#
# On entry:
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer
#   w3 = char (32-127)
#   x4 = font table address of theoretical char 0
#   [FLAGS] bit 1 (printer in use or not)
#   [P_FLAG] bit 0 and bit 2 (temp OVER, temp INVERSE)
#   if printer not in use:
#     w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#     [P_FLAG] bit 4 and bit 6 (temp INK 9, temp PAPER 9)
#     [TV_FLAGS] bit 0 (lower screen in use or not)
#     [DF_SZ]
#     [ATTR_T]
#     [MASK_T]
# On exit:
#   [FLAGS] bit 0 == 1 if w3==' ' else 0
#   If printer in use:
#     printer buffer updated (and potentially flushed)
#   Else:
#     display file and attributes file updated
#     x0 = 60 - new line offset into section
#     x1 = 109 - new column, or 1 for end-of-line
#     x2 += 2 (correct new cursor memory location, unless at first char of screen third)
#     Plus po_attr register changes (excluding x24):
#       x3
#       x5
#       x6
#       x7
#       x8
#       x9 = fb_req
#       x10
#       x11
#       x12
#       x13
#       x14
#       x15
#       x16
#       x17
#       x18
#       NZCV
#     If was at end-of-line before printing (entry x1 == 1):
#       cl_set register updates:
#         x4 = y offset into screen third of updated position (not entry position)
#       If lower screen:
#         [S_POSN_X_L] = 109 (start of line)
#         [S_POSN_Y_L] = x0-1 (line below)
#         [ECHO_E_X] = 109 (start of line)
#         [ECHO_E_Y] = x0-1 (line below)
#         [DF_CC_L] set to display file address for [S_POSN_{X,Y}_L]
#       If upper screen:
#         [S_POSN_X] = 109 (start of line)
#         [S_POSN_Y] = x0-1 (line below)
#         [DF_CC] set to display file address for [S_POSN_{X,Y}]
#     Else:
#       x4 = address of 32 byte character bit pattern
po_char_2:                               // L0B6A
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldrb    w5, [x28, FLAGS-sysvars]                // w5 = [FLAGS]
  and     w5, w5, 0xfe                            // Clear bit 0 (=> allow leading space)
  cmp     w3, #0x20                               // Space character?
  b.ne    1f                                      // If not, jump forward to 1:.
  orr     w5, w5, 0x1                             // Set bit 0 (=> suppress leading space)
1:
  strb    w5, [x28, FLAGS-sysvars]                // Update [FLAGS] with bit 0 clear iff char is a space.
  add     x4, x4, x3, lsl #5                      // x4 = first byte of bit pattern of char
  bl      pr_all
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
