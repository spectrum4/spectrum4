# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

# ------------------
# RAM Disk Catalogue
# ------------------
#
# Both the catalogue and files of the RAMDISK are contained in the RAMDISK
# section (from RAMDISK to RAMDISK+RAMDISKSIZE):
#   The catalogue is located at the top of RAMDISK section and grows downwards
#   The files are located at the bottom of RAMDISK and grow upwards
#
# Each catalogue entry contains 96 (0x60) bytes:
#   Bytes 0x00-0x3F: Filename.
#   Bytes 0x40-0x47: Start address of file
#   Bytes 0x48-0x4F: Length of file
#   Bytes 0x50-0x57: End address of file (used as current position indicator when loading/saving).
#   Bytes 0x58-0x5F: Flags:
#                     Bit 0:     1=Entry requires updating.
#                     Bits 1-63: Not used (always hold 0).
#
# When a file is deleted, any file which is stored after it is relocated to a
# lower memory address to remove the gap of the file contents, and the catalogue
# entries are moved to a higher memory address to remove the gap in the
# catalogue. This is clearly suboptimal, but is implemented this way to match the
# original spectrum. This can be improved later once things are working.
#
# A file consists of a 32 byte header (256 bits) followed by the data for the
# file. The header bytes have the following meaning:
#   Bytes 0x00-0x07: FLAGS
#                      Bits 0-15:  File type - 0x00=Program, 0x01=Numeric array, 0x02=Character array, 0x03=Code/Screen$.
#                      Bits 16-63: Auto-run line number for a program (0xffffffffffff if no auto-run).
#   Bytes 0x08-0x0F: Length of program/code block/screen$/array
#   Bytes 0x10-0x17: Start of code block/screen$
#   Bytes 0x18-0x1F: Offset to the variables (i.e. length of program) if a program. For an array, 0x18 holds the variable name.

.text
.align 2

