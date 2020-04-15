# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.global _start

.align 2
.text

_start:
# Disable interrupts, or assume they are already disabled?
  mrs     x0, mpidr_el1                   // x0 = Multiprocessor Affinity Register.
  ands    x0, x0, #0x3                    // x0 = core number.
  b.ne    sleep                           // Put all cores except core 0 to sleep.
  mov     x29, 0                          // Frame pointer 0 indicates end of stack.
  adr     x28, sysvars                    // x28 will remain at this constant value to make all sys vars via an immediate offset.
  mov     x0, x28                         // Zero
  adr     x1, sysvars_end                 // Out
3:                                        // System
  strb    wzr, [x0], #1                   // Variables
  cmp     x0, x1                          // ...
  b.ne    3b                              // ...
  bl      uart_init                       // Initialise UART interface.

# Should enable interrupts, set up vector jump tables, switch execution
# level etc, and all the kinds of things to initialise the processor system
# registers, memory virtualisation, initialise sound chip, USB, etc.
# Test memory banks?
# Init usb/keyboard?
# Init sound?

  bl      init_framebuffer                // Allocate a frame buffer with chosen screen settings.
  bl      init_ramdisk

  ldr     w14, arm_size                   // x14 = first byte of shared GPU memory, for determining where CPU dedicated RAM ends (one byte below).
  sub     x14, x14, 1                     // x14 = last byte of dedicated RAM (not shared with GPU).
  str     x14, [x28, P_RAMT-sysvars]      // [P_RAMT] = 0x3bffffff.
  mov     x15, UDG_COUNT * 4              // x15 = number of double words (8 bytes) of characters to copy to the user defined graphics region.
  adr     x16, R1_3D00 + (FIRST_UDG_CHAR - 32) * 32 // x16 = address of first UDG char to copy.
  sub     x18, x14, UDG_COUNT * 32 - 1    // x18 = first byte of user defined graphics.
  str     x18, [x28, UDG-sysvars]         // [UDG] = first byte of user defined graphics.

# Copy UDG_COUNT characters into User Defined Graphics memory region at end of RAM.
3:
  ldr     x17, [x16], 8
  str     x17, [x18], 8
  subs    x15, x15, 1
  b.ne    3b

  mov     w12, 0x40
  strb    w12, [x28, RASP-sysvars]        // [RASP]=0x40
  strb    wzr, [x28, PIP-sysvars]         // [PIP]=0x00
  sub     x13, x18, 1 + UDG_COUNT * 32
  str     x13, [x28, RAMTOP-sysvars]      // [RAMPTOP] = UDG - 1 (address of last byte before UDG starts).
  bl      new
# b       reboot

sleep:
  wfe                                     // Sleep until woken.
  b       sleep                           // Go to sleep; it has been a long day.

# Entry point for NEW (with interrupts disabled when running in bare metal since this routine will enable interrupts)
new:
  adr     x0, R1_3D00 - (0x20 * 0x20)     // x0 = where, in theory character zero would be.
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
  mov     x6, (R0_0589_END - R0_0589)/8   // x6 = number of double words (8 bytes) in R0_0589 block
  adr     x7, R0_0589

# Copy R0_0589 block to [CHANS] = start of heap = heap
3:
  ldr     x8, [x7], 8
  str     x8, [x5], 8
  subs    x6, x6, 1
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
  mov     x6, (R0_059E_END - R0_059E)/2   // x6 = number of half words (2 bytes) in R0_059E block
  adr     x7, R0_059E

# Copy R0_059E block to [STRMS]
1:
  ldrh    w8, [x7], 2
  strh    w8, [x5], 2
  subs    x6, x6, 1
  b.ne    1b

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
  ldr     x0, [x28, UDG-sysvars]
  mov     x1, UDG_COUNT
  mov     x2, #32
  bl      display_memory
  bl      display_sysvars
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

# On entry:
#   x0 = error number
error_1:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldr     x9, [x28, CH_ADD-sysvars]       // x9 = character address from CH_ADD.
  str     x9, [x28, X_PTR-sysvars]        // Copy it to the error pointer X_PTR.
  strb    w0, [x28, ERR_NR-sysvars]       // Store error number in ERR_NR.
  ldr     x9, [x28, ERR_SP-sysvars]       // ERR_SP points to an error handler on the
  mov     sp, x9                          // machine stack. There may be a hierarchy
                                          // of routines.
                                          // to MAIN-4 initially at base.
                                          // or REPORT-G on line entry.
                                          // or  ED-ERROR when editing.
                                          // or   ED-FULL during ed-enter.
                                          // or  IN-VAR-1 during runtime input etc.

  // TODO - a lot to implement here, skipping for now as I haven't understood
  // how the stack swapping works yet.

  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

