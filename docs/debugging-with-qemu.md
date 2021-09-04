Session 1:

```
qemu-system-aarch64 -s -S -M raspi3b -kernel build/spectrum4/kernel8-qemu-debug.elf -serial null -serial stdio
```

Session 2:

```
aarch64-none-elf-gdb build/spectrum4/kernel8-qemu-debug.elf
# (gdb) target remote localhost:1234
(gdb) target extended-remote localhost:1234
(gdb) disassemble
(gdb) si
```


Links

* https://www.raspberrypi.org/forums/viewtopic.php?t=296084
* https://wiki.osdev.org/Kernel_Debugging#Use_GDB_with_QEMU
* https://www.zeuthen.desy.de/dv/documentation/unixguide/infohtml/gdb/Continuing-and-Stepping.html
* https://www.sourceware.org/gdb/current/onlinedocs/gdb.html
* http://www.nodeadbeef.com/2018/07/bare-metal-aarch64-debugging-on.html
* https://qemu.readthedocs.io/en/latest/system/gdb.html
