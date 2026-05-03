/*
 * spectrum4.ld - Linker script for Spectrum4 kernel (pure AArch64 assembly)
 *
 * This file is part of the Spectrum +4 Project.
 * Licencing information can be found in the LICENCE file
 * (C) 2021-2026 Spectrum +4 Authors. All rights reserved.
 *
 * Output sections use C-identifier names (no leading dot) so that GNU ld
 * automatically provides `__start_<name>` and `__stop_<name>` boundary symbols
 * for each one. The test harness uses these symbols directly to junk-fill and
 * snapshot whole sections without needing manually-inserted boundary labels.
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

  /* --- ROM-OWNED BSS ---
   * Sysvars and small ROM-managed buffers
   */
  bss_roms : ALIGN(0x1000) {
    *(bss_roms)
    . = ALIGN(0x10);                    /* keep __stop_bss_roms 16-byte aligned for the 8-byte snapshot/fill loops */
  }

  /* --- KERNEL-OWNED BSS ---
   * Persistent runtime state owned by hardware abstractions that live outside
   * the ROM (xHCI rings, page tables).
   */
  bss_kernel : ALIGN(0x10) {
    *(bss_kernel)
  }

  /* --- USER HEAP ---
   * ram_disk + heap. Sized via RAM_DISK_SIZE / HEAP_SIZE per target — large in
   * release (256 MB each), small in tests/debug.
   */
  bss_userheap : ALIGN(0x10) {
    *(bss_userheap)
  }

  /* --- COHERENT DMA SECTION (2MB aligned) ---
   * Normal, Outer Shareable, Non-Cacheable (0x44)
   */
  bss_coherent : ALIGN(0x200000) {
    *(bss_coherent)
  }

  /* --- TEST-ONLY .text ---
   * only present in tests build - for test harness and unit tests
   */
  text_tests : ALIGN(0x1000) {
    *(text_tests)
    . = ALIGN(0x10);                    /* keep __stop_text_tests 16-byte aligned for the 8-byte snapshot loop */
  }

  /* --- TEST-ONLY BSS ---
   * Test harness state (memory_dumps, rand_data, etc.)
   */
  bss_tests : ALIGN(0x10) {
    *(bss_tests)
  }
}
