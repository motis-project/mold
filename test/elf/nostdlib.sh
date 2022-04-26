#!/bin/bash
export LC_ALL=C
set -e
CC="${CC:-cc}"
CXX="${CXX:-c++}"
GCC="${GCC:-gcc}"
GXX="${GXX:-g++}"
OBJDUMP="${OBJDUMP:-objdump}"
MACHINE="${MACHINE:-$(uname -m)}"
testname=$(basename "$0" .sh)
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t=out/test/elf/$testname
mkdir -p $t

cat <<EOF | $CC -o $t/a.o -c -xc - -fno-PIE
void _start() {}
EOF

$mold -o $t/exe $t/a.o

readelf -W --sections $t/exe > $t/log
! fgrep -q ' .dynsym ' $t/log || false
! fgrep -q ' .dynstr ' $t/log || false
! fgrep -q ' .got ' $t/log || false

echo OK
