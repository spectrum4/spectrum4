# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

# ------------------------------------------------------------------------------
# See "BCM2837 ARM Peripherals" datasheet pages 8-19:
#   https://cs140e.sergio.bz/docs/BCM2837-ARM-Peripherals.pdf
# ------------------------------------------------------------------------------
.set AUX_IRQ,        0x0000                       // Auxiliary Interrupt Status
.set AUX_ENABLES,    0x0004                       // Auxiliary Enables
.set AUX_MU_IO_REG,  0x0040                       // Mini Uart I/O Data
.set AUX_MU_IER,     0x0044                       // Mini Uart Interrupt Enable
.set AUX_MU_IIR,     0x0048                       // Mini Uart Interrupt Identify
.set AUX_MU_LCR,     0x004C                       // Mini Uart Line Control
.set AUX_MU_MCR,     0x0050                       // Mini Uart Modem Control
.set AUX_MU_LSR,     0x0054                       // Mini Uart Line Status
.set AUX_MU_MSR,     0x0058                       // Mini Uart Modem Status
.set AUX_MU_SCRATCH, 0x005C                       // Mini Uart Scratch
.set AUX_MU_CNTL,    0x0060                       // Mini Uart Extra Control
.set AUX_MU_STAT,    0x0064                       // Mini Uart Extra Status
.set AUX_MU_BAUD,    0x0068                       // Mini Uart Baudrate


# ------------------------------------------------------------------------------
# See "BCM2837 ARM Peripherals" datasheet pages 90-104:
#   https://cs140e.sergio.bz/docs/BCM2837-ARM-Peripherals.pdf
# ------------------------------------------------------------------------------
.set GPFSEL1,        0x0004                       // GPIO Function Select 1
.set GPPUD,          0x0094                       // GPIO Pin Pull-up/down Enable
.set GPPUDCLK0,      0x0098                       // GPIO Pin Pull-up/down Enable Clock 0

# ------------------------------------------------------------------------------
# Initialise the Mini UART interface for logging over serial port.
# Note, this is Broadcomm's own UART, not the ARM licenced UART interface.
# ------------------------------------------------------------------------------
.align 2
uart_init:
  adr     x4, mailbox_base                        // x4 = mailbox_base
  ldr     x1, [x4, aux_base-mailbox_base]         // x1 = [aux_base] = 0x000000003f215000 (rpi3) or 0x00000000fe215000 (rpi4)
  ldr     w2, [x1, AUX_ENABLES]                   // w2 = [AUX_ENABLES] (Auxiliary enables)
  orr     w2, w2, #1
  str     w2, [x1, AUX_ENABLES]                   //   [AUX_ENABLES] |= 0x00000001 => Enable Mini UART.
  str     wzr, [x1, AUX_MU_IER]                   //   [AUX_MU_IER_REG] = 0x00000000 => Disable Mini UART interrupts.
  str     wzr, [x1, AUX_MU_CNTL]                  //   [AUX_MU_CNTL_REG] = 0x00000000 => Disable Mini UART Tx/Rx
  mov     w2, #0x6                                // w2 = 6
  str     w2, [x1, AUX_MU_IIR]                    //   [AUX_MU_IIR_REG] = 0x00000006 => Mini UART clear Tx, Rx FIFOs
  mov     w3, #0x3                                // w3 = 3
  str     w3, [x1, AUX_MU_LCR]                    //   [AUX_MU_LCR_REG] = 0x00000003 => Mini UART in 8-bit mode.
  str     wzr, [x1, AUX_MU_MCR]                   //   [AUX_MU_MCR_REG] = 0x00000000 => Set UART1_RTS line high.
  ldr     w2, aux_mu_baud_reg
  str     w2, [x1, AUX_MU_BAUD]                   //   [AUX_MU_BAUD_REG] = 0x0000010e (rpi3) or 0x0000021d (rpi4)
                                                  //         => baudrate = system_clock_freq/(8*([AUX_MU_BAUD_REG]+1))
                                                  //                       (as close to 115200 as possible)
  ldr     x4, [x4, gpio_base-mailbox_base]        // x4 = [gpio_base] = 0x000000003f200000 (rpi3) or 0x00000000fe200000 (rpi4)
  ldr     w2, [x4, GPFSEL1]                       // w2 = [GPFSEL1]
  and     w2, w2, #0xfffc0fff                     // Unset bits 12, 13, 14 (FSEL14 => GPIO Pin 14 is an input).
                                                  // Unset bits 15, 16, 17 (FSEL15 => GPIO Pin 15 is an input).
  orr     w2, w2, #0x00002000                     // Set bit 13 (FSEL14 => GPIO Pin 14 takes alternative function 5).
  orr     w2, w2, #0x00010000                     // Set bit 16 (FSEL15 => GPIO Pin 15 takes alternative function 5).
  str     w2, [x4, GPFSEL1]                       //   [GPFSEL1] = updated value => Enable UART 1.
  str     wzr, [x4, GPPUD]                        //   [GPPUD] = 0x00000000 => GPIO Pull up/down = OFF
  mov     x5, #0x96                               // Wait 150 instruction cycles (as stipulated by datasheet).
