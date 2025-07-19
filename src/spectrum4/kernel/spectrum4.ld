/*
 * spectrum4.ld - Linker script for Spectrum4 kernel (pure AArch64 assembly)
 *
 * This file is part of the Spectrum +4 Project.
 * Licencing information can be found in the LICENCE file
 * (C) 2021 Spectrum +4 Authors. All rights reserved.
 */
ENTRY(_start)

SECTIONS
{
  . = 0xfffffff000000000;

  /* --- ASSEMBLY CODE --- */
  .text : ALIGN(0x10) {
    *(.text)
  }

  /* --- STATIC DATA --- */
  .data : ALIGN(0x10) {
    *(.data)
  }

  /* --- KERNEL BSS SECTION --- */
  .bss : ALIGN(0x10) {
    *(.bss)
  }

  /* --- COHERENT DMA SECTION (2MB aligned) ---
   * Normal, Outer Shareable, Non-Cacheable (0x44)
   */
  .bss.coherent : ALIGN(0x200000) {
    *(.bss.coherent)
  }
}
