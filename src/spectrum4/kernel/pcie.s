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
#   [heap+0x00]: last read status register
#   [heap+0x04]: number of iterations of 1ms reading status register
#   [heap+0x08]: initial class code
#   [heap+0x0c]: updated class code
#   [heap+0x10]: SSC status
#                  0x0000: enabled
#                  0xffff: disabled
#   [heap+0x12]: link capabilities
#   [heap+0x14]: revision number
#   [heap+0x18]: vid
#   [heap+0x1a]: did
#   [heap+0x1c]: header type
.align 2
pcie_init_bcm2711:

  mov     x5, x30
  movl    w10, 0xfd500000                         // x10 = pcie_base
  movl    w4, 0xfd509210                          // x4 = pcie reset controller register
  movl    w7, 0xfd504068                          // x7 = pcie status register
  adrp    x9, heap
  add     x9, x9, :lo12:heap                      // x9 = heap

  // Reset the PCI bridge
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L881-L885
  //
  // Updates registers:
  //   * RGR1_SW_INIT_1

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
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L887-L892
  //
  // Updates registers:
  //   * RGR1_SW_INIT_1
  //   * PCIE_MISC_HARD_PCIE_HARD_DEBUG

  and     w6, w6, #~0x2                           // clear bit 1 (RGR1_SW_INIT_1_INIT_GENERIC)
  str     w6, [x4]                                //   of [0xfd509210] (RGR1_SW_INIT_1)
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L888
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L730-L738
  ldr     w6, [x7, 0xfd504204-0xfd504068]
  and     w6, w6, #~0x08000000                    // clear bit 27 (HARD_DEBUG_SERDES_IDDQ)
  str     w6, [x7, 0xfd504204-0xfd504068]         //   of [0xfd504204] (PCIE_MISC_HARD_PCIE_HARD_DEBUG)
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

  ldur    w6, [x7, 0xfd504008-0xfd504068]
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
  stur    w6, [x7, 0xfd504008-0xfd504068]         //   of [0xfd504008] (PCIE_MISC_MISC_CTRL)

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
  stur    w6, [x7, 0xfd504034-0xfd504068]         // [0xfd504034] (PCIE_MISC_RC_BAR2_CONFIG_LO) = 0x11
                                                  // => RC BAR2 size = 4GB since bits 0-4 are set to return value of:
                                                  // https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L302-L318
  mov     w6, #0x4
  stur    w6, [x7, 0xfd504038-0xfd504068]         // [0xfd504038] (PCIE_MISC_RC_BAR2_CONFIG_HI) = 0x4
                                                  // => RC BAR2 offset = 16GB

  // Disable the PCIe->GISB (Global Incoherent System Bus) memory window
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L952-L955
  //
  // Updates registers:
  //   * PCIE_MISC_RC_BAR1_CONFIG_LO

  ldur    w6, [x7, 0xfd50402c-0xfd504068]
  and     w6, w6, #~0x1f                          // clear bits 0-4 (RC_BAR1_CONFIG_LO_SIZE)
  stur    w6, [x7, 0xfd50402c-0xfd504068]         // of [0xfd50402c] (PCIE_MISC_RC_BAR1_CONFIG_LO)

  // Disable the PCIe->SCB memory window
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L957-L960
  //
  // Updates registers:
  //   * PCIE_MISC_RC_BAR3_CONFIG_LO

  ldur    w6, [x7, 0xfd50403c-0xfd504068]
  and     w6, w6, #~0x1f                          // clear bits 0-4 (RC_BAR3_CONFIG_LO_SIZE)
  stur    w6, [x7, 0xfd50403c-0xfd504068]         // of [0xfd50403c] (PCIE_MISC_RC_BAR3_CONFIG_LO)

  // Unassert the fundamental reset
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L965-L966
  //
  // Updates registers:
  //   * RGR1_SW_INIT_1

  ldr     w6, [x4]                                // note, if we can assume the value hasn't changed, we could cache current value in a register and avoid this extra ldr instruction
  and     w6, w6, #~0x1                           // clear bit 0 (PCIE_RGR1_SW_INIT_1_PERST)
  str     w6, [x4]                                // of [0xfd509210] (RGR1_SW_INIT_1)

  // Give the RC/EP time to wake up, before trying to configure RC.
  // Poll status until ready, every 1ms, up to maximum of 100 times
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L968-L973

  mov     w8, #100                                // 100 attempts
  1:
    cbz     w8, 2f                                // exit loop if 100 iterations have completed
    sub     w8, w8, #1                            // note, linux kernel checks only every 5ms, but we check every 1ms
    mov     x0, #1000
    bl      wait_usec                             // sleep 1ms
    ldr     w0, [x7]
    tbz     w0, #4, 1b                            // repeat loop if bit 4 is clear (PCIE_MISC_PCIE_STATUS_PCIE_PHYLINKUP)
    tbz     w0, #5, 1b                            // repeat loop if bit 5 is clear (PCIE_MISC_PCIE_STATUS_PCIE_DL_ACTIVE)
