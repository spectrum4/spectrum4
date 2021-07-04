# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# Copy default STRMS and CHANS to heap
.align 2
test_chan_open_init:
  adr     x5, STRMS
  mov     x6, (initial_stream_data_END - initial_stream_data)/2
                                                  // x6 = number of half words (2 bytes) in initial_stream_data block
  adr     x7, initial_stream_data
  1:                                              // Loop to copy initial_stream_data block to [STRMS]
    ldrh    w8, [x7], #2
    strh    w8, [x5], #2
    subs    x6, x6, #1
    b.ne    1b
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
chan_open_minus_01_setup:
  b       test_chan_open_init

.align 2
chan_open_minus_01_setup_regs:
  mov     x0, #-1
  ret

.align 2
chan_open_minus_01_effects:
  _str    heap + 0x18*2, CURCHL                   //  Current channel is 'R'
  _resbit 4, FLAGS2                               //  K channel not in use
  ret

.align 2
chan_open_minus_01_effects_regs:
  mov     x0, 'R'
  mov     x1, 0x00
  mov     x9, 0x00
  mov     x10, 0x50
  nzcv    #0b0010
  ret



.align 2
chan_open_00_setup:
  _strb   0x03, BORDCR
  _strb   0b10100110, P_FLAG
  b       test_chan_open_init

.align 2
chan_open_00_setup_regs:
  mov     x0, #0x00
  ret

.align 2
chan_open_00_effects:
  _str    heap, CURCHL                            // Current channel is keyboard
  _resbit 1, FLAGS                                // Printer not in use
  _resbit 5, FLAGS                                // No new key
  _setbit 4, FLAGS2                               // K channel in use
  _setbit 0, TV_FLAG                              // Lower screen in use
  _strb   0x03, ATTR_T                            // [BORDCR]
  _strb   0x00, MASK_T
  _strb   0b10100010, P_FLAG                      // even (temp) bits cleared
  ret

.align 2
chan_open_00_effects_regs:
  mov     x0, 0b10100010                          // [P_FLAG]
  mov     x1, 0x03                                // [BORDCR]
  adr     x2, chan_k
  ldrb    w9, [x28, FLAGS2-sysvars]
  mov     x10, 'K'                                // Key for chn-cd-lu table
  nzcv    #0b0110
  ret



.align 2
chan_open_01_setup:
  _strb   0x03, BORDCR
  _strb   0b10100110, P_FLAG
  b       test_chan_open_init

.align 2
chan_open_01_setup_regs:
  mov     x0, #0x01
  ret

.align 2
chan_open_01_effects:
  _str    heap, CURCHL                            // Current channel is keyboard
  _resbit 1, FLAGS                                // Printer not in use
  _resbit 5, FLAGS                                // No new key
  _setbit 4, FLAGS2                               // K channel in use
  _setbit 0, TV_FLAG                              // Lower screen in use
  _strb   0x03, ATTR_T                            // [BORDCR]
  _strb   0x00, MASK_T
  _strb   0b10100010, P_FLAG
  ret

.align 2
chan_open_01_effects_regs:
  mov     x0, 0b10100010                          // [P_FLAG]
  mov     x1, 0x03                                // [BORDCR]
  adr     x2, chan_k
  ldrb    w9, [x28, FLAGS2-sysvars]
  mov     x10, 'K'                                // Key for chn-cd-lu table
  nzcv    #0b0110
  ret



.align 2
chan_open_02_setup:
  _strb   0b10100010, P_FLAG
  _strb   0x57, ATTR_P
  _strb   0x23, MASK_P
  b       test_chan_open_init

.align 2
chan_open_02_setup_regs:
  mov     x0, #0x02
  ret

.align 2
chan_open_02_effects:
  _str    heap + 0x18*1, CURCHL                   // Current channel is screen
  _resbit 1, FLAGS                                // Printer not in use
  _resbit 4, FLAGS2                               // K channel not in use
  _resbit 0, TV_FLAG                              // Main screen in use
  _strb   0x57, ATTR_T                            // [ATTR_P]
  _strb   0x23, MASK_T                            // [MASK_P]
  _strb   0b11110011, P_FLAG                      // Perm bits copied to temp bits
  ret

.align 2
chan_open_02_effects_regs:
  mov     x0, 0b11110011                          // [P_FLAG]
  mov     x1, 0x2357                              // ([MASK_P] << 8) | [ATTR_P]
  mov     x2, 0b01010001                          // [P_FLAG] with temp bits copied from perm bits; perm bits cleared
  mov     x9, 0x01
  mov     x10, 'S'                                // Key for chn-cd-lu table
  nzcv    #0b0110
  ret



.align 2
chan_open_03_setup:
  b       test_chan_open_init

.align 2
chan_open_03_setup_regs:
  mov     x0, #0x03
  ret

.align 2
chan_open_03_effects:
  _str    heap + 0x18*3, CURCHL                   // Current channel is printer
  _setbit 1, FLAGS                                // Printer in use
  _resbit 4, FLAGS2                               // K channel not in use
  ret

.align 2
chan_open_03_effects_regs:
  ldrb    w0, [x28, FLAGS-sysvars]
  mov     x1, chn_cd_lu + 0x08 + 2*0x10           // Third record in chn-cd-lu
  mov     x2, chan_p
  mov     w9, #0x00                               // No more records in chn-cd-lu
  mov     x10, 'P'                                // Key for chn-cd-lu table
  nzcv    #0b0110
  ret
