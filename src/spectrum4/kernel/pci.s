# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

# pci_bus
#   0x00-0x07: parent


# On entry:
#   x0 = pci_bus address
#   x1 = devfn
#   x2 = where (pci reg offset)
#
# On exit:
#
# Based on:
#   https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L707-L722
.align 2
brcm_pcie_map_conf:


# On entry:
#   x0 = bus data address
#   x1 = devfn
#   x2 = where (pci reg offset)
#   x3 = size
#   w4 = val
#
# On return:
#
# Based on https://github.com/raspberrypi/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/access.c#L77-L96
pci_generic_config_read:




