# ZX Spectrum +4

A modern-day ZX Spectrum OS rewritten from scratch in ARM assembly (aarch64) to
run natively on RPi +3B. Based on the Spectrum 128K.

If you are not familiar with the ZX Spectrum computer from the 1980's, there
are some excellent emulators around, such as [Retro Virtual
Machine](http://www.retrovirtualmachine.org/), and even some very good online
emulators that you can run directly in your browser.

For more information about the history and development of this project, see
https://github.com/spectrum4/notes.

__Please note this project is very much in its infancy.__

__Only a handful of routines have been ported/implemented so far.__

# Variations from the Spectrum 128K

The Spectrum +4 is intentionally incompatible with the original Spectrum. If
you wish to run original ZX Spectrum software, there are some excellent
emulators available such as [Retro Virtual
Machine](https://www.retrovirtualmachine.org/en/), or for the Raspberry Pi see
[ZXBaremulator](http://zxmini.speccy.org/en/index.html), as well as new
[compatible hardware](https://www.specnext.com/shop/).

The idea behind this project is to imagine what Sinclair/Amstrad might have
developed for their next Spectrum, if Raspberry Pi 3B hardware had been
available at the time, rather than to reproduce what they already had.

It is also an excuse for me to learn bare metal programming and aarch64
assembly. :-)

With that in mind, the following sections outline the differences between
Spectrum +4 and the original ZX Spectrum 128K.

## Graphics

![Screen loading demo](animated.gif)

In order to retain the spirit of the original Spectrum computers, the video
display preserves many of the original Spectrum principles:

  * The original colour palette
  * The original character cell restrictions
    * Each character cell is limited to a single 3 bit paper and 3 bit ink
      colour
    * Each character cell may be `BRIGHT` or not
    * Each character cell may `FLASH` or not
  * A solid border colour around the edges of the display

However, the screen geometry has changed a little:

  * Each character cell is now 16x16 pixels, rather than 8x8 pixels
  * The screen now is 108 character cells wide instead of 32
  * The screen now is 60 character cells high instead of 24

The border thickness is equivalent to the original Spectrum 128K in terms of
equivalent character cell counts:

  * Left border: 6 characters wide
  * Right border: 6 characters wide
  * Top border: 8 characters high
  * Bottom border: 7 characters high

This matches the original screen geometry (which had 8 pixels per character):
  * http://www.zxdesign.info/vidparam.shtml

In order to enforce the video restrictions, updates to the display file and
attributes file are trapped by the `poke_address` routine which syncs the
VideoCore IV GPU firmware framebuffer with the display file and attributes
file. This is rather inefficient, but I don't know a better way (yet) to handle
this for now.

The display file and attributes file differ from the Spectrum 128K as follows:

  * Each vertical screen third is now 20 character cells high rather than 8
  * Each cell now has 16 pixel rows instead of 8
  * A single pixel row of a character cell now requires 2 bytes instead of 1

The mechanics of converting memory addresses to `(x, y)` coordinates is no
longer a matter of simple bit manipulation. This is a consequence of the
dimensions no longer being powers of 2. However, sequencially updating bytes in
the display and attributes file simulates the original screen loading
mechanics, which is nice to have preserved.


## Memory

The Raspberry Pi 3B has 1GB RAM, which is considerably more than the Spectrum
128K.  Using the 64 bit instruction set means that most of the memory paging
routines in the original Spectrum can be mostly ignored and don't require
translation. It also means that there is much more space available for BASIC
programs, machine code routines, and RAM disk storage.

* Spectrum +4 is loaded at physical ARM address 0x00000000
* The RAM Disk is initially set to 256MB
* The HEAP is initially set to 256MB


## Execution context

* Spectrum +4 runs at EL3
* MMU is not enabled
* EL3 data cache is enabled
* EL3 instruction cache is enabled
* Currently interrupts are not enabled (keyboard routines not yet written)


# Code organisation

* All Spectrum +4 routines are written in aarch64 assembly (GNU assembler
  syntax).
* The Spectrum +4 source code is under the `/src/spectrum4` directory.
* The build and test directives live in the various `Tup*` files scattered
  throughout the repository (tup build system is used - see
  [Building](#building))
* As much as possible, the naming of system variables and routines, and the
  ordering of routines, match the disassembly in the
  `src/spectrum128k/roms/romX.s` files.
* Each ported routine contains a comment giving the label of the associated
  Spectrum 128K routine that it was ported from. The label is an `L` followed
  by the 16 bit hexadecimal address of the original Spectrum 128K routine.


## Building

To build/test everything, simply run `./tup-under-docker.sh`. This requires
that [`docker`](https://www.docker.com/) is installed on your system. It simply
calls [`tup`](http://gittup.org/tup/index.html) inside a docker container that
contains [all required build/test dependencies](docker/Dockerfile). See
`./tup-under-docker.sh -h` for more options.

If you prefer to use a native toolchain, or cannot run docker/amd64 containers
on your host (e.g. if building/testing directly on a Raspberry Pi) then see
[Building Without Docker](docs/building-without-docker.md).


## Running

After building using one of the methods above, the following distribution
files/directories will be updated:

  * Directory `src/spectrum4/dist/debug` contains a debug and release version of
    Spectrum +4, which logs debug messages to Mini UART, and performs a short
    demo on start up.
  * Directory `src/spectrum128k/tests` contains Spectrum 128K casette tape images
    (*.tzx files) and casette tape audio samples (*.wav files) for running the
    Spectrum 128K unit tests under a Spectrum 128K emulator (such as FUSE or
    Retro Virtual Machine) or on a real Spectrum 128K machine.
  * Directory `/src/spectrum4/dist/release` contains a release version of Spectrum
    +4, without debug logging, nor a start up demo.
  * Directory `/src/spectrum4/targets` contains Raspberry Pi 3B kernel images
    for running unit tests, either under QEMU, or on a real Raspberry Pi.

In order to run the debug and/or release builds of Spectrum +4 on an actual
Raspbery Pi 3B, either copy the contents of the given distribution directory to
a formatted SD card, or serve the directory contents over TFTP to a suitably
configured Raspberry Pi that has been configured to network boot. The
[github.com/spectrum4/notes](https://github.com/spectrum4/notes#5-rpi-3b-bootloading)
project has some information about that type of setup, if you are interested.

Alternatively, to run Spectrum +4 under QEMU instead of a real Raspberry Pi 3B,
run something like:

```
$ qemu-system-aarch64 -M raspi3b -kernel src/spectrum4/targets/qemu-debug.elf -serial null -serial stdio
```

Note, __you will likely need QEMU version 5.2.0 or later__. Also note that the `.elf`
file is passed to the `-kernel` option, rather than the `.img` file, in order that
QEMU loads the kernel at address 0x0 rather than 0x80000, which seems not to be
possible when passing the `.img` file directly.
