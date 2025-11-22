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
# 0x1c: XHCI_REG_CAP_HCCPARAMS2   0x00000000 0b  0: U3C U3 Entry Capbility not supported (Port Suspend Complete notification not supported)
#                                                0: CMC Configure Endpoint Command Max Exit Latency Too Large Capability
#                                                0: FSC
#                                                0: CTC
#                                                0: LEC
#                                                0: CIC
#                                                0: ETC
#                                                0: ETC_TSC
#                                                0: GSC
#                                                0: VTC



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

# a0: Capability 01: USB Legacy Support; SMI options all set to 0 - SMI only relevant for legacy x86/BIOS stuff
# b0: Capability 02: Supported Protocol v2.0 "USB " ports 1-1 protocol defined 0x006 => high speed only; integrated hub; PSIC 0x1; protocol slot type 0;
#         Protocol speed IDs: 0x01e00023 0b0000 0001 1110 0000 0000 0000 0010 0011 => PSIV=3 @ 480 Mb/s (symmetric) half-duplex
# d0: Capability 02: Supported Protocol v3.0 "USB " ports 2-5 ..... slot type 0;
#         .....
# 300: Capability 0a: USB Debug Capability

# PORT SC
# Port 1 and 2:
# 600000420 e1 02 02 40 00 00 00 00 00 00 00 00 00 00 00 00 a0 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# Port 3 and 4:
# 600000440 a0 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 a0 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# Port 5:
# 600000460 a0 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

# Port 1:    0x400202e1 = 0b0100 0000 0000 0010 0000 0010 1110 0001
#            0x400002e1 = 0b0100 0000 0000 0000 0000 0010 1110 0001 (CSC)
#            0x40200e03 = 0b0100 0000 0010 0000 0000 1110 0000 0011 (PED, PLS, Port Speed, PRC)
#            0x40000e03 = 0b0100 0000 0000 0000 0000 1110 0000 0011 (PRC)
#
#    0: Current Connect Status (CCS)        - ROS = 1 => Device Connected
#    1: Port Enabled/Disabled (PED)         - RW1CS = 0 => Port Disabled              / 1 => Port Enabled
#    2: RsvdZ = 0
#    3: Over-current Active (OCA)           - RO = 0 => Port does not have over-current condition
#    4: Port Reset (PR)                     - RW1S = 0 => Port is not in reset
#    8:5: Port Link State (PLS)             - RWS = 7 => Link is in the Polling State / 0 => Link is in the U0 State
#    9: Port Power (PP)                     - RWS = 1 => Port is not powered off (I believe - need to check HCCPARAMS1.PPC to be sure)
#    13:10: Port Speed (Port Speed)         - ROS = 0 => Port Speed is undefined speed / 3 => Port Speed is 3 (High Speed??)
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
  ldrwi   w13, x15, #0x20                         // TODO: remove this, just for debug: log USBCMD to see if RUN_STOP (bit 0) is clear or set

  ldrwi   w3, x15, #0x24                          // Read USBSTS in w3
  strwi   w3, x15, #0x24                          // Write back (RW1C) to clear bits (EINT, PCD)

  // loop through event TRBs
  1:
    dc      civac, x10                            // invalidate cache for TRB
    dsb     sy                                    // ensure completion
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

    ubfx    x16, x11, #42, #6                     // x16 = TRB Type (from bits 42-47 of x11)

    cmp     x16, #34
    b.eq    port_status_change_event

    cmp     x16, #33
    b.eq    command_completion_event
.if UART_DEBUG
    adr     x0, msg_unknown_event
