// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 0


// ------------------------------------------------------------------------------
// HID → Spectrum terminal code table for Alt+Shift modifier (E-mode CS —
// red keywords, 48K only). Letters map to ext_shift table keyword tokens.
// Symbols with native RPi 400 keys are UNMAPPED (0x00) per one-way principle
// (enter via native key only). Unmapped: A(~), D(\), F({), G(}), S(|), U(]), Y([).
// Digits map to INK colour codes (0x18-0x1f) and FLASH attribute codes (0x00-0x01).
// NOTE: Alt+Shift+8 = FLASH off = 0x00 collides with "unmapped" sentinel.
// Acceptable: 128K rejects these. Fix when 48K mode is implemented.
//
// HID-specific data table — analogue of Z80 ext_shift (rom1.s:1013).
// ------------------------------------------------------------------------------
hid_table_altshift:
//       +0    +1    +2    +3    +4    +5    +6    +7    +8    +9    +A    +B    +C    +D    +E    +F
  .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0xdc, 0xda, 0x00, 0xb7, 0x00, 0x00, 0xd8, 0xbf, 0xae, 0xaa, 0xab
                                                  // 0x00: (reserved x4), -,BRIGHT,PAPER,-,ATN,-,-,CIRCLE,IN,VAL$,SCREEN$,ATTR
  .byte 0xdd, 0xde, 0xdf, 0x7f, 0xb5, 0xd6, 0x00, 0xd5, 0x00, 0xdb, 0xb6, 0xd9, 0x00, 0xd7, 0x19, 0x1a
                                                  // 0x10: INVERSE,OVER,OUT,(C),ASN,VERIFY,-,MERGE,-,FLASH,ACS,INK(kw),-,BEEP, INK1,INK2
  .byte 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x18, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
                                                  // 0x20: INK3-7,INK0,FLASHoff,FLASHon, (rest unmapped)
  .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
                                                  // 0x30
  .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
                                                  // 0x40
  .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
                                                  // 0x50
  .byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00        // 0x60
