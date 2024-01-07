# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 3
# ---------------------------------
# The 'Initial Channel Information'
# ---------------------------------
# Initially there are four channels ('K', 'S', 'R', & 'P') for communicating
# with the 'keyboard', 'screen', 'workspace' and 'printer'. For each channel
# the output routine address comes before the input routine address and the
# channel's code. This table is almost identical to that in ROM 1 at 0x15AF but
# with changes to the channel P routines to use the RS232 port instead of the
# ZX Printer.
# Used at 0x01DD (ROM 0).
initial_channel_info:                    // L0589
  .quad print_out                                 // PRINT_OUT - K channel output routine.
  .quad key_input                                 // KEY_INPUT - K channel input routine.
  .byte 'K',0,0,0,0,0,0,0                         // 0x4B      - Channel identifier 'K'.
  .quad print_out                                 // PRINT_OUT - S channel output routine.
  .quad report_j                                  // REPORT_J  - S channel input routine.
  .byte 'S',0,0,0,0,0,0,0                         // 0x53      - Channel identifier 'S'.
  .quad add_char                                  // ADD_CHAR  - R channel output routine.
  .quad report_j                                  // REPORT_J  - R channel input routine.
  .byte 'R',0,0,0,0,0,0,0                         // 0x52      - Channel identifier 'R'.
  .quad pout                                      // POUT      - P Channel output routine.
  .quad pin                                       // PIN       - P Channel input routine.
  .byte 'P',0,0,0,0,0,0,0                         // 0x50      - Channel identifier 'P'.
  .quad 0x80                                      // End-marker. Not sure yet why this is needed, but might
                                                  // be so that user can grow this heap-based table and push
                                                  // BASIC program higher up in RAM? The stream data below
                                                  // points directly to entries in this table, so this table
                                                  // isn't iterated through when opening a channel.
initial_channel_info_END:
  nop                                             // remove this later - added so that labels are unique to avoid bugs in finding routines without tests
