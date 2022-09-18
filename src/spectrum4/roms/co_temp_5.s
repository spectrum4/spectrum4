.text
.align 2

# -------------------------------------------------------------------------
#
#         {fl}{br}{   paper   }{  ink    }    The temporary colour attributes
#          ___ ___ ___ ___ ___ ___ ___ ___    system variable.
# ATTR_T  |   |   |   |   |   |   |   |   |
#         |   |   |   |   |   |   |   |   |
#         |___|___|___|___|___|___|___|___|
#           7   6   5   4   3   2   1   0
#
#
#         {fl}{br}{   paper   }{  ink    }    The temporary mask used for
#          ___ ___ ___ ___ ___ ___ ___ ___    transparent colours. Any bit
# MASK_T  |   |   |   |   |   |   |   |   |   that is 1 shows that the
#         |   |   |   |   |   |   |   |   |   corresponding attribute is
#         |___|___|___|___|___|___|___|___|   taken not from ATTR-T but from
#           7   6   5   4   3   2   1   0     what is already on the screen.
#
#
#         {paper9 }{ ink9 }{ inv1 }{ over1}   The print flags. Even bits are
#          ___ ___ ___ ___ ___ ___ ___ ___    temporary flags. The odd bits
# P_FLAG  |   |   |   |   |   |   |   |   |   are the permanent flags.
#         | p | t | p | t | p | t | p | t |
#         |___|___|___|___|___|___|___|___|
#           7   6   5   4   3   2   1   0
#
# -----------------------------------------------------------------------

# ------------------------------------
#  The colour system variable handler.
# ------------------------------------
# This is an exit branch from PO-1-OPER, PO-2-OPER
# w5 holds control character 0x10 (INK) to 0x15 (OVER)
# w0 holds legal/illegal parameter. Legal values are:
#   0-9 for ink/paper
#   0,1 or 8 for bright/flash,
#   0 or 1 for over/inverse.
co_temp_5:                               // L2211
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  cmp     w5, #0x11
  b.ls    1f                                      // handle 0x10 (INK) and 0x11 (PAPER)
  cmp     w5, #0x13
  b.ls    7f                                      // handle 0x12 (FLASH) and 0x13 (BRIGHT)
  // TODO
  // 0x14 (INVERSE)
  // 0x15 (OVER)
  b       9f
// Handle INK (0x10) and PAPER (0x11)
// Zero flag clear for INK, set for PAPER
1:                                       // L2234
  stp     x0, x1, [sp, #-16]!
  stp     x2, x3, [sp, #-16]!
  stp     x4, x5, [sp, #-16]!
  stp     x6, x7, [sp, #-16]!
  mov     w1, #0x38
  mov     w2, #0x07
  lsl     w3, w0, #3                              // w3 holds colour in paper bits (3-5)
  csel    w1, w1, w2, eq                          // w1 = 0x07 (INK) or 0x38 (PAPER)
  csel    w3, w3, w0, eq                          // w3 = colour in bits 0-2 if INK, bits 3-5 if PAPER
  cmp     w0, #0x09
  b.ls    2f
  bl      report_k
  b       9f
2:                                       // L2246
// PAPER 0-9 / INK 0-9
  ldrb    w6, [x28, MASK_T-sysvars]               // w6 = current MASK_T
  ldrb    w4, [x28, P_FLAG-sysvars]               // w4 = current P_FLAG
  add     w7, w1, #0x09                           // w7 = 0x10 (INK) or 0x41 (PAPER)
  bic     w7, w7, #1                              // w7 = 0x10 (INK) or 0x40 (PAPER)
  cmp     w0, #0x08                               // INK 8 / PAPER 8 ?
  b.eq    3f
  ldrb    w2, [x28, ATTR_T-sysvars]
  bic     w2, w2, w1                              // clear bits in ATTR_T for ink or paper
  b.hi    4f                                      // jump ahead if INK 9 / PAPER 9
// INK 0-7 / PAPER 0-7
  orr     w2, w2, w3                              // colour in w2 bits 0-2 (ink) or 3-5 (paper)
  bic     w6, w6, w1                              // clear bits in MASK_T for ink or paper
  bic     w4, w4, w7                              // clear P_FLAG bit 4/6 for INK or PAPER 9
  b       5f
// INK 8 / PAPER 8
3:
  orr     w6, w6, w1                              // set bits in MASK_T for ink or paper
  bic     w4, w4, w7                              // clear P_FLAG bit 4/6 for INK or PAPER 9
  b       6f
// INK 9 / PAPER 9
4:
  orr     w6, w6, w1                              // set bits in MASK_T for ink or paper
  orr     w4, w4, w7                              // set P_FLAG bit 4/6 for INK or PAPER 9
  mvn     w3, w1                                  // invert w1 (0xfffffff8 for INK 9 or 0xffffffc7 for PAPER 9)
  mov     w5, #0x24
  and     w3, w3, w5                              // 0x20 for INK 9 or 0x04 for PAPER 9
  and     w3, w3, w2                              // Leading PAPER bit of ATTR_T in bit 5 if INK 9 or leading INK bit of ATTR_T in bit 2 if PAPER 9
  cmp     w3, wzr
  csel    w3, w1, wzr, eq                         // if leading INK/PAPER bit
  orr     w2, w2, w3
5:
  strb    w2, [x28, ATTR_T-sysvars]
6:
  strb    w6, [x28, MASK_T-sysvars]
  strb    w4, [x28, P_FLAG-sysvars]
  ldp     x6, x7, [sp], #16
  ldp     x4, x5, [sp], #16
  ldp     x2, x3, [sp], #16
  ldp     x0, x1, [sp], #16
  b       9f
// Handle FLASH (0x12) and BRIGHT (0x13)
// Zero flag clear for FLASH, set for BRIGHT
7:                                       // L2273
  mov     w1, #0x40
  mov     x2, #0x80
  csel    w1, w1, w2, eq                          // w1 = 128 (FLASH) or 64 (BRIGHT)
  ldrb    w2, [x28, ATTR_T-sysvars]
  ldrb    w3, [x28, MASK_T-sysvars]
  cmp     w0, #0x01
  b.lo    10f
  b.eq    11f
  cmp     w0, #0x08
  b.eq    12f
  bl      report_k
  b       9f
8:
  strb    w2, [x28, ATTR_T-sysvars]
  strb    w3, [x28, MASK_T-sysvars]
9:
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
// BRIGHT 0 / FLASH 0
10:
  bic     w2, w2, w1
  bic     w3, w3, w1
  b       8b
// BRIGHT 1 / FLASH 1
11:
  orr     w2, w2, w1
  bic     w3, w3, w1
  b       8b
// BRIGHT 8 / FLASH 8
12:
  bic     w2, w2, w1                              // not needed, but consistent with 128K
  orr     w3, w3, w1
  b       8b

report_k:                                // L2244
  ret
