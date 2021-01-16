# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.macro _strb val, addr
  mov       w0, \val & 0xff
  adrp      x1, \addr
  add       x1, x1, :lo12:\addr
  strb      w0, [x1]
.endm

.macro _str val, addr
  ldr       x0, =\val
  adrp      x1, \addr
  add       x1, x1, :lo12:\addr
  str       x0, [x1]
.endm

# Load a 32-bit immediate using mov.
.macro movl Wn, imm
  movz    \Wn,  \imm & 0xFFFF
  movk    \Wn, (\imm >> 16) & 0xFFFF, lsl #16
.endm

.macro log text
.if       DEBUG_PROFILE
  stp       x29, x30, [sp, #-16]!
  stp       x0, x1, [sp, #-16]!
  stp       x2, x3, [sp, #-16]!
  stp       x4, x5, [sp, #-16]!
  mov       x0, #\text
  bl        uart_send
  bl        uart_newline
  ldp       x4, x5, [sp], #16
  ldp       x2, x3, [sp], #16
  ldp       x0, x1, [sp], #16
  ldp       x29, x30, [sp], #16
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
  logreg 0
  logreg 1
  logreg 2
  logreg 3
  logreg 4
  logreg 5
  logreg 6
  logreg 7
  logreg 8
  logreg 9
  logreg 10
  logreg 11
  logreg 12
  logreg 13
  logreg 14
  logreg 15
  logreg 16
  logreg 17
  logreg 18
  logreg 19
  logreg 20
  logreg 21
  logreg 22
  logreg 23
  logreg 24
  logreg 25
  logreg 26
  logreg 27
  logreg 28
  logreg 29
  logreg 30
.endm

# .macro handle_invalid_entry type
#   kernel_entry
#   mov       x0, #\type
#   mrs       x1, esr_el1
#   mrs       x2, elr_el1
#   bl        show_invalid_entry_message
#   b         hang_core
# .endm

# .macro ventry label
#   .align 7
#   b         \label
# .endm
#
# .macro push_registers
#   sub       sp, sp, #0x100
#   stp       x0, x1, [sp, #16 * 0]
#   stp       x2, x3, [sp, #16 * 1]
#   stp       x4, x5, [sp, #16 * 2]
#   stp       x6, x7, [sp, #16 * 3]
#   stp       x8, x9, [sp, #16 * 4]
#   stp       x10, x11, [sp, #16 * 5]
#   stp       x12, x13, [sp, #16 * 6]
#   stp       x14, x15, [sp, #16 * 7]
#   stp       x16, x17, [sp, #16 * 8]
#   stp       x18, x19, [sp, #16 * 9]
#   stp       x20, x21, [sp, #16 * 10]
#   stp       x22, x23, [sp, #16 * 11]
#   stp       x24, x25, [sp, #16 * 12]
#   stp       x26, x27, [sp, #16 * 13]
#   stp       x28, x29, [sp, #16 * 14]
#   str       x30, [sp, #16 * 15]
# .endm
#
# .macro pop_registers
#   ldp       x0, x1, [sp, #16 * 0]
#   ldp       x2, x3, [sp, #16 * 1]
#   ldp       x4, x5, [sp, #16 * 2]
#   ldp       x6, x7, [sp, #16 * 3]
#   ldp       x8, x9, [sp, #16 * 4]
#   ldp       x10, x11, [sp, #16 * 5]
#   ldp       x12, x13, [sp, #16 * 6]
#   ldp       x14, x15, [sp, #16 * 7]
#   ldp       x16, x17, [sp, #16 * 8]
#   ldp       x18, x19, [sp, #16 * 9]
#   ldp       x20, x21, [sp, #16 * 10]
#   ldp       x22, x23, [sp, #16 * 11]
#   ldp       x24, x25, [sp, #16 * 12]
#   ldp       x26, x27, [sp, #16 * 13]
#   ldp       x28, x29, [sp, #16 * 14]
#   ldr       x30, [sp, #16 * 15]
#   add       sp, sp, #0x100
# .endm

# .macro kernel_exit
#   pop_registers
#   eret
# .endm
