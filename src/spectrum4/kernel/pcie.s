# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text

##########################################################################
# Information gleaned from the following sources:
#   * Linux Kernel:
#     + https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c
#   * Raspberry Pi Forums:
#     + https://forums.raspberrypi.com/viewtopic.php?p=1675084
#     + https://forums.raspberrypi.com/viewtopic.php?p=2087624
##########################################################################

# On return:
#   [heap+0x00]: last read status register
#   [heap+0x04]: number of iterations of 1ms reading status register
#   [heap+0x08]: initial class code
#   [heap+0x0c]: updated class code
#   [heap+0x10]: SSC configuration steps successfully completed (0-6)
#   [heap+0x12]: link capabilities
#   [heap+0x14]: revision number
#   [heap+0x18]: vid
#   [heap+0x1a]: did
#   [heap+0x1c]: header type (lower 8 bits)
#   [heap+0x20]: bus 1 class (upper 24 bits) and revision (lower 8 bits)
#   [heap+0x24]: bus 1 header type (lower 8 bits)
#   [heap+0x28]: SSC status register
#   [heap+0x2c]: XHCI_REG_CAP_HCIVERSION (16 bits)

.align 2
pcie_init_bcm2711:

  mov     x5, x30
  adrp    x10, 0xfd500000 + _start                // x10 = PCI to PCI bridge config space base address
  adrp    x4, 0xfd504000 + _start                 // x4 = VL805 USB Host controller registers
  adrp    x13, 0xfd508000 + _start                // x13 = USB Controller config space base address
  adrp    x14, 0xfd509000 + _start                // x14 = PCI bridge registers
  adrp    x7, heap
  add     x7, x7, :lo12:heap                      // x7 = heap

  // Reset the PCI bridge
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L881-L885
  //
  // Updates registers:
  //   * RGR1_SW_INIT_1

  ldrwi   w6, x14, #0x210
  orr     w6, w6, #3                              // set bits 0 (PCIE_RGR1_SW_INIT_1_PERST) and 1 (RGR1_SW_INIT_1_INIT_GENERIC)
                                                  //   bit 0 (PCIE_RGR1_SW_INIT_1_PERST):
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L882
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L771-L778
                                                  //   bit 1 (RGR1_SW_INIT_1_INIT_GENERIC):
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L883
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L730-L738
  strwi   w6, x14, #0x210                         //   of [0xfd509210] (RGR1_SW_INIT_1)
  mov     x0, #100
  bl      wait_usec                               // sleep 0.1ms (Linux kernel sleeps 0.1-0.2ms) with sleep_range:
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L885
                                                  //   https://www.kernel.org/doc/Documentation/timers/timers-howto.txt

  // Take the PCI bridge out of reset
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L887-L892
  //
  // Updates registers:
  //   * RGR1_SW_INIT_1
  //   * PCIE_MISC_HARD_PCIE_HARD_DEBUG

  and     w6, w6, #~0x2                           // clear bit 1 (RGR1_SW_INIT_1_INIT_GENERIC)
  strwi   w6, x14, #0x210                         //   of [0xfd509210] (RGR1_SW_INIT_1)
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L888
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L730-L738
  ldrwi   w6, x4, #0x204
  and     w6, w6, #~0x08000000                    // clear bit 27 (HARD_DEBUG_SERDES_IDDQ)
  strwi   w6, x4, #0x204                          //   of [0xfd504204] (PCIE_MISC_HARD_PCIE_HARD_DEBUG)
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L890-L892

  // Wait for SerDes (Serializer/Deserializer) to be stable
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L893-L894

  mov     x0, #100
  bl      wait_usec                               // sleep 0.1ms (Linux kernel sleeps 0.1-0.2ms) with sleep_range:
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L894
                                                  //   https://www.kernel.org/doc/Documentation/timers/timers-howto.txt

  // Set SCB_MAX_BURST_SIZE, CFG_READ_UR_MODE, SCB_ACCESS_EN
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L896-L913
  // and SCB0_SIZE (note, we perform these updates in a different order to Linux to reduce code footprint)
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L927-L938
  //
  // Updates registers:
  //   * PCIE_MISC_MISC_CTRL

  // Note, the entire following section could probably be simplified to just write
  // a hardcoded value to [0xfd504008] (PCIE_MISC_MISC_CTRL) but for now mirroring
  // what Linux does (although combining and reordering updates).
  //
  // Note, SCB_MAX_BURST_SIZE is a two bit field. For BCM2711 it is encoded as:
  //   0b00 => 128 bytes
  //   0b01 => 256 bytes
  //   0b10 => 512 bytes
  //   0b11 => Reserved value

  ldrwi   w6, x4, #0x8
  orr     w6, w6, #0x3000                         // set bits 12 (SCB_ACCESS_EN), 13 (CFG_READ_UR_MODE)
                                                  //   bit 12 (SCB_ACCESS_EN):
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L910
                                                  //   bit 13 (CFG_READ_UR_MODE):
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L911
  and     w6, w6, #~0x300000                      //   and clear bits 20, 21 (=> SCB_MAX_BURST_SIZE = 128 bytes)
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L901-L902
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L912
  mov     w8, 0b10001                             //   and bits 27-31 (SCB0_SIZE) write as 0b10001 = 17 (4GB)
  bfi     w6, w8, #27, #5                         //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L932
  strwi   w6, x4, #0x8                            //   of [0xfd504008] (PCIE_MISC_MISC_CTRL)

  // Configure *CPU inbound* memory view (address range on PCIe bus for PCIe devices to access system memory)
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L915-L925
  //
  //   rc bar2 size:  0x0000 0001 0000 0000 (4GB)
  //   pcie start:    0x0000 0004 0000 0000 -> cpu start:   0x0000 0000 0000 0000
  //   pcie end:      0x0000 0004 ffff ffff -> cpu end:     0x0000 0000 ffff ffff
  //
  // Explanation of values
  //   https://forums.raspberrypi.com/viewtopic.php?p=2148607
  //
  // Updates registers:
  //   * PCIE_MISC_RC_BAR2_CONFIG_LO
  //   * PCIE_MISC_RC_BAR2_CONFIG_HI

  mov     w6, #0x11
  strwi   w6, x4, #0x34                           // [0xfd504034] (PCIE_MISC_RC_BAR2_CONFIG_LO) = 0x11
                                                  // => RC BAR2 size = 4GB since bits 0-4 are set to return value of:
                                                  // https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L302-L318
  mov     w6, #0x4
  strwi   w6, x4, #0x38                           // [0xfd504038] (PCIE_MISC_RC_BAR2_CONFIG_HI) = 0x4
                                                  // => RC BAR2 offset = 16GB

  // Disable the PCIe->GISB (Global Incoherent System Bus) memory window
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L952-L955
  //
  // Updates registers:
  //   * PCIE_MISC_RC_BAR1_CONFIG_LO

  ldrwi   w6, x4, #0x2c
  and     w6, w6, #~0x1f                          // clear bits 0-4 (RC_BAR1_CONFIG_LO_SIZE)
  strwi   w6, x4, #0x2c                           // of [0xfd50402c] (PCIE_MISC_RC_BAR1_CONFIG_LO)

  // Disable the PCIe->SCB memory window
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L957-L960
  //
  // Updates registers:
  //   * PCIE_MISC_RC_BAR3_CONFIG_LO

  ldrwi   w6, x4, #0x3c
  and     w6, w6, #~0x1f                          // clear bits 0-4 (RC_BAR3_CONFIG_LO_SIZE)
  strwi   w6, x4, #0x3c                           // of [0xfd50403c] (PCIE_MISC_RC_BAR3_CONFIG_LO)

  // Unassert the fundamental reset
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L965-L966
  //
  // Updates registers:
  //   * RGR1_SW_INIT_1

  ldrwi   w6, x14, #0x210                         // note, if we can assume the value hasn't changed, we could cache current value in a register and avoid this extra ldr instruction
  and     w6, w6, #~0x1                           // clear bit 0 (PCIE_RGR1_SW_INIT_1_PERST)
  strwi   w6, x14, #0x210                         // of [0xfd509210] (RGR1_SW_INIT_1)

  // Give the RC/EP time to wake up, before trying to configure RC.
  // Poll status until ready, every 1ms, up to maximum of 100 times
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L968-L973

  mov     w8, #100                                // 100 attempts
  1:
    cbz     w8, 2f                                // exit loop if 100 iterations have completed
    sub     w8, w8, #1                            // note, linux kernel checks only every 5ms, but we check every 1ms
    mov     x0, #1000
    bl      wait_usec                             // sleep 1ms
    ldrwi   w0, x4, #0x68
    tbz     w0, #4, 1b                            // repeat loop if bit 4 is clear (PCIE_MISC_PCIE_STATUS_PCIE_PHYLINKUP)
    tbz     w0, #5, 1b                            // repeat loop if bit 5 is clear (PCIE_MISC_PCIE_STATUS_PCIE_DL_ACTIVE)
2:
  stp     w0, w8, [x7]                            // store last read status register value and number of 1ms on heap
  cbz     w8, 4f                                  // exit early if failed to wake up

  // Exit early if in endpoint mode, not in root complex mode => implies PCIe misconfiguration
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L980-L983

  tbz     w0, #7, 4f                              // if bit 7 is clear (PCIE_MISC_PCIE_STATUS_PCIE_PORT) branch ahead to 4:

  // Configure *CPU outbound* memory view (address range in system memory for CPU to access PCIe bus addresses)
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L985-L1000
  //
  //   size:          0x0000 0000 4000 0000 (1GB)
  //   cpu start:     0x0000 0006 0000 0000 -> pcie start:   0x0000 0000 c000 0000
  //   cpu end:       0x0000 0006 3fff ffff -> pcie end:     0x0000 0000 ffff ffff
  //
  // Updates registers:
  //   * PCIE_MISC_CPU_2_PCIE_MEM_WIN0_LO
  //   * PCIE_MISC_CPU_2_PCIE_MEM_WIN0_HI
  //   * PCIE_MISC_CPU_2_PCIE_MEM_WIN0_BASE_LIMIT
  //   * PCIE_MISC_CPU_2_PCIE_MEM_WIN0_BASE_HI
  //   * PCIE_MISC_CPU_2_PCIE_MEM_WIN0_LIMIT_HI

  // Set the pcie start address (rc bar2 offset)
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L433-L435

  mov     w0, 0xc0000000                          // PCI address of outbound window
  strwi   w0, x4, #0xc                            // [0xfd50400c] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_LO) =0xc0000000 (low 32 bits of pcie start)
  strwi   wzr, x4, #0x10                          // [0xfd504010] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_HI) =0x00000000 (high 32 bits of pcie start)

  // Set bits 20-31 of cpu start address and bits 20-31 of cpu end address
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L437-L446

  ldrwi   w0, x4, #0x70
  and     w0, w0, #0x000f000f                     // Clear bits 4-15 (BASE) and bits 20-31 (LIMIT)
  orr     w0, w0, #0x3ff00000                     //   then set bits 20-31 (LIMIT) to 0x3ff and bits 4-15 (BASE) to 0x000
  strwi   w0, x4, #0x70                           // of [0xfd504070] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_BASE_LIMIT)

  // Set bits 32-39 of cpu start address and bits 32-39 of cpu end address
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L448-L462

  mov     w8, #0x06                               // constant serves as both cpu base address bits 32-39 and cpu limit address bits 32-39
  ldrwi   w0, x4, #0x80                           // Update [0xfd504080] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_BASE_HI) lower 8 bits
  bfi     w0, w8, #0, #8                          //   to cpu base address bits 32-39 (=0x06)
  strwi   w0, x4, #0x80                           //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L456
  ldrwi   w6, x4, #0x84                           // Update [0xfd504084] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_LIMIT_HI) lower 8 bits
  bfi     w6, w8, #0, #8                          //   to cpu limit address bits 32-39 (=0x06)
  strwi   w6, x4, #0x84                           //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L462

  // Enable ASPM power modes L0s and L1
  // My rpi400 already had them enabled after a reset, so this might be unnecessary
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L1002-L1009
  //
  // Updates registers:
  //   * PCIE_RC_CFG_PRIV1_LINK_CAPABILITY

  ldrwi   w0, x10, #0x4dc
  orr     w0, w0, #0xc00                          // Set bits 10 (ASPM power mode L0s), 11 (ASPM power mode L1)
  strwi   w0, x10, #0x4dc                         // of [0xfd5004dc] (PCIE_RC_CFG_PRIV1_LINK_CAPABILITY)

  // For config space accesses on the RC, show the right class for a PCIe-PCIe bridge
  // Linux source code says the default setting is EP mode, but my rpi400 already
  // has the correct class code after a bridge reset, so this might be unnecessary
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L1011-L1018
  //
  // Updates registers:
  //   * PCIE_RC_CFG_PRIV1_ID_VAL3

  ldrwi   w0, x10, #0x43c
  and     w1, w0, 0xff000000                      // clear bits 0-23 (PCIE_RC_CFG_PRIV1_ID_VAL3_CLASS_CODE)
  mov     w2, 0x181                               // class code for pci-to-pci bridge is 0x060400 but the immediate
                                                  // value 0x060400 is out of range for a mov instruction, however
                                                  // the shifted value (0x060400 >> 10) = 0x181 is in range, and
                                                  // can be used in conjunction with a bfi instruction
  bfi     w1, w2, #10, #9                         // w1 = (class code & 0xff000000) | 0x00060400
  strwi   w1, x10, #0x43c                         // update register [0xfd50043c] (PCIE_RC_CFG_PRIV1_ID_VAL3)
  stp     w0, w1, [x7, #0x8]                      // store initial and updated class code on heap

  // Enable SSC (spread spectrum clocking) steps
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L372-L409
  //
  // Perhaps the MDIO register updates are only needed for ethernet, since MDIO seems to relate only to ethernet:
  //   https://en.wikipedia.org/wiki/Management_Data_Input/Output
  //
  // Updates registers:
  //   * MDIO register SET_ADDR
  //   * MDIO register SSC_CNTL

  mov     w6, wzr                                 // 0 SSC initialisation steps completed
  mov     w0, 0x1f                                // MDIO register offset for SET_ADDR
  mov     w1, 0x1100                              // SSC_REGS_ADDR
  bl      mdio_write                              // [SET_ADDR]=SSC_REGS_ADDR
  tbnz    w1, #31, 3f                             // abort SSC setup due to failed MDIO write operation
  mov     w6, #0x01                               // 1 SSC initialisation steps completed
  mov     w0, #0x02                               // MDIO register offset for SSC_CNTL
  bl      mdio_read                               // w1=[SSC_CNTL]
  tbz     w1, #31, 3f                             // abort SSC setup due to failed MDIO read operation
  mov     w6, #0x02                               // 2 SSC initialisation steps completed
  mov     w0, #0x02                               // set w0 again for SSC_CNTL (w0 was corrupted by mdio_read)
  orr     w1, w1, 0xc000                          // set bits 14 (OVRD_VAL) and 15 (OVRD_EN)
  bl      mdio_write                              // [SSC_CNTL] |= (OVRD_VAL | OVRD_EN)
  tbnz    w1, #31, 3f                             // abort SSC setup due to failed MDIO write operation
  mov     x0, #1000
  bl      wait_usec                               // wait 1ms
  mov     w6, #0x03                               // 3 SSC initialisation steps completed
  mov     w0, 0x01                                // MDIO register offset SSC_STATUS
  bl      mdio_read                               // w1=[SSC_STATUS]
  tbz     w1, #31, 3f                             // abort SSC setup due to failed MDIO read operation
  mov     w6, #0x04                               // 4 SSC initialisation steps completed
  strwi   w1, x7, #0x28                           // store [SSC_STATUS] on heap
  tbz     w1, #10, 3f                             // abort SSC setup since bit 10 (SSC_STATUS_SSC) is clear
  mov     w6, #0x05                               // 5 SSC initialisation steps completed
  tbz     w1, #11, 3f                             // abort SSC setup since bit 11 (SSC_STATUS_PLL_LOCK) is clear
  mov     w6, #0x06                               // 6 SSC initialisation steps completed
3:
  strhi   w6, x7, #0x10                           // store w6 on heap to record which configuration stage SSC reached

  ldrhi   w0, x10, #0xbe                          // Query link capabilities
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L1028-L1033

  strhi   w0, x7, #0x12                           // store w0 on heap to record link capabilities register

  // Set PCIe->SCB little endian mode for BAR 2 (not sure why this requires two bits)
  // My rpi400 already had correct endian mode after a reset, so this might be unnecessary
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L1035-L1039
  //
  // Updates registers:
  //   * PCIE_RC_CFG_VENDOR_VENDOR_SPECIFIC_REG1

  ldrwi   w0, x10, #0x188
  and     w0, w0, #~0xc                           // Clear bits 2, 3 (ENDIAN_MODE_BAR2) => little endian
  strwi   w0, x10, #0x188                         // of [0xfd500188] (PCIE_RC_CFG_VENDOR_VENDOR_SPECIFIC_REG1)

  // Refclk from RC should be gated with CLKREQ# input when
  // ASPM L0s,L1 is enabled => setting the CLKREQ_DEBUG_ENABLE
  // field to 1 and CLKREQ_L1SS_ENABLE field to 0
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L1041-L1060
  //
  // Updates registers:
  //   * PCIE_MISC_HARD_PCIE_HARD_DEBUG

  ldrwi   w0, x4, #0x204
  and     w0, w0, #~0x200000                      // clear bit 21 (CLKREQ_L1SS_ENABLE_MASK)
  orr     w0, w0, #0x2                            //   and set bit 1 (CLKREQ_DEBUG_ENABLE)
  strwi   w0, x4, #0x204                          // of [0xfd504204] (PCIE_MISC_HARD_PCIE_HARD_DEBUG)

  // Preserve revision number, device id, vendor id and header type on the heap

  ldrwi   w0, x4, #0x6c                           // w0 = [0xfd50406c] (PCIE_MISC_REVISION)
  strwi   w0, x7, #0x14                           // store revision number on heap
  ldrwi   w2, x10, #0x0                           // x2 bits 0-15: did, bits 16-31: vid
  ldrbi   w3, x10, #0xe                           // w3 = header type
  stp     w2, w3, [x7, #0x18]                     // store did/vid and header type on heap

  // MSI initisalisation
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L623-L641
  //
  // Updates registers:
  //   * MSI_INT_MASK_CLR
  //   * MSI_INT_CLR
  //   * PCIE_MISC_MSI_BAR_CONFIG_LO
  //   * PCIE_MISC_MSI_BAR_CONFIG_HI
  //   * PCIE_MISC_MSI_DATA_CONFIG

  mov     w0, #0xffffffff
  strwi   w0, x4, #0x514                          // set bits 0-31 of [0xfd504514] (MSI_INT_MASK_CLR)
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L627
  strwi   w0, x4, #0x508                          // set bits 0-31 of [0xfd504508] (MSI_INT_CLR)
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L628

  // Place the MSI target address inside the 32 bit addressable memory area
  // (0xfffffffc). Some devices might depend on it. This is possible since the
  // inbound window is located above the lower 4GB. Bit 0 of
  // PCIE_MISC_MSI_BAR_CONFIG_LO is repurposed to MSI enable, which we set,
  // thus target value is 0xfffffffc | 0x1 = 0xfffffffd.

  mov     w0, #0xfffffffd
  strwi   w0, x4, #0x44                           // [0xfd504044] (PCIE_MISC_MSI_BAR_CONFIG_LO) = 0xfffffffd
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L634-L635
  strwi   wzr, x4, #0x48                          // [0xfd504048] (PCIE_MISC_MSI_BAR_CONFIG_HI) = 0x0
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L636-L637
  movl    w0, 0xffe06540                          // PCIE_MISC_MSI_DATA_CONFIG_VAL_32
  strwi   w0, x4, #0x4c                           // [0xfd50404c] (PCIE_MISC_MSI_DATA_CONFIG) = 0xffe06540 ("PCIE_MISC_MSI_DATA_CONFIG_VAL_32")
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L639-L640
4:
  // Reset VL805 firmware (the USB Host Controller chip)
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/reset/reset-raspberrypi.c#L26-L66
  adr     x0, vl805_reset_req                     // x0 = memory block pointer for mailbox call to reset VL805 firmware
  bl      mbox_call

  // Corrupted by mbox_call above, so need to set again
  adrp    x10, 0xfd500000 + _start                // x10 = PCI to PCI bridge config space base address

  mov     x0, #200                                // sleep 200-1000us
  bl      wait_usec                               //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/reset/reset-raspberrypi.c#L58

  // Set LTR Enable bit in PCI Express Device Control 2 register (PCI_EXP_DEVCTL2) of the root complex, i.e. turn LTR on.
  // PCI Express capability starts at offset 0xac, and PCI_EXP_DEVCTL2 register has offset 0x28 from start of capability,
  // i.e. offset is 0xac + 0x28 = 0xd4
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/probe.c#L2166-L2177
  mov     w1, #0x0400
  strhi   w1, x10, #0xd4                          // [0xfd5000d4] = 0x0400 (was 0x0000)

  // Set SERR forwarding bit (bit 1) in PCI bridge control of root complex.
  // In contrast, Cirlce sets bit 0 instead which enables parity detection on secondary interface.
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/probe.c#L2207-L2223
  mov     w1, #0x0002
  strhi   w1, x10, #0x3e                          // [0xfd50003e] = 0x0002 (was 0x0000)

  // Disable Power Management (clear bit 8) and clear Power Management Status (by setting bit 15) of PCI_PM_CTRL register of root complex.
  // Power Management capability starts at offset 0x48, and PCI_PM_CTRL has offset 0x04 from start of capability,
  // i.e. offset is 0x48 + 0x04 = 0x4c
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/pci.c#L2354-L2368
  ldrhi   w1, x10, #0x4c                          // w1 = [0xfd50004c] (=0x2008) = current value of PCI_PM_CTRL for root complex
  and     w1, w1, #~0x0100                        // clear bit 8 (PCI_PM_CTRL_PME_ENABLE)
  orr     w1, w1, #0x8000                         //   and set bit 15 (PCI_PM_CTRL_PME_STATUS)
  strhi   w1, x10, #0x4c                          // of [0xfd50004c] (PCI_PM_CTRL)

  // Enable CRS Software Visibility (set bit 4) of PCI_EXP_RTCTL (Root Control)
  // CRS = Configuration Request Retry Status, directing devices to
  // return a vendor id of 0x0001 if they are not ready after a reset
  //   https://blog.linuxplumbersconf.org/2017/ocw/system/presentations/4732/original/crs.pdf
  // PCI Express capability starts at offset 0xac, and PCI_EXP_RTCTL register has offset 0x1c from start of capability,
  // i.e. offset is 0xac + 0x1c = 0xc8
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/probe.c#L1150-L1159
  mov     w1, #0x0010
  strhi   w1, x10, #0xc8                          // [0xfd5000c8] = 0x0010 (was 0x0000)

  // Clear errors on root complex
  // Write 0xffff to clear all status bits (e.g., parity errors, aborts)
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/probe.c#L1332-L1333
  mov     w1, #0xffff
  strhi   w1, x10, #0x6                           // PCI_STATUS = 0xffff (was 0x0010)

  // Configure bus numbers in root complex and latency timer
  // 0x18: PCI Primary Bus = 0x00
  // 0x19: Secondary Bus = 0x01
  // 0x1a: Subordinate Bus (Highest bus number behind bridge) = 0x01
  // 0x1b: Latency timer for secondary interface = 0x00
  ldr     w1, =0x00010100
  strwi   w1, x10, #0x18                          // was 0x00000000

  // PCIe RC ECAM Index Register (offset 0x9000 from base, x14 + 0x0)
  // Mounts VL805 (bus 1, device 0, function 0, offset 0) configuration space at physical address [0xfd58000] (x13)
  // 0b0000 bbbb bbbb dddd dfff oooo oooo oooo (b = bus, d = device, f = function, o = offset)
  // 0b0000 0000 0001 0000 0000 0000 0000 0000
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L707-L722
  mov     w1, #0x00100000
  strwi   w1, x14, #0x0                           // was 0x00000000

  // VL805: Set PCI command
  // 0b0000 0101 0100 0110
  // set bit 1  => Enable response in Memory space
  // set bit 2  => Enable bus mastering
  // set bit 6  => Enable parity checking
  // set bit 8  => Enable SERR
  // set bit 10 => INTx Emulation Disable
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/include/uapi/linux/pci_regs.h#L40-L51
  mov     w1, #0x546
  strhi   w1, x13, #0x4                           // was 0x0000

  // VL805: Disable Power Management (clear bit 8) and clear Power Management Status (by setting bit 15) of PCI_PM_CTRL register.
  // Power Management capability starts at offset 0x80, and PCI_PM_CTRL has offset 0x04 from start of capability,
  // i.e. offset is 0x80 + 0x04 = 0x84
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/pci.c#L2354-L2368
  ldrhi   w1, x13, #0x84                          // w1 = [0xfd50004c] (=0x2008) = current value of PCI_PM_CTRL for root complex
  and     w1, w1, #~0x0100                        // clear bit 8 (PCI_PM_CTRL_PME_ENABLE)
  orr     w1, w1, #0x8000                         //   and set bit 15 (PCI_PM_CTRL_PME_STATUS)
  strhi   w1, x13, #0x84                          // of [0xfd50004c] (PCI_PM_CTRL)

  // Retrain link and set common clock configuration and enable L0s/L1
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/pcie/aspm.c#L201-L203
  mov     w1, #0x63                               // PCI_EXP_LNKCTL_ASPM_L0S 0x0001: L0s Enable
                                                  // PCI_EXP_LNKCTL_ASPM_L1  0x0002: L1 Enable
                                                  // PCI_EXP_LNKCTL_RL       0x0020: Retrain Link
                                                  // PCI_EXP_LNKCTL_CCC      0x0040: Common Clock Configuration
  strhi   w1, x10, #0xbc                          // was 0x0000

  // Wait for link training to complete
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/pcie/aspm.c#L214-L221
  mov     w8, #1000                               // 1000 attempts
  5:
    cbz     w8, 6f                                // exit loop with failure if 1000 iterations have completed
    sub     w8, w8, #1
    mov     x0, #1000
    bl      wait_usec                             // sleep 1ms
    ldrhi   w0, x10, #0xbc                        // check current value
    tbnz    w0, #5, 5b                            // repeat loop if bit 5 is set (PCI_EXP_LNKSTA_LT) - implies link training still in progress


  mov     w1, #0x40                               // PCI_EXP_LNKCTL_CCC 0x0040: Common Clock Configuration
  strhi   w1, x13, #0xd4                          // was 0x0043

  ldr     w1, =0xc0000004                         // lower 32 bits of MEM_PCIE_RANGE_PCIE_START (pcie side address) | 0b100 (64 bit memory type) (was 0x00000004)
  strwi   w1, x13, #0x10
  strwi   wzr, x13, #0x14                         // upper 32 address bits = 0 (not technically needed, already 0, but nice to keep)

  // Set PCI I/O Base
  mov     w1, #0xf0
  strhi   w1, x10, #0x1c                          // was 0x0000

  // Set PCI Memory Base
  mov     w1, #0xc000c000
  strwi   w1, x10, #0x20                          // was 0xf800f800 - perhaps from previous circle run that uses this alternative value?

  // Set PCI Pref Memory Base
  mov     w1, #0x0000fff0
  strwi   w1, x10, #0x24                          // was 0x0001fff1

  // Interrupt line 0x3c ?
  mov     w1, #0x3e
  strbi   w1, x13, #0x3c                          // was 0x00

  // Set PCI Command
  mov     w1, #0x0006
  strhi   w1, x10, #0x4                           // was 0x0000

  // PCI cache line size
  mov     w1, #0x10
  strbi   w1, x13, #0xc                           // PCI cache line size = 0x10 (64/4) (was 0x00)

  mov     w1, #0xfffffffc
  strwi   w1, x13, #0x94                          // was 0x00000000

  mov     w1, #0x6540
  strhi   w1, x13, #0x9c                          // was 0x0000

  // PCI command config: response in memory space | bus mastering | parity checking | SERR | INTx emulation disable (was 0x0000)
  mov     w1, #0x546
  strhi   w1, x13, #0x4                           // Cicle does not disable INTx emulation

  mov     w1, #0x85
  strhi   w1, x13, #0x92                          // was 0x0084


  //           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
  //  fd500000 e4 14 11 27 06 00 10 00 20 00 04 06 00 00 01 00 00 00 00 00 00 00 00 00 00 01 01 00 00 00 00 20
  //  fd500020 00 c0 00 c0 f1 ff 01 00 00 00 00 00 00 00 00 00 00 00 00 00 48 00 00 00 00 00 00 00 00 01 02 00
  //
  //  fd500000: 0x14e4     Vendor ID (Broadcom Inc. and subsidiaries)
  //  fd500002: 0x2711     Device ID (BCM2711 PCIe Bridge)
  //  fd500004: 0x0006     Command
  //  fd500006: 0x0010     Status
  //  fd500008: 0x20       Revision ID
  //  fd500009: 0x060400   Class Code
  //  fd50000c: 0x00       Cache Line Size
  //  fd50000d: 0x00       Latency Timer
  //  fd50000e: 0x01       Header Type
  //  fd50000f: 0x00       BIST
  //  fd500010: 0x00000000 Base Address 0
  //  fd500014: 0x00000000 Base Address 1
  //  fd500018: 0x00       Primary Bus Number (set by us)
  //  fd500019: 0x01       Secondary Bus Number (set by us)
  //  fd50001a: 0x01       Subordinate Bus Number (set by us)
  //  fd50001b: 0x00       Secondary Latency Timer (set by us)
  //  fd50001c: 0x00       I/O Base
  //  fd50001d: 0x00       I/O Limit
  //  fd50001e: 0x2000     Secondary Status
  //  fd500020: 0xc000     Memory Base
  //  fd500022: 0xc000     Memory Limit
  //  fd500024: 0xfff1     Prefetchable Memory Base
  //  fd500026: 0x0001     Prefetchable Memory Limit
  //  fd500028: 0x00000000 Prefetchable Base upper 32 bits
  //  fd50002c: 0x00000000 Prefetchable Limit upper 32 bits
  //  fd500030: 0x0000     I/O Base upper 16 bits
  //  fd500032: 0x0000     I/O Limit upper 16 bits
  //  fd500034: 0x48       Capabilities Pointer
  //  fd500035: 0x000000   Reserved
  //  fd500038: 0x00000000 Expansion ROM Base Address
  //  fd50003c: 0x00       Interrupt Line
  //  fd50003d: 0x01       Interrupt Pin
  //  fd50003e: 0x0002     Bridge Control (set by us)
  //
  //           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
  //  fd500040 00 00 00 00 00 00 00 00 01 ac 13 48 08 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500060 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500080 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5000a0 00 00 00 00 00 00 00 00 00 00 00 00 10 00 42 00 02 80 00 00 10 2c 00 00 12 cc 64 00 40 00 12 d0
  //  fd5000c0 00 00 00 00 00 00 40 00 10 00 01 00 00 00 00 00 1f 08 08 00 00 04 00 00 06 00 00 80 02 00 00 00
  //  fd5000e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //
  //  Unknown purpose
  //
  //  fd500040: 0x00000000 ????
  //  fd500044: 0x00000000 ????
  //
  //  Capabilities
  //
  //  fd500048: 0x01 Power Management (13 48 08 20 00...)
  //                                         ^^^^^
  //  fd5000ac: 0x10 PCI Express (42 00 02 80 00 00 10 2c 00 00 12 cc 64 00 40 00 12 d0 00 00 00 00 00 00 40 00 10 00 01 00 00 00 00 00 1f 08 08 00 00 04 00 00 06 00 00 80 02 00...)
  //                                                                                                            ^^^^^                               ^^^^^
  //           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
  //  fd500100 01 00 01 18 00 00 00 00 00 00 00 00 30 20 06 00 00 00 00 00 00 20 00 00 00 00 00 00 00 00 00 00
  //  fd500120 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500140 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500160 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500180 0b 00 01 24 00 00 80 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5001a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5001c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5001e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500200 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500220 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500240 1e 00 01 00 1f 08 28 00 00 01 00 00 28 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500260 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500280 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5002a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5002c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5002e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500300 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500320 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500340 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500360 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500380 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5003a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5003c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5003e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500400 00 00 00 00 00 00 00 00 10 00 01 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500420 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 11 27 e4 14 e4 14 11 27 00 04 06 20
  //  fd500440 48 30 00 00 e4 0a 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500460 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500480 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5004a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5004c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 40 00 00 00 02 80 00 00 00 00 00 00 12 5e 31 00
  //  fd5004e0 00 00 00 00 1f 00 08 00 00 00 00 80 00 00 00 00 02 00 00 00 00 00 00 00 0f 00 00 00 00 00 00 00
  //  fd500500 03 00 01 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500520 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500540 1f 08 28 00 1e 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 80 02 0f 00 00 00 00 00 00 00
  //  fd500560 0f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500580 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5005a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5005c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5005e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500600 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500620 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500640 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500660 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd500680 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5006a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00


  // VL805 configuration space

  //           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
  //  fd508000 06 11 83 34 46 05 10 00 01 30 03 0c 10 00 00 00 04 00 00 c0 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd508020 00 00 00 00 00 00 00 00 00 00 00 00 06 11 83 34 00 00 00 00 80 00 00 00 00 00 00 00 3e 01 00 00



  //           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
  //  fd508040 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 06 11 83 34
  //  fd508060 30 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

  // VL805 Capabilities

  //           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
  //  fd508080 01 90 03 48 00 00 00 00 00 00 00 00 00 00 00 00 05 c4 85 00 fc ff ff ff 00 00 00 00 40 65 00 00
  //  fd5080a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5080c0 00 20 00 00 10 00 02 00 01 80 00 00 10 28 19 00 12 5c 06 00 40 00 12 10 00 00 00 00 00 00 00 00
  //  fd5080e0 00 00 00 00 00 00 00 00 12 00 00 00 00 00 00 00 00 00 00 00 22 00 01 00 00 00 00 00 00 00 00 00

  //  fd508080: 0x01 Power Management (03 48 00 00 00 00 00 00 00 00 00 00 00 00)
  //  fd508090: 0x05 Message Signalled Interrupts (85 00 fc ff ff ff 00 00 00 00 40 65 00 00 ....)
  //  fd5080c4: 0x10 PCI Express (02 00 01 80 00 00 10 28 19 00 12 5c 06 00 40 00 12 10 00 00 00 00 00 00 00 00 ...)

  //           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
  //  fd508100 01 00 01 00 00 00 10 00 00 00 00 00 31 20 06 00 00 20 00 00 00 20 00 00 14 00 00 00 00 00 00 00
  //  fd508120 00 00 00 01 03 00 00 00 01 00 00 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd508140 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd508160 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd508180 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5081a0 43 20 50 64 ff 03 c2 00 00 00 00 00 00 00 00 00 00 00 41 81 07 00 a1 0b 00 00 06 09 3a 09 0e 57
  //  fd5081c0 05 e0 a7 8a 04 00 00 00 00 00 00 00 00 cf 18 00 d8 20 07 28 01 00 00 00 00 00 00 00 00 00 00 00
  //  fd5081e0 01 12 22 21 00 80 c3 01 01 00 00 00 00 00 00 00 00 00 20 06 00 00 66 01 00 00 00 00 00 00 00 00
  //  fd508200 00 00 00 00 00 00 00 00 00 03 3c 3e 00 00 00 00 00 00 00 22 22 00 00 00 95 db 22 00 00 00 00 00
  //  fd508220 00 11 11 00 94 00 00 00 00 00 c0 ff 24 45 45 65 13 65 03 24 0d 0d 00 00 00 00 00 00 ff ff ff ff
  //  fd508240 00 00 ff ff 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 3f 1f 00 00 00 00 00 00 00 00 00
  //  fd508260 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd508280 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5082a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5082c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5082e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd508300 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd508320 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd508340 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd508360 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd508380 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5083a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5083c0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  //  fd5083e0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00


  ldrwi   w2, x13, #0x8                           // w2 = bus 1 class (upper 24 bits) revision (lower 8 bits)
                                                  //   class should be 0x0c0330, revision should be 0x01

  ldrbi   w3, x13, #0xe                           // w3 = bus 1 header type
  stp     w2, w3, [x7, #0x20]                     // store bus 1 class, revision and header type on heap

  ldr     x0, =(0x600000000 + _start)             // x0 = pcie start address = VL805 USB Host Controller Capability Registers
  ldrhi   w1, x0, #0x2                            // w1 = [XHCI_REG_CAP_HCIVERSION]
  strhi   w1, x7, #0x2c                           // store [XHCI_REG_CAP_HCIVERSION] on heap (should be 0x0110)

  // init spectrum4 MMIO data structure
  adr     x2, xhci_mmio
  str     x0, [x2], #8                            // [xhci_mmio] = 0x600000000 (pcie base)
  ldrbi   w1, x0, #0x0                            // w1 = capabilities length
  add     x1, x1, x0                              // w1 = address of first byte after capabilities = op base
  str     x1, [x2], #8                            // [xhci_mmio_op] = 0x600000000 + [0x600000000]
  ldrwi   w3, x0, #0x14                           // w3 = [XHCI_REG_CAP_DBOFF]
  and     w3, w3, 0xfffffffc
  add     x3, x3, x0
  str     x3, [x2], #8                            // [xhci_mmio_db] = 0x600000000 + ([0x600000014] && 0xfffffffc)
  ldrwi   w3, x0, #0x18                           // w3 = [XHCI_REG_CAP_RTSOFF]
  and     w3, w3, 0xffffffe0
  add     x3, x3, x0
  str     x3, [x2], #8                            // [xhci_mmio_rt] = 0x600000000 + ([0x600000018] && 0xffffffe0)
  add     x3, x1, #0x400                          // x3 = op base + 0x400
  str     x3, [x2], #8                            // [xhci_mmio_pt] = 0x600000400 + ([0x600000000])
  ldrwi   w3, x0, #0x4                            // w3 = [XHCI_REG_CAP_HCSPARAMS1]
  ldrwi   w4, x0, #0x8                            // w4 = [XHCI_REG_CAP_HCSPARAMS2]
  ldrwi   w6, x0, #0xc                            // w6 = [XHCI_REG_CAP_HCSPARAMS3]
  ldrwi   w7, x0, #0x10                           // w7 = [XHCI_REG_CAP_HCSPARAMS]
  stp     w3, w4, [x2], #8                        // update lower 64 bits of [xhci_cap_cache]
  stp     w6, w7, [x2], #8                        // update update 64 bits of [xhci_cap_cache]
  and     w7, w7, #0xffff0000
  add     x7, x0, x7, lsr #14                     // x7 = 0x600000000 + (([0x600000010] & 0xffff0000) << 14) = extended capabilities address
  str     x7, [x2], #8                            // [xhci_mmio_ec] = extended capabilities address
  ret     x5

.align 3
xhci_mmio: .space 8                               // = 0x600000000 (pcie base = xhci base) (capability registers)
xhci_mmio_op: .space 8                            // operational registers address
xhci_mmio_db: .space 8                            // doorbell registers address
xhci_mmio_rt: .space 8                            // runtime registers address
xhci_mmio_pt: .space 8                            // port register set address
xhci_cap_cache: .space 16                         // capability cache values
xhci_mmio_ec: .space 8                            // extended capabilities address



# ------------------------------
# Read from a MDIO register/port
# ------------------------------
# Read a value from an MDIO register. This is a two stage process. First,
# register [0xfd501100] (PCIE_RC_DL_MDIO_ADDR) is written to with details of
# the desired MDIO register to read from, and then register [0xfd501108]
# (PCIE_RC_DL_MDIO_RD_DATA) is polled to retrieve the value. The polling occurs
# at 10us intervals, with a maximum of 10 attempts.
#
# Linux implementation:
#  https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L331-L349
#
# On entry:
#   w0 = MDIO register/port to read from
#          bits 21-31: clear (required)
#          bit 20: ignored
#          bits 16-19: port (usually 0x0)
#          bits 0-15: regad
#            0x0001: SSC_STATUS
#            0x0002: SSC_CNTL
#            0x001f: SET_ADDR
# On return:
#   w0 corrupted
#   w1 = bits 0-30: MDIO register value
#        bit 31: set if read was successful, clear if read was unsuccessful
#   w2 corrupted
#   w3 corrupted
#   w8 = 0 for failure / 1-9 for success (number of remaining attempts)
#   x11 = return address of function
.align 2
mdio_read:
  mov     x11, x30
  orr     w0, w0, 0x00100000                      // set bit 20 => command = 0x001 (read operation)
  strwi   w0, x10, #0x1100                        // set [0xfd501100] (PCIE_RC_DL_MDIO_ADDR) = w0 (command | port | regad)
  ldrwi   w0, x10, #0x1100                        // read it back, presumably required since linux kernel does this:
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L339

  // Read [0xfd501108] (PCIE_RC_DL_MDIO_RD_DATA) into w1 every 10us until bit 31 is set or 10 attempts exhausted

  mov     w8, #10                                 // 10 attempts
  1:
    cbz     w8, 2f                                // exit loop if 10 iterations have completed
    sub     w8, w8, #1                            // decrement loop counter
    mov     x0, #10
    bl      wait_usec                             // sleep 10us
    ldrwi   w1, x10, #0x1108                      // w0=[0xfd501108] (PCIE_RC_DL_MDIO_RD_DATA)
    tbz     w1, #31, 1b                           // repeat loop if bit 31 is clear (=> read value before register update was complete)
2:
  ret     x11


# -----------------------------
# Write to a MDIO register/port
# -----------------------------
# Write a value to an MDIO register. This is a three stage process. First,
# register [0xfd501100] (PCIE_RC_DL_MDIO_ADDR) is written to with details of
# the desired MDIO register to update, and then register [0xfd501104]
# (PCIE_RC_DL_MDIO_WR_DATA) is written to with the target value. Finally, the
# same register [0xfd501104] (PCIE_RC_DL_MDIO_WR_DATA) is polled to determine
# if the update was successful. The polling occurs at 10us intervals, with a
# maximum of 10 attempts.
#
# Linux implementation:
#  https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L351-L370
#
# On entry:
#   w0 = MDIO register/port to write to
#          bits 20-31: clear (required)
#          bits 16-19: port (usually 0x0)
#          bits 0-15: regad
#            0x0002: SSC_CNTL
#            0x001f: SET_ADDR
#   w1 = bits 0-30: desired value to write to MDIO register
#        bit 31: ignored
# On return:
#   w0 corrupted
#   w1 = bits 0-30: unchanged, if successful
#        bit 31: clear if read was successful, set if read was unsuccessful
#   w2 corrupted
#   w3 corrupted
#   w8 = 0 for failure / 1-9 for success (number of remaining attempts)
#   x11 = return address of function
.align 2
mdio_write:
  mov     x11, x30
  strwi   w0, x10, #0x1100                        // set [0xfd501100] (PCIE_RC_DL_MDIO_ADDR) = w0 (command | port | regad)
                                                  // w0 command (bits 20-31) clear (0x000) on entry => write operation
  ldrwi   w0, x10, #0x1100                        // read it back, presumably required since linux kernel does this:
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L360
  orr     w1, w1, 0x80000000                      // value to set, with bit 31 set
  strwi   w1, x10, #0x1104                        // set [0xfd501104] (PCIE_RC_DL_MDIO_WR_DATA) = w1 (value to set, with bit 31 set)

  // Read [0xfd501104] (PCIE_RC_DL_MDIO_WR_DATA) into w1 every 10us until bit 31 is clear or 10 attempts exhausted

  mov     w8, #10                                 // 10 attempts
  1:
    cbz     w8, 2f                                // exit loop if 10 iterations have completed
    sub     w8, w8, #1                            // decrement loop counter
    mov     x0, #10
    bl      wait_usec                             // sleep 10us
    ldrwi   w1, x10, #0x1104                      // w0=[0xfd501104] (PCIE_RC_DL_MDIO_WR_DATA)
    tbnz    w1, #31, 1b                           // repeat loop if bit 31 is set (=> read value before register update was complete)
2:
  ret     x11


# # Return the PCIe register address for a given PCI bus, device function and
# # config space address offset.
# #
# # The bus is considered a root bus if the bus parent address is 0 (i.e. unset).
# # The root bus is accessed directly via the the root config registers. For
# # other devices, first write the request to the config space index register
# # (ECAM), and return the address of the result register.
# #
# # On entry:
# #   x0 = pci_bus address
# #   x1 = devfn
# #   w2 = where (pci reg offset)
# #
# # On exit:
# #   x0 = pcie register address
# #   x1 untouched
# #   w2 untouched
# #   x3 disturbed
# #   x4 disturbed
# #
# # Based on:
# #   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L707-L722
# .align 2
# map_conf:
#   ldrxi   x3, x0, #0x0                            // x3 = [bus address] = parent
#   cbnz    x3, 1f                                  // if parent bus non-zero (i.e. has been set), jump ahead to 1:
#   adrp    x4, 0xfd500000 + _start                 // x4 = pcie_base
#   add     x4, x4, x2                              // x4 = x4 + x2 = pcie_base + where
#   tst     x1, #0xf8                               // set flags based on AND upper 5 bits of devfn (device number)
#   csel    x0, x4, xzr, eq                         // if dev number == 0, x0 = pcie_base + where, otherwise 0
#   ret
# 1:
#   ldrbi   w3, x0, #8                              // w3 = [x3 + 8] = bus number
#   ubfiz   w4, w1, #12, #8                         // w4 = (w1 & 0xff) << 12 = (devfn & 0xff) << 12
#   orr     w4, w4, w3, lsl #20                     // w4 = (devfn & 0xff) << 12 | (bus number << 20)
#   dmb     oshst                                   // Data Memory Barrier Operation, Outer Shareable, Shareability Type
#   adrp    x0, 0xfd509000 + _start                 // x0 = pcie_base + 0x9000
#   strwi   w4, x0, #0                              // [pcie_base + 0x9000] = (devfn & 0xff) << 12 | (bus number << 20)
#   adrp    x0, 0xfd508000 + _start                 // x0 = pcie_base + 0x8000
#   add     x0, x0, x2                              // x0 = pcie_base + 0x8000 + where
#   ret


# Memory block for requesting VL805 host controller firmware reset
.align 4
vl805_reset_req:
  .word (vl805_reset_req_end-vl805_reset_req)     // Buffer size
  .word 0                                         // Request/response code
  .word 0x00030058                                // Tag 0 - Reset xHCI
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/include/soc/bcm2835/raspberrypi-firmware.h#L97
  .word 4                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word 0x00100000                                //   request: reset configuration  response: unknown
                                                  //     0x00100000 => pcie bus = 1 (bits 20-?), slot = 0 (bits 15-19), func = 0 (bits 12-14)
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/reset/reset-raspberrypi.c#L26-L66
  .word 0                                         // End Tags
vl805_reset_req_end:
