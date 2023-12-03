# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.arch armv8-a
.cpu cortex-a53

# Note, if we target just rpi4 / rpi400 later, we can change this as follows:
# .cpu cortex-a72

.global _start


.set SCREEN_WIDTH,     1920
.set SCREEN_HEIGHT,    1200
.set BORDER_LEFT,      96
.set BORDER_RIGHT,     96
.set BORDER_TOP,       128
.set BORDER_BOTTOM,    112

.set MAILBOX_REQ_ADDR, 0x0
.set MAILBOX_WRITE,    0x20
.set MAILBOX_STATUS,   0x18
.set MAILBOX_EMPTY_BIT,30
.set MAILBOX_FULL_BIT, 31

.set FIRST_UDG_CHAR,   'A'
.set UDG_COUNT,        21                         // Number of User Defined Graphics to copy (=> 'A'-'U').


.include "macros.s"


.text
.align 2
_start:
# TODO: enable interrupts, set up vector jump tables, switch execution
# level etc, and all the kinds of things to initialise the processor system
# registers, memory virtualisation, initialise sound chip, USB, etc.
# There seems to be a pretty good guide on exactly this here:
#   * https://developer.arm.com/documentation/dai0527/a/
  mrs     x0, mpidr_el1                           // x0 = Multiprocessor Affinity Register value.
  ands    x0, x0, #0x3                            // x0 = core number.
  b.ne    sleep                                   // Put all cores except core 0 to sleep.

# Start L1 Caches if in EL3: not sure if this is working
  mrs     x0, currentel
  and     x0, x0, #0x0c
  cmp     x0, #0x0c
  b.ne    1f

# We are in EL3
  mrs     x0, sctlr_el3                           // x0 = System Control Register (EL3) value
  orr     x0, x0, 0x0004                          // Data Cache (Bit 2)
  orr     x0, x0, 0x1000                          // Instruction Caches (Bit 12)
  msr     sctlr_el3, x0                           // System Control Register (EL3) = x0

##################################################
# Move from EL3 to EL1
  ldr     x0, =0x30d01804
  msr     sctlr_el1, x0                           // Update "System Control Register (EL1)":
                                                  //   set RES:1 bits (11, 20, 22, 23, 28, 29)
                                                  //   enable caches (bits 2, 12)
  mov     x0, 0x80000000
  msr     hcr_el2, x0                             // Update "Hypervisor Configuration Register":
                                                  //   set bit 31 => execution state for EL1 is aarch64
  mov     x0, 0x00000431
  msr     scr_el3, x0                             // Update "Secure Configuration Register":
                                                  //   set bit 0 => EL0 and EL1 are in non-secure state
                                                  //   set RES:1 bits 4, 5
                                                  //   set bit 10 => EL2 is aarch64, EL2 controls EL1 and EL0 behaviors

  mov     x0, 0x000001c5
  msr     spsr_el3, x0                            // Update "Saved Program Status Register (EL3)":
                                                  //   set bit 0 => dedicated stack pointer selected on EL switch to/from EL3
                                                  //   set bit 2 (and clear bit 3) => drop to EL1 on eret
                                                  //   set bit 6 => mask (disable) error (SError) interrupts
                                                  //   set bit 7 => mask (disable) regular (IRQ) interrupts
                                                  //   set bit 8 => mask (disable) fast (FIQ) interrupts
  adr     x0, 2f
  msr     elr_el3, x0                             // Update Exception Link Register (EL3):
                                                  //   set to return address after next `eret`
  eret
# Move from EL3 to EL1 completed
##################################################

1:
# TODO: Check if we are in EL2

2:
# We are in EL1
  adrp    x28, sysvars
  add     x28, x28, :lo12:sysvars                 // x28 will remain at this constant value to make all sys vars available via an immediate offset.
  bl      set_peripherals_addresses
  bl      set_clocks
  bl      uart_init                               // Initialise UART interface.
  bl      init_rpi_model                          // Fetch raspberry pi model identifier into system variable rpi_model.
  bl      init_framebuffer                        // Allocate a frame buffer with chosen screen settings.
  ldr     x0, rand_init
  blr     x0
  ldr     x0, pcie_init
  cbz     x0, 3f
  blr     x0
