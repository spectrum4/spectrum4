#!/usr/bin/env bash

# This file is part of the Spectrum +4 Project.
# Licencing information can be found in the LICENCE file
# (C) 2021 Spectrum +4 Authors. All rights reserved.

#################################################################################
# This script is an attempt to bootstrap a macOS environment with all the tools #
# needed for building/testing Spectrum +4 natively (i.e. outside of docker).    #
#################################################################################

function retry {
  set +e
  local n=0
  local max=10
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed" >&2
        sleep_time=$((2 ** n))
        echo "Sleeping $sleep_time seconds..." >&2
        sleep $sleep_time
        echo "Attempt $n/$max:" >&2
      else
        echo "Failed after $n attempts." >&2
        exit 67
      fi
    }
  done
  set -e
}

set -eu
set -o pipefail

if [ "$(uname)" != 'Darwin' ]; then
  echo "This script is designed to run on macOS. The uname utility reports that this host is running '$(uname)', but should be 'Darwin'. Exiting." >&2
  exit 64
fi

PREP_DIR="$(mktemp -t bootstrap-spectrum4-dev.XXXXXXXXXX -d)"
echo "Preparing installation inside temp directory: '${PREP_DIR}' ..."
cd "${PREP_DIR}"

# install homebrew
which brew > /dev/null 2>&1 || bash -c "$(retry curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# This may not be needed in general, but I had issues on macOS Big Sur (version
# 11.6.4) that were resolved by installing GNU make.
# in case GNU make is installed outside of brew, don't just brew install it
if ! hash gmake 2> /dev/null; then
  brew install make
fi

# install libspectrum (needed for building tape2wav and fuse)
if ! hash fuse 2> /dev/null || ! hash tape2wav 2> /dev/null; then

  # Note, libspectrum may already be installed, but not trivial to test if it
  # is working and all dependencies exist and are working, so reinstall. This
  # is a reasonably small overhead, and libspectrum is unlikely to be present
  # anyway, if neither fuse nor fuse-utils are present. So prefer
  # safety/reliability over time-saving here.

  # Install from source, since e.g. fuse version requires newer version than in
  # brew.

  # Note, audiofile is technically not needed for libspectrum, but needed later
  # for tape2wav. By installing it here, libspectrum and fuse will also inherit
  # libaudio support. Although not technically needed for libspectrum/fuse, if
  # we only installed audiofile immediately prior to building tape2wav, we
  # would get inconsistent results if libspectrum or fuse would be later
  # reinstalled, since audiofile support would get included. So include it from
  # the start, to avoid unexpected changes when reinstalling software.
  brew install automake audiofile
  retry git clone https://git.code.sf.net/p/fuse-emulator/libspectrum
  cd libspectrum
  git checkout e85c934f585cb8caff5eeab55899617b606abfeb
  ./autogen.sh
  ./configure
  gmake -j4
  sudo gmake install
  cd ..
fi

if ! hash fuse 2> /dev/null; then

  # Install (headless) fuse which includes ROMs.
  # Note, we build from source since we need to specify --with-null-ui so that
  # windows aren't displayed when unit tests run. This also picks up newer
  # fixes which were missing from the previous release, e.g.
  #   * https://github.com/spectrum4/spectrum4/issues/10#issuecomment-1902378210

  # brew install fuse-emulator       <- don't do this!

  # libspectrum and automake already installed above
  retry git clone https://git.code.sf.net/p/fuse-emulator/fuse
  cd fuse
  git checkout 54bb53145a42f054dd7b5e5aa0bfa2d41020e265
  ./autogen.sh
  ./configure --with-null-ui
  gmake -j4
  sudo gmake install
  cd ..
fi

# install tape2wav
if ! hash tape2wav 2> /dev/null; then
  # libspectrum and automake already installed above
  retry curl -fsSL 'https://sourceforge.net/projects/fuse-emulator/files/fuse-utils/1.4.3/fuse-utils-1.4.3.tar.gz/download' > fuse-utils-1.4.3.tar.gz
  tar xvfz fuse-utils-1.4.3.tar.gz
  cd fuse-utils-1.4.3
  ./configure
  gmake -j4
  sudo gmake install
  cd ..
fi

# in case go is installed outside of brew, don't just brew install it
if ! hash go 2> /dev/null; then
  brew install go
fi

