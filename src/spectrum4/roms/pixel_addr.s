# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text

# -----------------
# Get Pixel Address
# -----------------
#
# On entry:
#   x12 = y (0 to 927)
#   x13 = x (0 to 1727)
# On exit:
#   x11 = display_file + 216*(20*(16*((927-y)/320)+(((927-y)%320)&0x0f))+((927-y)%320>>4))+x/8
#   x12 = display_file
#   x14 = x%8


.align 2
pixel_addr:                              // L22AA
  mov     x11, 927
  sub     x12, x11, x12                           // x12 = 927-y
  mov     x11, #0xcccd000000000000                // x11 = 14757451553962983424
  umulh   x14, x11, x12                           // x14 = 14757451553962983424 * (927-y) / 2^64 = (4/5) * (927-y)
  lsr     x14, x14, #8                            // x14 = int((927-y)/320)
  add     x11, x14, x14, lsl #2                   // x11 = 5 * int((927-y)/320)
  sub     x11, x12, x11, lsl #6                   // x11 = (927-y) - 320 * int((927-y)/320) = (927-y)%320
  lsl     x14, x14, #4                            // x14 = 16*((927-y)/320)
  bfxil   x14, x11, #0, #4                        // x14 = 16*((927-y)/320) + (((927-y)%320)&0x0f) = 16*((927-y)/320) + ((927-y)&0x0f)
  add     x14, x14, x14, lsl #2                   // x14 = 5*(16*((927-y)/320) + ((927-y)&0x0f))
  lsl     x14, x14, #2                            // x14 = 20*(16*((927-y)/320)+((927-y)&0x0f))
  add     x14, x14, x11, lsr #4                   // x14 = 20*(16*((927-y)/320)+((927-y)&0x0f))+((927-y)%320>>4)
  add     x11, x14, x14, lsl #3                   // x11 = 9*(20*(16*((927-y)/320)+((927-y)&0x0f))+((927-y)%320>>4))
  lsl     x11, x11, #3                            // x11 = 72*(20*(16*((927-y)/320)+((927-y)&0x0f))+((927-y)%320>>4))
  add     x11, x11, x11, lsl #1                   // x11 = 216*(20*(16*((927-y)/320)+((927-y)&0x0f))+((927-y)%320>>4))
  adrp    x12, display_file
  add     x12, x12, :lo12:display_file            // x12 = display_file
  add     x11, x11, x12                           // x11 = display_file + 216*(20*(16*((927-y)/320)+((927-y)&0x0f))+((927-y)%320>>4))
  add     x11, x11, x13, lsr #3                   // x11 = display_file + 216*(20*(16*((927-y)/320)+((927-y)&0x0f))+((927-y)%320>>4))+x/8)
  and     x14, x13, #0x07                         // x14 = x13%8
  ret
