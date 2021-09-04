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

chan_s_01_setup:
  _strb   0x3c, ATTR_P
  _strb   0x2b, MASK_P
  _strb   0b00011100, P_FLAG

chan_s_01_effects:
  _resbit 0, TV_FLAG
  _resbit 1, FLAGS
  _strb   0x3c, ATTR_T
  _strb   0x2b, MASK_T
  _strb   0b00001100, P_FLAG
  ret

chan_s_01_effects_regs:
  mov     x0, 0b00001100
  ldr     w1, =0x2b3c
  mov     x2, 0b00000100
  ret
