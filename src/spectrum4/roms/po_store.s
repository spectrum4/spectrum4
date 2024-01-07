# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# -------------------------------------
# Store line, column, and pixel address
# -------------------------------------
# This routine updates the system variables associated with either
# the main screen, the lower screen/input buffer or the zx printer.
#
# If printer in use:
#   On entry:
#     Bit 1 of FLAGS set
#     w1 = value to store in P_POSN_X (109 - actual printer column)
#     x2 = value to store in PR_CC (address in printer buffer)
#     x28 = sysvars
#   On exit:
#     [P_POSN_X] set to printer position
#     [PR_CC] set to printer buffer address
#     w3 = [FLAGS]
#
# If upper screen in use:
#   On entry:
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] clear
#     w0 = value to store in S_POSN_Y (60 - actual upper screen row)
#     w1 = value to store in S_POSN_X (109 - actual upper screen column)
#     x2 = value to store in DF_CC (address of upper screen cursor in display file)
#     x28 = sysvars
#   On exit:
#     [S_POSN_{X,Y}] set to upper screen position
#     [DF_CC] set to display file address of upper screen position
#     w3 = [TV_FLAG]
#
# If lower screen in use:
#   On entry:
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] set
#     w0 = value to store in S_POSN_Y_L and ECHO_E_Y (120 - [DF_SZ] - actual lower screen row)
#     w1 = value to store in S_POSN_X_L and ECHO_E_X (109 - actual lower screen column)
#     x2 = value to store in DF_CC_L (address of lower screen cursor in display file)
#     x28 = sysvars
#   On exit:
#     [S_POSN_{X,Y}_L] set to lower screen position
#     [ECHO_E_{X,Y}] set to lower screen position
#     [DF_CC_L] set to display file address of lower screen position
#     w3 = [TV_FLAG]
po_store:                                // L0ADC
  ldrb    w3, [x28, FLAGS-sysvars]                // w3 = [FLAGS]
  tbnz    w3, #1, 2f                              // If printer in use, jump forward to 2:.
  ldrb    w3, [x28, TV_FLAG-sysvars]              // w3 = [TV_FLAG]
  tbnz    w3, #0, 1f                              // If lower screen in use, jump forward to 1:.
  // Upper screen in use; store channel 'S' cursor position.
  strb    w0, [x28, S_POSN_Y-sysvars]             // Store upper screen row.
  strb    w1, [x28, S_POSN_X-sysvars]             // Store upper screen column.
  str     x2, [x28, DF_CC-sysvars]                // Store upper screen display file address.
  b       3f                                      // Exit routine.
1:
  // Lower screen in use; store channel 'K' cursor position.
  strb    w0, [x28, S_POSN_Y_L-sysvars]           // Store lower screen row.
  strb    w1, [x28, S_POSN_X_L-sysvars]           // Store lower screen column.
  strb    w0, [x28, ECHO_E_Y-sysvars]             // Store input buffer row.
  strb    w1, [x28, ECHO_E_X-sysvars]             // Store input buffer column.
  str     x2, [x28, DF_CC_L-sysvars]              // Store lower screen display file address.
  b       3f                                      // Exit routine.
2:
  // Printer in use; store channel 'P' cursor position.
  strb    w1, [x28, P_POSN_X-sysvars]             // Store printer column.
  str     x2, [x28, PR_CC-sysvars]                // Store printer buffer address.
3:
  // Exit routine
  ret
