# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# -------------------
# Cursor left routine
# -------------------
# For screen:
#   If in leftmost column:
#     If on first line:
#       No change
#     Otherwise:
#       To rightmost column of previous line
#   Otherwise:
#     Backspace a char
# For ZX printer:
#   If in leftmost column:
#     No change
#   Otherwise:
#     Backspace a char
#
# On entry:
#   w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer
#   w3 = 0x08 (chr 8)
#
# On exit:
#   If upper screen in use:
#     [S_POSN_Y]
#     [S_POSN_X]
#     [DF_CC]
#   If lower screen in use:
#     [S_POSN_Y_L]
#     [S_POSN_X_L]
#     [ECHO_E_Y]
#     [ECHO_E_X]
#     [DF_CC_L]
#   If printer in use:
#     [P_POSN_X]
#     [PR_CC]
po_back:                                 // L0A23
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  add     w1, w1, #1                              // Move left one column.
  cmp     w1, #110                                // Were we already in leftmost column?
  b.ne    1f                                      // If not, no further changes needed, so skip forward to 1:
                                                  // to update saved cursor position and exit.
  // Started in leftmost column, column number now invalid.
  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  tbnz    w4, #1, 2f                              // If printer in use, exit without applying any updates.
  // Started in leftmost column of screen (either channel K or S).
  add     w0, w0, #1                              // Move up one screen line.
  mov     w1, #2                                  // w1 = rightmost column position
  cmp     w0, #61                                 // Were we already on first line of upper/lower screen?
  b.eq    2f                                      // If so, exit without applying any updates.
1:
  // Store updated cursor position.
  bl      cl_set
2:
  // Exit routine.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
