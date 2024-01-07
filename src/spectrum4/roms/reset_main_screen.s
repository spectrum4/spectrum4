# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2

# ---------------------
# ---------------------
#
# On entry:
# On exit:
reset_main_screen:                       // L2E1F
  ldrb    w0, [x28, TV_FLAG-sysvars]
  and     w0, w0, 0xfe
  strb    w0, [x28, TV_FLAG-sysvars]
  mov     w1, 0x14
  strb    w1, [x28, EC15-sysvars]
  ret
