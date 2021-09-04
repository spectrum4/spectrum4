# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text

# Address to place CHANS data - on fresh boot this would be 0x5cb6, but the user
# is free to relocate this data and update [CHANS] to the new location.
.set MY_CHANS, 0x7000

# Copy default chans from ROM to RAM
test_chan_flag_init:
  ld      hl, init_chan
  ld      de, MY_CHANS
  ld      bc, 0x0015
  ld      (CHANS), de
  ldir
  ret



chan_flag_01_setup:
  jp      test_chan_flag_init

chan_flag_01_setup_regs:
  ld      hl, MY_CHANS + 5*2              ; Current channel is 'R'
  ret

chan_flag_01_effects:
  _strh   MY_CHANS + 5*2, CURCHL          ; Current channel is 'R'
  _resbit 4, FLAGS2                       ; K channel not in use
  ret

chan_flag_01_effects_regs:
  ld      a, 0
  ld      c, 'R'
  ld      hl, 0x1633
  ldf     Z_FLAG|H_FLAG|PV_FLAG
  ret
