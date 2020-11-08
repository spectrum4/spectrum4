# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text
.align 2

# This code is inspired by https://github.com/torvalds/linux/blob/d4f6d923238dbdb69b8525e043fedef2670d4f2c/drivers/char/hw_random/bcm2835-rng.c


rand_init:
  mov     x1, #0x4000
  movk    x1, #0x3f10, lsl #16
  mov     w0, #0x40000                    // "warmup count": the initial numbers generated are "less random" so will be discarded
  str     w0, [x1, #0x04]                 // [0x3f104004] = 0x00040000
  ldr     w0, [x1, #0x10]
  orr     w0, w0, #0x01
  str     w0, [x1, #0x10]                 // Set bit 0 of [0x3f104010]  (mask the interrupt)
  ldr     w0, [x1]
  orr     w0, w0, #0x01
  str     w0, [x1]                        // Set bit 0 of [0x3f104000]  (enable the hardware generator)
  ret


rand_x0:
  mov     x1, #0x4000
  movk    x1, #0x3f10, lsl #16            // x1 = 0x3f104000
  1:                                      // Wait until ([0x3f104004] >> 24) >= 2
    ldr     w0, [x1, #0x04]                 // Since bits 24-31 tell us how many words
    lsr     w0, w0, #25                     // are available, this must be at least one,
    cbz     w0, 1b                          // before we can safely read two words.
  ldr     w0, [x1, #0x08]                 // w0 = [0x3f104008] (random data)
  ldr     w2, [x1, #0x08]                 // w2 = [0x3f104008] (random data)
  bfi     x0, x2, #32, #32                // Copy bits from w2 into high bits of x0.
  ret


# Write random data to a buffer.
#
# On entry:
#   x0 = address of buffer (4 byte aligned)
#   x1 = size of buffer (multiple of 4 bytes)
# On exit:
#   x0 = first address after buffer
#   x1 = 0
#   x2 = 0x3f104000
#   x3 = last random word written to buffer
rand_block:
  and     x0, x0, #~0b11
  and     x1, x1, #~0b11
  mov     x2, #0x4000
  movk    x2, #0x3f10, lsl #16            // x2 = 0x3f104000
  1:                                      // Loop until buffer filled
    2:                                      // Wait until ([0x3f104004] >> 24) >= 1
      ldr     w3, [x2, #0x04]                 // Since bits 24-31 tell us how many words
      lsr     w3, w3, #24                     // are available, this must be at least one.
      cbz     w3, 2b
    ldr     w3, [x2, #0x08]                 // w3 = [0x3f104008] (random data)
    str     w3, [x0], #0x04                 // Write to buffer.
    subs    x1, x1, #0x04
    cbnz    x1, 1b
  ret
