# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text
.align 2


# Converts a uint64 value to ASCII decimal representation. The caller must
# provide a buffer of at least 21 bytes. The result will be written to the end of
# the buffer, including a trailing 0 byte. The start address will be returned.
#
# On entry:
#   x0 = address of 21 (or more) byte buffer to write to
#   x2 = value to convert to decimal
# On exit:
#   x0 = address of start of string within buffer
#   x2 = 0
#   x3 = 0xcccccccccccccccd
#   x4 = 0
#   x5 = first byte of generated string
base10:
  add     x0, x0, #0x14                   // x0 = address of last allocated byte
  strb    wzr, [x0]                       // Store 0 in last allocated byte
  mov     x3, #0xcccccccccccccccc
  add     x3, x3, #1                      // x3 = constant for divison by 10
  1:
    umulh   x4, x3, x2
    lsr     x4, x4, #3                      // x4 = x2 / 10
    add     x5, x4, x4, lsl #2              // x5 = 5 * x4
    sub     x2, x2, x5, lsl #1              // x2 = x2 % 10 = value of last digit
    add     x5, x2, #0x30                   // x5 = ASCII value of digit = x2 + 48
    strb    w5, [x0, #-1]!                  // store ASCII value on stack at correct offset
    mov     x2, x4                          // x2 = previous x2 / 10
    cbnz    x2, 1b                          // if x2 != 0 continue looping
3:
  ret
