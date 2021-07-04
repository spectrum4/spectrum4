# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.set DEBUG_PROFILE, 1
.set RELEASE_PROFILE, 0

.set BORDER_COLOUR,    0x00cc0000                 // Default border colour around screen.
.set PAPER_COLOUR,     0x00cccccc                 // Default paper colour (background colour of screen).
.set INK_COLOUR,       0x00000000                 // Default ink colour (foreground colour of text on screen).

.set RAM_DISK_SIZE,    0x00010000                 // 64KB
.set HEAP_SIZE,        0x00010000                 // 64KB

.ifdef QEMU
  .set AUX_MU_LSR_DATA_READY, 0x60
  .set RNG_BIT_SHIFT,    24
.else
  .set AUX_MU_LSR_DATA_READY, 0x61
  .set RNG_BIT_SHIFT,    25
.endif
