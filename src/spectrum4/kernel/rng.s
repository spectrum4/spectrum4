# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


# These bcm283x hardware random number generator routines are inspired by:
#   https://github.com/torvalds/linux/blob/d4f6d923238dbdb69b8525e043fedef2670d4f2c/drivers/char/hw_random/bcm2835-rng.c


.align 2
rand_init_bcm283x:
  mov     x5, x30
.if       UART_DEBUG
  adr     x0, msg_init_rand
  bl      uart_puts
.endif
  movl    w1, 0x3f104000
  mov     w0, #0x00100000                         // "warmup count": the initial numbers generated are "less random" so will be discarded
                                                  // set this higher than in linux kernel, as results seem better with higher value
  str     w0, [x1, #0x04]                         // [0x3f104004] = 0x00100000
  ldr     w0, [x1, #0x10]
  orr     w0, w0, #0x01
  str     w0, [x1, #0x10]                         // Set bit 0 of [0x3f104010]  (mask the interrupt)
  ldr     w0, [x1]
  orr     w0, w0, #0x01
  str     w0, [x1]                                // Set bit 0 of [0x3f104000]  (enable the hardware generator)
.if       UART_DEBUG
  adr     x0, msg_done
  bl      uart_puts
.endif
  mov     x30, x5
  ret


rand_x0_bcm283x:
  movl    w1, 0x3f104000
  1:                                              // Wait until ([0x3f104004] >> 24) >= 1
    ldr     w0, [x1, #0x04]                       // Bits 24-31 tell us how many words
    lsr     w0, w0, #24                           // are available.
    cbz     w0, 1b                                // Try again if no words are available.
  ldr     w2, [x1, #0x08]                         // w0 = [0x3f104008] (random data)
  1:                                              // Wait until ([0x3f104004] >> 24) >= 1
    ldr     w0, [x1, #0x04]                       // Bits 24-31 tell us how many words
    lsr     w0, w0, #24                           // are available.
    cbz     w0, 1b                                // Try again if no words are available.
  ldr     w0, [x1, #0x08]                         // w2 = [0x3f104008] (random data)
  bfi     x0, x2, #32, #32                        // Copy bits from w2 into high bits of x0.
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
rand_block_bcm283x:
  and     x0, x0, #~0b11
  and     x1, x1, #~0b11
  movl    w2, 0x3f104000
  1:                                              // Loop until buffer filled
    2:                                            // Wait until ([0x3f104004] >> 24) >= 1
      ldr     w3, [x2, #0x04]                     // Since bits 24-31 tell us how many words
      lsr     w3, w3, #24                         // are available, this must be at least one.
      cbz     w3, 2b
    ldr     w3, [x2, #0x08]                       // w3 = [0x3f104008] (random data)
    str     w3, [x0], #0x04                       // Write to buffer.
    subs    x1, x1, #0x04
    cbnz    x1, 1b
  ret


# For iproc (bcm2711, used on rpi4/rpi400 etc), see
# https://github.com/raspberrypi/linux/blob/cc333a8a1e59968156c5312c7d375b702d7d73ac/drivers/char/hw_random/iproc-rng200.c#L176-L232


rand_init_iproc:
  mov     x5, x30
.if       UART_DEBUG
  adr     x0, msg_init_rand
  bl      uart_puts
.endif
  movl    w1, 0xfe104000
  mov     w0, #0x00100000                         // "warmup count": the initial numbers generated are "less random" so will be discarded
                                                  // set this higher than in linux kernel, as results seem better with higher value
  str     w0, [x1, #0x10]                         // [0xfe104010] = 0x00100000
  mov     w0, #0x00000200
  str     w0, [x1, #0x24]                         // [0xfe104024] = 0x00000200
  mov     w0, #0x00007fff
  str     w0, [x1]                                // [0xfe104000] = 0x00007fff
.if       UART_DEBUG
  adr     x0, msg_done
  bl      uart_puts
.endif
  mov     x30, x5
  ret


rand_x0_iproc:
  movl    w1, 0xfe104000
  1:                                              // Wait until [0xfe10400c] >= 16
    ldr     w0, [x1, #0x0c]
    cmp     w0, #16
    b.ls    1b
  2:
    ldrb    w0, [x1, #0x24]
    cmp     w0, #2
    b.lo    2b
  ldr     w0, [x1, #0x20]                         // w0 = [0xfe104008] (random data)
  ldr     w2, [x1, #0x20]                         // w2 = [0xfe104008] (random data)
  bfi     x0, x2, #32, #32                        // Copy bits from w2 into high bits of x0.
  ret


# Write random data to a buffer.
#
# On entry:
#   x0 = address of buffer (4 byte aligned)
#   x1 = size of buffer (multiple of 4 bytes)
# On exit:
#   x0 = first address after buffer
#   x1 = 0
#   x2 = 0xfe104000
#   x3 = last random word written to buffer
rand_block_iproc:
  and     x0, x0, #~0b11
  and     x1, x1, #~0b11
  movl    w2, 0xfe104000
  1:                                              // Wait until [0xfe10400c] >= 16
    ldr     w3, [x2, #0x0c]
    cmp     w3, #16
    b.ls    1b
  1:                                              // Loop until buffer filled
    2:                                            // Wait until ([0xfe104004] >> 24) >= 1
      ldrb    w3, [x2, #0x24]
      cbz     w3, 2b
    ldr     w3, [x2, #0x20]                       // w3 = [0xfe104008] (random data)
    str     w3, [x0], #0x04                       // Write to buffer.
    subs    x1, x1, #0x04
    cbnz    x1, 1b
  ret
