# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text
.align 2


rand_init:
  mov     x1, #0x4000
  movk    x1, #0x3f10, lsl #16
  mov     w0, #0x40000
  str     w0, [x1, #0x04]                 // [0x3f104004] = 0x00040000
  ldr     w0, [x1, #0x10]
  orr     w0, w0, #0x01
  str     w0, [x1, #0x10]                 // Set bit 0 of [0x3f104010]
  ldr     w0, [x1]
  orr     w0, w0, #0x01
  str     w0, [x1]                        // Set bit 0 of [0x3f104000]
  1:                                      // Wait until ([0x3f104010] >> 24) != 0
    ldr     w0, [x1, #0x04]
    lsr     w0, w0, #24
    cbz     w0, 1b
  ret


rand:
  mov     x0, #0x4008
  movk    x0, #0x3f10, lsl #16            // x0 = 0x3f104008
  ldr     w0, [x0]                        // w0 = [0x3f104008]
  ret
