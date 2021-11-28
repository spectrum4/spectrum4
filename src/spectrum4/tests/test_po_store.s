# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.if ROMS_INCLUDE
.else
  .include "print_w0.s"
.endif


.text
.align 2


# Test printer in use.

po_store_printer_setup:
  _setbit 1, FLAGS
  ret

po_store_printer_setup_regs:
  mov     x1, #0x03
  mov     x2, #0x3421
  ret

po_store_printer_effects:
  _strb   0x3, P_POSN_X
  _str    0x3421, PR_CC
  ret

po_store_printer_effects_regs:
  ldrb    w3, [x28, FLAGS-sysvars]
  ret


# Test upper screen in use.

po_store_upper_screen_setup:
  _resbit 1, FLAGS
  _resbit 0, TV_FLAG
  ret

po_store_upper_screen_setup_regs:
  mov     x0, 0x35
  mov     x1, 0x2f
  mov     x2, 0x1bce
  ret

po_store_upper_screen_effects:
  _strb   0x2f, S_POSN_X
  _strb   0x35, S_POSN_Y
  _str    0x1bce, DF_CC
  ret

po_store_upper_screen_effects_regs:
  ldrb    w3, [x28, TV_FLAG-sysvars]
  ret


# Test lower screen in use.

po_store_lower_screen_setup:
  _resbit 1, FLAGS
  _setbit 0, TV_FLAG
  ret

po_store_lower_screen_setup_regs:
  mov     x0, 0xe2
  mov     x1, 0x56
  mov     x2, 0x523c
  ret

po_store_lower_screen_effects:
  _strb   0x56, S_POSN_X_L
  _strb   0xe2, S_POSN_Y_L
  _strb   0x56, ECHO_E_X
  _strb   0xe2, ECHO_E_Y
  _str    0x523c, DF_CC_L
  ret

po_store_lower_screen_effects_regs:
  ldrb    w3, [x28, TV_FLAG-sysvars]
  ret
