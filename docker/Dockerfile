FROM ubuntu:20.04 AS spectrum4_too_much

# curl has been built as a standalone executable in build.sh
RUN mkdir -p /usr/local/bin
ENV PATH $PATH:/usr/local/bin
COPY build/curl /usr/local/bin

RUN apt-get update
RUN apt-get upgrade -y

# xz-utils is needed by tar command below
RUN apt-get install -y wget xz-utils

# install gcc cross-compiler toolchain
RUN wget -nv -O gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf.tar.xz 'https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf.tar.xz?revision=ea238776-c7c7-43be-ba0d-40d7f594af1f&la=en&hash=2937ED76D3E6B85BA511BCBD46AE121DBA5268F3'
RUN tar xvf gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf.tar.xz

# move gcc tools into /usr/local/bin
RUN mv /gcc-arm-9.2-2019.12-x86_64-aarch64-none-elf/bin/* /usr/local/bin

# for all executables required, find their library dependencies (using ldd),
# and copy everything needed into /dist
RUN for tool in /bin/sh aarch64-none-elf-as aarch64-none-elf-ld aarch64-none-elf-objcopy aarch64-none-elf-objdump aarch64-none-elf-readelf bash curl cat cp dirname env find mkdir rm sed which; do file=$(which ${tool}); ldd $file 2>/dev/null || true; echo $file; done | sed 's/(.*//' | sed 's/^[^\/]*//' | grep '^/' | sort -u | while read line; do echo "${line}"; mkdir -p "$(dirname "/dist${line}")"; cp -vp "${line}" "/dist${line}"; done

# add certificates needed by curl to /dist
RUN mkdir -p /dist/etc/ssl/certs && cp -vp /etc/ssl/certs/ca-certificates.crt /dist/etc/ssl/certs/ca-certificates.crt

# to aid future troubleshooting, show uncompressed size of /dist
RUN du -sh /dist

# now build a fresh image, with just the files in /dist
FROM scratch
COPY --from=spectrum4_too_much /dist/ /
ENV PATH /bin:/usr/bin:/usr/local/bin
