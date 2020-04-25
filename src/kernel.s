# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.text
# # ------------------------------------------------------------------------------
# # Entry point of the application
# # ------------------------------------------------------------------------------
# kernel:
#   bl        hang_non_primary_cores
#   bl        disable_interrupts
#   bl        setup_stack_pointers
#   bl        setup_ramdisk
#   bl        setup_system_registers
#   bl        setup_bss
#   bl        setup_uart
#   bl        setup_kernel
#   b         hang_core
#
#
# # ------------------------------------------------------------------------------
# # Puts non-primary cores to sleep
# # ------------------------------------------------------------------------------
# hang_non_primary_cores:
#   mrs       x0, mpidr_el1
#   and       x0, x0, #0xff     // Check processor id
#   cbnz      x0, hang_core     // Hang non-primary cores
#   ret
#
#
# # ------------------------------------------------------------------------------
# # Disables interrupts
# # ------------------------------------------------------------------------------
# disable_interrupts:
#   ret
#
# # ------------------------------------------------------------------------------
# # Sets up system registers
# # ------------------------------------------------------------------------------
# setup_system_registers:
#   # bits 29, 28, 23, 22, 20, 11
#   ldr       x0, =0b00110000110100000000100000000000 // 0x30d00800
#   msr       sctlr_el1, x0
#   mov       x0, 0b10000000000000000000000000000000  // 0x80000000
#   msr       hcr_el2, x0
#   mov       x0, 0b0000010000110001
#   msr       scr_el3, x0
#   mov       x0, 0b0000000111000101
#   msr       spsr_el3, x0
#   # x30 is link register; returns control to calling function when exiting EL3
#   msr       elr_el3, x30
#   eret
#
#
# # ------------------------------------------------------------------------------
# # Zeros bss memory for system variables
# # ------------------------------------------------------------------------------
# setup_bss:
#   adr       x0, bss_begin
#   adr       x1, bss_end
# 1:
#   str       xzr, [x0], #8
#   cmp       x0, x1
#   b.lo      1b
#   ret
#
#
# # ------------------------------------------------------------------------------
# # Sets up stack pointers
# # ------------------------------------------------------------------------------
# setup_stack_pointers:
#   mov       sp, stack_base
#   ret
#
#
# # ------------------------------------------------------------------------------
# # Sets up the kernel
# # ------------------------------------------------------------------------------
# setup_kernel:
#   ....
#   ret
#
#
# # ------------------------------------------------------------------------------
# # Never returns; loops forever, waiting for interrupts
# # ------------------------------------------------------------------------------
# hang_core:
# 1:
#   wfi                         // Wait for interrupt; like 'wfe' but more sleepy
#   b         1b
#
#
# # ------------------------------------------------------------------------------
# # Exception vectors.
# # ------------------------------------------------------------------------------
# .align  11
# vectors:
#   ventry    sync_invalid_el1t
#   ventry    irq_invalid_el1t
#   ventry    fiq_invalid_el1t
#   ventry    error_invalid_el1t
#
#   ventry    sync_invalid_el1h
#   ventry    el1_irq
#   ventry    fiq_invalid_el1h
#   ventry    error_invalid_el1h
#
#   ventry    sync_invalid_el0_64
#   ventry    irq_invalid_el0_64
#   ventry    fiq_invalid_el0_64
#   ventry    error_invalid_el0_64
#
#   ventry    sync_invalid_el0_32
#   ventry    irq_invalid_el0_32
#   ventry    fiq_invalid_el0_32
#   ventry    error_invalid_el0_32
#
# sync_invalid_el1t:
#   handle_invalid_entry  SYNC_INVALID_EL1t
#
# irq_invalid_el1t:
#   handle_invalid_entry  IRQ_INVALID_EL1t
#
# fiq_invalid_el1t:
#   handle_invalid_entry  FIQ_INVALID_EL1t
#
# error_invalid_el1t:
#   handle_invalid_entry  ERROR_INVALID_EL1t
#
# sync_invalid_el1h:
#   handle_invalid_entry  SYNC_INVALID_EL1h
#
# fiq_invalid_el1h:
#   handle_invalid_entry  FIQ_INVALID_EL1h
#
# error_invalid_el1h:
#   handle_invalid_entry  ERROR_INVALID_EL1h
#
# sync_invalid_el0_64:
#   handle_invalid_entry  SYNC_INVALID_EL0_64
#
# irq_invalid_el0_64:
#   handle_invalid_entry  IRQ_INVALID_EL0_64
#
# fiq_invalid_el0_64:
#   handle_invalid_entry  FIQ_INVALID_EL0_64
#
# error_invalid_el0_64:
#   handle_invalid_entry  ERROR_INVALID_EL0_64
#
# sync_invalid_el0_32:
#   handle_invalid_entry  SYNC_INVALID_EL0_32
#
# irq_invalid_el0_32:
#   handle_invalid_entry  IRQ_INVALID_EL0_32
#
# fiq_invalid_el0_32:
#   handle_invalid_entry  FIQ_INVALID_EL0_32
#
# error_invalid_el0_32:
#   handle_invalid_entry  ERROR_INVALID_EL0_32
#
# el1_irq:
#   kernel_entry
#   bl        handle_irq
#   kernel_exit
#
# show_invalid_entry_message:
#   # should output x0, x1, x2 to uart
#   ret
#
# handle_irq:
#   # IRQ_PENDING_1 = 3f00b204
#   mov       x0, #0xb204
#   movk      x0, #0x3f00, lsl #16
#
#   ldr       w0, [x0]
#   cmp       w0, #0x2
#   b.ne      1f
#   # handle expected IRQ here
#
#   ret
# 1:
#   # handle unexpected IRQ here
#
#   ret


kernel:
# Should enable interrupts, set up vector jump tables, switch execution
# level etc, and all the kinds of things to initialise the processor system
# registers, memory virtualisation, initialise sound chip, USB, etc.
  mrs     x0, mpidr_el1                   // x0 = Multiprocessor Affinity Register.
  ands    x0, x0, #0x3                    // x0 = core number.
  b.ne    sleep                           // Put all cores except core 0 to sleep.
  adr     x28, sysvars                    // x28 will remain at this constant value to make all sys vars available via an immediate offset.
  bl      uart_init                       // Initialise UART interface.
  bl      init_framebuffer                // Allocate a frame buffer with chosen screen settings.
  mrs     x0, currentel
  lsr     x0, x0, #2
  cmp     x0, 3
  b.ne    1f
# Start L1 Caches if in EL3...
  mrs     x0, sctlr_el3                   // x0 = System Control Register
  orr     x0, x0, 0x0004                  // Data Cache (Bit 2)
  orr     x0, x0, 0x1000                  // Instruction Caches (Bit 12)
  msr     sctlr_el3, x0                   // System Control Register = x0
1:
  b       restart                         // Raspberry Pi 3B initialisation complete.
                                          // Now call entry point in rom0.s which
                                          // is the converted ZX Spectrum 128k code.


sleep:
  wfe                                     // Sleep until woken.
  b       sleep                           // Go to sleep; it has been a long day.


init_framebuffer:
  adr     x0, mbreq                       // x0 = memory block pointer for mailbox call.
  mov     x27, x30
  bl      mbox_call
  mov     x30, x27
  ldr     w11, [x0, framebuffer-mbreq]    // w11 = allocated framebuffer address
  and     w11, w11, #0x3fffffff           // Clear upper bits beyond addressable memory
  str     w11, [x0, framebuffer-mbreq]    // Store framebuffer address in framebuffer system variable.
  ret


# On entry:
#   x0 = address of mailbox request
# On exit:
#   x0 unchanged
mbox_call:
  movl     w9, MAILBOX_BASE               // x9 = 0x3f00b880 (Mailbox Peripheral Address)
1:                                        // Wait for mailbox FULL flag to be clear.
  ldr     w10, [x9, MAILBOX_STATUS]       // w10 = mailbox status.
  tbnz    w10, MAILBOX_FULL_BIT, 1b       // If FULL flag set (bit 31), try again...
  mov     w11, 8                          // Mailbox channel 8.
  orr     w11, w0, w11                    // w11 = encoded request address + channel number.
  str     w11, [x9, MAILBOX_WRITE]        // Write request address / channel number to mailbox write register.
2:                                        // Wait for mailbox EMPTY flag to be clear.
  ldr     w12, [x9, MAILBOX_STATUS]       // w12 = mailbox status.
  tbnz    w12, MAILBOX_EMPTY_BIT, 2b      // If EMPTY flag set (bit 30), try again...
  ldr     w12, [x9, MAILBOX_REQ_ADDR]     // w12 = message request address + channel number.
  cmp     w11, w12                        // See if the message is for us.
  b.ne    2b                              // If not, try again.
  ret


