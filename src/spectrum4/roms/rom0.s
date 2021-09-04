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

.include "restart.s"
.include "pin.s"
.include "pout.s"
.include "new.s"

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

.include "print_message.s"
.include "initial_channel_info.s"
.include "initial_stream_data.s"
