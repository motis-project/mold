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
mold="$(pwd)/ld64.mold"
t=out/test/macho/$testname
mkdir -p $t

cat <<EOF | $CC -o $t/a.o -c -xc -
#include <stdio.h>

static int foo[100];

int main() {
  foo[1] = 5;
  printf("%d %d %p\n", foo[0], foo[1], foo);
}
EOF

clang -fuse-ld="$mold" -o $t/exe $t/a.o
$QEMU $t/exe | grep -q '^0 5 '

echo OK
