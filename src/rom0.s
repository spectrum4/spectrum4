# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.align 2
.text


restart:                         // L0000
  msr     daifset, #3                     // Disable (mask) interrupts and fast interrupts
  mov     x0, x28                         // Zero
  adr     x1, sysvars_end                 // Out
1:                                        // System
  strb    wzr, [x0], #1                   // Variables
  cmp     x0, x1                          // ...
  b.ne    1b                              // ...
  bl      init_ramdisk
  ldr     w14, arm_size                   // x14 = first byte of shared GPU memory, for determining where CPU dedicated RAM ends (one byte below).
  sub     x14, x14, 1                     // x14 = last byte of dedicated RAM (not shared with GPU).
  str     x14, [x28, P_RAMT-sysvars]      // [P_RAMT] = 0x3bffffff.
  mov     x15, UDG_COUNT * 4              // x15 = number of double words (8 bytes) of characters to copy to the user defined graphics region.
  adr     x16, chars + (FIRST_UDG_CHAR - 32) * 32 // x16 = address of first UDG char to copy.
  sub     x18, x14, UDG_COUNT * 32 - 1    // x18 = first byte of user defined graphics.
  str     x18, [x28, UDG-sysvars]         // [UDG] = first byte of user defined graphics.
# Copy UDG_COUNT characters into User Defined Graphics memory region at end of RAM.
2:
  ldr     x17, [x16], 8
  str     x17, [x18], 8
  subs    x15, x15, 1
  b.ne    2b
  mov     w12, 0x40
  strb    w12, [x28, RASP-sysvars]        // [RASP]=0x40
  strb    wzr, [x28, PIP-sysvars]         // [PIP]=0x00
  sub     x13, x18, 1 + UDG_COUNT * 32
  str     x13, [x28, RAMTOP-sysvars]      // [RAMPTOP] = UDG - 1 (address of last byte before UDG starts).
  b       new


pin:                             // L009A
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
// TODO
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


pout:                            // L009F
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
// TODO
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# Entry point for NEW (with interrupts disabled when running in bare metal since this routine will enable interrupts)
new:                             // L019D
  adr     x0, chars - (0x20 * 0x20)       // x0 = where, in theory character zero would be.
  str     x0, [x28, CHARS-sysvars]        // [CHARS] = theoretical address of char zero.
  ldr     x1, [x28, RAMTOP-sysvars]       // x1 = [RAMTOP].
  add     x1, x1, 1                       // x1 = [RAMTOP] + 1.
  and     sp, x1, 0xfffffff0              // sp = highest 16-byte aligned address equal to or lower than ([RAMTOP] + 1).
  mov     x29, 0                          // Frame pointer 0 indicates end of stack.
  ldrb    w1, [x28, FLAGS-sysvars]        // w1 = [FLAGS].
  orr     w1, w1, #0x10                   // w1 = [FLAGS] with bit 4 set.
                                          // [This bit is unused by 48K BASIC].
  strb    w1, [x28, FLAGS-sysvars]        // Update [FLAGS] to have bit 4 set.
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

  // TODO

/////////////////////////////////////////////////////////////////////////
// The following code is all just for demonstration / testing purposes...
/////////////////////////////////////////////////////////////////////////

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
  b       sleep



# Print zero byte delimited string stored at memory location x0 to current channel.
# On entry:
#   x0 = address of zero byte delimited string
print_message:                   // L057D
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19 / x20 on stack.
  mov     x19, x0
  b       2f
1:
  mov     w0, w1
  bl      print_w0
2:
  ldrb    w1, [x19], #1
  cbnz    w1, 1b
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret
