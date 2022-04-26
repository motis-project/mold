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

[ $MACHINE = x86_64 ] || { echo skipped; exit; }

cat <<EOF | $CC -o $t/a.o -c -xc -
#include <stdio.h>

int main() {
  printf("Hello world\n");
  return 0;
}
EOF

$CC -B. -no-pie -o $t/exe1 $t/a.o -Wl,--image-base=0x8000000
$QEMU $t/exe1 | grep -q 'Hello world'
readelf -W --sections $t/exe1 | grep -Eq '.interp\s+PROGBITS\s+0000000008000...\b'

cat <<EOF | $CC -o $t/b.o -c -xc -
void _start() {}
EOF

$CC -B. -no-pie -o $t/exe2 $t/b.o -nostdlib -Wl,--image-base=0xffffffff80000000
readelf -W --sections $t/exe2 | grep -Eq '.interp\s+PROGBITS\s+ffffffff80000...\b'

echo OK
