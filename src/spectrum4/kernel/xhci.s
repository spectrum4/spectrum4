# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/extensible-host-controler-interface-usb-xhci.pdf
# page 381 (section 5.3 Host Controller Capability Registers)


# Capability registers...
#
#           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
# 600000000 20 00 00 01 20 04 00 05 31 00 00 fc 04 00 e7 00 eb 41 28 00 00 01 00 00 00 02 00 00 00 00 00 00
#
# 0x00: XHCI_REG_CAP_CAPLENGTH    0x20        => Op base at 0x600000020
# 0x02: XHCI_REG_CAP_HCIVERSION   0x0100      => Version 1.0 = USB 3.0 controller
# 0x04: XHCI_REG_CAP_HCSPARAMS1   0x05000420  0b 00000101 (MaxPorts = 5) 00000 (Rsvd) 00000000100 (MaxIntrs = 4) 00100000 (MaxSlots = 32)
# 0x08: XHCI_REG_CAP_HCSPARAMS2   0xfc000031  0b 11111 (Max Scratchpad Buffers Lo = 31) 1 (Scratchpad Restore = 1) 00000 (Max Scratchpad Buffers Hi = 0) 0000000000000 (Rsvd) 0011 (Event Ring Segment Table Max = 3) 0001 (Isochronous Scheduling Threshold = 1)
# 0x0c: XHCI_REG_CAP_HCSPARAMS3   0x00e70004  0b 0000000011100111 (U2->U0 Device Exit Latency < 231 microseconds) 00000000 (Rsvd) 00000100 (U1->U0 Device Exit Latency < 4 microseconds)
# 0x10: XHCI_REG_CAP_HCCPARAMS1   0x002841eb  0b 0000000000101000: xHCI Extended Capabilities Pointer (xECP) = 40 => 160 bytes offset (0xa0) => extended capabilities at 0x6000000a0
#                                                0100: MaxPSASize = 4 => Primary Stream Array size = 32
#                                                0: Contiguous Frame ID Capability (CFC)
#                                                0: Stopped EDTLA Capability (SEC)
#                                                0: Stopped - Short Packet Capability (SPC)
#                                                1: Parse All Event Data (PAE)
#                                                1: No Secondary SID Support (NSS)
#                                                1: Latency Tolerance Messaging Capability (LTC)
#                                                1: Light HC Reset Capability (LHRC)
#                                                0: Port Indicators (PIND)
#                                                1: Port Power Control (PPC)
#                                                0: Context Size (CSZ) => 32 byte Context data structures (not Stream Contexts) (rather than 64 byte)
#                                                1: BW Negotiation Capability (BNC)
#                                                1: 64-bit Addressing Capability77 (AC64)
# 0x14: XHCI_REG_CAP_DBOFF        0x00000100 => Doorbell Array Offset = 0x100 (i.e. 0x600000100)
# 0x18: XHCI_REG_CAP_RTSOFF       0x00000200 => Runtime Register Space Offset (i.e. 0x600000200)
# 0x1c: XHCI_REG_CAP_HCCPARAMS2   0x00000000 =>



# Operational registers...
#
# 600000020 00 00 00 00 11 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#
# 0x20: XHCI_REG_OP_USBCMD        0x00000000
# 0x24: XHCI_REG_OP_USBSTS        0x00000011
# 0x28: XHCI_REG_OP_PAGESIZE      0x00000001  => 4KB page size
# 0x2c: reserved                  0x00000000
# 0x30: reserved                  0x00000000
# 0x34: XHCI_REG_OP_DNCTRL        0x00000000
# 0x38: XHCI_REG_OP_CRCR_LO       0x00000000
# 0x3c: XHCI_REG_OP_CRCR_HI       0x00000000
# 0x40: reserved                  0x00000000
# 0x44: reserved                  0x00000000
# 0x48: reserved                  0x00000000
# 0x4c: reserved                  0x00000000
# 0x50: XHCI_REG_OP_DCBAAP_LO     0x00000000
# 0x54: XHCI_REG_OP_DCBAAP_HI     0x00000000
# 0x58: XHCI_REG_OP_CONFIG        0x00000000


