# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text

# -------------------
# -------------------
# On entry:
#   w19 = start y
#   w20 = start x
#   w21 = y delta for next pixel
#   w22 = x delta for next pixel
#   w23 = number of pixels
# On exit:


.align 2
plot_line:                               // L3719
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  1:
    mov     w12, w19
    mov     w13, w20
    bl      plot_sub_1
    add     w19, w19, w21
    add     w20, w20, w22
    subs    w23, w23, #1
    b.ne    1b
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