cls:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  bl      cl_all
  bl      cls_lower
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

cls_lower:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!           // Backup x21 / x22 on stack.
  ldrb    w9, [x28, TV_FLAG-sysvars]      // w9[0-7] = [TV_FLAG]
  and     w9, w9, #0xffffffdf             // Reset bit 5 - signal do not clear lower screen.
  orr     w9, w9, #0x00000001             // Set bit 0 - signal lower screen in use.
  strb    w9, [x28, TV_FLAG-sysvars]      // [TV_FLAG] = w9[0-7]
  bl      temps                           // Routine temps picks up temporary colours.
  ldrb    w0, [x28, DF_SZ-sysvars]        // Fetch lower screen DF_SZ.
  bl      cl_line                         // Routine CL-LINE clears lower part and sets permanent attributes.
  adr     x0, attributes_file_end         // x0 = address of first byte after attributes file
  sub     x19, x0, 108*2                  // x19 = attribute address leftmost cell, second line up (first byte after last cell to clear)
  ldrb    w2, [x28, DF_SZ-sysvars]        // Fetch lower screen DF_SZ.
  mov     w3, #108
  umsubl  x20, w2, w3, x0                 // x20 = first attribute cell to clear
  ldrb    w21, [x28, ATTR_P-sysvars]      // Fetch permanent attribute from ATTR_P.
1:                                        // Set attributes file values to [ATTR_P] for lowest [DF_SZ] lines except bottom two lines.
  cmp     x19, x20
  b.ls    2f                              // Exit loop if x19 <= x20 (unsigned)
  sub     x19, x19, #1
  mov     x0, x19
  mov     w1, w21
  bl      poke_address
  b       1b
2:
  mov     w5, 2
  strb    w5, [x28, DF_SZ-sysvars]        // Set the lower screen size to two rows.
  bl      cl_chan
  ldp     x21, x22, [sp], #0x10           // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

