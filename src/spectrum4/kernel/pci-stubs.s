# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.global pci_log

.text
msg_pci:
.asciz "PCI: "

.align 2
pci_log:
.if UART_DEBUG
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     x4, x0
  adr     x0, msg_pci
  bl      uart_puts
  mov     x0, x4
  bl      uart_puts
  bl      uart_newline
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
.endif
  ret
