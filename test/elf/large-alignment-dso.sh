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

[ $MACHINE = i386 -o $MACHINE = arm ] && { echo skipped; exit; }

cat <<EOF | $CC -o $t/a.o -c -xc - -ffunction-sections -fPIC
#include <stdio.h>
#include <stdint.h>

void hello() __attribute__((aligned(32768), section(".hello")));
void world() __attribute__((aligned(32768), section(".world")));

void hello() {
  printf("Hello");
}

void world() {
  printf(" world");
}

void greet() {
  hello();
  world();
}
EOF

$CC -B. -o $t/b.so $t/a.o -shared

cat <<EOF | $CC -o $t/c.o -c -xc -
void greet();
int main() { greet(); }
EOF

$CC -B. -o $t/exe $t/c.o $t/b.so
$QEMU $t/exe | grep -q 'Hello world'

echo OK
