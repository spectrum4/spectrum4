# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text

# -------------------
# The Plot subroutine
# -------------------
# A screen byte holds 8 pixels so it is necessary to rotate a mask
# into the correct position to leave the other 7 pixels unaffected.
# However all 256 pixels in the character cell take any embedded colour
# items.
# A pixel can be reset (inverse 1), toggled (over 1), or set (with inverse
# and over switches off). With both switches on, the byte is simply put
# back on the screen though the colours may change.
#
# On entry:
#   x12 = y (0 to 927)
#   x13 = x (0 to 1727)
# On exit:


.align 2
plot_sub_1:                              // L22E9
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      pixel_addr                              // x11 = display file address, x14 = x & 0x07
  mov     x0, x11                                 // x0 = display file address (needed in x0 for po_attr)
  mov     w12, 0x80                               // w12 = mask for leftmost pixel of display file byte
  lsr     w12, w12, w14                           // w12 = mask for pixel bit (7-w14)
  ldrb    w13, [x28, P_FLAG-sysvars]              // w13 = [P_FLAG]
  ldrb    w14, [x0]                               // w14 = current display file value
  tbnz    w13, #0, 1f
// OVER 0
  tbnz    w13, #2, 2f
// OVER 0, INVERSE 0
  orr     w14, w14, w12
  b       3f
// OVER 1
1:
  tbnz    w13, #2, 4f
// OVER 1, INVERSE 0
  eor     w14, w14, w12
  b       3f
// OVER 0, INVERSE 1
2:
  bic     w14, w14, w12
3:
  strb    w14, [x0]
4:
  bl      po_attr
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
