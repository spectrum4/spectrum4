# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.text
.align 2


# Test print_w0 routine using a fake print routine that just buffers what is
# printed.


print_w0_1_setup:
  _str    fake_channel_block, CURCHL              // [CURCHL] = print_w0_1_channel_block
  ret


print_w0_1_setup_regs:
  mov     w0, 'x'                                 // x4 = 0xfedbca9876543210
  ret


print_w0_1_effects:
  adrp    x0, fake_print_buffer_location
  add     x0, x0, :lo12:fake_print_buffer_location
  adrp    x1, fake_print_buffer
  add     x1, x1, :lo12:fake_print_buffer
  mov     w2, 'x'
  strb    w2, [x1], #1
  str     x1, [x0]
  ret


print_w0_1_effects_regs:
  adrp    x1, fake_printout
  add     x1, x1, :lo12:fake_printout
  ret
