# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# Print keywords (with possible leading and/or trailing space) or UDGs (chars 0x90-0xff).
#
# On entry:
#   w3 = char (144-255 / 0x90-0xff)
#   x28 = sysvars
#   If printing a keyword:
#     [[CURCHL]] = print routine to call
#     ... any settings that routine at [[CURCHL]] requires ...
#   Else: (printing a UDG):
#     w1 = (109 - column), or 1 for end-of-line
#     x2 = address in display file / printer buffer(?)
#     [P_FLAG] bit 0 and bit 2 (temp OVER, temp INVERSE)
#     [UDG] = address of UDG character table (address of UDG 'A' bitmap)
#     If printer not in use:
#       [P_FLAG] bit 4 and bit 6 (temp INK 9, temp PAPER 9)
#       [TV_FLAGS] bit 0 (lower screen in use or not)
#       [DF_SZ]
#       [ATTR_T]
#       [MASK_T]
#       Display file / attribute file data at character cell
#   If w3 = 0xa3 / 0xa4:
#     [FLAGS] bit 4 set to 0 for UDG T/U or 1 for PLAY / SPECTRUM keyword
#     If [FLAGS] bit 4 set:
#       [FLAGS] bit 0 clear if leading space required before PLAY / SPECTRUM keyword
#   If printer in use:
#     Bit 1 of FLAGS set
#     [P_POSN_X]
#     [PR_CC]
#   If upper screen in use:
#     w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] clear
#     [S_POSN_{X,Y}]
#     [DF_CC]
#   If lower screen in use:
#     w0 = 60 - line offset into section (60 = top line of S/K, 59 = second line, etc)
#     Bit 1 of FLAGS clear
#     Bit 0 of [TV_FLAG] set
#     [S_POSN_{X,Y}_L]
#     [DF_CC_L]
#
# On exit:
#   If printing a UDG:
#     [FLAGS] bit 0 cleared
#     If printer in use:
#       printer buffer updated (and potentially flushed)
#       <other unknown stuff>
#     Else:
#       display file and attributes file updated
#       x0 = 60 - new line offset into section
#       x1 = 109 - new column, or 1 for end-of-line
#       x2 += 2 (correct new cursor memory location, unless at first char of screen third)
#       Plus po_attr register changes (excluding x24):
#         x3
#         x5
#         x6
#         x7
#         x8
#         x9 = fb_req
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
#     If printer in use:
#       for SPECTRUM/PLAY:
#         x0 = ' ', or whatever [[CURCHL]] changes it to
#         x1 = [[CURCHL]], or whatever [[CURCHL]] changes it to
#         x2 unchanged
#       for other keywords:
#         w0 = [FLAGS]
#         w1 = [P_POSN_X] (109 - actual printer column)
#         x2 = [PR_CC] (address in printer buffer)
#     If upper screen in use:
#       w0 = [S_POSN_Y] (60 - actual upper screen row)
#       w1 = [S_POSN_X] (109 - actual upper screen column)
#       x2 = [DF_CC] (address of upper screen cursor in display file)
#     If lower screen in use:
#       w0 = [S_POSN_Y_L] (120 - [DF_SZ] - actual lower screen row)
#       w1 = [S_POSN_X_L] (109 - actual lower screen column)
#       x2 = [DF_CC_L] (address of lower screen cursor in display file)
#     for SPECTRUM/PLAY:
#       x3 = 0 (SPECTRUM) / 1 (PLAY)
#       x4 = [FLAGS]
#       x5 = 4
#     for other keywords:
#       x3 -= 0xa5 (165)
#       x4 = first address after zero termination byte of BASIC keyword in token table
#       x5 = exit x3
#     x6 = last char of keyword (not including the trailing zero byte nor any added trailing space)
#     for RND/INKEY$/PI/<=/>=/<>/OPEN #/CLOSE #:
#       nzcv = 0b1000
#     for FN:
#       nzcv = 0b0110, or whatever [[CURCHL]] changes it to
#     for everything else:
#       nzcv = 0b0010, or whatever [[CURCHL]] changes it to
#     x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27 =
#       whataver [[CURCHL]] does with them
po_t_udg:                                // L0B52
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      print_token_udg_patch
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