# ---------------------------
# Clear text lines of display
# ---------------------------
# This subroutine, called from cl_all, cls_lower and auto_list and above,
# clears text lines at bottom of display.
#
# On entry:
#   x0 = number of lines to be cleared (1-60)
cl_line:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!           // Backup x21 / x22 on stack.
  stp     x23, x24, [sp, #-16]!           // Backup x23 / x24 on stack.
  stp     x25, x26, [sp, #-16]!           // Backup x25 / x26 on stack.
  mov     x19, x0                         // x19 = number of lines to be cleared (1-60)
  bl      cl_addr                         // Routine CL-ADDR gets top address.
                                          //   x0 = number of lines to be cleared (1-60)
                                          //   x1 = start line number to clear
                                          //   x2 = address of top left pixel of line to clear inside display file
                                          //   x3 = first screen third to clear (0-2)
                                          //   x4 = start char line inside first screen third to clear (0-19)
  mov     x5, #216
  mov     x6, #0x10e0
  umsubl  x19, w4, w5, x6                 // x19 = number of lines in top screen third * 216 = byte count for one pixel row across first screen third
  umull   x20, w0, w5                     // x20 = 216 * line count
  mov     x22, x3                         // x22 = top screen section (0/1/2)

  // counters
  mov     x26, x2                         // x26 = address of first pixel in first section of current pixel row
  mov     w23, #16                        // x23 = number of remaining pixel lines to clear (0-15)
2:
  mov     x21, x26                        // x21 = address of next byte to clear
  mov     x24, x19                        // x24 = number of remaining bytes to clear in current loop
  mov     x25, x22                        // x25 = current screen section (0-2)
3:
  mov     x0, x21
  mov     x1, #0
  bl      poke_address
  add     x21, x21, #1
  subs    x24, x24, #1                    // Reduce byte counter.
  b.ne    3b                              // Repeat until all rows are cleared.
  add     x21, x21, #0x00f, lsl #12       // x21 += 216*15*20 (=0xfd20) to reach same pixel row in first char line of next
  add     x21, x21, #0xd20                // screen third.
  mov     x24, #4320                      // x24 = 20 lines * 216 bytes = 4320 bytes
  add     x25, x25, #1                    // x22 = next screen third to update
  cmp     x25, #3
  b.ne    3b                              // Repeat if more sections to update
  add     x26, x26, #0x001, lsl #12       // Next row pixel address = previous base address + 216 bytes * 20 rows
  add     x26, x26, #0x0e0                // = previous base address + 4320 bytes = previous + 0x10e0 bytes
  subs    w23, w23, #1                    // Decrease text line pixel counter.
  b.ne    2b                              // Repeat if not all screen lines of text have been cleared.
  adr     x21, attributes_file_end        // x21 = first byte after end of attributes file.
  sub     x22, x21, x20, lsr #1           // x22 = start address in attributes file to clear
  ldrb    w19, [x28, TV_FLAG-sysvars]     // w19[0-7] = [TV_FLAG]
  tbz     w19, #0, 4f                     // If bit 0 is clear, lower screen is in use; jump ahead to 4:.
  ldrb    w20, [x28, BORDCR-sysvars]
  b       5f
4:
  ldrb    w20, [x28, ATTR_P-sysvars]
5:
  mov     x0, x22
  mov     w1, w20
  bl      poke_address
  add     x22, x22, #1
  cmp     x22, x21
  b.lo    5b                              // Repeat iff x22 < x21
  ldp     x25, x26, [sp], #0x10           // Restore old x25, x26.
  ldp     x23, x24, [sp], #0x10           // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10           // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

# On entry:
#   x0 = number of lines to be cleared (1-60)
# On exit:
#   x0 unchanged
#   x1 = start line number to clear
#   x2 = address of top left pixel of line to clear inside display file
#   x3 = start char line / 20
#   x4 = start char line % 20
cl_addr:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19 / x20 on stack.
  stp     x21, x22, [sp, #-16]!           // Backup x21 / x22 on stack.
  stp     x23, x24, [sp, #-16]!           // Backup x23 / x24 on stack.
  mov     x1, #60
  sub     x1, x1, x0
  adr     x2, display_file
  mov     x3, #0xcccccccccccccccc
  add     x3, x3, #1                      // x3 = 0x0xcccccccccccccccd
  umulh   x3, x3, x1                      // x3 = 14757395258967641293 * x1 / 2^64 = int(0.8*x1)
  lsr     x3, x3, #4                      // x3 = int(x1/20)
  add     x4, x3, x3, lsl #2              // x4 = 5 * int(x1/20)
  sub     x4, x1, x4, lsl #2              // x4 = x1 - 20 * int(x1/20) = x1%20
  mov     x5, #216
  umaddl  x2, w4, w5, x2                  // x2 = display_file + (x1%20)*216
  mov     x6, 0x00010000
  movk    x6, 0xe00
  umaddl  x2, w6, w3, x2                  // x2 = display_file + (x1%20)*216 + (x1/20)*69120
  mov     x19, x0
  mov     x20, x1
  mov     x21, x2
  mov     x22, x3
  mov     x23, x4
  bl      uart_x0
  bl      uart_newline
  mov     x0, x20
  bl      uart_x0
  bl      uart_newline
  mov     x0, x21
  bl      uart_x0
  bl      uart_newline
  mov     x0, x22
  bl      uart_x0
  bl      uart_newline
  mov     x0, x23
  bl      uart_x0
  bl      uart_newline
  mov     x0, x19
  mov     x1, x20
  mov     x2, x21
  mov     x3, x22
  mov     x4, x23
  ldp     x23, x24, [sp], #0x10           // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10           // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

cl_all:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  str     wzr, [x28, COORDS-sysvars]      // set COORDS to 0,0.
  ldrb    w9, [x28, FLAGS2-sysvars]       // w9 = [FLAGS2]
  and     w9, w9, #0xfe                   // w9 = [FLAGS2] with bit 0 unset
  strb    w9, [x28, FLAGS2-sysvars]       // Update [FLAGS2] to have bit 0 unset (signal main screen is clear).
  bl      cl_chan
  mov     x0, #-2                         // Select system channel 'S'.
  bl      chan_open                       // Routine chan_open opens it.
  bl      temps                           // Routine temps picks up permanent values.
  mov     x0, #60                         // There are 60 lines.
  bl      cl_line                         // Routine cl_line clears all 60 lines.
  ldr     x0, [x28, CURCHL-sysvars]       // x0 = [CURCHL] (channel 'S')
  adr     x1, print_out
  str     x1, [x0], #8                    // Reset output routine to print_out for channel S.
  mov     w0, 1
  strb    w0, [x28, SCR_CT-sysvars]       // Reset SCR_CT (scroll count) to default of 1.
  mov     x0, 0x3c                        // 0x3c => row 60 (off screen?).
  mov     x1, 0x6d                        // 0x6d = 109 => column 0, strangely (col = 109-x).
  bl      cl_set
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

cl_chan:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x0, -3                          // Stream -3 (-> channel K)
  bl      chan_open                       // Open channel K.
  ldr     x0, [x28, CURCHL-sysvars]       // x0 = [CURCHL]
  adr     x1, print_out
  str     x1, [x0], #8                    // Reset output routine to print_out for channel K.
  adr     x1, key_input
  str     x1, [x0], #8                    // Reset input routine to key_input for channel K.
  mov     x0, 0x3b                        // 0x3b => row 59.
  mov     x1, 0x6d                        // 0x6d = 109 => column 0, strangely (col = 109-x).
  bl      cl_set
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

# On entry:
#   x0 = row 0-60 / 1-60 ?
#   x1 = column (1-109) ?
cl_set:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19 / x20 on stack
  adr     x2, printer_buffer
  ldrb    w3, [x28, FLAGS-sysvars]
  tbnz    w3, #1, 2f
  ldrb    w4, [x28, TV_FLAG-sysvars]
  tbz     w4, #0, 1f
  ldrb    w5, [x28, DF_SZ-sysvars]
  add     w0, w0, w5
  sub     w0, w0, #60
1:
  mov     x19, x1
  bl      cl_addr
  mov     x1, x19
2:
  mov     x3, #109
  sub     x3, x3, x1
  add     x2, x2, x3, lsl #1
  bl      po_store
  ldp     x19, x20, [sp], #16             // Restore old x19, x20.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

# On entry:
#   x0 = row
#   x1 = column
#   x2 = address in display file
po_store:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldrb    w3, [x28, FLAGS-sysvars]
  tbnz    w3, #1, 2f
  ldrb    w3, [x28, TV_FLAG-sysvars]
  tbnz    w3, #0, 1f
  strb    w0, [x28, S_POSN_ROW-sysvars]
  strb    w1, [x28, S_POSN_COLUMN-sysvars]
  str     x2, [x28, DF_CC-sysvars]
  b       3f
1:
  strb    w0, [x28, S_POSNL_ROW-sysvars]
  strb    w1, [x28, S_POSNL_COLUMN-sysvars]
  strb    w0, [x28, ECHO_E_ROW-sysvars]
  strb    w1, [x28, ECHO_E_COLUMN-sysvars]
  str     x2, [x28, DF_CCL-sysvars]
  b       3f
2:
  strb    w1, [x28, P_POSN-sysvars]
  str     x2, [x28, PR_CC-sysvars]
3:
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

# On entry:
#   x0 = stream number in range [-3,15]
# On exit:
#   x0 = ?
chan_open:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  add     x9, x28, x0, lsl #1             // x9 = sysvars + stream number * 2
  ldrh    w10, [x9, STRMS-sysvars+6]      // w10 = [stream number * 2 + STRMS + 6] = CHANS offset + 1
  cbnz    w10, 1f                         // Non-zero indicates channel open, in which case continue
  mov     x0, 0x17                        // Error Report: Invalid stream
//   bl      error_1
  b       2f
1:
  add     x10, x10, CHANS-sysvars-1       // w10 = CHANS offset + 1 + CHANS - sysvars - 1 = address in CHANS - sysvars
  add     x0, x28, x10                    // x0 = address of channel data in CHANS
  bl      chan_flag
2:
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

# On entry:
#   x0 = address of channel information inside CHANS
chan_flag:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  str     x0, [x28, CURCHL-sysvars]       // set CURCHL system variable to CHANS record address
  ldrb    w9, [x28, FLAGS2-sysvars]       // w9 = [FLAGS2].
  and     w9, w9, #0xffffffef             // w9 = [FLAGS2] with bit 4 unset.
  strb    w9, [x28, FLAGS2-sysvars]       // Update [FLAGS2] to have bit 4 unset (signal K channel not in use).
  ldr     x0, [x0, 16]                    // w0 = channel letter (stored at CHANS record address + 16)
  adr     x1, R1_162D                     // x1 = address of flag setting routine lookup table
  bl      indexer                         // look up flag setting routine
  cbz     x1, 1f                          // If not found then there is no routine (channel 'R') to call.
  blr     x2                              // Call flag setting routine.
1:
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

# Routine indexer searches an in-memory key/value store for x0.
#
# Keys and values are double words (64 bit values). Each record contains a single
# key and a single value. Keys and values may have unrestricted 64 bit values.
#
# The structure of the key/value store is:
#
#   uint64: number of records
#   [
#     uint64: key
#     uint64: value
#   ] * number of records
#
# Therefore the size of the store is [ 2*(number of records)+1 ] * 8 bytes (since
# 64 bits require 8 bytes of storage).
#
# * The key/value store must be 8 byte aligned in memory.
# * Records may be stored in an arbitrary order; however if a duplicate key exists,
#   the record with the lowest address in memory will take precendence.
# * Callers should check for non-zero x1 before using x2.
#
# On entry:
#   x0 = 64 bit key to search for
#   x1 = address of key/value store (8 byte aligned)
#
# On exit:
#   x0 unchanged
#   x1 = address of 64 bit key if found, otherwise 0
#   x2 = 64 bit value for key if found, otherwise undefined value
indexer:
  ldr     x9, [x1], #-8                   // x9 = number of records. Set x1 to lookup table address - 8 = address of first record - 16.
1:
  cbz     x9, 2b                          // If all records have been exhausted, jump forward to 2:.
  ldr     x10, [x1, #16]!                 // Load key at x1+16 into x10, and proactively increase x1 by 16 for the next iteration.
  sub     x9, x9, 1                       // x9 = number of remaining records to check (which is now one less)
  cmp     x0, x10                         // Check if key matches wanted key.
  b.ne    1b                              // If not, loop back to 1:.
  ldr     x2, [x1, #8]                    // Key matches, set x2 to the value stored in x1 + 8, and leave x1 as it is.
  b       3f                              // Jump forward to 3:.
2:
  mov     x1, 0                           // Set x1 to zero to indicate value wasn't found.
3:
  ret


init_framebuffer:
  adr     x0, mbreq                       // x0 = memory block pointer for mailbox call.
  mov     x27, x30
  bl      mbox_call
  mov     x30, x27
  ldr     w11, [x0, framebuffer-mbreq]    // w11 = allocated framebuffer address
  and     w11, w11, #0x3fffffff           // Clear upper bits beyond addressable memory
  str     w11, [x0, framebuffer-mbreq]    // Store framebuffer address in framebuffer system variable.
  ret


# On entry:
#   x0 = address of mailbox request
# On exit:
#   x0 unchanged
mbox_call:
  movl     w9, MAILBOX_BASE               // x9 = 0x3f00b880 (Mailbox Peripheral Address)
1:                                        // Wait for mailbox FULL flag to be clear.
  ldr     w10, [x9, MAILBOX_STATUS]       // w10 = mailbox status.
  tbnz    w10, MAILBOX_FULL_BIT, 1b       // If FULL flag set (bit 31), try again...
  mov     w11, 8                          // Mailbox channel 8.
  orr     w11, w0, w11                    // w11 = encoded request address + channel number.
  str     w11, [x9, MAILBOX_WRITE]        // Write request address / channel number to mailbox write register.
2:                                        // Wait for mailbox EMPTY flag to be clear.
  ldr     w12, [x9, MAILBOX_STATUS]       // w12 = mailbox status.
  tbnz    w12, MAILBOX_EMPTY_BIT, 2b      // If EMPTY flag set (bit 30), try again...
  ldr     w12, [x9, MAILBOX_REQ_ADDR]     // w12 = message request address + channel number.
  cmp     w11, w12                        // See if the message is for us.
  b.ne    2b                              // If not, try again.
  ret


print_out:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

add_char:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

key_input:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

report_j:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

pin:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

pout:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# 'K' channel flag setting routine
R1_1634:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldrb    w9, [x28, TV_FLAG-sysvars]      // w9[0-7] = [TV_FLAG]
  orr     w9, w9, #0x00000001             // Set bit 0 - signal lower screen in use.
  strb    w9, [x28, TV_FLAG-sysvars]      // [TV_FLAG] = w9[0-7]
  ldrb    w9, [x28, FLAGS-sysvars]        // w9[0-7] = [FLAGS]
  and     w9, w9, #0xdddddddd             // Reset bit 1 (printer not in use) and bit 5 (no new key).
                                          // See https://dinfuehr.github.io/blog/encoding-of-immediate-values-on-aarch64
                                          // for choice of #0xdddddddd
  strb    w9, [x28, FLAGS-sysvars]        // [FLAGS] = w9[0-7]
  ldrb    w9, [x28, FLAGS2-sysvars]       // w9[0-7] = [FLAGS2]
  orr     w9, w9, #0x00000010             // Set bit 4 of FLAGS2 - signal K channel in use.
  strb    w9, [x28, FLAGS2-sysvars]       // [FLAGS2] = w9[0-7]
  bl      temps                           // Set temporary attributes.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# 'S' channel flag setting routine
R1_1642:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldrb    w0, [x28, TV_FLAG-sysvars]
  and     w0, w0, #0xfffffffe             // Clear bit 0 - signal main screen in use.
  strb    w0, [x28, TV_FLAG-sysvars]      // [TV_FLAG] = w0[0-7]
  ldrb    w0, [x28, FLAGS-sysvars]
  and     w0, w0, #0xfffffffd             // Clear bit 1 - signal printer not in use.
  strb    w0, [x28, FLAGS-sysvars]        // [FLAGS] = w0[0-7]
  bl      temps
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# 'P' channel flag setting routine
R1_164D:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  // TODO
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

temps:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldrh    w0, [x28, ATTR_P-sysvars]       // w0 = ATTR_P + MASK_P
  ldrb    w1, [x28, TV_FLAG-sysvars]
  tbz     w1, #0, 1f
  ldrb    w0, [x28, BORDCR-sysvars]       // attr = BORDCR, mask = 0
1:
  strh    w0, [x28, ATTR_T-sysvars]       // Store ATTR_P/MASK_P in ATTR_T/MASK_T if upper screen, BORDCR/0 if lower screen.
  mov     w0, 0
  tbnz    w1, #0, 2f
  ldrb    w0, [x28, P_FLAG-sysvars]
  lsr     w0, w0, #1
2:
  ldrb    w1, [x28, P_FLAG-sysvars]
  eor     w0, w0, w1
  and     w0, w0, 0x55555555
  eor     w0, w0, w1
  strb    w0, [x28, P_FLAG-sysvars]
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# On entry:
#   x0 = address
#   w1 = 8 bit value
poke_address:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19 / x20 on stack
  stp     x21, x22, [sp, #-16]!           // Backup x21 / x22 on stack
  stp     x23, x24, [sp, #-16]!           // Backup x23 / x24 on stack
  strb    w1, [x0]                        // Poke address
  adr     x9, display_file                // Check if address is in display file
  adr     x24, attributes_file
  subs    x11, x0, x9                     // x11 = display file offset
  b.lo    1f                              // if x0 < x9, jump ahead since before display file
  adr     x10, display_file_end           // Now compare address to upper limit of display file
  cmp     x0, x10
  b.hs    1f                              // if x0 >= x10 (display file end) jump ahead since after display file

  // framebuffer addresses = pitch*(BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))) + address of framebuffer + 4 * (BORDER_LEFT + 8*(x11%216) + [0-7])
  // attribute address = attributes_file+((x11/2)%108)+108*(((x11/216)%20)+20*(x11/(216*20*16)))

  adr     x9, mbreq                       // x9 = address of mailbox request.
  ldr     w10, [x9, framebuffer-mbreq]    // w10 = address of framebuffer
  ldr     w12, [x9, pitch-mbreq]          // w12 = pitch
  mov     x13, #0x425f
  movk    x13, #0x97b, lsl #16
  movk    x13, #0x25ed, lsl #32
  movk    x13, #0x97b4, lsl #48           // x13 = 0x97b425ed097b425f = 10931403895531586143
  umulh   x14, x13, x11                   // x14 = (10931403895531586143 * x11) / 18446744073709551616 = int(x11*16/27)
  lsr     x14, x14, #7                    // x14 = int(x11/216)
  mov     x15, #0xcccccccccccccccc
  add     x15, x15, #1                    // x15 = 0x0xcccccccccccccccd
  umulh   x16, x15, x14                   // x16 = 14757395258967641293 * int(x11/216) / 2^64 = (4/5) * int(x11/216)
  lsr     x16, x16, #4                    // x16 = int(int(x11/216)/20)
  add     x16, x16, x16, lsl #2           // x16 = 5 * int(int(x11/216)/20)
  sub     x16, x14, x16, lsl #2           // x16 = int(x11/216) - 20 * int(int(x11/216)/20) = (x11/216)%20
  mov     x17, #0x9d65
  movk    x17, #0xf2b, lsl #16
  movk    x17, #0xd648, lsl #32
  movk    x17, #0xf2b9, lsl #48           // x17 = 0xf2b9d6480f2b9d65 = 17490246232850537829
  umulh   x18, x17, x11                   // x18 = 17490246232850537829 * x11 / 2^64 = int(x11*128/135)
  ubfx    x19, x18, #12, #4               // x19 = bits 12-15 of int(x11*128/135) = (x11/(216*20)) % 16
  add     x19, x19, x16, lsl #4           // x19 = (x11/(216*20))%16 + 16*((x11/216)%20)
  lsr     x18, x18, #16                   // x18 = int(x11/(216*20*16))
  add     x18, x18, x18, lsl #2           // x18 = 5*int(x11/(216*20*16))
  add     x19, x19, x18, lsl #6           // x19 = (x11/(216*20))%16 + 16*((x11/216)%20) + 320*int(x11/216*20*16)
  add     x19, x19, BORDER_TOP            // x19 = BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))
  umaddl  x19, w19, w12, x10              // x19 = pitch*(BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))) + address of framebuffer
  mov     x20, #0xd8                      // x20 = 216
  msub    x21, x20, x14, x11              // x21 = x11 - int(x11/216)*216 = x11%216
  mov     x22, BORDER_LEFT
  add     x22, x22, x21, lsl #3           // x22 = BORDER_LEFT + 8*(x11%216)
  add     x23, x19, x22, lsl #2           // x23 = pitch*(BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))) + address of framebuffer + 4*(BORDER_LEFT + 8*(x11%216))

  lsr     x10, x11, #1                    // x10 = int(x11/2)
  umulh   x14, x13, x10                   // x14 = int(int(x11/2)*16/27)
  lsr     x14, x14, #6                    // x14 = int(x11/216)
  mov     x12, #0x6c                      // x12 = 108
  msub    x10, x12, x14, x10              // x10 = int(x11/2)-108*int((x11/2)/108)=(x11/2)%108
  add     x16, x16, x18, lsl #2           // x16 = (x11/216)%20+20*int(x11/(216*20*16))
  madd    x16, x16, x12, x10              // x16 = 108*(((x11/216)%20+20*int(x11/(216*20*16))) + (x11/2)%108
  ldrb    w17, [x24, x16]                 // w17 = attribute data
  mov     w20, #0xcc             // dim
  mov     w21, #0xff             // bright
  tst     w17, #0x40             // bright set?
  csel    w22, w20, w21, eq      // x22 = brightness
// w15 = foreground colour
  tst     w17, #0x02                      // red set?
  csel    w13, wzr, w22, eq
  tst     w17, #0x04                      // green set?
  csel    w14, wzr, w22, eq
  tst     w17, #0x01                      // blue set?
  csel    w15, wzr, w22, eq
  add     w15, w15, w14, lsl #8
  add     w15, w15, w13, lsl #16
// w7 = background colour
  tst     w17, #0x10                      // red set?
  csel    w5, wzr, w22, eq
  tst     w17, #0x20                      // green set?
  csel    w6, wzr, w22, eq
  tst     w17, #0x08                      // blue set?
  csel    w7, wzr, w22, eq
  add     w7, w7, w6, lsl #8
  add     w7, w7, w5, lsl #16
  mov     w8, #8
3:
  tst     x1, #0x80              // pixel set?
  csel    w3, w7, w15, eq
  str     w3, [x23], #4
  lsl     w1, w1, #1
  subs    w8, w8, #1
  b.ne    3b
  b       2f
1:
  subs    x11, x0, x24                    // x11 = attributes file offset
  b.lo    2f                              // if x0 < x24, jump ahead since before attributes file
  adr     x10, attributes_file_end        // Now compare address to upper limit of attributes file
  cmp     x0, x10
  b.hs    2f                              // if x0 >= x10 (attributes file end), jump ahead since after attributes file
// TODO: rewrite this section to be more efficient (don't call poke_address recursively)
  add     x10, x9, x11, lsl #1            // x10 = disp base address + attr offset * 2
  mov     x8, #64800                      // 216 * 20 * 15
  cmp     x11, #2160
  csel    x12, x8, xzr, hs
  add     x10, x10, x12
  mov     x3, #4320
  cmp     x11, x3
  csel    x12, x8, xzr, hs
  add     x0, x10, x12

  mov     x3, #16
4:
  stp     x3, x0, [sp, #-16]!
  ldrb    w1, [x0]
  bl      poke_address
  ldp     x3, x0, [sp]
  add     x0, x0, #1
  ldrb    w1, [x0]
  bl      poke_address
  ldp     x3, x0, [sp], #16
  add     x0, x0, #4000
  add     x0, x0, #320
  subs    x3, x3, #1
  b.ne    4b

2:
  ldp     x23, x24, [sp], #0x10           // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10           // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

clear_screen:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, display_file
  adr     x2, display_file_end
1:
  str     xzr, [x0], #8
  cmp     x0, x2
  b.ne    1b

  adr     x0, attributes_file
  mov     x1, #0x3838383838383838
  adr     x2, attributes_file_end
2:
  str     x1, [x0], #8
  cmp     x0, x2
  b.ne    2b
  movl    w0, PAPER_COLOUR                // w0 = default paper colour
  bl      paint_window
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

display_zx_screen:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x9, ZX_SCREEN
  adr     x0, display_file
1:
  ldrb    w1, [x9], #1
  stp     x0, x9, [sp, #-16]!
  bl      poke_address
  ldp     x0, x9, [sp], #16
  add     x0, x0, #1
  adr     x2, attributes_file_end
  cmp     x0, x2
  b.ne    1b
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# On entry:
#   x0 = start address
#   x1 = number of rows to print
#   x2 = screen line to start at
display_memory:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Store old x19, x20 on the the stack.
  stp     x21, x22, [sp, #-16]!           // Store old x21, x22 on the the stack.
  stp     x23, x24, [sp, #-16]!           // Store old x23, x24 on the the stack.
  sub     sp, sp, #112                    // 112 bytes for screen line buffer
  mov     x19, x0                         // x19 = start address
  mov     x20, x1                         // x20 = number of rows to print
  mov     x21, x2                         // x21 = screen line to start at
  mov     w23, #0x2020                    // two spaces ('  ')
  adr     x0, msg_hex_header              // Pointer to string
  mov     w1, #0                          // x coordinate
  mov     w3, #0x00ffffff                 // white ink
  mov     w4, #0x000000cc                 // (dark) blue paper
  bl      paint_string                    // paint hex header line
  add     x21, x21, #1                    // x21 = first data line screen line
1:
  mov     x1, sp                          // address to write text string to
  strh    w23, [x1], #2                   // write '  ' to screen line buffer on stack
  mov     x0, x19                         // x0 = dump address
  mov     x2, #32
  bl      hex_x0                          // append to screen line buffer and update x1
  mov     x22, #0x20                      // 32 values to print
2:
  strb    w23, [x1], #1                   // write ' ' to screen line buffer
  ldrb    w0, [x19], #1                   // w0 = data at address, bump address x19
  mov     x2, #8
  bl      hex_x0
  subs    x22, x22, #1
  b.ne    2b
  strh    w23, [x1], #2                   // write '  ' to screen line buffer
  strb    wzr, [x1], #1                   // append 0 byte to terminate string
  mov     x0, sp
  mov     w1, #0                          // x = 0
  mov     x2, x21                         // y = line number
  mov     w3, #0x00ffffff                 // white ink
  mov     w4, #0x000000cc                 // (dark) blue paper
  bl      paint_string                    // paint string
  add     x21, x21, #1                    // increase line number
  subs    x20, x20, #1
  b.ne    1b                              // if not, process next line
  add     sp, sp, #112                    // Free screen line buffer
  ldp     x23, x24, [sp], #0x10           // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10           // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# On entry:
#   x0 = hex value to convert to text
#   x1 = address to write text to (no trailing 0)
#   x2 = number of bits to print (multiple of 4)
# On exit:
#   x1 = address of next unused char (x1 += x2/4)
hex_x0:
  ror     x0, x0, x2
1:
  ror     x0, x0, #60
  and     w3, w0, #0x0f
  add     w3, w3, 0x30
  cmp     w3, 0x3a
  b.lo    2f
  add     w3, w3, 0x27
2:
  strb    w3, [x1], #1
  subs    w2, w2, #4
  b.ne    1b
  ret


# ------------------------------------------------------------------------------
# Wait (at least) x0 instruction cycles.
# ------------------------------------------------------------------------------
wait_cycles:
  subs    x0, x0, #0x1                    // x0 -= 1
  b.ne    wait_cycles                     // Repeat until x0 == 0.
  ret                                     // Return.

display_sysvars:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // callee-saved registers used later on.
  stp     x21, x22, [sp, #-16]!           // callee-saved registers used later on.
  sub     sp, sp, #32                     // 32 bytes buffer for storing hex representation of sysvar (maximum is 16 chars + trailing 0, so 17 bytes)
  adr     x0, msg_title_sysvars
  bl      uart_puts
  adr     x0, sysvarnames                 // x0 = address of first sys var name
  adr     x20, sysvaraddresses            // x20 = address of first sys var pointer
1:
  bl      uart_puts
  ldrb    w21, [x0], #1                   // x21 = size of sysvar data in bytes
  mov     x19, x0                         // x19 = address of next sysvar name
  adr     x0, msg_colon0x
  bl      uart_puts
  ldr     x0, [x20], #8                   // x0 = address of sys var
  tbnz    w21, #0, size1
  tbnz    w21, #1, size2
  tbnz    w21, #2, size4
  tbnz    w21, #3, size8
  ret

size1:
  ldrb    w0, [x0]
  b       2f
size2:
  ldrh    w0, [x0]
  b       2f
size4:
  ldr     w0, [x0]
  b       2f
size8:
  ldr     x0, [x0]

2:
  mov     x1, sp
  mov     x2, x21, lsl #3                 // x2 = size of sysvar data in bits
  bl      hex_x0
  strb    wzr, [x1]                       // Add a trailing zero.
  mov     x0, sp
  bl      uart_puts
  bl      uart_newline
  mov     x0, x19
  ldrb    w1, [x0]
  cbnz    w1, 1b
  bl      uart_newline
  add     sp, sp, #32                     // Free buffer.
  ldp     x21, x22, [sp], #16             // Pop callee-saved registers.
  ldp     x19, x20, [sp], #16             // Pop callee-saved registers.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret
