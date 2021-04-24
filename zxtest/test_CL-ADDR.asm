# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text

test_CL_ADDR_1_setup_regs:
  ld      b, 0x0b
  ret

test_CL_ADDR_1_effects_regs:
  ld      a, 0x48
  ld      d, 0x0d
  ld      l, 0xa0
  ld      h, 0x48
  ret
