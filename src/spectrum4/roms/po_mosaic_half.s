.text
.align 2
# --------------------------------
# Generate half a mosaic character
# --------------------------------
# The 16 2*2 mosaic characters 128-143 are formed from bits 0-3 of the
# character number. For example, char 134 (0b10000110) is:
#
#   0b1111111100000000
#   0b1111111100000000
#   0b1111111100000000
#   0b1111111100000000
#   0b1111111100000000  <bit 1> <bit 0>
#   0b1111111100000000
#   0b1111111100000000
#   0b1111111100000000
#   0b0000000011111111
#   0b0000000011111111
#   0b0000000011111111
#   0b0000000011111111
#   0b0000000011111111  <bit 3> <bit 2>
#   0b0000000011111111
#   0b0000000011111111
#   0b0000000011111111
#
# This routine generates either the top or bottom half of the character.
# Each half is comprised of 16 bytes (8 pixel rows; 2 bytes per row).
# It shifts w3 two bits right after processing bits 0 and 1, so that it
# can be called twice in succession to generate top half from bits 0/1
# and then the bottom half from bits 2/3.
#
# On entry:
#   w3 = LHS in bit 1, RHS in bit 0
#   x6 = address to write bit pattern to
# On exit:
#   [x6] = 16 byte pattern
#   w3 = input w3 shifted right two bits
#   x4 = last 8 bytes of bit pattern (same as first 8 bytes)
#   x5 = last 8 bytes of bit pattern with character right hand side bits cleared.
#   x6 += 16
#   NZCV =
#     if entry w3 bit 1 set:
#       0b0000
#     if entry w3 bit 1 clear:
#       0b0100
po_mosaic_half:                          // L0B3E
  mov     x4, 0x00ff00ff00ff00ff                  // Pattern for first 4 pixel rows if bit 0 set.
  tst     w3, #1                                  // Is bit 0 of w3 set?
  csel    x4, x4, xzr, ne                         // If so, use prepared bit 0 pattern, otherwise clear bits.
  mov     x5, 0xff00ff00ff00ff00                  // Pattern for first 4 pixel rows if bit 1 set.
  tst     w3, #2                                  // Is bit 1 of w3 set?
  csel    x5, x5, xzr, ne                         // If so, use prepared bit 1 pattern, otherwise clear bits.
  orr     x4, x4, x5                              // Merge results for bit 0 and bit 1.
  str     x4, [x6], #8                            // Write first four rows.
  str     x4, [x6], #8                            // Write second four rows (same as first four rows).
  lsr     w3, w3, #2                              // Shift w3 two bits, so next call will consider bits 2/3
                                                  // for lower half of mosaic character instead of bits 0/1
                                                  // for upper half of mosaic character.
  ret
