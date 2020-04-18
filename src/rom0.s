# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.align 2
.text


# Entry point for NEW (with interrupts disabled when running in bare metal since this routine will enable interrupts)
new:
  adr     x0, chars - (0x20 * 0x20)     // x0 = where, in theory character zero would be.
  str     x0, [x28, CHARS-sysvars]        // [CHARS] = theoretical address of char zero.
  ldr     x1, [x28, RAMTOP-sysvars]       // x1 = [RAMTOP].
  add     x1, x1, 1                       // x1 = [RAMTOP] + 1.
  and     sp, x1, 0xfffffff0              // sp = highest 16-byte aligned address equal to or lower than ([RAMTOP] + 1).
  mrs     x0, currentel
  str     x0, [sp, -16]!
  lsr     x0, x0, #2
  cmp     x0, 3
  b.ne    1f
# Start L1 Cache
  mrs     x0, sctlr_el3                   // x0 = System Control Register
  orr     x0, x0, 0x0004                  // Data Cache (Bit 2)
# orr     x0, x0, 0x0800                  // Branch Prediction (Bit 11) - this seems to be undocumented in ARM ARM
                                          // see: https://www.raspberrypi.org/forums/viewtopic.php?f=72&t=269441
  orr     x0, x0, 0x1000                  // Instruction Caches (Bit 12)
  msr     sctlr_el3, x0                   // System Control Register = x0
  str     x0, [sp, 8]
  b       2f
1:
  cmp     x0, 2
  b.ne    2f
  mrs     x0, sctlr_el2                   // 0000000030c50830
  str     x0, [sp, 8]                     // 0000 0000 0000 0000 0000 0000 0000 0000
                                          // 0011 0000 1100 0101 0000 1000 0011 0000
                                          //
                                          // RES0: 0b00000000000000000000000000000000
                                          // EnIA: 0b0 => RES0 in v8.0 (pointer auth)
                                          // EnIB: 0b0 => RES0 in v8.0 (pointer auth)
                                          // RES1: 0b11
                                          // EnDA: 0b0 => RES0 in v8.0 (pointer auth)
                                          // RES0: 0b0
                                          // EE: 0b0 => little endian translation table walks
                                          // RES0: 0b0
                                          // RES1: 0b11
                                          // IESB: 0b0 => RES0 in v8.0 (error sync event / debug)
                                          // RES0: 0b0
                                          // WXN: 0b0 => UNKNOWN since PE resets to EL2 (write execute never)
                                          // RES1: 0b1
                                          // RES0: 0b0
                                          // RES1: 0b1
                                          // RES0: 0b00
                                          // EnDB: 0b0 => RES0 in v8.0 (pointer auth)
                                          // I: 0b0 => Instruction cache disabled
                                          // RES1: 0b1
                                          // RES0: 0b0000
                                          // nAA: 0b0 => RES0 in v8.0
                                          // RES1: 0b11
                                          // SA: 0b0 => UNKNOWN since PE resets to EL2 (SP alignment checking)
                                          // C: 0b0 => data cache disabled
                                          // A: 0b0 => UNKNOWN since PE resets to EL2 (alignment checking)
                                          // M: 0b0 => EL2 stage 1 address translation disabled
2:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldrb    w1, [x28, FLAGS-sysvars]        // w1 = [FLAGS].
  orr     w1, w1, #0x10                   // w1 = [FLAGS] with bit 4 set.
                                          // [This bit is unused by 48K BASIC].
  strb    w1, [x28, FLAGS-sysvars]        // Update [FLAGS] to have bit 4 set.
