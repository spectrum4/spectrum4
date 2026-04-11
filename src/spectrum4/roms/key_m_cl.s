// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 2


// ------------------------------------------------------------------------------
// CAPS LOCK and mode-toggle handlers.
//
// On the Z80 (rom1.s:6148 key_m_cl) this is a dispatcher invoked by L367F for
// any key code in the range 0x06-0x0f: it handles CAPS LOCK (0x06), E-mode
// enter (0x0e) and G-mode enter (0x0f) internally — without signalling a new
// key to the editor — and returns control codes 0x07-0x0d through unchanged.
//
// On spectrum4 the equivalent dispatch is done via HID scancode matches in
// handle_keyboard_input (xhci.s), which branches directly to capslock or
// gmode_toggle below. Each handler toggles the relevant sysvar and then
// emits the original Spectrum terminal code through k_end (via the xhci.s
// kbd_store wrapper, which falls through to kbd_done). The `key_m_cl:`
// label is kept as an empty entry point for Z80 parity only; there is no
// code body because nothing calls key_m_cl directly on our side.
// On entry (all sub-routines):
//   x28 = sysvars base
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
key_m_cl:                                         // L10DB  -- Z80 dispatcher entry; no body on spectrum4
// ------------------------------------------------------------------------------
// TODO: Description
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
capslock:                                         // toggles FLAGS2 bit 3
  ldrb    w1, [x28, FLAGS2-sysvars]
  eor     w1, w1, #0x08                           // toggle CAPS LOCK bit
  strb    w1, [x28, FLAGS2-sysvars]
  mov     w2, #0x06                               // terminal code for CAPS LOCK
  b       kbd_store


// ------------------------------------------------------------------------------
// Toggle G-mode (MODE between 0 and 2) and emit terminal code 0x0f.
// Equivalent to the code-0x0f branch of Z80 key_m_cl (rom1.s:6165-6175).
// ------------------------------------------------------------------------------
// On entry:
//   TODO
// On exit:
//   TODO
gmode_toggle:
  ldrb    w1, [x28, MODE-sysvars]
  cmp     w1, #2
  mov     w3, #2
  csel    w1, wzr, w3, eq                         // if MODE==2, set 0; else set 2
  strb    w1, [x28, MODE-sysvars]
  mov     w2, #0x0f                               // terminal code for G-mode toggle
  b       kbd_store
