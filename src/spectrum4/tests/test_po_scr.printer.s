# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text
.align 2


.if ROMS_INCLUDE
.else
  .include "chan_flag.s"
  .include "chan_k.s"
  .include "chan_open.s"
  .include "chan_p.s"
  .include "chan_s.s"
  .include "chn_cd_lu.s"
  .include "cl_addr.s"
  .include "cl_set.s"
  .include "indexer.s"
  .include "po_msg.s"
  .include "po_search.s"
  .include "po_store.s"
  .include "po_table.s"
  .include "po_table_1.s"
  .include "print_w0.s"
  .include "temps.s"
.endif


po_scr_printer_setup:
  _setbit 1, FLAGS                                // printing => routine returns and does nothing
  ret


po_scr_printer_setup_regs:
  ldrb    w4, [x28, FLAGS-sysvars]
  ret
