.text
.align 2
# --------------
# Channel K flag
# --------------
# Flag setting routine for lower screen/keyboard channel ('K' channel).
#
# On entry:
# On exit:
#   [TV_FLAG] : set bit 0
#   [FLAGS] : clear bit 1 and bit 5
#   [FLAGS2] : set bit 4
#   [ATTR_T] = [BORDCR]
#   [MASK_T] = 0
#   [P_FLAG] : temp (even) bits set to zero
#   w0 = new [P_FLAG]
#   w1 = [BORDCR]
#   w9 = [FLAGS2]
chan_k:                                  // L1634
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldrb    w9, [x28, TV_FLAG-sysvars]              // w9[0-7] = [TV_FLAG]
  orr     w9, w9, #0x00000001                     // Set bit 0 - signal lower screen in use.
  strb    w9, [x28, TV_FLAG-sysvars]              // [TV_FLAG] = w9[0-7]
  ldrb    w9, [x28, FLAGS-sysvars]                // w9[0-7] = [FLAGS]
  and     w9, w9, #0xdddddddd                     // Clear bit 1 (printer not in use) and bit 5 (no new key).
                                                  // See https://dinfuehr.github.io/blog/encoding-of-immediate-values-on-aarch64
                                                  // for choice of #0xdddddddd
  strb    w9, [x28, FLAGS-sysvars]                // [FLAGS] = w9[0-7]
  ldrb    w9, [x28, FLAGS2-sysvars]               // w9[0-7] = [FLAGS2]
  orr     w9, w9, #0x00000010                     // Set bit 4 of FLAGS2 - signal K channel in use.
  strb    w9, [x28, FLAGS2-sysvars]               // [FLAGS2] = w9[0-7]
  bl      temps                                   // Set temporary attributes.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
