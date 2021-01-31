# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.


.text
.align 2


poke_address_1_setup:
  ret


poke_address_1_setup_regs:
  adrp x0, poke_address_test
  add x0, x0, :lo12:poke_address_test
  mov x1, #~0
  ret


poke_address_1_effects:
  ret


poke_address_1_effects_regs:
  ret


poke_address_2_setup:
  ret


poke_address_2_setup_regs:
  adr x0, display_file + 3456
  mov x1, #34
  ret


poke_address_2_effects:
  ret


poke_address_2_effects_regs:
  ret


poke_address_3_setup:
  ret


poke_address_3_setup_regs:
  adr x0, attributes_file + 3456
  mov x1, #78
  ret


poke_address_3_effects:
  ret


poke_address_3_effects_regs:
  ret


.bss
.align 0
poke_address_test: .space 1
