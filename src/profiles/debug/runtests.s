# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text
.align 2


check_sp_matches_x29:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp

// TODO
  ldp     x29, x30, [sp], #16
  ret


log_test_name:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  mov     x4, x0                          // Back up x0.
  adr     x0, msg_running_test_part_1
  bl      uart_puts
  mov     x0, x4                          // Restore x0.
  bl      uart_puts
  adr     x0, msg_running_test_part_2
  bl      uart_puts
  ldp     x29, x30, [sp], #16
  ret


msg_running_test_part_1: .asciz "Running test "
msg_running_test_part_2: .asciz "...\r\n"


.align 2
random_registers:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  sub     sp, sp, #0x100
  mov     x0, sp
  mov     x1, #0x100
  bl      rand_block
  pop_registers
  ldp     x29, x30, [sp], #16
  ret


random_sysvars:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  mov     x0, x28
  mov     x1, (sysvars_end - sysvars)
  bl      rand_block
  ldp     x29, x30, [sp], #16
  ret


test_equal:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
// TODO
  ldp     x29, x30, [sp], #16
  ret


test_register_equals:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
// TODO
  ldp     x29, x30, [sp], #16
  ret


test_registers_preserved:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  stp     x0, x1, [sp, #-16]!
  add     x0, sp, (32 + sysvars_end - sysvars + 256 + sysvars_end - sysvars)
  mov     x1, #8
  mov     x2, #40
  bl      display_memory
  add     x0, sp, (32 + sysvars_end - sysvars)
  mov     x1, #8
  mov     x2, #50
  bl      display_memory
  ldp     x0, x1, [sp], #16
  add     x2, sp, (16 + sysvars_end - sysvars + 256 + sysvars_end - sysvars)
                                          // x2 = addres on stack of x0 before calling method
  add     x3, sp, (16 + sysvars_end - sysvars)
                                          // x3 = addres on stack of x0 after calling method
  mov     x1, #0                          // Index of the register to compare
  1:
  // test for equality
    ldr     x4, [x2, x1, lsl #3]
    ldr     x5, [x3, x1, lsl #3]
    stp     x0, x1, [sp, #-16]!
    stp     x2, x3, [sp, #-16]!
    bl      report_if_equal
    ldp     x2, x3, [sp], #16
    ldp     x0, x1, [sp], #16
    lsr     x0, x0, #1
    add     x1, x1, #1
    cmp     x1, #30
    b.ne    1b
  ldp     x29, x30, [sp], #16
  ret


report_if_equal:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  sub     x1, x4, x5
  stp     x0, x1, [sp, #-16]!
  stp     x4, x5, [sp, #-16]!
  mov     x0, x4
  bl      uart_x0
  ldp     x0, x1, [sp, #16]
  adr     x6, msg_equal
  adr     x7, msg_not_equal
  cmp     x1, #0
  csel    x0, x6, x7, eq
  bl      uart_puts
  ldr     x0, [sp, #8]
  bl      uart_x0
  ldr     x0, [sp, #16]
  adr     x6, msg_expected_equal
  adr     x7, msg_expected_not_equal
  tst     x0, #1
  csel    x0, x6, x7, ne
  bl      uart_puts
  bl      uart_newline
  add     sp, sp, #32
  ldp     x29, x30, [sp], #16
  ret


msg_equal: .asciz " == "
msg_not_equal: .asciz " != "
msg_expected_equal: .asciz " and expected them to be equal"
msg_expected_not_equal: .asciz " and expected them to be different"


.align 2
test_uncorrupted_sysvars:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
// TODO
  ldp     x29, x30, [sp], #16
  ret
