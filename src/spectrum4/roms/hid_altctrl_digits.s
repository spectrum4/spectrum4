// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 0


// ------------------------------------------------------------------------------
// Alt+Ctrl+digit -> e_digits keywords (E-mode SS+digit, 48K only). Used by
// k_decode's normal_decode path when both Ctrl and Alt modifiers are held.
// HID scancodes: 0x1e=1, 0x1f=2, ..., 0x26=9, 0x27=0.
// Format: pairs of (HID scancode, terminal code), terminated by 0x00.
//
// HID-specific data table — analogue of Z80 e_digits (rom1.s:1090).
// ------------------------------------------------------------------------------
hid_altctrl_digits:
  .byte 0x27, 0xd0                                // Alt+Ctrl+0 -> FORMAT
  .byte 0x1e, 0xce                                // Alt+Ctrl+1 -> DEF FN
  .byte 0x1f, 0xa8                                // Alt+Ctrl+2 -> FN
  .byte 0x20, 0xca                                // Alt+Ctrl+3 -> LINE
  .byte 0x21, 0xd3                                // Alt+Ctrl+4 -> OPEN #
  .byte 0x22, 0xd4                                // Alt+Ctrl+5 -> CLOSE #
  .byte 0x23, 0xd1                                // Alt+Ctrl+6 -> MOVE
  .byte 0x24, 0xd2                                // Alt+Ctrl+7 -> ERASE
  .byte 0x25, 0xa9                                // Alt+Ctrl+8 -> POINT
  .byte 0x26, 0xcf                                // Alt+Ctrl+9 -> CAT
  .byte 0x00                                      // end of table
