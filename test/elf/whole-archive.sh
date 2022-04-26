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
.globl _start
_start:
EOF

echo 'int fn1() { return 42; }' | $CC -o $t/b.o -c -xc -
echo 'int fn2() { return 42; }' | $CC -o $t/c.o -c -xc -

rm -f $t/d.a
ar cr $t/d.a $t/b.o $t/c.o

$CC -B. -nostdlib -o $t/exe $t/a.o $t/d.a

readelf --symbols $t/exe > $t/readelf
! grep -q fn1 $t/readelf || false
! grep -q fn2 $t/readelf || false

$CC -B. -nostdlib -o $t/exe $t/a.o -Wl,--whole-archive $t/d.a

readelf --symbols $t/exe > $t/readelf
grep -q fn1 $t/readelf
grep -q fn2 $t/readelf

$CC -B. -nostdlib -o $t/exe $t/a.o -Wl,--whole-archive \
  -Wl,--no-whole-archive $t/d.a

readelf --symbols $t/exe > $t/readelf
! grep -q fn1 $t/readelf || false
! grep -q fn2 $t/readelf || false

echo OK
