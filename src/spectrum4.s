# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.set SCREEN_WIDTH,     1920
.set SCREEN_HEIGHT,    1200
.set BORDER_LEFT,      96
.set BORDER_RIGHT,     96
.set BORDER_TOP,       128
.set BORDER_BOTTOM,    112

.set MAILBOX_BASE,     0x3f00b880
.set MAILBOX_REQ_ADDR, 0x0
.set MAILBOX_WRITE,    0x20
.set MAILBOX_STATUS,   0x118
.set MAILBOX_EMPTY_BIT,30
.set MAILBOX_FULL_BIT, 31

.set RAM_DISK_SIZE,    0x10000000
.set HEAP_SIZE,        0x10000000

.set FIRST_UDG_CHAR,   'A'                // Character 'A'
.set UDG_COUNT,        21                 // Number of User Defined Graphics to copy (=> 'A'-'U').

.set BORDER_COLOUR,    0x00cc0000         // Default border colour around screen.
.set PAPER_COLOUR,     0x00cccccc         // Default paper colour (background colour of screen).
.set INK_COLOUR,       0x00000000         // Default ink colour (foreground colour of text on screen).

# Load a 32-bit immediate using mov.
.macro movl Wn, imm
  movz    \Wn,  \imm & 0xFFFF
  movk    \Wn, (\imm >> 16) & 0xFFFF, lsl #16
.endm

.arch armv8-a
.cpu cortex-a53
.global _start

.align 2
.text

_start:
# Disable interrupts, or assume they are already disabled?
  mrs     x0, mpidr_el1                   // x0 = Multiprocessor Affinity Register.
  ands    x0, x0, #0x3                    // x0 = core number.
  b.ne    4f                              // Put all cores except core 0 to sleep.
  mov     x29, 0                          // Frame pointer 0 indicates end of stack.
  adr     x28, sysvars                    // x28 will remain at this constant value to make all sys vars via an immediate offset.
  mov     x0, x28
  adr     x1, sysvars_end
3:
  strb    wzr, [x0], #1
  cmp     x0, x1
  b.ne    3b
  bl      uart_init                       // Initialise UART interface.

# Should enable interrupts, set up vector jump tables, switch execution
# level etc, and all the kinds of things to initialise the processor system
# registers, memory virtualisation, initialise sound chip, USB, etc.
# Test memory banks?
# Clear memory (set to 0's)?
# Init usb/keyboard?
# Init sound?

  bl      init_framebuffer                // Allocate a frame buffer with chosen screen settings.
  bl      init_ramdisk

  adr     x14, arm_size
  ldr     w14, [x14]                      // x14 = first byte of shared GPU memory, for determining where CPU dedicated RAM ends (one byte below).
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
4:
  wfe                                     // Sleep until woken.
  b       4b                              // Go to sleep; it has been a long day.

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
  orr     x0, x0, 0x0800                  // Branch Prediction (Bit 11) - this seems to be undocumented in ARM ARM
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
  bl      clear_screen

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

//   bl      cls                             // Clear the screen.

  bl      paint_copyright                 // Paint the copyright text ((C) 1982 Amstrad....)
  mov     w0, 0x20000000
  bl      wait_cycles
  bl      display_zx_screen
  mov     w0, 0x10000000
  bl      wait_cycles
  bl      clear_screen
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
  ldrb    w9, [x29, TV_FLAG-sysvars]      // w9[0-7] = [TV_FLAG]
  and     w9, w9, #0xffffffdf             // Reset bit 5 - signal do not clear lower screen.
  orr     w9, w9, #0x00000001             // Set bit 0 - signal lower screen in use.
  strb    w9, [x29, TV_FLAG-sysvars]      // [TV_FLAG] = w9[0-7]
  bl      TEMPS                           // Routine TEMPS picks up temporary colours.
  ldrb    w0, [x28, DF_SZ-sysvars]        // fetch lower screen DF_SZ
  bl      cl_line                         // routine CL-LINE clears lower part and sets permanent attributes.

  // TODO: a lot to do here
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
  mov     x12, x0                         // x12 = number of text lines to be cleared.
  add     x12, x12, x12, lsl #1           // x12 = x12 + x12 * 2 (= 3 * line count)
  add     x12, x12, x12, lsl #3           // x12 = x12 + x12 * 8 (= 9 * x12 = 27 * line count)
  mov     x15, x12                        // x15 = 27 * number of text lines to be cleared.
  bl      cl_addr                         // Routine CL-ADDR gets top address.
  mov     x9, x0                          // x9 = start address of top line to be cleared.
  mov     w10, #16                        // There are 16 screen lines to a text line.
  mov     x11, #0                         // x11 = number of screen sections (20 text lines) touched.
