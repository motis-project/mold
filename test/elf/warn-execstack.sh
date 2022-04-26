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
.section .note.GNU-stack, "x"
EOF

cat <<EOF | $CC -o $t/b.o -c -xc -
int main() {}
EOF

$GCC -B. -o $t/exe $t/a.o $t/b.o 2>&1 | grep -q 'may cause a segmentation fault'

echo OK
