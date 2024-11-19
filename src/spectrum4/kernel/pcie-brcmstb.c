/*
 * This file is part of the Spectrum +4 Project.
 * Licencing information can be found in the LICENCE file
 * (C) 2021 Spectrum +4 Authors. All rights reserved.
 */

#include "pci.h"

// https://github.com/torvalds/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c

struct pci_host_bridge bridge;

// Line 1250
int brcm_pcie_probe() {
  bridge.bus = 0; // null
  bridge.busnr = 0;
  bridge.domain_nr = 0xffffffff;
  bridge.ignore_reset_delay = 0;
  bridge.no_ext_tags = 0;
  bridge.native_aer = 1;
  bridge.native_pcie_hotplug = 1;
  bridge.native_shpc_hotplug = 1;
  bridge.native_pme = 1;
  bridge.native_ltr = 1;
  bridge.native_dpc = 1;
  bridge.preserve_config = 0;
  bridge.size_windows = 0;
  bridge.msi_domain = 0;
  return pci_host_probe(&bridge);
}
