# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# Print zero byte delimited string stored at memory location x0 to current channel.
# On entry:
#   x2 = address of zero byte delimited string
print_message:                           // L057D
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  b       2f
  1:
    bl      print_w0
  2:
    ldrb    w0, [x2], #1
    cbnz    w0, 1b
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