2:
  add     x11, x11, #1                    // Increase number of screen sections affected by one.
  subs    x12, x12, #540                  // Screen is divided into 3 sections, each having 20 text lines.
  b.hi    2b                              // Keep subtracting 540 until zero or a negative number reached.
  add     x12, x12, #540                  // Add 540 back on, to get number of lines in top section * 27 to
                                          // be cleared, between 27 and 540.
                                          // (= Number of double words per pixel row * line count)
  mov     x13, x11                        // Backup x11 in x13
  mov     x14, x12                        // Backup x12 in x14
3:
  ldr     xzr, [x9], 8                    // Clear double word at x9, and bump x9 to next double word address.
  subs    x12, x12, 1                     // Reduce double word counter.
  b.ne    3b                              // Repeat until all rows are cleared.
  add     x9, x9, #0x00f, lsl #12         // 216 * 15 * 20 = 64800 = 0xfd20 bytes gets us to start of next
  add     x9, x9, #0xd20                  // screen section.
  mov     x12, #540                       // x12 = 20 lines * 27 double words = 540 double words
  subs    x11, x11, #1                    // x11 = number of remaining sections to update
  b.ne    3b                              // Repeat if more sections to update
  mov     x12, x14                        // Restore first section double word clearing length.
  mov     x11, x13                        // Restore number of sections count.
  add     x0, x0, #0x001, lsl #12         // Next row pixel address = previous base address + 216 bytes * 20 rows
  add     x0, x0, #0x0e0                  // = previous base address + 4320 bytes = previous + 0x10e0 bytes
  mov     x9, x0                          // Restore previous top address
  subs    w10, w10, #1                    // Decrease text line pixel counter.
  b.ne    3b                              // Repeat if not all screen lines of text have been cleared.
  adr     x9, attributes_file_end         // x9 = first byte after end of attributes file.
  sub     x10, x9, x15, lsl #2            // x10 = start address in attributes file to clear
  ldrb    w9, [x29, TV_FLAG-sysvars]      // w9[0-7] = [TV_FLAG]
  tbz     w9, #0, 4f                      // If bit 0 is clear, lower screen is in use; jump ahead to 4:.
  ldrb    w11, [x29, BORDCR-sysvars]
  b       5f
4:
  ldrb    w11, [x29, ATTR_P-sysvars]
5:
  bfm     w11, w11, #24, #7               // copy bits 0-7 to bits 8-15
  bfm     w11, w11, #16, #15              // copy bits 0-15 to bits 16-31
6:
  ldr     w11, [x10], #4
  cmp     x10, x9
  b.lt    6b
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

cl_addr:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  // TODO: a lot to do here
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

cl_all:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  str     wzr, [x28, COORDS-sysvars]      // set COORDS to 0,0.
  ldrb    w9, [x28, FLAGS2-sysvars]       // w9 = [FLAGS2].
  and     w9, w9, #0xfe                   // w9 = [FLAGS2] with bit 0 unset.
  strb    w9, [x28, FLAGS2-sysvars]       // Update [FLAGS2] to have bit 0 unset (signal main screen is clear).
  bl      cl_chan
  // TODO: a lot to do here
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

