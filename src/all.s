# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2019 Spectrum +4 Authors. All rights reserved.

.arch armv8-a
.cpu cortex-a53
.global _start

.include "profileflags.s"

.set SCREEN_WIDTH,     1920
.set SCREEN_HEIGHT,    1200
.set BORDER_LEFT,      96
.set BORDER_RIGHT,     96
.set BORDER_TOP,       128
.set BORDER_BOTTOM,    112

.set MAILBOX_BASE,     0x3f00b880
.set MAILBOX_REQ_ADDR, 0x0
.set MAILBOX_WRITE,    0x20
.set MAILBOX_STATUS,   0x18
.set MAILBOX_EMPTY_BIT,30
.set MAILBOX_FULL_BIT, 31

.set FIRST_UDG_CHAR,   'A'
.set UDG_COUNT,        21               // Number of User Defined Graphics to copy (=> 'A'-'U').


.macro _strb val, addr
  mov     w0, \val & 0xff
  adrp    x1, \addr
  add     x1, x1, :lo12:\addr
  strb    w0, [x1]
.endm


.macro _strh val, addr
  mov     w0, \val & 0xffff
  adrp    x1, \addr
  add     x1, x1, :lo12:\addr
  strh    w0, [x1]
.endm


.macro _strhbe val, addr
  mov     w0, ((\val & 0xff) << 8) | ((\val & 0xff00) >> 8)
  adrp    x1, \addr
  add     x1, x1, :lo12:\addr
  strh    w0, [x1]
.endm


.macro _str val, addr
  ldr     x0, =\val
  adrp    x1, \addr
  add     x1, x1, :lo12:\addr
  str     x0, [x1]
.endm


.macro _pixel val, x, y
  adr     x2, framebuffer
  ldr     w0, [x2]
  ldr     w1, [x2, pitch-framebuffer]
  mov     w2, \y
  umaddl  x0, w1, w2, x0
  mov     w1, \x
  movz    x2, \val & 0xffff
  movk    x2, (\val >> 16) & 0xffff, lsl #16
  movk    x2, (\val >> 32) & 0xffff, lsl #32
  movk    x2, (\val >> 48) & 0xffff, lsl #48
  add     x0, x0, x1, lsl #2
  str     x2, [x0]
.endm


# Load a 32-bit immediate using mov.
.macro movl Wn, imm
  movz    \Wn, \imm & 0xffff
  movk    \Wn, (\imm >> 16) & 0xffff, lsl #16
.endm


