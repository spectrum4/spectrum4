# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# On exit:
#   x1: new timer value ([next_interrupt])
#   x2: 0x2000000
#   plus any changes made by timed_interrupt routine (potentially replacing x1/x2 changes above)
.align 2
handle_xhci_irq:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
.if UART_DEBUG
  adr     x0, msg_xhci_event
  bl      uart_puts
.endif
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


.if UART_DEBUG
msg_xhci_event:
  .asciz "XHCI event occurred\r\n"
.endif
