.text
.align 2
# Print UDG bitmap (chars 0x90-0xa4).
#
# On entry:
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer
#   w3 = UDG char-165 (-21 to -1)
#   x28 = sysvars address
#   [FLAGS] bit 1 (printer in use or not)
#   [P_FLAG] bit 0 and bit 2 (temp OVER, temp INVERSE)
#   [UDG] = address of UDG character table (address of UDG 'A' bitmap)
#   if printer not in use:
#     w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#     [P_FLAG] bit 4 and bit 6 (temp INK 9, temp PAPER 9)
#     [TV_FLAGS] bit 0 (lower screen in use or not)
#     [DF_SZ]
#     [ATTR_T]
#     [MASK_T]
# On exit:
#   [FLAGS] bit 0 cleared
#   x3 += 21 (0 to 20)
#   If printer in use:
#     printer buffer updated (and potentially flushed)
#   Else:
#     display file and attributes file updated
#     x0 = 60 - new line offset into section
#     x1 = 109 - new column, or 1 for end-of-line
#     x2 += 1 (correct new cursor memory location, unless at first char of screen third)
#     Plus po_attr register changes (excluding x3/x24):
#       x5
#       x6
#       x7
#       x8
#       x9 = mbreq
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
rejoin_po_t_udg:                         // L0B56
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  add     w3, w3, UDG_COUNT                       // w3 now in range 0 to 20
  ldr     x4, [x28, UDG-sysvars]                  // x4 = [UDG]
  bl      po_char_2
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
