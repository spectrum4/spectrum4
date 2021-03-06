# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

# This file is auto-generated by test_cl_addr.sh. DO NOT EDIT!

.text

cl_addr_0x01_setup_regs:
  ld      b, 0x01
  ret

cl_addr_0x01_effects_regs:
  ld      a, 0x50
  ld      d, 0x17
  ld      hl, 0x50e0
  ldf     PV_FLAG
  ret

cl_addr_0x02_setup_regs:
  ld      b, 0x02
  ret

cl_addr_0x02_effects_regs:
  ld      a, 0x50
  ld      d, 0x16
  ld      hl, 0x50c0
  ldf     PV_FLAG
  ret

cl_addr_0x03_setup_regs:
  ld      b, 0x03
  ret

cl_addr_0x03_effects_regs:
  ld      a, 0x50
  ld      d, 0x15
  ld      hl, 0x50a0
  ldf     PV_FLAG
  ret

cl_addr_0x04_setup_regs:
  ld      b, 0x04
  ret

cl_addr_0x04_effects_regs:
  ld      a, 0x50
  ld      d, 0x14
  ld      hl, 0x5080
  ldf     PV_FLAG
  ret

cl_addr_0x05_setup_regs:
  ld      b, 0x05
  ret

cl_addr_0x05_effects_regs:
  ld      a, 0x50
  ld      d, 0x13
  ld      hl, 0x5060
  ldf     PV_FLAG
  ret

cl_addr_0x06_setup_regs:
  ld      b, 0x06
  ret

cl_addr_0x06_effects_regs:
  ld      a, 0x50
  ld      d, 0x12
  ld      hl, 0x5040
  ldf     PV_FLAG
  ret

cl_addr_0x07_setup_regs:
  ld      b, 0x07
  ret

cl_addr_0x07_effects_regs:
  ld      a, 0x50
  ld      d, 0x11
  ld      hl, 0x5020
  ldf     PV_FLAG
  ret

cl_addr_0x08_setup_regs:
  ld      b, 0x08
  ret

cl_addr_0x08_effects_regs:
  ld      a, 0x50
  ld      d, 0x10
  ld      hl, 0x5000
  ldf     PV_FLAG
  ret

cl_addr_0x09_setup_regs:
  ld      b, 0x09
  ret

cl_addr_0x09_effects_regs:
  ld      a, 0x48
  ld      d, 0x0f
  ld      hl, 0x48e0
  ldf     PV_FLAG | X3_FLAG
  ret

cl_addr_0x0a_setup_regs:
  ld      b, 0x0a
  ret

cl_addr_0x0a_effects_regs:
  ld      a, 0x48
  ld      d, 0x0e
  ld      hl, 0x48c0
  ldf     PV_FLAG | X3_FLAG
  ret

cl_addr_0x0b_setup_regs:
  ld      b, 0x0b
  ret

cl_addr_0x0b_effects_regs:
  ld      a, 0x48
  ld      d, 0x0d
  ld      hl, 0x48a0
  ldf     PV_FLAG | X3_FLAG
  ret

cl_addr_0x0c_setup_regs:
  ld      b, 0x0c
  ret

cl_addr_0x0c_effects_regs:
  ld      a, 0x48
  ld      d, 0x0c
  ld      hl, 0x4880
  ldf     PV_FLAG | X3_FLAG
  ret

cl_addr_0x0d_setup_regs:
  ld      b, 0x0d
  ret

cl_addr_0x0d_effects_regs:
  ld      a, 0x48
  ld      d, 0x0b
  ld      hl, 0x4860
  ldf     PV_FLAG | X3_FLAG
  ret

cl_addr_0x0e_setup_regs:
  ld      b, 0x0e
  ret

cl_addr_0x0e_effects_regs:
  ld      a, 0x48
  ld      d, 0x0a
  ld      hl, 0x4840
  ldf     PV_FLAG | X3_FLAG
  ret

cl_addr_0x0f_setup_regs:
  ld      b, 0x0f
  ret

cl_addr_0x0f_effects_regs:
  ld      a, 0x48
  ld      d, 0x09
  ld      hl, 0x4820
  ldf     PV_FLAG | X3_FLAG
  ret

cl_addr_0x10_setup_regs:
  ld      b, 0x10
  ret

cl_addr_0x10_effects_regs:
  ld      a, 0x48
  ld      d, 0x08
  ld      hl, 0x4800
  ldf     PV_FLAG | X3_FLAG
  ret

cl_addr_0x11_setup_regs:
  ld      b, 0x11
  ret

cl_addr_0x11_effects_regs:
  ld      a, 0x40
  ld      d, 0x07
  ld      hl, 0x40e0
  ldf     0x0
  ret

cl_addr_0x12_setup_regs:
  ld      b, 0x12
  ret

cl_addr_0x12_effects_regs:
  ld      a, 0x40
  ld      d, 0x06
  ld      hl, 0x40c0
  ldf     0x0
  ret

cl_addr_0x13_setup_regs:
  ld      b, 0x13
  ret

cl_addr_0x13_effects_regs:
  ld      a, 0x40
  ld      d, 0x05
  ld      hl, 0x40a0
  ldf     0x0
  ret

cl_addr_0x14_setup_regs:
  ld      b, 0x14
  ret

cl_addr_0x14_effects_regs:
  ld      a, 0x40
  ld      d, 0x04
  ld      hl, 0x4080
  ldf     0x0
  ret

cl_addr_0x15_setup_regs:
  ld      b, 0x15
  ret

cl_addr_0x15_effects_regs:
  ld      a, 0x40
  ld      d, 0x03
  ld      hl, 0x4060
  ldf     0x0
  ret

cl_addr_0x16_setup_regs:
  ld      b, 0x16
  ret

cl_addr_0x16_effects_regs:
  ld      a, 0x40
  ld      d, 0x02
  ld      hl, 0x4040
  ldf     0x0
  ret

cl_addr_0x17_setup_regs:
  ld      b, 0x17
  ret

cl_addr_0x17_effects_regs:
  ld      a, 0x40
  ld      d, 0x01
  ld      hl, 0x4020
  ldf     0x0
  ret

cl_addr_0x18_setup_regs:
  ld      b, 0x18
  ret

cl_addr_0x18_effects_regs:
  ld      a, 0x40
  ld      d, 0x00
  ld      hl, 0x4000
  ldf     0x0
  ret
