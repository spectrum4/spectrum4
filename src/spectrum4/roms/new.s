# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

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

  bl      irq_vector_init
  dsb     sy                                      // TODO: Not sure if this is needed at all, or if a less aggressive barrier can be used
  bl      timer_init
  dsb     sy                                      // TODO: Not sure if this is needed at all, or if a less aggressive barrier can be used
  ldr     x0, enable_ic
  blr     x0
  dsb     sy                                      // TODO: Not sure if this is needed at all, or if a less aggressive barrier can be used

  bl      enable_irq

  ldr     x0, pcie_init
  cbz     x0, 9f
  blr     x0
9:

.if UART_DEBUG
# RPi version logging
  adr     x0, msg_rpi_model
  bl      uart_puts
  ldr     w0, rpi_model
  bl      uart_x0
  bl      uart_newline
  adr     x0, msg_rpi_revision
  bl      uart_puts
  ldr     w0, rpi_revision
  bl      uart_x0
  bl      uart_newline

# Register logging
  logarm  CNTFRQ_EL0
  logarm  CTR_EL0
  logarm  CurrentEL
  logarm  DAIF
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
  logarm  SCTLR_EL1
  logarm  SP_EL0

# PCIe status logging

# PCIe revision: 0x0000000000000304
# PCIe link is ready
# PCIe status register: 0x00000000000000b0
# PCIe loop iterations: 0x000000000000002e
# PCIe class code (initial): 0x0000000020060400
# PCIe class code (updated): 0x0000000020060400
# SSC configuration stage / link capabilities: 0x0000000090120006
# SSC status register: 0x0000000080001c17
# VID/DID: 0x00000000000014e4/0x0000000000002711
# Header type: 0x0000000000000001

#   [heap+0x00]: last read status register
#   [heap+0x04]: number of iterations of 1ms reading status register
#   [heap+0x08]: initial class code
#   [heap+0x0c]: updated class code
#   [heap+0x10]: SSC configuration steps successfully completed (0-6)
#   [heap+0x12]: link capabilities
#   [heap+0x14]: revision number
#   [heap+0x18]: vid
#   [heap+0x1a]: did
#   [heap+0x1c]: header type
#   [heap+0x20]: SSC status register

  ldr     x0, pcie_init
  cbz     x0, 4f                                  // skip PCIE logging if no pcie (e.g. rpi3b)
  adr     x0, msg_pcie_revision
  bl      uart_puts
  adrp    x10, heap
  add     x10, x10, :lo12:heap
  ldr     w0, [x10, #0x14]                        // w0 = revision number
  ldp     w8, w9, [x10]                           // w8 = last read status register,
                                                  // w9 = number of iterations of 1ms reading status register
  bl      uart_x0
  bl      uart_newline
  tbz     w8, #4, 1f
  tbnz    w8, #5, 2f
1:
  adr     x0, msg_pcie_not_ready
  bl      uart_puts
2:
  adr     x0, msg_pcie_link_ready
  tbnz    w8, #7, 3f
  adr     x0, msg_pcie_not_in_rc_mode
3:
  bl      uart_puts
  adr     x0, msg_pcie_status_register
  bl      uart_puts
  mov     x0, x8
  bl      uart_x0
  bl      uart_newline
  adr     x0, msg_pcie_loop_iterations
  bl      uart_puts
  mov     x0, x9
  bl      uart_x0
  bl      uart_newline
  adr     x0, msg_class_code_initial
  bl      uart_puts
  ldp     w0, w8, [x10, #0x8]                     // w0 = initial class code
                                                  // w8 = updated class code
  bl      uart_x0
  bl      uart_newline
  adr     x0, msg_class_code_updated
  bl      uart_puts
  mov     x0, x8
  bl      uart_x0
  bl      uart_newline
  adr     x0, msg_ssc_config_state_link_capabilities
  bl      uart_puts
  ldr     w0, [x10, #0x10]                        // w0 = ssc config stage / link capabilities
  bl      uart_x0
  bl      uart_newline
  adr     x0, msg_ssc_status
  bl      uart_puts
  ldr     w0, [x10, #0x20]                        // w0 = ssc status
  bl      uart_x0
  bl      uart_newline
  adr     x0, msg_vid_did
  bl      uart_puts
  ldrh    w0, [x10, #0x18]                        // w0 = vid
  bl      uart_x0
  mov     x0, '/'
  bl      uart_send
  ldrh    w0, [x10, #0x1a]                        // w8 = did
  bl      uart_x0
  bl      uart_newline
  adr     x0, msg_header_type
  bl      uart_puts
  ldr     w0, [x10, #0x1c]                        // w9 = header type
  bl      uart_x0
  bl      uart_newline
  b       5f
4:
  adr     x0, msg_no_pcie
  bl      uart_puts
  b       6f
5:
// Display pcie memory region
  mov     w0, 0xfd500000                          // start address
  mov     x1, #54                                 // number of rows to print
  mov     x2, #0                                  // screen line to start at
  bl      display_memory
  mov     w0, 0x400000
  bl      wait_usec
// Display MMU tables
6:
  adrp    x19, pg_dir                             // start address
  mov     x20, #25
  7:
    mov     x0, x19
    mov     x1, #32                               // number of rows to print
    mov     x2, #0                                // screen line to start at
    bl      display_memory
    add     x19, x19, #0x400
    subs    x20, x20, #1
    b.ne    7b
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
  8:
    ldr     x8, [x7], #8
    str     x8, [x5], #8
    subs    x6, x6, #1
    b.ne    8b
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
  9:
    ldrh    w8, [x7], #2
    strh    w8, [x5], #2
    subs    x6, x6, #1
    b.ne    9b
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


.if UART_DEBUG

msg_rpi_model:
  .asciz "Raspberry Pi model: "

msg_rpi_revision:
  .asciz "Raspberry Pi revision: "

msg_midr_el1:
  .asciz "Register MIDR_EL1 value: "

msg_revidr_el1:
  .asciz "Register REVIDR_EL1 value: "

msg_no_pcie:
  .asciz "No PCIe on this machine\r\n"

msg_pcie_revision:
  .asciz "PCIe revision: "

msg_pcie_status_register:
  .asciz "PCIe status register: "

msg_pcie_loop_iterations:
  .asciz "PCIe loop iterations: "

msg_pcie_not_ready:
  .asciz "ERROR: PCIe link not ready!\r\n"

msg_pcie_not_in_rc_mode:
  .asciz "ERROR: PCIe link not in RC mode!\r\n"

msg_pcie_link_ready:
  .asciz "PCIe link is ready\r\n"

msg_class_code_initial:
  .asciz "PCIe class code (initial): "

msg_class_code_updated:
  .asciz "PCIe class code (updated): "

msg_ssc_config_state_link_capabilities:
  .asciz "SSC configuration stage / link capabilities: "

msg_ssc_status:
  .asciz "SSC status register: "

msg_vid_did:
  .asciz "VID/DID: "

msg_header_type:
  .asciz "Header type: "

.endif
