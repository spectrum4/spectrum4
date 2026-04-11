// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 2


// ------------------------------------------------------------------------------
// Process Key Press
// Handle key presses for menus and the Editor.
// Uses compact table-driven dispatch: handler = table + offset * 4, where each
// offset is a signed halfword. Saves 6 bytes per entry vs 8-byte addresses, and
// the search loop is reusable across menu keys (L2577) and editing keys (L2537).
// Equivalent to rom0.s L2669 + L3FCE.
// ------------------------------------------------------------------------------
// On entry:
//   w0 = key code
//   x28 = sysvars base
// On exit:
//   register values depend on key hander routines called
process_key:                             // L2669
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp

  // Check if menu is displayed
  ldrb    w1, [x28, EC0D-sysvars]
  tbz     w1, #1, 3f                              // bit 1 clear = no menu, editor path (not yet implemented)

  // Menu is displayed, search menu keys table
  adr     x1, menu_keys_table

  // Search key action table at x1 and call matched handler.
  // Table format: .hword count, off0..offN-1; .byte key0..keyN-1
  // Each offset is (handler - table) / 4, as a signed halfword.
  ldrh    w2, [x1]                                // w2 = number of entries
  add     x3, x1, #2                              // x3 = offsets array (halfword entries)
  add     x4, x3, x2, lsl #1                      // x4 = codes array (past offsets)
  mov     w5, #0                                  // w5 = index
  1:
    cbz     w2, 3f                                // no more entries, no match
    ldrb    w6, [x4, x5]                          // w6 = key code from table
    cmp     w0, w6
    b.eq    2f                                    // match found
    add     w5, w5, #1
    sub     w2, w2, #1
    b       1b
2:
  // Match found: handler = table + offset * 4
  ldrsh   x6, [x3, x5, lsl #1]                    // x6 = signed halfword offset
  add     x6, x1, x6, lsl #2                      // x6 = handler address
  blr     x6
3:
  ldp     x29, x30, [sp], #0x10
  ret
