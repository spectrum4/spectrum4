.text
.align 2
# -------------------------
# Fetch position parameters
# -------------------------
# This routine fetches the line/column and display file address
# of the upper or lower screen or, if the printer is in use,
# the column position and absolute memory address.
#
# If printer in use:
#   On entry:
#     Bit 1 of FLAGS set
#     [P_POSN_X] set to printer position
#     [PR_CC] set to printer buffer address
#     x28 = sysvars
#   On exit:
#     w0 = [FLAGS]
#     w1 = [P_POSN_X] (109 - actual printer column)
#     x2 = [PR_CC] (address in printer buffer)
#
# If upper screen in use:
#   On entry:
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] clear
#     [S_POSN_{X,Y}] set to upper screen position
#     [DF_CC] set to display file address of upper screen position
#     x28 = sysvars
#   On exit:
#     w0 = [S_POSN_Y] (60 - actual upper screen row)
#     w1 = [S_POSN_X] (109 - actual upper screen column)
#     x2 = [DF_CC] (address of upper screen cursor in display file)
#
# If lower screen in use:
#   On entry:
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] set
#     [S_POSN_{X,Y}_L] set to lower screen position
#     [DF_CC_L] set to display file address of lower screen position
#     x28 = sysvars
#   On exit:
#     w0 = [S_POSN_Y_L] (120 - [DF_SZ] - actual lower screen row)
#     w1 = [S_POSN_X_L] (109 - actual lower screen column)
#     x2 = [DF_CC_L] (address of lower screen cursor in display file)
po_fetch:                                // L0B03
  ldrb    w0, [x28, FLAGS-sysvars]                // w0 = [FLAGS]
  tbnz    w0, #1, 2f                              // If printer in use, jump forward to 2:.
  ldrb    w0, [x28, TV_FLAG-sysvars]              // w0 = [TV_FLAG]
  tbnz    w0, #0, 1f                              // If lower screen in use, jump forward to 1:.
  // Upper screen in use; fetch channel 'S' cursor position.
  ldrb    w0, [x28, S_POSN_Y-sysvars]             // Fetch upper screen row.
  ldrb    w1, [x28, S_POSN_X-sysvars]             // Fetch upper screen column.
  ldr     x2, [x28, DF_CC]                        // Fetch upper screen display file address.
  b       3f                                      // Exit routine.
1:
  // Lower screen in use; fetch channel 'K' cursor position.
  ldrb    w0, [x28, S_POSN_Y_L-sysvars]           // Fetch lower screen row.
  ldrb    w1, [x28, S_POSN_X_L-sysvars]           // Fetch lower screen column.
  ldr     x2, [x28, DF_CC_L]                      // Fetch lower screen display file address.
  b       3f                                      // Exit routine.
2:
  // Printer in use; fetch channel 'P' cursor position.
  ldrb    w1, [x28, P_POSN_X-sysvars]             // Fetch printer column.
  ldr     x2, [x28, PR_CC]                        // Fetch printer buffer address.
3:
  // Exit routine.
  ret
