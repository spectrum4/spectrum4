# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.text
.align 2


.if ROMS_INCLUDE
.else
  .include "print_w0.s"
.endif


# Test printer in use.

po_fetch_printer_setup:
  _setbit 1, FLAGS
  _strb   0x3, P_POSN_X
  _str    0x3421, PR_CC
  ret

po_fetch_printer_effects_regs:
  ldrb    w0, [x28, FLAGS-sysvars]
  mov     x1, #0x03
  mov     x2, #0x3421
  ret


# Test upper screen in use.

po_fetch_upper_screen_setup:
  _resbit 1, FLAGS
  _resbit 0, TV_FLAG
  _strb   0x2f, S_POSN_X
  _strb   0x35, S_POSN_Y
  _str    0x1bce, DF_CC
  ret

po_fetch_upper_screen_effects_regs:
  mov     x0, 0x35
  mov     x1, 0x2f
  mov     x2, 0x1bce
  ret


# Test lower screen in use.

po_fetch_lower_screen_setup:
  _resbit 1, FLAGS
  _setbit 0, TV_FLAG
  _strb   0x56, S_POSN_X_L
  _strb   0xe2, S_POSN_Y_L
  _str    0x523c, DF_CC_L
  ret

po_fetch_lower_screen_effects_regs:
  mov     x0, 0xe2
  mov     x1, 0x56
  mov     x2, 0x523c
  ret
