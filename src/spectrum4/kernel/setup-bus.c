/*
 * This file is part of the Spectrum +4 Project.
 * Licencing information can be found in the LICENCE file
 * (C) 2021 Spectrum +4 Authors. All rights reserved.
 */

#include "pci.h"

// https://github.com/torvalds/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/setup-bus.c

// Line 28
unsigned int pci_flags;

// Line 178
static void __dev_sort_resources(struct pci_dev *dev, struct list_head *head) {
  u16 class = dev->class >> 8;

  /* Don't touch classless devices or host bridges or IOAPICs */
  if (class == PCI_CLASS_NOT_DEFINED || class == PCI_CLASS_BRIDGE_HOST)
    return;

  /* Don't touch IOAPIC devices already enabled by firmware */
  if (class == PCI_CLASS_SYSTEM_PIC) {
    u16 command;
    pci_read_config_word(dev, PCI_COMMAND, &command);
    if (command & (PCI_COMMAND_IO | PCI_COMMAND_MEMORY))
      return;
  }

  pdev_sort_resources(dev, head);
}

// Line 493
static void pbus_assign_resources_sorted(const struct pci_bus *bus,
                                         struct list_head *realloc_head,
                                         struct list_head *fail_head) {
  struct pci_dev *dev;
  LIST_HEAD(head);

  for (dev = (struct pci_dev *)bus->devices.next;
       &dev->bus_list != &bus->devices;
       dev = (struct pci_dev *)(dev)->bus_list.next)
    __dev_sort_resources(dev, &head);

  __assign_resources_sorted(&head, realloc_head, fail_head);
}

// Line 1337
void pci_bus_size_bridges(struct pci_bus *bus) {
  /*
          __pci_bus_size_bridges(bus, NULL);
  */
}

// Line 1379
void __pci_bus_assign_resources(const struct pci_bus *bus,
                                struct list_head *realloc_head,
                                struct list_head *fail_head) {
  struct pci_bus *b;
  struct pci_dev *dev;

  pbus_assign_resources_sorted(bus, realloc_head, fail_head);

  list_for_each_entry(dev, &bus->devices, bus_list) {
    pdev_assign_fixed_resources(dev);

    b = dev->subordinate;
    if (!b)
      continue;

    __pci_bus_assign_resources(b, realloc_head, fail_head);

    switch (dev->hdr_type) {
    case PCI_HEADER_TYPE_BRIDGE:
      if (!pci_is_enabled(dev))
        pci_setup_bridge(b);
      break;

    case PCI_HEADER_TYPE_CARDBUS:
      pci_setup_cardbus(b);
      break;

    default:
      pci_info(dev, "not setting up bridge for bus %04x:%02x\n",
               pci_domain_nr(b), b->number);
      break;
    }
  }
}

// Line 1415
void pci_bus_assign_resources(const struct pci_bus *bus) {
  __pci_bus_assign_resources(bus, NULL, NULL);
}

// Line 1481
void pci_bus_claim_resources(struct pci_bus *b) {
  /*
          pci_bus_allocate_resources(b);
          pci_bus_allocate_dev_resources(b);
  */
}
