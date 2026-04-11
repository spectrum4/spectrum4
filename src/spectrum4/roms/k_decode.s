// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 2


// ==============================================================================
// HID scancode → Spectrum terminal code dispatcher. Entered from k_new
// (roms/k_new.s) after the edge-detect / press-edge arming in xhci.s.
//
// Equivalent to Z80 rom1.s:1485 k_decode. The Z80 version decides by letter vs
// digit and MODE (KLC/E/G) and calls into addit / k_e_let / k_klc_let /
// k_digit / k_gra_dgt / k_klc_dgt. We dispatch by HID scancode range and
// modifier byte (Shift / Ctrl / Alt) and select one of the hid_table_* tables
// via k_look_up, with addit for G-mode letters and k_gra_dgt for G-mode digits.
//
// Z80 k_klc_let / k_klc_dgt are *not* extracted as separate files on spectrum4 —
// the HID approach doesn't have the letter/digit split inside k_decode; all
// non-G-mode scancodes go through the same table_lookup pipeline.
// ==============================================================================


// ------------------------------------------------------------------------------
// Main HID decode entry. On entry, w0 holds the HID scancode, w16 the merged
// L|R modifier byte, w17 the raw HID modifier byte, w18 the full 8-byte HID
// report. Falls through / branches into the rest of the decode pipeline.
// ------------------------------------------------------------------------------
// On entry:
//   w0 = HID scancode (known non-zero, != previous scancode)
//   w16 = merged Ctrl/Shift/Alt modifier bits (bits 0-3)
//   w17 = raw HID modifier byte
//   x28 = sysvars base
// On exit:
//   TODO
k_decode:                                // L0333
  // Range check -- scancodes above 0x65 are keypad/international, not mapped
  cmp     w0, #0x65
  b.hi    kbd_done

  // --- Special keys (modifier-independent) ---
  adr     x3, hid_special_keys


