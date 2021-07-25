# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


# Logs all sysvars to UART.
#
# On entry:
#   <nothing>
# On exit:
#   x0 = 0x0a
#   x1 = AUX_BASE
#   x2 = [AUX_MU_LSR] = 0x21 / 0x61 (see page 15 of BCM ARM2835/7 ARM Peripherals) when waiting to send final newline
#   x3 = [AUX_MU_LSR] = 0x21 / 0x61 (see page 15 of BCM ARM2835/7 ARM Peripherals) when waiting to write final sysvar value
#   x4 = value of last logged 1/2/4/8 byte sysvar (currently [PR_CC])
#   NZCV: depends on size of last sysvar, currently last sysvar is MEMBOT, so 0b0110
#     if last sysvar is 1/2/4/8 byte sysvar: 0b1000
#     otherwise: 0b0110
display_sysvars:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x23, [sp, #-16]!                   // callee-saved registers used later on.
  stp     x20, x21, [sp, #-16]!                   // callee-saved registers used later on.
  adr     x0, msg_title_sysvars
  bl      uart_puts
  adr     x19, sysvars_meta                       // x0 = address of sysvars metadata table
  mov     w23, SYSVAR_COUNT                       // x23 = number of system variables to log
  1:
    ldr     x20, [x19], #8                        // x20 = sysvar_meta entry
    bl      display_sysvar
    bl      uart_newline
    sub     w23, w23, #1
    cbnz    w23, 1b
  bl      uart_newline
  ldp     x20, x21, [sp], #16                     // Pop callee-saved registers.
  ldp     x19, x23, [sp], #16                     // Pop callee-saved registers.
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
