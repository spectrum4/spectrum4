# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text

.align 2
chan_s_01_setup:
  _strb   0x3c, ATTR_P
  _strb   0x2b, MASK_P
  _strb   0b00011100, P_FLAG

.align 2
chan_s_01_effects:
  _resbit 0, TV_FLAG
  _resbit 1, FLAGS
  _strb   0x3c, ATTR_T
  _strb   0x2b, MASK_T
  _strb   0b00001100, P_FLAG
  ret

.align 2
chan_s_01_effects_regs:
  ld      a, 0b00001100
  ld      hl, P_FLAG
  ldf     X3_FLAG|PV_FLAG
  ret