2:
  stp     w0, w8, [x9]                            // store last read status register value and number of 1ms on heap
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

  // Set the pcie start address
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L433-L435

  mov     w0, 0xc0000000                          // PCI address of outbound window
  stur    w0, [x7, 0xfd50400c-0xfd504068]         // [0xfd50400c] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_LO) =0xc0000000 (low 32 bits of pcie start)
  stur    wzr, [x7, 0xfd504010-0xfd504068]        // [0xfd504010] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_HI) =0x00000000 (high 32 bits of pcie start)

  // Set bits 20-31 of cpu start address and bits 20-31 of cpu end address
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L437-L446

  ldr     w0, [x7, 0xfd504070-0xfd504068]
  and     w0, w0, #0x000f000f                     // Clear bits 4-15 (BASE) and bits 20-31 (LIMIT)
  orr     w0, w0, #0x3ff00000                     //   then set bits 20-31 (LIMIT) to 0x3ff
  str     w0, [x7, 0xfd504070-0xfd504068]         // of [0xfd504070] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_BASE_LIMIT)

  // Set bits 32-39 of cpu start address and bits 32-39 of cpu end address
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L448-L462

  mov     w8, #0x06                               // constant serves as both cpu base address bits 32-39 and cpu limit address bits 32-39
  ldr     w0, [x7, 0xfd504080-0xfd504068]         // Update [0xfd504080] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_BASE_HI) lower 8 bits
  bfi     w0, w8, #0, #8                          //   to cpu base address bits 32-39 (=0x06)
  str     w0, [x7, 0xfd504080-0xfd504068]         //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L456
  ldr     w6, [x7, 0xfd504084-0xfd504068]         // Update [0xfd504084] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_LIMIT_HI) lower 8 bits
  bfi     w6, w8, #0, #8                          //   to cpu limit address bits 32-39 (=0x06)
  str     w6, [x7, 0xfd504084-0xfd504068]         //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L462

  // Enable ASPM power modes L0s and L1
  // My rpi400 already had them enabled after a reset, so this might be unnecessary
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L1002-L1009
  //
  // Updates registers:
  //   * PCIE_MISC_CPU_2_PCIE_MEM_WIN0_BASE_LIMIT

  ldr     w0, [x10, 0xfd5004dc-0xfd500000]
  orr     w0, w0, #0xc00                          // Set bits 10 (ASPM power mode L0s), 11 (ASPM power mode L1)
  str     w0, [x10, 0xfd5004dc-0xfd500000]        // of [0xfd5004dc] (PCIE_MISC_CPU_2_PCIE_MEM_WIN0_BASE_LIMIT)

  // For config space accesses on the RC, show the right class for a PCIe-PCIe bridge
  // Linux source code says the default setting is EP mode, but my rpi400 already
  // has the correct class code after a bridge reset, so this might be unnecessary
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L1011-L1018
  //
  // Updates registers:
  //   * PCIE_RC_CFG_PRIV1_ID_VAL3

  ldr     w0, [x10, 0xfd50043c-0xfd500000]
  and     w1, w0, 0xff000000                      // clear bits 0-23 (PCIE_RC_CFG_PRIV1_ID_VAL3_CLASS_CODE)
  mov     w2, 0x181                               // class code for pci-to-pci bridge is 0x060400 but the immediate
                                                  // value 0x060400 is out of range for a mov instruction, however
                                                  // the shifted value (0x060400 >> 10) = 0x181 is in range, and
                                                  // can be used in conjunction with a bfi instruction
  bfi     w1, w2, #10, #9                         // w1 = (class code & 0xff000000) | 0x00060400
  str     w1, [x10, 0xfd50043c-0xfd500000]        // update register [0xfd50043c] (PCIE_RC_CFG_PRIV1_ID_VAL3)
  stp     w0, w1, [x9, #0x08]                     // store initial and updated class code on heap

  // Enable SSC (spread spectrum clocking) steps
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L372-L409
  //
  // Perhaps the MDIO register updates are only needed for ethernet, since MDIO seems to relate only to ethernet:
  //   https://en.wikipedia.org/wiki/Management_Data_Input/Output
  //
  // Updates registers:
  //   * MDIO register SET_ADDR
  //   * MDIO register SSC_CNTL

  mov     w6, 0xffff                              // flag to indicate SSC was unsuccessful
  mov     w0, 0x1f                                // MDIO register offset for SET_ADDR
  mov     w1, 0x1100                              // SSC_REGS_ADDR
  bl      mdio_write                              // [SET_ADDR]=SSC_REGS_ADDR
  tbnz    w1, #31, 3f                             // abort SSC setup due to failed MDIO write operation
  mov     w0, 0x02                                // MDIO register offset for SSC_CNTL
  bl      mdio_read                               // w1=[SSC_CNTL]
  tbz     w1, #31, 3f                             // abort SSC setup due to failed MDIO read operation
  orr     w1, w1, 0xc000                          // set bits 14 (OVRD_VAL) and 15 (OVRD_EN)
  bl      mdio_write                              // [SSC_CNTL] |= (OVRD_VAL | OVRD_EN)
  tbnz    w1, #31, 3f                             // abort SSC setup due to failed MDIO write operation
  mov     w0, 0x01                                // MDIO register offset SSC_STATUS
  bl      mdio_read                               // w1=[SSC_STATUS]
  tbz     w1, #31, 3f                             // abort SSC setup due to failed MDIO read operation
  tbz     w1, #10, 3f                             // abort SSC setup since bit 10 (SSC_STATUS_SSC) is clear
  tbz     w1, #11, 3f                             // abort SSC setup since bit 11 (SSC_STATUS_PLL_LOCK) is clear
  mov     w6, wzr                                 // flag that SSC was successful
3:
  strh    w6, [x9, #0x10]                         // store w6 on heap to record whether SSC was successful

  ldrh    w0, [x10, 0xfd5000be-0xfd500000]        // Query link capabilities
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L1028-L1033

  strh    w0, [x9, #0x12]                         // store w0 on heap to record link capabilities register

  // Set PCIe->SCB little endian mode for BAR 2 (not sure why this requires two bits)
  // My rpi400 already had correct endian mode after a reset, so this might be unnecessary
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L1035-L1039
  //
  // Updates registers:
  //   * PCIE_RC_CFG_VENDOR_VENDOR_SPECIFIC_REG1

  ldr     w0, [x10, 0xfd500188-0xfd500000]
  and     w0, w0, #~0xc                           // Clear bits 2, 3 (ENDIAN_MODE_BAR2) => little endian
  str     w0, [x10, 0xfd500188-0xfd500000]        // of [0xfd500188] (PCIE_RC_CFG_VENDOR_VENDOR_SPECIFIC_REG1)

  // Refclk from RC should be gated with CLKREQ# input when
  // ASPM L0s,L1 is enabled => setting the CLKREQ_DEBUG_ENABLE
  // field to 1 and CLKREQ_L1SS_ENABLE field to 0
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L1041-L1060
  //
  // Updates registers:
  //   * PCIE_MISC_HARD_PCIE_HARD_DEBUG

  ldr     w0, [x7, 0xfd504204-0xfd504068]
  and     w0, w0, #~0x200000                      // clear bit 21 (CLKREQ_L1SS_ENABLE_MASK)
  orr     w0, w0, #0x2                            //   and set bit 1 (CLKREQ_DEBUG_ENABLE)
  str     w0, [x7, 0xfd504204-0xfd504068]         // of [0xfd504204] (PCIE_MISC_HARD_PCIE_HARD_DEBUG)

  // Preserve revision number, device id, vendor id and header type on the heap

  ldr     w0, [x7, 0xfd50406c-0xfd504068]         // w0 = [0xfd50406c] (PCIE_MISC_REVISION)
  str     w0, [x9, #0x14]                         // store revision number on heap
  ldr     w2, [x10]                               // x2 bits 0-15: did, bits 16-31: vid
  ldrb    w3, [x10, #0x0e]                        // w3 = header type
  stp     w2, w3, [x9, #0x18]                     // store did/vid and header type on heap

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
  str     w0, [x7, 0xfd504514-0xfd504068]         // set bits 0-31 of [0xfd504514] (MSI_INT_MASK_CLR)
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L627
  str     w0, [x7, 0xfd504508-0xfd504068]         // set bits 0-31 of [0xfd504508] (MSI_INT_CLR)
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L628

  // Place the MSI target address inside the 32 bit addressable memory area
  // (0xfffffffc). Some devices might depend on it. This is possible since the
  // inbound window is located above the lower 4GB. Bit 0 of
  // PCIE_MISC_MSI_BAR_CONFIG_LO is repurposed to MSI enable, which we set,
  // thus target value is 0xfffffffc | 0x1 = 0xfffffffd.

  mov     w0, #0xfffffffd
  str     w0, [x7, 0xfd504044-0xfd504068]         // [0xfd504044] (PCIE_MISC_MSI_BAR_CONFIG_LO) = 0xfffffffd
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L634-L635
  str     wzr, [x7, 0xfd504048-0xfd504068]        // [0xfd504048] (PCIE_MISC_MSI_BAR_CONFIG_HI) = 0x0
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L636-L637
  movl    w0, 0xffe06540                          // PCIE_MISC_MSI_DATA_CONFIG_VAL_32
  str     w0, [x7, 0xfd50404c-0xfd504068]         // [0xfd50404c] (PCIE_MISC_MSI_DATA_CONFIG) = 0xffe06540 ("PCIE_MISC_MSI_DATA_CONFIG_VAL_32")
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L639-L640

4:
  ret     x5


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
  str     w0, [x10, 0xfd501100-0xfd500000]        // set [0xfd501100] (PCIE_RC_DL_MDIO_ADDR) = w0 (command | port | regad)
  ldr     w0, [x10, 0xfd501100-0xfd500000]        // read it back, presumably required since linux kernel does this:
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L339

  // Read [0xfd501108] (PCIE_RC_DL_MDIO_RD_DATA) into w1 every 10us until bit 31 is set or 10 attempts exhausted

  mov     w8, #10                                 // 10 attempts
  1:
    cbz     w8, 2f                                // exit loop if 10 iterations have completed
    sub     w8, w8, #1                            // decrement loop counter
    mov     x0, #10
    bl      wait_usec                             // sleep 10us
    ldr     w1, [x10, 0xfd501108-0xfd500000]      // w0=[0xfd501108] (PCIE_RC_DL_MDIO_RD_DATA)
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
  str     w0, [x10, 0xfd501100-0xfd500000]        // set [0xfd501100] (PCIE_RC_DL_MDIO_ADDR) = w0 (command | port | regad)
                                                  // w0 command (bits 20-31) clear (0x000) on entry => write operation
  ldr     w0, [x10, 0xfd501100-0xfd500000]        // read it back, presumably required since linux kernel does this:
                                                  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L360
  orr     w1, w1, 0x80000000                      // value to set, with bit 31 set
  str     w1, [x10, 0xfd501104-0xfd500000]        // set [0xfd501104] (PCIE_RC_DL_MDIO_WR_DATA) = w1 (value to set, with bit 31 set)

  // Read [0xfd501104] (PCIE_RC_DL_MDIO_WR_DATA) into w1 every 10us until bit 31 is clear or 10 attempts exhausted

  mov     w8, #10                                 // 10 attempts
  1:
    cbz     w8, 2f                                // exit loop if 10 iterations have completed
    sub     w8, w8, #1                            // decrement loop counter
    mov     x0, #10
    bl      wait_usec                             // sleep 10us
    ldr     w1, [x10, 0xfd501104-0xfd500000]      // w0=[0xfd501104] (PCIE_RC_DL_MDIO_WR_DATA)
    tbnz    w1, #31, 1b                           // repeat loop if bit 31 is set (=> read value before register update was complete)
2:
  ret     x11