3:
.if       TESTS_AUTORUN
  bl      fill_memory_with_junk
  ldr     w0, arm_size
  and     sp, x0, #~0x0f                          // Set stack pointer at top of ARM memory
  bl      irq_vector_init
  dsb     sy                                      // TODO: Not sure if this is needed at all, or if a less aggressive barrier can be used
  bl      timer_init
  dsb     sy                                      // TODO: Not sure if this is needed at all, or if a less aggressive barrier can be used
  ldr     x0, enable_ic
  blr     x0
  dsb     sy                                      // TODO: Not sure if this is needed at all, or if a less aggressive barrier can be used
  bl      enable_irq
  bl      run_tests
.endif
.if       ROMS_AUTORUN
  b       restart                                 // Raspberry Pi initialisation complete.
                                                  // Now call entry point in rom0.s which
                                                  // is the converted ZX Spectrum 128k code.
.endif

sleep:
  wfi                                             // Sleep until woken.
  b       sleep                                   // Go to sleep; it has been a long day.


init_rpi_model:
  adr     x0, rpi_model_req                       // x0 = memory block pointer for mailbox call to get rpi model identifier
  mov     x27, x30                                // preserve link register in x27
  bl      mbox_call
  ret     x27


init_framebuffer:
  adr     x0, fb_req                              // x0 = memory block pointer for mailbox call.
  mov     x27, x30
  bl      mbox_call
  ldr     w11, [x0, framebuffer-fb_req]           // w11 = allocated framebuffer address
  and     w11, w11, #0x3fffffff                   // Translate bus address to physical ARM address.
  str     w11, [x0, framebuffer-fb_req]           // Store framebuffer address in framebuffer system variable.
  ret     x27


# Memory block for Raspberry Pi model identifier mailbox call
.align 4
rpi_model_req:
  .word (rpi_model_req_end-rpi_model_req)         // Buffer size
  .word 0                                         // Request/response code
  .word 0x00010001                                // Tag 0 - Get board model
  .word 4                                         //   value buffer size (response > request, so use response size)
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
// On my Raspberry Pi 3 Model B, rpi_model = 0x0
rpi_model:
  .word 0                                         //   request: padding              response: model identifier
  .word 0x00010002                                // Tag 1 - Get board revision
  .word 4                                         //   value buffer size (response > request, so use response size)
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
// Possible values documented at:
//   * https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#new-style-revision-codes-in-use
// On my Raspberry Pi 3 Model B, rpi_revision = 0x00a02082
// On my Raspberry Pi 400, rpi_revision = 0x00c03130
rpi_revision:
  .word 0                                         //   request: padding              response: revision identifier
  .word 0                                         // End Tags
rpi_model_req_end:


# Memory block for GPU mailbox call to allocate framebuffer
.align 4
fb_req:
  .word (fb_req_end-fb_req)                       // Buffer size
  .word 0                                         // Request/response code
  .word 0x00048003                                // Tag 0 - Set Screen Size
  .word 8                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word SCREEN_WIDTH                              //   request: width                response: width
  .word SCREEN_HEIGHT                             //   request: height               response: height
  .word 0x00048004                                // Tag 1 - Set Virtual Screen Size
  .word 8                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word SCREEN_WIDTH                              //   request: width                response: width
  .word SCREEN_HEIGHT                             //   request: height               response: height
  .word 0x00048009                                // Tag 2 - Set Virtual Offset
  .word 8                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word 0                                         //   request: x offset             response: x offset
  .word 0                                         //   request: y offset             response: y offset
  .word 0x00048005                                // Tag 3 - Set Colour Depth
  .word 4                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
                                                  //                   32 bits per pixel => 8 red, 8 green, 8 blue, 8 alpha
                                                  //                   See https://en.wikipedia.org/wiki/RGBA_color_space
  .word 32                                        //   request: bits per pixel       response: bits per pixel
  .word 0x00048006                                // Tag 4 - Set Pixel Order (really is "Colour Order", not "Pixel Order")
  .word 4                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
  .word 0                                         //   request: 0 => BGR, 1 => RGB   response: 0 => BGR, 1 => RGB
  .word 0x00040001                                // Tag 5 - Get (Allocate) Buffer
  .word 8                                         //   value buffer size (response > request, so use response size)
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
framebuffer:
  .word 4096                                      //   request: alignment in bytes   response: frame buffer base address
  .word 0                                         //   request: padding              response: frame buffer size in bytes
  .word 0x00040008                                // Tag 6 - Get Pitch (bytes per line)
  .word 4                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
