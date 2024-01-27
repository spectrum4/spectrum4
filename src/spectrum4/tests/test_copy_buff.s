# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.


# TODO: implement tests, once copy_buff is implemented. Note, copy_buff is
# routine that writes printer buffer to printer, and we don't have a printer
# interface on spectrum4 yet (could potentially write binary data to UART, and
# have software on receiving end to convert to an image).


.text
.align 2
copy_buff_1_setup_regs:
  ret
