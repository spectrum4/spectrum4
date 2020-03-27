/*
 * This file is part of the Spectrum +4 Project.
 * Licencing information can be found in the LICENCE file
 * (C) 2019 Spectrum +4 Authors. All rights reserved.
 */
SECTIONS
{
  /*
   * Start address of the kernel.
   *
   * The GPU firmware by default loads kernel8.img at address 0x80000, and
   * therefore we set the start address to this location.
   *
   * If we wanted to load and execute the A64 kernel code directly at RAM
   * address 0, we would need to tell start.elf not populate ATAGs and to use
   * address 0x0, which could be done with the two following settings in
   * config.txt:
   *
   *   disable_commandline_tags=1
   *   kernel_old=1
   */
  . = 0x80000;


  /*
   * Executable code.
   *
   * All text segments are copied here. The first .text segment included by all.s
   * starts with the `_start` function, which is the entry point to the kernel.
   */
  .text :
  {
    *(.text)
  }


  /*
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


  /*
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


  /*
   * The lowest allowed address for the tip of the (downwards-growing) stack.
   *
   * Matches the RAM drive end.
   */
  stack_lower_bound = .;
}