.macro log char
.if       DEBUG_PROFILE
  stp     x29, x30, [sp, #-16]!
  stp     x0, x1, [sp, #-16]!
  stp     x2, x3, [sp, #-16]!
  stp     x4, x5, [sp, #-16]!
  mov     x0, #\char
  bl      uart_send
  bl      uart_newline
  ldp     x4, x5, [sp], #16
  ldp     x2, x3, [sp], #16
  ldp     x0, x1, [sp], #16
  ldp     x29, x30, [sp], #16
.endif
.endm


.macro logreg index
.if       DEBUG_PROFILE
  stp     x29, x30, [sp, #-16]!
  stp     x0, x1, [sp, #-16]!
  stp     x2, x3, [sp, #-16]!
  stp     x4, x5, [sp, #-16]!
  mov     x0, 'x'
  bl      uart_send
  mov     x2, #\index
  sub     sp, sp, 32
  mov     x0, sp
  bl      base10
  bl      uart_puts
  add     sp, sp, #32
  mov     x0, ':'
  bl      uart_send
  mov     x0, ' '
  bl      uart_send
  ldp     x4, x5, [sp]
  ldp     x2, x3, [sp, #16]
  ldp     x0, x1, [sp, #32]
  mov     x0, x\index
  bl      uart_x0
  bl      uart_newline
  ldp     x4, x5, [sp], #16
  ldp     x2, x3, [sp], #16
  ldp     x0, x1, [sp], #16
  ldp     x29, x30, [sp], #16
.endif
.endm


.macro logregs
  logreg  0
  logreg  1
  logreg  2
  logreg  3
  logreg  4
  logreg  5
  logreg  6
  logreg  7
  logreg  8
  logreg  9
  logreg  10
  logreg  11
  logreg  12
  logreg  13
  logreg  14
  logreg  15
  logreg  16
  logreg  17
  logreg  18
  logreg  19
  logreg  20
  logreg  21
  logreg  22
  logreg  23
  logreg  24
  logreg  25
  logreg  26
  logreg  27
  logreg  28
  logreg  29
  logreg  30
.endm


.macro nzcv value
  tst     wzr, #1
  ccmp    wzr, #0, \value, ne
.endm


.text
.align 2
_start:
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
.if       DEBUG_PROFILE
  bl      rand_init
  bl      fill_memory_with_junk
  ldr     w0, arm_size
  and     sp, x0, #~0x0f                  // Set stack pointer at top of ARM memory
  bl      run_tests
.endif
  b       restart                         // Raspberry Pi 3B initialisation complete.
                                          // Now call entry point in rom0.s which
                                          // is the converted ZX Spectrum 128k code.


sleep:
  wfi                                     // Sleep until woken.
  b       sleep                           // Go to sleep; it has been a long day.


init_framebuffer:
  adr     x0, mbreq                       // x0 = memory block pointer for mailbox call.
  mov     x27, x30
  bl      mbox_call
  mov     x30, x27
  ldr     w11, [x0, framebuffer-mbreq]    // w11 = allocated framebuffer address
  and     w11, w11, #0x3fffffff           // Translate bus address to physical ARM address.
  str     w11, [x0, framebuffer-mbreq]    // Store framebuffer address in framebuffer system variable.
  ret


# Memory block for GPU mailbox call to allocate framebuffer
.data
.align 4
mbreq:
  .word (mbreq_end-mbreq)                 // Buffer size
  .word 0                                 // Request/response code
  .word 0x00048003                        // Tag 0 - Set Screen Size
  .word 8                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word SCREEN_WIDTH                      //   request: width                response: width
  .word SCREEN_HEIGHT                     //   request: height               response: height
  .word 0x00048004                        // Tag 1 - Set Virtual Screen Size
  .word 8                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word SCREEN_WIDTH                      //   request: width                response: width
  .word SCREEN_HEIGHT                     //   request: height               response: height
  .word 0x00048009                        // Tag 2 - Set Virtual Offset
  .word 8                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word 0                                 //   request: x offset             response: x offset
  .word 0                                 //   request: y offset             response: y offset
  .word 0x00048005                        // Tag 3 - Set Colour Depth
  .word 4                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
                                          //                   32 bits per pixel => 8 red, 8 green, 8 blue, 8 alpha
                                          //                   See https://en.wikipedia.org/wiki/RGBA_color_space
  .word 32                                //   request: bits per pixel       response: bits per pixel
  .word 0x00048006                        // Tag 4 - Set Pixel Order (really is "Colour Order", not "Pixel Order")
  .word 4                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word 0                                 //   request: 0 => BGR, 1 => RGB   response: 0 => BGR, 1 => RGB
  .word 0x00040001                        // Tag 5 - Get (Allocate) Buffer
  .word 8                                 //   value buffer size (response > request, so use response size)
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
framebuffer:
  .word 4096                              //   request: alignment in bytes   response: frame buffer base address
  .word 0                                 //   request: padding              response: frame buffer size in bytes
  .word 0x00040008                        // Tag 6 - Get Pitch (bytes per line)
  .word 4                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
pitch:
  .word 0                                 //   request: padding              response: bytes per line
  .word 0x00010005                        // Tag 7 - Get ARM memory
  .word 8                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
arm_base:
  .word 0                                 //   request: padding              response: base address in bytes
arm_size:
  .word 0                                 //   request: padding              response: size in bytes
  .word 0                                 // End Tags
mbreq_end:



# On entry:
#   x0 = address of mailbox request
# On exit:
#   x0 unchanged
.text
.align 2
mbox_call:
  movl     w9, MAILBOX_BASE               // x9 = 0x3f00b880 (Mailbox Peripheral Address)
1:                                      // Wait for mailbox FULL flag to be clear.
  ldr     w10, [x9, MAILBOX_STATUS]       // w10 = mailbox status.
  tbnz    w10, MAILBOX_FULL_BIT, 1b       // If FULL flag set (bit 31), try again...
  mov     w11, 8                          // Mailbox channel 8.
  orr     w11, w0, w11                    // w11 = encoded request address + channel number.
  str     w11, [x9, MAILBOX_WRITE]        // Write request address / channel number to mailbox write register.
2:                                      // Wait for mailbox EMPTY flag to be clear.
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
  b.lo    2f                              // if x0 < x9, jump ahead since before display file
  adr     x10, display_file_end           // Now compare address to upper limit of display file
  cmp     x0, x10
  b.hs    2f                              // if x0 >= x10 (display file end) jump ahead since after display file
// x0 in display file
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
  mov     w20, #0xcc                      // dim
  mov     w21, #0xff                      // bright
  tst     w17, #0x40                      // bright set?
  csel    w22, w20, w21, eq               // x22 = brightness
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
  1:
    tst     x1, #0x80                       // pixel set?
    csel    w3, w7, w15, eq
    str     w3, [x23], #4
    lsl     w1, w1, #1
    subs    w8, w8, #1
    b.ne    1b
  b       4f
2:
  subs    x11, x0, x24                    // x11 = attributes file offset
  b.lo    4f                              // if x0 < x24, jump ahead since before attributes file
  adr     x10, attributes_file_end        // Now compare address to upper limit of attributes file
  cmp     x0, x10
  b.hs    4f                              // if x0 >= x10 (attributes file end), jump ahead since after attributes file
// x0 in attributes file
  // TODO: rewrite this section to be more efficient (don't call poke_address recursively)
  add     x10, x9, x11, lsl #1            // x10 = disp base address + attr offset * 2
  mov     x8, #64800                      // x8 = 216 * 20 * 15
  cmp     x11, #2160                      // x11 >= 108 * 20? (=> attribute in section 1/2)
  csel    x12, x8, xzr, hs                // If attribute address in section 0, x12 = 0 else 216*20*15
  add     x10, x10, x12                   // If attribute address in section 0 or 1, x10 = display address of top left pixel
  mov     x3, #4320                       // x3 = 108 * 20 * 2 (attribute offset section 2)
  cmp     x11, x3                         // x11 >= 108 * 20 * 2? (=> attribute in section 2)
  csel    x12, x8, xzr, hs                // If attribute address in section 0/1, x12 = 0 else 216*20*15
  add     x0, x10, x12                    // x0 = display address of top left pixel
  mov     x3, #16                         // x3 = pixel row counter (16 -> 0)
  3:
    stp     x3, x0, [sp, #-16]!
    ldrb    w1, [x0]
    bl      poke_address                    // refresh left 8 pixels
    ldp     x3, x0, [sp]
    add     x0, x0, #1                      // next  address
    ldrb    w1, [x0]
    bl      poke_address                    // refresh right 8 pixels
    ldp     x3, x0, [sp], #16
    add     x0, x0, #4000
    add     x0, x0, #320                    // bump x0 by 216*20 - start of next pixel row for current character
    subs    x3, x3, #1                      // decrement counter
    b.ne    3b                              // repeat until 16 pixel rows updated for current character
4:
  ldp     x23, x24, [sp], #0x10           // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10           // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10           // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# ------------------------------------------------------------------------------
# Wait (at least) x0 instruction cycles.
# ------------------------------------------------------------------------------
wait_cycles:
  subs    x0, x0, #0x1                    // x0 -= 1
  b.ne    wait_cycles                     // Repeat until x0 == 0.
  ret                                     // Return.


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


.set PM_BASE,                    0x3f100000
.set PM_WDOG,                    0x24
.set PM_RSTC,                    0x1c
.set PM_RSTC_WRCFG_CLR,          0xffffffcf
.set PM_RSTC_WRCFG_FULL_RESET,   0x00000020
.set PM_PASSWORD,                0x5a000000


# ------------------------------------------------------------------------------
# Reboots the machine after ~150us
# See:
#   https://github.com/torvalds/linux/blob/366a4e38b8d0d3e8c7673ab5c1b5e76bbfbc0085/drivers/firmware/raspberrypi.c#L249-L257
#   https://github.com/torvalds/linux/blob/366a4e38b8d0d3e8c7673ab5c1b5e76bbfbc0085/drivers/watchdog/bcm2835_wdt.c#L100-L123
# ------------------------------------------------------------------------------
reboot:
.if       DEBUG_PROFILE
  adr     x0, msg_rebooting
  mov     x1, #48
  mov     x2, #59
  mov     x3, #0x00ffffff
  mov     x4, #0x00ff0000
  bl      paint_string
.endif
  mov     x0, 0x8000000
  bl      wait_cycles
  adr     x0, mbox_reboot
  bl      mbox_call
  mov     x0, PM_BASE
  mov     w1, PM_PASSWORD
  orr     w2, w1, #0x0c
  str     w2, [x0, PM_WDOG]               // [0x3f100024] = 0x5a00000a
  ldr     w3, [x0, PM_RSTC]
  and     w3, w3, PM_RSTC_WRCFG_CLR
  orr     w3, w3, w1
  orr     w3, w3, PM_RSTC_WRCFG_FULL_RESET
  str     w3, [x0, PM_RSTC]               // [0x3f10001c] = ([0x3f10001c] & 0xffffffcf) | 0x5a000020
# msr     daifset, #2
  b       sleep


# Memory block for GPU mailbox call to advise of incoming reboot
.data
.align 4
mbox_reboot:
  .word (mbox_reboot_end-mbox_reboot)     // Buffer size = 24 = 0x18
  .word 0                                 // Request/response code
  .word 0x00030048                        // Tag 0 - RPI_FIRMWARE_NOTIFY_REBOOT
  .word 0                                 //   value buffer size
  .word 0                                 //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word 0                                 // End Tags
mbox_reboot_end:


# On entry:
#   w0 = colour to paint border
.text
.align 2
paint_border:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!           // Push x19, x20 on the stack so x19 can be used in this function.
  mov     w19, w0                         // w19 = w0 (colour to paint border)
  mov     w0, 0                           // Paint rectangle from 0,0 (top left of screen) with width
  mov     w1, 0                           // SCREEN_WIDTH and height BORDER_TOP in colour w19 (border colour).
  mov     w2, SCREEN_WIDTH                // This is the border across the top of the screen.
  mov     w3, BORDER_TOP
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, 0                           // Paint left border in border colour. This starts below the top
  mov     w1, BORDER_TOP                  // border (0, BORDER_TOP) and is BORDER_LEFT wide and stops above
  mov     w2, BORDER_LEFT                 // the bottom border (drawn later in function).
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, SCREEN_WIDTH-BORDER_RIGHT   // Paint the right border in border colour. This also starts below
  mov     w1, BORDER_TOP                  // the top border, but on the right of the screen, and is
  mov     w2, BORDER_RIGHT                // BORDER_RIGHT wide. It also stops immediately above bottom border.
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  mov     w0, 0                           // Paint the bottom border in border colour. This is BORDER_BOTTOM
  mov     w1, SCREEN_HEIGHT-BORDER_BOTTOM // high, and is as wide as the screen.
  mov     w2, SCREEN_WIDTH
  mov     w3, BORDER_BOTTOM
  mov     w4, w19
  bl      paint_rectangle
  ldp     x19, x20, [sp], #0x10           // Restore x19 so no calling function is affected.
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


# On entry:
#   w0 = x
#   w1 = y
#   w2 = width (pixels)
#   w3 = height (pixels)
#   w4 = colour
paint_rectangle:
  adr     x9, mbreq                       // x9 = address of mailbox request.
  ldr     w10, [x9, framebuffer-mbreq]    // w10 = address of framebuffer
  ldr     w11, [x9, pitch-mbreq]          // w11 = pitch
  umaddl  x10, w1, w11, x10               // x10 = address of framebuffer + y*pitch
  add     w10, w10, w0, lsl #2            // w10 = address of framebuffer + y*pitch + x*4
  fill_rectangle:                         // Fills entire rectangle
    mov     w12, w10                        // w12 = reference to start of line
    mov     w13, w2                         // w13 = width of line
    fill_line:                              // Fill a single row of the rectangle with colour.
      str     w4, [x10], 4                    // Colour current point, and update x10 to next point.
      subs    w13, w13, 1                     // Decrease horizontal pixel counter.
      b.ne    fill_line                       // Repeat until line complete.
    add     w10, w12, w11                   // x10 = start of current line + pitch = start of new line.
    subs    w3, w3, 1                       // Decrease vertical pixel counter.
    b.ne    fill_rectangle                  // Repeat until all framebuffer lines complete.
  ret


# On entry:
#   w0 = colour to paint main screen
paint_window:
  stp     x29, x30, [sp, #-16]!           // Push frame pointer, procedure link register on stack.
  mov     x29, sp                         // Update frame pointer to new stack location.
  mov     w4, w0                          // Paint a single rectange that fills the gap inside the
  mov     w0, BORDER_LEFT                 // four borders of the screen.
  mov     w1, BORDER_TOP
  mov     w2, SCREEN_WIDTH-BORDER_LEFT-BORDER_RIGHT
  mov     w3, SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM
  bl      paint_rectangle
  ldp     x29, x30, [sp], #0x10           // Pop frame pointer, procedure link register off stack.
  ret


.bss

.align 4                                // Make sure sysvars at least start at a reasonable boundary (16 byte)
                                        // to aid caching, simplify copying memory block, etc.

sysvars:
.align 0
COL:            .space 1                // Current column from 1 to WIDTH. Set to 0 by NEW command.
WIDTH:          .space 1                // Paper column width. Default value of 80.
TVPARS:         .space 1                // Number of inline parameters expected by RS232 (e.g. 2 for AT).
RASP:           .space 1                // Length of warning buzz.
PIP:            .space 1                // Length of keyboard click.
FLAGS:          .space 1                // Flags to control the BASIC system:
                                        //   Bit 0: 1=Suppress leading space.
                                        //   Bit 1: 1=Using printer, 0=Using screen.
                                        //   Bit 2: 1=Print in L-Mode, 0=Print in K-Mode.
                                        //   Bit 3: 1=L-Mode, 0=K-Mode.
                                        //   Bit 4: 1=128K Mode, 0=48K Mode. [Always 0 on 48K Spectrum].
                                        //   Bit 5: 1=New key press code available in LAST_K.
                                        //   Bit 6: 1=Numeric variable, 0=String variable.
                                        //   Bit 7: 1=Line execution, 0=Syntax checking.
FLAGS2:         .space 1                // Flags:
                                        //   Bit 0  : 1=Screen requires clearing.
                                        //   Bit 1  : 1=Printer buffer contains data.
                                        //   Bit 2  : 1=In quotes.
                                        //   Bit 3  : 1=CAPS LOCK on.
                                        //   Bit 4  : 1=Using channel 'K'.
                                        //   Bit 5-7: Not used (always 0).
TV_FLAG:        .space 1                // Flags associated with the TV:
                                        //   Bit 0  : 1=Using lower editing area, 0=Using main screen.
                                        //   Bit 1-2: Not used (always 0).
                                        //   Bit 3  : 1=Mode might have changed.
                                        //   Bit 4  : 1=Automatic listing in main screen, 0=Ordinary listing in main screen.
                                        //   Bit 5  : 1=Lower screen requires clearing after a key press.
                                        //   Bit 6  : 1=Tape Loader option selected (set but never tested). [Always 0 on 48K Spectrum]
                                        //   Bit 7  : Not used (always 0).
BORDCR:         .space 1                // Border colour multiplied by 8; also contains the attributes normally used for the lower half.
ERR_NR:         .space 1                // 1 less than the report code. Starts off at 255 (for -1).
DF_SZ:          .space 1                // The number of lines (including one blank line) in the lower part of the screen. (1-60)
SCR_CT:         .space 1                // Counts scrolls - it is always 1 more than the number of scrolls that will be done before
                                        // stopping with 'scroll?'.
P_POSN:         .space 1                // 109-column number of printer position.
ECHO_E_COL:     .space 1                // 109-column number (in lower half) of end of input buffer.
ECHO_E_ROW:     .space 1                // 60-line number (in lower half) of end of input buffer.
S_POSN_COL:     .space 1                // 109-column number for PRINT position.
S_POSN_ROW:     .space 1                // 60-line number for PRINT position.
S_POSNL_COL:    .space 1                // Like S_POSN_COL for lower part.
S_POSNL_ROW:    .space 1                // Like S_POSN_ROW for lower part.
P_FLAG:         .space 1                // Flags:
                                        //   Bit 0: Temporary 1=OVER 1, 0=OVER 0.
                                        //   Bit 1: Permanent 1=OVER 1, 0=OVER 0.
                                        //   Bit 2: Temporary 1=INVERSE 1, 0=INVERSE 0.
                                        //   Bit 3: Permanent 1=INVERSE 1, 0=INVERSE 0.
                                        //   Bit 4: Temporary 1=Using INK 9.
                                        //   Bit 5: Permanent 1=Using INK 9.
                                        //   Bit 6: Temporary 1=Using PAPER 9.
                                        //   Bit 7: Permanent 1=Using PAPER 9.
BREG:           .space 1                // Calculator's B register.

.align 1
REPDEL:         .space 1                // Place REPDEL in .align 1 section since REPDEL+REPPER is read/written together as a halfword.
                                        // Time (in 50ths of a second) that a key must be held down before it repeats. This starts off at 35.
REPPER:         .space 1                // Delay (in 50ths of a second) between successive repeats of a key held down - initially 5.
ATTR_P:         .space 1                // Permanent current colours, etc, as set up by colour statements.
MASK_P:         .space 1                // Used for transparent colours, etc. Any bit that is 1 takes value from current attribute value, 0 from ATTR_P/T.
ATTR_T:         .space 1                // Temporary current colours (as set up by colour items).
MASK_T:         .space 1                // Like MASK_P, but temporary.
BAUD:           .space 2                // Baud rate timing constant for RS232 socket. Default value of 11. [Name clash with ZX Interface 1 system variable at 0x5CC3]
SERFL:          .space 2                // Byte 0: Second character received flag:
                                        //           Bit 0   : 1=Character in buffer.
                                        //           Bits 1-7: Not used (always hold 0).
                                        // Byte 1: Received Character.
RNFIRST:        .space 2                // Starting line number when renumbering. Default value of 10.
RNSTEP:         .space 2                // Step size when renumbering. Default value of 10.
STRMS:          .space 2*19             // Address offsets of 19 channels attached to streams.

.align 2
COORDS:         .space 2                // X-coordinate of last point plotted.
COORDS_Y:       .space 2                // Y-coordinate of last point plotted.
TVDATA:         .space 2                // Stores bytes of colour, AT and TAB controls going to TV.

.align 3
SFNEXT:         .space 8                // End of RAM disk catalogue marker. Pointer to first empty catalogue entry.
SFSPACE:        .space 8                // Number of bytes free in RAM disk.
CHARS:          .space 8                // 256 less than address of character set, which starts with ' ' and carries on to '©'.
LIST_SP:        .space 8                // Address of return address from automatic listing.

# Pointers to inside the HEAP
VARS:           .space 8                // Address of variables.
# DEST:           .space 8                // Address of variable in assignment.
CHANS:          .space 8                // Address of channel data.
CURCHL:         .space 8                // Address of information currently being used for input and output.
PROG:           .space 8                // Address of BASIC program.
# NXTLIN:         .space 8                // Address of next line in program.
DATADD:         .space 8                // Address of terminator of last DATA item.
E_LINE:         .space 8                // Address of command being typed in.
# K_CUR:          .space 8                // Address of cursor.
CH_ADD:         .space 8                // Address of the next character to be interpreted - the character after the argument of PEEK,
                                        // or the NEWLINE at the end of a POKE statement.
X_PTR:          .space 8                // Address of the character after the '?' marker.
WORKSP:         .space 8                // Address of temporary work space.
STKBOT:         .space 8                // Address of bottom of calculator stack.
STKEND:         .space 8                // Address of start of spare space.

# Other pointers
RAMTOP:         .space 8                // Address of last byte of BASIC system area.
P_RAMT:         .space 8                // Address of last byte of physical RAM.
UDG:            .space 8                // Address of first user-defined graphic. Can be changed to save space by having fewer.
ERR_SP:         .space 8                // Address of item on machine stack to be used as error return.

# Editor
DF_CC:          .space 8                // Address in display file of PRINT position.
DF_CCL:         .space 8                // Like DF CC for lower part of screen.
PR_CC:          .space 8                // Full address of next position for LPRINT to print at (in ZX Printer buffer).
                                        // Legal values in printer_buffer range. [Not used in 128K mode]
MEMBOT:         .space 32               // Calculator's memory area - used to store numbers that cannot conveniently be put on the
                                        // calculator stack.

.align 4                                // Ensure sysvars_end is at a 16 byte boundary.
sysvars_end:

printer_buffer: .space 0xd80            // Printer buffer used by 48K Basic but not by 128K Basic (see docs/printer-buffer.md)
printer_buffer_end:

# Memory regions
display_file:   .space (SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM)*(SCREEN_WIDTH-BORDER_LEFT-BORDER_RIGHT)/8
                                        // One pixel per bit => 8 pixels per byte
display_file_end:
attributes_file:.space (SCREEN_HEIGHT-BORDER_TOP-BORDER_BOTTOM)*(SCREEN_WIDTH-BORDER_LEFT-BORDER_RIGHT)/256
                                        // 16*16 pixels per attribute record => 256 pixles per byte
attributes_file_end:
ram_disk:       .space RAM_DISK_SIZE
heap:           .space HEAP_SIZE





.include "font.s"
.include "rom0.s"
.include "rom1.s"
.include "profile.s"
