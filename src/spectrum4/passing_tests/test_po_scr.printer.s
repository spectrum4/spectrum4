# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

.text


po_scr_printer_setup:
  _setbit 1, FLAGS                                // printing => routine returns and does nothing
  ret


po_scr_printer_setup_regs:
  ldrb    w4, [x28, FLAGS-sysvars]
  ret
