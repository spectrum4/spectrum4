.text
.align 2
# ----------------------
# Temporary colour items
# ----------------------
# This subroutine copies the permanent colour items to the temporary ones.
#
# On entry:
# On exit:
#
#   If Channel K (bit 0 of TV_FLAG is set):
#     [ATTR_T] = [BORDCR]
#     [MASK_T] = 0
#     [P_FLAG] : temp bits set to zero
#     w0 = new [P_FLAG]
#     w1 = [BORDCR]
#
#   If Channel S (bit 0 of TV_FLAG is clear):
#     [ATTR_T] = [ATTR_P]
#     [MASK_T] = [MASK_P]
#     [P_FLAG] : perm copied to temp bits
#     w0 = new [P_FLAG]
#     w1 = ([MASK_P] << 8) | [ATTR_P]
#     w2 = [P_FLAG] with temp bits copied from perm bits; perm bits cleared
temps:                                   // L0D4D
  ldrb    w0, [x28, P_FLAG-sysvars]               // w0 = [P_FLAG]
  and     w0, w0, 0xaaaaaaaa                      // w0 = [P_FLAG] with temp bits cleared, perm bits unaltered
  ldrb    w1, [x28, TV_FLAG-sysvars]              // w1 = [TV_FLAG]
  tbnz    w1, #0, 1f                              // If lower screen in use, jump forward to 1:.
  // Upper screen in use.
  ldrh    w1, [x28, ATTR_P-sysvars]               // w1[0-7] = [ATTR_P]
                                                  // w1[8-15] = [MASK_P]
  lsr     w2, w0, #1                              // w2 = [P_FLAG] with temp bits copied from perm bits; perm bits cleared
  orr     w0, w2, w0                              // w0 = [P_FLAG] with temp bits copied from perm bits; perm bits unaltered
  b       2f                                      // Jump ahead to 2:.
1:
  // Lower screen in use.
  ldrb    w1, [x28, BORDCR-sysvars]               // w1[0-7] = [BORDCR]
                                                  // w1[8-15] = 0
2:
  strh    w1, [x28, ATTR_T-sysvars]               // [ATTR_T] = w1[0-7] =
                                                  //    if upper screen: [ATTR_P]
                                                  //    if lower screen: [BORDCR]
                                                  // [MASK_T] = w1[8-15] =
                                                  //    if upper screen: [MASK_P]
                                                  //    if lower screen: 0
  strb    w0, [x28, P_FLAG-sysvars]               // [P_FLAG] =
                                                  //    if upper screen: perm flags unaltered, temp flags copied from perm
                                                  //    if lower screen: perm flags unaltered, temp flags cleared
  ret
