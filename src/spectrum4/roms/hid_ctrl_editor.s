// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 0


// ------------------------------------------------------------------------------
// Ctrl+key -> 128K editor action. Probed first when Ctrl is held (before the
// keyword-token fallback in hid_ctrl_keywords). Terminal codes in the 0xa0-0xb4
// range are intercepted by the 128K editor action table; see
// project_keyboard_mapping_table.md §7.
// Format: pairs of (HID scancode, terminal code), terminated by 0x00.
//
// HID-specific data table — no Z80 equivalent.
// ------------------------------------------------------------------------------
hid_ctrl_editor:
  .byte 0x50, 0xaf                                // Ctrl+Left -> Word Left
  .byte 0x4f, 0xae                                // Ctrl+Right -> Word Right
  .byte 0x4a, 0xa6                                // Ctrl+Home -> Top of Program
  .byte 0x4d, 0xa5                                // Ctrl+End -> End of Program
  .byte 0x2a, 0xb4                                // Ctrl+Backspace -> Delete Word Left
  .byte 0x4c, 0xb3                                // Ctrl+Del -> Delete Word Right
  .byte 0x0e, 0xb0                                // Ctrl+K -> Delete to EOL
  .byte 0x18, 0xb1                                // Ctrl+U -> Delete to SOL
  .byte 0x00                                      // end of table
