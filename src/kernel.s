# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.section .text
# ------------------------------------------------------------------------------
# Entry point of the application
# ------------------------------------------------------------------------------
kernel:
  bl        hang_non_primary_cores
  # L0000:
  bl        disable_interrupts
  # L0004: delay to allow screen to settle - not needed
  # L00C7: 1) test RAM banks - can implement later or skip entirely
  #        2) reset keypad - not needed
  # L0137: 1) reset sound - not needed
  #        2) copy paging routines from ROM -> RAM - not needed
  #        3) setup stack
  bl        setup_stack_pointers
  #        4) initialise RAM disk
  bl        setup_ramdisk
  bl        setup_system_registers
  bl        setup_bss
  bl        setup_uart
  bl        setup_kernel
  b         hang_core


# ------------------------------------------------------------------------------
# Puts non-primary cores to sleep
# ------------------------------------------------------------------------------
hang_non_primary_cores:
  mrs       x0, mpidr_el1
  and       x0, x0, #0xff     // Check processor id
  cbnz      x0, hang_core     // Hang non-primary cores
  ret


# ------------------------------------------------------------------------------
# Disables interrupts
# ------------------------------------------------------------------------------
disable_interrupts:
  ret

# ------------------------------------------------------------------------------
# Sets up system registers
# ------------------------------------------------------------------------------
setup_system_registers:
  # bits 29, 28, 23, 22, 20, 11
  ldr       x0, =0b00110000110100000000100000000000 // 0x30d00800
  msr       sctlr_el1, x0
  mov       x0, 0b10000000000000000000000000000000  // 0x80000000
  msr       hcr_el2, x0
  mov       x0, 0b0000010000110001
  msr       scr_el3, x0
  mov       x0, 0b0000000111000101
  msr       spsr_el3, x0
  # x30 is link register; returns control to calling function when exiting EL3
  msr       elr_el3, x30
  eret


# ------------------------------------------------------------------------------
# Zeros bss memory for system variables
# ------------------------------------------------------------------------------
setup_bss:
  adr       x0, bss_begin
  adr       x1, bss_end
  sub       x1, x1, x0
1:
  str       xzr, [x0], #8
  subs      x1, x1, #8
  b.gt      1b
  ret


# ------------------------------------------------------------------------------
# Sets up stack pointers
# ------------------------------------------------------------------------------
setup_stack_pointers:
  mov       sp, stack_base
  ret


# ------------------------------------------------------------------------------
# Sets up the kernel
# ------------------------------------------------------------------------------
setup_kernel:
  ldr       x0, Var2
  ldr       x3, Var1
  sub       x4, x4, #20
  ret


# ------------------------------------------------------------------------------
# Never returns; loops forever, waiting for interrupts
# ------------------------------------------------------------------------------
hang_core:
1:
  wfi                         // Wait for interrupt; like 'wfe' but more sleepy
  b         1b


# ------------------------------------------------------------------------------
# Exception vectors.
# ------------------------------------------------------------------------------
.align  11
vectors:
  ventry    sync_invalid_el1t
  ventry    irq_invalid_el1t
  ventry    fiq_invalid_el1t
  ventry    error_invalid_el1t

  ventry    sync_invalid_el1h
  ventry    el1_irq
  ventry    fiq_invalid_el1h
  ventry    error_invalid_el1h

  ventry    sync_invalid_el0_64
  ventry    irq_invalid_el0_64
  ventry    fiq_invalid_el0_64
  ventry    error_invalid_el0_64

  ventry    sync_invalid_el0_32
  ventry    irq_invalid_el0_32
  ventry    fiq_invalid_el0_32
  ventry    error_invalid_el0_32

sync_invalid_el1t:
  handle_invalid_entry  SYNC_INVALID_EL1t

irq_invalid_el1t:
  handle_invalid_entry  IRQ_INVALID_EL1t

fiq_invalid_el1t:
  handle_invalid_entry  FIQ_INVALID_EL1t

error_invalid_el1t:
  handle_invalid_entry  ERROR_INVALID_EL1t

sync_invalid_el1h:
  handle_invalid_entry  SYNC_INVALID_EL1h

fiq_invalid_el1h:
  handle_invalid_entry  FIQ_INVALID_EL1h

error_invalid_el1h:
  handle_invalid_entry  ERROR_INVALID_EL1h

sync_invalid_el0_64:
  handle_invalid_entry  SYNC_INVALID_EL0_64

irq_invalid_el0_64:
  handle_invalid_entry  IRQ_INVALID_EL0_64

fiq_invalid_el0_64:
  handle_invalid_entry  FIQ_INVALID_EL0_64

error_invalid_el0_64:
  handle_invalid_entry  ERROR_INVALID_EL0_64

sync_invalid_el0_32:
  handle_invalid_entry  SYNC_INVALID_EL0_32

irq_invalid_el0_32:
  handle_invalid_entry  IRQ_INVALID_EL0_32

fiq_invalid_el0_32:
  handle_invalid_entry  FIQ_INVALID_EL0_32

error_invalid_el0_32:
  handle_invalid_entry  ERROR_INVALID_EL0_32

el1_irq:
  kernel_entry
  bl        handle_irq
  kernel_exit

show_invalid_entry_message:
  # should output x0, x1, x2 to uart
  ret

handle_irq:
  # IRQ_PENDING_1 = 3f00b204
  mov       x0, #0xb204
  movk      x0, #0x3f00, lsl #16

  ldr       w0, [x0]
  cmp       w0, #0x2
  b.ne      1f
  # handle expected IRQ here

  ret
1:
  # handle unexpected IRQ here

  ret
