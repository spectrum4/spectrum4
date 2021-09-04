# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


# Logs sysvar to UART. No leading/trailing whitespace.
#
# Examples:
#   [0x000000000003b871] WIDTH: 0x50
#   [0x000000000003b890] RNFIRST: 0x000a
#   [0x000000000003b8c8] SFNEXT: 0x0000000000170a10
#   [0x000000000003b894] STRMS: 01 00 19 00 31 00 01 00 01 00 19 00 49 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#
# On entry:
#   x20: address of sysvar metadata (sysvar_XXXXXX label)
# On exit:
#   x0 =
#     1 byte sysvar: stack pointer - 61
#     2 byte sysvar: stack pointer - 59
#     4 byte sysvar: stack pointer - 55
#     8 byte sysvar: stack pointer - 47
#         otherwise: stack pointer - 60
#   x1 = AUX_BASE
#   x2 = 0
#   x3 = [AUX_MU_LSR] = 0x21 / 0x61 (see page 15 of BCM ARM2835/7 ARM Peripherals)
#   x4 =
#     1/2/4/8 byte sysvar: sysvar value
#               otherwise: unchanged
#   NZCV =
#     1/2/4/8 byte sysvar: 0b1000
#               otherwise: 0b0110
display_sysvar:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x21, x24, [sp, #-16]!                   // callee-saved registers used later on.
  sub     sp, sp, #32                             // 32 bytes buffer for storing hex representation of sysvar (maximum is 16 chars + trailing 0, so 17 bytes)
  mov     x0, '['
  bl      uart_send                               // Log "["
  ldr     x0, [x20]                               // x0 = address offset of sys var
  add     x0, x0, x28
  bl      uart_x0                                 // Log "<sys var address>"
  mov     x0, ']'
  bl      uart_send                               // Log "]"
  mov     x0, ' '
  bl      uart_send                               // Log " "
  add     x0, x20, #9
  bl      uart_puts                               // Log system variable name
  ldrb    w21, [x20, #8]                          // w21 = size of sysvar data in bytes
  ldr     x24, [x20]                              // x24 = address offset of sys var
  cmp     w21, #1
  b.eq    3f
  cmp     w21, #2
  b.eq    4f
  cmp     w21, #4
  b.eq    5f
  cmp     w21, #8
  b.eq    6f
  // not 1/2/4/8 bytes => print one byte at a time
  mov     x0, ':'
  bl      uart_send
  mov     x0, ' '
  bl      uart_send
  add     x24, x24, x28
  2:
    ldrb    w0, [x24], #1
    mov     x1, sp
    mov     x2, #8
    bl      hex_x0
    mov     w0, #0x0020
    strh    w0, [x1], #2                          // Add a space and trailing zero.
    mov     x0, sp
    bl      uart_puts
    subs    w21, w21, #1
    b.ne    2b
  b       8f
3:
  // 1 byte
  ldrb    w4, [x28, x24]
  b       7f
4:
  // 2 bytes
  ldrh    w4, [x28, x24]
  b       7f
5:
  // 4 bytes
  ldr     w4, [x28, x24]
  b       7f
6:
  // 8 bytes
  ldr     x4, [x28, x24]
7:
  adr     x0, msg_colon0x
  bl      uart_puts                               // Log ": 0x"
  mov     x0, x4
  mov     x1, sp
  mov     x2, x21, lsl #3                         // x2 = size of sysvar data in bits
  bl      hex_x0
  strb    wzr, [x1]                               // Add a trailing zero.
  mov     x0, sp
  bl      uart_puts
8:
  add     sp, sp, #32                             // Free buffer.
  ldp     x21, x24, [sp], #16                     // Pop callee-saved registers.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret


.data
msg_title_sysvars:             .asciz "System Variables\r\n================\r\n"
msg_colon0x:                   .asciz ": 0x"
