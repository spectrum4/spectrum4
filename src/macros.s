# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

# Load a 32-bit immediate using mov.
.macro movl Wn, imm
  movz    \Wn,  \imm & 0xFFFF
  movk    \Wn, (\imm >> 16) & 0xFFFF, lsl #16
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
