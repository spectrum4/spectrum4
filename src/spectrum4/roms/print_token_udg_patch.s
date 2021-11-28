.text
.align 2
# Print key words or UDGs (chars 0x90-0xff).
#
# On entry:
#   w1 = (109 - column), or 1 for end-of-line
#   x2 = address in display file / printer buffer(?)
#   w3 = char (144-255 / 0x90-0xff)
#   x28 = sysvars
#   If printing a keyword:
#     [[CURCHL]] = print routine to call
#     ... any settings that routine at [[CURCHL]] requires ...
#   Else: (printing a UDG):
#     [P_FLAG] bit 0 and bit 2 (temp OVER, temp INVERSE)
#     [UDG] = address of UDG character table (address of UDG 'A' bitmap)
#     If printer not in use:
#       [P_FLAG] bit 4 and bit 6 (temp INK 9, temp PAPER 9)
#       [TV_FLAGS] bit 0 (lower screen in use or not)
#       [DF_SZ]
#       [ATTR_T]
#       [MASK_T]
#   If w3 = 0xa3 / 0xa4:
#     [FLAGS] bit 4 set to 0 for UDG T/U or 1 for PLAY / SPECTRUM keyword
#     If [FLAGS] bit 4 set:
#       [FLAGS] bit 0 clear if leading space required before PLAY / SPECTRUM keyword
#   If printer in use:
#     Bit 1 of FLAGS set
#     [P_POSN_X] set to printer position
#     [PR_CC] set to printer buffer address
#   If upper screen in use:
#     w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] clear
#     [S_POSN_{X,Y}] set to upper screen position
#     [DF_CC] set to display file address of upper screen position
#   If lower screen in use:
#     w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] set
#     [S_POSN_{X,Y}_L] set to lower screen position
#     [DF_CC_L] set to display file address of lower screen position
#
# On exit:
#   If printing a UDG:
#     [FLAGS] bit 0 cleared
#     x3 += 21 (0 to 20)
#     If printer in use:
#       printer buffer updated (and potentially flushed)
#     Else:
#       display file and attributes file updated
#       x0 = 60 - new line offset into section
#       x1 = 109 - new column, or 1 for end-of-line
#       x2 += 1 (correct new cursor memory location, unless at first char of screen third)
#       Plus po_attr register changes (excluding x3/x24):
#         x5
#         x6
#         x7
#         x8
#         x9 = mbreq
#         x10
#         x11
#         x12
#         x13
#         x14
#         x15
#         x16
#         x17
#         x18
#         NZCV
#       If was at end-of-line before printing (entry x1 == 1):
#         cl_set register updates:
#           x4 = y offset into screen third of updated position (not entry position)
#         If lower screen:
#           [S_POSN_X_L] = 109 (start of line)
#           [S_POSN_Y_L] = x0-1 (line below)
#           [ECHO_E_X] = 109 (start of line)
#           [ECHO_E_Y] = x0-1 (line below)
#           [DF_CC_L] set to display file address for [S_POSN_{X,Y}_L]
#         If upper screen:
#           [S_POSN_X] = 109 (start of line)
#           [S_POSN_Y] = x0-1 (line below)
#           [DF_CC] set to display file address for [S_POSN_{X,Y}]
#       Else:
#         x4 = address of 32 byte character bit pattern
#   If printing keyword:
#     for SPECTRUM/PLAY:
#       x3 = 0 (SPECTRUM) / 1 (PLAY)
#       x5 = 4
#     else:
#       x3 unchanged
#       x5 = x3
#     x4 = first address after zero termination byte of BASIC keyword in token table
#     x6 = last char of keyword (not including the trailing zero byte nor any added trailing space)
#     NZCV = ???
#     If printer in use:
#       w0 = [FLAGS]
#       w1 = [P_POSN_X] (109 - actual printer column)
#       x2 = [PR_CC] (address in printer buffer)
#     If upper screen in use:
#       w0 = [S_POSN_Y] (60 - actual upper screen row)
#       w1 = [S_POSN_X] (109 - actual upper screen column)
#       x2 = [DF_CC] (address of upper screen cursor in display file)
#     If lower screen in use:
#       w0 = [S_POSN_Y_L] (120 - [DF_SZ] - actual lower screen row)
#       w1 = [S_POSN_X_L] (109 - actual lower screen column)
#       x2 = [DF_CC_L] (address of lower screen cursor in display file)
print_token_udg_patch:                   // L3B9F
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  cmp     w3, #0xa3                               // Is char 'SPECTRUM' (128K mode) / UDG T (48K mode)?
  b.eq    2f                                      // If so, jump forward to 2:.
  cmp     w3, #0xa4                               // Is char 'PLAY' (128K mode) / UDG U (48K mode)?
  b.eq    2f                                      // If so, jump forward to 2:.
1:
  subs    w3, w3, #0xa5                           // w3 = (char - 165)
  b.pl    3f                                      // If char is token (w3 >= 0) jump forward to 3:.
  // UDG character
  bl      rejoin_po_t_udg                         // Rejoin 48K BASIC routine.
  b       5f                                      // Exit routine.
2:
  // SPECTRUM/PLAY token (128K mode) or T/U UDG (48K mode)

  // TODO: See if we can find an alternative unused register for storing FLAGS
  // in, since we read it multiple times below.

  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  tbz     w4, #4, 1b                              // If in 48K mode, jump back to 1:.
  // SPECTRUM or PLAY token in 128K mode
  adr     x4, tkn_spectrum                        // x4 = address of "SPECTRUM" string
  adr     x5, tkn_play                            // x5 = address of "PLAY" string
  subs    w3, w3, #0xa3                           // w3 = 0 for "SPECTRUM" or 1 for "PLAY"
  csel    x4, x4, x5, eq                          // x4 = correct address for token string
  mov     w5, #0x04                               // Indicate trailing space required
  // TODO: check if any registers need to be preserved here
  bl      po_table_1                              // Print SPECTRUM or PLAY.
  // TODO: set carry flag??? Why???
  ldrb    w4, [x28, FLAGS-sysvars]                // w4 = [FLAGS]
  tbnz    w4, #1, 5f                              // If printer in use, jump forward to 5:.
  // Printer not in use
  b       4f
3:
  bl      po_tokens
4:
  bl      po_fetch
5:
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
