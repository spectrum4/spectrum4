# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

##########################################################################
# Information gleaned from the following sources:
#   * Linux Kernel:
#     + https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c
#   * Raspberry Pi Forums:
#     + https://forums.raspberrypi.com/viewtopic.php?p=1675084
#     + https://forums.raspberrypi.com/viewtopic.php?p=2087624
##########################################################################

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

  // Reset the PCI bridge

  ldr     w6, [x4]
  orr     w6, w6, #3                              // set bits 0 (PCIE_RGR1_SW_INIT_1_PERST) and 1 (RGR1_SW_INIT_1_INIT_GENERIC)
                                                  //   bit 0 (PCIE_RGR1_SW_INIT_1_PERST):
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L882
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L771-L778
                                                  //   bit 1 (RGR1_SW_INIT_1_INIT_GENERIC):
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L883
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L730-L738
  str     w6, [x4]                                //   of [0xfd509210] (RGR1_SW_INIT_1)
  mov     x0, #100
  bl      wait_usec                               // sleep 0.1ms (Linux kernel sleeps 0.1-0.2ms) with sleep_range:
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L885
                                                  //   https://www.kernel.org/doc/Documentation/timers/timers-howto.txt

  // Take the PCI bridge out of reset

  and     w6, w6, #~0x2                           // clear bit 1 (RGR1_SW_INIT_1_INIT_GENERIC)
  str     w6, [x4]                                //   of [0xfd509210] (RGR1_SW_INIT_1)
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L888
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L730-L738
  ldr     w6, [x7, 0xfd504204-0xfd504068]
  and     w6, w6, #~0x08000000                    // clear bit 27 (HARD_DEBUG_SERDES_IDDQ)
  str     w6, [x7, 0xfd504204-0xfd504068]         //   of [0xfd504204] (PCIE_MISC_HARD_PCIE_HARD_DEBUG)
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L890-L892

  // Wait for SerDes (Serializer/Deserializer) to be stable

  mov     x0, #100
  bl      wait_usec                               // sleep 0.1ms (Linux kernel sleeps 0.1-0.2ms) with sleep_range:
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L894
                                                  //   https://www.kernel.org/doc/Documentation/timers/timers-howto.txt

  // Note, the entire following section could probably be simplified to just write
  // a hardcoded value to [0xfd504008] (PCIE_MISC_MISC_CTRL) but for now mirroring
  // what Linux does (although combining and reordering updates).

  // SCB_MAX_BURST_SIZE is a two bit field. For BCM2711 it is encoded as:
  //   0b00 => 128 bytes
  //   0b01 => 256 bytes
  //   0b10 => 512 bytes
  //   0b11 => Reserved value

  ldur    w6, [x7, 0xfd504008-0xfd504068]
  orr     w6, w6, #0x3000                         // set bits 12 (SCB_ACCESS_EN), 13 (CFG_READ_UR_MODE)
                                                  //   bit 12 (SCB_ACCESS_EN):
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L910
                                                  //   bit 13 (CFG_READ_UR_MODE):
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L911
  and     w6, w6, #~0x300000                      //   and clear bits 20, 21 (=> SCB_MAX_BURST_SIZE = 128 bytes)
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L912
  mov     w8, 0b10001                             //   and bits 27-31 (SCB0_SIZE) write as 0b10001 = 17 (4GB)
  bfi     w6, w8, #27, #5                         //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L932
  stur    w6, [x7, 0xfd504008-0xfd504068]         //   of [0xfd504008] (PCIE_MISC_MISC_CTRL)

  // PCIE_MISC_RC_BAR2_CONFIG_{LO,HI} are set here in the Linux kernel, based on the DMA ranges specified in the Device Tree.
  // The pcie ranges and dma ranges in https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/arch/arm/boot/dts/bcm2711.dtsi#L588-L596
  // appear to suggest that 1GB of CPU physical addresses [0x0000 0006 0000 0000 -> 0x0000 0006 3fff ffff] should be memory mapped to
  // 1GB of PCIE bus addresses [0x0000 0000 c000 0000 -> 0x0000 0000 ffff ffff] (from "ranges") and that
  // 3GB of PCIE bus addresses [0x0000 0000 0000 0000 -> 0x0000 0000 bfff ffff] should be mapped to CPU physical addresses
  // [0x0000 0000 0000 0000 -> 0x0000 0000 bfff ffff] (from "dma-ranges"):
  //   * https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L915-L925
  //   * https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L780-L865
  // The code that calculates PCIE_MISC_RC_BAR2_CONFIG_{LO,HI} I haven't completely understood, but from the values that actually get
  // assigned on my rpi400, it looks like rc bar2 offset is 16GB, and rc bar2 size is 4GB. This doesn't seem to match the above ranges,
  // so I am a little confused. The code for determining PCIE_MISC_RC_BAR2_CONFIG_{LO,HI} also appears to only query the "dma-ranges",
  // and not the "ranges", so this probably only relates to inbound memory views, not outbound.

  mov     w6, #0x11
  stur    w6, [x7, 0xfd504034-0xfd504068]         // [0xfd504034] (PCIE_MISC_RC_BAR2_CONFIG_LO) = 0x11
                                                  // => RC BAR2 size = 4GB since bits 0-4 are set to return value of:
                                                  // https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L302-L318
  mov     w6, #0x4
  stur    w6, [x7, 0xfd504038-0xfd504068]         // [0xfd504038] (PCIE_MISC_RC_BAR2_CONFIG_HI) = 0x4
                                                  // => RC BAR2 offset = 16GB

  // Disable the PCIe->GISB (Global Incoherent System Bus) memory window

  ldur    w6, [x7, 0xfd50402c-0xfd504068]
  and     w6, w6, #~0x1f                          // clear bits 0-4 (RC_BAR1_CONFIG_LO_SIZE)
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L952-L955
  stur    w6, [x7, 0xfd50402c-0xfd504068]         // of [0xfd50402c] (PCIE_MISC_RC_BAR1_CONFIG_LO)

  // Disable the PCIe->SCB memory window

  ldur    w6, [x7, 0xfd50403c-0xfd504068]
  and     w6, w6, #~0x1f                          // clear bits 0-4 (RC_BAR3_CONFIG_LO_SIZE)
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L957-L960
  stur    w6, [x7, 0xfd50403c-0xfd504068]         // of [0xfd50403c] (PCIE_MISC_RC_BAR3_CONFIG_LO)

  // Unassert the fundamental reset

  ldr     w6, [x4]                                // note, if we can assume the value hasn't changed, we could cache current value in a register and avoid this extra ldr instruction
  and     w6, w6, #~0x1                           // clear bit 0 (PCIE_RGR1_SW_INIT_1_PERST)
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L966
  str     w6, [x4]                                // of [0xfd509210] (RGR1_SW_INIT_1)

  // Give the RC/EP time to wake up, before trying to configure RC.
  // Intermittently check status for link-up, up to a total of 100ms.
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L968-L973

  mov     w8, #100                                // 100ms
1:
  cbz     w8, 2f                                  // branch forward to error routine at 3: if 100 iterations have completed
  sub     w8, w8, #1                              // note, linux kernel checks only every 5ms, but we check every 1ms
  mov     x0, #1000
  bl      wait_usec                               // sleep 1ms
  ldr     w0, [x7]
  tbz     w0, #4, 1b                              // repeat loop if bit 4 is clear (PCIE_MISC_PCIE_STATUS_PCIE_PHYLINKUP)
  tbz     w0, #5, 1b                              // repeat loop if bit 5 is clear (PCIE_MISC_PCIE_STATUS_PCIE_DL_ACTIVE)
2:
  stp     w0, w8, [x9, #0x04]                     // store last read status register value and number of 1ms
                                                  // loop iterations on heap, to report later
  cbz     w8, 3f                                  // exit early if failed to wake up
  tbz     w0, #7, 3f                              // exit early if bit 7 is clear (PCIE_MISC_PCIE_STATUS_PCIE_PORT)
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L980-L983
                                                  // implies PCIe misconfigured: in EP (endpoint) mode rather than RC (root complex) mode

  // Configure a single outbound window:
  //   pcie base address           = 0x0000 0000 c000 0000
  //   cpu base address            = 0x0000 0006 0000 0000
  //   size                        = 0x0000 0000 3ff0 0000
  //   cpu limit address
  //     (cpu address + size - 1)  = 0x0000 0006 3fef ffff

  // Set the base of the pcie address window
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L433-L435

  mov     w0, 0xc0000000                          // PCI address of outbound window
  stur    w0, [x7, 0xfd50400c-0xfd504068]         // [0xfd50400c] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_LO) =0xc0000000 (low 32 bits of pcie address)
  stur    wzr, [x7, 0xfd504010-0xfd504068]        // [0xfd504010] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_HI) =0x00000000 (high 32 bits of pcie address)

  // Write the cpu base address (bits 20-31) and limit address (bits 20-31)
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L437-L446

  ldr     w0, [x7, 0xfd504070-0xfd504068]
  and     w0, w0, #0x000f000f                     // Clear bits 4-15 (BASE) and bits 20-31 (LIMIT)
  orr     w0, w0, #0x3ff00000                     //   then set bits 20-31 (LIMIT) to 0x3ff
  str     w0, [x7, 0xfd504070-0xfd504068]         // of [0xfd504070] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_BASE_LIMIT)

  // Write the cpu base address (bits 32-39) and limit address (bits 32-39)
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L448-L462

  mov     w8, #0x06                               // constant serves as both cpu base address bits 32-39 and cpu limit address bits 32-39
  ldr     w0, [x7, 0xfd504080-0xfd504068]         // Update [0xfd504080] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_BASE_HI) lower 8 bits
  bfi     w0, w8, #0, #8                          //   to cpu base address bits 32-39 (=0x06)
  str     w0, [x7, 0xfd504080-0xfd504068]         //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L456
  ldr     w6, [x7, 0xfd504084-0xfd504068]         // Update [0xfd504084] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_LIMIT_HI) lower 8 bits
  bfi     w6, w8, #0, #8                          //   to cpu limit address bits 32-39 (=0x06)
  str     w6, [x7, 0xfd504084-0xfd504068]         //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L462

  // * set bits 10, 11 (already set) of [0xfd5004dc] (priv1 link capability)
  // * set bits 0-23 of [0xfd50043c] to 0x060400 (pcie-pcie bridge) - were already set
  // * Enable SSC (spread spectrum clocking) steps
  //   * set [0xfd501100]=0x1f (SET_ADDR_OFFSET to be written)
  //   * read it back ([0xfd501100])
  //   * set [0xfd501104]=0x80001100 (value to set, with bit 31 set)
  //   * read it back every 10us until bit 31 is clear or 10 attempts fail
  //   * set [0xfd501100]=0x100002 (SSC_CNTL_OFFSET to be read)
  //   * read it back ([0xfd501100])
  //   * SSC_CNTL_OFFSET = read [0xfd501108] every 10us until bit 31 is set or 10 attempts failed
  //   * set bits 14, 15 of SSC_CNTL_OFFSET (although bit 15 was already set)
  //   * set [0xfd501100]=0x2 (SSC_CNTL_OFFSET to be written)
  //   * read it back ([0xfd501100])
  //   * write SSC_CNTL_OFFSET to [0xfd501104]
  //   * read it back every 10us until bit 31 is clear or 10 attempts fail
  //   * set [0xfd501100]=0x100001 (SSC_STATUS_OFFSET to be read)
  //   * read it back ([0xfd501100])
  //   * SSC_STATUS_OFFSET = read [0xfd501108] every 10us until bit 31 is set or 10 attempts failed
  // * read 16 bits of [0xfd5000be]
  // * report pcie current link speed (bits 0-3) and negotiated link width (bits 4-9) (number of lanes?) and whether SSC enabled (from SSC_STATUS_OFFSET??)
  // * clear bits 2, 3 of [0xfd500188] (PCIe->SCB endian mode for BAR) (although already clear)
  // * clear bit 21 and set bit 1 of [0xfd504204] (refclk from RC gated with CLKREQ# input when ASPM L0s,L1 is enabled)
  // * get revision from [0xfd50406c]
  // * MSI init stuff
  //   * set [0xfd504514]=0xffffffff (mask interrupts?)
  //   * set [0xfd504508]=0xffffffff (clear interrupts?)
  //   * set [0xfd504044]=0xfffffffd (lower 32 bits of msi target address with bit 0 set => msi enable)
  //   * set [0xfd504048]=0x0 (upper 32 bits of msi target address)
  //   * set [0xfd50404c]=0xffe06540

  ldr     w0, [x7, 0xfd50406c-0xfd504068]         // w0 = [0xfd50406c] (revision number)
  str     w0, [x9]                                // store revision number on heap for logging later
                                                  // since logging requires stack pointer initialised
                                                  // but that isn't done yet, so do it later
  mov     w0, #0xffffffff
  str     w0, [x7, 0xfd504314-0xfd504068]         // set bits 0-31 of [0xfd504314] (clear interrupts)
  str     w0, [x7, 0xfd504310-0xfd504068]         // set bits 0-31 of [0xfd504310] (mask interrupts)

  cbz     w8, 2f                                  // abort pcie initialisation if bit 4 or bit 5 not set
  ldr     w0, [x10, 0x043c]                       // class code
  and     w1, w0, 0xff000000
  mov     w2, 0x181
  bfi     w1, w2, #10, #9                         // w1 = (class code & 0xff000000) | 0x00060400
  str     w1, [x10, 0x043c]                       // update class code
  stp     w0, w1, [x9, #0x0c]                     // store initial and updated class code on heap
  mov     w0, 0x03f00000
  str     w0, [x7, 0xfd504070-0xfd504068]         // RPI_PCIE_REG_MEM_CPU_LO ([0xfd504070] = 0x03f00000)
  mov     w1, 0x6
  str     w1, [x7, 0xfd504080-0xfd504068]         // RPI_PCIE_REG_MEM_CPU_HI_START ([0xfd504080] = 0x00000006)
  str     w1, [x7, 0xfd504084-0xfd504068]         // RPI_PCIE_REG_MEM_CPU_HI_END ([0xfd504084] = 0x00000006)
  ldr     w2, [x10]                               // x2 bits 0-15: did, bits 16-31: vid
  ldrb    w3, [x10, #0x0e]                        // w3 = header type
  stp     w2, w3, [x9, #0x14]                     // store did/vid/header type on heap
3:
  ret     x5
