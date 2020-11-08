# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

# Generated from the files in the /test directory.

# This file is auto-generated by all.sh. DO NOT EDIT!

.text


.align 3
all_tests:
  .quad 1                                 // Number of tests.
  .quad test_po_change_test_case_1


##########################################################################
############# Test po_change test case 1 #################################
##########################################################################

.align 3
# Test case definition
test_po_change_test_case_1:
  .quad test_po_change_test_case_1_name
  .quad test_po_change_test_case_1_setup_ram
  .quad test_po_change_test_case_1_setup_sysvars
  .quad test_po_change_test_case_1_setup_registers
  .quad test_po_change_test_case_1_effects_ram
  .quad test_po_change_test_case_1_effects_sysvars
  .quad test_po_change_test_case_1_effects_registers
  .quad test_po_change_test_case_1_exec

# Test case name
test_po_change_test_case_1_name:
  .asciz "po_change test case 1"

# Test case setup

.align 3
# RAM setup
test_po_change_test_case_1_setup_ram:
  .quad 3                                 // Number of RAM entries = 3
  .quad test_po_change_test_case_1_setup_ram_channel_block
  .quad test_po_change_test_case_1_setup_ram_new_input_routine
  .quad test_po_change_test_case_1_setup_ram_old_input_routine

.align 3
test_po_change_test_case_1_setup_ram_channel_block:
  .quad 16                                // 16 => pointer
  .quad 2                                 // old_input_routine
  .asciz "channel_block"                  // name: "channel_block"

.align 3
test_po_change_test_case_1_setup_ram_new_input_routine:
  .quad 8                                 // 8 => quad
  .quad 0xfedcba9876543210                // quad: 0xfedcba9876543210
  .asciz "new_input_routine"              // name: "new_input_routine"

.align 3
test_po_change_test_case_1_setup_ram_old_input_routine:
  .quad 8                                 // 8 => quad
  .quad 0x0123456789abcdef                // quad: 0x0123456789abcdef
  .asciz "old_input_routine"              // name: "old_input_routine"

.align 3
# System variables setup
test_po_change_test_case_1_setup_sysvars:
  .quad 0b0000000000000000000000100000000000000000000000000000000000000000
                                          // Index 41 => CURCHL
  .quad 0b0000000000000000000000100000000000000000000000000000000000000000
                                          // Index 41: 1 => CURCHL value is pointer
  .quad 0                                 // [CURCHL] = channel_block

.align 3
# Registers setup
test_po_change_test_case_1_setup_registers:
  .quad 0b0000000000000000000000000000000000000000000000000000001100000000
  .quad 1                                 // new_input_routine

# Test case effects

.align 3
# RAM effects
test_po_change_test_case_1_effects_ram:
  .quad 1                                 // Number of RAM entries = 1
  .quad 0                                 // channel_block updated
  .quad 16                                // 16 => new value is pointer
  .quad 1                                 // value = new_input_routine

.align 3
# System variable effects
test_po_change_test_case_1_effects_sysvars:
  .quad 0b0000000000000000000000000000000000000000000000000000000000000000
  .quad 0b0000000000000000000000000000000000000000000000000000000000000000

.align 3
# Register effects
test_po_change_test_case_1_effects_registers:
  .quad 0b0000000000000000000000000000000000000000000000000000110000000000
  .quad 0                                 // channel_block

# Test case execution

.align 2
test_po_change_test_case_1_exec:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  ldp     x0, x1, [x0]                    // Restore x0, x1 values
  bl      po_change
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret

##########################################################################
