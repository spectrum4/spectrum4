// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 2


// ------------------------------------------------------------------------------
// G-mode letter → UDG. Called from k_decode's G-mode branch when the scancode
// is a letter (HID 0x04-0x16 = a-s, 19 keys).
//
// Equivalent to Z80 rom1.s:1502 addit. The Z80 version does `add a, 0x4f`
// (matrix code 0x41 = 'A' → 0x90 = UDG A). On spectrum4 we work from a HID
// scancode offset so the arithmetic is `0x90 + (scancode - 0x04)` = UDG code.
// ------------------------------------------------------------------------------
// On entry:
//   w0 = HID scancode (in range 0x04-0x16, letters a-s)
//   x28 = sysvars base
// On exit:
//   w1, w2 corrupted
//   w2 = UDG terminal code (0x90-0xa2)
//   branches to kbd_store
addit:                                   // L033E
  sub     w1, w0, #0x04
  add     w2, w1, #0x90                           // UDG code = 0x90 + (scancode - 0x04)
  b       kbd_store