# On entry:
#   x0 = address
#   w1 = 8 bit value
poke_address:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Backup x19 / x20 on stack
  stp     x21, x22, [sp, #-16]!           // Backup x21 / x22 on stack
  stp     x23, x24, [sp, #-16]!           // Backup x23 / x24 on stack
  strb    w1, [x0]                        // Poke address
  adr     x9, display_file                // Check if address is in display file
  adr     x24, attributes_file
  subs    x11, x0, x9                     // x11 = display file offset
  b.lo    1f                              // if x0 < x9, jump ahead since before display file
  adr     x10, display_file_end           // Now compare address to upper limit of display file
  cmp     x0, x10
  b.hs    1f                              // if x0 >= x10 (display file end) jump ahead since after display file
  // framebuffer addresses = pitch*(BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))) + address of framebuffer + 4 * (BORDER_LEFT + 8*(x11%216) + [0-7])
  // attribute address = attributes_file+((x11/2)%108)+108*(((x11/216)%20)+20*(x11/(216*20*16)))
  adr     x9, mbreq                       // x9 = address of mailbox request.
  ldr     w10, [x9, framebuffer-mbreq]    // w10 = address of framebuffer
  ldr     w12, [x9, pitch-mbreq]          // w12 = pitch
  mov     x13, #0x425f
  movk    x13, #0x97b, lsl #16
  movk    x13, #0x25ed, lsl #32
  movk    x13, #0x97b4, lsl #48           // x13 = 0x97b425ed097b425f = 10931403895531586143
  umulh   x14, x13, x11                   // x14 = (10931403895531586143 * x11) / 18446744073709551616 = int(x11*16/27)
  lsr     x14, x14, #7                    // x14 = int(x11/216)
  mov     x15, #0xcccccccccccccccc
  add     x15, x15, #1                    // x15 = 0x0xcccccccccccccccd
  umulh   x16, x15, x14                   // x16 = 14757395258967641293 * int(x11/216) / 2^64 = (4/5) * int(x11/216)
  lsr     x16, x16, #4                    // x16 = int(int(x11/216)/20)
  add     x16, x16, x16, lsl #2           // x16 = 5 * int(int(x11/216)/20)
  sub     x16, x14, x16, lsl #2           // x16 = int(x11/216) - 20 * int(int(x11/216)/20) = (x11/216)%20
  mov     x17, #0x9d65
  movk    x17, #0xf2b, lsl #16
  movk    x17, #0xd648, lsl #32
  movk    x17, #0xf2b9, lsl #48           // x17 = 0xf2b9d6480f2b9d65 = 17490246232850537829
  umulh   x18, x17, x11                   // x18 = 17490246232850537829 * x11 / 2^64 = int(x11*128/135)
  ubfx    x19, x18, #12, #4               // x19 = bits 12-15 of int(x11*128/135) = (x11/(216*20)) % 16
  add     x19, x19, x16, lsl #4           // x19 = (x11/(216*20))%16 + 16*((x11/216)%20)
  lsr     x18, x18, #16                   // x18 = int(x11/(216*20*16))
  add     x18, x18, x18, lsl #2           // x18 = 5*int(x11/(216*20*16))
  add     x19, x19, x18, lsl #6           // x19 = (x11/(216*20))%16 + 16*((x11/216)%20) + 320*int(x11/216*20*16)
  add     x19, x19, BORDER_TOP            // x19 = BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))
  umaddl  x19, w19, w12, x10              // x19 = pitch*(BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))) + address of framebuffer
  mov     x20, #0xd8                      // x20 = 216
  msub    x21, x20, x14, x11              // x21 = x11 - int(x11/216)*216 = x11%216
  mov     x22, BORDER_LEFT
  add     x22, x22, x21, lsl #3           // x22 = BORDER_LEFT + 8*(x11%216)
  add     x23, x19, x22, lsl #2           // x23 = pitch*(BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))) + address of framebuffer + 4*(BORDER_LEFT + 8*(x11%216))
  lsr     x10, x11, #1                    // x10 = int(x11/2)
  umulh   x14, x13, x10                   // x14 = int(int(x11/2)*16/27)
  lsr     x14, x14, #6                    // x14 = int(x11/216)
  mov     x12, #0x6c                      // x12 = 108
  msub    x10, x12, x14, x10              // x10 = int(x11/2)-108*int((x11/2)/108)=(x11/2)%108
  add     x16, x16, x18, lsl #2           // x16 = (x11/216)%20+20*int(x11/(216*20*16))
  madd    x16, x16, x12, x10              // x16 = 108*(((x11/216)%20+20*int(x11/(216*20*16))) + (x11/2)%108
  ldrb    w17, [x24, x16]                 // w17 = attribute data
  mov     w20, #0xcc             // dim
  mov     w21, #0xff             // bright
  tst     w17, #0x40             // bright set?
  csel    w22, w20, w21, eq      // x22 = brightness
// w15 = foreground colour
  tst     w17, #0x02                      // red set?
  csel    w13, wzr, w22, eq
  tst     w17, #0x04                      // green set?
  csel    w14, wzr, w22, eq
  tst     w17, #0x01                      // blue set?
  csel    w15, wzr, w22, eq
  add     w15, w15, w14, lsl #8
  add     w15, w15, w13, lsl #16
// w7 = background colour
  tst     w17, #0x10                      // red set?
  csel    w5, wzr, w22, eq
  tst     w17, #0x20                      // green set?
  csel    w6, wzr, w22, eq
  tst     w17, #0x08                      // blue set?
  csel    w7, wzr, w22, eq
  add     w7, w7, w6, lsl #8
  add     w7, w7, w5, lsl #16
  mov     w8, #8
3:
  tst     x1, #0x80              // pixel set?
  csel    w3, w7, w15, eq
  str     w3, [x23], #4
  lsl     w1, w1, #1
  subs    w8, w8, #1
  b.ne    3b
  b       2f
1:
  subs    x11, x0, x24                    // x11 = attributes file offset
  b.lo    2f                              // if x0 < x24, jump ahead since before attributes file
  adr     x10, attributes_file_end        // Now compare address to upper limit of attributes file
  cmp     x0, x10
  b.hs    2f                              // if x0 >= x10 (attributes file end), jump ahead since after attributes file
// TODO: rewrite this section to be more efficient (don't call poke_address recursively)
  add     x10, x9, x11, lsl #1            // x10 = disp base address + attr offset * 2
  mov     x8, #64800                      // 216 * 20 * 15
  cmp     x11, #2160
  csel    x12, x8, xzr, hs
  add     x10, x10, x12
  mov     x3, #4320
  cmp     x11, x3
  csel    x12, x8, xzr, hs
  add     x0, x10, x12
  mov     x3, #16
4:
  stp     x3, x0, [sp, #-16]!
  ldrb    w1, [x0]
  bl      poke_address
  ldp     x3, x0, [sp]
  add     x0, x0, #1
  ldrb    w1, [x0]
  bl      poke_address
  ldp     x3, x0, [sp], #16
  add     x0, x0, #4000
  add     x0, x0, #320
  subs    x3, x3, #1
  b.ne    4b
2:
  ldp     x23, x24, [sp], #0x10           // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10           // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


display_zx_screen:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  adr     x9, ZX_SCREEN
  adr     x0, display_file
1:
  ldrb    w1, [x9], #1
  stp     x0, x9, [sp, #-16]!
  bl      poke_address
  ldp     x0, x9, [sp], #16
  add     x0, x0, #1
  adr     x2, attributes_file_end
  cmp     x0, x2
  b.ne    1b
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x0 = start address
#   x1 = number of rows to print
#   x2 = screen line to start at
display_memory:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Store old x19, x20 on the the stack.
  stp     x21, x22, [sp, #-16]!           // Store old x21, x22 on the the stack.
  stp     x23, x24, [sp, #-16]!           // Store old x23, x24 on the the stack.
  sub     sp, sp, #112                    // 112 bytes for screen line buffer
  mov     x19, x0                         // x19 = start address
  mov     x20, x1                         // x20 = number of rows to print
  mov     x21, x2                         // x21 = screen line to start at
  mov     w23, #0x2020                    // two spaces ('  ')
  adr     x0, msg_hex_header              // Pointer to string
  mov     w1, #0                          // x coordinate
  mov     w3, #0x00ffffff                 // white ink
  mov     w4, #0x000000cc                 // (dark) blue paper
  bl      paint_string                    // paint hex header line
  add     x21, x21, #1                    // x21 = first data line screen line
1:
  mov     x1, sp                          // address to write text string to
  strh    w23, [x1], #2                   // write '  ' to screen line buffer on stack
  mov     x0, x19                         // x0 = dump address
  mov     x2, #32
  bl      hex_x0                          // append to screen line buffer and update x1
  mov     x22, #0x20                      // 32 values to print
2:
  strb    w23, [x1], #1                   // write ' ' to screen line buffer
  ldrb    w0, [x19], #1                   // w0 = data at address, bump address x19
  mov     x2, #8
  bl      hex_x0
  subs    x22, x22, #1
  b.ne    2b
  strh    w23, [x1], #2                   // write '  ' to screen line buffer
  strb    wzr, [x1], #1                   // append 0 byte to terminate string
  mov     x0, sp
  mov     w1, #0                          // x = 0
  mov     x2, x21                         // y = line number
  mov     w3, #0x00ffffff                 // white ink
  mov     w4, #0x000000cc                 // (dark) blue paper
  bl      paint_string                    // paint string
  add     x21, x21, #1                    // increase line number
  subs    x20, x20, #1
  b.ne    1b                              // if not, process next line
  add     sp, sp, #112                    // Free screen line buffer
  ldp     x23, x24, [sp], #0x10           // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10           // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   x0 = hex value to convert to text
#   x1 = address to write text to (no trailing 0)
#   x2 = number of bits to print (multiple of 4)
# On exit:
#   x1 = address of next unused char (x1 += x2/4)
hex_x0:
  ror     x0, x0, x2
1:
  ror     x0, x0, #60
  and     w3, w0, #0x0f
  add     w3, w3, 0x30
  cmp     w3, 0x3a
  b.lo    2f
  add     w3, w3, 0x27
2:
  strb    w3, [x1], #1
  subs    w2, w2, #4
  b.ne    1b
  ret


# ------------------------------------------------------------------------------
# Wait (at least) x0 instruction cycles.
# ------------------------------------------------------------------------------
wait_cycles:
  subs    x0, x0, #0x1                    // x0 -= 1
  b.ne    wait_cycles                     // Repeat until x0 == 0.
  ret                                     // Return.


display_sysvars:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // callee-saved registers used later on.
  stp     x21, x22, [sp, #-16]!           // callee-saved registers used later on.
  sub     sp, sp, #32                     // 32 bytes buffer for storing hex representation of sysvar (maximum is 16 chars + trailing 0, so 17 bytes)
  adr     x0, msg_title_sysvars
  bl      uart_puts
  adr     x0, sysvarnames                 // x0 = address of first sys var name
  adr     x20, sysvaraddresses            // x20 = address of first sys var pointer
1:
  bl      uart_puts
  ldrb    w21, [x0], #1                   // x21 = size of sysvar data in bytes
  mov     x19, x0                         // x19 = address of next sysvar name
  adr     x0, msg_colon0x
  bl      uart_puts
  ldr     x0, [x20], #8                   // x0 = address of sys var
  tbnz    w21, #0, size1
  tbnz    w21, #1, size2
  tbnz    w21, #2, size4
  tbnz    w21, #3, size8
  ret
size1:
  ldrb    w0, [x0]
  b       2f
size2:
  ldrh    w0, [x0]
  b       2f
size4:
  ldr     w0, [x0]
  b       2f
size8:
  ldr     x0, [x0]
2:
  mov     x1, sp
  mov     x2, x21, lsl #3                 // x2 = size of sysvar data in bits
  bl      hex_x0
  strb    wzr, [x1]                       // Add a trailing zero.
  mov     x0, sp
  bl      uart_puts
  bl      uart_newline
  mov     x0, x19
  ldrb    w1, [x0]
  cbnz    w1, 1b
  bl      uart_newline
  add     sp, sp, #32                     // Free buffer.
  ldp     x21, x22, [sp], #16             // Pop callee-saved registers.
  ldp     x19, x20, [sp], #16             // Pop callee-saved registers.
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  ret


/////////////////////////////////////////////////////////////////////////
// The following code is all just for demonstration / testing purposes...
/////////////////////////////////////////////////////////////////////////
demo:
  bl      paint_copyright                 // Paint the copyright text ((C) 1982 Amstrad....)
  mov     w0, 0x20000000
  bl      wait_cycles
  bl      display_zx_screen
  mov     w0, 0x10000000
  bl      wait_cycles
  mov     x0, #60
  bl      cls
  mov     x0, sp
  mov     x1, #1
  mov     x2, #0
  bl      display_memory
  adr     x0, mbreq
  mov     x1, #5
  mov     x2, #3
  bl      display_memory
  adr     x0, sysvars
  mov     x1, #10
  mov     x2, #10
  bl      display_memory
  adrp    x0, heap
  add     x0, x0, #:lo12:heap             // x0 = heap
  sub     x0, x0, #0x60
  mov     x1, #8
  mov     x2, #22
  bl      display_memory
  adr     x0, STRMS
  mov     x1, #2
  mov     x2, #32
  bl      display_memory
  ldr     x0, [x28, CHANS-sysvars]
  mov     x1, #2
  mov     x2, #36
  bl      display_memory
  bl      display_sysvars
  ldp     x29, x30, [sp], #16             // Pop frame pointer, procedure link register off stack.
  b       sleep
