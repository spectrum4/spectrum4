# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.macro _strb val, addr
  mov     w0, \val & 0xff
  adrp    x1, \addr
  add     x1, x1, :lo12:\addr
  strb    w0, [x1]
.endm


.macro _strh val, addr
  mov     w0, \val & 0xffff
  adrp    x1, \addr
  add     x1, x1, :lo12:\addr
  strh    w0, [x1]
.endm


# like _strh, but val in *big endian* format
.macro _strhbe val, addr
  mov     w0, ((\val & 0xff) << 8) | ((\val & 0xff00) >> 8)
  adrp    x1, \addr
  add     x1, x1, :lo12:\addr
  strh    w0, [x1]
.endm


# like hword, but in *big endian* format (useful for linear pixel maps)
.macro _hwordbe val
  .hword   ((\val & 0xff) << 8) | ((\val & 0xff00) >> 8)
.endm


.macro _str val, addr
  ldr     x0, =\val
  adrp    x1, \addr
  add     x1, x1, :lo12:\addr
  str     x0, [x1]
.endm


.macro _pixel val, x, y
  adrp    x2, framebuffer
  add     x2, x2, :lo12:framebuffer
  ldr     w0, [x2]
  orr     x0, x0, 0xfffffff000000000              // Convert to virtual address
  ldr     w1, [x2, pitch-framebuffer]
  mov     w2, \y
  umaddl  x0, w1, w2, x0
  mov     w1, \x
  movz    x2, \val & 0xffff
  movk    x2, (\val >> 16) & 0xffff, lsl #16
  movk    x2, (\val >> 32) & 0xffff, lsl #32
  movk    x2, (\val >> 48) & 0xffff, lsl #48
  add     x0, x0, x1, lsl #2
  str     x2, [x0]
.endm


.macro _setmsk mask, address
  ldrb    w0, [x28, \address-sysvars]
  orr     w0, w0, \mask
  strb    w0, [x28, \address-sysvars]
.endm


.macro _resmsk mask, address
  ldrb    w0, [x28, \address-sysvars]
  and     w0, w0, ~\mask
  strb    w0, [x28, \address-sysvars]
.endm


.macro _setbit bit, address
  _setmsk (1<<\bit), \address
.endm


.macro _resbit bit, address
  _resmsk (1<<\bit), \address
.endm


# Load a 32-bit immediate using mov.
.macro movl Wn, imm
  movz    \Wn, \imm & 0xffff
  movk    \Wn, (\imm >> 16) & 0xffff, lsl #16
.endm


.macro log char
.if UART_DEBUG
  stp     x29, x30, [sp, #-16]!
  stp     x0, x1, [sp, #-16]!
  stp     x2, x3, [sp, #-16]!
  stp     x4, x5, [sp, #-16]!
  mrs     x4, nzcv                                // copy N, Z, C, and V flags into x4 (not disturbed by following uart_puts call)
  mov     x0, #\char
  bl      uart_send
  bl      uart_newline
  msr     nzcv, x4                                // restore flags
  ldp     x4, x5, [sp], #16
  ldp     x2, x3, [sp], #16
  ldp     x0, x1, [sp], #16
  ldp     x29, x30, [sp], #16
.endif
.endm


.macro logreg index
.if UART_DEBUG
  stp     x29, x30, [sp, #-16]!
  stp     x0, x1, [sp, #-16]!
  stp     x2, x3, [sp, #-16]!
  stp     x4, x5, [sp, #-16]!
  mrs     x0, nzcv
  str     x0, [sp, #-16]!                         // preserve N, Z, C, and V flags on the stack
  mov     x0, 'x'
  bl      uart_send
  mov     x2, #\index
  sub     sp, sp, 32
  mov     x0, sp
  bl      base10
  bl      uart_puts
  add     sp, sp, #32
  mov     x0, ':'
  bl      uart_send
  mov     x0, ' '
  bl      uart_send
  ldp     x4, x5, [sp, #16]                       // restore these registers, in case they are being logged!
  ldp     x2, x3, [sp, #32]
  ldp     x0, x1, [sp, #48]
  mov     x0, x\index
  bl      uart_x0
  bl      uart_newline
  ldr     x0, [sp], #16                           // fetch preserved nzcv from stack
  msr     nzcv, x0                                // restore it
  ldp     x4, x5, [sp], #16
  ldp     x2, x3, [sp], #16
  ldp     x0, x1, [sp], #16
  ldp     x29, x30, [sp], #16
.endif
.endm


.macro logregs
  logreg  0
  logreg  1
  logreg  2
  logreg  3
  logreg  4
  logreg  5
  logreg  6
  logreg  7
  logreg  8
  logreg  9
  logreg  10
  logreg  11
  logreg  12
  logreg  13
  logreg  14
  logreg  15
  logreg  16
  logreg  17
  logreg  18
  logreg  19
  logreg  20
  logreg  21
  logreg  22
  logreg  23
  logreg  24
  logreg  25
  logreg  26
  logreg  27
  logreg  28
  logreg  29
  logreg  30
  lognzcv
.endm


.macro lognzcv
  logarm  NZCV
.endm


.macro clear_carry
  stp     x1, x2, [sp, #-16]!                     // backup x1, x2
  mrs     x1, nzcv                                // copy N, Z, C, and V flags into x1
  mov     x2, #0x20000000                         // mask for the carry flag (bit 29)
  bic     x1, x1, x2                              // clear the carry flag
  msr     nzcv, x1                                // apply changes back to NZCV register
  ldp     x1, x2, [sp], #16                       // restore x1, x2
.endm


.macro set_carry
  stp     x1, x2, [sp, #-16]!                     // backup x1, x2
  mrs     x1, nzcv                                // copy N, Z, C, and V flags into x1
  mov     x2, #0x20000000                         // mask for the carry flag (bit 29)
  orr     x1, x1, x2                              // set the carry flag
  msr     nzcv, x1                                // apply changes back to NZCV register
  ldp     x1, x2, [sp], #16                       // restore x1, x2
.endm


.macro nzcv value
  tst     wzr, #1
  ccmp    wzr, #0, \value, ne
.endm


.macro logarm reg
.if UART_DEBUG
  stp     x29, x30, [sp, #-16]!
  stp     x0, x1, [sp, #-16]!
  stp     x2, x3, [sp, #-16]!
  stp     x4, x5, [sp, #-16]!
  mrs     x4, nzcv                                // preserve N, Z, C, and V flags in x4 (not disturbed by following uart_puts call)
  adrp    x0, msg_\reg
  add     x0, x0, :lo12:msg_\reg
  bl      uart_puts
  msr     nzcv, x4                                // restore flags from x4 (in case nzcv is flag being logged)
  mrs     x0, \reg                                // read register value into x0
  bl      uart_x0
  bl      uart_newline
  msr     nzcv, x4                                // restore nzcv again (since uart_x0 / uart_newline may have disturbed it)
  ldp     x4, x5, [sp], #16
  ldp     x2, x3, [sp], #16
  ldp     x0, x1, [sp], #16
  ldp     x29, x30, [sp], #16
.endif
.endm


.macro strbi val, base, offset
  read_write_immediate strb, msg_write, 8, \val, \base, \offset
.endm


.macro strhi val, base, offset
  read_write_immediate strh, msg_write, 16, \val, \base, \offset
.endm


.macro strwi val, base, offset
  read_write_immediate str, msg_write, 32, \val, \base, \offset
.endm


.macro strxi val, base, offset
  read_write_immediate str, msg_write, 64, \val, \base, \offset
.endm


.macro ldrbi val, base, offset
  read_write_immediate ldrb, msg_read, 8, \val, \base, \offset
.endm


.macro ldrhi val, base, offset
  read_write_immediate ldrh, msg_read, 16, \val, \base, \offset
.endm


.macro ldrwi val, base, offset
  read_write_immediate ldr, msg_read, 32, \val, \base, \offset
.endm


.macro ldrxi val, base, offset
  read_write_immediate ldr, msg_read, 64, \val, \base, \offset
.endm


.macro read_write_immediate op, message, bitcount, val, base, offset
  \op     \val, [\base, \offset]
.if UART_DEBUG
  stp     x29, x30, [sp, #-16]!
  stp     x0, x1, [sp, #-16]!
  stp     x2, x3, [sp, #-16]!
  stp     x4, x5, [sp, #-16]!
  str     \base, [sp, #-8]!
  str     \val, [sp, #-8]!
  mrs     x0, nzcv                                // preserve N, Z, C, V flags
  str     x0, [sp, #-8]!
  adr     x0, \message
  bl      uart_puts
  mov     x0, '['
  bl      uart_send
  ldr     x0, [sp, #16]                           // x0 = \base
  mov     x1, \offset
  add     x0, x0, x1                              // x0 = \base + \offset
  bl      uart_x0
  mov     x0, ']'
  bl      uart_send
  mov     x0, '='
  bl      uart_send
  ldr     x0, [sp, #8]
  mov     x2, \bitcount
  bl      uart_x0_s
  bl      uart_newline
  ldr     x0, [sp], #8
  msr     nzcv, x0                                // restore N, Z, C, V flags
  ldr     \val, [sp], #8
  ldr     \base, [sp], #8
  ldp     x4, x5, [sp], #16
  ldp     x2, x3, [sp], #16
  ldp     x0, x1, [sp], #16
  ldp     x29, x30, [sp], #16
.endif
.endm


.if UART_DEBUG
.macro msgreg regname
msg_\regname:
.asciz "\regname: "
.endm
.endif