cl_chan:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x0, -3                          // Stream -3 (-> channel K)
  bl      chan_open                       // Open channel K
  // TODO: a lot to do here
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
  movl     w9, MAILBOX_BASE               // x9 = 0x3f00b880 (Mailbox Peripheral Address)
  1:                                      // Wait for mailbox FULL flag to be clear.
    ldr     w10, [x9, MAILBOX_STATUS]     // w10 = mailbox status.
    tbnz    w10, MAILBOX_FULL_BIT, 1b     // If FULL flag set (bit 31), try again...
  adr     x10, mbreq                      // x10 = memory block pointer for mailbox call.
  mov     w11, 8                          // Mailbox channel 8.
  orr     w11, w10, w11                   // w11 = encoded request address + channel number.
  str     w11, [x9, MAILBOX_WRITE]        // Write request address / channel number to mailbox write register.
  2:                                      // Wait for mailbox EMPTY flag to be clear.
    ldr     w12, [x9, MAILBOX_STATUS]     // w12 = mailbox status.
    tbnz    w12, MAILBOX_EMPTY_BIT, 2b    // If EMPTY flag set (bit 30), try again...
  ldr     w12, [x9, MAILBOX_REQ_ADDR]     // w12 = message request address + channel number.
  cmp     w11, w12                        // See if the message is for us.
  b.ne    2b                              // If not, try again.
  ldr     w11, [x10, framebuffer-mbreq]   // w11 = allocated framebuffer address
  and     w11, w11, #0x3fffffff           // Clear upper bits beyond addressable memory
  str     w11, [x10, framebuffer-mbreq]   // Store framebuffer address in framebuffer system variable.
  ret

# On entry:
#   w0 = colour to paint border
paint_border:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Push x19, x20 on the stack so x19 can be used in this function.
  mov     w19, w0                         // w19 = w0 (colour to paint border)
  mov     w0, 0                           // Paint rectangle from 0,0 (top left of screen) with width
  mov     w1, 0                           // SCREEN_WIDTH and height BORDER_TOP in colour w19 (border colour).
  mov     w2, SCREEN_WIDTH                // This is the border across the top of the screen.
  mov     w3, BORDER_TOP
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, 0                           // Paint left border in border colour. This starts below the top
  mov     w1, BORDER_TOP                  // border (0, BORDER_TOP) and is BORDER_LEFT wide and stops above
  mov     w2, BORDER_LEFT                 // the bottom border (drawn later in function).
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, SCREEN_WIDTH-BORDER_RIGHT   // Paint the right border in border colour. This also starts below
  mov     w1, BORDER_TOP                  // the top border, but on the right of the screen, and is
  mov     w2, BORDER_RIGHT                // BORDER_RIGHT wide. It also stops immediately above bottom border.
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, 0                           // Paint the bottom border in border colour. This is BORDER_BOTTOM
  mov     w1, SCREEN_HEIGHT-BORDER_BOTTOM // high, and is as wide as the screen.
  mov     w2, SCREEN_WIDTH
  mov     w3, BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  ldp     x19, x20, [sp], #0x10           // Restore x19 so no calling function is affected.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# On entry:
#   w0 = x
#   w1 = y
#   w2 = width (pixels)
#   w3 = height (pixels)
#   w4 = colour
paint_rectangle:
  adr     x9, mbreq                       // x9 = address of mailbox request.
  ldr     w10, [x9, framebuffer-mbreq]    // w10 = address of framebuffer
  ldr     w11, [x9, pitch-mbreq]          // w11 = pitch
  umaddl  x10, w1, w11, x10               // x10 = address of framebuffer + y*pitch
  add     w10, w10, w0, lsl #2            // w10 = address of framebuffer + y*pitch + x*4
  fill_rectangle:                         // Fills entire rectangle
    mov     w12, w10                      // w12 = reference to start of line
    mov     w13, w2                       // w13 = width of line
    fill_line:                            // Fill a single row of the rectangle with colour.
      str     w4, [x10], 4                // Colour current point, and update x10 to next point.
      subs    w13, w13, 1                 // Decrease horizontal pixel counter.
      b.ne    fill_line                   // Repeat until line complete.
    add     w10, w12, w11                 // x10 = start of current line + pitch = start of new line.
    subs    w3, w3, 1                     // Decrease vertical pixel counter.
    b.ne    fill_rectangle                // Repeat until all framebuffer lines complete.
  ret

