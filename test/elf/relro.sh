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

cat <<EOF | $CC -c -xc -o $t/a.o -
#include <stdio.h>
int main() {
  printf("Hello world\n");
}
EOF

$CC -B. -o $t/exe1 $t/a.o -Wl,-z,relro,-z,lazy
$QEMU $t/exe1 | grep -q 'Hello world'
readelf --segments -W $t/exe1 > $t/log1
grep -q 'GNU_RELRO ' $t/log1

$CC -B. -o $t/exe2 $t/a.o -Wl,-z,relro,-z,now
$QEMU $t/exe2 | grep -q 'Hello world'
readelf --segments -W $t/exe2 > $t/log2
grep -q 'GNU_RELRO ' $t/log2

$CC -B. -o $t/exe3 $t/a.o -Wl,-z,norelro
$QEMU $t/exe3 | grep -q 'Hello world'
readelf --segments -W $t/exe3 > $t/log3
! grep -q 'GNU_RELRO ' $t/log3 || false

echo OK
