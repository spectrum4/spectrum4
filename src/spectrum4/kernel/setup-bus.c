/*
 * This file is part of the Spectrum +4 Project.
 * Licencing information can be found in the LICENCE file
 * (C) 2021 Spectrum +4 Authors. All rights reserved.
 */

#include "pci.h"

// https://github.com/torvalds/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/setup-bus.c

// Line 28
unsigned int pci_flags;

// Line 1337
void pci_bus_size_bridges(struct pci_bus *bus) {
  /*
          __pci_bus_size_bridges(bus, NULL);
  */
}

// Line 1481
void pci_bus_claim_resources(struct pci_bus *b) {
  /*
          pci_bus_allocate_resources(b);
          pci_bus_allocate_dev_resources(b);
  */
}
