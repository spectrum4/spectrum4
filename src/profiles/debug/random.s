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


rand:
  mov     x1, #0x4000
  movk    x1, #0x3f10, lsl #16            // x1 = 0x3f104000
  1:                                      // Wait until ([0x3f104004] >> 24) != 0
    ldr     w0, [x1, #0x04]               // since bits 24-31 tell us how many
    lsr     w0, w0, #24                   // words are available, and this must
    cbz     w0, 1b                        // be at least one, before we read it.
  ldr     w0, [x1, #0x08]                 // w0 = [0x3f104008] (random data)
  ret
