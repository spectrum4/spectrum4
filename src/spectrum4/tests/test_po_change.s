# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.text
.align 2


# This test sets [CURCHL] to a test channel block, which has the input routine address set to
# 0x0123456789abcdef. It calls po_change to change this input routine to 0xfedcba9876543210.


po_change_1_setup:
  _str    po_change_1_channel_block, CURCHL       // [CURCHL] = po_change_1_channel_block
  ret


po_change_1_setup_regs:
  ldr     x4, =0xfedbca9876543210                 // x4 = 0xfedbca9876543210
  ret


po_change_1_effects:
  _str    0xfedbca9876543210, po_change_1_channel_block
                                                  // [po_change_1_channel_block] = 0xfedbca9876543210
  ret


po_change_1_effects_regs:
  adr     x5, po_change_1_channel_block           // x5 = po_change_1_channel_block
  ret


.align 3
po_change_1_channel_block:
  .quad 0x0123456789abcdef
