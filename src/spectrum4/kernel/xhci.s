# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# [XHCI] s5.3 p381 -- Host Controller Capability Registers (see references.inc for spec URL)


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
#                                                1: 64-bit Addressing Capability (AC64)
# 0x14: XHCI_REG_CAP_DBOFF        0x00000100 => Doorbell Array Offset = 0x100 (i.e. 0x600000100)
# 0x18: XHCI_REG_CAP_RTSOFF       0x00000200 => Runtime Register Space Offset (i.e. 0x600000200)
# 0x1c: XHCI_REG_CAP_HCCPARAMS2   0x00000000 0b  0: U3C U3 Entry Capability not supported (Port Suspend Complete notification not supported)
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
#    8:5: PLS = 5 => Port is in the RxDetect State [XHCI] s5.4.8 p406 Table 5-27
#                                                        [USB3] s7.5.3 p165
#    9: PP = 1 => Port is not powered off (I believe - need to check HCCPARAMS1.PPC to be sure)
#    13:10: PS = 0 => Port Speed is undefined speed
#    15:14: PIC = 0 => Port indicators are off
#    ...
#    21: PRC = 0 => No change to port reset status
#    ...
#    30: DR = 0 => Device is removable


# ring_write_trb — Write a TRB to any ring, handling cycle bit and link TRB wrapping.
#
# Inputs:
#   x0  = pointer to ring metadata block (32-byte struct: enqueue, PCS, start, end)
#   x1  = TRB dword 0-1 (data field, 8 bytes)
#   x2  = TRB dword 2-3 (status in lower 32, control in upper 32) — WITHOUT cycle bit set
#
# Outputs:
#   Ring metadata updated (enqueue pointer advanced, PCS toggled on wrap)
#
# Clobbers: x3, x4, x5
# Preserves: x0, x1, x2, x6-x30
.align 2
ring_write_trb:
  ldr     x3, [x0, #0x00]                         // x3 = current enqueue pointer
  ldrb    w4, [x0, #0x08]                         // w4 = PCS (0 or 1)
  bfi     x2, x4, #32, #1                         // set cycle bit (bit 0 of Control dword = bit 32 of x2) to PCS
  str     x1, [x3, #0x00]                         // write TRB data (dwords 0-1)
  str     x2, [x3, #0x08]                         // write TRB status+control (dwords 2-3) with cycle bit
  bfc     x2, #32, #1                             // clear cycle bit back out of x2 (restore caller's value)
  add     x3, x3, #16                             // advance enqueue to next slot
  ldr     x5, [x0, #0x18]                         // x5 = ring end
  sub     x5, x5, #16                             // x5 = last slot (link TRB position)
  cmp     x3, x5
  b.lo    1f                                      // if enqueue < link TRB slot, just store and return

  // Enqueue has reached the link TRB slot — handle wrapping
  // Update link TRB's cycle bit to match current PCS so xHC follows it
  ldr     w3, [x5, #0x0c]                         // w3 = link TRB control dword (at offset 0x0c from link TRB)
  bfi     w3, w4, #0, #1                          // set link TRB cycle bit (bit 0 of control dword) to current PCS
  str     w3, [x5, #0x0c]                         // write back link TRB control

  // Toggle PCS
  eor     w4, w4, #1                              // toggle PCS
  strb    w4, [x0, #0x08]                         // store new PCS

  // Reset enqueue to ring start
  ldr     x3, [x0, #0x10]                         // x3 = ring start
1:
  str     x3, [x0, #0x00]                         // store updated enqueue pointer
  ret


# Note: preserve x7 and x8 since caller (handle_irq_bcm2711) uses these
.align 2
handle_xhci_irq:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
.if UART_DEBUG
  adr     x0, msg_xhci_event
  bl      uart_puts
.endif
  adrp    x9, 0xfd504000 + _start                 // x9 = Broadcom PCIe STB register base (MSI registers at x9+0x500)
                                                  // BCM2711-proprietary MSI controller registers; see Linux kernel:
                                                  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c
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
                                                  // PCIe BAR mapped to 0x600000000 by pcie_init_bcm2711 in pcie.s
  ldrwi   w13, x15, #0x20                         // TODO: remove this, just for debug: log USBCMD to see if RUN_STOP (bit 0) is clear or set

  ldrwi   w3, x15, #0x24                          // Read USBSTS in w3
  strwi   w3, x15, #0x24                          // Write back (RW1C) to clear status bits: bit 3 EINT (Event Interrupt), bit 4 PCD (Port Change Detect)

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
                                                  // [XHCI] s4.11.3 p222 -- Event TRBs: TRB Type is in bits 15:10 of DWORD3 (= bits 42-47 of 128-bit TRB)
    cmp     x16, #34                              // [XHCI] s6.4.6 p511 Table 6-91 -- TRB Type 34 = Port Status Change Event
    b.eq    port_status_change_event

    cmp     x16, #33                              // [XHCI] s6.4.6 p511 Table 6-91 -- TRB Type 33 = Command Completion Event
    b.eq    command_completion_event

    cmp     x16, #32                              // [XHCI] s6.4.6 p511 Table 6-91 -- TRB Type 32 = Transfer Event
    b.eq    transfer_event

.if UART_DEBUG
    adr     x0, msg_unknown_event
.endif
    b       panic

                                                  // [XHCI] s4.9.4 p179 -- Event Ring Management: dequeue pointer advancement and CCS toggle
2:
    add     x10, x10, #16                         // Bump x10 to next event TRB entry (potentially overrunning event ring)
    and     x13, x10, #0xfff                      // x13 = offset within page (= offset from ring start, since event ring is page-aligned and < 4KB)
    cmp     x13, #(event_ring_end-event_ring)     // check if x10 has overrun the ring
    b.ne    1b                                    // if not, loop around
    and     x10, x10, #~0xfff                     // wrap: reset x10 to start of ring (clear page offset)
    eor     x14, x14, #(1<<32)                    // toggle Event Consumer Cycle Status bit
    strxi   x14, x12, xhci_event_ccs-xhci_vars    // store it
    b       1b                                    // loop around
3:
                                                  // [XHCI] s5.5.2 p424 -- Interrupter Register Set: ERDP at offset 0x18 from interrupter 0 base (0x220)
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
  add     x17, x15, x17, lsl #4                   // x17 = base + port_number*16; PORTSC[n] is at base+0x420+(n-1)*16, reached via [x17, #0x410]
  ldrwi   w18, x17, #0x410                        // w18 = [PORTSC for port_number] (e.g. port 1 => base+0x420)
  ubfx    w19, w18, #1, #1                        // w19 = bit 1 of w18 = PED (port enabled)
  eor     w19, w19, #1                            // invert w19 bit 0 i.e. 0 if port enabled, 1 if port disabled
  bfi     w18, w19, #4, #1                        // PR (port reset) = 0 if port enabled, 1 if port disabled
  and     w18, w18, #~0x2                         // Don't set bit 1 (PED) since this would disable port
  strwi   w18, x17, #0x410                        // write value back to clear RW1CS changes, potentially reset port
  tbnz    w19, #0, 2b                             // if resetting port, return and wait for next port status change

  // Port is enabled — issue Enable Slot command via ring_write_trb
  // [XHCI] s6.4.3.2 p488 -- Enable Slot Command TRB
  adr     x0, xhci_cmd_ring_meta
  mov     x1, xzr                                 // TRB data = 0
  mov     w2, #(9 << 10)                          // Control: TRB Type = 9 (Enable Slot) [XHCI] s6.4.6 p511 Table 6-91
  lsl     x2, x2, #32                             // shift into upper 32 bits (Control dword); Status = 0
  bl      ring_write_trb

  // Set callback for command completion
  adr     x3, handle_enable_slot_done
  str     x3, [x12, #xhci_command_handler-xhci_vars]

  dsb     sy                                      // ensure TRB writes are complete before ringing doorbell
  strwi   wzr, x15, #0x100                        // ring host controller doorbell (register 0) [XHCI] s5.6 p429

  b       2b


handle_enable_slot_done:
  // Handle Enable Slot command completion
  // x11 bits 56-63 = Slot ID [XHCI] s6.4.2.1 p487 -- Command Completion Event TRB
  lsr     x16, x11, #56                           // x16 = Slot ID
  mov     w18, #0x4                               // upper 32 bits for DMA addresses
  adrp    x17, dcbaa                              // x17 = dcbaa (virtual)
  add     x17, x17, x16, lsl #3                   // x17 = dcbaa[slotID]
  adrp    x16, slot1_device_context               // conveniently sits at a 4KB page boundary
  strwi   w16, x17, #0x0
  strwi   w18, x17, #0x4                          // dcbaa[slotID] = slot1_device_context (DMA)

  // Issue Address Device command via ring_write_trb
  // [XHCI] s6.4.3.4 p490 -- Address Device Command TRB
  adrp    x17, slot1_input_context
  add     x17, x17, :lo12:slot1_input_context
  mov     x1, x17                                 // TRB data = slot1_input_context (virtual)
  bfi     x1, x18, #32, #32                       // TRB data = slot1_input_context (DMA)
  ldr     x2, =0x01002C0000000000                 // Control: TRB Type=11 (Address Device), Slot 1; Status=0
  adr     x0, xhci_cmd_ring_meta
  bl      ring_write_trb

  // Set callback for Address Device completion
  adr     x3, handle_address_device_done
  str     x3, [x12, #xhci_command_handler-xhci_vars]

  dsb     sy                                      // ensure TRB writes are complete before ringing doorbell
  strwi   wzr, x15, #0x100                        // ring host controller doorbell (register 0) [XHCI] s5.6 p429

  b       2b


handle_address_device_done:
  // Handle Address Device command completion — issue GET_DESCRIPTOR(device, 8 bytes) on slot 1 EP0

  // Setup Stage TRB
  // [XHCI] s6.4.1.2.1 p468 -- Setup Stage TRB
  adr     x0, xhci_xfer_s1e0_ring_meta
  ldr     x1, =0x0008000001000680                 // bmRequestType=0x80 (device-to-host), bRequest=0x06 (GET_DESCRIPTOR),
                                                  // wValue=0x0100 (Device descriptor, index 0), wIndex=0, wLength=8
  ldr     x2, =0x0003084000000008                 // Control: TRB Type=2 (Setup Stage), TRT=3 (IN), IDT=1; Status: Transfer Length=8
                                                  // cycle bit NOT set — ring_write_trb handles it
  bl      ring_write_trb

  // Data Stage TRB
  // [XHCI] s6.4.1.2.2 p470 -- Data Stage TRB
  adrp    x1, slot1_descriptor
  add     x1, x1, :lo12:slot1_descriptor          // x1 = slot1_descriptor (virtual)
  mov     w3, #0x4
  bfi     x1, x3, #32, #32                        // x1 = slot1_descriptor (DMA)
  ldr     x2, =0x00010C0000000008                 // Control: TRB Type=3 (Data Stage), DIR=1 (IN); Status: Transfer Length=8
                                                  // cycle bit NOT set — ring_write_trb handles it
  bl      ring_write_trb

  // Status Stage TRB
  // [XHCI] s6.4.1.2.3 p472 -- Status Stage TRB
  mov     x1, xzr                                 // TRB data = 0
  mov     x2, #0x0000102000000000                 // Control: TRB Type=4 (Status Stage), IOC=1; Status=0
                                                  // cycle bit NOT set — ring_write_trb handles it
  bl      ring_write_trb

  // Set callback for transfer completion
  adr     x3, handle_get_device_descriptor_8_done
  str     x3, [x12, #xhci_transfer_handler-xhci_vars]

  dsb     sy                                      // ensure TRB writes are complete before ringing doorbell

  // Ring slot 1 doorbell, EP0 target = 1
  // [XHCI] s5.6 p429 Table 5-43
  mov     w6, #0x1                                // DB Target = 1 (Control EP0 Enqueue Pointer Update)
  strwi   w6, x15, #0x104                         // ring doorbell register 1 (slot 1)

  b       2b


handle_get_device_descriptor_8_done:
  // Handle GET_DESCRIPTOR(device, 8 bytes) transfer completion
  // Verify bMaxPacketSize0 (byte 7) matches HS default (64)
  // [XHCI] s4.6.5 p111 -- Evaluate Context for EP0 Max Packet Size
  adrp    x3, slot1_descriptor
  add     x3, x3, :lo12:slot1_descriptor
  dc      ivac, x3
  dsb     ish
  ldrxi   x18, x3, #0x0                           // x18 = first 8 bytes of device descriptor
.if UART_DEBUG
  lsr     x0, x18, #56                            // x0 = byte 7 = bMaxPacketSize0
  cmp     w0, #64
  b.eq    1f
  adr     x0, msg_unexpected_max_packet_size
  b       panic
1:
.endif

  // Issue GET_DESCRIPTOR(device, wLength=18) on slot 1 EP0
  // [USB2] s9.4.3 p253 -- Get Descriptor
  adr     x0, xhci_xfer_s1e0_ring_meta

  // Setup Stage TRB
  ldr     x1, =0x0012000001000680                 // bmRequestType=0x80, bRequest=0x06 (GET_DESCRIPTOR),
                                                  // wValue=0x0100 (Device, index 0), wIndex=0, wLength=18
  ldr     x2, =0x0003084000000008                 // TRB Type=2 (Setup Stage), TRT=3 (IN), IDT=1; Transfer Length=8
  bl      ring_write_trb

  // Data Stage TRB
  adrp    x1, slot1_descriptor
  add     x1, x1, :lo12:slot1_descriptor
  mov     w3, #0x4
  bfi     x1, x3, #32, #32                        // x1 = slot1_descriptor (DMA)
  ldr     x2, =0x00010C0000000012                 // TRB Type=3 (Data Stage), DIR=1 (IN); Transfer Length=18
  bl      ring_write_trb

  // Status Stage TRB
  mov     x1, xzr
  mov     x2, #0x0000102000000000                 // TRB Type=4 (Status Stage), IOC=1
  bl      ring_write_trb

  adr     x3, handle_get_device_descriptor_done
  str     x3, [x12, #xhci_transfer_handler-xhci_vars]
  dsb     sy
  mov     w6, #0x1
  strwi   w6, x15, #0x104                         // ring slot 1 doorbell
  b       2b


handle_get_device_descriptor_done:
  // Handle GET_DESCRIPTOR(device, 18 bytes) transfer completion
  // Read full 18-byte device descriptor, verify bDeviceClass=0x09 (hub)
  // [USB2] s9.6.1 p261 -- Device Descriptor
  adrp    x3, slot1_descriptor
  add     x3, x3, :lo12:slot1_descriptor
  dc      ivac, x3
  dsb     ish
  ldrxi   x18, x3, #0x0                           // bytes 0-7
  ldrxi   x19, x3, #0x8                           // bytes 8-15
.if UART_DEBUG
  ubfx    w0, w18, #24, #8                        // w0 = byte 3 = bDeviceClass (should be 0x09 for hub)
  // we expect bDeviceClass=0x09 for a hub
.endif

  // Issue GET_DESCRIPTOR(configuration, wLength=9) on slot 1 EP0 — header only
  // [USB2] s9.4.3 p253 -- Get Descriptor; [USB2] s9.6.3 p264 -- Configuration Descriptor
  adr     x0, xhci_xfer_s1e0_ring_meta

  // Setup Stage TRB
  ldr     x1, =0x0009000002000680                 // bmRequestType=0x80, bRequest=0x06 (GET_DESCRIPTOR),
                                                  // wValue=0x0200 (Configuration, index 0), wIndex=0, wLength=9
  ldr     x2, =0x0003084000000008                 // TRB Type=2 (Setup Stage), TRT=3 (IN), IDT=1; Transfer Length=8
  bl      ring_write_trb

  // Data Stage TRB
  adrp    x1, slot1_descriptor
  add     x1, x1, :lo12:slot1_descriptor
  mov     w3, #0x4
  bfi     x1, x3, #32, #32
  ldr     x2, =0x00010C0000000009                 // TRB Type=3 (Data Stage), DIR=1 (IN); Transfer Length=9
  bl      ring_write_trb

  // Status Stage TRB
  mov     x1, xzr
  mov     x2, #0x0000102000000000                 // TRB Type=4 (Status Stage), IOC=1
  bl      ring_write_trb

  adr     x3, handle_get_config_descriptor_header_done
  str     x3, [x12, #xhci_transfer_handler-xhci_vars]
  dsb     sy
  mov     w6, #0x1
  strwi   w6, x15, #0x104
  b       2b


handle_get_config_descriptor_header_done:
  // Handle GET_DESCRIPTOR(configuration, 9 bytes) — extract wTotalLength, request full descriptor
  // [USB2] s9.6.3 p264 -- Configuration Descriptor
  adrp    x3, slot1_descriptor
  add     x3, x3, :lo12:slot1_descriptor
  dc      ivac, x3
  dsb     ish
  ldrxi   x18, x3, #0x0                           // bytes 0-7 of config descriptor

  // wTotalLength is bytes 2-3 (LE)
  ubfx    w16, w18, #16, #16                      // w16 = wTotalLength

  // Issue GET_DESCRIPTOR(configuration, wLength=wTotalLength) — full descriptor tree
  adr     x0, xhci_xfer_s1e0_ring_meta

  // Setup Stage TRB — wLength = wTotalLength
  // bmRequestType=0x80, bRequest=0x06, wValue=0x0200, wIndex=0, wLength=w16
  ldr     x1, =0x0000000002000680                 // bmRequestType=0x80, bRequest=0x06, wValue=0x0200, wIndex=0
  bfi     x1, x16, #48, #16                       // insert wLength at bytes 6-7

  ldr     x2, =0x0003084000000008                 // TRB Type=2 (Setup Stage), TRT=3 (IN), IDT=1; Transfer Length=8
  bl      ring_write_trb

  // Data Stage TRB — Transfer Length = wTotalLength
  adrp    x1, slot1_descriptor
  add     x1, x1, :lo12:slot1_descriptor
  mov     w3, #0x4
  bfi     x1, x3, #32, #32
  ldr     x2, =0x00010C0000000000                 // TRB Type=3 (Data Stage), DIR=1 (IN)
  orr     x2, x2, x16                             // insert Transfer Length in lower 17 bits of status
  bl      ring_write_trb

  // Status Stage TRB
  mov     x1, xzr
  mov     x2, #0x0000102000000000                 // TRB Type=4 (Status Stage), IOC=1
  bl      ring_write_trb

  adr     x3, handle_get_config_descriptor_full_done
  str     x3, [x12, #xhci_transfer_handler-xhci_vars]
  dsb     sy
  mov     w6, #0x1
  strwi   w6, x15, #0x104
  b       2b


handle_get_config_descriptor_full_done:
  // Handle GET_DESCRIPTOR(configuration, full) — parse configuration descriptor tree
  // Layout: Configuration Descriptor (9) + Interface Descriptor (9) + Endpoint Descriptor (7)
  // [USB2] s9.6.3 p264 -- Configuration Descriptor
  // [USB2] s9.6.5 p267 -- Interface Descriptor
  // [USB2] s9.6.6 p269 -- Endpoint Descriptor
  adrp    x3, slot1_descriptor
  add     x3, x3, :lo12:slot1_descriptor
  dc      ivac, x3
  add     x4, x3, #0x40                           // invalidate second cache line (descriptors may span 2 lines)
  dc      ivac, x4
  dsb     ish

  // Configuration Descriptor (bytes 0-8):
  //   byte 5 = bConfigurationValue
  ldrb    w16, [x3, #5]                           // w16 = bConfigurationValue
  strb    w16, [x12, #xhci_hub_config_value-xhci_vars]

  // Interface Descriptor (bytes 9-17):
  //   byte 14 (offset 9+5) = bInterfaceClass — should be 0x09 (hub)
.if UART_DEBUG
  ldrb    w0, [x3, #14]
  cmp     w0, #0x09
  b.eq    1f
  adr     x0, msg_not_a_hub
  b       panic
1:
.endif

  // Endpoint Descriptor (bytes 18-24):
  //   byte 18 (offset 18+0) = bLength
  //   byte 19 (offset 18+1) = bDescriptorType (should be 5 = endpoint)
  //   byte 20 (offset 18+2) = bEndpointAddress
  //   byte 21 (offset 18+3) = bmAttributes
  //   bytes 22-23 (offset 18+4) = wMaxPacketSize (LE)
  //   byte 24 (offset 18+6) = bInterval
  ldrb    w17, [x3, #22]                          // wMaxPacketSize lo
  ldrb    w18, [x3, #23]                          // wMaxPacketSize hi
  orr     w17, w17, w18, lsl #8                   // w17 = wMaxPacketSize
  strh    w17, [x12, #xhci_hub_ep_max_pkt-xhci_vars]

  ldrb    w18, [x3, #24]                          // w18 = bInterval
  strb    w18, [x12, #xhci_hub_ep_interval-xhci_vars]

  // Issue GET_DESCRIPTOR(hub class) — get bNbrPorts before SET_CONFIGURATION
  // so we have it for the Configure Endpoint input context
  // [USB2] s11.24.2.5 p423 -- Get Hub Descriptor
  adr     x0, xhci_xfer_s1e0_ring_meta

  // Setup Stage TRB
  // bmRequestType=0xA0 (class, device, device-to-host), bRequest=0x06 (GET_DESCRIPTOR),
  // wValue=0x2900 (hub descriptor, index 0), wIndex=0, wLength=8 (min hub descriptor size)
  ldr     x1, =0x00080000290006A0
  ldr     x2, =0x0003084000000008                 // TRB Type=2, TRT=3, IDT=1; Transfer Length=8
  bl      ring_write_trb

  // Data Stage TRB
  adrp    x1, slot1_descriptor
  add     x1, x1, :lo12:slot1_descriptor
  mov     w3, #0x4
  bfi     x1, x3, #32, #32
  ldr     x2, =0x00010C0000000008                 // TRB Type=3, DIR=1; Transfer Length=8
  bl      ring_write_trb

  // Status Stage TRB
  mov     x1, xzr
  mov     x2, #0x0000102000000000
  bl      ring_write_trb

  adr     x3, handle_get_hub_descriptor_done
  str     x3, [x12, #xhci_transfer_handler-xhci_vars]
  dsb     sy
  mov     w6, #0x1
  strwi   w6, x15, #0x104
  b       2b


handle_get_hub_descriptor_done:
  // Handle GET_DESCRIPTOR(hub class) — extract bNbrPorts, prepare input context, issue SET_CONFIGURATION
  // [USB2] s11.23.2.1 p417 -- Hub Descriptor
  //   byte 0 = bDescLength
  //   byte 1 = bDescriptorType (0x29)
  //   byte 2 = bNbrPorts
  //   byte 3 = wHubCharacteristics lo
  //   byte 4 = wHubCharacteristics hi
  //   byte 5 = bPwrOn2PwrGood
  adrp    x3, slot1_descriptor
  add     x3, x3, :lo12:slot1_descriptor
  dc      ivac, x3
  dsb     ish
  ldrxi   x18, x3, #0x0                           // x18 = first 8 bytes of hub descriptor

  ubfx    w16, w18, #16, #8                       // w16 = byte 2 = bNbrPorts
  strb    w16, [x12, #xhci_hub_num_ports-xhci_vars]

  // Prepare slot1_input_context for Configure Endpoint
  // Update Input Control Context: Add Flags = A0 (Slot) | A3 (EP1 IN)
  adrp    x17, slot1_input_context
  add     x17, x17, :lo12:slot1_input_context
  mov     w19, #0x09                              // A0=1 (Slot), A3=1 (EP1 IN DCI=3)
  str     w19, [x17, #0x04]                       // Input Control Context DWORD1 = Add Flags

  // Update Slot Context for hub
  // DWORD0: Context Entries=3, Hub=1, Speed=3 (HS), Route String=0
  //   Context Entries (31:27) = 3 => 0x18000000
  //   Hub (26) = 1 => 0x04000000
  //   Speed (23:20) = 3 => 0x00300000
  mov     w19, #0x1C300000                        // Context Entries=3, Hub=1, Speed=3 (HS)
  str     w19, [x17, #0x20]                       // Slot Context DWORD0

  // DWORD1: Root Hub Port Number=1, Number of Ports=bNbrPorts
  //   Number of Ports (31:24) = bNbrPorts
  //   Root Hub Port Number (23:16) = 1
  mov     w19, #0x00010000                        // Root Hub Port Number = 1
  orr     w19, w19, w16, lsl #24                  // Number of Ports = bNbrPorts
  str     w19, [x17, #0x24]                       // Slot Context DWORD1

  // Update EP1 IN Context (at offset 0x80 from input context start)
  // DWORD0: Interval from endpoint descriptor; for HS interrupt, Interval = bInterval
  ldrb    w19, [x12, #xhci_hub_ep_interval-xhci_vars]
  lsl     w19, w19, #16                           // Interval field is bits 23:16
  str     w19, [x17, #0x80]                       // EP1 IN DWORD0

  // DWORD1: CErr=3, EP Type=7 (Interrupt IN), Max Packet Size from descriptor
  //   CErr (2:1) = 3 => bits 1-2 = 0x6
  //   EP Type (5:3) = 7 (Interrupt IN) => bits 3-5 = 0x38
  //   Max Packet Size (31:16)
  ldrh    w19, [x12, #xhci_hub_ep_max_pkt-xhci_vars]
  lsl     w19, w19, #16                           // Max Packet Size in bits 31:16
  orr     w19, w19, #0x3E                         // CErr=3 (bits 2:1=0x6), EP Type=7 (bits 5:3=0x38) = 0x06|0x38 = 0x3E
  str     w19, [x17, #0x84]                       // EP1 IN DWORD1

  // DWORD4: Average TRB Length = wMaxPacketSize
  ldrh    w19, [x12, #xhci_hub_ep_max_pkt-xhci_vars]
  str     w19, [x17, #0x90]                       // EP1 IN DWORD4

  // Cache clean the input context (it's in .data = cacheable memory)
  dc      cvac, x17                               // clean cache line at x17 (input control + slot context)
  add     x4, x17, #0x40
  dc      cvac, x4                                // clean EP0 context area
  add     x4, x4, #0x40
  dc      cvac, x4                                // clean EP1 OUT + EP1 IN context area
  dsb     sy

  // Issue SET_CONFIGURATION(bConfigurationValue) on slot 1 EP0
  // [USB2] s9.4.7 p256 -- Set Configuration
  adr     x0, xhci_xfer_s1e0_ring_meta

  // Setup Stage TRB (no data stage)
  // bmRequestType=0x00 (host-to-device, standard, device), bRequest=0x09 (SET_CONFIGURATION),
  // wValue=bConfigurationValue, wIndex=0, wLength=0
  ldrb    w16, [x12, #xhci_hub_config_value-xhci_vars]
  mov     x1, #0x0000000000000900                 // bmRequestType=0x00, bRequest=0x09
  bfi     x1, x16, #16, #8                        // wValue = bConfigurationValue

  ldr     x2, =0x0000084000000008                 // TRB Type=2 (Setup Stage), TRT=0 (No Data Stage), IDT=1; Transfer Length=8
  bl      ring_write_trb

  // Status Stage TRB (DIR=1 for no-data-stage control transfers)
  // [XHCI] s6.4.1.2.3 p472 -- "set to '1' (IN)" for no data stage
  mov     x1, xzr
  ldr     x2, =0x0001102000000000                 // TRB Type=4, IOC=1, DIR=1 (IN)
  bl      ring_write_trb

  adr     x3, handle_set_configuration_hub_done
  str     x3, [x12, #xhci_transfer_handler-xhci_vars]
  dsb     sy
  mov     w6, #0x1
  strwi   w6, x15, #0x104
  b       2b


handle_set_configuration_hub_done:
  // Handle SET_CONFIGURATION transfer completion — issue Configure Endpoint command
  // [XHCI] s4.6.6 p115 -- Configure Endpoint; [XHCI] s6.4.3.5 p491 -- Configure Endpoint Command TRB

  // Input context is already prepared (handle_get_hub_descriptor_done did it)
  adrp    x17, slot1_input_context
  add     x17, x17, :lo12:slot1_input_context
  mov     x1, x17                                 // TRB data = slot1_input_context (virtual)
  mov     w18, #0x4
  bfi     x1, x18, #32, #32                       // TRB data = slot1_input_context (DMA)
  ldr     x2, =0x0100300000000000                 // Control: TRB Type=12 (Configure Endpoint), Slot 1; Status=0
  adr     x0, xhci_cmd_ring_meta
  bl      ring_write_trb

  adr     x3, handle_configure_endpoint_hub_done
  str     x3, [x12, #xhci_command_handler-xhci_vars]

  dsb     sy
  strwi   wzr, x15, #0x100                        // ring host controller doorbell (register 0)
  b       2b


handle_configure_endpoint_hub_done:
  // Handle Configure Endpoint command completion — hub is fully configured
  // End of Chunk B. Chunk C starts with SET_PORT_FEATURE(PORT_POWER).
  b       2b


command_completion_event:
.if UART_DEBUG
  adr     x0, msg_command_completion_event
  bl      uart_puts
.endif
  ubfx    w0, w11, #24, #8                        // w0 = Completion Code (bits 31:24 of Status field)
  cmp     w0, #1                                  // 1 = Success [XHCI] s6.4.5 p507 Table 6-90
  b.eq    1f
.if UART_DEBUG
  adr     x0, msg_command_failed
.endif
  b       panic
1:
  ldr     x3, [x12, #xhci_command_handler-xhci_vars]
  br      x3


transfer_event:
.if UART_DEBUG
  adr     x0, msg_transfer_event
  bl      uart_puts
.endif
  ubfx    w0, w11, #24, #8                        // w0 = Completion Code (bits 31:24 of Status field)
  cmp     w0, #1                                  // 1 = Success [XHCI] s6.4.5 p507 Table 6-90
  b.eq    1f
.if UART_DEBUG
  adr     x0, msg_transfer_failed
.endif
  b       panic
1:
  ldr     x3, [x12, #xhci_transfer_handler-xhci_vars]
  br      x3


panic:
.if UART_DEBUG
  bl      uart_puts
.endif
  b       sleep

xhci_unexpected_event:
.if UART_DEBUG
  adr     x0, msg_unexpected_handler
.endif
  b       panic


.if UART_DEBUG
msg_xhci_event:
  .asciz "XHCI MSI vector status: "
msg_port_status_change_event:
  .asciz "XHCI Port Status Change Event\r\n"
msg_command_completion_event:
  .asciz "XHCI Command Completion Event\r\n"
msg_transfer_event:
  .asciz "XHCI Transfer Event\r\n"
msg_unknown_event:
  .asciz "Unknown XHCI Event\r\n"
msg_command_failed:
  .asciz "XHCI command failed"
msg_transfer_failed:
  .asciz "XHCI transfer failed"
msg_unexpected_handler:
  .asciz "Unexpected xHCI completion (no handler set)\r\n"
msg_unexpected_max_packet_size:
  .asciz "bMaxPacketSize0 != 64 for HS hub\r\n"
msg_not_a_hub:
  .asciz "bInterfaceClass != 0x09 (not a hub)\r\n"
.endif


.data

# TODO: Consider moving this to .bss.coherent (non-cacheable) region. Currently in .data
# (Normal Cacheable, AttrIndx 0). The xHC DMA-reads this during Address Device command.
# Static .data is safe IF the CPU never modifies the cache lines, but placing it in the
# coherent region alongside other DMA buffers would be cleaner and avoid any risk of
# dirty cache line write-backs from adjacent data affecting the xHC's view.
#
# USB Slot 1 Input Context (Address Device Command)
# Note: Slot 1 is the VL805's internal USB 2.0 hub (bDeviceClass=0x09, bDeviceProtocol=0x01 single TT).
# A USB keyboard would be connected downstream of this hub, requiring hub enumeration first.
# [XHCI] s6.2.5 p459 -- Input Context
.align 6
slot1_input_context:
# Input Control Context
# [XHCI] s6.2.5.1 p461 -- Input Control Context
.word 0x00000000
.word 0x00000003                                  // A0=1, A1=1
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
# Slot Context
# [XHCI] s6.2.2 p444 -- Slot Context
.word 0x08300000                                  // 0b00001 0 0 0 0011 00000000000000000000
.word 0x00010000                                  // 0b00000000 00000001 0000000000000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
                                                  // Context Entries = 1 (only EP0 configured at Address Device time)
                                                  // Hub = 0 (set to 0 for Address Device; would be updated via Configure Endpoint after reading hub descriptor)
                                                  // MTT (Multiple TT support) = 0 (disabled; hub reports single TT via bDeviceProtocol=0x01)
                                                  // Speed = 3 (High Speed / USB 2.0 - matches port 1's Supported Protocol capability)
                                                  // Route String = 0 (directly attached to root hub port, no upstream hubs)
                                                  // Number of Ports = 0 (set to 0 for Address Device; would be updated after reading hub descriptor)
                                                  // Root Hub Port Number = 1 (VL805 port 1 = internal USB 2.0 hub)
# Endpoint Context
# [XHCI] s6.2.3 p449 -- Endpoint Context
.word 0x00000000                                  // 0b00000000 00000000 0 00000 00 00000 000; Max ESIT Payload Hi = 0; Interval = 0; LSA = 0; MaxPStreams = 0; Mult = 0; RsvdZ = 0; EP State = 0
.word 0x00400026                                  // 0b0000000001000000 00000000 0 0 100 11 0; Max Packet Size = 64; Max Burst Size = 0; HID = 0; RsvdZ = 0; EP Type = 4; CErr = 3; RsvdZ = 0
.dword (transfer_ring_slot1_EP0-0xfffffff000000000+0x400000000+0x1)
                                                  // TR Dequeue Pointer = DMA(transfer_ring_slot1_EP0); RsvdZ = 0; DCS = 1
.word 0x00000008                                  // 0b0000000000000000 0000000000001000; Max ESIT Payload Lo = 0; Average TRB Length = 8
.word 0x00000000
.word 0x00000000
.word 0x00000000

                                                  // EP State = 0 (Disabled - required for input contexts)
                                                  // Mult = 0 (required for non-SS-Isochronous endpoint types)
                                                  // MaxPStreams = 0; streams not supported => TR Dequeue Pointer is a transfer ring
                                                  // LSA = 0; RsvdZ since MaxPStreams == 0
                                                  // Interval = 0 (don't care for Control endpoints) [XHCI] s6.2.3.6 p456
                                                  // Max ESIT Payload Hi = 0; RsvdZ since LEC == 0 (bits 31:24 of DWORD0)
                                                  // Max ESIT Payload Lo = 0; RsvdZ since LEC == 0 (bits 31:16 of DWORD4)
                                                  // CErr = 3; 3 attempts before giving up on executing a TD
                                                  // EP Type = 4; Control (bidirectional)
                                                  // HID = 0; does not apply to non-stream-enabled endpoints
                                                  // Max Burst Size = 0 => burst size 1 (since encoding is zero-based)
                                                  // Max Packet Size = 64 bytes (USB 2.0 High Speed devices always use 64 bytes for EP0;
                                                  //   no need to start with 8 and update as you would for Full Speed devices)
                                                  // DCS = 1; Dequeue Cycle State (initially 1, alternates each time we loop around ring)
                                                  // Average TRB Length = 8 bytes (bits 15:0 of DWORD4; used by xHC for bandwidth scheduling)
                                                  // TR Dequeue Pointer = DMA address (transfer_ring_slot1_EP0)

# EP1 OUT Context (DCI 2) — unused placeholder, required to reach EP1 IN at correct offset
# [XHCI] s6.2.3 p449 -- Endpoint Context
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000
.word 0x00000000

# EP1 IN Context (DCI 3) — hub interrupt endpoint; populated at runtime by handle_get_config_descriptor_full_done
# [XHCI] s6.2.3 p449 -- Endpoint Context
slot1_input_ep1in:
.word 0x00000000                                  // DWORD0: Interval, etc. — filled at runtime
.word 0x00000000                                  // DWORD1: CErr, EP Type, Max Packet Size — filled at runtime
.dword (transfer_ring_slot1_EP1-0xfffffff000000000+0x400000000+0x1)
                                                  // TR Dequeue Pointer = DMA(transfer_ring_slot1_EP1); DCS = 1
.word 0x00000000                                  // DWORD4: Average TRB Length — filled at runtime
.word 0x00000000
.word 0x00000000
.word 0x00000000
