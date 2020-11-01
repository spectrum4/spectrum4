# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

# This file is auto-generated by all.sh. DO NOT EDIT!

# The code is generated from the files in the /src/profiles/debug/testcases
# directory.

.text
.align 2


run_tests:
  ldr     w0, arm_size
  and     sp, x0, #~0x0f
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  bl      test_po_change_case_1
  ldp     x29, x30, [sp], #16
  ret


test_po_change_case_1:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  adr     x0, msg_po_change_case_1
  bl      log_test_name
  bl      random_sysvars
  adr     x0, po_change_case_1_channel_block
  str     x0, [x28, CURCHL-sysvars]
  bl      random_registers
  adr     x28, sysvars
  adr     x4, po_change_case_1_new_input_routine
  push_registers
  push_sysvars
  bl      po_change
  push_registers
  push_sysvars
  ldr     w0, =0b00111111111111111111111111011111
  adr     x8, msg_po_change_case_1
  bl      test_registers_preserved
  mov     w0, #5
  adr     x1, po_change_case_1_channel_block
  bl      test_register_equals
  adr     x0, po_change_case_1_corrupted_sysvars
  bl      test_uncorrupted_sysvars
  mov     sp, x29
  ldp     x29, x30, [sp], #16
  ret


msg_po_change_case_1:
  .asciz "po_change test case 1"

po_change_case_1_corrupted_sysvars:
  .byte 0

.align 3
po_change_case_1_old_input_routine:
  .quad 0x12345678

.align 3
po_change_case_1_new_input_routine:
  .quad 0x87654321

.align 3
po_change_case_1_channel_block:
  .quad po_change_case_1_old_input_routine
