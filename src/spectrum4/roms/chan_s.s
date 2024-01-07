# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# --------------
# Channel S flag
# --------------
# Flag setting routine for upper screen channel ('S' channel).
#
# On entry:
# On exit:
#   [TV_FLAG] - clears bit 0 to signal main screen in use.
#   [FLAGS] - clears bit 1 to signal printer not in use.
#   [ATTR_T] = [ATTR_P]
#   [MASK_T] = [MASK_P]
#   [P_FLAG] = perm copied to temp bits
#   w0 = new [P_FLAG]
#   w1 = ([MASK_P] << 8) | [ATTR_P]
#   w2 = [P_FLAG] with temp bits copied from perm bits; perm bits cleared
chan_s:                                  // L1642
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldrb    w0, [x28, TV_FLAG-sysvars]
  and     w0, w0, #~0x01                          // Clear bit 0 - signal main screen in use.
  strb    w0, [x28, TV_FLAG-sysvars]              // [TV_FLAG] = w0[0-7]
  ldrb    w0, [x28, FLAGS-sysvars]
  and     w0, w0, #0xfffffffd                     // Clear bit 1 - signal printer not in use.
  strb    w0, [x28, FLAGS-sysvars]                // [FLAGS] = w0[0-7]
  bl      temps
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