// ------------------------------------------------------------------------------
// Scan the hid_special_keys table for a match. On hit, dispatch to the
// per-key handler (capslock / gmode_toggle / esc_break) or fall through to
// kbd_store for simple codes.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
special_scan:
  ldrb    w1, [x3]
  cbz     w1, special_done                        // end of table, not a special key
  ldrb    w2, [x3, #1]
  add     x3, x3, #2
  cmp     w0, w1
  b.ne    special_scan
  // Match found. capslock / gmode_toggle live in roms/key_m_cl.s (L10DB);
  // esc_break is still in xhci.s as a stub.
  cmp     w0, #0x39                               // CapsLock?
  b.eq    capslock
  cmp     w0, #0x2b                               // Tab?
  b.eq    gmode_toggle
  cmp     w0, #0x29                               // Esc?
  b.eq    esc_break
  b       kbd_store                               // all other special keys: store terminal code


// ------------------------------------------------------------------------------
// Not a special key: check G-mode, then dispatch by modifier.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
special_done:
  ldrb    w1, [x28, MODE-sysvars]
  cmp     w1, #2
  b.eq    gmode_decode


// ------------------------------------------------------------------------------
// Standard (non-G-mode) decoding: Ctrl / Alt / Shift / CapsLock lookup.
// Reached directly when not in G-mode, or as the fall-through from k_gra_dgt
// for keys G-mode does not remap (cursor keys, Enter, Space, Backspace, t-z,
// punctuation) — those keep their normal terminal codes regardless of MODE.
// Equivalent to a fusion of Z80 k_klc_let (L034F) and k_klc_dgt (L039D);
// HID dispatch shape doesn't split letters and digits at this level.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
normal_decode:
  // --- Ctrl modifier check ---
  tst     w16, #0x1                               // Ctrl set?
  b.eq    no_ctrl

  // Ctrl is set. Check if Alt is also set (Alt+Ctrl = e_digits)
  tst     w16, #0x4                               // Alt set?
  b.eq    ctrl_only

  // Alt+Ctrl: scan e_digits keyword table
  adr     x3, hid_altctrl_digits
  b       scan_pair_table


// ------------------------------------------------------------------------------
// Ctrl only: scan editor actions then keyword token tables
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
ctrl_only:
  adr     x3, hid_ctrl_editor
  bl      scan_pair_table_fn
  cbnz    w2, kbd_store                           // found editor action
  adr     x3, hid_ctrl_keywords
  b       scan_pair_table


// ------------------------------------------------------------------------------
// No Ctrl: select lookup table based on Alt/Shift/CapsLock modifiers.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
no_ctrl:
  tst     w16, #0x4                               // Alt set?
  b.eq    no_alt
  tst     w16, #0x2                               // Shift set?
  b.eq    alt_only
  adr     x3, hid_table_altshift                  // Alt+Shift
  b       k_look_up


// ------------------------------------------------------------------------------
// Alt only: use Alt (E-mode unshifted) lookup table.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
alt_only:
  adr     x3, hid_table_alt
  b       k_look_up


// ------------------------------------------------------------------------------
// No Alt: check Shift and CapsLock to select plain or shift table.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
no_alt:
  tst     w16, #0x2                               // Shift set?
  b.eq    no_shift

  // Shift is set. Check CAPS LOCK -- Shift+CapsLock+letter = lowercase
  ldrb    w1, [x28, FLAGS2-sysvars]
  tbz     w1, #3, shift_no_caps                   // CAPS LOCK off, normal shift
  cmp     w0, #0x04
  b.lo    shift_no_caps                           // not a letter
  cmp     w0, #0x1d
  b.hi    shift_no_caps                           // not a letter
  adr     x3, hid_table_plain                     // Shift+CapsLock+letter = lowercase
  b       k_look_up


// ------------------------------------------------------------------------------
// Shift without CapsLock (or non-letter key): use shift lookup table.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
shift_no_caps:
  adr     x3, hid_table_shift
  b       k_look_up


// ------------------------------------------------------------------------------
// No Shift: check CapsLock for letter keys, otherwise use plain table.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
no_shift:
  ldrb    w1, [x28, FLAGS2-sysvars]
  tbz     w1, #3, plain                           // CAPS LOCK off
  cmp     w0, #0x04
  b.lo    plain                                   // not a letter
  cmp     w0, #0x1d
  b.hi    plain                                   // not a letter
  adr     x3, hid_table_shift                     // CapsLock+letter = uppercase
  b       k_look_up


// ------------------------------------------------------------------------------
// No modifiers active: use plain (unshifted) lookup table.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
plain:
  adr     x3, hid_table_plain
  b       k_look_up


// ------------------------------------------------------------------------------
// G-mode dispatch: letters a-s → UDG (addit), digits 1-8 → block graphic
// (k_gra_dgt), digits 0/9 → DELETE/GRAPHICS. Letters t-z and everything else
// fall through to normal_decode via k_gra_dgt.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
gmode_decode:
  // Letters a-s (scancodes 0x04-0x16): go to addit (→ UDG)
  sub     w1, w0, #0x04
  cmp     w1, #19
  b.lo    addit                                   // w0-0x04 < 19 → letter a-s
  b       k_gra_dgt                               // otherwise: digit / passthrough


// ==============================================================================
// Pair-table scan helpers. HID-specific — no Z80 equivalent (Z80 uses fixed
// contiguous tables, not sparse pair lists).
// ==============================================================================


// ------------------------------------------------------------------------------
// Callable scan: returns w2 = terminal code, or 0 if not found.
// Used by ctrl_only to probe hid_ctrl_editor before falling back to keywords.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
scan_pair_table_fn:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
// ------------------------------------------------------------------------------
// TODO: Description
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
scan_pair_loop_fn:
  ldrb    w1, [x3]
  cbz     w1, scan_pair_notfound_fn
  ldrb    w2, [x3, #1]
  add     x3, x3, #2
  cmp     w0, w1
  b.ne    scan_pair_loop_fn
  ldp     x29, x30, [sp], #0x10
  ret


// ------------------------------------------------------------------------------
// Callable scan: no match found.
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
scan_pair_notfound_fn:
  mov     w2, #0
  ldp     x29, x30, [sp], #0x10
  ret


// ------------------------------------------------------------------------------
// Tail-branch scan: on match, go to kbd_store; on miss, go to kbd_done.
// Used by terminal branches of normal_decode (altctrl, ctrl keywords).
// ------------------------------------------------------------------------------
scan_pair_table:
  ldrb    w1, [x3]
  cbz     w1, kbd_done
  ldrb    w2, [x3, #1]
  add     x3, x3, #2
  cmp     w0, w1
  b.ne    scan_pair_table
  b       kbd_store
