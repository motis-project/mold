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

cat <<EOF | $CC -o $t/a.o -c -xassembler -
.globl get_foo
get_foo:
  lea _TLS_MODULE_BASE_@TLSDESC(%rip), %rax
  call *_TLS_MODULE_BASE_@TLSCALL(%rax)
  lea foo@dtpoff(%rax), %rax
  mov %fs:(%rax), %eax
  ret
.section .tdata, "awT", @progbits
foo:
.long 20
EOF

cat <<EOF | $CC -o $t/b.o -c -xc -
_Thread_local int bar = 3;
EOF

cat <<EOF | $CC -o $t/c.o -c -xc -
#include <stdio.h>

int get_foo();
extern _Thread_local int bar;

int main() {
  printf("%d %d\n", get_foo(), bar);
}
EOF

$CC -B. -o $t/exe1 $t/a.o $t/b.o $t/c.o
$QEMU $t/exe1 | grep -q '^20 3$'

$CC -B. -o $t/exe2 $t/a.o $t/b.o $t/c.o -Wl,-no-relax
$QEMU $t/exe2 | grep -q '^20 3$'

$CC -B. -o $t/d.so $t/a.o -shared
$CC -B. -o $t/exe3 $t/b.o $t/c.o $t/d.so
$QEMU $t/exe3 | grep -q '^20 3$'

echo OK