# Here we should also set interuppt mode, and enable interrupts, and initialise printer
  mov     w2, 0x000B                      // = 11; timing constant for 9600 baud. Maybe useful for UART?
  strh    w2, [x28, BAUD-sysvars]         // [BAUD] = 0x000B
  strb    wzr, [x28, SERFL-sysvars]       // 0x5B61. Indicate no byte waiting in RS232 receive buffer.
  strb    wzr, [x28, COL-sysvars]         // 0x5B63. Set RS232 output column position to 0.
  strb    wzr, [x28, TVPARS-sysvars]      // 0x5B65. Indicate no control code parameters expected.
  mov     w3, 0x50                        // Default to a printer width of 80 columns.
  strb    w3, [x28, WIDTH-sysvars]        // 0x5B64. Set RS232 printer output width.
  mov     w4, 0x000A                      // Use 10 as the initial renumber line and increment.
  strh    w4, [x28, RNFIRST-sysvars]      // Store the initial line number when renumbering.
  strh    w4, [x28, RNSTEP-sysvars]       // Store the renumber line increment.
  adrp    x5, heap
  add     x5, x5, #:lo12:heap             // x5 = start of heap
  str     x5, [x28, CHANS-sysvars]        // [CHANS] = start of heap
  mov     x6, (initial_channel_info_END - initial_channel_info)/8   // x6 = number of double words (8 bytes) in initial_channel_info block
  adr     x7, initial_channel_info

# Copy initial_channel_info block to [CHANS] = start of heap = heap
3:
  ldr     x8, [x7], #8
  str     x8, [x5], #8
  subs    x6, x6, #1
  b.ne    3b

  sub     x9, x5, 1
  str     x9, [x28, DATADD-sysvars]
  str     x5, [x28, PROG-sysvars]
  str     x5, [x28, VARS-sysvars]
  mov     w10, 0x80
  strb    w10, [x5], 1
  str     x5, [x28, E_LINE-sysvars]
  mov     w11, 0x0D
  strb    w11, [x5], 1
  strb    w10, [x5], 1
  str     x5, [x28, WORKSP-sysvars]
  str     x5, [x28, STKBOT-sysvars]
  str     x5, [x28, STKEND-sysvars]
  mov     w12, 0x38
  strb    w12, [x28, ATTR_P-sysvars]
  strb    w12, [x28, MASK_P-sysvars]
  strb    w12, [x28, BORDCR-sysvars]

  movl    w0, BORDER_COLOUR               // w0 = default border colour
  bl      paint_border
//bl      clear_screen

  mov     w13, 0x0523                     // The values five and thirty five.
  strh    w13, [x28, REPDEL-sysvars]      // REPDEL. Set the default values for key delay and key repeat.
//
//
//         DEC  (IY-0x3A)     // Set KSTATE+0 to 0xFF.
//         DEC  (IY-0x36)     // Set KSTATE+4 to 0xFF.
//
//
  adr     x5, STRMS
  mov     x6, (initial_stream_data_END - initial_stream_data)/2   // x6 = number of half words (2 bytes) in initial_stream_data block
  adr     x7, initial_stream_data

# Copy initial_stream_data block to [STRMS]
4:
  ldrh    w8, [x7], #2
  strh    w8, [x5], #2
  subs    x6, x6, #1
  b.ne    4b

//         RES  1,(IY+0x01)   // FLAGS. Signal printer not is use.

  mov     w5, 255
  strb    w5, [x28, ERR_NR-sysvars]       // Signal no error.
  mov     w5, 2
  strb    w5, [x28, DF_SZ-sysvars]        // Set the lower screen size to two rows.

  bl      cls
  bl      paint_copyright                 // Paint the copyright text ((C) 1982 Amstrad....)
  mov     w0, 0x20000000
  bl      wait_cycles
  bl      display_zx_screen
  mov     w0, 0x10000000
  bl      wait_cycles
  mov     x0, #60
  bl      cls
  mov     x0, sp
  mov     x1, #1
  mov     x2, #0
  bl      display_memory
  adr     x0, mbreq
  mov     x1, #5
  mov     x2, #3
  bl      display_memory
  adr     x0, sysvars
  mov     x1, #10
  mov     x2, #10
  bl      display_memory
  adrp    x0, heap
  add     x0, x0, #:lo12:heap             // x0 = heap
  sub     x0, x0, #0x60
  mov     x1, #8
  mov     x2, #22
  bl      display_memory
  adr     x0, STRMS
  mov     x1, #2
  mov     x2, #32
  bl      display_memory
  ldr     x0, [x28, CHANS-sysvars]
  mov     x1, #2
  mov     x2, #36
  bl      display_memory
  bl      display_sysvars
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

