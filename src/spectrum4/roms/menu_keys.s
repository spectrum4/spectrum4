// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 1


// Menu Keys Action Table
// Equivalent to rom0.s L2577.
//
// Compact table format: .hword count, off0..offN-1; .byte key0..keyN-1
// Each offset is (handler - table) / 4, as a signed halfword.
// Handler address = table + offset * 4.
menu_keys_table:
  .hword 4                                        // Number of entries
  .hword (menu_up - menu_keys_table) / 4          // Cursor Up handler offset
  .hword (menu_down - menu_keys_table) / 4        // Cursor Down handler offset
  .hword (menu_select - menu_keys_table) / 4      // Edit (= menu select) handler offset
  .hword (menu_select - menu_keys_table) / 4      // Enter (= menu select) handler offset
  .byte 0x0b                                      // Cursor Up
  .byte 0x0a                                      // Cursor Down
  .byte 0x07                                      // Edit (= menu select)
  .byte 0x0d                                      // Enter (= menu select)
