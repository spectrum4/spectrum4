/*
 * This file is part of the Spectrum +4 Project.
 * Licencing information can be found in the LICENCE file
 * (C) 2021 Spectrum +4 Authors. All rights reserved.
 */

#include "pci.h"

int pci_host_probe(struct pci_host_bridge *bridge) {
  struct pci_bus *bus, *child;
  int ret;
  ret = pci_scan_root_bus_bridge(bridge);
  if (ret < 0) {
    /*
        dev_err(bridge->dev.parent, "Scanning root bridge failed");
    */
    return ret;
  }

  bus = bridge->bus;

  /*
   * We insert PCI resources into the iomem_resource and
   * ioport_resource trees in either pci_bus_claim_resources()
   * or pci_bus_assign_resources().
   */
  /*
    if (pci_has_flag(PCI_PROBE_ONLY)) {
      pci_bus_claim_resources(bus);
    } else {
      pci_bus_size_bridges(bus);
      pci_bus_assign_resources(bus);

      list_for_each_entry(child, &bus->children, node)
          pcie_bus_configure_settings(child);
    }

    pci_bus_add_devices(bus);
  */
  return 0;
}

int pci_scan_root_bus_bridge(struct pci_host_bridge *bridge) {
  /*
    struct resource_entry *window;
    bool found = false;
    struct pci_bus *b;
    int max, bus, ret;

    if (!bridge)
      return -EINVAL;

    resource_list_for_each_entry(
        window, &bridge->windows) if (window->res->flags & IORESOURCE_BUS) {
      bridge->busnr = window->res->start;
      found = true;
      break;
    }

    ret = pci_register_host_bridge(bridge);
    if (ret < 0)
      return ret;

    b = bridge->bus;
    bus = bridge->busnr;

    if (!found) {
                    dev_info(&b->dev,
                     "No busn resource found for root bus, will use [bus
       %02x-ff]\n", bus); pci_bus_insert_busn_res(b, bus, 255);
    }

    max = pci_scan_child_bus(b);

    if (!found)
      pci_bus_update_busn_res_end(b, max);

  */
  return 0;
}
