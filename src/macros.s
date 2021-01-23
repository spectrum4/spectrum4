# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.


.macro _strb val, addr
  mov     w0, \val & 0xff
  adrp    x1, \addr
  add     x1, x1, :lo12:\addr
  strb    w0, [x1]
.endm


.macro _str val, addr
  ldr     x0, =\val
  adrp    x1, \addr
  add     x1, x1, :lo12:\addr
  str     x0, [x1]
.endm


# Load a 32-bit immediate using mov.
.macro movl Wn, imm
  movz    \Wn,  \imm & 0xFFFF
  movk    \Wn, (\imm >> 16) & 0xFFFF, lsl #16
.endm


.macro log char
.if       DEBUG_PROFILE
  stp     x29, x30, [sp, #-16]!
  stp     x0, x1, [sp, #-16]!
  stp     x2, x3, [sp, #-16]!
  stp     x4, x5, [sp, #-16]!
  mov     x0, #\char
  bl      uart_send
  bl      uart_newline
  ldp     x4, x5, [sp], #16
  ldp     x2, x3, [sp], #16
  ldp     x0, x1, [sp], #16
  ldp     x29, x30, [sp], #16
.endif
.endm


.macro logreg index
.if       DEBUG_PROFILE
  stp     x29, x30, [sp, #-16]!
  stp     x0, x1, [sp, #-16]!
  stp     x2, x3, [sp, #-16]!
  stp     x4, x5, [sp, #-16]!
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
  ldp     x4, x5, [sp]
  ldp     x2, x3, [sp, #16]
  ldp     x0, x1, [sp, #32]
  mov     x0, x\index
  bl      uart_x0
  bl      uart_newline
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
.endm


.macro nzcv value
  tst     wzr, #1
  ccmp    wzr, #0, \value, ne
.endm