# in case qemu is installed outside of brew, don't just brew install it
if ! hash qemu-system-aarch64 2> /dev/null; then
  brew install qemu || (
    echo
    echo "Note, if you are using a very old macOS version (such as High Sierra) you might"
    echo "have better luck installing QEMU via macports (although the version I tried"
    echo "didn't open a display window - perhaps gtk disabled in ./configure ?)"
    echo
    echo "See https://ports.macports.org/port/qemu/"
  )
fi

# This is a bash script, so bash must be installed otherwise this script wouldn't run.
# However, there have been problems with bash 3.2.57(1)-release (arm64-apple-darwin21):
#   * https://github.com/gittup/tup/issues/466#issuecomment-1195105183
# so let's make sure bash 5 or later is installed.
# Note, in case bash 5+ is installed outside of brew, don't just brew install it.
if [ $(bash --version | sed -n 's/.*version //p' | head -1 | sed 's/\..*//') -lt 5 ]; then
  brew install bash
fi

# install binutils for targets z80-unknown-elf and aarch64-none-elf
z80_tools_absent=false
aarch64_tools_absent=false
for tool in as ld readelf objcopy objdump; do
  hash "z80-unknown-elf-${tool}" 2> /dev/null || z80_tools_absent=true
  hash "aarch64-none-elf-${tool}" 2> /dev/null || aarch64_tools_absent=true
done

if ${z80_tools_absent} || ${aarch64_tools_absent}; then

  # This makeinfo hack avoids needing to install makeinfo 6.8 or higher for binutils 2.41.
  # See:
  #   * https://sourceware.org/bugzilla/show_bug.cgi?id=30703#c16
  TEMP_BIN_DIR="${PREP_DIR}/temp-bin-dir"
  mkdir -p "${TEMP_BIN_DIR}"
  PATH="${TEMP_BIN_DIR}:${PATH}"
  ln -s /usr/bin/true "${TEMP_BIN_DIR}/makeinfo"

  retry curl -fsSL 'https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.gz' > binutils-2.41.tar.gz
  tar xfz binutils-2.41.tar.gz

  if ${z80_tools_absent}; then
    mkdir binutils-z80-build
    cd binutils-z80-build
    ../binutils-2.41/configure \
      --target=z80-unknown-elf \
      --disable-werror
    gmake -j4
    sudo gmake install
    cd ..
  fi

  if ${aarch64_tools_absent}; then
    mkdir binutils-aarch64-build
    cd binutils-aarch64-build
    ../binutils-2.41/configure \
      --target=aarch64-none-elf
    gmake -j4
    sudo gmake install
    cd ..
  fi
fi

# install md5sum
if ! hash md5sum 2> /dev/null; then
  echo '#!/usr/bin/env bash
  md5 -r "${@}"' > md5sum
  chmod a+x md5sum
  sudo mv md5sum /usr/local/bin/md5sum
fi

# install tup
if ! hash tup 2> /dev/null; then
  # macfuse is needed by tup
  brew install --cask macfuse
  brew install pcre
  retry curl -fsSL 'https://github.com/gittup/tup/archive/b037d4b211de6025703b77c3287b76159656ef22.zip' > tup.zip
  unzip tup.zip
  cd tup-*
  if ! ./bootstrap.sh; then
    echo
    echo "Now you (probably) need to enable kernel extensions for macFUSE. Follow the guide here: "
    echo
    echo "  * https://www.m3datarecovery.com/mac-bitlocker/enable-system-extension-m1-mac.html"
    echo
    echo "Note, that guide is for BitLocker for Mac, but the same process applies for granting"
    echo "macFUSE permission as a kernel extension."
    echo
    echo "After granting access, run this script ($0) again to complete the installation."
    exit 65
  fi
  sudo mv build/tup /usr/local/bin
  cd ..
fi

# install shfmt
if ! hash shfmt 2> /dev/null; then
  go install mvdan.cc/sh/v3/cmd/shfmt@latest
  sudo mv $(go env GOPATH)/bin/shfmt /usr/local/bin
fi

cd
echo "Deleting '${PREP_DIR}' ..."
rm -rf "${PREP_DIR}"

echo
echo 'Note, if you also want to debug tests, you can install aarch64-none-elf-gdb'
echo 'too, or you can just run it from the spectrum4 docker container. To install it'
echo 'locally, see:'
echo
echo '  * https://www.npmjs.com/package/@xpack-dev-tools/aarch64-none-elf-gcc'
echo '  * https://xpack.github.io/aarch64-none-elf-gcc/releases/'
echo
echo "Installation completed successfully."
