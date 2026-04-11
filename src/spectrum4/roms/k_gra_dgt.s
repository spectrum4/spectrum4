// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 2


// ------------------------------------------------------------------------------
// G-mode digit decode.
//
// Digit keys 1-8 produce block graphics (0x80-0x8f). Digit 9 produces the
// GRAPHICS toggle code (0x0f). Digit 0 produces DELETE (0x0c). Any other
// scancode (cursor keys, letters t-z, Enter, Space, etc.) falls through
// via normal_decode — see project_menu_mode_divergence.md for rationale.
//
// Equivalent to Z80 rom1.s:1601 k_gra_dgt. The Z80 version indexes into
// ctl_codes for '9' and '0', and applies AND 0x07 + 0x80 + optional XOR 0x0f
// for digits 1-8. We do the same arithmetic on the HID scancode range
// (0x1e-0x27 = digits 1,2,3,4,5,6,7,8,9,0).
// ------------------------------------------------------------------------------
// On entry:
//   w0 = HID scancode (known non-letter, non-a-s)
//   w16 bit 1 = Shift modifier state (inverts block graphic)
//   x28 = sysvars base
// On exit:
//   w1, w2 corrupted
//   w2 = block graphic / DELETE / GRAPHICS terminal code
//   branches to kbd_store on a mapped key, or normal_decode for unmapped
k_gra_dgt:                               // L0389
  // Digit 0 (scancode 0x27) -> DELETE (0x0c)
  cmp     w0, #0x27
  b.eq    gmode_zero
  // Digit 9 (scancode 0x26) -> GRAPHICS toggle (0x0f)
  cmp     w0, #0x26
  b.eq    gmode_nine
  // Digits 1-8 (scancodes 0x1e-0x25) -> block graphics
  // Digit value = scancode - 0x1d (digit 1->1, ..., 8->8)
  // Block graphic = (digit_value AND 0x07) + 0x80
  //   digit 1->0x81, 2->0x82, ..., 7->0x87, 8->0x80
  sub     w1, w0, #0x1d
  cmp     w1, #9
  b.hs    normal_decode                           // not a G-mode-remapped key, decode normally (cursor keys, Enter, t-z, etc.)
  and     w1, w1, #0x07
  add     w2, w1, #0x80
  // Shift inverts the block (XOR 0x0f)
  tst     w16, #0x2
  b.eq    kbd_store
  eor     w2, w2, #0x0f
  b       kbd_store


// ------------------------------------------------------------------------------
// G-mode digit 0 -> DELETE (0x0c). Subordinate label of k_gra_dgt.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
gmode_zero:
  mov     w2, #0x0c
  b       kbd_store


// ------------------------------------------------------------------------------
// G-mode digit 9 -> GRAPHICS (0x0f), handled by key_m_cl to toggle MODE.
// Subordinate label of k_gra_dgt.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
gmode_nine:
  mov     w2, #0x0f
  b       kbd_store
