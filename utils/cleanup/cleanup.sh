#!/bin/bash

cd "$(dirname "${0}")"

go install

for rom in rom0 rom1; do
  "$(go env GOPATH)/bin/cleanup" "../../src/spectrum128k/${rom}.s"
done

../../docker.sh

for rom in rom1; do
  z80-unknown-elf-readelf -W -a ../../build/spectrum128k/${rom}.elf | grep LOCAL | grep 'DEFAULT  *1 ' | grep NOTYPE | while read a addr b c d e f name; do echo $addr $name; done > x
  cat x | while read a b; do
    echo $a
  done | sort -u | while read addr; do
    lines=$(cat x | grep "^${addr}" | wc -l)
    if [ "${lines}" == 2 ]; then
      cat x | grep "^${addr}" | LC_ALL=C sort -u > $addr.labels
    fi
  done
  for file in *.labels; do
    OLD=$(cat $file | sed -n 1p | sed 's/.* //')
    NEW=$(cat $file | sed -n 2p | sed 's/.* //')
    NEW_LENGTH=${#NEW}
    OLD_LONGER="${OLD}          "
    OLD_LONGER="${OLD_LONGER:0:${NEW_LENGTH}}"
    cat ../../src/spectrum128k/${rom}.s | sed "s/^${OLD}:/${OLD//?/ } /" > xx
    if [ "${NEW_LENGTH}" -gt 5 ]; then
      cat xx | sed "s/${OLD_LONGER}/${NEW}/" > yy
      mv yy xx
    fi
    cat xx | sed "s/${OLD}/${NEW}/g" > ../../src/spectrum128k/${rom}.s
  done
done

rm x xx *.labels

../../docker.sh
