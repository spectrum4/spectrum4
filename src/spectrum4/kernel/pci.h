/*
 * This file is part of the Spectrum +4 Project.
 * Licencing information can be found in the LICENCE file
 * (C) 2021 Spectrum +4 Authors. All rights reserved.
 */

// https://github.com/torvalds/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/include/linux/pci.h

extern void pci_log(const char *str);

typedef __signed__ char __s8;
typedef unsigned char __u8;

typedef __signed__ short __s16;
typedef unsigned short __u16;

typedef __signed__ int __s32;
typedef unsigned int __u32;

__extension__ typedef __signed__ long long __s64;
__extension__ typedef unsigned long long __u64;

typedef __s8 s8;
typedef __u8 u8;
typedef __s16 s16;
typedef __u16 u16;
typedef __s32 s32;
typedef __u32 u32;
typedef __s64 s64;
typedef __u64 u64;

// general purpose, from e.g. include/linux/types.h
struct list_head {
  struct list_head *next, *prev;
};

#define LIST_HEAD_INIT(name)                                                   \
  { &(name), &(name) }

#define LIST_HEAD(name) struct list_head name = LIST_HEAD_INIT(name)

// # 33 "./include/linux/list.h"
/**
 * INIT_LIST_HEAD - Initialize a list_head structure
 * @list: list_head structure to be initialized.
 *
 * Initializes the list_head to point to itself.  If it is a list header,
 * the result is an empty list.
 */
static inline void INIT_LIST_HEAD(struct list_head *list) {
  list->next = list;
  list->prev = list;
}

// # 63 "./include/linux/list.h"
/*
 * Insert a new entry between two known consecutive entries.
 *
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 */
static inline void __list_add(struct list_head *new, struct list_head *prev,
                              struct list_head *next) {
  next->prev = new;
  new->next = next;
  new->prev = prev;
  prev->next = new;
}

// # 98 "./include/linux/list.h"
/**
 * list_add_tail - add a new entry
 * @new: new entry to be added
 * @head: list head to add it before
 *
 * Insert a new entry before the specified head.
 * This is useful for implementing queues.
 */
static inline void list_add_tail(struct list_head *new,
                                 struct list_head *head) {
  __list_add(new, head->prev, head);
}

// For simplicity, this has been embedded directly from:
// https://github.com/torvalds/linux/blob/14b35093ca68bf2c81bbc90aace5007142b40b40/drivers/pci/controller/pcie-brcmstb.c#L280-L300
struct brcm_pcie {
  /*
          struct device		*dev;
  */
  void *base;
  /*
          struct clk		*clk;
          struct device_node	*np;
  bool ssc;
  bool l1ss;
  */
  int gen;
  /*
          u64			msi_target_addr;
          struct brcm_msi		*msi;
  */
  const int *reg_offsets;
  /*
          enum pcie_type		type;
          struct reset_control	*rescal;
          struct reset_control	*perst_reset;
  */
  int num_memc;
  /*
          u64			memc_size[PCIE_BRCM_MAX_MEMC];
          u32			hw_rev;
          void			(*perst_set)(struct brcm_pcie *pcie, u32 val);
          void			(*bridge_sw_init_set)(struct brcm_pcie *pcie,
     u32 val);
  */
};

// Line 312
/* The pci_dev structure describes PCI devices */
struct pci_dev {
  struct list_head bus_list;   /* Node in per-bus list */
  struct pci_bus *bus;         /* Bus this device is on */
  struct pci_bus *subordinate; /* Bus this device bridges to */

  void *sysdata; /* Hook for sys-specific extension */
  // 	struct proc_dir_entry *procent;	/* Device entry in /proc/bus/pci */
  // 	struct pci_slot	*slot;		/* Physical slot this device is in */