# Extended capabilities...
#
# 6000000a0 01 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 08 00 02 55 53 42 20 01 01 06 10 00 00 00 00
# 6000000c0 23 00 e0 01 00 00 00 00 00 00 00 00 00 00 00 00 02 8c 00 03 55 53 42 20 02 04 00 10 00 00 00 00
# 6000000e0 34 01 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000220 00 00 00 00 a0 0f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000240 00 00 00 00 a0 0f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000260 00 00 00 00 a0 0f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000280 00 00 00 00 a0 0f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000300 0a 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000320 00 00 00 00 00 00 00 00 a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

# PORT SC
# Port 1 and 2:
# 600000420 e1 02 02 40 00 00 00 00 00 00 00 00 00 00 00 00 a0 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# Port 3 and 4:
# 600000440 a0 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 a0 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# Port 5:
# 600000460 a0 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

# Port 1:    0x400202e1 = 0b0100 0000 0000 0010 0000 0010 1110 0001
#                   e03 =                            1110 0000 0011
#    0: Current Connect Status (CCS)        - ROS = 1 => Device Connected
#    1: Port Enabled/Disabled (PED)         - RW1CS = 0 => Port Disabled
#    2: RsvdZ = 0
#    3: Over-current Active (OCA)           - RO = 0 => Port does not have over-current condition
#    4: Port Reset (PR)                     - RW1S = 0 => Port is not in reset
#    8:5: Port Link State (PLS)             - RWS = 7 => Port is in the Polling State
#    9: Port Power (PP)                     - RWS = 1 => Port is not powered off (I believe - need to check HCCPARAMS1.PPC to be sure)
#    13:10: Port Speed (Port Speed)         - ROS = 0 => Port Speed is undefined speed
#    15:14: Port Indicator Control (PIC)    - RWS = 0 => Port indicators are off
#    16: Port Link State Write Strobe (LWS) - RW = 0
#    17: Connect Status Change (CSC)        - RW1CS = 0
#    18: Port Enabled/Disabled Change (PEC) - RW1CS = 0
#    19: Warm Port Reset Change (WRC)       - RW1CS/RsvdZ = 0
#    20: Over-current Change (OCC)          - RW1CS = 0
#    21: Port Reset Change (PRC)            - RW1CS = 1 => Port Reset Complete
#    22: Port Link State Change (PLC)       - RW1CS = 0
#    23: Port Config Error Change (CEC)     - RW1CS/RsvdZ = 0
#    24: Cold Attach Status (CAS)           - RO = 0
#    25: Wake on Connect Enable (WCE)       - RWS = 0
#    26: Wake on Disconnect Enable (WDE)    - RWS = 0
#    27: Wake on Over-current Enable (WOE)  - RWS = 0
#    29:28: RsvdZ = 0
#    30: Device Removable (DR)              - RO = 1 => Device is non-removable
#    31: Warm Port Reset (WPR)              - RW1S/RsvdZ = 0
#
# Port 2-5:  0x000002a0 = 0b0000 0000 0000 0000 0000 0010 1010 0000
#    0: CCS = 0 => Device is not connected
#    1: PED = 0 => Port Disabled
#    3: OCA = 0 => Port does not have over-current condition
#    4: PR = 0 => Port is not in reset
#    8:5: PLS = 5 => Port is in the RxDetect State (USB 3 spec section 10.14.2.6.1)
#    9: PP = 1 => Port is not powered off (I believe - need to check HCCPARAMS1.PPC to be sure)
#    13:10: PS = 0 => Port Speed is undefined speed
#    15:14: PIC = 0 => Port indicators are off
#    ...
#    21: PRC = 0 => No change to port reset status
#    ...
#    30: DR = 0 => Device is removable


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
  ldrwi   w18, x17, #0x410                        // w18 = [0x6 0000 0420 + (port number - 1) * 0x10] = [PORTSC]
  ubfx    w19, w18, #1, #1                        // w19 = bit 1 of w18 = PED (port enabled)
  eor     w19, w19, #1                            // invert w19 bit 0 i.e. 0 if port enabled, 1 if port disabled
  bfi     w18, w19, #4, #1                        // PR (port reset) = 0 if port enabled, 1 if port disabled
  strwi   w18, x17, #0x410                        // write value back to clear RW1CS changes, potentially reset port
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
