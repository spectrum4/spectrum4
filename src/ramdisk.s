# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

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
# There is no heap and no malloc/free functions in spectrum4, when a file is
# deleted, any file which is stored after it is relocated to a lower memory
# address to remove the gap of the file contents, and the catalogue entries are
# moved to a higher memory address to remove the gap in the catalogue. This is
# clearly suboptimal, but is implemented this way to match the original
# spectrum. This can be later improved once things are working.
#
# A file consists of a 32 byte header (256 bits) followed by the data for the file. The header bytes
# have the following meaning:
#   Bytes 0x00-0x07: FLAGS
#                      Bits 0-15:  File type - 0x00=Program, 0x01=Numeric array, 0x02=Character array, 0x03=Code/Screen$.
#                      Bits 16-63: Auto-run line number for a program (0xffffffffffff if no auto-run).
#   Bytes 0x08-0x0F: Length of program/code block/screen$/array
#   Bytes 0x10-0x17: Start of code block/screen$
#   Bytes 0x18-0x1F: Offset to the variables (i.e. length of program) if a program. For an array, 0x18 holds the variable name.

.text
# ------------------------------------------------------------------------------
# Initialises the ram disk
# ------------------------------------------------------------------------------
init_ramdisk:
  mov     x9, RAM_DISK_SIZE               // x9 = size of ramdisk.
  sub     x9, x9, #0x60                   // x9 = offset from start of RAM disk to last journal entry; RAM disk entries are 96 (0x60) bytes and journal grows downwards from end of ramdisk.
  adr     x10, ram_disk                   // x10 = start address of ramdisk.
  add     x11, x9, x10                    // x11 = absolute address of last journal entry of RAM disk.
  str     x11, [x28, SFNEXT-sysvars]      // Store current journal entry in SFNEXT.
  str     x10, [x11, #0x40]               // Store RAM_DISK start location in first RAM Disk Catalogue journal entry.
  str     x9, [x28, SFSPACE-sysvars]      // Store free space in SFSPACE.
  ret
