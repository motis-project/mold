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

# We need to implement R_386_GOT32X relaxation to support PIE on i386
[ $MACHINE = i386 ] && { echo skipped; exit; }

[ $MACHINE = aarch64 ] && { echo skipped; exit; }

cat <<EOF | $CC -o $t/a.o -c -xc - -fPIE
#include <stdio.h>
int main() {
  printf("Hello world\n");
}
EOF

# Skip if the system does not support -static-pie
$CC -o $t/exe1 $t/a.o -static-pie >& /dev/null || { echo skipped; exit; }
$QEMU $t/exe1 >& /dev/null || { echo skipped; exit; }

$CC -B. -o $t/exe2 $t/a.o -static-pie
$QEMU $t/exe2 | grep -q 'Hello world'

echo OK
