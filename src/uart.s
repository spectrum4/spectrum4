.section .text
# ------------------------------------------------------------------------------
# Initialise the UART interface for logging over serial port
# ------------------------------------------------------------------------------
.global setup_uart
setup_uart:
  stp     x29, x30, [sp, #-32]!
  mov     x29, sp
  mov     x0, #0x4                        // #4
  movk    x0, #0x3f20, lsl #16
  // w0 = [0x3f200004-7]
  ldr     w0, [x0]
  str     w0, [x29, #28]
  ldr     w0, [x29, #28]
  // unset bits 12, 13, 14 (FSEL14 => GPIO Pin 14 is an input)
  and     w0, w0, #0xffff8fff
  str     w0, [x29, #28]
  ldr     w0, [x29, #28]
  // set bit 13 (FSEL14 => GPIO Pin 14 takes alternate function 5)
  orr     w0, w0, #0x2000
  str     w0, [x29, #28]
  ldr     w0, [x29, #28]
  // unset bits 15, 16, 17 (FSEL15 => GPIO Pin 15 is an input)
  and     w0, w0, #0xfffc7fff
  str     w0, [x29, #28]
  ldr     w0, [x29, #28]
  // set bit 16
  orr     w0, w0, #0x00010000 // (FSEL15 => GPIO Pin 15 takes alternative function 5)
  str     w0, [x29, #28]
  // w1 = ([0x3f200004-7] OR 0x00012000) AND 0xfffc0fff
  ldr     w1, [x29, #28]
  // x0 = [0x000000003f200004]
  mov     x0, #0x4                        // #4
  movk    x0, #0x3f20, lsl #16
  // write back changes to [0x3f200004-7] => enabled UART 1 (mini UART - Broadcomm's own UART, not the ARM licenced UART)
  str     w1, [x0]
  mov     w1, #0x0                        // #0
  // x0 = 0x000000003f200094
  mov     x0, #0x94                       // #148
  movk    x0, #0x3f20, lsl #16
  // [0x000000003f200094] = 0x00000000
  str     w1, [x0]
  // delay 150 instruction cycles
  mov     x0, #0x96                       // #150
  bl      delay
  // w1 = 0x0000c000
  mov     w1, #0xc000                     // #49152
  // x0 = 0x000000003f200098
  mov     x0, #0x98                       // #152
  movk    x0, #0x3f20, lsl #16
  // [0x000000003f200098] = 0x0000c000
  str     w1, [x0]
  // delay 150 instruction cycles
  mov     x0, #0x96                       // #150
  bl      delay
  // w1 = 0x00000000
  mov     w1, #0x0                        // #0
  // x0 = 0x000000003f200098
  mov     x0, #0x98                       // #152
  movk    x0, #0x3f20, lsl #16
  // [0x000000003f200098] = 0x00000000
  str     w1, [x0]
  // w1 = 0x00000001
  mov     w1, #0x1                        // #1
  // x0 = 0x000000003f215004
  mov     x0, #0x5004                     // #20484
  movk    x0, #0x3f21, lsl #16
  // [0x000000003f215004] = 0x00000001
  str     w1, [x0]
  // w1 = 0x00000000
  mov     w1, #0x0                        // #0
  // x0 = 0x000000003f215060
  mov     x0, #0x5060                     // #20576
  movk    x0, #0x3f21, lsl #16
  // [0x000000003f215060] = 0x00000000
  str     w1, [x0]
  // w1 = 0x00000000
  mov     w1, #0x0                        // #0
  // x0 = 0x000000003f215044
  mov     x0, #0x5044                     // #20548
  movk    x0, #0x3f21, lsl #16
  // [0x000000003f215044] = 0x00000000
  str     w1, [x0]
  // w1 = 0x00000003
  mov     w1, #0x3                        // #3
  // x0 = 0x000000003f21504c
  mov     x0, #0x504c                     // #20556
  movk    x0, #0x3f21, lsl #16
  // [0x000000003f21504c] = 0x00000003
  str     w1, [x0]
  // w1 = 0x00000000
  mov     w1, #0x0                        // #0
  // x0 = 0x000000003f215050
  mov     x0, #0x5050                     // #20560
  movk    x0, #0x3f21, lsl #16
  // [0x000000003f215050] = 0x00000000
  str     w1, [x0]
  // w1 = 0x0000010e (270)
  mov     w1, #0x10e                      // #270
  // x0 = 0x000000003f215068
  mov     x0, #0x5068                     // #20584
  movk    x0, #0x3f21, lsl #16
  // [0x000000003f215068] = 0x0000010e
  str     w1, [x0]
  // w1 = 0x00000003
  mov     w1, #0x3                        // #3
  // x0 = 0x000000003f215060
  mov     x0, #0x5060                     // #20576
  movk    x0, #0x3f21, lsl #16
  // [0x000000003f215060] = 0x00000003
  str     w1, [x0]
  // restore frame pointer, link register
  ldp     x29, x30, [sp], #32
  ret

delay:
  // decrease x0
  subs    x0, x0, #0x1 
  // repeat until x0 = 0
  b.ne    delay
  ret  
