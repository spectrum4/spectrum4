# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text



# The condition flags are set by either the BIT 1, (IY+(FLAGS-C_IY))
# instruction at the start of po_fetch routine, or the
# BIT 0, (IY+(TV_FLAG-C_IY)) further down.
#
# Condition flag effects for BIT n, (IY+a) are described (unofficially)
# in http://www.z80.info/zip/z80-documented.pdf:
#
#   S_FLAG set if n = 7 and tested bit is set.
#   Z_FLAG set if the tested bit is clear.
#   H_FLAG always set.
#   PV_FLAG set just like ZF flag.
#   N_FLAG always clear.
#   C_FLAG unchanged.
#
# The effects on X3_FLAG and X5_FLAG of BIT n, (IX+a) instructions
# are also described, but not BIT n, (IY+a) instructions. However
# the FUSE emulator tests suggest the latter instructions affect the
# X3/X5 flags the same way as the former instructions, so I'll go
# with that unless I'm proved wrong:
#
#   X3 = bit 3 of MSB of address IY+a
#   X5 = bit 5 of MSB of address IY+a


# Test printer in use.

po_fetch_printer_setup:
  _setbit 1, FLAGS
  _strb   0x3, P_POSN_X
  _strh   0x3421, PR_CC
  ret

po_fetch_printer_effects_regs:
  ld      c, 0x3
  ld      hl, 0x3421
  f_clear_set  S_FLAG|Z_FLAG|X5_FLAG|PV_FLAG|N_FLAG, X3_FLAG|H_FLAG
  ret


# Test upper screen in use.

po_fetch_upper_screen_setup:
  _resbit 1, FLAGS
  _resbit 0, TV_FLAG
  _strh   0x352f, S_POSN_X
  _strh   0x1bce, DF_CC
  ret

po_fetch_upper_screen_effects_regs:
  ld      bc, 0x352f
  ld      hl, 0x1bce
  f_clear_set  S_FLAG|X5_FLAG|N_FLAG, X3_FLAG|H_FLAG|Z_FLAG|PV_FLAG
  ret


# Test lower screen in use.

po_fetch_lower_screen_setup:
  _resbit 1, FLAGS
  _setbit 0, TV_FLAG
  _strh   0xe256, S_POSN_X_L
  _strh   0x523c, DF_CC_L
  ret

po_fetch_lower_screen_effects_regs:
  ld      bc, 0xe256
  ld      hl, 0x523c
  f_clear_set  S_FLAG|Z_FLAG|X5_FLAG|PV_FLAG|N_FLAG, X3_FLAG|H_FLAG
  ret
