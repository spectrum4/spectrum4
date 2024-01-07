# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2


# On entry:
#   x0 = hex value to convert to text
#   x1 = address to write text to (no trailing 0)
#   x2 = number of bits to print (multiple of 4)
# On exit:
#   x1 = address of next unused char (x1 += x2/4)
hex_x0:
  ror     x0, x0, x2
1:
  ror     x0, x0, #60
  and     w3, w0, #0x0f
  add     w3, w3, 0x30
  cmp     w3, 0x3a
  b.lo    2f
  add     w3, w3, 0x27
2:
  strb    w3, [x1], #1
  subs    w2, w2, #4
  b.ne    1b
  ret
