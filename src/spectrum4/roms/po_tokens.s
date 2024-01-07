# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# -----------------------------------------------------------------------------
# Print BASIC keyword (chars 0xa5-0xff) with possible leading/trailing space(s)
# -----------------------------------------------------------------------------
#
# No leading space for:
#   "RND" | "INKEY$" | "PI" | "FN" | "POINT" | "SCREEN$" | "ATTR" | "AT" | "TAB" | "VAL$" | "CODE"
#   | "VAL" | "LEN" | "SIN" | "COS" | "TAN" | "ASN" | "ACS" | "ATN" | "LN" | "EXP" | "INT" | "SQR"
#   | "SGN" | "ABS" | "PEEK" | "IN" | "USR" | "STR$" | "CHR$" | "NOT" | "BIN" | "<=" | ">=" | "<>"
#
# For all other keywords:
#   Leading space only if bit 0 of FLAGS is clear
#
# Trailing space for all keywords (regardless of bit 0 of FLAGS) except for:
#   "RND" | "INKEY$" | "PI" | "<=" | ">=" | "<>" | "OPEN #" | "CLOSE #"
#
# On entry:
#   w3 = token table index (char-165) (0 to 90)
#   x28 = sysvars
#   [[CURCHL]] = print routine to call
#   ... any settings that routine at [[CURCHL]] requires ...
# On exit:
#   x0 =
#     for keywords  "RND" | "INKEY$" | "PI" | "<=" | ">=" | "<>" | "OPEN #" | "CLOSE #":
#       0x0
#     else:
#       ' '
#   x1 = [[CURCHL]]
#   x4 = first address after zero termination byte of BASIC keyword in token table
#   x5 = x3
#   x6 = last char of keyword (not including the trailing zero byte nor any added trailing space)
#   NZCV =
#     for keywords  "RND" | "INKEY$" | "PI" | "<=" | ">=" | "<>" | "OPEN #" | "CLOSE #":
#       0b1000
#     for "FN":
#       0b0110
#     else:
#       0b0010
po_tokens:                               // L0C10
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  adr     x4, tkn_table                           // Address of table with BASIC keywords
  mov     w5, w3                                  // Tokens use the token table index to determine trailing space
  bl      po_table
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
