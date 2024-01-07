# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# On entry:
# On exit:
reset_indentation:                       // L35BC
  mov     w0, #0x0501
  strh    w0, [x28, FD6A-sysvars]
  ret
