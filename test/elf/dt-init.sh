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

[ $MACHINE = riscv64 ] && { echo skipped; exit; }

cat <<EOF | $CC -c -fPIC -o $t/a.o -xc -
void keep();

int main() {
  keep();
}
EOF

cat <<EOF | $CC -c -fPIC -o $t/b.o -xc -
#include <stdio.h>

void init() {
  printf("init\n");
}

void fini() {
  printf("fini\n");
}

void keep() {}
EOF

$CC -B. -o $t/c.so -shared $t/b.o
$CC -B. -o $t/d.so -shared $t/b.o -Wl,-init,init -Wl,-fini,fini

$CC -o $t/exe1 $t/a.o $t/c.so
$CC -o $t/exe2 $t/a.o $t/d.so

$QEMU $t/exe1 > $t/log1
$QEMU $t/exe2 > $t/log2

! grep -q init $t/log1 || false
! grep -q fini $t/log1 || false

grep -q init $t/log2
grep -q fini $t/log2

echo OK
