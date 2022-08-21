# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.set UART_DEBUG, 1

.set TESTS_INCLUDE, 1
.set TESTS_AUTORUN, 1
.set MEMORY_DUMPS_BUFFER_SIZE, 0x02000000         // 32MB

.set DEMO_INCLUDE, 0
.set DEMO_AUTORUN, 0

.set ROMS_INCLUDE, 0
.set ROMS_AUTORUN, 0

.set QEMU, 1


.set BORDER_COLOUR,    0x000000cc                 // Default border colour around screen.
.set PAPER_COLOUR,     0x00cccccc                 // Default paper colour (background colour of screen).
.set INK_COLOUR,       0x00000000                 // Default ink colour (foreground colour of text on screen).

.set RAM_DISK_SIZE,    0x00010000                 // 64KB
.set HEAP_SIZE,        0x00010000                 // 64KB