  unsigned int devfn; /* Encoded device & function index */
  unsigned short vendor;
  unsigned short device;
  unsigned short subsystem_vendor;
  unsigned short subsystem_device;
  unsigned int class; /* 3 bytes: (base,sub,prog-if) */
  u8 revision;        /* PCI revision, low byte of class word
// */
  u8 hdr_type;        /* PCI header type (`multi' flag
// masked out) */
  //  #ifdef CONFIG_PCIEAER u16 aer_cap;
  // /* AER capability offset */ 	struct aer_stats *aer_stats;	/* AER
  // stats for this device */ #endif #ifdef CONFIG_PCIEPORTBUS 	struct rcec_ea
  // *rcec_ea;
  // /* RCEC cached endpoint association */ 	struct pci_dev  *rcec; /*
  // Associated RCEC device */ #endif 	u32		devcap;		/* PCIe
  // Device Capabilities */ 	u8		pcie_cap;	/* PCIe
  // capability offset */ 	u8		msi_cap;	/* MSI
  // capability offset */ 	u8 msix_cap;	/* MSI-X capability offset */
  // u8		pcie_mpss:3;
  // /* PCIe Max Payload Size Supported */ 	u8		rom_base_reg;
  // /* Config register controlling ROM */ 	u8		pin;
  // /* Interrupt pin this device uses */ 	u16		pcie_flags_reg;
  // /* Cached PCIe Capabilities Register */ 	unsigned long
  // *dma_alias_mask;/* Mask of enabled devfn aliases */

  // 	struct pci_driver *driver;	/* Driver bound to this device */
  // 	u64		dma_mask;	/* Mask of the bits of bus address this
  // 					   device implements.  Normally this is
  // 					   0xffffffff.  You only need to change
  // 					   this if your device has broken DMA
  // 					   or supports 64-bit transfers.  */

  // 	struct device_dma_parameters dma_parms;

  // 	pci_power_t	current_state;	/* Current operating state. In ACPI,
  // 					   this is D0-D3, D0 being fully
  // 					   functional, and D3 being off. */
  // 	unsigned int	imm_ready:1;	/* Supports Immediate Readiness */
  // 	u8		pm_cap;		/* PM capability offset */
  // 	unsigned int	pme_support:5;	/* Bitmask of states from which PME#
  // 					   can be generated */
  // 	unsigned int	pme_poll:1;	/* Poll device's PME status bit */
  // 	unsigned int	d1_support:1;	/* Low power state D1 is supported */
  // 	unsigned int	d2_support:1;	/* Low power state D2 is supported */
  // 	unsigned int	no_d1d2:1;	/* D1 and D2 are forbidden */
  // 	unsigned int	no_d3cold:1;	/* D3cold is forbidden */
  // 	unsigned int	bridge_d3:1;	/* Allow D3 for bridge */
  // 	unsigned int	d3cold_allowed:1;	/* D3cold is allowed by user */
  // 	unsigned int	mmio_always_on:1;	/* Disallow turning off io/mem
  // 						   decoding during BAR sizing */
  // 	unsigned int	wakeup_prepared:1;
  // 	unsigned int	runtime_d3cold:1;	/* Whether go through runtime
  // 						   D3cold, not set for devices
  // 						   powered on/off by the
  // 						   corresponding bridge */
  // 	unsigned int	skip_bus_pm:1;	/* Internal: Skip bus-level PM */
  // 	unsigned int	ignore_hotplug:1;	/* Ignore hotplug events */
  // 	unsigned int	hotplug_user_indicators:1; /* SlotCtl indicators
  // 						      controlled exclusively by
  // 						      user sysfs */
  // 	unsigned int	clear_retrain_link:1;	/* Need to clear Retrain Link
  // 						   bit manually */
  // 	unsigned int	d3hot_delay;	/* D3hot->D0 transition time in ms */
  // 	unsigned int	d3cold_delay;	/* D3cold->D0 transition time in ms */

  // #ifdef CONFIG_PCIEASPM
  // 	struct pcie_link_state	*link_state;	/* ASPM link state */
  // 	unsigned int	ltr_path:1;	/* Latency Tolerance Reporting
  // 					   supported from root to here */
  // 	u16		l1ss;		/* L1SS Capability pointer */
  // #endif
  // 	unsigned int	pasid_no_tlp:1;		/* PASID works without TLP
  // Prefix */ 	unsigned int	eetlp_prefix_path:1;	/* End-to-End TLP Prefix
  // */

  // 	pci_channel_state_t error_state;	/* Current connectivity state */
  // 	struct device	dev;			/* Generic device interface */

  // 	int		cfg_size;		/* Size of config space */

  // 	/*
  // 	 * Instead of touching interrupt line and base address registers
  // 	 * directly, use the values stored here. They might be different!
  // 	 */
  // 	unsigned int	irq;
  // 	struct resource resource[DEVICE_COUNT_RESOURCE]; /* I/O and memory
  // regions + expansion ROMs */

