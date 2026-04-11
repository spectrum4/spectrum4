// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 2


// ------------------------------------------------------------------------------
// Look up terminal code by HID scancode in one of the hid_table_* tables.
// The caller has selected the appropriate table (based on modifier state)
// and placed its address in x3.
//
// Equivalent to Z80 rom1.s:1519 k_look_up. The Z80 version indexes with DE
// (main-key value) into tables like sym_codes / e_unshift / ext_shift / etc.
// We index with the HID scancode (in w0) into the HID-specific tables.
// ------------------------------------------------------------------------------
// On entry:
//   w0 = HID scancode (0x00-0x65)
//   x3 = selected lookup table base
//   x28 = sysvars base
// On exit:
//   w2 = terminal code from table[scancode], or falls to kbd_done if unmapped (0x00)
//   falls through to kbd_store (to deliver w2) on a mapped entry
k_look_up:                               // L034A
  ldrb    w2, [x3, x0]                            // w2 = terminal code from table[scancode]
  cbz     w2, kbd_done                            // 0x00 = unmapped
  b       kbd_store
