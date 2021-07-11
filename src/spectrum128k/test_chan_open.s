# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text

# TODO: We only test opening configured streams (i.e. where the entry in STRMS is
# not 0x0000), since the ROM 1 error handler routine does not appear to return
# normally, but instead rewrites the stack and (I believe) returns to a location
# defined under the rewritten stack. It might be possible to add tests once I've
# understood the stack-rewriting mechanism, by putting an appropriate return
# address (or addresses) on the new stack, so that the CALL to chan_open returns
# to the address after the CALL instruction, with the same stack it entered with.

# Address to place CHANS data - on fresh boot this would be 0x5cb6, but the user
# is free to relocate this data and update [CHANS] to the new location.
.set MY_CHANS, 0x7000

# Copy default STRMS and CHANS from ROM to RAM
test_chan_open_init:
  ld      hl, init_strm
  ld      de, STRMS
  ld      bc, 0x000e
  ldir
  ld      hl, init_chan
  ld      de, MY_CHANS
  ld      bc, 0x0015
  ld      (CHANS), de
  ldir
  ret



chan_open_minus_01_setup:
  jp      test_chan_open_init

chan_open_minus_01_setup_regs:
  ld      a, 0xff
  ret

chan_open_minus_01_effects:
  _strh   MY_CHANS + 5*2, CURCHL          ; Current channel is 'R'
  _resbit 4, FLAGS2                       ; K channel not in use
  ret

chan_open_minus_01_effects_regs:
  ld      a, 0
  ld      c, 'R'
  ld      de, 0x0a
  ld      hl, 0x1633
  ldf     Z_FLAG|H_FLAG|PV_FLAG
  ret



chan_open_00_setup:
  _strb   0x03, BORDCR
  _strb   0xa6, P_FLAG
  jp      test_chan_open_init

chan_open_00_setup_regs:
  ld      a, 0x00
  ret

chan_open_00_effects:
  _strh   MY_CHANS, CURCHL                ; Current channel is keyboard
  _resbit 1, FLAGS                        ; Printer not in use
  _resbit 5, FLAGS                        ; No new key
  _setbit 4, FLAGS2                       ; K channel in use
  _setbit 0, TV_FLAG                      ; Lower screen in use
  _strb   0x03, ATTR_T                    ; [BORDCR]
  _strb   0x00, MASK_T
  _strb   0xa2, P_FLAG
  ret

chan_open_00_effects_regs:
  ld      a, 0xa2                         ; [P_FLAG]
  ld      c, 'K'                          ; Key for chn-cd-lu table
  ld      de, 0x06                        ; chn-cd-lu entry for channel K
  ld      hl, P_FLAG
  ldf     S_FLAG|X5_FLAG
  ret



chan_open_01_setup:
  _strb   0x03, BORDCR
  _strb   0xa6, P_FLAG
  jp      test_chan_open_init

chan_open_01_setup_regs:
  ld      a, 0x01
  ret

chan_open_01_effects:
  _strh   MY_CHANS, CURCHL                ; Current channel is keyboard
  _resbit 1, FLAGS                        ; Printer not in use
  _resbit 5, FLAGS                        ; No new key
  _setbit 4, FLAGS2                       ; K channel in use
  _setbit 0, TV_FLAG                      ; Lower screen in use
  _strb   0x03, ATTR_T                    ; [BORDCR]
  _strb   0x00, MASK_T
  _strb   0xa2, P_FLAG
  ret

chan_open_01_effects_regs:
  ld      a, 0xa2                         ; [P_FLAG]
  ld      c, 'K'                          ; Key for chn-cd-lu table
  ld      de, 0x06                        ; chn-cd-lu entry for channel K
  ld      hl, P_FLAG
  ldf     S_FLAG|X5_FLAG
  ret



chan_open_02_setup:
  _strb   0xa6, P_FLAG
  _strb   0x57, ATTR_P
  _strb   0x23, MASK_P
  jp      test_chan_open_init

chan_open_02_setup_regs:
  ld      a, 0x02
  ret

chan_open_02_effects:
  _strh   MY_CHANS + 5*1, CURCHL          ; Current channel is screen
  _resbit 1, FLAGS                        ; Printer not in use
  _resbit 4, FLAGS2                       ; K channel not in use
  _resbit 0, TV_FLAG                      ; Main screen in use
  _strb   0x57, ATTR_T                    ; [ATTR_P]
  _strb   0x23, MASK_T                    ; [MASK_P]
  _strb   0xf3, P_FLAG                    ; Perm bits copied to temp bits?
  ret

chan_open_02_effects_regs:
  ld      a, 0xf3                         ; [P_FLAG]
  ld      c, 'S'                          ; Key for chn-cd-lu table
  ld      de, 0x12                        ; chn-cd-lu entry for channel S?
  ld      hl, P_FLAG
  ldf     S_FLAG|X5_FLAG|PV_FLAG
  ret



chan_open_03_setup:
  jp      test_chan_open_init

chan_open_03_setup_regs:
  ld      a, 0x03
  ret

chan_open_03_effects:
  _strh   MY_CHANS + 5*3, CURCHL          ; Current channel is printer
  _setbit 1, FLAGS                        ; Printer in use
  _resbit 4, FLAGS2                       ; K channel not in use
  ret

chan_open_03_effects_regs:
  ld      a, 'P'                          ; Key found in chn-cd-lu, so A=C
  ld      c, 'P'                          ; Key for chn-cd-lu table
  ld      de, 0x1b                        ; chn-cd-lu entry for channel P
  ld      hl, chan_p                      ; Address of flag setting routine for channel P
  ldf     Z_FLAG                          ; Z_FLAG since key found in chn-cd-lu
  ret