  // 	bool		match_driver;		/* Skip attaching driver */

  // 	unsigned int	transparent:1;		/* Subtractive decode bridge */
  // 	unsigned int	io_window:1;		/* Bridge has I/O window */
  // 	unsigned int	pref_window:1;		/* Bridge has pref mem window */
  // 	unsigned int	pref_64_window:1;	/* Pref mem window is 64-bit */
  // 	unsigned int	multifunction:1;	/* Multi-function device */

  // 	unsigned int	is_busmaster:1;		/* Is busmaster */
  // 	unsigned int	no_msi:1;		/* May not use MSI */
  // 	unsigned int	no_64bit_msi:1;		/* May only use 32-bit MSIs */
  // 	unsigned int	block_cfg_access:1;	/* Config space access blocked
  // */ 	unsigned int	broken_parity_status:1;	/* Generates false
  // positive parity */ 	unsigned int	irq_reroute_variant:2;	/* Needs
  // IRQ rerouting variant */ 	unsigned int	msi_enabled:1; 	unsigned int
  // msix_enabled:1; 	unsigned int	ari_enabled:1;		/* ARI
  // forwarding */ 	unsigned int	ats_enabled:1;		/* Address
  // Translation Svc */ 	unsigned int	pasid_enabled:1;	/*
  // Process Address Space ID */ 	unsigned int	pri_enabled:1;
  // /* Page Request Interface */ 	unsigned int	is_managed:1; 	unsigned
  // int needs_freset:1;		/* Requires fundamental reset */
  // unsigned int state_saved:1; 	unsigned int	is_physfn:1; 	unsigned
  // int is_virtfn:1; 	unsigned int	is_hotplug_bridge:1; 	unsigned int
  // shpc_managed:1;		/* SHPC owned by shpchp */ 	unsigned int
  // is_thunderbolt:1;	/* Thunderbolt controller */
  // 	/*
  // 	 * Devices marked being untrusted are the ones that can potentially
  // 	 * execute DMA attacks and similar. They are typically connected
  // 	 * through external ports such as Thunderbolt but not limited to
  // 	 * that. When an IOMMU is enabled they should be getting full
  // 	 * mappings to make sure they cannot access arbitrary memory.
  // 	 */
  // 	unsigned int	untrusted:1;
  // 	/*
  // 	 * Info from the platform, e.g., ACPI or device tree, may mark a
  // 	 * device as "external-facing".  An external-facing device is
  // 	 * itself internal but devices downstream from it are external.
  // 	 */
  // 	unsigned int	external_facing:1;
  // 	unsigned int	broken_intx_masking:1;	/* INTx masking can't be used */
  // 	unsigned int	io_window_1k:1;		/* Intel bridge 1K I/O windows
  // */ 	unsigned int	irq_managed:1; 	unsigned int
  // non_compliant_bars:1;
  // /* Broken BARs; ignore them */ 	unsigned int	is_probed:1;
  // /* Device probing in progress */ 	unsigned int
  // link_active_reporting:1;/* Device capable of reporting link active */
  // 	unsigned int	no_vf_scan:1;		/* Don't scan for VFs after IOV
  // enablement */ 	unsigned int	no_command_memory:1;	/* No
  // PCI_COMMAND_MEMORY
  // */ 	pci_dev_flags_t dev_flags; 	atomic_t	enable_cnt;
  // /* pci_enable_device has been called */

  // 	u32		saved_config_space[16]; /* Config space saved at suspend
  // time */ 	struct hlist_head saved_cap_space; 	int
  // rom_attr_enabled;	/* Display of ROM attribute enabled? */ 	struct
  // bin_attribute *res_attr[DEVICE_COUNT_RESOURCE]; /* sysfs file for resources
  // */ 	struct bin_attribute *res_attr_wc[DEVICE_COUNT_RESOURCE]; /*
  // sysfs file for WC mapping of resources */

