# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

# ------------------------------------------------------------------------------
# See "BCM2837 ARM Peripherals" datasheet pages 8-19:
#   https://cs140e.sergio.bz/docs/BCM2837-ARM-Peripherals.pdf
# ------------------------------------------------------------------------------
.set AUX_BASE,       0x3f215000

.set AUX_IRQ,        0x0000  // Auxiliary Interrupt Status
.set AUX_ENABLES,    0x0004  // Auxiliary Enables
.set AUX_MU_IO_REG,  0x0040  // Mini Uart I/O Data
.set AUX_MU_IER,     0x0044  // Mini Uart Interrupt Enable
.set AUX_MU_IIR,     0x0048  // Mini Uart Interrupt Identify
.set AUX_MU_LCR,     0x004C  // Mini Uart Line Control
.set AUX_MU_MCR,     0x0050  // Mini Uart Modem Control
.set AUX_MU_LSR,     0x0054  // Mini Uart Line Status
.set AUX_MU_MSR,     0x0058  // Mini Uart Modem Status
.set AUX_MU_SCRATCH, 0x005C  // Mini Uart Scratch
.set AUX_MU_CNTL,    0x0060  // Mini Uart Extra Control
.set AUX_MU_STAT,    0x0064  // Mini Uart Extra Status
.set AUX_MU_BAUD,    0x0068  // Mini Uart Baudrate


# ------------------------------------------------------------------------------
# See "BCM2837 ARM Peripherals" datasheet pages 90-104:
#   https://cs140e.sergio.bz/docs/BCM2837-ARM-Peripherals.pdf
# ------------------------------------------------------------------------------
.set GPIO_BASE,      0x3f200000

.set GPFSEL1,        0x0004  // GPIO Function Select 1
.set GPPUD,          0x0094  // GPIO Pin Pull-up/down Enable
.set GPPUDCLK0,      0x0098  // GPIO Pin Pull-up/down Enable Clock 0

.text

# ------------------------------------------------------------------------------
# Initialise the Mini UART interface for logging over serial port.
# Note, this is Broadcomm's own UART, not the ARM licenced UART interface.
# ------------------------------------------------------------------------------
uart_init:
  mov     x1, AUX_BASE & 0xffff0000
  movk    x1, AUX_BASE & 0x0000ffff       // x1 = 0x3f215000 = AUX_BASE
  ldr     w2, [x1, AUX_ENABLES]           // w2 = [0x3f215004] = [AUX_ENABLES] (Auxiliary enables)
  orr     w2, w2, #1
  str     w2, [x1, AUX_ENABLES]           //   [AUX_ENABLES] |= 0x00000001 => Enable Mini UART.
  str     wzr, [x1, AUX_MU_IER]           //   [AUX_MU_IER_REG] = 0x00000000 => Disable Mini UART interrupts.
  str     wzr, [x1, AUX_MU_CNTL]          //   [AUX_MU_CNTL_REG] = 0x00000000 => Disable Mini UART Tx/Rx
  mov     w2, #0x6                        // w2 = 6
  str     w2, [x1, AUX_MU_IIR]            //   [AUX_MU_IIR_REG] = 0x00000006 => Mini UART clear Tx, Rx FIFOs
  mov     w3, #0x3                        // w3 = 3
  str     w3, [x1, AUX_MU_LCR]            //   [AUX_MU_LCR_REG] = 0x00000003 => Mini UART in 8-bit mode.
  str     wzr, [x1, AUX_MU_MCR]           //   [AUX_MU_MCR_REG] = 0x00000000 => Set UART1_RTS line high.
  mov     w2, #0x10e                      // w2 = 270
  str     w2, [x1, AUX_MU_BAUD]           //   [AUX_MU_BAUD_REG] = 0x0000010e
                                          //         => baudrate = system_clock_freq/(8*(270+1))
                                          //                     = 250MHz/(8*271) ~= 115314
                                          //                       (as close to 115200 as possible)
  mov     x4, GPIO_BASE                   // x4 = 0x3f200000 = GPIO_BASE
  ldr     w2, [x4, GPFSEL1]               // w2 = [GPFSEL1]
  and     w2, w2, #0xfffc0fff             // Unset bits 12, 13, 14 (FSEL14 => GPIO Pin 14 is an input).
                                          // Unset bits 15, 16, 17 (FSEL15 => GPIO Pin 15 is an input).
  orr     w2, w2, #0x00002000             // Set bit 13 (FSEL14 => GPIO Pin 14 takes alternative function 5).
  orr     w2, w2, #0x00010000             // Set bit 16 (FSEL15 => GPIO Pin 15 takes alternative function 5).
  str     w2, [x4, GPFSEL1]               //   [GPFSEL1] = updated value => Enable UART 1.
  str     wzr, [x4, GPPUD]                //   [GPPUD] = 0x00000000 => GPIO Pull up/down = OFF
  mov     x5, #0x96                       // Wait 150 instruction cycles (as stipulated by datasheet).
