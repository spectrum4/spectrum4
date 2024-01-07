# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.include "screen.s"

.text
.align 2

demo:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  bl      paint_copyright                         // Paint the copyright text ((C) 1982 Amstrad....)
  mov     w0, 0x400000
  bl      wait_usec
  bl      display_zx_screen
  mov     w0, 0x400000
  bl      wait_usec
  movl    w0, PAPER_COLOUR
  bl      paint_window
  mov     x0, sp
  mov     x1, #1
  mov     x2, #0
  bl      display_memory
  adrp    x0, fb_req
  add     x0, x0, :lo12:fb_req
  mov     x1, #5
  mov     x2, #3
  bl      display_memory
  mov     x0, x28                                 // x0 = sysvars
  mov     x1, #10
  mov     x2, #10
  bl      display_memory
  adrp    x0, heap
  add     x0, x0, #:lo12:heap                     // x0 = heap
  sub     x0, x0, #0x60
  mov     x1, #8
  mov     x2, #22
  bl      display_memory
  add     x0, x28, STRMS-sysvars
  mov     x1, #2
  mov     x2, #32
  bl      display_memory
  ldr     x0, [x28, CHANS-sysvars]
  mov     x1, #2
  mov     x2, #36
  bl      display_memory
  bl      display_sysvars
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


paint_copyright:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adrp    x0, msg_demo_copyright
  add     x0, x0, :lo12:msg_demo_copyright        // x0 = location of demo copyright message.
  mov     w1, 38                                  // Print at x=38.
  mov     w2, 40                                  // Print at y=40.
  movl    w3, INK_COLOUR                          // Ink colour is default system ink colour.
  movl    w4, PAPER_COLOUR                        // Paper colour is default system paper colour.
  bl      paint_string                            // Paint the copyright string to screen.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x0 = start address
#   x1 = number of rows to print
#   x2 = screen line to start at
display_memory:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Store old x19, x20 on the the stack.
  stp     x21, x22, [sp, #-16]!                   // Store old x21, x22 on the the stack.
  stp     x23, x24, [sp, #-16]!                   // Store old x23, x24 on the the stack.
  sub     sp, sp, #112                            // 112 bytes for screen line buffer
  mov     x19, x0                                 // x19 = start address
  mov     x20, x1                                 // x20 = number of rows to print
  mov     x21, x2                                 // x21 = screen line to start at
  mov     w23, #0x2020                            // two spaces ('  ')
  adr     x0, msg_hex_header                      // Pointer to string
  mov     w1, #0                                  // x coordinate
  mov     w3, #0x00ffffff                         // white ink
  mov     w4, #0x000000cc                         // (dark) blue paper
  bl      paint_string                            // paint hex header line
  add     x21, x21, #1                            // x21 = first data line screen line
1:
  mov     x1, sp                                  // address to write text string to
  strh    w23, [x1], #2                           // write '  ' to screen line buffer on stack
  mov     x0, x19                                 // x0 = dump address
  mov     x2, #32
  bl      hex_x0                                  // append to screen line buffer and update x1
  mov     x22, #0x20                              // 32 values to print
2:
  strb    w23, [x1], #1                           // write ' ' to screen line buffer
  ldrb    w0, [x19], #1                           // w0 = data at address, bump address x19
  mov     x2, #8
  bl      hex_x0
  subs    x22, x22, #1
  b.ne    2b
  strh    w23, [x1], #2                           // write '  ' to screen line buffer
  strb    wzr, [x1], #1                           // append 0 byte to terminate string
  mov     x0, sp
  mov     w1, #0                                  // x = 0
  mov     x2, x21                                 // y = line number
  mov     w3, #0x00ffffff                         // white ink
  mov     w4, #0x000000cc                         // (dark) blue paper
  bl      paint_string                            // paint string
  add     x21, x21, #1                            // increase line number
  subs    x20, x20, #1
  b.ne    1b                                      // if not, process next line
  add     sp, sp, #112                            // Free screen line buffer
  ldp     x23, x24, [sp], #0x10                   // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10                   // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


display_zx_screen:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adrp    x9, ZX_SCREEN
  add     x9, x9, :lo12:ZX_SCREEN
  adrp    x0, display_file
  add     x0, x0, :lo12:display_file
1:
  ldrb    w1, [x9], #1
  stp     x0, x9, [sp, #-16]!
  bl      poke_address
  ldp     x0, x9, [sp], #16
  add     x0, x0, #1
  adrp    x2, attributes_file_end
  add     x2, x2, :lo12:attributes_file_end
  cmp     x0, x2
  b.ne    1b
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

msg_hex_header:                .asciz "           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f  "
msg_demo_copyright:                      // L0561
  .byte 0x7f                                      // '(c)'.
  .asciz " 2022 Spectrum +4 Demo Authors"
