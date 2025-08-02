# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text

##########################################################################
# Information gleaned from the following sources:
#   * Linux Kernel:
#     + https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c
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
  adrp    x10, 0xfd500000 + _start                // x10 = RC config space base address
  adrp    x4, 0xfd504000 + _start                 // x4 = Broadcom PCIe Set Top Box registers
  adrp    x13, 0xfd508000 + _start                // x13 = VL805 USB Controller config space base address
  adrp    x14, 0xfd509000 + _start                // x14 = ECAM Index register
  adrp    x7, heap
  add     x7, x7, :lo12:heap                      // x7 = heap

  // Reset the PCI bridge
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1378-L1390

                                                  // +=============================+
  ldrwi   w6, x14, #0x210                         // | RGR1_SW_INIT_1 [0xfd509210] |
                                                  // +=============================+
                                                  //
                                                  //                                            P
                                                  //                                          I E
                                                  //                                          N R
                                                  //                                          I S
                                                  //    ---- ---- ---- ---- ---- ---- ---- -- T T
                                                  //
                                                  //    3322/2222/2222/1111/1111/11
                                                  //    1098/7654/3210/9876/5432/1098/7654/32 1 0
                                                  //
                                                  // 0b ----/----/----/----/----/----/----/-- - -  CLEAR BITS
                                                  // 0x    0    0    0    0    0    0    0      0
                                                  //
                                                  // 0b ----/----/----/----/----/----/----/-- 1 1  SET BITS
  orr     w6, w6, #3                              // 0x    0    0    0    0    0    0    0      3
                                                  //
                                                  // PERST = 0b1:
                                                  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1383-L1390
                                                  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L2227
                                                  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1018-L1027
                                                  //
                                                  // INIT = 0b1:
                                                  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1378-L1381
                                                  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L2228
  strwi   w6, x14, #0x210                         //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L950-L974

  mov     x0, #100                                // sleep 0.1ms (Linux kernel sleeps 0.1-0.2ms) with sleep_range:
  bl      wait_usec                               //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1392
                                                  //   https://www.kernel.org/doc/Documentation/timers/timers-howto.txt

  // Take the PCI bridge out of reset
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1394-L1397

  and     w6, w6, #~0x2                           //   GENERIC = 0b0:
  strwi   w6, x14, #0x210                         //     https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1395
                                                  //     https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L2228
                                                  //     https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L950-L974

  // Clear SERDES_IDDQ, i.e. put the PCIe Serializer/Deserializer PHY into IDDQ (deep power-down mode)
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1399-L1404
                                                  // +=============================================+
  ldrwi   w6, x4, #0x204                          // | PCIE_MISC_HARD_PCIE_HARD_DEBUG [0xfd504204] |
                                                  // +=============================================+
                                                  //
                                                  //                                               C
                                                  //                          R                    L
                                                  //                          E                    K
                                                  //                          F                    R
                                                  //                    R     C                    E
                                                  //                    E     L                    Q
                                                  //                    F     K                    _
                                                  //                    C     _                P   D
                                                  //         S        L L     O                E   E
                                                  //         E        1 K     V                R   B
                                                  //         R        S _     R                S   U
                                                  //         D        S O     D                T   G
                                                  //         E        _ V     _                _   _
                                                  //         S        E R     E                A   E
                                                  //         _        N D     N                S   N
                                                  //         I        A _     A                S   A
                                                  //         D        B O     B                E   B
                                                  //         D        L U     L                R   L
                                                  //    ---- Q --- -- E T --- E ---- ---- ---- T - E -
                                                  //
                                                  //    3322/2 222/22 2 2/111 1/1111/11
                                                  //    1098/7 654/32 1 0/987 6/5432/1098/7654/3 2 1 0
                                                  //
                                                  // 0b ----/0 ---/-- - -/--- -/----/----/----/- - - - CLEAR BITS
  and     w6, w6, #~0x08000000                    // 0x    0     8      0     0    0    0    0       0
                                                  //
                                                  // 0b ----/- ---/-- - -/--- -/----/----/----/- - - - SET BITS
                                                  // 0x    0     0      0     0    0    0    0       0
                                                  //
                                                  // SERDES_IDDQ = 0b0
  strwi   w6, x4, #0x204                          //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1403

  // Wait for SerDes (Serializer/Deserializer) to be stable
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1405-L1406

  mov     x0, #100                                // sleep 0.1ms (Linux kernel sleeps 0.1-0.2ms) with sleep_range:
  bl      wait_usec                               //   https://www.kernel.org/doc/Documentation/timers/timers-howto.txt

  // Update PCIE_MISC_MISC_CTRL
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1408-L1432
  //     *plus*
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1445-L1456
  //
  // Note, unlike the Linux driver, we combine these updates (to reduce code footprint)

                                                  // +==================================+
  ldrwi   w6, x4, #0x8                            // | PCIE_MISC_MISC_CTRL [0xfd504008] |
                                                  // +==================================+
                                                  //
                                                  //                  S
                                                  //                  C                P    P
                                                  //                  B          C     C    C
                                                  //                  _          F     I    I
                                                  //                  M          G     E    E
                                                  //                  A          _ S   _    _
                                                  //                  X          R C   R    R
                                                  //                  _          E B   C    C
                                                  //                  B          A _   B    B
                                                  //    S      S      U          D A   _    _    S
                                                  //    C      C      R          _ C   M    6    C
                                                  //    B      B      S          U C   P    4    B
                                                  //    0      1      T          R E   S    B    2
                                                  //    _      _      _          _ S   _    _    _
                                                  //    S      S      S          M S   M    M    S
                                                  //    I      I      I          O _   O    O    I
                                                  //    Z      Z      Z          D E   D    D    Z
                                                  //    E      E      E  ---- -- E N - E -- E -- E
                                                  //
                                                  //    3322/2 222/22 22/1111/11 1 1/1 1
                                                  //    1098/7 654/32 10/9876/54 3 2/1 0 98/7 65 4/3210
                                                  //
                                                  // 0b -000/- ---/-- 00/----/-- - -/- - --/- -- -/---- CLEAR BITS
  mov     w8, #~0x70300000                        // 0x    7     0     3    0      0      0      0    0
  and     w6, w6, w8                              //
                                                  // 0b 1---/1 ---/-- --/----/-- 1 1/- 1 --/1 -- -/---- SET BITS
  ldr     w8, =0x88003480                         // 0x    8     8     0    0      3      4      8    0
  orr     w6, w6, w8                              //
                                                  // SCB0_SIZE = 0b10001 = 17 (number of bits required to address bus - 15)
                                                  //   => System Control Bus size is > 2GB, and <= 4GB
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L932
                                                  //
                                                  // SCB_MAX_BURST_SIZE = 0b00
                                                  //   Probably maximum size for burst transactions on internal system control bus
                                                  //     0b00 => 128 bytes
                                                  //     0b01 => 256 bytes
                                                  //     0b10 => 512 bytes
                                                  //     0b11 => Reserved value
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L901-L902
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L912
                                                  //
                                                  // CFG_READ_UR_MODE = 0b1
                                                  //   Probably determines behaviour when attempting to read from an unconnected slot (Unsupported Request completions)
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L911
                                                  //
                                                  // SCB_ACCESS_EN = 0b1
                                                  //   Enable access to internal system control bus of PCIe controller?
                                                  //     https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L910
                                                  //
                                                  // PCIE_RCB_MPS_MODE = 0b1
                                                  //   Configures whether receive completion boundary is aligned to max payload size?
                                                  //     https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1430
                                                  //
                                                  // PCIE_RCB_64B_MODE = 0b1
                                                  //   64 byte alignment for receive completion boundaries?
  strwi   w6, x4, #0x8                            //     https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1431

  strwi   wzr, x4, #0x2c                          // Disable first inbound window (RC1)
  strwi   wzr, x4, #0x30                          //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1191-L1199

  // Configure RC2 *CPU inbound* memory view (address range on PCIe bus for PCIe devices to access system memory)
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

  strwi   wzr, x4, #0x3c                          // Disable third inbound window (RC3)
  strwi   wzr, x4, #0x40                          //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1302-L1306

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

  // Set PCIe->SCB little endian mode for BAR 2 (not sure why this requires two bits)
  // My rpi400 already had correct endian mode after a reset, so this might be unnecessary
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L1035-L1039
  //
  // Updates registers:
  //   * PCIE_RC_CFG_VENDOR_VENDOR_SPECIFIC_REG1

  ldrwi   w0, x10, #0x188
  and     w0, w0, #~0xc                           // Clear bits 2, 3 (ENDIAN_MODE_BAR2) => little endian
  strwi   w0, x10, #0x188                         // of [0xfd500188] (PCIE_RC_CFG_VENDOR_VENDOR_SPECIFIC_REG1)

  // Preserve revision number, on the heap
  ldrwi   w0, x4, #0x6c                           // w0 = [0xfd50406c] (PCIE_MISC_REVISION)
  strwi   w0, x7, #0x14                           // store revision number on heap

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

  // Preserve device id, vendor id on the heap
  ldrwi   w2, x10, #0x0                           // x2 bits 0-15: did, bits 16-31: vid
  // Preserve header type on the heap
  ldrbi   w3, x10, #0xe                           // w3 = header type
  stp     w2, w3, [x7, #0x18]                     // store did/vid and header type on heap
4:

  // RC: Set LTR Enable bit in PCI Express Device Control 2 register (PCI_EXP_DEVCTL2) of the root complex, i.e. turn LTR on.
  // PCI Express capability starts at offset 0xac, and PCI_EXP_DEVCTL2 register has offset 0x28 from start of capability,
  // i.e. offset is 0xac + 0x28 = 0xd4
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/probe.c#L2166-L2177
  mov     w1, #0x0400
  strhi   w1, x10, #0xd4                          // [0xfd5000d4] = 0x0400 (was 0x0000)

  // RC: Set SERR forwarding bit (bit 1) in PCI bridge control of root complex.
  // In contrast, Cirlce sets bit 0 instead which enables parity detection on secondary interface.
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/probe.c#L2207-L2223
  mov     w1, #0x0002
  strhi   w1, x10, #0x3e                          // [0xfd50003e] = 0x0002 (was 0x0000)

  // RC: Disable Power Management (clear bit 8) and clear Power Management Status (by setting bit 15) of PCI_PM_CTRL register of root complex.
  // Power Management capability starts at offset 0x48, and PCI_PM_CTRL has offset 0x04 from start of capability,
  // i.e. offset is 0x48 + 0x04 = 0x4c
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/pci.c#L2354-L2368
  ldrhi   w1, x10, #0x4c                          // w1 = [0xfd50004c] (=0x2008) = current value of PCI_PM_CTRL for root complex
  and     w1, w1, #~0x0100                        // clear bit 8 (PCI_PM_CTRL_PME_ENABLE)
  orr     w1, w1, #0x8000                         //   and set bit 15 (PCI_PM_CTRL_PME_STATUS)
  strhi   w1, x10, #0x4c                          // of [0xfd50004c] (PCI_PM_CTRL)

  // RC: Clear AER status registers
  // For RC, AER is the first extended capability at 0x100 offset
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/pcie/aer.c#L1413-L1419
  ldrwi   w1, x10, #0x130                         // Read root error status
  strwi   w1, x10, #0x130                         // Clear set bits (don't clear already cleared bits, since they may be reserved)
  ldrwi   w1, x10, #0x110                         // Read correctable error status
  strwi   w1, x10, #0x110                         // Clear set bits (don't clear already cleared bits, since they may be reserved)
  ldrwi   w1, x10, #0x104                         // Read uncorrectable error status
  strwi   w1, x10, #0x104                         // Clear set bits (don't clear already cleared bits, since they may be reserved)

  // RC: Enable PCIe error reporting
  ldrhi   w1, x10, #0xb4                          // PCI_EXP_DEVCTL (offset 0x8 from 0xac where PCIe device capability starts)
  orr     w1, w1, #0xf                            //  PCI_EXP_DEVCTL_CERE    0x01    Correctable Error Reporting Enable
                                                  //  PCI_EXP_DEVCTL_NFERE   0x02    Non-Fatal Error Reporting Enable
                                                  //  PCI_EXP_DEVCTL_FERE    0x04    Fatal Error Reporting Enable
                                                  //  PCI_EXP_DEVCTL_URRE    0x08    Unsupported Request Reporting Enable
  strhi   w1, x10, #0xb4

  // RC: Configure bus numbers and latency timer
  // 0x18: PCI Primary Bus = 0x00
  // 0x19: Secondary Bus = 0x01
  // 0x1a: Subordinate Bus (Highest bus number behind bridge) = 0x01
  // 0x1b: Latency timer for secondary interface = 0x00
  ldr     w1, =0x00010100
  strwi   w1, x10, #0x18                          // was 0x00000000

  // RC: Clear errors
  // Write 0xffff to clear all status bits (e.g., parity errors, aborts)
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/probe.c#L1332-L1333
  mov     w1, #0xffff
  strhi   w1, x10, #0x6                           // PCI_STATUS = 0xffff (was 0x0010)

  // Broadcom PCIe Stats Trigger
  // 0->1 transition on CTRL_EN is required to clear counters and start capture
  // microseconds count of 0 starts continuous gathering
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1627-L1645
  ldrwi   w6, x10, #0x1940
  and     w6, w6, #~0x1                           // clear bit 0 (PCIE_RC_PL_STATS_CTRL_EN_MASK) and
  strwi   w6, x10, #0x1940                        // of [0xfd501940] (PCIE_RC_PL_STATS_CTRL)
  and     w6, w6, #~0xfffffff0                    // clear bits 4-31 (PCIE_RC_PL_STATS_CTRL_LEN_MASK) and
  orr     w6, w6, #0x1                            // set bit 0 (PCIE_RC_PL_STATS_CTRL_EN_MASK)
  strwi   w6, x10, #0x1940                        // of [0xfd501940] (PCIE_RC_PL_STATS_CTRL)

  // Unassert the fundamental reset
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L965-L966
  //
  // Updates registers:
  //   * RGR1_SW_INIT_1

  ldrwi   w6, x14, #0x210                         // note, if we can assume the value hasn't changed, we could cache current value in a register and avoid this extra ldr instruction
  and     w6, w6, #~0x1                           // clear bit 0 (PCIE_RGR1_SW_INIT_1_PERST)
  strwi   w6, x14, #0x210                         // of [0xfd509210] (RGR1_SW_INIT_1)

  // Wait for 100ms after PERST# deassertion; see PCIe CEM specification
  // sections 2.2, PCIe r5.0, 6.6.1.
  ldr     x0, =100000
  bl      wait_usec                               // sleep 100,000us = 100ms

  // Give the RC/EP even more time to wake up, before trying to configure RC.
  // Poll status until ready, every 1ms, up to maximum of 100 times
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1800-L1806
   mov     w8, #100                               // 100 attempts
   1:
     cbz     w8, 2f                               // exit loop if 100 iterations have completed
     sub     w8, w8, #1                           // note, linux kernel checks only every 5ms, but we check every 1ms
     mov     x0, #1000
     bl      wait_usec                            // sleep 1ms
     ldrwi   w0, x4, #0x68
     tbz     w0, #4, 1b                           // repeat loop if bit 4 is clear (PCIE_MISC_PCIE_STATUS_PCIE_PHYLINKUP)
     tbz     w0, #5, 1b                           // repeat loop if bit 5 is clear (PCIE_MISC_PCIE_STATUS_PCIE_DL_ACTIVE)
 2:
   stp     w0, w8, [x7]                           // store last read status register value and number of 1ms on heap
// cbz     w8, 4f                                 // exit early if failed to wake up

  // Exit early if in endpoint mode, not in root complex mode => implies PCIe misconfiguration
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L980-L983

//  tbz     w0, #7, 4f                            // if bit 7 is clear (PCIE_MISC_PCIE_STATUS_PCIE_PORT) branch ahead to 4:

  // Extends the timeout period for an access to an internal bus to 4s
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1537-L1554
  ldr     w1, =4*216000000                        // 4s @ 216MHz
  strwi   w1, x14, #0x208

  // Provides L0s, L1, and L1SS, but not compliant to provide Clock Power
  // Management; specifically, may not be able to meet the Tclron max timing of
  // 400ns as specified in "Dynamic Clock Control", section 3.2.5.2.2 of the
  // PCIe spec. This situation is atypical and should happen only with older
  // devices.
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/controller/pcie-brcmstb.c#L1594-L1601

  // Updates registers:
  //   * PCIE_MISC_HARD_PCIE_HARD_DEBUG

  ldrwi   w0, x4, #0x204
  orr     w0, w0, #0x200000                       // set bit 21 (L1SS_ENABLE)
  strwi   w0, x4, #0x204                          // of [0xfd504204] (PCIE_MISC_HARD_PCIE_HARD_DEBUG)

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

  // RC Disable:
  //   PCI_EXP_RTCTL_SECEE      0x0001     System Error on Correctable Error
  //   PCI_EXP_RTCTL_SENFEE     0x0002     System Error on Non-Fatal Error
  //   PCI_EXP_RTCTL_SEFEE      0x0004     System Error on Fatal Error
  //   PCI_EXP_RTCTL_PMEIE      0x0008     PME Interrupt
  //
  // CRS = Configuration Request Retry Status, directing devices to
  // return a vendor id of 0x0001 if they are not ready after a reset
  //   https://blog.linuxplumbersconf.org/2017/ocw/system/presentations/4732/original/crs.pdf
  //
  // RC Enable:
  //   PCI_EXP_RTCTL_RRS_SVE    0x0010     Config RRS Software Visibility Enable
  //
  // PCI Express capability starts at offset 0xac, and PCI_EXP_RTCTL register has offset 0x1c from start of capability,
  // i.e. offset is 0xac + 0x1c = 0xc8
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/probe.c#L1150-L1159
  mov     w1, #0x0010
  strhi   w1, x10, #0xc8                          // [0xfd5000c8] = 0x0010 (was 0x0000)

  // PCIe RC ECAM Index Register (offset 0x9000 from base, x14 + 0x0)
  // Mounts VL805 (bus 1, device 0, function 0, offset 0) configuration space at physical address [0xfd58000] (x13)
  // 0b0000 bbbb bbbb dddd dfff oooo oooo oooo (b = bus, d = device, f = function, o = offset)
  // 0b0000 0000 0001 0000 0000 0000 0000 0000
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L707-L722
  mov     w1, #0x00100000
  strwi   w1, x14, #0x0                           // was 0x00000000

  // VL805: Disable Power Management (clear bit 8) and clear Power Management Status (by setting bit 15) of PCI_PM_CTRL register.
  // Power Management capability starts at offset 0x80, and PCI_PM_CTRL has offset 0x04 from start of capability,
  // i.e. offset is 0x80 + 0x04 = 0x84
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/pci.c#L2354-L2368
  ldrhi   w1, x13, #0x84                          // w1 = [0xfd50004c] (=0x2008) = current value of PCI_PM_CTRL for root complex
  and     w1, w1, #~0x0100                        // clear bit 8 (PCI_PM_CTRL_PME_ENABLE)
  orr     w1, w1, #0x8000                         //   and set bit 15 (PCI_PM_CTRL_PME_STATUS)
  strhi   w1, x13, #0x84                          // of [0xfd50004c] (PCI_PM_CTRL)

  // VL805: Enable PCIe error reporting
  ldrhi   w1, x13, #0xcc                          // PCI_EXP_DEVCTL (offset 0x8 from 0xac where PCIe device capability starts)
  orr     w1, w1, #0xf                            //  PCI_EXP_DEVCTL_CERE    0x01    Correctable Error Reporting Enable
                                                  //  PCI_EXP_DEVCTL_NFERE   0x02    Non-Fatal Error Reporting Enable
                                                  //  PCI_EXP_DEVCTL_FERE    0x04    Fatal Error Reporting Enable
                                                  //  PCI_EXP_DEVCTL_URRE    0x08    Unsupported Request Reporting Enable
  strhi   w1, x13, #0xcc

  // RC ASPM: Retrain link and set common clock configuration
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/pcie/aspm.c#L201-L203
  mov     w1, #0x60                               // PCI_EXP_LNKCTL_RL       0x0020: Retrain Link
                                                  // PCI_EXP_LNKCTL_CCC      0x0040: Common Clock Configuration
  strhi   w1, x10, #0xbc                          // was 0x0000

  // RC: Wait for link training to complete
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/pci.c#L4663-L4691
  mov     w8, #1000                               // 1000 attempts
  5:
    cbz     w8, 6f                                // exit loop with failure if 1000 iterations have completed
    sub     w8, w8, #1
    mov     x0, #1000
    bl      wait_usec                             // sleep 1ms
    ldrhi   w0, x10, #0xbe                        // check link status
    tbnz    w0, #11, 5b                           // repeat loop if bit 11 is set (PCI_EXP_LNKSTA_LT) - implies link training still in progress

  // RC: Clear LBMS (Link Bandwidth Management Status) after a manual retrain so
  // that the bit can be used to track link speed or width changes made by
  // hardware itself in attempt to correct unreliable link operation.
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/pci.c#L4732-L4737
  mov     w1, #0x4000                             // PCI_EXP_LNKSTA_LBMS
  strhi   w1, x10, #0xbe                          // Update link status register

  // VL805:
  ldr     w1, =0xc0000004                         // lower 32 bits of MEM_PCIE_RANGE_PCIE_START (pcie side address) | 0b100 (64 bit memory type) (was 0x00000004)
  strwi   w1, x13, #0x10
  strwi   wzr, x13, #0x14                         // upper 32 address bits = 0 (not technically needed, already 0, but nice to keep)

  // RC: Set PCI I/O Base
  mov     w1, #0xf0
  strhi   w1, x10, #0x1c                          // was 0x0000

  // RC: Set PCI Memory Base
  mov     w1, #0xc000c000
  strwi   w1, x10, #0x20                          // was 0xf800f800 - perhaps from previous circle run that uses this alternative value?

  // RC: Set PCI Pref Memory Base
  mov     w1, #0x0000fff0
  strwi   w1, x10, #0x24                          // was 0x0001fff1

  // Interrupt line for RC to match value linux assigned - probably not needed
  mov     w1, #0x1b
  strbi   w1, x10, #0x3c

  // RC: PCI Set Master (Update PCI Command)
  // 0b0000 0000 0000 0110
  // set bit 1  => Enable response in Memory space
  // set bit 2  => Enable bus mastering
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/pcie/portdrv.c#L696
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/pcie/portdrv.c#L342
  //   https://github.com/raspberrypi/linux/blob/rpi-6.12.y/drivers/pci/pci.c#L4292-L4307 and something else
  mov     w1, #0x0006
  strhi   w1, x10, #0x4                           // was 0x0000

  // RC: Initialise PME (pcie_pme_probe)
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/pcie/pme.c#L322-L361
  // Note:
  //   *) PME interrupts were already disabled earlier
  //   *) TODO: register an interrupt handler for PME events
  // 1) clear root PME status
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/pcie/pme.c#L348
  mov     w1, 0x10000
  strwi   w1, x10, #0xcc
  // 2) update Root Control register
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/pcie/pme.c#L347
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/pcie/pme.c#L359
  ldrhi   w1, x10, #0xc8                          // Read Root Control register
  orr     w1, w1, #0x8                            // Enable bits:
                                                  //   3: PCI_EXP_RTCTL_PMEIE   PME Interrupt Enable
                                                  //     https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/pcie/pme.c#L57-L58
  strhi   w1, x10, #0xc8                          // and update value

  // AER enable root port
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/pcie/aer.c#L1392-L1422
  // 1) Clear PCIe Capability's Device Status
  //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/pci/pcie/aer.c#L1405-L1407
  ldrhi   w1, x10, #0xb6                          // Read PCIe Capability's Device Status
  strhi   w1, x10, #0xb6                          // Clear set bits (don't clear already cleared bits, since they may be reserved)

  // RC: Enable interrupt in response to error messages
  ldrwi   w1, x10, #0x12c                         // Read PCI_ERR_ROOT_COMMAND
  orr     w1, w1, #0x7                            // Set bits:
                                                  //   0: PCI_ERR_ROOT_CMD_COR_EN       Enable correctable error reporting
                                                  //   1: PCI_ERR_ROOT_CMD_NONFATAL_EN  Enable non-fatal error reporting
                                                  //   2: PCI_ERR_ROOT_CMD_FATAL_EN     Enable fatal error reporting
  strwi   w1, x10, #0x12c                         // and update value

  // VL805: Interrupt line to match value linux assigned - probably not needed
  mov     w1, #0x1b
  strbi   w1, x13, #0x3c                          // was 0x00

  // RC: Enable L1
  mov     w1, #0x0042                             // PCI_EXP_LNKCTL_ASPM_L1    0x0002: L1 Enable
                                                  // PCI_EXP_LNKCTL_CCC        0x0040: Common Clock Configuration
  strhi   w1, x10, #0xbc

  // VL805: Enable L1
  mov     x1, #0x0142                             // PCI_EXP_LNKCTL_ASPM_L1    0x0002: L1 Enable
                                                  // PCI_EXP_LNKCTL_CCC        0x0040: Common Clock Configuration
                                                  // PCI_EXP_LNKCTL_CLKREQ_EN  0x0100: Enable ClkReq

  strhi   w1, x13, #0xd4

  // Reset VL805 firmware (the USB Host Controller chip)
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/reset/reset-raspberrypi.c#L26-L66
  adr     x0, vl805_reset_req                     // x0 = memory block pointer for mailbox call to reset VL805 firmware
  bl      mbox_call                               //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/reset/reset-raspberrypi.c#L52-L53
  mov     x0, #200                                // sleep 200-1000us
  bl      wait_usec                               //   https://github.com/raspberrypi/linux/blob/7ed6e66fa032a16a419718f19c77a634a92d1aec/drivers/reset/reset-raspberrypi.c#L57-L58
  // Corrupted by mbox_call above, so need to set again
  adrp    x10, 0xfd500000 + _start                // x10 = PCI to PCI bridge config space base address

  // VL805: PCI cache line size
  mov     w1, #0x10
  strbi   w1, x13, #0xc                           // PCI cache line size = 0x10 (64/4) (was 0x00)

  // VL805: configure MSI
  //   Configure Queue size: 0b010 (log2 => 4)
  //   Disable MSI enable, if enabled

                                                  // +=================================+
                                                  // | PCI_MSI_FLAGS (Message Control) |
                                                  // +=================================+
                                                  //
                                                  //             P 6 C
                                                  //             E 4 O   A
                                                  //             R B N   V
                                                  //             _ I F   A   M
                                                  //             V T I   I   S
                                                  //             E _ G   L   I
                                                  //             C C _   _   _
                                                  //             T A Q   Q   E
                                                  //             O P _   _   N
                                                  //             R A S   S   A
                                                  //             _ B I   I   B
                                                  //             M L Z   Z   L
                                                  //    0000 000 A E E-- E-- E
                                                  //
                                                  //    1111/11
                                                  //    5432/109 8/7 654/321 0
                                                  //
                                                  // 0b ----/--- -/- 0-0/--- 0  CLEAR BITS
                                                  // 0x    0     0     5     1
                                                  //
                                                  // 0b ----/--- -/1 -1-/--- -  SET BITS
                                                  // 0x    0     0     a     0


  mov     w1, #0x00a4
  strhi   w1, x13, #0x92

  // VL805:
  mov     w1, #0xfffffffc
  strwi   w1, x13, #0x94                          // was 0x00000000

  // VL805:
  mov     w1, #0x6540
  strhi   w1, x13, #0x9c                          // was 0x0000

  // VL805: Set PCI command
  // 0b0000 0101 0100 0110
  // set bit 1  => Enable response in Memory space
  // set bit 2  => Enable bus mastering
  // set bit 6  => Enable parity checking
  // set bit 8  => Enable SERR
  // set bit 10 => INTx Emulation Disable
  //   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/include/uapi/linux/pci_regs.h#L40-L51
  mov     w1, #0x546
  strhi   w1, x13, #0x4                           // was 0x0000 (note, circle does not disable INTx emulation)

  // Enable MSI bit in PCI_MSI_FLAGS
  mov     w1, #0x00a5
  strhi   w1, x13, #0x92


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

  //  09-0b: 0c0330 => usb3 xhci (0c = serial bus controller, 0c = usb host controller, 30 = usb3 xhci)

  // VL805 legacy data

  //           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
  //  fd508040 00 00 00 00 00 01 00 00 09 00 00 0e 04 00 00 00 c0 38 01 00 00 00 00 00 00 00 00 00 06 11 83 34
  //  fd508060 30 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 08 00 03 00 01 00 00 18

  //  60: 30 => release 3.0 (not 3.1 or 3.2)
  //  61: 20 (default) => SOF cycle time of 60000

  //  fd508048: Mirror of xHCI Command Ring Control Register lower 32 bits (0x0e000009)
  //    Bits 31:6 (address) = 0x0e000000 → Command Ring 64 byte aligned Base Address lower 32 bits
  //    Bits 5:0 (flags) = 0x09 → 0b001001
  //      Bit 5: CRCS (Command Ring Cycle State) → 0
  //      Bit 4: CA (Command Abort) → 0
  //      Bit 3: CRR (Command Ring Running) → 1
  //      Bit 2: Reserved → 0
  //      Bit 1: Reserved → 0
  //      Bit 0: RCS (Ring Cycle State) → 1
  //  fd508050: Firmware version 0x000138c0

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
# adr     x2, xhci_mmio
# str     x0, [x2], #8                            // [xhci_mmio] = 0x600000000 (pcie base)
# ldrbi   w1, x0, #0x0                            // w1 = capabilities length
# add     x1, x1, x0                              // x1 = address of first byte after capabilities = op base
# str     x1, [x2], #8                            // [xhci_mmio_op] = 0x600000000 + [0x600000000]
# ldrwi   w3, x0, #0x14                           // w3 = [XHCI_REG_CAP_DBOFF]
# and     w3, w3, 0xfffffffc
# add     x3, x3, x0
# str     x3, [x2], #8                            // [xhci_mmio_db] = 0x600000000 + ([0x600000014] && 0xfffffffc)
# ldrwi   w3, x0, #0x18                           // w3 = [XHCI_REG_CAP_RTSOFF]
# and     w3, w3, 0xffffffe0
# add     x3, x3, x0
# str     x3, [x2], #8                            // [xhci_mmio_rt] = 0x600000000 + ([0x600000018] && 0xffffffe0)
# add     x3, x1, #0x400                          // x3 = op base + 0x400
# str     x3, [x2], #8                            // [xhci_mmio_pt] = 0x600000400 + ([0x600000000])
# ldrwi   w3, x0, #0x4                            // w3 = [XHCI_REG_CAP_HCSPARAMS1]
# ldrwi   w4, x0, #0x8                            // w4 = [XHCI_REG_CAP_HCSPARAMS2]
# ldrwi   w6, x0, #0xc                            // w6 = [XHCI_REG_CAP_HCSPARAMS3]
# ldrwi   w9, x0, #0x10                           // w9 = [XHCI_REG_CAP_HCSPARAMS]
# stp     w3, w4, [x2], #8                        // update lower 64 bits of [xhci_cap_cache]
# stp     w6, w9, [x2], #8                        // update upper 64 bits of [xhci_cap_cache]
# and     w9, w9, #0xffff0000
# add     x9, x0, x9, lsr #14                     // x9 = 0x600000000 + (([0x600000010] & 0xffff0000) << 14) = extended capabilities address
# str     x9, [x2], #8                            // [xhci_mmio_ec] = extended capabilities address

  // reset the Host Controller
  // wait until (USBSTS.CNR == 0) and (USBSTS.HCHalted == 1)
  6:
    ldrwi   w3, x0, #0x24                         // w3 = [USBSTS]
    tbnz    w3, #11, 6b                           // loop while CNR != 0
    tbz     w3, #0, 6b                            // loop while HCHalted == 0

  // set USBCMD.HCRST = 1
  ldrwi   w3, x0, #0x20                           // w3 = [USBCMD]
  orr     w3, w3, #0x2                            // set bit 1 (HCRST)
  strwi   w3, x0, #0x20

  // wait until (USBCMD.HCRST == 0)
  7:
    ldrwi   w3, x0, #0x20                         // w3 = [USBCMD]
    tbnz    w3, #0x1, 7b                          // loop while HCRST != 0

  // wait until (USBSTS.CNR == 0)
  8:
    ldrwi   w3, x0, #0x24                         // w3 = USBSTS
    tbnz    w3, #11, 8b                           // loop while CNR != 0
#   tbz     w3, #11, 8b                           // loop while Halted == 0

  adrp    x1, xhci_start
  adrp    x2, xhci_end
  add     x2, x2, :lo12:xhci_end
  9:
    stp     xzr, xzr, [x1], #16
    cmp     x1, x2
    b.lt    9b

  mov     w3, #0x20
  strwi   w3, x0, #0x58                           // [XHCI_REG_OP_CONFIG] = 32 (=> maximum 32 device slots)

  adrp    x1, scratchpad_bufs                     // x1 = scratchpad_bufs (virutal)
  mov     w4, #0x4                                // upper 32 bits for DMA addresses
  adrp    x9, dcbaa                               // x9 = dcbaa (virtual)

  strwi   w9, x0, #0x50                           // [XHCI_REG_OP_DCBAAP_LO] = :lo32:dcbaa (virtual) = :lo32:dcbaa (physical) = :lo32:dcbaa (dma)
  strwi   w4, x0, #0x54                           // [XHCI_REG_OP_DCBAAP_HI] = 0x4 => DCBAAP = dcbaa (DMA)

  add     x3, x9, scratchpad_ptrs-dcbaa           // x3 = scratchpad_ptrs (virtual)
  mov     x6, x3                                  // x6 = scratchpad_ptrs (virual)
  bfi     x6, x4, #32, #32                        // x6 = scratchpad_ptrs (DMA)
  strxi   x6, x9, #0x0                            // [dcbaa] = scratchpad_ptrs (DMA)

  bfi     x1, x4, #32, #32                        // x1 = scratchpad_bufs (DMA)

  mov     w2, 31                                  // 31 scratchpads to initialise
  10:
    strxi   x1, x3, #8                            // scratchpad_ptrs[i] = DMA(scratchpad_bufs[i])
    add     x1, x1, #0x1000
    sub     w2, w2, #1
    cbnz    w2, 10b

  adrp    x1, command_ring                        // x1 = command_ring (virtual)
  orr     x1, x1, #1                              // set cycle bit in CRCR (bit 0)

  // must perform 32 bit writes; MMIO region
  // Command ring dequeue pointer -> first TRB in command ring TRB
  strwi   w1, x0, #0x38                           // [XHCI_REG_OP_CRCR_LO] = lower32(command_ring (virtual)) | 0x1 = lower32(command_ring (DMA)) | 0x1
  ldrwi   w2, x0, #0x38
  strwi   w4, x0, #0x3c                           // [XHCI_REG_OP_CRCR_HI] = 4 = upper32(command_ring (DMA))
  ldrwi   w2, x0, #0x3c

  adrp    x2, event_ring                          // x2 = event_ring (virtual)
  add     x3, x2, erst-event_ring                 // x3 = ERST (virtual)
  bfi     x2, x4, #32, #32                        // x2 = event_ring (DMA)

// https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/extensible-host-controler-interface-usb-xhci.pdf
// Section 6.5 (page 514)
  strxi   x2, x3, #0x0                            // [ERST] = event_ring (DMA)
  mov     w9, #0x00fc
  strhi   w9, x3, #0x8                            // [ERST+0x8] = 0xfc (event ring has 252 TRBs)

  // must perform 32 bit writes; MMIO region
  strwi   w3, x0, #0x230                          // [interrupt 0 ERSTBA] = lower32(erst (virtual)) = lower32(erst (DMA))
  strwi   w4, x0, #0x234                          // [interrupt 0 ERSTBA] = 4 = upper32(erst (DMA))

  mov     w8, #1
  strwi   w8, x0, #0x228                          // [interrupt 0 ERSTSZ] = 1 segment
  // must perform 32 bit writes; MMIO region
  strwi   w2, x0, #0x238                          // [interrupt 0 ERDP] = lower32(event_ring (DMA))
  strwi   w4, x0, #0x23c                          // [interrupt 0 ERDP] = 4 = upper32(event_ring (DMA))
  ldrwi   w8, x0, #0x220                          // w8 = [interrupt 0 IMAN]
  orr     w8, w8, #2                              // InterruptEnable (bit 1) = 1
  strwi   w8, x0, #0x220                          // update [interrupt 0 IMAN] setting InterruptEnable (bit 1) = 1

  // set USBCMD.RUN_STOP = 1 and USBCMD.INTE = 1
  ldrwi   w3, x0, #0x20                           // w3 = [USBCMD]
  orr     w3, w3, #0x1                            // set bit 0 (RUN_STOP)
  orr     w3, w3, #0x4                            // set bit 2 (INTE)
  strwi   w3, x0, #0x20

  11:
    ldrwi   w3, x0, #0x24                         // w3 = USBSTS
    tbnz    w3, #0, 11b                           // loop while HCHalted != 0

  // https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/extensible-host-controler-interface-usb-xhci.pdf
  // Section 6.4.3.1 (page 488)
  adrp    x1, command_ring                        // x1 = command_ring (virtual)
  mov     w2, (23 << 10) | 1                      // TRB Type = 23 (No-Op: see page 512 of xHCI spec)
  strxi   xzr, x1, #0x0
  strwi   wzr, x1, #0x8
  strwi   w2, x1, #0xc
  mov     x8, x1
  bfi     x8, x4, #32, #32                        // x2 = event_ring (DMA)
  strxi   x8, x1, #0x10
  mov     w9, (6 << 10) | (1 << 1)                // TRB Type = 6 (Link TRB), Toggle Cycle = 1, Cycle = 0
  strwi   wzr, x1, #0x18
  strwi   w9, x1, #0x1c

  strwi   wzr, x0, #0x100                         // ring host controller doorbell (register 0)

  // Test - try to write to MSI address directly to trigger interrupt...
  // If my maths isn't totally off, this should be the MSI target address as a CPU virtual address, and it should be mapped.
  // However, currently this is causing a crash (later on) so there may be an issue in the interrupt handler...
  // Commenting out for now until I have gotten to the bottom of it...
  //
  //   mov     w3, #0x6540
  //   ldr     x2, =0xfffffff63ffffffc
  //   strwi   w3, x2, #0x0

  ret     x5


# https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/extensible-host-controler-interface-usb-xhci.pdf
# page 381 (section 5.3 Host Controller Capability Registers)


# Capability registers...
#
#           00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
# 600000000 20 00 00 01 20 04 00 05 31 00 00 fc 04 00 e7 00 eb 41 28 00 00 01 00 00 00 02 00 00 00 00 00 00
#
# 0x00: XHCI_REG_CAP_CAPLENGTH    0x20        => Op base at 0x600000020
# 0x02: XHCI_REG_CAP_HCIVERSION   0x0100      => Version 1.0 = USB 3.0 controller
# 0x04: XHCI_REG_CAP_HCSPARAMS1   0x05000420  0b 00000101 (MaxPorts = 5) 00000 (Rsvd) 00000000100 (MaxIntrs = 4) 00100000 (MaxSlots = 32)
# 0x08: XHCI_REG_CAP_HCSPARAMS2   0xfc000031  0b 11111 (Max Scratchpad Buffers Lo = 31) 1 (Scratchpad Restore = 1) 00000 (Max Scratchpad Buffers Hi = 0) 0000000000000 (Rsvd) 0011 (Event Ring Segment Table Max = 3) 0001 (Isochronous Scheduling Threshold = 1)
# 0x0c: XHCI_REG_CAP_HCSPARAMS3   0x00e70004  0b 0000000011100111 (U2->U0 Device Exit Latency < 231 microseconds) 00000000 (Rsvd) 00000100 (U1->U0 Device Exit Latency < 4 microseconds)
# 0x10: XHCI_REG_CAP_HCCPARAMS1   0x002841eb  0b 0000000000101000: xHCI Extended Capabilities Pointer (xECP) = 40 => 160 bytes offset (0xa0) => extended capabilities at 0x6000000a0
#                                                0100: MaxPSASize = 4 => Primary Stream Array size = 32
#                                                0: Contiguous Frame ID Capability (CFC)
#                                                0: Stopped EDTLA Capability (SEC)
#                                                0: Stopped - Short Packet Capability (SPC)
#                                                1: Parse All Event Data (PAE)
#                                                1: No Secondary SID Support (NSS)
#                                                1: Latency Tolerance Messaging Capability (LTC)
#                                                1: Light HC Reset Capability (LHRC)
#                                                0: Port Indicators (PIND)
#                                                1: Port Power Control (PPC)
#                                                0: Context Size (CSZ) => 32 byte Context data structures (not Stream Contexts) (rather than 64 byte)
#                                                1: BW Negotiation Capability (BNC)
#                                                1: 64-bit Addressing Capability77 (AC64)
# 0x14: XHCI_REG_CAP_DBOFF        0x00000100 => Doorbell Array Offset = 0x100 (i.e. 0x600000100)
# 0x18: XHCI_REG_CAP_RTSOFF       0x00000200 => Runtime Register Space Offset (i.e. 0x600000200)
# 0x1c: XHCI_REG_CAP_HCCPARAMS2   0x00000000 =>



# Operational registers...
#
# 600000020 00 00 00 00 11 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
#
# 0x20: XHCI_REG_OP_USBCMD        0x00000000
# 0x24: XHCI_REG_OP_USBSTS        0x00000011
# 0x28: XHCI_REG_OP_PAGESIZE      0x00000001  => 4KB page size
# 0x2c: reserved                  0x00000000
# 0x30: reserved                  0x00000000
# 0x34: XHCI_REG_OP_DNCTRL        0x00000000
# 0x38: XHCI_REG_OP_CRCR_LO       0x00000000
# 0x3c: XHCI_REG_OP_CRCR_HI       0x00000000
# 0x40: reserved                  0x00000000
# 0x44: reserved                  0x00000000
# 0x48: reserved                  0x00000000
# 0x4c: reserved                  0x00000000
# 0x50: XHCI_REG_OP_DCBAAP_LO     0x00000000
# 0x54: XHCI_REG_OP_DCBAAP_HI     0x00000000
# 0x58: XHCI_REG_OP_CONFIG        0x00000000


# Extended capabilities...
#
# 6000000a0 01 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 08 00 02 55 53 42 20 01 01 06 10 00 00 00 00
# 6000000c0 23 00 e0 01 00 00 00 00 00 00 00 00 00 00 00 00 02 8c 00 03 55 53 42 20 02 04 00 10 00 00 00 00
# 6000000e0 34 01 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000220 00 00 00 00 a0 0f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000240 00 00 00 00 a0 0f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000260 00 00 00 00 a0 0f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000280 00 00 00 00 a0 0f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000300 0a 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000320 00 00 00 00 00 00 00 00 a0 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000420 e1 02 02 40 00 00 00 00 00 00 00 00 00 00 00 00 a0 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000440 a0 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 a0 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00
# 600000460 a0 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00



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


# .align 3
# xhci_mmio: .space 8                               // = 0x600000000 (pcie base = xhci base) (capability registers)
# xhci_mmio_op: .space 8                            // operational registers address
# xhci_mmio_db: .space 8                            // doorbell registers address
# xhci_mmio_rt: .space 8                            // runtime registers address
# xhci_mmio_pt: .space 8                            // port register set address
# xhci_cap_cache: .space 16                         // capability cache values
# xhci_mmio_ec: .space 8                            // extended capabilities address
