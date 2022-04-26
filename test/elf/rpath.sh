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

cat <<EOF | $CC -o $t/a.o -c -x assembler -
  .text
  .globl main
main:
  nop
EOF

$CC -B. -o $t/exe $t/a.o \
  -Wl,-rpath,/foo -Wl,-rpath,/bar -Wl,-R/no/such/directory -Wl,-R/

readelf --dynamic $t/exe | \
  fgrep -q 'Library runpath: [/foo:/bar:/no/such/directory:/]'

echo OK
