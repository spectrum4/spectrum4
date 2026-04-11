// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 0


// ------------------------------------------------------------------------------
// Ctrl+letter -> SYMBOL SHIFT keyword tokens (48K only, 11 entries). Probed
// after hid_ctrl_editor in k_decode's ctrl_only branch.
// Format: pairs of (HID scancode, terminal code), terminated by 0x00.
//
// HID-specific data table — analogue of Z80 sym_codes keyword entries (rom1.s:1059).
// ------------------------------------------------------------------------------
hid_ctrl_keywords:
  .byte 0x04, 0xe2                                // Ctrl+A -> STOP
  .byte 0x07, 0xcd                                // Ctrl+D -> STEP
  .byte 0x08, 0xc8                                // Ctrl+E -> >=
  .byte 0x09, 0xcc                                // Ctrl+F -> TO
  .byte 0x0a, 0xcb                                // Ctrl+G -> THEN
  .byte 0x0c, 0xac                                // Ctrl+I -> AT
  .byte 0x14, 0xc7                                // Ctrl+Q -> <=
  .byte 0x16, 0xc3                                // Ctrl+S -> NOT
  .byte 0x18, 0xc5                                // Ctrl+U -> OR
  .byte 0x1a, 0xc9                                // Ctrl+W -> <>
  .byte 0x1c, 0xc6                                // Ctrl+Y -> AND
  .byte 0x00                                      // end of table