.endif
    b       panic

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
  and     w18, w18, #~0x2                         // Don't set bit 1 (PED) since this would disable port
  strwi   w18, x17, #0x410                        // write value back to clear RW1CS changes, potentially reset port
  tbnz    w19, #0, 2b                             // if resetting port, return and wait for next port status change

  // https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/extensible-host-controler-interface-usb-xhci.pdf
  // Section 6.4.3.2 (page 488)
  adrp    x1, command_ring                        // x1 = command_ring (virtual)
  mov     w2, (9 << 10) | 1                       // TRB Type = 9 (Enable Slot: see page 512 of xHCI spec)
  strxi   xzr, x1, #0x0
  strwi   wzr, x1, #0x8
  strwi   w2, x1, #0xc

  // Ensure link TRB is configured before first doorbell ring, since xHC may read arbitrarily ahead
  mov     x18, x1
  mov     w2, #0x4
  bfi     x18, x2, #32, #32                       // x18 = command_ring (DMA)
  strxi   x18, x1, #(command_ring_end - command_ring - 0x10)
  mov     w19, (6 << 10) | (1 << 1)               // TRB Type = 6 (Link TRB), Toggle Cycle = 1, Cycle = 0
  strwi   wzr, x1, #(command_ring_end - command_ring - 0x08)
  strwi   w19, x1, #(command_ring_end - command_ring - 0x04)

  dsb     sy                                      // ensure TRB writes are complete before ringing doorbell
  strwi   wzr, x15, #0x100                        // ring host controller doorbell (register 0)

  b       2b


command_completion_event:
.if UART_DEBUG
  adr     x0, msg_command_completion_event
  bl      uart_puts
.endif
  mov     w18, #0x4
  adrp    x16, command_ring
  subs    w1, w13, w16                            // calculate offset from start of command ring
  lsr     x16, x11, #56                           // x16 = Slot ID (from bits 56-63 of x11)
  b.eq    4f                                      // if offset from start of command ring 0 (i.e. first TRB), jump ahead to Enable Slot completion handling
  cmp     w1, #0x10                               // is it Address Device command?
  b.eq    5f                                      // if so, jump ahead to Address Device completion handling
.if UART_DEBUG
  adr     x0, msg_unknown_command_trb
.endif
  b       panic
4:
  // Handle Enable Slot command completion
  adrp    x17, dcbaa                              // x17 = dcbaa (virtual)
  add     x17, x17, x16, lsl #3                   // x17 = dcbaa[slotID]
  adrp    x16, keyboard_device_context            // conveniently sits at a 4KB page boundary
  strwi   w16, x17, #0x0
  strwi   w18, x17, #0x4                          // dcbaa[slotID] = keyboard_device_context (DMA)
  adrp    x17, keyboard_input_context_address_device
  add     x17, x17, :lo12:keyboard_input_context_address_device
  adrp    x1, command_ring                        // x1 = command_ring (virtual)
  mov     w2, (11 << 10) | 1                      // TRB Type = 11, BSR = 0 (Address Device: see page 511 of xHCI spec)
  orr     w2, w2, 0x01000000                      // Slot 1
  strwi   w17, x1, #0x10
  strwi   w18, x1, #0x14
  strwi   wzr, x1, #0x18
  strwi   w2, x1, #0x1c
  dsb     sy                                      // ensure TRB writes are complete before ringing doorbell
  strwi   wzr, x15, #0x100                        // ring host controller doorbell (register 0)
  b       2b
5:
  // Handle Address Device command completion

  // Create a GET_DESCRIPTOR request
  // Setup Stage
  // xHCI spec page 468
  adrp    x0, transfer_ring_keyboard_EP0
  add     x0, x0, :lo12:transfer_ring_keyboard_EP0
  ldr     x1, =0x0008000001000680                 // 0b0000000000001000 0000000000000000 0000000100000000 00000110 10000000
                                                  // wLength = 8 => descriptor length 8 bytes (duplicate of TRB transfer length in DATA STAGE?)
                                                  // wIndex = 0 => Zero or Language ID
                                                  // wValue 0x100 (256) => Descriptor Type 1 (DEVICE - page 251 of USB 2.0 spec) and Descriptor Index 0.
                                                  //   The descriptor index is used to select a specific descriptor (only for configuration and
                                                  //   string descriptors) when several descriptors of the same type are implemented in a device. For example, a
                                                  //   device can implement several configuration descriptors. For other standard descriptors that can be retrieved
                                                  //   via a GetDescriptor() request, a descriptor index of zero must be used. The range of values used for a
                                                  //   descriptor index is from 0 to one less than the number of descriptors of that type implemented by the device.
                                                  // bRequest 0x6 => GET_DESCRIPTOR (page 251 and sectio 9.4.3 on page 253 of USB 2.0 spec)
                                                  // bmRequestType 128 (0x80) => device to host, standard type, device recipient (page 248 of USB 2.0 spec)

  ldr     x2, =0x0003084100000008                 // 0b00000000000000 11 000010 000 1 0 0000 1 0000000000 00000 00000000000001000
                                                  // RsvdZ
                                                  // TRT (Transfer Type) = 3 (IN data stage) (p469 xHCI spec)
                                                  // TRB Type = 2 (Setup Stage) (p511 xHCI)
                                                  // RsvdZ
                                                  // IDT = 1 (required for setup stage - p469 xHCI spec)
                                                  // IOC = 0 (interrupt on completion not enabled - only needed on last TRB)
                                                  // RsvdZ
                                                  // C = 1 => cycle bit 1
                                                  // Interruptor Target = 0
                                                  // RsvdZ
                                                  // TRB Transfer Length = 8. Always 8 according to xHCI spec page 469.
  stp     x1, x2, [x0]

  // Data Stage
  // xHCI spec page 470
  adrp    x3, keyboard_descriptor
  add     x3, x3, :lo12:keyboard_descriptor       // Physical address of data buffer for keyboard descriptor

  ldr     x4, = 0x00010c0100000008                // 0b000000000000000 1 000011 000 0 0 0 0 0 0 1 0000000000 00000 00000000000001000
                                                  // RsvdZ
                                                  // DIR = 1. IN direction. p471.
                                                  // TRB Type = 3 (Data stage) (p511)
                                                  // RsvdZ
                                                  // IDT = 0 (immediate data: false, i.e. data is referenced via pointer)
                                                  // IOC = 0 (no interrupt on completion - only needed on last TRB)
                                                  // CH = 0 (end of chain, i.e. DATA STAGE is a single TRB)
                                                  // NS = 0 (no snoop - don't understand - see https://linux-usb.vger.kernel.narkive.com/2ODz0UCV/why-use-pci-express-no-snoop-option-for-xhci)
                                                  // ISP = 0 (interrupt on short packet disabled)
                                                  // ENT = 0 (evaluate next TRB disabled - see page 250, also not allowed since chain bit = 0)
                                                  // C = 1 (cycle bit)
                                                  // Interruptor Target = 0
                                                  // TD size = 0. The spec is very complicated here, and I don't understand it. xHCI spec page 218.
                                                  // TRB transfer length = 8 bytes. Looks like the host is free to set this to preferred value? p470.
  stp     w3, w18, [x0, #0x10]
  str     x4, [x0, #0x18]


  // Status Stage
  // xHCI spec page 472
                                                  // 0b00000000000000000000000000000000 00000000000000000000000000000000
                                                  // RsvdZ
                                                  // RsvdZ
  mov     x5, #0x0000102100000000                 // 0b000000000000000 0 000100 0000 1 0 00 0 1 0000000000 0000000000000000000000
                                                  // RsvdZ
                                                  // DIR = 0
                                                  // TRB Type = 4 (Status Stage) (p511)
                                                  // RsvdZ
                                                  // IOC = 1 (interrupt on completion)
                                                  // CH = 0 (last TRB of TD)
                                                  // RsvdZ
                                                  // ENT = 0
                                                  // C = 1
                                                  // Interruptor target = 0
                                                  // RsvdZ
  stp     xzr, x5, [x0, #0x20]

  // Create Link TRB before ringing doorbell, since xHC may reads ahead past last TRB
  mov     x18, x0
  mov     w2, #0x4
  bfi     x18, x2, #32, #32                       // x18 = transfer ring (DMA)
  strxi   x18, x0, #(transfer_ring_keyboard_EP0_end - transfer_ring_keyboard_EP0 - 0x10)
  mov     w19, (6 << 10) | (1 << 1)               // TRB Type = 6 (Link TRB), Toggle Cycle = 1, Cycle = 0
  strwi   wzr, x0, #(transfer_ring_keyboard_EP0_end - transfer_ring_keyboard_EP0 - 0x08)
  strwi   w19, x0, #(transfer_ring_keyboard_EP0_end - transfer_ring_keyboard_EP0 - 0x04)

  mov     w6, #0x1                                // Control EP0 Enqueue Pointer Update (page 431 xHCI spec)
  add     x16, x15, x16, lsl #2                   // x16 = 0x100 less than address of doorbell for slot number stored in x16
  dsb     sy                                      // ensure TRB writes are complete before ringing doorbell
  ldrwi   w3, x15, #0x24                          // TODO: remove this, just for debug: w3 = USBSTS
  strwi   w6, x16, #0x100                         // ring doorbell of device slot in w16
  ldrwi   w3, x15, #0x24                          // TODO: remove this, just for debug: w3 = USBSTS

  b       2b


panic:
.if UART_DEBUG
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
msg_unknown_command_trb:
  .asciz "Unknown Command TRB\r\n"
.endif


.data

# USB Keyboard Input Context (Address Device Command)
# https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/extensible-host-controler-interface-usb-xhci.pdf
# Section 6.2.5 (page 459)
.align 6
keyboard_input_context_address_device:
# Input Control Context
# https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/extensible-host-controler-interface-usb-xhci.pdf
# Section 6.2.5.1 (page 461)
.word 0x00000000
.word 0x00000003                                  // A0=1, A1=1
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
# Slot Context
# https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/extensible-host-controler-interface-usb-xhci.pdf
# Section 6.2.2 (page 444)
.word 0x08300000                                  // 0b00001 0 0 0 0011 00000000000000000000
.word 0x00010000                                  // 0b00000000 00000001 0000000000000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
                                                  // Context Entries = 1
                                                  // Hub = 0
                                                  // MTT (Multiple TT support) = 0 (disabled)
                                                  // Speed = 3
                                                  // Route String = 0
                                                  // Number of Ports = 0
                                                  // Root Hub Port Number = 1
# Endpoint Context
# https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/extensible-host-controler-interface-usb-xhci.pdf
# Section 6.2.3 (page 449)
.word 0x00000000                                  // 0b00000000 00000000 0 00000 00 00000 000; Max ESIT Payload Hi = 0; Interval = 0; LSA = 0; MaxPStreams = 0; Mult = 0; RsvdZ = 0; EP State = 0
.word 0x00400026                                  // 0b0000000001000000 00000000 0 0 100 11 0; Max Packet Size = 64; Max Burst Size = 0; HID = 0; RsvdZ = 0; EP Type = 4; CErr = 3; RsvdZ = 0
.dword (transfer_ring_keyboard_EP0-0xfffffff000000000+0x400000000+0x1)
                                                  // TR Dequeue Pointer = DMA(transfer_ring_keyboard_EP0); RsvdZ = 0; DCS = 1
.word 0x00000008                                  // 0b0000000000000000 0000000000001000; Max ESIT Payload Lo = 0; Average TB Length = 8
.word 0x00000000
.word 0x00000000
.word 0x00000000

                                                  // EP State = 0 (Disabled - required for input contexts)
                                                  // Mult = 0 (required for non-SS-Isochronous endpoint types)
                                                  // MaxPStreams = 0; streams not supported => TR Dequeue Pointer is a transfer ring
                                                  // LSA = 0; RsvdZ since MaxPStreams == 0
                                                  // Interval = 11 (=> send/receive every 256 ms)
                                                  // Max ESIT Payload = 0; RsvdZ since LEC == 0
                                                  // CErr = 3; 3 attempts before giving up on executing a TD
                                                  // EP Type = 4; Control (bidirectional)
                                                  // HID = 0; does not apply to non-stream-enabled endpoints
                                                  // Max Burst Size = 0 => burst size 1 (since encoding is zero-based)
                                                  // Max Packet Size = 64 bytes
                                                  // DCS = 1; Dequeue Cycle State (initially 1, alternates each time we loop around ring)
                                                  // TR Dequeue Pointer = DMA address (transfer_ring_keyboard_EP0)