restart:                                 // L0000
  msr     daifset, #3                             // Disable (mask) interrupts and fast interrupts.
  mov     x0, x28                                 // x0 = sys variable start address
  adr     x1, sysvars_end                         // x1 = sys variable end marker
  1:                                              // Loop to clear all bits of all system variables.
    strb    wzr, [x0], #1                         // Clear byte.
    cmp     x0, x1                                // Check if all bytes updated.
    b.ne    1b                                    // If not, loop back.

  // Initialise RAM disk
  mov     x9, RAM_DISK_SIZE                       // x9 = size of RAM disk
  sub     x9, x9, #0x60                           // x9 = offset from start of RAM disk to last journal entry; RAM disk entries are 96 (0x60) bytes and journal grows downwards from end of RAM disk
  adr     x10, ram_disk                           // x10 = start address of ramdisk
  add     x11, x9, x10                            // x11 = absolute address of last journal entry of RAM disk
  str     x11, [x28, SFNEXT-sysvars]              // Store current journal entry in SFNEXT.
  str     x10, [x11, #0x40]                       // Store RAM_DISK start location in first RAM Disk Catalogue journal entry.
  str     x9, [x28, SFSPACE-sysvars]              // Store free space in SFSPACE.

  ldr     w14, arm_size                           // x14 = first byte of shared GPU memory, for determining where CPU dedicated RAM ends (one byte below)
  sub     x14, x14, 1                             // x14 = last byte of dedicated RAM (not shared with GPU)
  str     x14, [x28, P_RAMT-sysvars]              // [P_RAMT] = 0x3bffffff
  mov     x15, UDG_COUNT * 4                      // x15 = number of double words (8 bytes) of characters to copy to the user defined graphics region
  adr     x16, char_set + (FIRST_UDG_CHAR - 32) * 32
                                                  // x16 = address of first UDG char to copy
  sub     x18, x14, UDG_COUNT * 32 - 1            // x18 = first byte of user defined graphics
  str     x18, [x28, UDG-sysvars]                 // [UDG] = first byte of user defined graphics

  // Loop to copy UDG_COUNT characters into User Defined Graphics memory region at end of RAM.
  2:
    ldr     x17, [x16], 8
    str     x17, [x18], 8
    subs    x15, x15, 1
    b.ne    2b

  mov     w12, 0x40
  strb    w12, [x28, RASP-sysvars]                // [RASP]=0x40
  strb    wzr, [x28, PIP-sysvars]                 // [PIP]=0x00
  sub     x13, x18, 1 + UDG_COUNT * 32
  str     x13, [x28, RAMTOP-sysvars]              // [RAMPTOP] = UDG - 1 (address of last byte before UDG starts).
  b       new


pin:                                     // L009A
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  // TODO
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


pout:                                    // L009F
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  // TODO
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


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
.if       DEBUG_PROFILE
  bl      demo                                    // Demonstrate features for manual inspection.
.endif
  b       sleep

# -----------------------
# New Error Message Table
# -----------------------

msg_merge_error:                         // L048C
  .asciz "MERGE error"                            // Report 'a'.
msg_wrong_file_type:                     // L0497
  .asciz "Wrong file type"                        // Report 'b'.
msg_code_error:                          // L04A6
  .asciz "CODE error"                             // Report 'c'.
msg_too_many_brackets:                   // L04B0
  .asciz "Too many brackets"                      // Report 'd'.
msg_file_already_exists:                 // L04C1
  .asciz "File already exists"                    // Report 'e'.
msg_invalid_name:                        // L04D4
  .asciz "Invalid name"                           // Report 'f'.
msg_file_does_not_exist:                 // L04E0
  .asciz "File does not exist"                    // Report 'g' & 'h'.
msg_invalid_device:                      // L04F3
  .asciz "Invalid device"                         // Report 'i'.
msg_invalid_baud_rate:                   // L0501
  .asciz "Invalid baud rate"                      // Report 'j'.
msg_invalid_note_name:                   // L0512
  .asciz "Invalid note name"                      // Report 'k'.
msg_number_too_big:                      // L0523
  .asciz "Number too big"                         // Report 'l'.
msg_note_out_of_range:                   // L0531
  .asciz "Note out of range"                      // Report 'm'.
msg_out_of_range:                        // L0542
  .asciz "Out of range"                           // Report 'n'.
msg_too_many_tied_notes:                 // L054E
  .asciz "Too many tied notes"                    // Report 'o'.
msg_bad_parameter:                                // <missing>
  .asciz "Bad parameter"                          // Report 'p'.
msg_copyright:                           // L0561
  .byte 0x7f                                      // '(c)'.
  .asciz " 1986 Sinclair Research Ltd"


# Print zero byte delimited string stored at memory location x0 to current channel.
# On entry:
#   x0 = address of zero byte delimited string
print_message:                           // L057D
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack.
  mov     x19, x0
  b       2f
1:
  mov     w0, w1
  bl      print_w0
2:
  ldrb    w1, [x19], #1
  cbnz    w1, 1b
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


.align 3
# ---------------------------------
# The 'Initial Channel Information'
# ---------------------------------
# Initially there are four channels ('K', 'S', 'R', & 'P') for communicating
# with the 'keyboard', 'screen', 'workspace' and 'printer'. For each channel
# the output routine address comes before the input routine address and the
# channel's code. This table is almost identical to that in ROM 1 at 0x15AF but
# with changes to the channel P routines to use the RS232 port instead of the
# ZX Printer.
# Used at 0x01DD (ROM 0).
initial_channel_info:                    // L0589
  .quad print_out                                 // PRINT_OUT - K channel output routine.
  .quad key_input                                 // KEY_INPUT - K channel input routine.
  .byte 'K',0,0,0,0,0,0,0                         // 0x4B      - Channel identifier 'K'.
  .quad print_out                                 // PRINT_OUT - S channel output routine.
  .quad report_j                                  // REPORT_J  - S channel input routine.
  .byte 'S',0,0,0,0,0,0,0                         // 0x53      - Channel identifier 'S'.
  .quad add_char                                  // ADD_CHAR  - R channel output routine.
  .quad report_j                                  // REPORT_J  - R channel input routine.
  .byte 'R',0,0,0,0,0,0,0                         // 0x52      - Channel identifier 'R'.
  .quad pout                                      // POUT      - P Channel output routine.
  .quad pin                                       // PIN       - P Channel input routine.
  .byte 'P',0,0,0,0,0,0,0                         // 0x50      - Channel identifier 'P'.
  .quad 0x80                                      // End-marker. Not sure yet why this is needed, but might
                                                  // be so that user can grow this heap-based table and push
                                                  // BASIC program higher up in RAM? The stream data below
                                                  // points directly to entries in this table, so this table
                                                  // isn't iterated through when opening a channel.
initial_channel_info_END:


.align 1
# -------------------------
# The 'Initial Stream Data'
# -------------------------
# Initially there are seven streams: -3 to 3.
# This table is identical to that in ROM 1 at 0x15C6.
initial_stream_data:                     // L059E
  .byte 0x01, 0x00                                // Stream -3 leads to channel 'K'.
  .byte 0x19, 0x00                                // Stream -2 leads to channel 'S'.
  .byte 0x31, 0x00                                // Stream -1 leads to channel 'R'.
  .byte 0x01, 0x00                                // Stream  0 leads to channel 'K'.
  .byte 0x01, 0x00                                // Stream  1 leads to channel 'K'.
  .byte 0x19, 0x00                                // Stream  2 leads to channel 'S'.
  .byte 0x49, 0x00                                // Stream  3 leads to channel 'P'.
initial_stream_data_END:
