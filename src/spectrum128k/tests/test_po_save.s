# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# Test PO-SAVE routine using a fake print routine that just buffers what is
# printed.

po_save_1_setup:
  ld      hl, fake_channel_block
  jp      fake_channel_init

po_save_1_setup_regs:
  ld      a, 'y'                          ; print 'y'
  ret

po_save_1_effects:
  _strb   3, 0x4000                       ; modified by fake_printout routine
  _strb   'y', 0x4002                     ; modified by fake_printout routine
  ret

po_save_1_effects_regs:
  ret

# Test PO-SAVE routine using a fake print routine that just corrupts all
# registers, so we can see which are preserved by PO-SAVE.

po_save_2_setup:
  ld      hl, fake_touch_registers_channel_block
  jp      fake_channel_init

po_save_2_setup_regs:
  jr      po_save_1_setup_regs

po_save_2_effects:
  jr      po_save_1_effects

po_save_2_effects_regs:
  push    de
  push    hl
  call    touch_all_registers
  pop     hl
  pop     de
  ret
