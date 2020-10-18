# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text
.align 2

display_sysvars:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // callee-saved registers used later on.
  stp     x21, x22, [sp, #-16]!           // callee-saved registers used later on.
  sub     sp, sp, #32                     // 32 bytes buffer for storing hex representation of sysvar (maximum is 16 chars + trailing 0, so 17 bytes)
  adr     x0, msg_title_sysvars
  bl      uart_puts
  adr     x0, sysvarnames                 // x0 = address of first sys var name
  adr     x20, sysvaraddresses            // x20 = address of first sys var pointer
1:
  bl      uart_puts
  ldrb    w21, [x0], #1                   // x21 = size of sysvar data in bytes
  mov     x19, x0                         // x19 = address of next sysvar name
  adr     x0, msg_colon0x
  bl      uart_puts
  ldr     x0, [x20], #8                   // x0 = address of sys var
  tbnz    w21, #0, size1
  tbnz    w21, #1, size2
  tbnz    w21, #2, size4
  tbnz    w21, #3, size8
  ret
size1:
  ldrb    w0, [x0]
  b       2f
size2:
  ldrh    w0, [x0]
  b       2f
size4:
  ldr     w0, [x0]
  b       2f
size8:
  ldr     x0, [x0]
2:
  mov     x1, sp
  mov     x2, x21, lsl #3                 // x2 = size of sysvar data in bits
  bl      hex_x0
  strb    wzr, [x1]                       // Add a trailing zero.
  mov     x0, sp
  bl      uart_puts
  bl      uart_newline
  mov     x0, x19
  ldrb    w1, [x0]
  cbnz    w1, 1b
  bl      uart_newline
  add     sp, sp, #32                     // Free buffer.
  ldp     x21, x22, [sp], #16             // Pop callee-saved registers.
  ldp     x19, x20, [sp], #16             // Pop callee-saved registers.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


display_zx_screen:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x9, ZX_SCREEN
  adr     x0, display_file
1:
  ldrb    w1, [x9], #1
  stp     x0, x9, [sp, #-16]!
  bl      poke_address
  ldp     x0, x9, [sp], #16
  add     x0, x0, #1
  adr     x2, attributes_file_end
  cmp     x0, x2
  b.ne    1b
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x0 = start address
#   x1 = number of rows to print
#   x2 = screen line to start at
display_memory:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Store old x19, x20 on the the stack.
  stp     x21, x22, [sp, #-16]!           // Store old x21, x22 on the the stack.
  stp     x23, x24, [sp, #-16]!           // Store old x23, x24 on the the stack.
  sub     sp, sp, #112                    // 112 bytes for screen line buffer
  mov     x19, x0                         // x19 = start address
  mov     x20, x1                         // x20 = number of rows to print
  mov     x21, x2                         // x21 = screen line to start at
  mov     w23, #0x2020                    // two spaces ('  ')
  adr     x0, msg_hex_header              // Pointer to string
  mov     w1, #0                          // x coordinate
  mov     w3, #0x00ffffff                 // white ink
  mov     w4, #0x000000cc                 // (dark) blue paper
  bl      paint_string                    // paint hex header line
  add     x21, x21, #1                    // x21 = first data line screen line
1:
  mov     x1, sp                          // address to write text string to
  strh    w23, [x1], #2                   // write '  ' to screen line buffer on stack
  mov     x0, x19                         // x0 = dump address
  mov     x2, #32
  bl      hex_x0                          // append to screen line buffer and update x1
  mov     x22, #0x20                      // 32 values to print
2:
  strb    w23, [x1], #1                   // write ' ' to screen line buffer
  ldrb    w0, [x19], #1                   // w0 = data at address, bump address x19
  mov     x2, #8
  bl      hex_x0
  subs    x22, x22, #1
  b.ne    2b
  strh    w23, [x1], #2                   // write '  ' to screen line buffer
  strb    wzr, [x1], #1                   // append 0 byte to terminate string
  mov     x0, sp
  mov     w1, #0                          // x = 0
  mov     x2, x21                         // y = line number
  mov     w3, #0x00ffffff                 // white ink
  mov     w4, #0x000000cc                 // (dark) blue paper
  bl      paint_string                    // paint string
  add     x21, x21, #1                    // increase line number
  subs    x20, x20, #1
  b.ne    1b                              // if not, process next line
  add     sp, sp, #112                    // Free screen line buffer
  ldp     x23, x24, [sp], #0x10           // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10           // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x0 = hex value to convert to text
#   x1 = address to write text to (no trailing 0)
#   x2 = number of bits to print (multiple of 4)
# On exit:
#   x1 = address of next unused char (x1 += x2/4)
hex_x0:
  ror     x0, x0, x2
1:
  ror     x0, x0, #60
  and     w3, w0, #0x0f
  add     w3, w3, 0x30
  cmp     w3, 0x3a
  b.lo    2f
  add     w3, w3, 0x27
2:
  strb    w3, [x1], #1
  subs    w2, w2, #4
  b.ne    1b
  ret

/////////////////////////////////////////////////////////////////////////
// The following code is all just for demonstration / testing purposes...
/////////////////////////////////////////////////////////////////////////
demo:
  bl      paint_copyright                 // Paint the copyright text ((C) 1982 Amstrad....)
  mov     w0, 0x20000000
  bl      wait_cycles
  bl      display_zx_screen
  mov     w0, 0x10000000
  bl      wait_cycles
  mov     x0, #60
  bl      cls
  mov     x0, sp
  mov     x1, #1
  mov     x2, #0
  bl      display_memory
  adr     x0, mbreq
  mov     x1, #5
  mov     x2, #3
  bl      display_memory
  adr     x0, sysvars
  mov     x1, #10
  mov     x2, #10
  bl      display_memory
  adrp    x0, heap
  add     x0, x0, #:lo12:heap             // x0 = heap
  sub     x0, x0, #0x60
  mov     x1, #8
  mov     x2, #22
  bl      display_memory
  adr     x0, STRMS
  mov     x1, #2
  mov     x2, #32
  bl      display_memory
  ldr     x0, [x28, CHANS-sysvars]
  mov     x1, #2
  mov     x2, #36
  bl      display_memory
  bl      display_sysvars
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  b       sleep


# ------------------------------------------------------------------------------
# Send '\r\n' over Mini UART
# ------------------------------------------------------------------------------
uart_newline:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x0, #13
  bl      uart_send
  mov     x0, #10
  bl      uart_send
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# ------------------------------------------------------------------------------
# Send a null terminated string over Mini UART.
# ------------------------------------------------------------------------------
uart_puts:
  mov     x1, AUX_BASE & 0xffff0000
  movk    x1, AUX_BASE & 0x0000ffff       // x1 = 0x3f215000 = AUX_BASE
1:
  ldrb    w2, [x0], #1
  cbz     w2, 5f
  cmp     w2, #127
  b.ne    4f
  mov     w2, '('
2:
  ldr     w3, [x1, AUX_MU_LSR]            // w3 = [AUX_MU_LSR_REG]
  tbz     x3, #5, 2b                      // Repeat last statement until bit 5 is set.
  strb    w2, [x1, AUX_MU_IO_REG]         //   [AUX_MU_IO_REG] = w2
  mov     w2, 'c'
3:
  ldr     w3, [x1, AUX_MU_LSR]            // w3 = [AUX_MU_LSR_REG]
  tbz     x3, #5, 3b                      // Repeat last statement until bit 5 is set.
  strb    w2, [x1, AUX_MU_IO_REG]         //   [AUX_MU_IO_REG] = w2
  mov     w2, ')'
4:
  ldr     w3, [x1, AUX_MU_LSR]            // w3 = [AUX_MU_LSR_REG]
  tbz     x3, #5, 4b                      // Repeat last statement until bit 5 is set.
  strb    w2, [x1, AUX_MU_IO_REG]         //   [AUX_MU_IO_REG] = w2
  b       1b
5:
  ret

uart_x0:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19, x20
  mov     x19, x0                         // Backup x0 in x19
  sub     sp, sp, #0x20                   // Allocate space on stack for hex string
  mov     x1, sp
  mov     x2, 64
  bl      hex_x0
  strb    wzr, [x1], #1
  mov     x0, sp
  bl      uart_puts
  add     sp, sp, #0x20
  mov     x0, x19                         // Restore x0
  ldp     x19, x20, [sp], #0x10           // Restore x19, x20
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


.data

msg_colon0x:
.asciz ": 0x"

msg_title_sysvars:
.ascii "System Variables"
.byte 10,13
.ascii "================"
.byte 10,13,0

msg_hex_header:
  .asciz "           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f  "