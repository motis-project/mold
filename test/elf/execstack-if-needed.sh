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

cat <<EOF | $CC -c -xassembler -o $t/a.o -
.globl main
main:
  ret
.section .note.GNU-stack, "x", @progbits
EOF

$CC -B. -o $t/exe $t/a.o >& /dev/null
readelf --segments -W $t/exe | grep -q 'GNU_STACK.* RW '

$CC -B. -o $t/exe $t/a.o -Wl,-z,execstack-if-needed
readelf --segments -W $t/exe | grep -q 'GNU_STACK.* RWE '

echo OK
