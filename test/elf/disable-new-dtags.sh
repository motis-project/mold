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

cat <<EOF | $CC -o $t/a.o -c -xc -fPIC -
void foo() {}
EOF

$CC -B. -shared -o $t/b.so $t/a.o -Wl,-rpath=/foo
readelf --dynamic $t/b.so | grep -q 'RUNPATH.*/foo'

$CC -B. -shared -o $t/b.so $t/a.o -Wl,-rpath=/foo -Wl,-enable-new-dtags
readelf --dynamic $t/b.so | grep -q 'RUNPATH.*/foo'

$CC -B. -shared -o $t/b.so $t/a.o -Wl,-rpath=/foo -Wl,-disable-new-dtags
readelf --dynamic $t/b.so | grep -q 'RPATH.*/foo'

echo OK
