.text
.align 2
restart:                                 // L0000
  msr     daifset, #3                             // Disable (mask) interrupts and fast interrupts.
  mov     x0, x28                                 // x0 = sys variable start address
  adrp    x1, sysvars_end                         // x1 = sys variable end marker
  add     x1, x1, :lo12:sysvars_end
  1:                                              // Loop to clear all bits of all system variables.
    strb    wzr, [x0], #1                         // Clear byte.
    cmp     x0, x1                                // Check if all bytes updated.
    b.ne    1b                                    // If not, loop back.

  // Initialise RAM disk
  mov     x9, RAM_DISK_SIZE                       // x9 = size of RAM disk
  sub     x9, x9, #0x60                           // x9 = offset from start of RAM disk to last journal entry; RAM disk entries are 96 (0x60) bytes and journal grows downwards from end of RAM disk
  adrp    x10, ram_disk                           // x10 = start address of ramdisk
  add     x10, x10, :lo12:ram_disk
  add     x11, x9, x10                            // x11 = absolute address of last journal entry of RAM disk
  str     x11, [x28, SFNEXT-sysvars]              // Store current journal entry in SFNEXT.
  str     x10, [x11, #0x40]                       // Store RAM_DISK start location in first RAM Disk Catalogue journal entry.
  str     x9, [x28, SFSPACE-sysvars]              // Store free space in SFSPACE.

  ldr     w14, arm_size                           // x14 = first byte of shared GPU memory, for determining where CPU dedicated RAM ends (one byte below)
  sub     x14, x14, 1                             // x14 = last byte of dedicated RAM (not shared with GPU)
  str     x14, [x28, P_RAMT-sysvars]              // [P_RAMT] = 0x3bffffff
  mov     x15, UDG_COUNT * 4                      // x15 = number of double words (8 bytes) of characters to copy to the user defined graphics region
  adrp    x16, char_set + (FIRST_UDG_CHAR - 32) * 32
  add     x16, x16, :lo12:(char_set + (FIRST_UDG_CHAR - 32) * 32)
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
