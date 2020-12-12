# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

# Generated from the files in the /test directory.

# This file is auto-generated by all.sh. DO NOT EDIT!


all_tests:
  .byte 1                                 ; Number of tests.
  .hword test_cl_addr_test_case_1


##########################################################################
############# Test cl_addr test case 1 ###################################
##########################################################################

# Test case definition
test_cl_addr_test_case_1:
  .hword test_cl_addr_test_case_1_name
# .hword test_cl_addr_test_case_1_setup_stack
# .hword test_cl_addr_test_case_1_setup_sysvars
  .hword test_cl_addr_test_case_1_setup_registers
# .hword test_cl_addr_test_case_1_effects_stack
# .hword test_cl_addr_test_case_1_effects_sysvars
  .hword test_cl_addr_test_case_1_effects_registers
  .hword test_cl_addr_test_case_1_exec

# Test case name
test_cl_addr_test_case_1_name:
  .asciz "cl_addr test case 1"

# Test case setup

# Stack setup
test_cl_addr_test_case_1_setup_stack:
  .byte 0                                 ; Number of stack entries = 0

# System variables setup
test_cl_addr_test_case_1_setup_sysvars:
  .hword 0b00000000

# Registers setup
test_cl_addr_test_case_1_setup_registers:
  .byte 0b11000000                        ; Set BC'
  .byte 0b10100000                        ; Set A
  .byte 0b00001111                        ; Set DE
  .hword 0x1234                           ; BC' = 0x1234
  .byte  0xbc                             ; A = 0xbc
  .byte  0x0b                             ; B = 0x0b
  .hword 0x2345                           ; DE = 0x2345
  .hword 0x48A3                           ; HL = 0x48A3

# Test case effects

# Stack effects
test_cl_addr_test_case_1_effects_stack:

# System variable effects
test_cl_addr_test_case_1_effects_sysvars:
  .byte 0b00000000
  .byte 0b00000000

# Registers effects
test_cl_addr_test_case_1_effects_registers:
  .byte 0b00000000                        ; bc' af' iy  ix
  .byte 0b00000000                        ; bc  af  hl' de'
  .byte 0b00000000                        ; ..  ..  hl  de

# Test case execution

test_cl_addr_test_case_1_exec:
  pop     hl
  call    0x0E9B                          ; cl_addr
  jp      test_exec_return

##########################################################################