  // #ifdef CONFIG_HOTPLUG_PCI_PCIE
  // 	unsigned int	broken_cmd_compl:1;	/* No compl for some cmds */
  // #endif
  // #ifdef CONFIG_PCIE_PTM
  // 	unsigned int	ptm_root:1;
  // 	unsigned int	ptm_enabled:1;
  // 	u8		ptm_granularity;
  // #endif
  // #ifdef CONFIG_PCI_MSI
  // 	const struct attribute_group **msi_irq_groups;
  // #endif
  // 	struct pci_vpd	vpd;
  // #ifdef CONFIG_PCIE_DPC
  // 	u16		dpc_cap;
  // 	unsigned int	dpc_rp_extensions:1;
  // 	u8		dpc_rp_log_size;
  // #endif
  // #ifdef CONFIG_PCI_ATS
  // 	union {
  // 		struct pci_sriov	*sriov;		/* PF: SR-IOV info */
  // 		struct pci_dev		*physfn;	/* VF: related PF */
  // 	};
  // 	u16		ats_cap;	/* ATS Capability offset */
  // 	u8		ats_stu;	/* ATS Smallest Translation Unit */
  // #endif
  // #ifdef CONFIG_PCI_PRI
  // 	u16		pri_cap;	/* PRI Capability offset */
  // 	u32		pri_reqs_alloc; /* Number of PRI requests allocated */
  // 	unsigned int	pasid_required:1; /* PRG Response PASID Required */
  // #endif
  // #ifdef CONFIG_PCI_PASID
  // 	u16		pasid_cap;	/* PASID Capability offset */
  // 	u16		pasid_features;
  // #endif
  // #ifdef CONFIG_PCI_P2PDMA
  // 	struct pci_p2pdma __rcu *p2pdma;
  // #endif
  // 	u16		acs_cap;	/* ACS Capability offset */
  // 	phys_addr_t	rom;		/* Physical address if not from BAR */
  // 	size_t		romlen;		/* Length if not from BAR */
  // 	char		*driver_override; /* Driver name to force a match */

  // 	unsigned long	priv_flags;	/* Private flags for the PCI driver */

  // 	/* These methods index pci_reset_fn_methods[] */
  // 	u8 reset_methods[PCI_NUM_RESET_METHODS]; /* In priority order */
};

// Line 544
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
  unsigned int native_aer : 1;          // OS may use PCIe AER
  unsigned int native_pcie_hotplug : 1; // OS may use PCIe hotplug
  unsigned int native_shpc_hotplug : 1; // OS may use SHPC hotplug
  unsigned int native_pme : 1;          // OS may use PCIe PME
  unsigned int native_ltr : 1;          // OS may use PCIe LTR
  unsigned int native_dpc : 1;          // OS may use PCIe DPC
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
  struct brcm_pcie pcie; // For simplicity, this has been embedded directly
};

// Line 626
struct pci_bus {
  struct list_head node;     // Node in list of buses
  struct pci_bus *parent;    // Parent bus this bridge is on
  struct list_head children; // List of child buses
  struct list_head devices;  // List of devices on this bus
  /*
  struct pci_dev *self;      // Bridge device as seen by parent
  struct list_head slots;    // List of slots on this bus;
                             // protected by pci_slot_mutex
  struct resource *resource[PCI_BRIDGE_RESOURCE_NUM];
  */
  struct list_head resources; // Address space routed to this bus
  /*
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
  int domain_nr;
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

// Line 1065
enum {
  PCI_REASSIGN_ALL_RSRC = 0x00000001,   /* Ignore firmware setup */
  PCI_REASSIGN_ALL_BUS = 0x00000002,    /* Reassign all bus numbers */
  PCI_PROBE_ONLY = 0x00000004,          /* Use existing setup */
  PCI_CAN_SKIP_ISA_ALIGN = 0x00000008,  /* Don't do ISA alignment */
  PCI_ENABLE_PROC_DOMAINS = 0x00000010, /* Enable domains in /proc */
  PCI_COMPAT_DOMAIN_0 = 0x00000020,     /* ... except domain 0 */
  PCI_SCAN_ALL_PCIE_DEVS = 0x00000040,  /* Scan all, not just dev 0 */
};

// Line 1032
void pcie_bus_configure_settings(struct pci_bus *bus);
// Line 1077
void pci_bus_add_devices(const struct pci_bus *bus);
// Line 1082
int pci_host_probe(struct pci_host_bridge *bridge);
// Line 1085
extern unsigned int pci_flags;
// Line 1089
int pci_scan_root_bus_bridge(struct pci_host_bridge *bridge);
// Line 1458
void pci_bus_claim_resources(struct pci_bus *bus);
// Line 1459
void pci_bus_size_bridges(struct pci_bus *bus);
