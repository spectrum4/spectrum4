# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# Copy default CHANS to heap
.align 2
test_chan_flag_init:
  adrp    x5, heap
  add     x5, x5, #:lo12:heap                     // x5 = start of heap
  str     x5, [x28, CHANS-sysvars]                // [CHANS] = start of heap
  mov     x6, (initial_channel_info_END - initial_channel_info)/8
  adr     x7, initial_channel_info
  2:                                              // Loop to copy initial_channel_info block to [CHANS] = start of heap
    ldr     x8, [x7], #8
    str     x8, [x5], #8
    subs    x6, x6, #1
    b.ne    2b
  ret



.align 2
chan_flag_01_setup:
  b       test_chan_flag_init

.align 2
chan_flag_01_setup_regs:
  adr     x0, heap + 0x18*2
  ret

.align 2
chan_flag_01_effects:
  _str    heap + 0x18*2, CURCHL                   //  Current channel is 'R'
  _resbit 4, FLAGS2                               //  K channel not in use
  ret

.align 2
chan_flag_01_effects_regs:
  mov     x0, 'R'
  mov     x1, 0x00
  mov     x9, 0x00
  mov     x10, 0x50
  nzcv    #0b0010
  ret
