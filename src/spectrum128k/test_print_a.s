# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


# Test PRINT-A routine (RST 0x10) using a fake print routine that just
# buffers what is printed.

#########################################################################################################################
# test named "print_a_t1" rather than "print_a_1" in order that subsequent test does not clash with rom routine print_a_2
#########################################################################################################################
print_a_1_setup:
  ld      hl, fake_channel_block
  jp      fake_channel_init

print_a_1_setup_regs:
  ld      a, 'x'                          ; print 'x'
  ret

print_a_1_effects:
  _strb   3, 0x4000                       ; modified by fake_printout routine
  _strb   'x', 0x4002                     ; modified by fake_printout routine
  ret

print_a_1_effects_regs:
  exx
  ld      de, fake_channel_block+1        ; since fake_printout doesn't update DE, value from PRINT-A
  exx
  ret

# Test PRINT-A routine (RST 0x10) using a fake print routine that just
# corrupts all registers, so we can see which are preserved by RST 0x10.

print_a_2_setup:
  ld      hl, fake_touch_registers_channel_block
  jp      fake_channel_init

print_a_2_setup_regs:
  jr      print_a_1_setup_regs

print_a_2_effects:
  jr      print_a_1_effects

print_a_2_effects_regs:
  exx
  push    hl
  call    touch_all_registers
  pop     hl
  exx
  ret
