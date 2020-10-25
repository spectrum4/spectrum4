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
  add     x2, sp, (16 + sysvars - sysvars_end + 256 + sysvars - sysvars_end)
                                          // x2 = addres on stack of x0 before calling method
  add     x3, sp, (16 + sysvars - sysvars_end)
                                          // x3 = addres on stack of x0 after calling method
  mov     x1, #0                          // Index of the register to compare
1:
  tbnz    x0, #0, 3f                      // bit 0 of x0 set?
2:
  lsr     x0, x0, #1
  add     x1, x1, #1
  cmp     x1, #31
  b.ne    1b
  b       4f
3:
// test for equality
  ldr     x4, [x2, x1, lsl #3]
  ldr     x5, [x3, x1, lsl #3]
  bl      report_if_equal
  b       2b
4:
  ldp     x29, x30, [sp], #16
  ret


report_if_equal:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
  mov     x6, '='
  mov     x7, '!'
  cmp     x4, x5
  csel    x0, x6, x7, eq
  bl      uart_send
  bl      uart_newline
  ldp     x29, x30, [sp], #16
  ret

test_uncorrupted_sysvars:
  stp     x29, x30, [sp, #-16]!
  mov     x29, sp
// TODO
  ldp     x29, x30, [sp], #16
  ret
