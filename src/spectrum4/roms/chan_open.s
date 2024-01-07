# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# ------------
# Open channel
# ------------
# This subroutine opens channel 'K', 'S', 'R', 'P' or a custom user channel. This
# is either called directly, or in response to a user's request, for example,
# when '#' is encountered with output - PRINT/LIST/... or with input -
# INPUT/INKEY$/... It is entered with a system stream -3 to -1, or a user stream
# 0 to 15.
#
# On entry:
#   x0 = stream number in range [-3,15]
#
# On exit:
#   If Channel K:
#     [CURCHL] = address in CHANS block of Channel K
#     [FLAGS] : clears bit 1 and bit 5 => Printer not in use and no new key
#     [FLAGS2] : sets bit 4 => Channel K in use
#     [TV_FLAG] : sets bit 0 => Lower screen in use
#     [ATTR_T] = [BORDCR]
#     [MASK_T] = 0
#     [P_FLAG] : temp bits cleared
#     x0 = [P_FLAG]
#     x1 = [BORDCR]
#     x2 = chan_k
#     w9 = [FLAGS2]
#     x10 = 'K'
#     NZCV = 0b0110
#
#   If Channel S:
#     [CURCHL] = address in CHANS block of Channel S
#     [FLAGS] : clears bit 1 => Printer not in use
#     [FLAGS2] : clears bit 4 => Channel K not in use
#     [TV_FLAG] : clears bit 0 => Lower screen not in use
#     [ATTR_T] = [ATTR_P]
#     [MASK_T] = [MASK_P]
#     [P_FLAG] : perm bits copied to temp bits
#     x0 = [P_FLAG]
#     x1 = ([MASK_P] << 8) | [ATTR_P]
#     x2 = [P_FLAG] with temp bits copied from perm bits; perm bits cleared
#     x9 = 0x01
#     x10 = 'S'
#     NZCV = 0b0110
#
#   If Channel P:
#     [CURCHL] = address in CHANS block of Channel P
#     [FLAGS] : sets bit 1 => Printer in use
#     [FLAGS2] : clears bit 4 => Channel K not in use
#     w0 = [FLAGS]
#     x1 = chn_cd_lu + 0x28
#     x2 = chan_p
#     x9 = 0x00
#     x10 = 'P'
#     NZCV = 0b0110
#
#   If Channel R / custom user channel:
#     [CURCHL] = address in CHANS block of Channel R / custom user channel
#     [FLAGS2] : clears bit 4 => Channel K not in use
#     x0 = 'R'
#     x1 = 0x00
#     x9 = 0x00
#     x10 = 'P' (last key in chn-cd-lu table)
#     NZCV = 0b0010 (cmp 'R', 'P')
chan_open:                               // L1601
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  add     x9, x28, x0, lsl #1                     // x9 = sysvars + stream number * 2
  ldrh    w10, [x9, STRMS-sysvars+6]              // w10 = [stream number * 2 + STRMS + 6] = CHANS offset + 1
  cbnz    w10, 1f                                 // Non-zero indicates channel open, in which case continue
  mov     x0, 0x17                                // Error Report: Invalid stream
// TODO: check if this should be `b` instead of `bl` followed by `b 2f`.
//   bl      error_1
  b       2f
1:
  ldr     x9, [x28, CHANS-sysvars]                // x9 = [CHANS]
  add     x10, x10, x9                            // w10 = [CHANS] + CHANS offset + 1
  sub     x0, x10, #1                             // x0 = address of channel data in CHANS
  bl      chan_flag
2:
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
