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

.include "restart.s"                     // L0000
.include "pin.s"                         // L009A
.include "pout.s"                        // L009F
.include "new.s"                         // L019D
.include "error_messages.s"              // L048C
.include "print_message.s"               // L057D
.include "initial_channel_info.s"        // L0589
.include "initial_stream_data.s"         // L059E
.include "basic_48k.s"                   // L1B47
.include "init_mode.s"                   // L2584
.include "main_menu.s"                   // L259F
.include "wait_key_press.s"              // L2653
.include "tape_tester.s"                 // L2816
.include "tape_loader.s"                 // L2831
.include "basic_128k.s"                  // L286C
.include "calculator.s"                  // L2885
.include "reset_cursor.s"                // L28BE
.include "reset_main_screen.s"           // L2E1F
.include "reset_indentation.s"           // L35BC
.include "mode_l.s"                      // L365E
.include "display_menu.s"                // L36A8
.include "store_menu_screen_area.s"      // L373B
.include "restore_menu_screen_area.s"    // L373E
.include "init_cursor.s"                 // L3A7F
