.text
.align 2
# -------------------------
# Print spaces up to column
# -------------------------
# Keep printing a space character until cursor x position = (w4%108). If at
# least one space is printed, set system flag to suppress leading spaces.
#
# On entry:
#   w4 = new x character position plus arbitrary multiple of 108 (0-65535)
po_fill:                                 // L0AC3
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      po_fetch
  add     w6, w4, w1                              // w6 = newx + 109 - oldx
  sub     w6, w6, #1                              // w6 = 108 + newx - oldx
  mov     w2, #0x00010000
  movk    w2, #0x00002f69                         // w2 = 77673
  umull   x3, w6, w2                              // x3 = (108 + newx - oldx) * 77673
  lsr     x3, x3, #23                             // x3 = (108 + newx - oldx) * 77673 / 8388608
                                                  //    = (108 + newx - oldx) / 108
  mov     w5, #108
  umsubl  x2, w5, w3, x6                          // x2 = x6 - w5*w3 = (108 + newx - oldx) % 108
                                                  //    = (newx - oldx) % 108
                                                  //    = number of spaces to print
  cbz     x2, 3f                                  // Exit if no spaces to print.
  ldrb    w6, [x28, FLAGS-sysvars]                // w6 = [FLAGS]
  orr     w6, w6, #0x1                            // Set bit 0 (signal suppress leading space)
  strb    w6, [x28, FLAGS-sysvars]                // [FLAGS] = w6
  // Loop to print chr$ 128 (w19+1) times.
  2:
    mov     x0, ' '                               // x0 = space character (' ')
    bl      print_w0                              // Print it.
    subs    w2, w2, #1                            // Decrement counter.
    b.ne    2b                                    // Repeat while counter != 0
3:
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
