# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


co_temp_5_1_setup:
  ret

co_temp_5_1_setup_regs:
  ld      a, 0x11                         ; PAPER
  ld      d, 0x00                         ; 0
  ret

co_temp_5_1_effects:
  _strb   0xc2, ATTR_T                    ; TODO: depends on initial values
  _strb   0xc2, MASK_T                    ; TODO: depends on initial values
  _strb   0x8a, P_FLAG                    ; TODO: depends on initial values
  ret

co_temp_5_1_effects_regs:
  ldf     0x88                            ; TODO: depends on intial values
  ld      a, 0x40
  ld      c, 0x00
  ld      b, 0x40
  ld      hl, P_FLAG+1                    ; (MEMBOT)
  ret
