<!--
This file is part of the Spectrum +4 Project.
Licencing information can be found in the LICENCE file
(C) 2021 Spectrum +4 Authors. All rights reserved.
-->

# Setting up a development environment for Spectrum +4

## Recommended: build and test using docker

In order to build and test Spectrum +4, all you need is docker. Then simply
run `./tup-under-docker.sh` from the root directory of the repository.

## Building/testing natively on your host

For those who prefer to use a native toolchain rather than docker, or cannot
run docker arm64/amd64 containers for some reason, this section will guide you
through the process of installing all of the required tools on your system.

You will require an aarch64 toolchain in your PATH, including the following
tools from [binutils](https://www.gnu.org/software/binutils/):

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

```bash
$ export AARCH64_TOOLCHAIN_PREFIX=''
```

You will also need a z80 toolchain in your PATH from
[binutils](https://www.gnu.org/software/binutils/), and the Free Unix Spectrum
Emulator (`fuse`), for running the Spectrum 128K unit tests against an emulated
Spectrum 128K:

  * `z80-unknown-elf-as`
  * `z80-unknown-elf-ld`
  * `z80-unknown-elf-readelf`
  * `z80-unknown-elf-objcopy`
  * `z80-unknown-elf-objdump`
  * Free Unix Spectrum Emulator [`fuse`](http://fuse-emulator.sourceforge.net/)

If using gnu binutils, you will require __version 2.36 or later__.

Just as above for the aarch64 toolchain, you can also use a different prefix
than `z80-unknown-elf-` for the z80 toolchain by exporting the
`Z80_TOOLCHAIN_PREFIX` environment variable.

You will also require `qemu-system-aarch64` for running the Spectrum +4 test
suite:

  * [`qemu-system-aarch64`](https://www.qemu.org/) (v5.2.0 or later)

Note, GNU gas assembly syntax is assumed, so some z80 assemblers may use
incompatible syntax. GNU gas assembly syntax was chosen for this project to
keep the z80 and aarch64 assembly as closely aligned as possible.

You will also require these tools from
[coreutils](https://www.gnu.org/software/coreutils/):

  * `cat`
  * `cp`
  * `dirname`
  * `env`
  * `head`
  * `ln`
  * `md5sum`
  * `mkdir`
  * `mv`
  * `rm`
  * `sleep`
  * `sort`
  * `wc`

Plus these additional tools:

  * [`bash`](https://www.gnu.org/software/bash/)
  * [`cmp`](https://www.gnu.org/software/diffutils/) (from diffutils)
  * [`curl`](https://github.com/curl/curl/)
  * [`find`](https://www.gnu.org/software/findutils/) (from findutils)
  * [`go`](https://golang.org/)
  * [`hexdump`](https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git/)
  (from util-linux)
  * [`sed`](https://www.gnu.org/software/sed/)
  * [`shfmt`](https://github.com/mvdan/sh/tree/master/cmd/shfmt)
  * [`tape2wav`](https://sourceforge.net/p/fuse-emulator/fuse-utils/ci/master/tree/)
  (from fuse-utils)
  * [`tup`](http://gittup.org/tup/)
  * [`which`](https://carlowood.github.io/which/) (which likely in turn requires
  [`/bin/sh`](https://www.gnu.org/software/bash/))

To check your environment is suitable for building, run
[`./check-env.sh`](check-env.sh).

Run `./check-env.sh -h` to see additional options.

Once the output of `check-env.sh` says that your environment is suitably
configured, you can build simply by running `tup` in any directory of the
repository.

Note, if you switch between running `tup` and `./tup-under-docker.sh`,
everything will be rebuilt, so you are usually better off sticking with one
command or the other.

## macOS

Running the [`bootstrap-macOS.sh`](macOS/bootstrap-macOS.sh) script should get
you most of the way.  Please raise an issue in github if you encounter any
problems.

## Ubuntu

Running the [`bootstrap-ubuntu.sh`](ubuntu/bootstrap-ubuntu.sh) script should
get you most of the way.  Please raise an issue in github if you encounter any
problems.

## Windows

Probably the simplest solution for is to install [WSL
2](https://docs.microsoft.com/en-us/windows/wsl/install) and run an Ubuntu
distribution, and then follow the instructions above for Ubuntu.
