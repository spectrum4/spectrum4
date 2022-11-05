# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.if ROMS_INCLUDE
.else
  .include "print_w0.s"
.endif


.text
.align 2


display_sysvars_1_setup:
  _str    0x0716253443526170, F6EC
  ret


# x0: 0x0a
# x1: [aux_base]
# x2: [AUX_MU_LSR] = 0x21 / 0x61 (see page 15 of BCM ARM2835/7 ARM Peripherals) when waiting to send final newline
# x3: [AUX_MU_LSR] = 0x21 / 0x61 (see page 15 of BCM ARM2835/7 ARM Peripherals) when waiting to write final sysvar value
# x4: value of last logged 1/2/4/8 byte sysvar (currently [K_CUR])
# NZCV: depends on size of last sysvar, currently last sysvar is MEMBOT, so 0b0110
#   if last sysvar is 1/2/4/8 byte sysvar: 0b1000
#   otherwise: 0b0110
display_sysvars_1_effects_regs:
  mov     x0, #0x0a
  adr     x1, aux_base
  ldr     x1, [x1]
  movl    x2, 0x12323434
  movl    x3, 0x75364253
  ldr     x4, =0x0716253443526170
  nzcv    #0b0110
  ret
