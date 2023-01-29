# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


# Information gleaned from the following sources:
#   * https://forums.raspberrypi.com/viewtopic.php?p=1675084&hilit=pcie#p1675084

.align 2
pcie_init_bcm2711:
  mov     x5, x30
  movl    w4, 0xfd509210                          // reset controller
  ldr     w6, [x4]
  orr     w6, w6, #3
  str     w6, [x4]
  mov     x0, #1000
  bl      wait_usec
  and     w6, w6, #~0x2
  str     w6, [x4]
  ldr     w6, [x4]                                // might not be necessary
  movk    w4, #0x406c
  ldr     w0, [x4]
  adrp    x1, heap
  add     x1, x1, :lo12:heap
  str     w0, [x1]
  ret     x5
