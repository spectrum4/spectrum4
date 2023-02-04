# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


# Information gleaned from the following sources:
#   * https://forums.raspberrypi.com/viewtopic.php?p=1675084&hilit=pcie#p1675084

# On return:
#   [heap+0x00]: revision number
#   [heap+0x04]: last read status register
#   [heap+0x08]: number of iterations of 1ms reading status register
#   [heap+0x0c]: initial class code
#   [heap+0x10]: updated class code
#   [heap+0x14]: vid
#   [heap+0x16]: did
#   [heap+0x18]: header type

.align 2
pcie_init_bcm2711:
  mov     x5, x30
  movl    w10, 0xfd500000                         // x10 = pcie_base
  movl    w4, 0xfd509210                          // x4 = pcie reset controller register
  movl    w7, 0xfd504068                          // x7 = pcie status register
  adrp    x9, heap
  add     x9, x9, :lo12:heap                      // x9 = heap
  ldr     w6, [x4]
  orr     w6, w6, #3
  str     w6, [x4]                                // set bits 0 and 1 of reset controller
  mov     x0, #1000
  bl      wait_usec                               // sleep 1ms
  and     w6, w6, #~0x2
  str     w6, [x4]                                // clear bit 1 of reset controller
  ldr     w6, [x4]                                // read back value - really necessary?
  ldr     w0, [x7, 0x406c-0x4068]
  str     w0, [x9]                                // store revision number on heap for logging later
                                                  // since logging requires stack pointer initialised
                                                  // but that isn't done yet, so do it later
  mov     w0, #0xffffffff
  str     w0, [x7, 0x4314-0x4068]                 // clear interrupts
  str     w0, [x7, 0x4310-0x4068]                 // mask interrupts
  ldr     w6, [x4]                                // read back value - really necessary again? probably not!
  and     w6, w6, #~0x1
  str     w6, [x4]                                // clear bit 0 of reset controller (bring out of reset)
  mov     w8, #100
1:                                                // loop waiting for bits 4 and 5 of pcie status register to be set
  cbz     w8, 2f                                  // exit loop if still not acheived after 100 iterations
  sub     w8, w8, #1
  mov     x0, #1000
  bl      wait_usec                               // sleep 1ms
  ldr     w0, [x7]
  tbz     w0, #4, 1b                              // only repeat loop if bit 4 is clear
  tbz     w0, #5, 1b                              // only repeat loop if bit 5 is clear
2:
  stp     w0, w8, [x9, #0x04]                     // store last read status register value and number of 1ms
                                                  // loop iterations on heap, to report later
  cbz     w8, 3f                                  // abort pcie initialisation if bit 4 or bit 5 not set
  ldr     w0, [x10, 0x043c]                       // class code
  and     w1, w0, 0xff000000
  mov     w2, 0x181
  bfi     w1, w2, #10, #9                         // w1 = (class code & 0xff000000) | 0x00060400
  str     w1, [x10, 0x043c]                       // update class code
  stp     w0, w1, [x9, #0x0c]                     // store initial and updated class code on heap
  mov     w0, 0xf8000000                          // PCI address as seen by PCI controller?
  stur    w0, [x7, 0x400c-0x4068]                 // [0x400c]=0xf8000000 (low 32 bits of PCIe address as seen by PCI controller?)
  stur    wzr, [x7, 0x4010-0x4068]                // [0x4010]=0x00000000 (high 32 bits of PCIe address as seen by PCI controller?)
  mov     w0, 0x03f00000
  str     w0, [x7, 0x4070-0x4068]                 // RPI_PCIE_REG_MEM_CPU_LO
  mov     w1, 0x6
  str     w1, [x7, 0x4080-0x4068]                 // RPI_PCIE_REG_MEM_CPU_HI_START
  str     w1, [x7, 0x4084-0x4068]                 // RPI_PCIE_REG_MEM_CPU_HI_END
  ldr     w2, [x10]                               // bits 0-15: did, bits 16-31: vid
  ldrb    w3, [x10, #0x0e]                        // header type
  stp     w2, w3, [x9, #0x14]
3:
  ret     x5
