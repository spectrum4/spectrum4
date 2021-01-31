# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.


.text
.align 2


display_sysvar_1_setup:
  ret


display_sysvar_1_setup_regs:
  adr     x20, sysvar_MEMBOT
  ret


display_sysvar_1_effects:
  ret


display_sysvar_1_effects_regs:
  add     x0, sp, 0xc4
  movl    w1, AUX_BASE
  mov     x2, #0
  mov     x3, #0x21
  nzcv    #0b0110
  ret
