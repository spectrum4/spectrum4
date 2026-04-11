// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 0


// ------------------------------------------------------------------------------
// HID special-keys table. Scanned by k_decode's special_scan loop before any
// modifier-based dispatch — entries here produce a terminal code regardless
// of modifier state. CapsLock, Tab and Esc are routed to dedicated handlers
// (capslock / gmode_toggle / esc_break) after the match; the rest fall into
// kbd_store. Format: pairs of (HID scancode, terminal code), terminated 0x00.
//
// HID-specific data table — no Z80 equivalent (Z80 uses a fixed matrix scan).
// ------------------------------------------------------------------------------
hid_special_keys:
  .byte 0x29, 0x00                                // Esc -> BREAK (handled specially, code unused)
  .byte 0x2b, 0x0f                                // Tab -> G-mode toggle (handled specially)
  .byte 0x39, 0x06                                // CapsLock -> CAPS LOCK (handled specially)
  .byte 0x3a, 0x04                                // F1 -> TRUE VIDEO
  .byte 0x3b, 0x05                                // F2 -> INV VIDEO
  .byte 0x4c, 0xaa                                // Del -> Delete Right (128K editor action)
  .byte 0x4a, 0xa8                                // Home -> Start of Line
  .byte 0x4d, 0xa7                                // End -> End of Line
  .byte 0x4b, 0xad                                // PgUp -> Ten Rows Up
  .byte 0x4e, 0xac                                // PgDn -> Ten Rows Down
  .byte 0x00                                      // end of table
