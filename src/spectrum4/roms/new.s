.text
.align 2
# Entry point for NEW (with interrupts disabled when running in bare metal since this routine will enable interrupts)
new:                                     // L019D
  adr     x0, char_set - (0x20 * 0x20)            // x0 = where, in theory character zero would be.
  str     x0, [x28, CHARS-sysvars]                // [CHARS] = theoretical address of char zero.
  ldr     x1, [x28, RAMTOP-sysvars]               // x1 = [RAMTOP].
  add     x1, x1, 1                               // x1 = [RAMTOP] + 1.
  and     sp, x1, #~0x0f                          // sp = highest 16-byte aligned address equal to or lower than ([RAMTOP] + 1).
  mov     x29, 0                                  // Frame pointer 0 indicates end of stack.
  ldrb    w1, [x28, FLAGS-sysvars]                // w1 = [FLAGS].
  orr     w1, w1, #0x10                           // w1 = [FLAGS] with bit 4 set.
                                                  // [This bit is unused by 48K BASIC].
  strb    w1, [x28, FLAGS-sysvars]                // Update [FLAGS] to have bit 4 set.
  mov     w2, 0x000B                              // = 11; timing constant for 9600 baud. Maybe useful for UART?
  strh    w2, [x28, BAUD-sysvars]                 // [BAUD] = 0x000B
  strb    wzr, [x28, SERFL-sysvars]               // 0x5B61. Indicate no byte waiting in RS232 receive buffer.
  strb    wzr, [x28, COL-sysvars]                 // 0x5B63. Set RS232 output column position to 0.
  strb    wzr, [x28, TVPARS-sysvars]              // 0x5B65. Indicate no control code parameters expected.
  mov     w3, 0x50                                // Default to a printer width of 80 columns.
  strb    w3, [x28, WIDTH-sysvars]                // 0x5B64. Set RS232 printer output width.
  mov     w4, 0x000A                              // Use 10 as the initial renumber line and increment.
  strh    w4, [x28, RNFIRST-sysvars]              // Store the initial line number when renumbering.
  strh    w4, [x28, RNSTEP-sysvars]               // Store the renumber line increment.
  adrp    x5, heap
  add     x5, x5, #:lo12:heap                     // x5 = start of heap
  str     x5, [x28, CHANS-sysvars]                // [CHANS] = start of heap
  mov     x6, (initial_channel_info_END - initial_channel_info)/8
                                                  // x6 = number of double words (8 bytes) in initial_channel_info block
  adr     x7, initial_channel_info

  // Loop to copy initial_channel_info block to [CHANS] = start of heap = heap
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
  strb    w12, [x28, ATTR_T-sysvars]
  strb    w12, [x28, BORDCR-sysvars]
  movl    w0, BORDER_COLOUR                       // w0 = default border colour
  bl      paint_border
  mov     w13, 0x0523                             // The values five and thirty five.
  strh    w13, [x28, REPDEL-sysvars]              // REPDEL. Set the default values for key delay and key repeat.
//
//
//         DEC  (IY-0x3A)     // Set KSTATE+0 to 0xFF.
//         DEC  (IY-0x36)     // Set KSTATE+4 to 0xFF.
//
//
  adr     x5, STRMS
  mov     x6, (initial_stream_data_END - initial_stream_data)/2
                                                  // x6 = number of half words (2 bytes) in initial_stream_data block
  adr     x7, initial_stream_data

  // Loop to copy initial_stream_data block to [STRMS]
  4:
    ldrh    w8, [x7], #2
    strh    w8, [x5], #2
    subs    x6, x6, #1
    b.ne    4b

//         RES  1,(IY+0x01)   // FLAGS. Signal printer not is use.
  mov     w5, 255
  strb    w5, [x28, ERR_NR-sysvars]               // Signal no error.
  mov     w5, 2
  strb    w5, [x28, DF_SZ-sysvars]                // Set the lower screen size to two rows.

  bl      cls
.if       DEMO_AUTORUN
  bl      demo                                    // Demonstrate features for manual inspection.
.endif
  b       sleep