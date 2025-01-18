# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2


# paint_string paints the zero byte delimited text string pointed to by x0 to the screen in the
# system font (16x16 pixels) at the screen print coordinates given by w1, w2. The ink colour is
# taken from w3 and paper colour from w4.
#
# On entry:
#   x0 = pointer to string
#   w1 = x
#   w2 = y
#   w3 = ink colour
#   w4 = paper colour
paint_string:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x0, x1, [sp, #-16]!
  stp     x2, x3, [sp, #-16]!
  str     x4, [sp, #-16]!
  bl      uart_puts
  bl      uart_newline
  ldr     x4, [sp], #0x10
  ldp     x2, x3, [sp], #0x10
  ldp     x0, x1, [sp], #0x10
  adrp    x9, fb_req
  add     x9, x9, :lo12:fb_req                    // x9 = address of mailbox request.
  ldr     w10, [x9, framebuffer-fb_req]           // w10 = physical address of framebuffer
  orr     x10, x10, #0xfffffff000000000           // x10 = virtual address of framebuffer
  ldr     w9, [x9, pitch-fb_req]                  // w9 = pitch
  adrp    x11, char_set-32*32
  add     x11, x11, :lo12:(char_set-32*32)        // x11 = theoretical start of character table for char 0
  1:
    ldrb    w12, [x0], 1                          // w12 = char from string, and update x0 to next char
    cbz     w12, 4f                               // if found end marker, jump to end of function and return
    add     x13, x11, x12, lsl #5                 // x13 = address of character bitmap
    mov     w14, BORDER_TOP                       // w14 = BORDER_TOP
    add     w14, w14, w2, lsl #4                  // w14 = BORDER_TOP + y * 16
    mov     w15, BORDER_LEFT                      // w15 = BORDER_LEFT
    add     w15, w15, w1, lsl #4                  // w15 = BORDER_LEFT + x * 16
    add     x15, x10, x15, lsl #2                 // x15 = address of framebuffer + 4* (BORDER_LEFT + x * 16)
    umaddl  x14, w9, w14, x15                     // x14 = pitch*(BORDER_TOP + y * 16) + address of framebuffer + 4 * (BORDER_LEFT + x*16)
    mov     w15, 16                               // w15 = y counter
    2:                                            // Paint char
      mov     x16, x14                            // x16 = leftmost pixel of current row address
      mov     w12, 0x800080                       // w12 = mask for current pixel
      ldrh    w17, [x13], 2                       // w17 = bitmap for current row, and update x13 to next bitmap pattern
      3:                                          // Paint a horizontal row of pixels of character
        tst     w17, w12                          // apply pixel mask
        csel    w18, w3, w4, ne                   // if pixel set, colour w3 (ink colour) else colour w4 (paper colour)
        str     w18, [x14], 4                     // Colour current point, and update x14 to next point.
        lsr     w12, w12, 1                       // Shift bit mask to next pixel
        cmp     w12, 0x80
        b.ne    3b
      add     x14, x16, x9                        // x14 = start of current line + pitch = start of new line.
      subs    w15, w15, 1                         // Decrease vertical pixel counter.
      b.ne    2b
    add     w1, w1, 1                             // Increment w1 (x print position) so that the next char starts to the right of the current char.
    b       1b                                    // Repeat outer loop.
4:
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
