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

cat <<'EOF' | $CC -c -o $t/a.o -x assembler -
.globl val1, val2, val3

.section .rodata.str1.1,"aMS",@progbits,1
val1:
.ascii "Hello \0"

.section .rodata.str4.4,"aMS",@progbits,4
.align 4
val2:
.ascii "world   \0\0\0\0"

.section .rodata.cst8,"aM",@progbits,8
.align 8
val3:
.ascii "abcdefgh"
EOF

cat <<'EOF' | $CC -c -o $t/b.o -xc -
#include <stdio.h>

extern char val1, val2, val3;

int main() {
  printf("%p %p %p\n", &val1, &val2, &val3);
}
EOF

$CC -B. -o $t/exe $t/a.o $t/b.o

readelf -p .rodata.str $t/exe | grep -q Hello
readelf -p .rodata.str $t/exe | grep -q world
readelf -p .rodata.cst $t/exe | grep -q abcdefgh

echo OK
