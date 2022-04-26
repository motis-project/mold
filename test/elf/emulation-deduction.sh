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

# Skip if target is not x86-64
[ $MACHINE = x86_64 ] || { echo skipped; exit; }

cat <<EOF | $CC -o $t/a.o -c -xc -
void _start() {}
EOF

"$mold" -o $t/exe $t/a.o
readelf --file-header $t/exe | grep -qi x86-64

echo OK
