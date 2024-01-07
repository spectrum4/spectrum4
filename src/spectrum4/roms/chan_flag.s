# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# -----------------
# Set channel flags
# -----------------
# This subroutine is used from ED-EDIT, str$ and read-in to reset the
# current channel when it has been temporarily altered.
#
# On entry:
#
#   x0 = address of channel information inside CHANS
#
# On exit:
#
#   K Channel:
#     [CURCHL] = x0
#     [FLAGS] : clears bit 1 and bit 5
#     [FLAGS2] : sets bit 4
#     [TV_FLAG] : sets bit 0
#     [ATTR_T] = [BORDCR]
#     [MASK_T] = 0
#     [P_FLAG] : clears temp bits
#     w0 = new [P_FLAG]
#     w1 = [BORDCR]
#     x2 = chan_k
#     w9 = [FLAGS2]
#     x10 = 'K'
#     NZCV = 0b0110
#
#   S Channel:
#     [CURCHL] = x0
#     [FLAGS] : clears bit 1 => Printer not in use
#     [FLAGS2] : clears bit 4
#     [TV_FLAG] : clears bit 0 => Main screen in use
#     [ATTR_T] = [ATTR_P]
#     [MASK_T] = [MASK_P]
#     [P_FLAG] : Copies perm bits to temp bits
#     w0 = new [P_FLAG]
#     w1 = ([MASK_P] << 8) | [ATTR_P]
#     x2 = [P_FLAG] with temp bits copied from perm bits; perm bits cleared
#     w9 = 1
#     x10 = 'S'
#     NZCV = 0b0110
#
#   P Channel:
#     [CURCHL] = x0
#     [FLAGS] : sets bit 1 => Printer in use
#     [FLAGS2] : clears bit 4
#     w0 = new [P_FLAG]
#     x1 = chn_cd_lu + 0x28
#     x2 = chan_p
#     x9 = 0
#     x10 = 'P'
#
#   R Channel / custom user channel:
#     [CURCHL] = x0
#     [FLAGS2] : clears bit 4 => Channel K not in use
#     x0 = 'R'
#     x1 = 0x00
#     x9 = 0x00
#     x10 = 'P' (last key in chn-cd-lu table)
#     NZCV = 0b0010 (cmp 'R', 'P')
chan_flag:                               // L1615
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  str     x0, [x28, CURCHL-sysvars]               // [CURCHL] = CHANS record address
  ldrb    w9, [x28, FLAGS2-sysvars]               // w9 = [FLAGS2].
  and     w9, w9, #~0x10                          // w9 = [FLAGS2] with bit 4 clear.
  strb    w9, [x28, FLAGS2-sysvars]               // Update [FLAGS2] to have bit 4 clear (signal K channel not in use).
  ldr     x0, [x0, 16]                            // w0 = channel letter (stored at CHANS record address + 16)
  adr     x1, chn_cd_lu                           // x1 = address of flag setting routine lookup table
  bl      indexer                                 // look up flag setting routine
  cbz     x1, 1f                                  // If not found then there is no routine (channel 'R' or custom user channel) to call.
  blr     x2                                      // Call flag setting routine.
1:
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
