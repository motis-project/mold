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

# Skip if libc is musl because musl does not fully support GNU-style
# symbol versioning.
echo 'int main() {}' | $CC -o $t/exe -xc -
readelf --dynamic $t/exe | grep -q ld-musl && { echo OK; exit; }

cat <<EOF | $CC -fPIC -c -o $t/a.o -xc -
int foo1() { return 1; }
int foo2() { return 2; }
int foo3() { return 3; }

__asm__(".symver foo1, foo@VER1");
__asm__(".symver foo2, foo@VER2");
__asm__(".symver foo3, foo@@VER3");
EOF

echo 'VER1 { local: *; }; VER2 { local: *; }; VER3 { local: *; };' > $t/b.ver
$CC -B. -shared -o $t/c.so $t/a.o -Wl,--version-script=$t/b.ver

cat <<EOF | $CC -c -o $t/d.o -xc -
#include <stdio.h>

int foo1();
int foo2();
int foo3();
int foo();

__asm__(".symver foo1, foo@VER1");
__asm__(".symver foo2, foo@VER2");
__asm__(".symver foo3, foo@VER3");

int main() {
  printf("%d %d %d %d\n", foo1(), foo2(), foo3(), foo());
}
EOF

$CC -B. -o $t/exe $t/d.o $t/c.so
$QEMU $t/exe | grep -q '^1 2 3 3$'

echo OK
