# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


# Specification Reference Table
#
# This file defines spec tags used in code comments across kernel/*.s files.
# References in code use the format: [TAG] sN.N.N pNNN -- description
#   [TAG]       = spec identifier from this table
#   sN.N.N      = section number
#   pNNN        = page number
#   Table N-N   = table reference
#   Figure N-N  = figure reference
#
# Example: [XHCI] s4.6.5 p110 -- Address Device command
#
# SHA256 checksums are for the specific PDF revision used when page/section
# references were verified. If your copy has a different checksum, page
# numbers may have shifted.


# [A53TRM]
#   ARM Cortex-A53 MPCore Processor Technical Reference Manual (DDI0500)
#   https://developer.arm.com/documentation/ddi0500/j/
#   SHA256: 06004a007e003e7f2b506699b8c65a288ae325147aaba67cc7e4615e3ed21193
#   Note: ARM docs portal; navigate to download PDF.

# [A72TRM]
#   ARM Cortex-A72 MPCore Processor Technical Reference Manual
#   https://developer.arm.com/documentation/100095/latest/
#   SHA256: 47f52c93806507962c2cd0b77991d7aebacfaae5734ac617fc45a5babdff738f
#   Note: ARM docs portal; navigate to download PDF.

# [ARMV8]
#   ARM Architecture Reference Manual for A-profile architecture
#   DDI0487
#   https://developer.arm.com/documentation/ddi0487/latest/
#   SHA256: f02558906617a5df49a77f5f991e93d671fd16aba12623cfdd319038afbbbba7
#   Note: ARM docs portal; navigate to download PDF.

# [BCM2711]
#   Broadcom BCM2711 ARM Peripherals
#   https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf
#   SHA256: d6e16ea089a1716e80621f99a26e130a2379f0a81d945dc22e4f80dc49dcdc78

# [BCM2836]
#   BCM2836 ARM Local Peripherals (QA7 rev3.4)
#   https://datasheets.raspberrypi.com/bcm2836/bcm2836-peripherals.pdf
#   SHA256: 8eae4db439d768de5b069900c1e5040607cb54704d063b39802dac185ffafad2

# [BCM2837]
#   Broadcom BCM2837 ARM Peripherals (unofficial; not maintained by Broadcom)
#   https://cs140e.sergio.bz/docs/BCM2837-ARM-Peripherals.pdf
#   SHA256: 278287cc6dd871362b98b338e692de370dbb725ceea7ace54ba0a1b14cb98f7b

# [GIC400]
#   ARM GIC-400 Generic Interrupt Controller Technical Reference Manual
#   DDI0471B, r0p1
#   https://developer.arm.com/documentation/ddi0471/b/
#   SHA256: 15463e9ac6c82114378b4dc7cee1fb4eaa545f4b5073af4bf8a57d22b9403c52
#   Note: ARM docs portal; navigate to download PDF.

# [GICv2]
#   ARM Generic Interrupt Controller Architecture Specification
#   IHI0048B, v2.0
#   https://developer.arm.com/documentation/ihi0048/b/
#   SHA256: ab1874e354b3ca1c522ea0f53f8cb6174b6caeff1e4d055dcdf18bca5bc20ce1
#   Note: ARM docs portal; navigate to download PDF.

# [HID]
#   USB Device Class Definition for Human Interface Devices (HID)
#   Revision 1.11, June 2001 (USB-IF)
#   https://www.usb.org/sites/default/files/hid1_11.pdf
#   SHA256: 206272dacaf01ff34beda038b8ed59abbb02f028394896345c393bc026795d36

# [HUT]
#   HID Usage Tables for Universal Serial Bus (USB)
#   Revision 1.5, January 2024 (USB-IF)
#   https://www.usb.org/sites/default/files/hut1_5.pdf
#   SHA256: f4ead217b01134f89199155ed616d4eeae9ad40a5f73dad9544002b592c07db3

# [PCIE]
#   PCI Express Base Specification
#   Revision 5.0, 2019 (PCI-SIG)
#   https://pcisig.com/specifications
#   SHA256: 3ed091683ce8eb8ebcf1aba2b490b1545aea55e0102086a6c424db9129955ae8
#   Note: PCI-SIG membership required for download.
#   Note: BCM2711 / VL805 hardware is PCIe Gen 2; config space register definitions
#   referenced here are backward compatible and unchanged since PCIe 1.0.

# [USB2]
#   Universal Serial Bus Specification
#   Revision 2.0, April 2000 (USB-IF)
#   https://www.usb.org/sites/default/files/usb_20_20250603.zip
#   SHA256: d39698a33486c399124af92bd02e4f978fd9a836b5cf4e52e6e4633eb1d89f61
#   Note: ZIP archive; the main spec is "usb_20.pdf" within. SHA256 is of the PDF, not the ZIP.

# [USB3]
#   Universal Serial Bus 3.2 Specification
#   Revision 1.1, June 2022 (USB-IF) -- supersedes USB 3.0/3.1
#   https://www.usb.org/sites/default/files/usb_32_202206_0.zip
#   SHA256: 26e025a56ce0352f4f91fcaaca67b622d8e9e030ca429804bf7da98f52e674fd
#   Note: ZIP archive; the main spec is "USB 3.2 Revision 1.1.pdf" within. SHA256 is of the PDF, not the ZIP.

# [XHCI]
#   eXtensible Host Controller Interface for Universal Serial Bus (xHCI)
#   Revision 1.2, May 2019 (Intel)
#   https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/extensible-host-controler-interface-usb-xhci.pdf
#   SHA256: 9257ca24f34bff08e6020623f707c788ca0f0df657aa713309ff489a68b1731e
