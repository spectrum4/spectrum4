# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

# This file is auto-generated by test_po_tokens.sh. DO NOT EDIT!


.text



# This test prints char 0xfd (BASIC keyword "CLEAR") to printer with bit 0 of
# [FLAGS] set to 0 (leading space _not_ suppressed) using a mock print-out
# routine that doesn't disturb any registers. Expected output is " CLEAR ".

print_token_udg_patch_02_setup:
  _setbit 1, 0x5001                       ; printer in use
  _strb   0xe3, 0x5000 + 0x45             ; P_POSN_X read from (IY + 0x45)
  _strh   0x3713, PR_CC
  jp      fake0

print_token_udg_patch_02_setup_regs:
  ld      a, 0xfd
  ld      iy, 0x5000
  ret

print_token_udg_patch_02_effects:
  ld      de, msg_print_token_udg_patch_02
  call    print_msg_de
  ret

print_token_udg_patch_02_effects_regs:
  ld      a, ' '
  ld      c, 0xe3
  ld      d, 0xfd-0xa5
  ld      e, X3_FLAG | N_FLAG
  ld      hl, 0x3713
  ldf     H_FLAG
  ret

msg_print_token_udg_patch_02: .asciz " CLEAR "




# This test prints char 0xa3 (BASIC keyword "SPECTRUM" when in 128K mode) to
# printer with bit 0 of [FLAGS] set to 0 (leading space _not_ suppressed) using a
# mock print-out routine that doesn't disturb any registers. Expected output is
# " SPECTRUM ".

print_token_udg_patch_03_setup:
  _setbit 1, 0x5001                       ; printer in use
  _setbit 4, 0x5001                       ; 128K mode - SPECTRUM keyword not UDG 'T'
  jp      fake0

print_token_udg_patch_03_setup_regs:
  ld      a, 0xa3
  ld      iy, 0x5000
  ret

print_token_udg_patch_03_effects:
  ld      de, msg_print_token_udg_patch_03
  call    print_msg_de
  ret

print_token_udg_patch_03_effects_regs:
  ldf     C_FLAG | H_FLAG
  ld      a, ' '
  ld      d, 4
  ld      e, Z_FLAG | N_FLAG
  ret

msg_print_token_udg_patch_03: .asciz " SPECTRUM "


# This test prints char 0xa4 (BASIC keyword "PLAY" when in 128K mode) to upper
# screen with bit 0 of [FLAGS] set to 1 (leading space suppressed) using a mock
# print-out routine that doesn't disturb any registers. Expected output is
# "PLAY ".

print_token_udg_patch_04_setup:
  _resbit 1, 0x5001                       ; print to screen
  _setbit 4, 0x5001                       ; 128K mode - SPECTRUM keyword not UDG 'T'
  _resbit 0, 0x5002                       ; print to upper screen
  _strb   0x34, S_POSN_Y
  _strb   0x12, S_POSN_X
  _strh   0x2345, DF_CC
  jp      fake1

print_token_udg_patch_04_setup_regs:
  ld      a, 0xa4
  ld      iy, 0x5000
  ret

print_token_udg_patch_04_effects:
  ld      de, msg_print_token_udg_patch_04
  call    print_msg_de
  ret

print_token_udg_patch_04_effects_regs:
  ldf     PV_FLAG | H_FLAG | Z_FLAG | C_FLAG
  ld      a, ' '
  ld      b, 0x34
  ld      c, 0x12
  ld      d, 4
  ld      e, N_FLAG
  ld      hl, 0x2345
  ret

msg_print_token_udg_patch_04: .asciz "PLAY "