pitch:
  .word 0                                         //   request: padding              response: bytes per line
  .word 0x00010005                                // Tag 7 - Get ARM memory
  .word 8                                         //   value buffer size
  .word 0                                         //   request: should be 0          response: 0x80000000 (success) / 0x80000001 (failure)
arm_base:
  .word 0                                         //   request: padding              response: base address in bytes
arm_size:
  .word 0                                         //   request: padding              response: size in bytes
  .word 0                                         // End Tags
fb_req_end:



# On entry:
#   x0 = address of mailbox request
# On exit:
#   x0 unchanged
#   x9 corrupted
#   x10 corrupted
#   x11 corrupted
#   x12 corrupted
.align 2
mbox_call:
  ldr     x9, mailbox_base                        // x9 = [mailbox_base] (Mailbox Peripheral Address) = 0x000000003f00b880 (rpi3) or 0x00000000fe00b880 (rpi4)
1:                                                // Wait for mailbox FULL flag to be clear.
  ldr     w10, [x9, MAILBOX_STATUS]               // w10 = mailbox status.
  tbnz    w10, MAILBOX_FULL_BIT, 1b               // If FULL flag set (bit 31), try again...
  mov     w11, 8                                  // Mailbox channel 8.
  orr     w11, w0, w11                            // w11 = encoded request address + channel number.
  str     w11, [x9, MAILBOX_WRITE]                // Write request address / channel number to mailbox write register.
2:                                                // Wait for mailbox EMPTY flag to be clear.
  ldr     w12, [x9, MAILBOX_STATUS]               // w12 = mailbox status.
  tbnz    w12, MAILBOX_EMPTY_BIT, 2b              // If EMPTY flag set (bit 30), try again...
  ldr     w12, [x9, MAILBOX_REQ_ADDR]             // w12 = message request address + channel number.
  cmp     w11, w12                                // See if the message is for us.
  b.ne    2b                                      // If not, try again.
  ret


