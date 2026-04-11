// This file is part of the Spectrum +4 Project.
// Licencing information can be found in the LICENCE file
// (C) 2021-2026 Spectrum +4 Authors. All rights reserved.


.text
.align 1
// -------------------------
// The 'Initial Stream Data'
// -------------------------
// Initially there are seven streams: -3 to 3.
// This table is identical to that in ROM 1 at 0x15c6.
initial_stream_data:                     // L059E
  .byte 0x01, 0x00                                // Stream -3 leads to channel 'K'.
  .byte 0x19, 0x00                                // Stream -2 leads to channel 'S'.
  .byte 0x31, 0x00                                // Stream -1 leads to channel 'R'.
  .byte 0x01, 0x00                                // Stream  0 leads to channel 'K'.
  .byte 0x01, 0x00                                // Stream  1 leads to channel 'K'.
  .byte 0x19, 0x00                                // Stream  2 leads to channel 'S'.
  .byte 0x49, 0x00                                // Stream  3 leads to channel 'P'.
initial_stream_data_END:
.if UART_DEBUG                                    // when debugging, add space here, so that
  .space 4                                        // initial_stream_data_END does not share value with
.endif                                            // whatever symbol follows, to simplify debugging.
