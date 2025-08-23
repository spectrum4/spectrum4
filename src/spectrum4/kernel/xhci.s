# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# Note: preserve x7 and x8 since caller (handle_irq_bcm2711) uses these
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
  adrp    x9, 0xfd504000 + _start                 // x4 = MSI status register
  ldr     w0, [x9, #0x500]                        // w0 = [MSI status]
.if UART_DEBUG
  bl      uart_x0                                 // log MSI interrupt vectors
  bl      uart_newline
.endif
  bl      consume_xhci_events
  str     w0, [x9, #0x508]                        // clear MSI interrupts
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

.align 2
# Note preserve x7, x8 and x9 since call stack (handle_xhci_irq and handle_irq_bcm2711) use these
consume_xhci_events:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x12, xhci_vars
  ldr     x10, [x12, xhci_event_dequeue-xhci_vars]
  1:
    ldp     x0, x11, [x10], #16
    tbz     x11, #32, 2f
.if UART_DEBUG
    bl      uart_x0
    bl      uart_newline
    mov     x0, x11
    bl      uart_x0
    bl      uart_newline
.endif
    b       1b
2:
  str     x10, [x12, xhci_event_dequeue-xhci_vars]
                                                  // advance event dequeue pointer
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret



.if UART_DEBUG
msg_xhci_event:
  .asciz "XHCI MSI vector status: "
.endif
