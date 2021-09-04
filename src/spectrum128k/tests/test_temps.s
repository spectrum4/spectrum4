# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


temps_chan_k_setup:
  _strb   0x34, BORDCR
  _strb   0b10010110, P_FLAG
  _setbit 0, TV_FLAG

temps_chan_k_effects:
  _strb   0x34, ATTR_T
  _strb   0, MASK_T
  _strb   0b10000010, P_FLAG
  ret

temps_chan_k_effects_regs:
  ld      a, 0b10000010
  ld      hl, P_FLAG
  ldf     S_FLAG|PV_FLAG
  ret


temps_chan_s_setup:
  _strb   0x3c, ATTR_P
  _strb   0x2b, MASK_P
  _strb   0b00011100, P_FLAG
  _resbit 0, TV_FLAG

temps_chan_s_effects:
  _strb   0x3c, ATTR_T
  _strb   0x2b, MASK_T
  _strb   0b00001100, P_FLAG
  ret

temps_chan_s_effects_regs:
  ld      a, 0b00001100
  ld      hl, P_FLAG
  ldf     X3_FLAG|PV_FLAG
  ret
