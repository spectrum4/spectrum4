/*
 * This file is part of the Spectrum +4 Project.
 * Licencing information can be found in the LICENCE file
 * (C) 2021 Spectrum +4 Authors. All rights reserved.
 */

extern void pci_log(const char *str);

struct pci_host_bridge {
  /*
    struct device dev;
  */
  struct pci_bus *bus; // Root bus
                       /*
                           struct pci_ops    *ops;
                           struct pci_ops    *child_ops;
                       */
  void *sysdata;
  int busnr;
  int domain_nr;
  /*
    struct list_head windows;                  // resource_entry
    struct list_head dma_ranges;               // dma ranges resource list
    u8 (*swizzle_irq)(struct pci_dev *, u8 *); // Platform IRQ swizzler
    int (*map_irq)(const struct pci_dev *, u8, u8);
    void (*release_fn)(struct pci_host_bridge *);
  */
  void *release_data;
  unsigned int ignore_reset_delay : 1;  // For entire hierarchy
  unsigned int no_ext_tags : 1;         // No Extended Tags
  unsigned int no_inc_mrrs : 1;         // No Increase MRRS
  unsigned int native_aer : 1;          // OS may use PCIe AER
  unsigned int native_pcie_hotplug : 1; // OS may use PCIe hotplug
  unsigned int native_shpc_hotplug : 1; // OS may use SHPC hotplug
  unsigned int native_pme : 1;          // OS may use PCIe PME
  unsigned int native_ltr : 1;          // OS may use PCIe LTR
  unsigned int native_dpc : 1;          // OS may use PCIe DPC
  unsigned int native_cxl_error : 1;    // OS may use CXL RAS//vents
  unsigned int preserve_config : 1;     // Preserve FW resource setup
  unsigned int size_windows : 1;        // Enable root bus sizing
  unsigned int msi_domain : 1;          // Bridge wants MSI domain
                                        /*
                                            // Resource alignment requirements
                                            resource_size_t (*align_resource)(struct pci_dev *dev,
                                                    const struct resource *res,
                                                    resource_size_t start,
                                                    resource_size_t size,
                                                    resource_size_t align);
                                        */
  unsigned long private[];              // ____cacheline_aligned;
};

struct pci_bus {

  /*
    struct list_head node;     // Node in list of buses
    struct pci_bus *parent;    // Parent bus this bridge is on
    struct list_head children; // List of child buses
    struct list_head devices;  // List of devices on this bus
    struct pci_dev *self;      // Bridge device as seen by parent
    struct list_head slots;    // List of slots on this bus;
                               // protected by pci_slot_mutex
    struct resource *resource[PCI_BRIDGE_RESOURCE_NUM];
    struct list_head resources; // Address space routed to this bus
    struct resource busn_res;   // Bus numbers routed to this bus

    struct pci_ops *ops;         // Configuration access functions
  */
  void *sysdata;               // Hook for sys-specific extension
                               /*
                                   struct proc_dir_entry *procdir;    // Directory entry in /proc/bus/pci
                               */
  unsigned char number;        // Bus number
  unsigned char primary;       // Number of primary bridge
  unsigned char max_bus_speed; // enum pci_bus_speed
  unsigned char cur_bus_speed; // enum pci_bus_speed
#ifdef CONFIG_PCI_DOMAINS_GENERIC
  int domain_nr;
#endif

  char name[48];

  unsigned short bridge_ctl; // Manage NO_ISA/FBB/et al behaviors
                             /*
                               pci_bus_flags_t bus_flags; // Inherited by child buses
                               struct device *bridge;
                               struct device dev;
                               struct bin_attribute *legacy_io;  // Legacy I/O for this bus
                               struct bin_attribute *legacy_mem; // Legacy mem
                             */
  unsigned int is_added : 1;
  unsigned int unsafe_warn : 1; // warned about RW1C config write
};

int pci_host_probe(struct pci_host_bridge *bridge);
int pci_scan_root_bus_bridge(struct pci_host_bridge *bridge);
