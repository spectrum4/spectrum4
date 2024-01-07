# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.text

# On entry:
#   w0 = colour to paint border
.align 2
paint_border:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Push x19, x20 on the stack so x19 can be used in this function.
  mov     w19, w0                                 // w19 = w0 (colour to paint border)
  mov     w0, 0                                   // Paint rectangle from 0,0 (top left of screen) with width
  mov     w1, 0                                   // SCREEN_WIDTH and height BORDER_TOP in colour w19 (border colour).
  mov     w2, SCREEN_WIDTH                        // This is the border across the top of the screen.
  mov     w3, BORDER_TOP
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, 0                                   // Paint left border in border colour. This starts below the top
  mov     w1, BORDER_TOP                          // border (0, BORDER_TOP) and is BORDER_LEFT wide and stops above
  mov     w2, BORDER_LEFT                         // the bottom border (drawn later in function).
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, SCREEN_WIDTH-BORDER_RIGHT           // Paint the right border in border colour. This also starts below
  mov     w1, BORDER_TOP                          // the top border, but on the right of the screen, and is
  mov     w2, BORDER_RIGHT                        // BORDER_RIGHT wide. It also stops immediately above bottom border.
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, 0                                   // Paint the bottom border in border colour. This is BORDER_BOTTOM
  mov     w1, SCREEN_HEIGHT-BORDER_BOTTOM         // high, and is as wide as the screen.
  mov     w2, SCREEN_WIDTH
  mov     w3, BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  ldp     x19, x20, [sp], #0x10                   // Restore x19 so no calling function is affected.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   w0 = x
#   w1 = y
#   w2 = width (pixels)
#   w3 = height (pixels)
#   w4 = colour
paint_rectangle:
  adr     x9, fb_req                              // x9 = address of mailbox request.
  ldr     w10, [x9, framebuffer-fb_req]           // w10 = physical address of framebuffer
  orr     x10, x10, #0xffff000000000000           // x10 = virtual address of framebuffer
  ldr     w11, [x9, pitch-fb_req]                 // w11 = pitch
  umaddl  x10, w1, w11, x10                       // x10 = address of framebuffer + y*pitch
  add     x10, x10, x0, lsl #2                    // x10 = address of framebuffer + y*pitch + x*4
  fill_rectangle:                                 // Fills entire rectangle
    mov     x12, x10                              // x12 = reference to start of line
    mov     w13, w2                               // w13 = width of line
    fill_line:                                    // Fill a single row of the rectangle with colour.
      str     w4, [x10], 4                        // Colour current point, and update x10 to next point.
      subs    w13, w13, 1                         // Decrease horizontal pixel counter.
      b.ne    fill_line                           // Repeat until line complete.
    add     x10, x12, x11                         // x10 = start of current line + pitch = start of new line.
    subs    w3, w3, 1                             // Decrease vertical pixel counter.
    b.ne    fill_rectangle                        // Repeat until all framebuffer lines complete.
  ret


# On entry:
#   w0 = colour to paint main screen
paint_window:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     w4, w0                                  // Paint a single rectange that fills the gap inside the
  mov     w0, BORDER_LEFT                         // four borders of the screen.
  mov     w1, BORDER_TOP
  mov     w2, SCREEN_WIDTH-BORDER_LEFT-BORDER_RIGHT
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  bl      paint_rectangle
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
