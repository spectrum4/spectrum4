# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.if ROMS_INCLUDE
.else
  .include "print_w0.s"
.endif


.text
.align 2


display_sysvar_1_setup:
  _strb   0x93, WIDTH
  ret


display_sysvar_1_setup_regs:
  adrp    x20, sysvar_WIDTH
  add     x20, x20, :lo12:sysvar_WIDTH
  ret


display_sysvar_1_effects_regs:
  sub     x0, sp, #0x5d
  movl    w1, AUX_BASE
  mov     x2, #0
  mov     x3, AUX_MU_LSR_DATA_READY
  mov     x4, #0x93
  nzcv    #0b1000
  ret


display_sysvar_2_setup:
  _strh   0x3945, TVDATA
  ret


display_sysvar_2_setup_regs:
  adrp    x20, sysvar_TVDATA
  add     x20, x20, :lo12:sysvar_TVDATA
  ret


display_sysvar_2_effects_regs:
  sub     x0, sp, #0x5b
  movl    w1, AUX_BASE
  mov     x2, #0
  mov     x3, AUX_MU_LSR_DATA_READY
  mov     x4, #0x3945
  nzcv    #0b1000
  ret


display_sysvar_8_setup:
  _str    0x1324354657687980, ERR_SP
  ret


display_sysvar_8_setup_regs:
  adrp    x20, sysvar_ERR_SP
  add     x20, x20, :lo12:sysvar_ERR_SP
  ret


display_sysvar_8_effects_regs:
  sub     x0, sp, #0x4f
  movl    w1, AUX_BASE
  mov     x2, #0
  mov     x3, AUX_MU_LSR_DATA_READY
  ldr     x4, =0x1324354657687980
  nzcv    #0b1000
  ret


display_sysvar_other_setup_regs:
  adrp    x20, sysvar_MEMBOT
  add     x20, x20, :lo12:sysvar_MEMBOT
  ret


display_sysvar_other_effects_regs:
  sub     x0, sp, #0x5c
  movl    w1, AUX_BASE
  mov     x2, #0
  mov     x3, AUX_MU_LSR_DATA_READY
  nzcv    #0b0110
  ret
