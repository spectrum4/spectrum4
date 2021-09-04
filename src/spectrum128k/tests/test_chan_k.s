# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text

.align 2
chan_k_01_setup:
  _strb   0x34, BORDCR
  _strb   0b10010110, P_FLAG

.align 2
chan_k_01_effects:
  _resbit 1, FLAGS
  _resbit 5, FLAGS
  _setbit 4, FLAGS2
  _setbit 0, TV_FLAG
  _strb   0x34, ATTR_T
  _strb   0, MASK_T
  _strb   0b10000010, P_FLAG
  ret

.align 2
chan_k_01_effects_regs:
  ld      a, 0b10000010
  ld      hl, P_FLAG
  ldf     S_FLAG|PV_FLAG
  ret
