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

cat <<EOF | $CC -c -o $t/a.o -x assembler -
.globl init1, init2, fini1, fini2

.section .init_array,"aw",@init_array
.p2align 3
.quad init1

.section .init_array,"aw",@init_array
.p2align 3
.quad init2

.section .fini_array,"aw",@fini_array
.p2align 3
.quad fini1

.section .fini_array,"aw",@fini_array
.p2align 3
.quad fini2
EOF

cat <<EOF | $CC -c -o $t/b.o -xc -
#include <stdio.h>

void init1() { printf("init1 "); }
void init2() { printf("init2 "); }
void fini1() { printf("fini1\n"); }
void fini2() { printf("fini2 "); }

int main() {
  return 0;
}
EOF

$CC -B. -o $t/exe $t/a.o $t/b.o
$QEMU $t/exe | grep -q 'init1 init2 fini2 fini1'

echo OK