1:
  subs    x5, x5, #0x1                    // x0 -= 1
  b.ne    1b                              // Repeat until x0 == 0.
  mov     w2, #0xc000                     // w2 = 2^14 + 2^15
  str     w2, [x4, GPPUDCLK0]             //   [GPPUDCLK0] = 0x0000c000 => Control signal to lines 14, 15.
  mov     x0, #0x96                       // Wait 150 instruction cycles (as stipulated by datasheet).
2:
  subs    x0, x0, #0x1                    // x0 -= 1
  b.ne    2b                              // Repeat until x0 == 0.
  str     wzr, [x4, GPPUDCLK0]            //   [GPPUDCLK0] = 0x00000000 => Remove control signal to lines 14, 15.
  str     w3, [x1, AUX_MU_CNTL]           //   [AUX_MU_CNTL_REG] = 0x00000003 => Enable Mini UART Tx/Rx
  ret                                     // Return.


# ------------------------------------------------------------------------------
# Send a byte over Mini UART
# ------------------------------------------------------------------------------
uart_send:
  mov     x1, AUX_BASE & 0xffff0000
  movk    x1, AUX_BASE & 0x0000ffff       // x1 = 0x3f215000 = AUX_BASE
1:
  ldr     w2, [x1, AUX_MU_LSR]            // w2 = [AUX_MU_LSR_REG]
  tbz     x2, #5, 1b                      // Repeat last statement until bit 5 is set.
  strb    w0, [x1, AUX_MU_IO_REG]         //   [AUX_MU_IO_REG] = w0
  ret


# ------------------------------------------------------------------------------
# Send '\r\n' over Mini UART
# ------------------------------------------------------------------------------
uart_newline:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     x0, #13
  bl      uart_send
  mov     x0, #10
  bl      uart_send
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# ------------------------------------------------------------------------------
# Send a null terminated string over Mini UART.
# ------------------------------------------------------------------------------
uart_puts:
  mov     x1, AUX_BASE & 0xffff0000
  movk    x1, AUX_BASE & 0x0000ffff       // x1 = 0x3f215000 = AUX_BASE
1:
  ldrb    w2, [x0], #1
  cbz     w2, 5f
  cmp     w2, #127
  b.ne    4f
  mov     w2, '('
2:
  ldr     w3, [x1, AUX_MU_LSR]            // w3 = [AUX_MU_LSR_REG]
  tbz     x3, #5, 2b                      // Repeat last statement until bit 5 is set.
  strb    w2, [x1, AUX_MU_IO_REG]         //   [AUX_MU_IO_REG] = w2
  mov     w2, 'c'
3:
  ldr     w3, [x1, AUX_MU_LSR]            // w3 = [AUX_MU_LSR_REG]
  tbz     x3, #5, 3b                      // Repeat last statement until bit 5 is set.
  strb    w2, [x1, AUX_MU_IO_REG]         //   [AUX_MU_IO_REG] = w2
  mov     w2, ')'
4:
  ldr     w3, [x1, AUX_MU_LSR]            // w3 = [AUX_MU_LSR_REG]
  tbz     x3, #5, 4b                      // Repeat last statement until bit 5 is set.
  strb    w2, [x1, AUX_MU_IO_REG]         //   [AUX_MU_IO_REG] = w2
  b       1b
5:
  ret
