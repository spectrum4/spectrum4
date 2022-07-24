FROM ubuntu:20.04 AS spectrum4_too_much
MAINTAINER Pete Moore <petemoore@gmx.net>

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /usr/local/bin
ENV PATH $PATH:/usr/local/bin

RUN apt-get update
RUN apt-get upgrade -y

# xz-utils is needed by tar command below
# build-essential is needed for building z80 binutils and libspectrum/fuse
# libglib2.0 is needed for building libspectrum
# bsdmainutils contains hexdump
# libpixman-1-dev and meson needed for building qemu
# libaudiofile-dev is required by tape2wav in fuse-utils
RUN apt-get install -y wget xz-utils build-essential libglib2.0 bsdmainutils libpixman-1-dev meson libaudiofile-dev fuse3 libfuse3-dev unzip

RUN case "$(uname -m)" in x86_64) ARCH=amd64;; *) ARCH=$(uname -m);; esac && wget -O /usr/local/bin/curl https://github.com/moparisthebest/static-curl/releases/download/v7.78.0/curl-${ARCH} && chmod a+x /usr/local/bin/curl

# install libspectrum (needed by fuse)
# RUN curl -L 'https://sourceforge.net/projects/fuse-emulator/files/libspectrum/1.4.4/libspectrum-1.4.4.tar.gz/download' > libspectrum-1.4.4.tar.gz && tar xvfz libspectrum-1.4.4.tar.gz && cd libspectrum-1.4.4 && ./configure && make && make install && cd ..
RUN apt-get install -y libspectrum-dev

# install (headless) fuse which includes ROMs
RUN curl -L 'https://sourceforge.net/projects/fuse-emulator/files/fuse/1.5.7/fuse-1.5.7.tar.gz/download' > fuse-1.5.7.tar.gz && tar xvfz fuse-1.5.7.tar.gz && cd fuse-1.5.7 && ./configure --with-null-ui && make && make install && cd ..

# install fuse-utils to get tape2wav
RUN curl -L 'https://sourceforge.net/projects/fuse-emulator/files/fuse-utils/1.4.3/fuse-utils-1.4.3.tar.gz/download' > fuse-utils-1.4.3.tar.gz && tar xvfz fuse-utils-1.4.3.tar.gz && cd fuse-utils-1.4.3 && ./configure && make && make install && cd ..

# install gcc cross-compiler toolchain
RUN wget -nv -O "gcc-arm-11.2-2022.02-$(uname -m)-aarch64-none-elf.tar.xz" "https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/gcc-arm-11.2-2022.02-$(uname -m)-aarch64-none-elf.tar.xz"
RUN tar xvf "gcc-arm-11.2-2022.02-$(uname -m)-aarch64-none-elf.tar.xz"

# move gcc tools into /usr/local/bin
RUN mv "/gcc-arm-11.2-2022.02-$(uname -m)-aarch64-none-elf/bin"/* /usr/local/bin

# install z80 cross-compiler binutils
RUN wget -O binutils.tar.gz https://ftpmirror.gnu.org/binutils/binutils-2.37.tar.gz && tar zvfx binutils.tar.gz && cd binutils-2.37 && ./configure --target=z80-unknown-elf --disable-werror && make && make install && cd ..

RUN curl -L 'https://download.qemu-project.org/qemu-5.2.0.tar.xz' > qemu-5.2.0.tar.xz && tar xvf qemu-5.2.0.tar.xz && mkdir qemu-5.2.0/build && cd qemu-5.2.0/build && ../configure --target-list=aarch64-softmmu --disable-vnc && make -j4 && make install && cd ..

RUN curl -L 'https://github.com/gittup/tup/archive/43e19d62656a2c20fbdfb75989a9b681c5b6b216.zip' > tup.zip && unzip tup.zip && cd tup-* && CFLAGS="-g" ./build.sh && mv build/tup /usr/local/bin && cd ..
# RUN apt-get install -y software-properties-common && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 486D3664 && apt-add-repository 'deb http://ppa.launchpad.net/anatol/tup/ubuntu precise main' && apt-get update --allow-insecure-repositories && apt-get install tup

# add certificates needed by curl to /dist
RUN mkdir -p /dist/etc/ssl/certs && cp -vp /etc/ssl/certs/ca-certificates.crt /dist/etc/ssl/certs/ca-certificates.crt

# add fuse ROMs
RUN mkdir -p /dist/usr/local/share && mv /usr/local/share/fuse /dist/usr/local/share/fuse

# add qemu keymaps etc
RUN mv /usr/local/share/qemu /dist/usr/local/share/qemu

# add C.UTF-8 locale
RUN mkdir -p /dist/usr/lib/locale/ && mv /usr/lib/locale/C.UTF-8 /dist/usr/lib/locale/C.UTF-8

# install go 1.16.15
RUN case "$(uname -m)" in x86_64) ARCH=amd64;; aarch64) ARCH=arm64;; esac && mkdir -p /dist/usr/lib && cd /dist/usr/lib && curl -L "https://golang.org/dl/go1.16.15.linux-${ARCH}.tar.gz" > "go1.16.15.linux-${ARCH}.tar.gz" && tar xvfz "go1.16.15.linux-${ARCH}.tar.gz" && rm "go1.16.15.linux-${ARCH}.tar.gz"
RUN mkdir -p /dist/tmp

# install shfmt
RUN /dist/usr/lib/go/bin/go install mvdan.cc/sh/v3/cmd/shfmt@latest && mv ${HOME}/go/bin/shfmt /usr/local/bin/shfmt 

# for all executables required, find their library dependencies (using ldd),
# and copy everything needed into /dist
# LD_LIBRARY_PATH needed for ldd to find libspectrum.so.8
# ENV LD_LIBRARY_PATH /usr/local/lib
RUN for tool in /bin/sh aarch64-none-elf-as aarch64-none-elf-ld aarch64-none-elf-objcopy aarch64-none-elf-objdump aarch64-none-elf-readelf bash cat cmp cp curl dirname env find fuse fusermount3 head hexdump ln md5sum mkdir mv qemu-system-aarch64 rm sed shfmt sleep sort tape2wav tup wc which z80-unknown-elf-as z80-unknown-elf-ld z80-unknown-elf-objcopy z80-unknown-elf-objdump z80-unknown-elf-readelf; do file=$(which ${tool}); ldd $file 2>/dev/null || true; echo $file; done | sed 's/(.*//' | sed 's/^[^\/]*//' | grep '^/' | sort -u | while read line; do echo "${line}"; mkdir -p "$(dirname "/dist${line}")"; cp -vp "${line}" "/dist${line}"; done

# now build a fresh image, with just the files in /dist
FROM scratch
COPY --from=spectrum4_too_much /dist/ /
ENV PATH /usr/lib/go/bin:/bin:/usr/bin:/usr/local/bin
ENV GOROOT /usr/lib/go
# needed for fuse to find libspectrum.so.8
# ENV LD_LIBRARY_PATH /usr/local/lib
