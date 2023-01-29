.text
.align 2
# Entry point for NEW (with interrupts disabled when running in bare metal since this routine will enable interrupts)
new:                                     // L019D
  adrp    x0, char_set - 0x20 * 0x20
  add     x0, x0, :lo12:(char_set - 0x20 * 0x20)  // x0 = where, in theory character zero would be.
  str     x0, [x28, CHARS-sysvars]                // [CHARS] = theoretical address of char zero.
  ldr     x1, [x28, RAMTOP-sysvars]               // x1 = [RAMTOP].
  add     x1, x1, 1                               // x1 = [RAMTOP] + 1.
  and     sp, x1, #~0x0f                          // sp = highest 16-byte aligned address equal to or lower than ([RAMTOP] + 1).
  mov     x29, 0                                  // Frame pointer 0 indicates end of stack.

.if       UART_DEBUG
  mov     x0, msg_rpi_model
  bl      uart_puts
  ldr     w0, rpi_model
  bl      uart_x0
  bl      uart_newline
  mov     x0, msg_rpi_revision
  bl      uart_puts
  ldr     w0, rpi_revision
  bl      uart_x0
  bl      uart_newline

  mov     x0, msg_pcie_revision
  bl      uart_puts
  adrp    x1, heap
  add     x1, x1, :lo12:heap
  ldr     w0, [x1]
  bl      uart_x0
  bl      uart_newline

# logarm  ACTLR_EL3
  logarm  CNTFRQ_EL0
  logarm  CTR_EL0
  logarm  CurrentEL
  logarm  DAIF
# logarm  ELR_EL3
  logarm  ID_AA64AFR0_EL1
  logarm  ID_AA64AFR1_EL1
  logarm  ID_AA64DFR0_EL1
  logarm  ID_AA64DFR1_EL1
  logarm  ID_AA64ISAR0_EL1
  logarm  ID_AA64ISAR1_EL1
  logarm  ID_AA64MMFR0_EL1
  logarm  ID_AA64MMFR1_EL1
  logarm  ID_AA64MMFR2_EL1
  logarm  ID_AA64PFR0_EL1
  logarm  ID_AA64PFR1_EL1
  logarm  ID_AFR0_EL1
  logarm  ID_DFR0_EL1
  logarm  ID_ISAR0_EL1
  logarm  ID_ISAR1_EL1
  logarm  ID_ISAR2_EL1
  logarm  ID_ISAR3_EL1
  logarm  ID_ISAR4_EL1
  logarm  ID_ISAR5_EL1
  logarm  ID_MMFR0_EL1
  logarm  ID_MMFR1_EL1
  logarm  ID_MMFR2_EL1
  logarm  ID_MMFR3_EL1
  logarm  ID_MMFR4_EL1
  logarm  ID_PFR0_EL1
  logarm  ID_PFR1_EL1
  logarm  MIDR_EL1
  logarm  NZCV
  logarm  REVIDR_EL1
# logarm  SCR_EL3
  logarm  SCTLR_EL1
# logarm  SCTLR_EL2
# logarm  SCTLR_EL3
# logarm  SPSR_EL3
  logarm  SP_EL0
# logarm  SP_EL1
# logarm  SP_EL2
.endif

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
  adrp    x7, initial_channel_info
  add     x7, x7, :lo12:initial_channel_info
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
// Not translated the following instructions, since they may well need to work differently.
// TODO: check this after implementing keyboard reading routines
//   DEC  (IY-0x3A)     // Set KSTATE+0 to 0xFF.
//   DEC  (IY-0x36)     // Set KSTATE+4 to 0xFF.
  add     x5, x28, STRMS - sysvars
  mov     x6, (initial_stream_data_END - initial_stream_data)/2
                                                  // x6 = number of half words (2 bytes) in initial_stream_data block
  adr     x7, initial_stream_data
  // Loop to copy initial_stream_data block to [STRMS]
  4:
    ldrh    w8, [x7], #2
    strh    w8, [x5], #2
    subs    x6, x6, #1
    b.ne    4b
  ldrb    w0, [x28, FLAGS-sysvars]
  and     w0, w0, #~0x02
  strb    w0, [x28, FLAGS-sysvars]                // clear bit 1 of FLAGS (signal printer not in use)
  mov     w5, #0xff
  strb    w5, [x28, ERR_NR-sysvars]               // Signal no error.
  mov     w5, #0x02
  strb    w5, [x28, DF_SZ-sysvars]                // Set the lower screen size to two rows.
  bl      cls
// TODO: Commented out, since this method doesn't return unless a key is pressed, and we don't have keypress routines yet...
# bl      tv_tuner
  ldrb    w2, [x28, S_POSN_X_L-sysvars]
  sub     w2, w2, #0x28
  strb    w2, [x28, S_POSN_X_L-sysvars]
  ldr     x2, [x28, DF_CC_L-sysvars]
  add     x2, x2, #0x50
  str     x2, [x28, DF_CC_L-sysvars]

  adr     x2, msg_copyright
  bl      print_message
  mov     w5, #0x02
  strb    w5, [x28, DF_SZ-sysvars]                // Set the lower screen size to two rows.
  ldrb    w1, [x28, TV_FLAG-sysvars]
  orr     w1, w1, #0x20
  strb    w1, [x28, TV_FLAG-sysvars]              // set bit 5 of TV_FLAG (signal lower screen will require clearing)
// TODO: Check this - but I think swap stack routines aren't needed at all. On
// the 128K, I believe the stack is in the RAM page that gets paged out, and so
// it is forced to use separate stacks per RAM bank that gets paged in.
# add     x0, x28, TSTACK-sysvars
# str     x0, [x28, OLDSP-sysvars]
# bl      swap_stack
  mov     w0, #0x38
  strb    w0, [x28, EC11-sysvars]
  strb    w0, [x28, EC0F-sysvars]
  bl      init_mode
# bl      swap_stack
  b       main_menu


msg_rpi_model:
  .asciz "Raspberry Pi model: "

msg_rpi_revision:
  .asciz "Raspberry Pi revision: "

msg_midr_el1:
  .asciz "Register MIDR_EL1 value: "

msg_revidr_el1:
  .asciz "Register REVIDR_EL1 value: "

msg_pcie_revision:
  .asciz "PCIe revision: "
