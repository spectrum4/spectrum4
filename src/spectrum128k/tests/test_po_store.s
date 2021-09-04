# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text



# Test printer in use.

po_store_printer_setup:
  _setbit 1, FLAGS
  ret

po_store_printer_setup_regs:
  ld      c, 0x3
  ld      hl, 0x3421
  ret

po_store_printer_effects:
  _strb   0x3, P_POSN_X
  _strh   0x3421, PR_CC
  ret

po_store_printer_effects_regs:
  f_clear_set N_FLAG|PV_FLAG|X5_FLAG|Z_FLAG|S_FLAG, H_FLAG|X3_FLAG
  ret


# Test upper screen in use.

po_store_upper_screen_setup:
  _resbit 1, FLAGS
  _resbit 0, TV_FLAG
  ret

po_store_upper_screen_setup_regs:
  ld      bc, 0x352f
  ld      hl, 0x1bce
  ret

po_store_upper_screen_effects:
  _strh   0x352f, S_POSN_X
  _strh   0x1bce, DF_CC
  ret

po_store_upper_screen_effects_regs:
  f_clear_set N_FLAG|X5_FLAG|S_FLAG, H_FLAG|X3_FLAG|PV_FLAG|Z_FLAG
  ret


# Test lower screen in use.

po_store_lower_screen_setup:
  _resbit 1, FLAGS
  _setbit 0, TV_FLAG
  ret

po_store_lower_screen_setup_regs:
  ld      bc, 0xe256
  ld      hl, 0x523c
  ret

po_store_lower_screen_effects:
  _strh   0xe256, S_POSN_X_L
  _strh   0xe256, ECHO_E_X
  _strh   0x523c, DF_CC_L
  ret

po_store_lower_screen_effects_regs:
  f_clear_set N_FLAG|PV_FLAG|X5_FLAG|Z_FLAG|S_FLAG, H_FLAG|X3_FLAG
  ret
