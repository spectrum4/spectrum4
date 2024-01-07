# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
# --------------------------
# Channel code look-up table
# --------------------------
# This table is used to find one of the three flag setting routines. A zero
# end-marker is required as channel 'R' is not present.
.align 3
chn_cd_lu:                               // L162D
  .quad 0x0000000000000003                        // 3 records
  .byte 'K',0,0,0,0,0,0,0                         // 0x4B - Channel identifier 'K'.
  .quad chan_k
  .byte 'S',0,0,0,0,0,0,0                         // 0x53 - Channel identifier 'S'.
  .quad chan_s
  .byte 'P',0,0,0,0,0,0,0                         // 0x50 - Channel identifier 'P'.
  .quad chan_p
