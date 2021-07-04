# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# This test sets [CURCHL] to a test channel block, which has the input routine address set to
# 0x0123456789abcdef. It calls po_change to change this input routine to 0xfedcba9876543210.

po_change_1_setup:
  _strh   po_change_1_channel_block, CURCHL
  ret

po_change_1_setup_regs:
  ld      de, 0x2345
  ret

po_change_1_effects:
  _strh   0x2345, po_change_1_channel_block
  ret

po_change_1_effects_regs:
  ld      hl, po_change_1_channel_block+1
  ret

po_change_1_channel_block:
  .hword  0x1234
