# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2
# -------------------------------------
# Update Current Channel Output Routine
# -------------------------------------
#
# On entry:
#   x4 = function pointer for handling 1 or 2 control chars (po_cont or po_tv_2)
# On exit:
#   [[CURCHL]] = x4
#   x5 = [CURCHL]
po_change:                               // L0A80
  ldr     x5, [x28, CURCHL-sysvars]               // x5 = [CURCHL]
  str     x4, [x5]                                // Set current channel output routine
  ret
