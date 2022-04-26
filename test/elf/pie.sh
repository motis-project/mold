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

cat <<EOF | $CC -o $t/a.o -c -xc -fPIE -
#include <stdio.h>

int main() {
  printf("Hello world\n");
  return 0;
}
EOF

$CC -B. -pie -o $t/exe $t/a.o
readelf --file-header $t/exe | grep -q -E '(Shared object file|Position-Independent Executable file)'
$QEMU $t/exe | grep -q 'Hello world'

echo OK
