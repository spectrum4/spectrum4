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
  adrp    x9, 0xfd504000 + _start                 // x9 = MSI status register
.if UART_DEBUG
  ldr     w0, [x9, #0x500]                        // w0 = [MSI status]
  bl      uart_x0                                 // log MSI interrupt vectors
  bl      uart_newline
.endif
  mov     w0, #0x1
  str     w0, [x9, #0x508]                        // MSI_INT_CLR = 1 (clear MSI vector 0)
  bl      consume_xhci_events
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret

.align 2
# Note preserve x7, x8 and x9 since call stack (handle_xhci_irq and handle_irq_bcm2711) use these
consume_xhci_events:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x12, xhci_vars
  ldrxi   x10, x12, xhci_event_dequeue-xhci_vars
  ldrxi   x14, x12, xhci_event_ccs-xhci_vars      // x14 = Event Consumer Cycle Status (in bit 32)
  ldr     x15, =(0x600000000 + _start)            // x15 = VL805 USB Host Controller Capability Registers

  // loop through event TRBs
  1:
    ldrxi   x13, x10, #0x0                        // x13 = Event TRB Data Buffer Pointer (or immediate data)
    ldrxi   x11, x10, #0x8                        // x11 = Control (63:32) and Status (31:0)
    eor     x11, x11, x14                         // xor Producer Cycle State with Consumer Cycle State
    tbnz    x11, #32, 3f                          // Break from loop if PCS!=CCS (=> this is not a pending TRB)

// Example TRBs

//   read [0xfffffff000221000]=0x01000000 = 0b > 0000 0001 < 0000 0000 0000 0000 0000 0000 => Port = 1
//   read [0xfffffff000221004]=0x00000000 = 0b0000 0000 0000 0000 0000 0000 0000 0000
//   read [0xfffffff000221008]=0x01000000 = 0b > 0000 0001 < 0000 0000 0000 0000 0000 0000 => Completion Code = 1
//   read [0xfffffff00022100c]=0x00008801 = 0b0000 0000 0000 0000 > 1000 10 < 00 0000 000 > 1 < => TRB Type = 34 (Port Status Change Event), Cycle Bit = 1

//   read [0xfffffff000221010]=0x00220000 = 0b0000 0000 0010 0010 0000 0000 0000 0000
//   read [0xfffffff000221014]=0x00000004 = 0b0000 0000 0000 0000 0000 0000 0000 0100
//   read [0xfffffff000221018]=0x01000000 = 0b0000 0001 0000 0000 0000 0000 0000 0000
//   read [0xfffffff00022101c]=0x00008401 = 0b0000 0000 0000 0000 > 1000 01 < 00 0000 000 > 1 < => TRB Type = 33 (Command Completion Event), Cycle Bit = 1

    and     x16, x11, #0x0000fc0000000000

    mov     x17, #0x0000880000000000
    cmp     x16, x17
    b.eq    port_status_change_event

    mov     x17, #0x0000840000000000
    cmp     x16, x17
    b.eq    command_completion_event

    b       unknown_event

2:
    add     x10, x10, #16                         // Bump x10 to next event TRB entry (potentially overrunning event ring)
    and     x13, x10, #0xfff                      // x13 = lower 12 bits of x10 (event ring offset)
    cmp     x13, #(event_ring_end-event_ring)     // check if x10 has overrun the ring
    b.ne    1b                                    // if not, loop around
    and     x10, x10, #~0xfff                     // set x10 to start of ring
    eor     x14, x14, #(1<<32)                    // toggle Event Consumer Cycle Status bit
    strxi   x14, x12, xhci_event_ccs-xhci_vars    // store it
    b       1b                                    // loop around
3:
  orr     w1, w10, #0x8                           // prepare to clear ERDP.EHB (RW1C)
  mov     w2, #0x4                                // ERDP_HI = 0x4 for DMA address
  strwi   w1, x15, #0x238                         // [ERDP_LO] = next TRB (lo) with EHB cleared
  strwi   w2, x15, #0x23c                         // [ERDP_HI] = next TRB (hi)
  strxi   x10, x12, xhci_event_dequeue-xhci_vars
                                                  // advance event dequeue pointer
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


port_status_change_event:
.if UART_DEBUG
  adr     x0, msg_port_status_change_event
  bl      uart_puts
.endif
  lsr     w17, w13, #24                           // w17 = port number
  add     x17, x15, x17, lsl #4                   // x17 = 0x6 0000 0000 + port number * 0x10
  ldrwi   x18, x17, #0x410                        // x18 = [0x6 0000 0420 + (port number - 1) * 0x10] = [PORTSC]
  b       2b


command_completion_event:
.if UART_DEBUG
  adr     x0, msg_command_completion_event
  bl      uart_puts
.endif
  b       2b


unknown_event:
.if UART_DEBUG
  adr     x0, msg_unknown_event
  bl      uart_puts
.endif
  b       sleep


.if UART_DEBUG
msg_xhci_event:
  .asciz "XHCI MSI vector status: "
msg_port_status_change_event:
  .asciz "Port Status Change Event\r\n"
msg_command_completion_event:
  .asciz "Command Completion Event\r\n"
msg_unknown_event:
  .asciz "Unknown Event\r\n"
.endif