# On entry:
#   w0 = colour to paint main screen
paint_window:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     w4, w0                          // Paint a single rectange that fills the gap inside the
  mov     w0, BORDER_LEFT                 // four borders of the screen.
  mov     w1, BORDER_TOP
  mov     w2, SCREEN_WIDTH-BORDER_LEFT-BORDER_RIGHT
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  bl      paint_rectangle
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# paint_string paints the zero byte delimited text string pointed to by x0 to the screen in the
# system font (16x16 pixels) at the screen print coordinates given by w1, w2. The ink colour is
# taken from w3 and paper colour from w4.
#
# On entry:
#   x0 = pointer to string
#   w1 = x
#   w2 = y
#   w3 = ink colour
#   w4 = paper colour
paint_string:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  stp     x0, x1, [sp, #-16]!
  stp     x2, x3, [sp, #-16]!
  str     x4, [sp, #-16]!
  mov     x29, sp                         // Update frame pointer to new stack location.
  bl      uart_puts
  bl      uart_newline
  ldr     x4, [sp], #0x10
  ldp     x2, x3, [sp], #0x10
  ldp     x0, x1, [sp], #0x10
  adr     x9, mbreq                       // x9 = address of mailbox request.
  ldr     w10, [x9, framebuffer-mbreq]    // w10 = address of framebuffer
  ldr     w9, [x9, pitch-mbreq]           // w9 = pitch
  adr     x11, chars-32*32                // x11 = theoretical start of character table for char 0
//   ldr     x11, [x28, CHARS-sysvars]       // x11 = theoretical start of character table for char 0
1:
  ldrb    w12, [x0], 1                    // w12 = char from string, and update x0 to next char
  cbz     w12, 2f                         // if found end marker, jump to end of function and return
  add     x13, x11, x12, lsl #5           // x13 = address of character bitmap
  mov     w14, BORDER_TOP                 // w14 = BORDER_TOP
  add     w14, w14, w2, lsl #4            // w14 = BORDER_TOP + y * 16
  mov     w15, BORDER_LEFT                // w15 = BORDER_LEFT
  add     w15, w15, w1, lsl #4            // w15 = BORDER_LEFT + x * 16
  add     w15, w10, w15, lsl #2           // w15 = address of framebuffer + 4* (BORDER_LEFT + x * 16)
  umaddl  x14, w9, w14, x15               // w14 = pitch*(BORDER_TOP + y * 16) + address of framebuffer + 4 * (BORDER_LEFT + x*16)
  mov     w15, 16                         // w15 = y counter
  paint_char:
    mov     w16, w14                      // w16 = leftmost pixel of current row address
    mov     w12, 1 << 15                  // w12 = mask for current pixel
    ldrh    w17, [x13], 2                 // w17 = bitmap for current row, and update x13 to next bitmap pattern
    paint_line:                           // Paint a horizontal row of pixels of character
      tst     w17, w12                    // apply pixel mask
      csel    w18, w3, w4, ne             // if pixel set, colour w3 (ink colour) else colour w4 (paper colour)
      str     w18, [x14], 4               // Colour current point, and update x14 to next point.
      lsr     w12, w12, 1                 // Shift bit mask to next pixel
      cbnz    w12, paint_line             // Repeat until line complete.
    add     w14, w16, w9                  // x14 = start of current line + pitch = start of new line.
    subs    w15, w15, 1                   // Decrease vertical pixel counter.
    b.ne    paint_char                    // Repeat until all framebuffer lines complete.
  add     w1, w1, 1                       // Increment w1 (x print position) so that the next char starts to the right of the current char.
  b       1b                              // Repeat outer loop.
2:
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

paint_copyright:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x0, msg_copyright               // x0 = location of system copyright message.
  mov     w1, 38                          // Print at x=38.
  mov     w2, 40                          // Print at y=40.
  movl    w3, INK_COLOUR                  // Ink colour is default system ink colour.
  movl    w4, PAPER_COLOUR                // Paper colour is default system paper colour.
  bl      paint_string                    // Paint the copyright string to screen.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

R1_09F4:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

R1_0F81:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

R1_10A8:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

R1_15C4:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

R1_5B2F:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

R1_5B34:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# 'K' channel flag setting routine
R1_1634:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldrb    w9, [x29, TV_FLAG-sysvars]      // w9[0-7] = [TV_FLAG]
  orr     w9, w9, #0x00000001             // Set bit 0 - signal lower screen in use.
  strb    w9, [x29, TV_FLAG-sysvars]      // [TV_FLAG] = w9[0-7]
  ldrb    w9, [x29, FLAGS-sysvars]        // w9[0-7] = [FLAGS]
  and     w9, w9, #0xdddddddd             // Reset bit 1 (printer not in use) and bit 5 (no new key).
                                          // See https://dinfuehr.github.io/blog/encoding-of-immediate-values-on-aarch64
                                          // for choice of #0xdddddddd
  strb    w9, [x29, FLAGS-sysvars]        // [FLAGS] = w9[0-7]
  ldrb    w9, [x29, FLAGS2-sysvars]       // w9[0-7] = [FLAGS2]
  orr     w9, w9, #0x00000010             // Set bit 4 of FLAGS2 - signal K channel in use.
  strb    w9, [x29, FLAGS2-sysvars]       // [FLAGS2] = w9[0-7]
  bl      TEMPS                           // Set temporary attributes.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# 'S' channel flag setting routine
R1_1642:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  // TODO
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# 'P' channel flag setting routine
R1_164D:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  // TODO
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

TEMPS:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  // TODO
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret

# On entry:
#   x0 = address
#   w1 = 8 bit value
poke_address:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  strb    w1, [x0]                        // Poke address
  adr     x9, display_file                // Check if address is in display file
  adr     x25, attributes_file
  subs    x11, x0, x9                     // x11 = display file offset
  b.lo    1f                              // if negative, jump ahead since before display file
  adr     x10, display_file_end           // Now compare address to upper limit of display file
  cmp     x0, x10                         // is address >= display_file_end?
  b.hs    1f                              // if so, jump ahead since after display file

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
  ldrb    w17, [x25, x16]                 // w17 = attribute data
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
  subs    x11, x0, x25                    // x11 = attributes file offset
  b.lo    2f                              // if negative, jump ahead since before attributes file
  adr     x10, attributes_file_end        // Now compare address to upper limit of attributes file
  cmp     x0, x10                         // is address >= attributes_file_end?
  b.hs    2f                              // if so, jump ahead since after attributes file
  // TODO: handle attributes file update
//   mov     w20, #0xcc             // dim
//   mov     w21, #0xff             // bright
//   tst     w1, #0x40              // bright set?
//   csel    w22, w20, w21, eq      // x22 = brightness
// // w15 = foreground colour
//   tst     w1, #0x02                       // red set?
//   csel    w13, wzr, w22, eq
//   tst     w1, #0x04                       // green set?
//   csel    w14, wzr, w22, eq
//   tst     w1, #0x01                       // blue set?
//   csel    w15, wzr, w22, eq
//   add     w15, w15, w14, lsl #8
//   add     w15, w15, w13, lsl #16
// // w7 = background colour
//   tst     w1, #0x10                       // red set?
//   csel    w5, wzr, w22, eq
//   tst     w1, #0x20                       // green set?
//   csel    w6, wzr, w22, eq
//   tst     w1, #0x08                       // blue set?
//   csel    w7, wzr, w22, eq
//   add     w7, w7, w6, lsl #8
//   add     w7, w7, w5, lsl #16

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
  // mov     x0, 0x200
  // bl      wait_cycles
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
  stp     x19, x20, [sp, #-16]!           // Store old x19, x20 on the the stack.
  stp     x21, x22, [sp, #-16]!           // Store old x21, x22 on the the stack.
  stp     x23, x24, [sp, #-16]!           // Store old x23, x24 on the the stack.
  sub     sp, sp, #112                    // 112 bytes for screen line buffer
  mov     x29, sp                         // Update frame pointer to new stack location.
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
  stp     x19, x20, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  stp     x21, x22, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
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
  strb    wzr, [x1]                       // add a trailing zero
  mov     x0, sp
  bl      uart_puts
  bl      uart_newline
  mov     x0, x19
  ldrb    w1, [x0]
  cbnz    w1, 1b
  bl      uart_newline
  add     sp, sp, #32                     // Free buffer
  ldp     x21, x22, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ldp     x19, x20, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret
