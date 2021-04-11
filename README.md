# ZX Spectrum +4

A modern-day ZX Spectrum OS rewritten from scratch in ARM assembly (aarch64) to
run natively on RPi +3B. Based on the Spectrum 128K.

If you are not familiar with the ZX Spectrum computer from the 1980's, there
are some excellent emulators around, such as [Retro Virtual
Machine](http://www.retrovirtualmachine.org/), and even some very good online
emulators that you can run directly in your browser.

For more information about the history and development of this project, see
https://github.com/spectrum4/notes.

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
    * Each character cell may FLASH or not
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
* The majority of code is in `/src/rom0.s` and `/src/rom1.s` which are a
  translation of the original Spectrum 128K ROM routines.
* As much as possible, the naming of system variables and routines, and
  the ordering of routines, match the disassembly documents cited in the
  `romX.s` files.
* The definition of each routine has a comment with the label of the associated
  disassembly, to map back to the original routine. The label is an `L`
  followed by the 64 bit address of the routine in hexadecimal, for convenient
  mapping back to the original Spectrum 128K disassembly code.

## Building

You can either build under docker (simplest) or natively on your host, if you
are prepared to install all of the required toolchains.

### Building under Docker (linux/amd64) (recommended)

* Make sure `docker` is installed, and is in your `PATH`
* Run `./docker.sh` from the root folder of the repository to build and test

### Building natively on your host

This alternative version is suitable for those who prefer to use a native
toolchain, or cannot run docker/amd64 containers for some reason (e.g. if
building/testing directly on a Raspberry Pi).

You will require an aarch64 toolchain in your PATH, including the following
tools:

  * `aarch64-none-elf-as`
  * `aarch64-none-elf-ld`
  * `aarch64-none-elf-readelf`
  * `aarch64-none-elf-objcopy`
  * `aarch64-none-elf-objdump`

If your toolchain has a different prefix to "aarch64-none-elf-" then export
environment variable `AARCH64_TOOLCHAIN_PREFIX` containing the prefix you wish
to use instead.  If you wish to use no prefix at all (`as`, `ld`, `readelf`,
`objcopy`, `objdump`) because you are e.g. building on a Raspberry Pi directly,
explicitly set `AARCH64_TOOLCHAIN_PREFIX` to the empty string:

```
$ export AARCH64_TOOLCHAIN_PREFIX=''
```

You will also need a z80 toolchain in your PATH, and `fuse`, for running the
Spectrum 128K unit tests against an emulated Spectrum 128K:

  * `fuse`
  * `z80-unknown-elf-as`
  * `z80-unknown-elf-ld`
  * `z80-unknown-elf-readelf`
  * `z80-unknown-elf-objcopy`
  * `z80-unknown-elf-objdump`

Just as above for the aarch64 toolchain, you can also use a different prefix
than `z80-unknown-elf-` for the z80 toolchain by exporting the
`Z80_TOOLCHAIN_PREFIX` environment variable.

Note, GNU gas assembly syntax is assumed, so some z80 assemblers may use
incompatible syntax. GNU gas assembly syntax was chosen for this project to
keep the z80 and aarch64 assembly as closely aligned as possible.

You will also require:

  * `bash`
  * `cat`
  * `cmp`
  * `cp`
  * `curl`
  * `dirname`
  * `env`
  * `find`
  * `go`
  * `head`
  * `hexdump`
  * `mkdir`
  * `mv`
  * `rm`
  * `sed`
  * `sleep`
  * `sort`
  * `wc`
  * `which` (which likely in turn requires `/bin/sh`)

To build, run `./all.sh` from the root folder to build everything.

## Running

After building using one of the methods above, the following distribution
files/directories will be updated:

  * file `/dist/z80/runtests.tzx` contains a Spectrum 128K casette tape image
    for running the Spectrum 128K unit tests (see repository `/tests`
    directory) under a Spectrum 128K emulator (such as FUSE)
  * directory `/dist/aarch64/debug` contains a debug version of Spectrum +4,
    which logs debug messages to Mini UART, runs unit tests and performs a
    short demo on start up
  * directory `/dist/aarch64/release` contains a release version of Spectrum
    +4, without debug logging, unit tests, nor a start up demo

In order to run the debug and/or release builds of Spectrum +4 on an actual
Raspbery Pi 3B, either copy the contents of the given distribution directory to
a formatted SD card, or serve the directory contents over TFTP to a suitably
configured Raspberry Pi that has been configured to network boot. The
[github.com/spectrum4/notes](https://github.com/spectrum4/notes#5-rpi-3b-bootloading)
project has some information about that type of setup, if you are interested.
