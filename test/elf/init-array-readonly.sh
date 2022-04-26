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
.section .init_array,"aw",@init_array
.p2align 3
.globl init1
.quad init1
EOF

# GNU assembler automatically turns on W bit if the section name
# is `.init_array`, so avoid using that name in assembly.
cat <<EOF | $CC -c -o $t/b.o -x assembler -
.section .init_xxxxx,"a",@progbits
.p2align 3
.globl init2
.quad init2
EOF

perl -i -pe s/init_xxxxx/init_array/g $t/b.o

cat <<EOF | $CC -c -o $t/c.o -xc -
#include <stdio.h>

void init1() { printf("init1 "); }
void init2() { printf("init2 "); }

int main() {
  return 0;
}
EOF

$CC -B. -o $t/exe $t/a.o $t/b.o $t/c.o
$QEMU $t/exe | grep -q 'init1 init2'

echo OK