1:
  subs    x5, x5, #0x1                            // x0 -= 1
  b.ne    1b                                      // Repeat until x0 == 0.
  mov     w2, #0xc000                             // w2 = 2^14 + 2^15
  str     w2, [x4, GPPUDCLK0]                     //   [GPPUDCLK0] = 0x0000c000 => Control signal to lines 14, 15.
  mov     x0, #0x96                               // Wait 150 instruction cycles (as stipulated by datasheet).
2:
  subs    x0, x0, #0x1                            // x0 -= 1
  b.ne    2b                                      // Repeat until x0 == 0.
  str     wzr, [x4, GPPUDCLK0]                    //   [GPPUDCLK0] = 0x00000000 => Remove control signal to lines 14, 15.
  str     w3, [x1, AUX_MU_CNTL]                   //   [AUX_MU_CNTL_REG] = 0x00000003 => Enable Mini UART Tx/Rx
.if TESTS_INCLUDE
  adrp    x0, uart_disable
  add     x0, x0, :lo12:uart_disable
  strb    wzr, [x0]
.endif
  ret                                             // Return.


# ------------------------------------------------------------------------------
# Send a byte over Mini UART
# ------------------------------------------------------------------------------
# On entry:
#   x0: char to send
# On exit:
#   x1: [aux_base] = 0x000000003f215000 (rpi3) or 0x00000000fe215000 (rpi4)
#   x2: Last read of [AUX_MU_LSR_REG] when waiting for bit 5 to be set
uart_send:
  adr     x1, mailbox_base                        // x1 = mailbox_base
  ldr     x1, [x1, aux_base-mailbox_base]         // x1 = [aux_base] = 0x000000003f215000 (rpi3) or 0x00000000fe215000 (rpi4)
1:
  ldr     w2, [x1, AUX_MU_LSR]                    // w2 = [AUX_MU_LSR_REG]
  tbz     x2, #5, 1b                              // Repeat last statement until bit 5 is set.

/////////////////////
// This following section allows us to disable UART output during testing but
// setting the one byte test system variable 'uart_disable' to a non zero value
// without affecting any register values so to not impact tests.
.if TESTS_INCLUDE
  movl    w2, 0x12323434                          // rpi3/rpi4/qemu hold different values in w2 (from [AUX_MU_LSR_REG]) so use magic value in test
  adrp    x1, uart_disable
  add     x1, x1, :lo12:uart_disable
  ldrb    w1, [x1]
  cbnz    w1, 2f
  adr     x1, mailbox_base                        // x1 = mailbox_base
  ldr     x1, [x1, aux_base-mailbox_base]         // x1 = [aux_base] = 0x000000003f215000 (rpi3) or 0x00000000fe215000 (rpi4)
  b       3f
2:
  adr     x1, mailbox_base                        // x1 = mailbox_base
  ldr     x1, [x1, aux_base-mailbox_base]         // x1 = [aux_base] = 0x000000003f215000 (rpi3) or 0x00000000fe215000 (rpi4)
  ret
3:
.endif
/////////////////////
  strb    w0, [x1, AUX_MU_IO_REG]                 //   [AUX_MU_IO_REG] = w0
  ret

