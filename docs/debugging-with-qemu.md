<!--
This file is part of the Spectrum +4 Project.
Licencing information can be found in the LICENCE file
(C) 2021 Spectrum +4 Authors. All rights reserved.
-->

# Debugging Spectrum +4 tests

If a spectrum4 test fails and you would like to interactively debug it, you can
do so using gnu gdb (cross compiled for `aarch64-none-elf`).  You will need it
installed on your host (it isn't included in the docker container).

Run the following command, to see which commands you will need to debug the
test:

```bash
$ src/spectrum4/tests/debug.sh <test_name>
```

This command will output the commands you will need to debug test `<test_name>`.
You will need two sessions for performing the debugging:

*) In the first session, you will run a command to start QEMU in debug mode,
   awaiting instructions over port 1234
*) In the second session, you will run a command to start the debugger on your
   host environment and connect to port 1234 to provide instructions to the qemu
   environment

## Links

  * <https://www.raspberrypi.org/forums/viewtopic.php?t=296084>
  * <https://wiki.osdev.org/Kernel_Debugging#Use_GDB_with_QEMU>
  * <https://www.zeuthen.desy.de/dv/documentation/unixguide/infohtml/gdb/Continuing-and-Stepping.html>
  * <https://www.sourceware.org/gdb/current/onlinedocs/gdb.html>
  * <http://www.nodeadbeef.com/2018/07/bare-metal-aarch64-debugging-on.html>
  * <https://qemu.readthedocs.io/en/v7.1.0/system/gdb.html>
