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

* All code is written in aarch64 assembly.
* All source codes is under the `/src` directory.
* The build script is `/all.sh` in the top folder.
* The majority of code is in `/src/spectrum4/rom0.s` and `/src/spectrum4/rom1.s`
  which are a translation of the original Spectrum 128K ROM routines.
* As much as possible, the naming of system variables and routines, and
  the ordering of routines, match the disassembly documents cited in the
  `romX.s` files.
* The definition of each routine has a comment with the label of the associated
  disassembly, to map back to the original routine. The label is an `L`
  followed by the 64 bit address of the routine in hexadecimal, for convenient
  mapping back to the original Spectrum 128K disassembly code.


## Building

To build/test everything, simply run `./docker.sh`. This requires that docker
is installed on your system.

To see further help options, run `./docker.sh -h`.

If you prefer to use a native toolchain, or cannot run docker/amd64 containers
on your host (e.g. if building/testing directly on a Raspberry Pi) then see
[Building Without Docker](docs/building_without_docker.md).


## Running

After building using one of the methods above, the following distribution
files/directories will be updated:

  * file `/dist/spectrum128k/runtests.tzx` contains a Spectrum 128K casette
    tape image for running the Spectrum 128K unit tests under a Spectrum 128K
    emulator (such as FUSE) feeding from a static random data sample
  * file `/dist/spectrum128k/runtests.wav` is the same, but for loading on a real
    Spectrum 128K machine (it is an audio file of the casette tape)
  * (for local builds only) additional files with `-cryptorandom` suffixes will be
    generated, which on each build, contain different cryptographically generated
    random data for providing additional fuzzing for test inputs
  * directory `/dist/spectrum4/debug` contains a debug version of Spectrum +4,
    which logs debug messages to Mini UART, runs unit tests and performs a
    short demo on start up
  * directory `/dist/spectrum4/release` contains a release version of Spectrum
    +4, without debug logging, unit tests, nor a start up demo

In order to run the debug and/or release builds of Spectrum +4 on an actual
Raspbery Pi 3B, either copy the contents of the given distribution directory to
a formatted SD card, or serve the directory contents over TFTP to a suitably
configured Raspberry Pi that has been configured to network boot. The
[github.com/spectrum4/notes](https://github.com/spectrum4/notes#5-rpi-3b-bootloading)
project has some information about that type of setup, if you are interested.

Alternatively, to run Spectrum +4 under QEMU instead of a real Raspberry Pi 3B,
run something like:

```
$ qemu-system-aarch64 -M raspi3b -kernel build/spectrum4/kernel8-qemu-debug.elf -serial null -serial stdio
```

Note, __you will likely need QEMU version 5.2.0 or later__.