# On entry:
#   x0 = address
#   w1 = 8 bit value
poke_address:
  stp     x29, x30, [sp, #-16]!                   // Push frame pointer, procedure link register on stack.
  mov     x29, sp                                 // Update frame pointer to new stack location.
  stp     x19, x20, [sp, #-16]!                   // Backup x19 / x20 on stack
  stp     x21, x22, [sp, #-16]!                   // Backup x21 / x22 on stack
  stp     x23, x24, [sp, #-16]!                   // Backup x23 / x24 on stack
  strb    w1, [x0]                                // Poke address
  adrp    x9, display_file                        // Check if address is in display file
  add     x9, x9, :lo12:display_file
  adrp    x24, attributes_file
  add     x24, x24, :lo12:attributes_file
  subs    x11, x0, x9                             // x11 = display file offset
  b.lo    2f                                      // if x0 < x9, jump ahead since before display file
  adrp    x10, display_file_end                   // Now compare address to upper limit of display file
  add     x10, x10, :lo12:display_file_end
  cmp     x0, x10
  b.hs    2f                                      // if x0 >= x10 (display file end) jump ahead since after display file
// x0 in display file
  // framebuffer addresses = pitch*(BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))) + address of framebuffer + 4 * (BORDER_LEFT + 8*(x11%216) + [0-7])
  // attribute address = attributes_file+((x11/2)%108)+108*(((x11/216)%20)+20*(x11/(216*20*16)))
  adrp    x9, fb_req                              // x9 = address of mailbox request.
  add     x9, x9, :lo12:fb_req
  ldr     w10, [x9, framebuffer-fb_req]           // w10 = address of framebuffer
  ldr     w12, [x9, pitch-fb_req]                 // w12 = pitch
  ldr     x13, =0x97b425ed097b425f                // x13 = 0x97b425ed097b425f = 10931403895531586143
  umulh   x14, x13, x11                           // x14 = (10931403895531586143 * x11) / 18446744073709551616 = int(x11*16/27)
  lsr     x14, x14, #7                            // x14 = int(x11/216)
  mov     x15, #0xcccccccccccccccc
  add     x15, x15, #1                            // x15 = 0x0xcccccccccccccccd
  umulh   x16, x15, x14                           // x16 = 14757395258967641293 * int(x11/216) / 2^64 = (4/5) * int(x11/216)
  lsr     x16, x16, #4                            // x16 = int(int(x11/216)/20)
  add     x16, x16, x16, lsl #2                   // x16 = 5 * int(int(x11/216)/20)
  sub     x16, x14, x16, lsl #2                   // x16 = int(x11/216) - 20 * int(int(x11/216)/20) = (x11/216)%20
  ldr     x17, =0xf2b9d6480f2b9d65                // x17 = 0xf2b9d6480f2b9d65 = 17490246232850537829
  umulh   x18, x17, x11                           // x18 = 17490246232850537829 * x11 / 2^64 = int(x11*128/135)
  ubfx    x19, x18, #12, #4                       // x19 = bits 12-15 of int(x11*128/135) = (x11/(216*20)) % 16
  add     x19, x19, x16, lsl #4                   // x19 = (x11/(216*20))%16 + 16*((x11/216)%20)
  lsr     x18, x18, #16                           // x18 = int(x11/(216*20*16))
  add     x18, x18, x18, lsl #2                   // x18 = 5*int(x11/(216*20*16))
  add     x19, x19, x18, lsl #6                   // x19 = (x11/(216*20))%16 + 16*((x11/216)%20) + 320*int(x11/216*20*16)
  add     x19, x19, BORDER_TOP                    // x19 = BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))
  umaddl  x19, w19, w12, x10                      // x19 = pitch*(BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))) + address of framebuffer
  mov     x20, #0xd8                              // x20 = 216
  msub    x21, x20, x14, x11                      // x21 = x11 - int(x11/216)*216 = x11%216
  mov     x22, BORDER_LEFT
  add     x22, x22, x21, lsl #3                   // x22 = BORDER_LEFT + 8*(x11%216)
  add     x23, x19, x22, lsl #2                   // x23 = pitch*(BORDER_TOP + 16*((x11/216)%20) + (x11/(216*20))%16 + 320*(x11/(216*20*16))) + address of framebuffer + 4*(BORDER_LEFT + 8*(x11%216))
  lsr     x10, x11, #1                            // x10 = int(x11/2)
  umulh   x14, x13, x10                           // x14 = int(int(x11/2)*16/27)
  lsr     x14, x14, #6                            // x14 = int(x11/216)
  mov     x12, #0x6c                              // x12 = 108
  msub    x10, x12, x14, x10                      // x10 = int(x11/2)-108*int((x11/2)/108)=(x11/2)%108
  add     x16, x16, x18, lsl #2                   // x16 = (x11/216)%20+20*int(x11/(216*20*16))
  madd    x16, x16, x12, x10                      // x16 = 108*(((x11/216)%20+20*int(x11/(216*20*16))) + (x11/2)%108
  ldrb    w17, [x24, x16]                         // w17 = attribute data
  mov     w20, #0xcc                              // dim
  mov     w21, #0xff                              // bright
  tst     w17, #0x40                              // bright set?
  csel    w22, w20, w21, eq                       // x22 = brightness
// w15 = foreground colour
  tst     w17, #0x02                              // red set?
  csel    w13, wzr, w22, eq
  tst     w17, #0x04                              // green set?
  csel    w14, wzr, w22, eq
  tst     w17, #0x01                              // blue set?
  csel    w15, wzr, w22, eq
  add     w15, w15, w14, lsl #8
  add     w15, w15, w13, lsl #16
// w7 = background colour
  tst     w17, #0x10                              // red set?
  csel    w5, wzr, w22, eq
  tst     w17, #0x20                              // green set?
  csel    w6, wzr, w22, eq
  tst     w17, #0x08                              // blue set?
  csel    w7, wzr, w22, eq
  add     w7, w7, w6, lsl #8
  add     w7, w7, w5, lsl #16
  mov     w8, #8
  1:
    tst     x1, #0x80                             // pixel set?
    csel    w3, w7, w15, eq
    str     w3, [x23], #4
    lsl     w1, w1, #1
    subs    w8, w8, #1
    b.ne    1b
  b       4f
2:
  subs    x11, x0, x24                            // x11 = attributes file offset
  b.lo    4f                                      // if x0 < x24, jump ahead since before attributes file
  adrp    x10, attributes_file_end                // Now compare address to upper limit of attributes file
  add     x10, x10, :lo12:attributes_file_end
  cmp     x0, x10
  b.hs    4f                                      // if x0 >= x10 (attributes file end), jump ahead since after attributes file
// x0 in attributes file
  // TODO: rewrite this section to be more efficient (don't call poke_address recursively)
  add     x10, x9, x11, lsl #1                    // x10 = disp base address + attr offset * 2
  mov     x8, #64800                              // x8 = 216 * 20 * 15
  cmp     x11, #2160                              // x11 >= 108 * 20? (=> attribute in section 1/2)
  csel    x12, x8, xzr, hs                        // If attribute address in section 0, x12 = 0 else 216*20*15
  add     x10, x10, x12                           // If attribute address in section 0 or 1, x10 = display address of top left pixel
  mov     x3, #4320                               // x3 = 108 * 20 * 2 (attribute offset section 2)
  cmp     x11, x3                                 // x11 >= 108 * 20 * 2? (=> attribute in section 2)
  csel    x12, x8, xzr, hs                        // If attribute address in section 0/1, x12 = 0 else 216*20*15
  add     x0, x10, x12                            // x0 = display address of top left pixel
  mov     x3, #16                                 // x3 = pixel row counter (16 -> 0)
  3:
    stp     x3, x0, [sp, #-16]!
    ldrb    w1, [x0]
    bl      poke_address                          // refresh left 8 pixels
    ldp     x3, x0, [sp]
    add     x0, x0, #1                            // next  address
    ldrb    w1, [x0]
    bl      poke_address                          // refresh right 8 pixels
    ldp     x3, x0, [sp], #16
    add     x0, x0, #4000
    add     x0, x0, #320                          // bump x0 by 216*20 - start of next pixel row for current character
    subs    x3, x3, #1                            // decrement counter
    b.ne    3b                                    // repeat until 16 pixel rows updated for current character
4:
  ldp     x23, x24, [sp], #0x10                   // Restore old x23, x24.
  ldp     x21, x22, [sp], #0x10                   // Restore old x21, x22.
  ldp     x19, x20, [sp], #0x10                   // Restore old x19, x20.
  ldp     x29, x30, [sp], #0x10                   // Pop frame pointer, procedure link register off stack.
  ret


# ------------------------------------------------------------------------------
# Wait (at least) x0 instruction cycles.
# ------------------------------------------------------------------------------
wait_cycles:
  subs    x0, x0, #0x1                            // x0 -= 1
  b.ne    wait_cycles                             // Repeat until x0 == 0.
  ret                                             // Return.


# ------------------------------------------------------------------------------
# Wait x0 microseconds
#
# On exit:
#   x0 corrupted
#   x1 corrupted
#   x2 corrupted
#   x3 corrupted
# ------------------------------------------------------------------------------
wait_usec:
  mrs     x1, cntpct_el0                          // Physical count value in all 64 bits
  ldr     x2, =0x431bde82d7b634db                 // 4835703278458516699
  ldr     w3, cntfrq                              // We don't use https://github.com/raspberrypi/tools/blob/master/armstubs/armstub8.S
                                                  // so ARM register cntfrq_el0 is not set for us. Since we are in EL1 when we know if
                                                  // we are on rpi3b or rpi4/rpi400 we can't update cntfrq_el0 (need to be in EL3 to
                                                  // update it) so we have this value in RAM instead.
  mul     x0, x0, x3                              // x0 = entry x0 * clock frequency
  umulh   x0, x0, x2                              // x0 = entry x0 * clock frequency * 4835703278458516699
  lsr     x0, x0, #18                             // x0 = entry x0 * clock frequency * 4835703278458516699 / 4835703278458516698824704
                                                  //    = entry x0 * clock frequency / 1,000,000
                                                  //    = number of oscillations to wait
  1:
    mrs     x2, cntpct_el0                        // x2 = updated counter
    sub     x2, x2, x1                            // x2 = number of oscillations since function start
    cmp     x2, x0                                // compare actual oscillation count against required oscillation count
    b.lo    1b                                    // loop if additional oscillations are required
  ret


.include "uart.s"
.include "reboot.s"
.include "paint.s"


# Converts a uint64 value to ASCII decimal representation. The caller must
# provide a buffer of at least 21 bytes. The result will be written to the end of
# the buffer, including a trailing 0 byte. The start address will be returned.
# The generated decimal string has no left padding with 0's or spaces etc.
#
# On entry:
#   x0 = address of 21 (or more) byte buffer to write to
#   x2 = value to convert to decimal
# On exit:
#   x0 = address of start of string within buffer
#   x1 = first char (byte) of generated string (e.g. 48-57 for '0'-'9', _not_ the address)
#   x2 = 0
#   x3 = 0xcccccccccccccccd
#   x4 = 0
base10:
  add     x0, x0, #0x14                           // x0 = address of last allocated byte
  strb    wzr, [x0]                               // Store 0 in last allocated byte
  mov     x3, #0xcccccccccccccccc
  add     x3, x3, #1                              // x3 = constant for divison by 10
  1:
    umulh   x4, x3, x2
    lsr     x4, x4, #3                            // x4 = x2 / 10
    add     x1, x4, x4, lsl #2                    // x1 = 5 * x4
    sub     x2, x2, x1, lsl #1                    // x2 = x2 % 10 = value of last digit
    add     x1, x2, #0x30                         // x1 = ASCII value of digit = x2 + 48
    strb    w1, [x0, #-1]!                        // store ASCII value on stack at correct offset
    mov     x2, x4                                // x2 = previous x2 / 10
    cbnz    x2, 1b                                // if x2 != 0 continue looping
3:
  ret


.if       UART_DEBUG
msg_init_rand:                 .asciz "Initialising random number generator unit... "
msg_done:                      .asciz "DONE.\r\n"
.endif


.include "rng.s"
.include "pcie.s"
.include "irq.s"
.include "timer.s"


# Set initial values to rpi4 values, and replace at runtime if different machine.
#
# RPi 4/400 (bcm2711):
#   * https://datasheets.raspberrypi.com/bcm2711/bcm2711-peripherals.pdf
#   * https://github.com/raspberrypi/firmware/issues/1374 (implies that low peripherals mode is enabled by default by VPU)

.align 3
mailbox_base:
  .quad     0x00000000fe00b880                    // default is for rpi4
gpio_base:
  .quad     0x00000000fe200000                    // default is for rpi4
aux_base:
  .quad     0x00000000fe215000                    // default is for rpi4
rand_init:
  .quad     rand_init_iproc                       // default is for rpi4
rand_block:
  .quad     rand_block_iproc                      // default is for rpi4
rand_x0:
  .quad     rand_x0_iproc                         // default is for rpi4
aux_mu_baud_reg:
  .word     0x0000021d                            // default is for rpi4
cntfrq:
  .word     54000000                              // default is for rpi4
pcie_init:
  .quad     pcie_init_bcm2711                     // default is for rpi4
local_control:
  .quad     0x00000000ff800000                    // default is for rpi4
timer_base:
  .quad     0x00000000fe003000                    // default is for rpi4
enable_ic:
  .quad     enable_ic_bcm2711                     // default is for rpi4
handle_irq:
  .quad     handle_irq_bcm2711                    // default is for rpi4


# RPi 3B (bcm2837):
#   * https://github.com/raspberrypi/documentation/issues/325 (explains differences between bcm2835 and bcm2837)
#   * https://www.raspberrypi.org/app/uploads/2012/02/BCM2835-ARM-Peripherals.pdf
.align 3
base_rpi3:
# rpi3 mailbox_base
  .quad     0x000000003f00b880
# rpi3 gpio_base
  .quad     0x000000003f200000
# rpi3 aux_base
  .quad     0x000000003f215000
# rpi3 rand_init
  .quad     rand_init_bcm283x
# rpi3 rand_block
  .quad     rand_block_bcm283x
# rpi3 rand_x0
  .quad     rand_x0_bcm283x
# rpi3 aux_mu_baud_reg
  .word     0x0000010e
# rpi3 cntfrq
  .word     19200000
# rpi3 pcie_init
  .quad     0x0000000000000000                    // 0 => no pcie
# rpi3 local_control
  .quad     0x0000000040000000
# rpi3 timer_base
  .quad     0x000000003f003000
# rpi3 enable_ic
  .quad     enable_ic_bcm283x
# rpi3 handle_irq
  .quad     handle_irq_bcm283x


.align 2
set_peripherals_addresses:
  mrs     x0, midr_el1                            // See https://developer.arm.com/documentation/ddi0601/2022-09/AArch64-Registers/MIDR-EL1--Main-ID-Register?lang=en
                                                  // x0 = Main ID Register value 0xNNNNNNNNIIVAPPPR, where:
                                                  //
                                                  // NNNNNNNN = N/A (reserved)
                                                  // II = Implementer
                                                  //   0x00: Reserved for software use
                                                  //   0xc0: Ampere Computing
                                                  //   0x41: Arm Limited
                                                  //   0x42: Broadcom Corporation
                                                  //   0x43: Cavium Inc.
                                                  //   0x44: Digital Equipment Corporation
                                                  //   0x46: Fujitsu Ltd.
                                                  //   0x49: Infineon Technologies AG
                                                  //   0x4d: Motorola or Freescale Semiconductor Inc.
                                                  //   0x4e: NVIDIA Corporation
                                                  //   0x50: Applied Micro Circuits Corporation
                                                  //   0x51: Qualcomm Inc.
                                                  //   0x56: Marvell International Ltd.
                                                  //   0x69: Intel Corporation
                                                  //   0xc0: Ampere Computing
                                                  // V = Variant
                                                  // A = Architecture
                                                  //   0x1: Armv4
                                                  //   0x2: Armv4T
                                                  //   0x3: Armv5(obsolete)
                                                  //   0x4: Armv5T
                                                  //   0x5: Armv5TE
                                                  //   0x6: Armv5TEJ
                                                  //   0x7: Armv6
                                                  //   0xf: Architectural features are individually identified in the ID_* registers, see 'ID registers'
                                                  // PPP = Part Number
                                                  //   0xd03: Raspberry Pi 3B (potentially also 3A+, 3B+, CM 3+, ...)
                                                  // R = Revision
                                                  //
                                                  // e.g.
                                                  //   0x00000000410fd034 (value on my Raspberry Pi 3 Model B)
                                                  //   => Implementer = 0x41 = Arm Limited
                                                  //   => Variant = 0x0 (r0 for r0p4)
                                                  //   => Architecture = 0xf = "features are identified in the ID_* registers"
                                                  //   => Part Number = 0xd03 (presumably, Raspberry Pi 3)
                                                  //   => Revision = 0x4 (p4 for r0p4)
                                                  //   0x00000000410fd083 (value on my Raspberry Pi 400)
                                                  //   => Implementer = 0x41 = Arm Limited
                                                  //   => Variant = 0x0 (r0 for r0p3)
                                                  //   => Architecture = 0xf = "features are identified in the ID_* registers"
                                                  //   => Part Number = 0xd08 (presumably, Raspberry Pi 4)
                                                  //   => Revision = 0x3 (p3 for r0p3)

# mrs     x1, revidr_el1                          // e.g. x1 = 0x80 (value on my Raspberry Pi 3 Model B)
                                                  //           0x00 (value on my Raspberry Pi 400)
  and     x0, x0, #0xfff0
  mov     x1, #0xd030
  cmp     x0, x1
  b.ne    1f
  adr     x0, base_rpi3
  adr     x1, mailbox_base
  ldp     x2, x3, [x0]                            //  x2 = [rpi3 mailbox_base]
                                                  //  x3 = [rpi3 gpio_base]
  ldp     x4, x5, [x0, #16]                       //  x4 = [rpi3 aux_base]
                                                  //  x5 = [rpi3 uart_init]
  ldp     x6, x7, [x0, #32]                       //  x6 = [rpi3 uart_block]
                                                  //  x7 = [rpi3 uart_x0]
  ldp     x8, x9, [x0, #48]                       //  x8 = [rpi3 aux_mu_baud_reg] (bits 0-31)
                                                  //       [rpi3 cntfrq] (bits 32-63)
                                                  //  x9 = [rpi3 pcie_init]
  ldp     x10, x11, [x0, #64]                     // x10 = [rpi3 local_control]
                                                  // x11 = [rpi3 timer_base]
  ldp     x12, x13, [x0, #80]                     // x12 = [rpi3 enable_ic]
                                                  // x13 = [rpi3 handle_irq]
  stp     x2, x3, [x1]                            // [mailbox_base]    = [rpi3 mailbox_base]
                                                  // [gpio_base]       = [rpi3 gpio_base]
  stp     x4, x5, [x1, #16]                       // [aux_base]        = [rpi3 aux_base]
                                                  // [uart_init]       = [rpi3 uart_init]
  stp     x6, x7, [x1, #32]                       // [uart_block]      = [rpi3 uart_block]
                                                  // [uart_x0]         = [rpi3 uart_x0]
  stp     x8, x9, [x1, #48]                       // [aux_mu_baud_reg] = [rpi3 aux_mu_baud_reg] (32 bit)
                                                  // [cntfrq]          = [rpi3 cntfrq] (32 bit)
                                                  // [pcie_init]       = [rpi3 pcie_init]
  stp     x10, x11, [x1, #64]                     // [local_control]   = [rpi3 local_control]
                                                  // [timer_base]      = [rpi3 timer_base]
  stp     x12, x13, [x1, #80]                     // [enable_ic]       = [rpi3 enable_ic]
                                                  // [handle_irq]      = [rpi3 handle_irq]
1:
  ret


.align 2
# Emulates https://github.com/raspberrypi/tools/blob/2e59fc67d465510179155973d2b959e50a440e47/armstubs/armstub8.S#L98-L102
# which seems to be important for the frequency at which ARM register cntpct_el0 increments (used by wait_usec)
set_clocks:
  ldr     x0, local_control
  str     wzr, [x0]
  mov     w1, 0x80000000
  str     w1, [x0, 8]
  ret

.include "armregs.s"
.include "font.s"
.include "entry.s"
