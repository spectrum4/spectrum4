.text

# -----------------------------
# Menu Sinclair Stripes Bitmaps
# -----------------------------
# Bit-patterns for the Sinclair stripes used on the menus.
.align 1
sinclair_stripes:                        // L3802

# 0x20 - Character: ' '          CHR$(32)

  _hwordbe  0b0000000000000001
  _hwordbe  0b0000000000000011
  _hwordbe  0b0000000000000111
  _hwordbe  0b0000000000001111
  _hwordbe  0b0000000000011111
  _hwordbe  0b0000000000111111
  _hwordbe  0b0000000001111111
  _hwordbe  0b0000000011111111
  _hwordbe  0b0000000111111111
  _hwordbe  0b0000001111111111
  _hwordbe  0b0000011111111111
  _hwordbe  0b0000111111111111
  _hwordbe  0b0001111111111111
  _hwordbe  0b0011111111111111
  _hwordbe  0b0111111111111111
  _hwordbe  0b1111111111111111

# 0x21 - Character: '!'          CHR$(33)

  _hwordbe  0b1111111111111110
  _hwordbe  0b1111111111111100
  _hwordbe  0b1111111111111000
  _hwordbe  0b1111111111110000
  _hwordbe  0b1111111111100000
  _hwordbe  0b1111111111000000
  _hwordbe  0b1111111110000000
  _hwordbe  0b1111111100000000
  _hwordbe  0b1111111000000000
  _hwordbe  0b1111110000000000
  _hwordbe  0b1111100000000000
  _hwordbe  0b1111000000000000
  _hwordbe  0b1110000000000000
  _hwordbe  0b1100000000000000
  _hwordbe  0b1000000000000000
  _hwordbe  0b0000000000000000


# -----------------------
# Sinclair Stripes 'Text'
# -----------------------
# CHARS points to RAM at $5A98, and characters ' ' and '!' redefined
# as the Sinclair strips using the bit patterns above.
.align 0
sinclair_stripes_text:                   // L3812
  .byte 0x10, 0x02, ' '                           // INK 2;
  .byte 0x11, 0x06, '!'                           // PAPER 6;
  .byte 0x10, 0x04, ' '                           // INK 4;
  .byte 0x11, 0x05, '!'                           // PAPER 5;
  .byte 0x10, 0x00, ' '                           // INK 0;
  .byte 0xff


# --------------------------------------
# Print the Sinclair stripes on the menu
# --------------------------------------
.align 2
print_sinclair_stripes:                  // L3822
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  ldr     x2, [x28, CHARS-sysvars]
  adr     x0, sinclair_stripes-32*32
  str     x0, [x28, CHARS-sysvars]
  adr     x4, sinclair_stripes_text
  bl      print_str_ff
  str     x2, [x28, CHARS-sysvars]
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret
