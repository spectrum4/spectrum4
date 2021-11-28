.text
.align 1
# -------------------------
# The 'Initial Stream Data'
# -------------------------
# Initially there are seven streams: -3 to 3.
# This table is identical to that in ROM 1 at 0x15C6.
initial_stream_data:                     // L059E
  .byte 0x01, 0x00                                // Stream -3 leads to channel 'K'.
  .byte 0x19, 0x00                                // Stream -2 leads to channel 'S'.
  .byte 0x31, 0x00                                // Stream -1 leads to channel 'R'.
  .byte 0x01, 0x00                                // Stream  0 leads to channel 'K'.
  .byte 0x01, 0x00                                // Stream  1 leads to channel 'K'.
  .byte 0x19, 0x00                                // Stream  2 leads to channel 'S'.
  .byte 0x49, 0x00                                // Stream  3 leads to channel 'P'.
initial_stream_data_END:
  nop                                             // remove this later - added so that labels are unique to avoid bugs in finding routines without tests
