# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.text
.align 2


.if ROMS_INCLUDE
.else
  .include "print_w0.s"
.endif


display_sysvar_1_setup:
  _strb   0x93, WIDTH
  ret


display_sysvar_1_setup_regs:
  adr     x20, sysvar_WIDTH
  ret


display_sysvar_1_effects_regs:
  sub     x0, sp, #61
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
  adr     x20, sysvar_TVDATA
  ret


display_sysvar_2_effects_regs:
  sub     x0, sp, #59
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
  adr     x20, sysvar_ERR_SP
  ret


display_sysvar_8_effects_regs:
  sub     x0, sp, #47
  movl    w1, AUX_BASE
  mov     x2, #0
  mov     x3, AUX_MU_LSR_DATA_READY
  ldr     x4, =0x1324354657687980
  nzcv    #0b1000
  ret


display_sysvar_other_setup_regs:
  adr     x20, sysvar_MEMBOT
  ret


display_sysvar_other_effects_regs:
  sub     x0, sp, #60
  movl    w1, AUX_BASE
  mov     x2, #0
  mov     x3, AUX_MU_LSR_DATA_READY
  nzcv    #0b0110
  ret
