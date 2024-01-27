# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


.text
.align 2

chan_p_01_effects:
  _setbit 1, FLAGS
  ret

chan_p_01_effects_regs:
  ldrb    w0, [x28, FLAGS-sysvars]
  ret