# ------------------------------------------------------------------------------
# Send '\r\n' over Mini UART
# ------------------------------------------------------------------------------
#
# On entry:
#   <nothing>
# On exit:
#   x0: 0x0a
#   x1: [aux_base] = 0x000000003f215000 (rpi3) or 0x00000000fe215000 (rpi4)
#   x2: Last read of [AUX_MU_LSR_REG] when waiting for bit 5 to be set
uart_newline:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  mov     x0, #13
  bl      uart_send
  mov     x0, #10
  bl      uart_send
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# ------------------------------------------------------------------------------
# Send a null terminated string over Mini UART.
# ------------------------------------------------------------------------------
#
# On entry:
#   x0 = address of null terminated string
# On exit:
#   x0 = address of null terminator
#   x1 = [aux_base] = 0x000000003f215000 (rpi3) or 0x00000000fe215000 (rpi4)
#   x2 = 0
#   x3 = [AUX_MU_LSR]
uart_puts:
  adr     x1, mailbox_base                        // x1 = mailbox_base
  ldr     x1, [x1, aux_base-mailbox_base]         // x1 = [aux_base] = 0x000000003f215000 (rpi3) or 0x00000000fe215000 (rpi4)
1:
  ldrb    w2, [x0], #1
  cbz     w2, 5f
  cmp     w2, #127
  b.ne    4f
  mov     w2, '('
2:
  ldr     w3, [x1, AUX_MU_LSR]                    // w3 = [AUX_MU_LSR_REG]
  tbz     x3, #5, 2b                              // Repeat last statement until bit 5 is set.

/////////////////////
// This following section allows us to disable UART output during testing by
// setting the one byte test system variable 'uart_disable' to a non zero value
// without affecting any register values so to not impact tests.
.if TESTS_INCLUDE
  adrp    x1, uart_disable
  add     x1, x1, :lo12:uart_disable
  ldrb    w1, [x1]
  cbnz    x1, uart_puts
  adr     x1, mailbox_base                        // x1 = mailbox_base
  ldr     x1, [x1, aux_base-mailbox_base]         // x1 = [aux_base] = 0x000000003f215000 (rpi3) or 0x00000000fe215000 (rpi4)
.endif
/////////////////////

  strb    w2, [x1, AUX_MU_IO_REG]                 //   [AUX_MU_IO_REG] = w2
  mov     w2, 'c'
3:
  ldr     w3, [x1, AUX_MU_LSR]                    // w3 = [AUX_MU_LSR_REG]
  tbz     x3, #5, 3b                              // Repeat last statement until bit 5 is set.
  strb    w2, [x1, AUX_MU_IO_REG]                 //   [AUX_MU_IO_REG] = w2
  mov     w2, ')'
4:
  ldr     w3, [x1, AUX_MU_LSR]                    // w3 = [AUX_MU_LSR_REG]
  tbz     x3, #5, 4b                              // Repeat last statement until bit 5 is set.

/////////////////////
// This following section allows us to disable UART output during testing by
// setting the one byte test system variable 'uart_disable' to a non zero value
// without affecting any register values so to not impact tests.
.if TESTS_INCLUDE
  adrp    x1, uart_disable
  add     x1, x1, :lo12:uart_disable
  ldrb    w1, [x1]
  cbnz    x1, uart_puts
  adr     x1, mailbox_base                        // x1 = mailbox_base
  ldr     x1, [x1, aux_base-mailbox_base]         // x1 = [aux_base] = 0x000000003f215000 (rpi3) or 0x00000000fe215000 (rpi4)
.endif
/////////////////////

  strb    w2, [x1, AUX_MU_IO_REG]                 //   [AUX_MU_IO_REG] = w2
  b       1b
5:
.if TESTS_INCLUDE
  movl    w3, 0x75364253                          // rpi3/rpi4/qemu hold different values in w3 (from [AUX_MU_LSR_REG]) so use magic value in test
.endif
  ret


# ------------------------------------------------------------------------------
# Write the value of x0 as a hex string (0x0123456789abcdef) to Mini UART.
# ------------------------------------------------------------------------------
#
# On entry:
#   x0 = value to write as a hex string to Mini UART.
uart_x0:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19, x20
  mov     x19, x0                                 // Backup x0 in x19
  sub     sp, sp, #0x20                           // Allocate space on stack for hex string
  mov     w2, 0x7830
  mov     x1, sp
  strh    w2, [x1], #2                            // "0x"
  mov     x2, 64
  bl      hex_x0
  strb    wzr, [x1], #1
  mov     x0, sp
  bl      uart_puts
  add     sp, sp, #0x20
  mov     x0, x19                                 // Restore x0
  ldp     x19, x20, [sp], #16                     // Restore x19, x20
  ldp     x29, x30, [sp], #16                     // Pop frame pointer, procedure link register off stack.
  ret
