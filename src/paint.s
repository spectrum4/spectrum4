# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.align 2
.text

# On entry:
#   w0 = colour to paint border
paint_border:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Push x19, x20 on the stack so x19 can be used in this function.
  mov     w19, w0                         // w19 = w0 (colour to paint border)
  mov     w0, 0                           // Paint rectangle from 0,0 (top left of screen) with width
  mov     w1, 0                           // SCREEN_WIDTH and height BORDER_TOP in colour w19 (border colour).
  mov     w2, SCREEN_WIDTH                // This is the border across the top of the screen.
  mov     w3, BORDER_TOP
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, 0                           // Paint left border in border colour. This starts below the top
  mov     w1, BORDER_TOP                  // border (0, BORDER_TOP) and is BORDER_LEFT wide and stops above
  mov     w2, BORDER_LEFT                 // the bottom border (drawn later in function).
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, SCREEN_WIDTH-BORDER_RIGHT   // Paint the right border in border colour. This also starts below
  mov     w1, BORDER_TOP                  // the top border, but on the right of the screen, and is
  mov     w2, BORDER_RIGHT                // BORDER_RIGHT wide. It also stops immediately above bottom border.
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, 0                           // Paint the bottom border in border colour. This is BORDER_BOTTOM
  mov     w1, SCREEN_HEIGHT-BORDER_BOTTOM // high, and is as wide as the screen.
  mov     w2, SCREEN_WIDTH
  mov     w3, BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  ldp     x19, x20, [sp], #0x10           // Restore x19 so no calling function is affected.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# On entry:
#   w0 = x
#   w1 = y
#   w2 = width (pixels)
#   w3 = height (pixels)
#   w4 = colour
paint_rectangle:
  adr     x9, mbreq                       // x9 = address of mailbox request.
  ldr     w10, [x9, framebuffer-mbreq]    // w10 = address of framebuffer
  ldr     w11, [x9, pitch-mbreq]          // w11 = pitch
  umaddl  x10, w1, w11, x10               // x10 = address of framebuffer + y*pitch
  add     w10, w10, w0, lsl #2            // w10 = address of framebuffer + y*pitch + x*4
  fill_rectangle:                         // Fills entire rectangle
    mov     w12, w10                      // w12 = reference to start of line
    mov     w13, w2                       // w13 = width of line
    fill_line:                            // Fill a single row of the rectangle with colour.
      str     w4, [x10], 4                // Colour current point, and update x10 to next point.
      subs    w13, w13, 1                 // Decrease horizontal pixel counter.
      b.ne    fill_line                   // Repeat until line complete.
    add     w10, w12, w11                 // x10 = start of current line + pitch = start of new line.
    subs    w3, w3, 1                     // Decrease vertical pixel counter.
    b.ne    fill_rectangle                // Repeat until all framebuffer lines complete.
  ret

# On entry:
#   w0 = colour to paint main screen
paint_window:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     w4, w0                          // Paint a single rectange that fills the gap inside the
  mov     w0, BORDER_LEFT                 // four borders of the screen.
  mov     w1, BORDER_TOP
  mov     w2, SCREEN_WIDTH-BORDER_LEFT-BORDER_RIGHT
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  bl      paint_rectangle
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

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
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x0, x1, [sp, #-16]!
  stp     x2, x3, [sp, #-16]!
  str     x4, [sp, #-16]!
  bl      uart_puts
  bl      uart_newline
  ldr     x4, [sp], #0x10
  ldp     x2, x3, [sp], #0x10
  ldp     x0, x1, [sp], #0x10
  adr     x9, mbreq                       // x9 = address of mailbox request.
  ldr     w10, [x9, framebuffer-mbreq]    // w10 = address of framebuffer
  ldr     w9, [x9, pitch-mbreq]           // w9 = pitch
  adr     x11, chars-32*32                // x11 = theoretical start of character table for char 0
//   ldr     x11, [x28, CHARS-sysvars]       // x11 = theoretical start of character table for char 0
1:
  ldrb    w12, [x0], 1                    // w12 = char from string, and update x0 to next char
  cbz     w12, 2f                         // if found end marker, jump to end of function and return
  add     x13, x11, x12, lsl #5           // x13 = address of character bitmap
  mov     w14, BORDER_TOP                 // w14 = BORDER_TOP
  add     w14, w14, w2, lsl #4            // w14 = BORDER_TOP + y * 16
  mov     w15, BORDER_LEFT                // w15 = BORDER_LEFT
  add     w15, w15, w1, lsl #4            // w15 = BORDER_LEFT + x * 16
  add     w15, w10, w15, lsl #2           // w15 = address of framebuffer + 4* (BORDER_LEFT + x * 16)
  umaddl  x14, w9, w14, x15               // w14 = pitch*(BORDER_TOP + y * 16) + address of framebuffer + 4 * (BORDER_LEFT + x*16)
  mov     w15, 16                         // w15 = y counter
  paint_char:
    mov     w16, w14                      // w16 = leftmost pixel of current row address
    mov     w12, 1 << 15                  // w12 = mask for current pixel
    ldrh    w17, [x13], 2                 // w17 = bitmap for current row, and update x13 to next bitmap pattern
    paint_line:                           // Paint a horizontal row of pixels of character
      tst     w17, w12                    // apply pixel mask
      csel    w18, w3, w4, ne             // if pixel set, colour w3 (ink colour) else colour w4 (paper colour)
      str     w18, [x14], 4               // Colour current point, and update x14 to next point.
      lsr     w12, w12, 1                 // Shift bit mask to next pixel
      cbnz    w12, paint_line             // Repeat until line complete.
    add     w14, w16, w9                  // x14 = start of current line + pitch = start of new line.
    subs    w15, w15, 1                   // Decrease vertical pixel counter.
    b.ne    paint_char                    // Repeat until all framebuffer lines complete.
  add     w1, w1, 1                       // Increment w1 (x print position) so that the next char starts to the right of the current char.
  b       1b                              // Repeat outer loop.
2:
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

paint_copyright:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, msg_copyright               // x0 = location of system copyright message.
  mov     w1, 38                          // Print at x=38.
  mov     w2, 40                          // Print at y=40.
  movl    w3, INK_COLOUR                  // Ink colour is default system ink colour.
  movl    w4, PAPER_COLOUR                // Paper colour is default system paper colour.
  bl      paint_string                    // Paint the copyright string to screen.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret
