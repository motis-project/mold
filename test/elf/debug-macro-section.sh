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

cat <<EOF > $t/a.h
#define A 23
#define B 99
EOF

cat <<EOF | $GCC -o $t/b.o -c -xc - -I$t -g3
#include "a.h"
extern int z();
int main () { return z() - 122; }
EOF

cat <<EOF | $GCC -o $t/c.o -c -xc - -I$t -g3
#include "a.h"
int z()  { return A + B; }
EOF

$GCC -B. -o $t/exe $t/b.o $t/c.o
$OBJDUMP --dwarf=macro $t/exe > $t/log
! grep 'DW_MACRO_import -.* 0x0$' $t/log || false

echo OK
