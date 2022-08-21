.text
.align 2

# -------------------------------------------------------------------------
#
#         {fl}{br}{   paper   }{  ink    }    The temporary colour attributes
#          ___ ___ ___ ___ ___ ___ ___ ___    system variable.
# ATTR_T  |   |   |   |   |   |   |   |   |
#         |   |   |   |   |   |   |   |   |
# 23695   |___|___|___|___|___|___|___|___|
#           7   6   5   4   3   2   1   0
#
#
#         {fl}{br}{   paper   }{  ink    }    The temporary mask used for
#          ___ ___ ___ ___ ___ ___ ___ ___    transparent colours. Any bit
# MASK_T  |   |   |   |   |   |   |   |   |   that is 1 shows that the
#         |   |   |   |   |   |   |   |   |   corresponding attribute is
# 23696   |___|___|___|___|___|___|___|___|   taken not from ATTR-T but from
#           7   6   5   4   3   2   1   0     what is already on the screen.
#
#
#         {paper9 }{ ink9 }{ inv1 }{ over1}   The print flags. Even bits are
#          ___ ___ ___ ___ ___ ___ ___ ___    temporary flags. The odd bits
# P_FLAG  |   |   |   |   |   |   |   |   |   are the permanent flags.
#         | p | t | p | t | p | t | p | t |
# 23697   |___|___|___|___|___|___|___|___|
#           7   6   5   4   3   2   1   0
#
# -----------------------------------------------------------------------

# ------------------------------------
#  The colour system variable handler.
# ------------------------------------
# This is an exit branch from PO-1-OPER, PO-2-OPER
# w5 holds control character 0x10 (INK) to 0x$15 (OVER)
# w0 holds legal/illegal parameter. Legal values are:
#   0-9 for ink/paper
#   0,1 or 8 for bright/flash,
#   0 or 1 for over/inverse.
co_temp_5:                               // L2211
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  cmp     w5, #0x11
  b.ls    co_temp_7                               // handle 0x10 (INK) and 0x11 (PAPER)
  cmp     w5, #0x13
  b.ls    co_temp_c                               // handle 0x12 (FLASH) and 0x13 (BRIGHT)
  // TODO
  b       1f
co_temp_7:
  // TODO
  b       1f
co_temp_c:
  mov     w1, #0x40
  mov     x2, #0x80
  csel    w1, w1, w2, eq                          // w1 = 128 (FLASH) or 64 (BRIGHT)
  ldrb    w2, [x28, ATTR_T-sysvars]
  ldrb    w3, [x28, MASK_T-sysvars]
  cmp     w0, #0x01
  b.lo    3f
  b.eq    4f
  cmp     w0, #0x08
  b.eq    5f
  bl      report_k
  b       2f
1:
  strb    w2, [x28, ATTR_T-sysvars]
  strb    w3, [x28, MASK_T-sysvars]
2:
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
// BRIGHT 0 / FLASH 0
3:
  bic     w2, w2, w1
  bic     w3, w3, w1
  b       1b
// BRIGHT 0 / FLASH 0
4:
  orr     w2, w2, w1
  bic     w3, w3, w1
  b       1b
// BRIGHT 8 / FLASH 8
5:
  bic     w2, w2, w1                              // not needed, but consistent with 128K
  orr     w3, w3, w1
  b       1b

report_k:
  ret
