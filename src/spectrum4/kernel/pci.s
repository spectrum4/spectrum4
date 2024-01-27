# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2

# pci_bus memory block
#   0x00-0x07: parent bus address (or 0 if root bus)
#   0x08-0x0f: bus number


# On entry:
#   x0 = bus data address
#   x1 = devfn
#   x2 = where (pci reg offset)
#   w3 = size
#
# On return:
#   w0 = 0x00 (PCI successful), or
#        0x86 (PCI device not found), or
#        0x87 (PCI bad register number => unaligned access)
#   w1 = value read (if access was aligned)
#   w2 = untouched
#   x3 disturbed
#   w5 = size - 1
#
# Based on
#   * https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/access.c#L35-L48
#   * https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/access.c#L77-L96
pci_read:
  sub     w5, w3, #1
  tst     w2, w5
  b.ne    6f
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  bl      map_conf
  cbnz    x0, 1f
  mov     w1, #-1
  mov     w0, #0x86                               // PCIBIOS_DEVICE_NOT_FOUND
  b       5f
1:
  cbz     w5, 3f
  cmp     w5, #0x1
  b.eq    2f
  ldr     w1, [x0]
  b       4b
2:
  ldrh    w1, [x0]
  b       4b
3:
  ldrb    w1, [x0]
4:
  dmb     oshld
  mov     w0, #0                                  // PCIBIOS_SUCCESSFUL
5:
  ldp     x29, x30, [sp], #16
  ret
6:
  mov     w0, #0x87                               // PCIBIOS_BAD_REGISTER_NUMBER (unaligned access)
  ret

# TODO work in progress
#
# Based on
#   * https://github.com/petemoore/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/probe.c#L2333-L2348
pci_dev_vendor_id:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  mov     w2, #0x00
  mov     w3, #0x04
  bl      pci_read
  and     w2, w1, #0xffff
  cmp     w2, #0x0001
  b.eq    1f
  mov     x0, #0x01
  b       2f
1:
2:
  ldp     x29, x30, [sp], #16
  ret

.include "stubs.s"
