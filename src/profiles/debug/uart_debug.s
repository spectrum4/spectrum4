# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text
.align 2


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
#
# On entry:
#   x0 = address of null terminated string
# On exit:
#   x0 = address of null terminated string (unchanged)
#   x1 = AUX_BASE
#   x2 = 0
#   x3 = [AUX_MU_LSR]
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


# ------------------------------------------------------------------------------
# Write the value of x0 as a hex string (0x0123456789abcdef) to Mini UART.
# ------------------------------------------------------------------------------
#
# On entry:
#   x0 = value to write as a hex string to Mini UART.
.align 2
uart_x0:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19, x20
  mov     x19, x0                         // Backup x0 in x19
  sub     sp, sp, #0x20                   // Allocate space on stack for hex string
  mov     w2, 0x7830
  mov     x1, sp
  mov     x1, sp
  strh    w2, [x1], #2                    // "0x"
  mov     x2, 64
  bl      hex_x0
  strb    wzr, [x1], #1
  mov     x0, sp
  bl      uart_puts
  add     sp, sp, #0x20
  mov     x0, x19                         // Restore x0
  ldp     x19, x20, [sp], #16             // Restore x19, x20
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret
