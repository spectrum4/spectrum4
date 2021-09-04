# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2


.if ROMS_INCLUDE
.else
  .include "print_w0.s"
  .include "temps.s"
.endif


chan_k_01_setup:
  _strb   0x34, BORDCR
  _strb   0b10010110, P_FLAG

chan_k_01_effects:
  _resbit 1, FLAGS
  _resbit 5, FLAGS
  _setbit 4, FLAGS2
  _setbit 0, TV_FLAG
  _strb   0x34, ATTR_T
  _strb   0, MASK_T
  _strb   0b10000010, P_FLAG
  ret

chan_k_01_effects_regs:
  mov     x0, 0b10000010
  mov     x1, 0x34
  ldrb    w9, [x28, FLAGS2-sysvars]
  ret
