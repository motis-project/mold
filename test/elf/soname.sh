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

cat <<EOF | $CC -fPIC -c -o $t/a.o -xc -
void foo() {}
EOF

$CC -o $t/b.so -shared $t/a.o
readelf --dynamic $t/b.so > $t/log
! fgrep -q 'Library soname' $t/log || false

$CC -B. -o $t/b.so -shared $t/a.o -Wl,-soname,foo
readelf --dynamic $t/b.so | fgrep -q 'Library soname: [foo]'

echo OK
