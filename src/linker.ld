SECTIONS
{
  /**
   * Start address of the kernel.
   *
   * We can place executable code directly at RAM address 0 and tell start.elf
   * not to populate any ATAGs. Note, this requires the following two settings
   * in config.txt:
   *
   *   disable_commandline_tags=1
   *   kernel_old=1
   *
   * Technically, we don't need to explicitly include this line below, since by
   * default the start address is already 0x0, but it makes the linker script a
   * little more explicit, and simplifies relocation to a different address if
   * wanted later.
   *
   * Without the above config.txt settings, the aarch64 kernel image would be
   * loaded at address 0x80000, in which case we would need to set to 0x80000
   * here instead of 0x0.
   */
  . = 0x80000;


  /**
   * Executable code.
   *
   * All text segments are copied here. The first .text segment included by all.s
   * starts with the `_start` function, which is the entry point to the kernel.
   */
  .text :
  {
    *(.text)
  }


  /**
   * Global variables that are initialised to non-zero values.
   *
   * All .data segments are copied here.
   *
   * Uncomment this line to align the data section to a 4K page boundary.
   *
   *   . = ALIGN(0x1000);
   */
  .data :
  {
    *(.data)
  }


  /**
   * Global variables that are initialised to zero.
   *
   * All .bss segments are copied here.
   */
  .bss :
  {
    bss_begin = .;
    *(.bss*)
    bss_end = .;
  }


  /**
   * The lowest allowed address for the tip of the (downwards-growing) stack.
   *
   * Matches the RAM drive end.
   */
  stack_lower_bound = .;
}
